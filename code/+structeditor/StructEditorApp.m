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
        LoadingHtmlSource
        EnableNestedStruct matlab.lang.OnOffSwitchState = 'off' 
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
                data % struct
                propValues.Title = "Edit Struct"
                propValues.Theme (1,1) string = "" % Use system default
                propValues.LoadingHtmlSource = ''
                propValues.EnableNestedStruct = 'off'
            end
            
            % Set properties (excluding Theme which is handled by HasTheme)
            obj.Title = propValues.Title;
            obj.LoadingHtmlSource = propValues.LoadingHtmlSource;
            obj.EnableNestedStruct = propValues.EnableNestedStruct;

            obj.Data = data;

            % Step 1: Parse input data % Todo: postSetData function?
            if obj.EnableNestedStruct
                obj.DataTree = structeditor.utility.getTreeStruct(data);
                if ~isempty(obj.DataTree.children)
                    obj.ShowSidebar = true;
                    % %Todo: flatten struct.
                end
            end

            % Step 2: Create UI components
            obj.setup()

            % Step 3: Initialize theme AFTER figure is created
            % This automatically handles both R2025a+ and legacy versions
            obj.initializeTheme(obj.UIFigure, propValues.Theme);
            
            % Add callback to update custom themed components
            obj.addThemeChangedCallback(@obj.onThemeChanged);
            % obj.createControls() Todo...
            % Create the UIControlContainer
            H = structeditor.UIControlContainer(obj.ControlPanel, obj.Data, ...
                'LoadingHtmlSource', obj.LoadingHtmlSource, ...
                'LabelPosition', obj.LabelPosition); %'Theme', obj.ThemeObject,
            obj.UIControlContainers = H;

            obj.onThemeChanged()
        end
    
        function delete(obj)
            % Clean up theme manager
            %obj.cleanupTheme();
            
            if ~isempty(obj.UIFigure) && isvalid(obj.UIFigure)
                uiresume(obj.UIFigure)
                
                drawnow
                pause(0.05)
                
                delete(obj.UIControlContainers)
                delete(obj.Footer)
                delete(obj.UIFigure)
            end
        end
    end

    methods
        function alwaysOnTop(obj)
            obj.UIFigure.WindowStyle = "alwaysontop";
        end

        function normalMode(obj)
            obj.UIFigure.WindowStyle = "normal";
        end

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
    
        function reset(obj)
            for i = 1:numel(obj.UIControlContainers)
                obj.UIControlContainers(i).reset()
            end
            obj.FinishState = "";
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

        function set.Data(obj, value)
            obj.Data = value;
            obj.postSetData()
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
                delete(obj)
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

        function postSetData(obj)
            % Update UIControlContainers with new data
            if ~isempty(obj.UIControlContainers)
                for i = 1:numel(obj.UIControlContainers)
                    if isvalid(obj.UIControlContainers(i))
                        % NB/Todo: Currently only works for scalar data...
                        obj.UIControlContainers(i).Data = obj.Data;
                    end
                end
            end
            
            % Update data tree if nested structs are enabled
            if obj.EnableNestedStruct
                obj.DataTree = structeditor.utility.getTreeStruct(obj.Data);
                if ~isempty(obj.DataTree.children) && obj.ShowSidebar
                    % Update sidebar menu if it exists
                    if ~isempty(obj.SidebarMenu) && isvalid(obj.SidebarMenu)
                        % Note: SidebarMenu would need an update method to refresh
                        % For now, this handles the data tree update
                    end
                end
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

            if obj.FinishState == "Finished" % Update
                drawnow; pause(0.05)
                obj.Data = obj.UIControlContainers.Data;
            end
            
            obj.close()
        end
        
        function onThemeChanged(obj, ~, ~)
            % Called when theme changes (system or programmatic)
            % Update custom themed components
            
            % Get current theme object for components that need it
            themeObj = obj.ThemeObject;
            
            % Update footer
            if ~isempty(obj.Footer) && isvalid(obj.Footer)
                obj.Footer.Theme = themeObj;
            end
            
            % Update control containers
            for i = 1:numel(obj.UIControlContainers)
                if isvalid(obj.UIControlContainers(i))
                    obj.UIControlContainers(i).Theme = themeObj;
                end
            end
            
            % Update separators with theme colors
            if ~isempty(obj.UISeparators)
                set(obj.UISeparators, 'BackgroundColor', themeObj.ColorModel.BorderColor);
            end
            
            % Update sidebar if it exists
            if ~isempty(obj.SidebarMenu) && isvalid(obj.SidebarMenu)
                obj.SidebarMenu.Theme = themeObj;
            end
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


            obj.SidebarMenu = structeditor.TreeMenu(obj.SidebarPanel, dataTree, obj.ThemeObject);
            obj.SidebarMenu.SelectionChangedFcn = @obj.onDataGroupChanged;
        end

        function createHeader(obj)
            obj.Header = uilabel(obj.MainGridLayout);
            obj.Header.Layout.Row = 1;
            obj.Header.Layout.Column = unique([1, 1+obj.ShowSidebar*2]);
            obj.Header.Text = obj.Description;
        end

        function createFooter(obj)
            obj.Footer = structeditor.component.FinishButtons(obj.MainGridLayout);
            obj.Footer.Layout.Row = 1 + obj.ShowHeader*2 + obj.ShowFooter*2;
            obj.Footer.Layout.Column = unique([1, 1+obj.ShowSidebar*2]);
            obj.Footer.FinishButtonPushedFcn = @obj.onFinishedButtonPushed;
        end
    end

    methods (Access = private)
        function setup(obj)

            % Initialize figure 
            obj.UIFigure = uifigure();
            obj.UIFigure.Name = obj.Title;
            obj.UIFigure.CloseRequestFcn = @obj.onUIFigureCloseRequest;

            % Create grid layout
            obj.MainGridLayout = uigridlayout(obj.UIFigure);
            obj.MainGridLayout.Padding = [25, 10, 25, 10];
            obj.MainGridLayout.Tag = "Main Grid Layout";

            % Create main component panel
            obj.ControlPanel = uipanel(obj.MainGridLayout);
            obj.ControlPanel.Title = "";
            obj.ControlPanel.BorderType = "none";
            obj.ControlPanel.Tag = "Control Panel";

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
