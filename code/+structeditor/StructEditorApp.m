classdef StructEditorApp < handle & ...
        matlab.mixin.SetGetExactNames & ...
        structeditor.mixin.HasTheme
    
    properties (Access = private, Description = "Stylable UI Components")
        % UIFigure:
        % This is the figure handle for the window of this app
        UIFigure matlab.ui.Figure
      
        % MainGridLayout:
        % The main grid layout of the UI Figure where all sub containers
        % are placed
        MainGridLayout matlab.ui.container.GridLayout

        % ControlPanel:
        % A panel holding "custom components / containers" with ui controls.
        ControlPanel matlab.ui.container.Panel

        % SidebarPanel:
        % A panel holding a sidebar menu for navigating nested structs /
        % objects. Note: This panel is not created for flat structs / objects.
        SidebarPanel matlab.ui.container.Panel

        % A panel is placed in a very narrow grid cell to create the
        % appearance of a separator
        UISeparators (1,:) matlab.ui.container.Panel
        % Todo: UITabGroup
    end

    properties (Access = private, Description = "Themed UI Components")
        Header
        UIControlContainers (1,:)
        Footer
        SidebarMenu
    end

    properties
        Data
    end

    properties (Access = private)
        DataTree
    end

    properties (SetAccess = private)
        FinishState (1,1) string {mustBeMember(FinishState, ["", "Finished", "Canceled"])} = ""
        CloseOnExit (1,1) logical = true
    end

    properties
        Title (1,1) string = "Edit Struct"
        Description (1,1) string = "Please fill out the following fields"
        HeaderHeight = 50
        FooterHeight = 50
        SidebarWidth = 150
        LabelPosition (1,1) string {mustBeMember(LabelPosition, ["left", "above"])} = "left"
    end

    properties (Hidden)
        OkButtonText (1,1) string = "Ok" 
        CancelButtonText (1,1) string = "Cancel" 
    end

    properties (Access = private) %Dependent?
        ShowHeader = true
        ShowFooter = true
        ShowSidebar = false
        IsStandalone (1,1) logical = true
    end

    properties (Access = private, Dependent)
        MainPanelRow
        MainPanelColumn
    end
    
    methods
        function obj = StructEditorApp(data, propValues)
            arguments
                data struct
                propValues.Title = "Edit Struct"
                propValues.Theme = structeditor.enum.Theme.Light
            end
            
            % Todo: Before or after setting data and creating controls?
            propNvPairs = namedargs2cell(propValues);
            obj.set(propNvPairs{:});

            obj.Data = data;

            % Step 1: Parse input data % Todo: postSetData function?
            obj.DataTree = structeditor.utility.getTreeStruct(data);
            if ~isempty(obj.DataTree.children)
                obj.ShowSidebar = true;
                % %Todo: flatten struct.
            end

            % Step 2: Create UI components
            obj.setup()

            % obj.createControls() Todo...
            % Create the UIControlContainer
            H = structeditor.UIControlContainer(obj.ControlPanel, obj.Data, 'Theme', obj.Theme);
            obj.UIControlContainers = H;

            % Apply theme...
            %obj.Theme = structeditor.enum.Theme.NDI;
            if ~isempty(obj.Theme)
                obj.updateTheme( obj.UIFigure )
            end
        end
    end

    methods
        function uiwait(obj, preventClose)
            if nargin == 2
                obj.CloseOnExit = ~preventClose;
            end
            obj.IsStandalone = false;
            obj.FinishState = "";
            uiwait(obj.UIFigure)
        end
   
        function show(obj)
            obj.UIFigure.Visible = 'on';
        end

        function hide(obj)
            obj.UIFigure.Visible = 'off';
        end

        function tf = hasFigure(obj)
            tf = isvalid(obj.UIFigure);
        end
    end
    
    methods % Property set / get methods
        function value = get.MainPanelRow(obj)
            value = 1;
            if obj.ShowHeader
                value = value + 2;
            end
        end

        function value = get.MainPanelColumn(obj)
            value = 1;
            if obj.ShowSidebar
                value = value + 2;
            end
        end
    
        function set.Title(obj, value)
            obj.Title = value;
            obj.postSetTitle()
        end
        
        function set.Description(obj, value)
            obj.Description = value;
            obj.postSetDescription()
        end

        function set.LabelPosition(obj, value)
            obj.LabelPosition = value;
            obj.postSetLabelPosition()
        end

        function set.CancelButtonText(obj, value)
            obj.CancelButtonText = value;
            obj.postSetCancelButtonText()
        end

        function set.OkButtonText(obj, value)
            obj.OkButtonText = value;
            obj.postSetOkButtonText()
        end

    end

    methods (Access = private) % Property post set methods
        function onUIFigureCloseRequest(obj, src, event)
            if obj.CloseOnExit
                uiresume(obj.UIFigure)
                drawnow
                pause(0.05)
                
                delete(obj.UIControlContainers)
                delete(obj.Footer)
                delete(obj.UIFigure)
            else
                uiresume(obj.UIFigure)
            end
        end

        function postSetTitle(obj)
            if ~isempty(obj.UIFigure)
                obj.UIFigure.Name = obj.Title;
            end
        end

        function postSetDescription(obj)
            if ~isempty(obj.Header)
                obj.Header.Text = obj.Description;
            end
        end

        function postSetLabelPosition(obj)
            for i = 1:numel(obj.UIControlContainers)
                obj.UIControlContainers(i).LabelPosition = obj.LabelPosition;
            end
        end

        function postSetCancelButtonText(obj)
            obj.Footer.CancelButtonText = obj.CancelButtonText;
        end

        function postSetOkButtonText(obj)
            obj.Footer.OkButtonText = obj.OkButtonText;
        end
    end

    methods (Access = private) % Callback methods
        function onDataGroupChanged(obj, src, evt)
            disp(evt)
        end

        function onFinishedButtonPushed(obj, src, evt)
            
            obj.FinishState = evt.FinishState;

            if obj.FinishState == "Finished" % Update date
                obj.Data = obj.UIControlContainers.Data;
            end
            
            obj.close()
        end
    end

    methods (Access = private) % Component creation
        function updateMainGridLayout(obj)

            if isempty(obj.MainGridLayout); return; end

            % Initialize layout parameters
            columnWidth = {"1x"};
            rowHeight = {"1x"};

            if obj.ShowHeader
                rowHeight = [{obj.HeaderHeight, 1}, rowHeight];
            end
            if obj.ShowFooter
                rowHeight = [rowHeight, {1, obj.FooterHeight}];
            end
            if obj.ShowSidebar
                columnWidth = [{obj.SidebarWidth, 1}, columnWidth];
            end

            obj.MainGridLayout.ColumnWidth = columnWidth;
            obj.MainGridLayout.RowHeight = rowHeight;

            % Place control panel in the main grid layout:
            obj.ControlPanel.Layout.Row = obj.MainPanelRow;
            obj.ControlPanel.Layout.Column = obj.MainPanelColumn;
        end

        function createSeparator(obj, row, column, label)
            separator = uipanel(obj.MainGridLayout);
            separator.BorderType = 'None';
            separator.Layout.Row = row;
            separator.Layout.Column = column;
            separator.Tag = label;
            obj.UISeparators(end+1) = separator;
            separator.BackgroundColor = [0.3, 0.3, 0.3]; % Todo, get from theme...
        end
        
        function createSidebarMenu(obj, dataTree)

            obj.SidebarPanel = uipanel(obj.MainGridLayout);
            obj.SidebarPanel.Title = "";
            obj.SidebarPanel.BorderType = "none";
            obj.SidebarPanel.Layout.Row = obj.MainPanelRow;
            obj.SidebarPanel.Layout.Column = 1;
            obj.SidebarPanel.Tag = "Sidemenu Panel";


            obj.SidebarMenu = structeditor.TreeMenu(obj.SidebarPanel, dataTree, obj.Theme);
            obj.SidebarMenu.SelectionChangedFcn = @obj.onDataGroupChanged;
        end

        function createHeader(obj)
            obj.Header = uilabel(obj.MainGridLayout);
            obj.Header.Layout.Row = 1;
            obj.Header.Layout.Column = unique([1, 1+obj.ShowSidebar*2]);
            obj.Header.Text = obj.Description;
        end

        function createFooter(obj)
            obj.Footer = structeditor.FinishButtons(obj.MainGridLayout);
            obj.Footer.Layout.Row = 1 + obj.ShowHeader*2 + obj.ShowFooter*2;
            obj.Footer.Layout.Column = unique([1, 1+obj.ShowSidebar*2]);
            obj.Footer.FinishButtonPushedFcn = @obj.onFinishedButtonPushed;
        end
    end

    methods (Access = protected)
        function updateTheme(obj, figureHandle )
            updateTheme@structeditor.mixin.HasTheme(obj, figureHandle)

            % Apply to themed components...
            obj.Footer.Theme = obj.Theme; % Todo...

            % Update separators.
            set(obj.UISeparators, 'BackgroundColor', obj.Theme.ColorModel.BorderColor)
            %obj.UIControlContainers.UIGridLayout.BackgroundColor = 'w';
        end
    end 

    methods (Access = private)
        function setup(obj)

            % Initialize figure 
            obj.UIFigure = uifigure();
            obj.UIFigure.Name = obj.Title;
            if ~isempty(obj.Theme)
                obj.Theme.styleComponent(obj.UIFigure)
            end
            obj.UIFigure.CloseRequestFcn = @obj.onUIFigureCloseRequest;

            % Create grid layout
            obj.MainGridLayout = uigridlayout(obj.UIFigure);
            obj.MainGridLayout.Padding = [25, 10, 25, 10];
            obj.MainGridLayout.Tag = "Main Grid Layout";
            if ~isempty(obj.Theme)
                obj.Theme.styleComponent(obj.MainGridLayout)
            end

            % Create main component panel
            obj.ControlPanel = uipanel(obj.MainGridLayout);
            obj.ControlPanel.Title = "";
            obj.ControlPanel.BorderType = "none";
            obj.ControlPanel.Tag = "Control Panel";
            if ~isempty(obj.Theme)
                obj.Theme.styleComponent(obj.ControlPanel)
            end

            obj.updateMainGridLayout()

            % Create separators
            if obj.ShowHeader
                rowInd = 2; 
                colInd = unique([1, 1+obj.ShowSidebar*2]);
                obj.createSeparator(rowInd, colInd, 'Header Separator');
            end
            if obj.ShowFooter
                rowInd = obj.ShowHeader*2 + obj.ShowFooter*2; 
                colInd = unique([1, 1+obj.ShowSidebar*2]);
                obj.createSeparator(rowInd, colInd, 'Footer Separator');
            end
            if obj.ShowSidebar
                rowInd = unique([obj.MainPanelRow-obj.ShowHeader, obj.MainPanelRow+obj.ShowFooter]); 
                colInd = 2;
                obj.createSeparator(rowInd, colInd, 'Sidemenu Separator');
            end

            if obj.ShowSidebar
                obj.createSidebarMenu(obj.DataTree)
            end
            
            if obj.ShowHeader
                obj.createHeader()
            end

            obj.createFooter()
        end

        function close(obj)
            obj.onUIFigureCloseRequest()
        end
    end
end
