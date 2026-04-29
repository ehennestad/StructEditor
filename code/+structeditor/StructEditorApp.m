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
        HeaderDescriptionLabel
        GroupDropDown
        HeaderPluginPanel
        FooterPluginPanel
        SidebarPluginPanel
        UIControlContainers (1,:)
        Footer
        FooterGrid
        SidebarMenu
    end

    properties (Dependent)
        Data
        Figure
        wasCanceled
        dataEdit
        dataOrig
    end

    properties (SetAccess = private)
        OriginalData
    end

    properties (Access = private)
        Data_
        DataTree
        GroupData (1,:) cell = {}
        GroupNames (1,:) string = strings(1, 0)
        GroupOutputNames (1,:) string = strings(1, 0)
        GroupInputShape (1,1) string {mustBeMember(GroupInputShape, ["struct", "cell", "structOfStructs"])} = "struct"
        GroupCellSize (1,:) double = [1 1]
        CurrentGroupIndex (1,1) double = 1
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
        Width = 560
        Height = 420 
        LabelPosition (1,1) string = "left"
        LoadingHtmlSource
        EnableNestedStruct matlab.lang.OnOffSwitchState = 'off' 
        ValueChangedFcn
        Callback
        Plugins (1,:) cell = {}
        IsModal (1,1) logical = false
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
        IsDeleting (1,1) logical = false
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
                propValues.Description
                propValues.Prompt
                propValues.Name
                propValues.Theme (1,1) string = "" % Use system default
                propValues.LoadingHtmlSource = ''
                propValues.EnableNestedStruct = 'off'
                propValues.Width = 560
                propValues.Height = 420
                propValues.CustomFigureSize
                propValues.LabelPosition = "left"
                propValues.OkButtonText = 'Ok'
                propValues.CancelButtonText = 'Cancel'
                propValues.CloseOnExit
                propValues.ValueChangedFcn
                propValues.Callback
                propValues.Plugin
                propValues.Plugins
                propValues.ReferencePosition
                propValues.DataTips
                propValues.TabMode
                propValues.AdjustFigureSize
            end
            
            if isfield(propValues, 'Theme')
                theme = propValues.Theme; propValues = rmfield(propValues, 'Theme');
            end
            if isfield(propValues, 'Prompt') && ~isfield(propValues, 'Description')
                propValues.Description = propValues.Prompt;
            end
            if isfield(propValues, 'Prompt')
                propValues = rmfield(propValues, 'Prompt');
            end
            if isfield(propValues, 'CustomFigureSize')
                figureSize = propValues.CustomFigureSize;
                propValues = rmfield(propValues, 'CustomFigureSize');
                if isnumeric(figureSize) && numel(figureSize) == 2
                    propValues.Width = figureSize(1);
                    propValues.Height = figureSize(2);
                else
                    error("structeditor:InvalidCustomFigureSize", ...
                        "CustomFigureSize must be a two-element numeric vector [width height].")
                end
            end
            if isfield(propValues, 'Name')
                groupNameInput = propValues.Name;
                propValues = rmfield(propValues, 'Name');
            else
                groupNameInput = [];
            end
            propValues = obj.removeDeferredLegacyOptions(propValues);
            if isfield(propValues, 'Plugin')
                if isfield(propValues, 'Plugins')
                    propValues.Plugins = [obj.wrapPluginList(propValues.Plugins), {propValues.Plugin}];
                else
                    propValues.Plugins = {propValues.Plugin};
                end
                propValues = rmfield(propValues, 'Plugin');
            end
            if isfield(propValues, 'Plugins')
                propValues.Plugins = obj.wrapPluginList(propValues.Plugins);
            end

            % Set properties (excluding Theme which is handled by HasTheme)
            obj.set(propValues)

            obj.replaceData(data, groupNameInput);

            % Step 1: Parse input data % Todo: postSetData function?
            if obj.EnableNestedStruct
                obj.DataTree = structeditor.utility.getTreeStruct(obj.GroupData{obj.CurrentGroupIndex});
                if ~isempty(obj.DataTree.children)
                    obj.ShowSidebar = true;
                    % %Todo: flatten struct.
                end
            end

            % Step 2: Create UI components
            obj.setup()

            % Step 3: Initialize theme AFTER figure is created
            % This automatically handles both R2025a+ and legacy versions
            obj.initializeTheme(obj.UIFigure, theme);
            
            % Add callback to update custom themed components
            obj.addThemeChangedCallback(@obj.onThemeChanged);
            obj.recreateControlContainer()
            obj.attachPlugins()

            obj.onThemeChanged()
        end
    
        function delete(obj)
            % Clean up theme manager
            %obj.cleanupTheme();

            if obj.IsDeleting
                return
            end
            obj.IsDeleting = true;
            notify(obj, 'AppDestroyed')
            
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

    events
        AppDestroyed
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
            % We are waiting for figure, it should always be op top
            obj.UIFigure.WindowStyle = "alwaysontop";
            uiwait(obj.UIFigure)
        end

        function waitfor(obj, preventClose)
            if nargin < 2
                obj.uiwait()
            else
                obj.uiwait(preventClose)
            end
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

        function replaceData(obj, data, groupNames)
            if nargin < 3
                groupNames = [];
            end

            obj.OriginalData = data;
            obj.initializeGroupData(data, groupNames);
            obj.Data_ = obj.composeDataFromGroups();
            obj.FinishState = "";

            if ~isempty(obj.UIFigure) && isvalid(obj.UIFigure)
                obj.updateGroupSelector()
                obj.recreateControlContainer()
            end
        end

        function container = getAttachmentContainer(obj, location)
            location = lower(string(location));
            switch location
                case "header"
                    container = obj.HeaderPluginPanel;
                case "footer"
                    container = obj.FooterPluginPanel;
                case "sidebar"
                    container = obj.SidebarPluginPanel;
                otherwise
                    error("structeditor:InvalidPluginLocation", ...
                        "Plugin location must be header, footer, or sidebar.")
            end
        end

        function plugin = getPlugin(obj, className)
            className = char(className);
            plugin = [];
            for i = 1:numel(obj.Plugins)
                if isa(obj.Plugins{i}, className)
                    plugin = obj.Plugins{i};
                    return
                end
            end
        end
    end
    
    methods % Property set / get methods
        function value = get.Data(obj)
            value = obj.Data_;
        end

        function value = get.Figure(obj)
            value = obj.UIFigure;
        end

        function set.Data(obj, value)
            obj.initializeGroupData(value, []);
            obj.Data_ = obj.composeDataFromGroups();
            obj.postSetData()
        end

        function value = get.wasCanceled(obj)
            value = obj.FinishState == "Canceled";
        end

        function value = get.dataEdit(obj)
            value = obj.Data;
        end

        function set.dataEdit(obj, value)
            obj.replaceData(value);
        end

        function value = get.dataOrig(obj)
            value = obj.OriginalData;
        end

        function set.dataOrig(obj, value)
            obj.OriginalData = value;
        end

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
            obj.LabelPosition = structeditor.StructEditorApp.normalizeLabelPosition(value);
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
            if ~isempty(obj.HeaderDescriptionLabel) && isvalid(obj.HeaderDescriptionLabel)
                obj.HeaderDescriptionLabel.Text = obj.Description;
            elseif ~isempty(obj.Header)
                obj.Header.Text = obj.Description;
            end
        end

        function postSetData(obj)
            % Update UIControlContainers with new data
            if ~isempty(obj.UIControlContainers)
                for i = 1:numel(obj.UIControlContainers)
                    if isvalid(obj.UIControlContainers(i))
                        obj.UIControlContainers(i).Data = obj.GroupData{obj.CurrentGroupIndex};
                    end
                end
            end
            
            % Update data tree if nested structs are enabled
            if obj.EnableNestedStruct
                obj.DataTree = structeditor.utility.getTreeStruct(obj.GroupData{obj.CurrentGroupIndex});
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
            if ~isempty(obj.Footer) && isvalid(obj.Footer)
                obj.Footer.CancelButtonText = obj.CancelButtonText;
            end
        end

        function postSetOkButtonText(obj)
            if ~isempty(obj.Footer) && isvalid(obj.Footer)
                obj.Footer.OkButtonText = obj.OkButtonText;
            end
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
                obj.syncCurrentGroupFromUI()
                obj.Data_ = obj.composeDataFromGroups();
            end

            obj.notifyPluginsFinishStateChanged(evt)
            
            obj.close()
        end

        function onGroupSelectionChanged(obj, src, ~)
            obj.syncCurrentGroupFromUI()
            obj.CurrentGroupIndex = find(obj.GroupNames == string(src.Value), 1, "first");
            obj.recreateControlContainer()
        end

        function onControlValueChanged(obj, ~, evt)
            obj.syncCurrentGroupFromUI()
            obj.Data_ = obj.composeDataFromGroups();

            control = obj.getControlFromValueChangedEvent(evt);
            eventData = struct();
            eventData.Name = string(evt.Name);
            eventData.OldValue = evt.OldValue;
            eventData.NewValue = evt.NewValue;
            eventData.GroupName = obj.GroupNames(obj.CurrentGroupIndex);
            eventData.GroupIndex = obj.CurrentGroupIndex;
            eventData.PageNumber = evt.PageNumber;
            eventData.Control = control;
            eventData.UIControls = control;

            if ~isempty(obj.ValueChangedFcn)
                obj.ValueChangedFcn(obj, eventData)
            end

            obj.notifyPluginsDataChanged(eventData)

            callback = obj.getCallbackForCurrentGroup();
            if ~isempty(callback)
                callback(char(evt.Name), evt.NewValue)
            end
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


            sidebarGrid = uigridlayout(obj.SidebarPanel);
            sidebarGrid.ColumnWidth = {'1x'};
            sidebarGrid.RowHeight = {'1x', 32};
            sidebarGrid.Padding = [0 0 0 0];

            treePanel = uipanel(sidebarGrid);
            treePanel.BorderType = "none";
            treePanel.Title = "";
            treePanel.Layout.Row = 1;
            treePanel.Layout.Column = 1;

            obj.SidebarPluginPanel = uipanel(sidebarGrid);
            obj.SidebarPluginPanel.BorderType = "none";
            obj.SidebarPluginPanel.Title = "";
            obj.SidebarPluginPanel.Layout.Row = 2;
            obj.SidebarPluginPanel.Layout.Column = 1;

            obj.SidebarMenu = structeditor.TreeMenu(treePanel, dataTree, obj.ThemeObject);
            obj.SidebarMenu.SelectionChangedFcn = @obj.onDataGroupChanged;
        end

        function createHeader(obj)
            obj.Header = uigridlayout(obj.MainGridLayout);
            if obj.hasGroups()
                obj.Header.ColumnWidth = {'1x', 160, 260};
            else
                obj.Header.ColumnWidth = {'1x', 0, 260};
            end
            obj.Header.RowHeight = {'1x'};
            obj.Header.Padding = [0 0 0 0];
            obj.Header.ColumnSpacing = 10;
            obj.Header.Layout.Row = 1;
            obj.Header.Layout.Column = unique([1, 1+obj.ShowSidebar*2]);

            obj.HeaderDescriptionLabel = uilabel(obj.Header);
            obj.HeaderDescriptionLabel.Layout.Row = 1;
            obj.HeaderDescriptionLabel.Layout.Column = 1;
            obj.HeaderDescriptionLabel.Text = obj.Description;

            if obj.hasGroups()
                obj.GroupDropDown = uidropdown(obj.Header);
                obj.GroupDropDown.Layout.Row = 1;
                obj.GroupDropDown.Layout.Column = 2;
                obj.GroupDropDown.Items = cellstr(obj.GroupNames);
                obj.GroupDropDown.Value = obj.GroupNames(obj.CurrentGroupIndex);
                obj.GroupDropDown.ValueChangedFcn = @obj.onGroupSelectionChanged;
            end

            obj.HeaderPluginPanel = uipanel(obj.Header);
            obj.HeaderPluginPanel.BorderType = "none";
            obj.HeaderPluginPanel.Title = "";
            obj.HeaderPluginPanel.Layout.Row = 1;
            obj.HeaderPluginPanel.Layout.Column = 3;
        end

        function createFooter(obj)
            obj.FooterGrid = uigridlayout(obj.MainGridLayout);
            obj.FooterGrid.ColumnWidth = {'1x', 180};
            obj.FooterGrid.RowHeight = {'1x'};
            obj.FooterGrid.Padding = [0 0 0 0];
            obj.FooterGrid.Layout.Row = 1 + obj.ShowHeader*2 + obj.ShowFooter*2;
            obj.FooterGrid.Layout.Column = unique([1, 1+obj.ShowSidebar*2]);

            obj.FooterPluginPanel = uipanel(obj.FooterGrid);
            obj.FooterPluginPanel.BorderType = "none";
            obj.FooterPluginPanel.Title = "";
            obj.FooterPluginPanel.Layout.Row = 1;
            obj.FooterPluginPanel.Layout.Column = 1;

            obj.Footer = structeditor.component.FinishButtons(obj.FooterGrid);
            obj.Footer.Layout.Row = 1;
            obj.Footer.Layout.Column = 2;
            obj.Footer.FinishButtonPushedFcn = @obj.onFinishedButtonPushed;
        end
    end

    methods (Access = private)
        function setup(obj)

            % Initialize figure 
            obj.UIFigure = uifigure();
            obj.UIFigure.Name = obj.Title;
            obj.UIFigure.CloseRequestFcn = @obj.onUIFigureCloseRequest;
            obj.UIFigure.Position(3) = obj.Width;
            obj.UIFigure.Position(4) = obj.Height;

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

    methods (Access = private)
        function attachPlugins(obj)
            for i = 1:numel(obj.Plugins)
                plugin = obj.Plugins{i};
                if ismethod(plugin, 'attach')
                    plugin.attach(obj)
                elseif ismethod(plugin, 'Attach')
                    plugin.Attach(obj)
                end
            end
        end

        function notifyPluginsDataChanged(obj, evt)
            for i = 1:numel(obj.Plugins)
                plugin = obj.Plugins{i};
                if ismethod(plugin, 'onDataChanged')
                    plugin.onDataChanged(obj, evt)
                end
            end
        end

        function notifyPluginsFinishStateChanged(obj, evt)
            for i = 1:numel(obj.Plugins)
                plugin = obj.Plugins{i};
                if ismethod(plugin, 'onFinishStateChanged')
                    plugin.onFinishStateChanged(obj, evt)
                end
            end
        end

        function initializeGroupData(obj, data, groupNames)
            if iscell(data)
                assert(all(cellfun(@isstruct, data(:))), ...
                    "structeditor:InvalidGroupedData", ...
                    "Cell-array grouped data must contain structs.")

                obj.GroupInputShape = "cell";
                obj.GroupCellSize = size(data);
                obj.GroupData = reshape(data, 1, []);
                obj.GroupOutputNames = strings(1, numel(obj.GroupData));

            elseif isstruct(data) && isscalar(data) && obj.isStructOfStructs(data)
                obj.GroupInputShape = "structOfStructs";
                names = fieldnames(data);
                obj.GroupOutputNames = string(names);
                obj.GroupData = cell(1, numel(names));
                for i = 1:numel(names)
                    obj.GroupData{i} = data.(names{i});
                end
                if isempty(groupNames)
                    groupNames = string(names);
                end

            else
                assert(isstruct(data) && isscalar(data), ...
                    "structeditor:InvalidData", ...
                    "StructEditorApp expects a scalar struct, cell array of structs, or scalar struct whose fields are structs.")

                obj.GroupInputShape = "struct";
                obj.GroupData = {data};
                obj.GroupOutputNames = strings(1, 1);
            end

            if isempty(groupNames)
                obj.GroupNames = "Group " + string(1:numel(obj.GroupData));
            else
                obj.GroupNames = string(groupNames);
            end

            assert(numel(obj.GroupNames) == numel(obj.GroupData), ...
                "structeditor:InvalidGroupNames", ...
                "Number of group names must match number of data groups.")

            obj.CurrentGroupIndex = min(obj.CurrentGroupIndex, numel(obj.GroupData));
            if isempty(obj.CurrentGroupIndex) || obj.CurrentGroupIndex < 1
                obj.CurrentGroupIndex = 1;
            end
        end

        function data = composeDataFromGroups(obj)
            switch obj.GroupInputShape
                case "cell"
                    data = reshape(obj.GroupData, obj.GroupCellSize);

                case "structOfStructs"
                    data = struct();
                    for i = 1:numel(obj.GroupNames)
                        data.(obj.GroupOutputNames(i)) = obj.GroupData{i};
                    end

                otherwise
                    data = obj.GroupData{1};
            end
        end

        function tf = hasGroups(obj)
            tf = numel(obj.GroupData) > 1;
        end

        function syncCurrentGroupFromUI(obj)
            if ~isempty(obj.UIControlContainers) && isvalid(obj.UIControlContainers(1))
                obj.GroupData{obj.CurrentGroupIndex} = obj.UIControlContainers(1).Data;
            end
        end

        function recreateControlContainer(obj)
            if ~isempty(obj.UIControlContainers)
                delete(obj.UIControlContainers(isvalid(obj.UIControlContainers)))
                obj.UIControlContainers = structeditor.UIControlContainer.empty();
            end

            delete(obj.ControlPanel.Children)

            H = structeditor.UIControlContainer(obj.ControlPanel, obj.GroupData{obj.CurrentGroupIndex}, ...
                'LoadingHtmlSource', obj.LoadingHtmlSource, ...
                'LabelPosition', obj.LabelPosition);
            H.ValueChangedFcn = @obj.onControlValueChanged;
            if ~isempty(obj.ThemeObject)
                H.Theme = obj.ThemeObject;
            end
            obj.UIControlContainers = H;
        end

        function updateGroupSelector(obj)
            if isempty(obj.GroupDropDown) || ~isvalid(obj.GroupDropDown)
                return
            end

            obj.GroupDropDown.Items = cellstr(obj.GroupNames);
            obj.GroupDropDown.Value = obj.GroupNames(obj.CurrentGroupIndex);
        end

        function callback = getCallbackForCurrentGroup(obj)
            callback = obj.Callback;
            if iscell(callback)
                if numel(callback) >= obj.CurrentGroupIndex
                    callback = callback{obj.CurrentGroupIndex};
                else
                    callback = [];
                end
            end
        end

        function control = getControlFromValueChangedEvent(~, evt)
            if isprop(evt, 'Control')
                control = evt.Control;
            elseif isprop(evt, 'UIControls')
                control = evt.UIControls;
            else
                control = [];
            end
        end
    end

    methods (Static)
        function propValues = removeDeferredLegacyOptions(propValues)
            deferredOptions = ["ReferencePosition", "DataTips", "TabMode", "AdjustFigureSize"];
            for i = 1:numel(deferredOptions)
                optionName = deferredOptions(i);
                if isfield(propValues, optionName)
                    propValues = rmfield(propValues, optionName);
                end
            end
        end

        function value = normalizeLabelPosition(value)
            value = lower(string(value));
            switch value
                case "over"
                    value = "above";
            end

            mustBeMember(value, ["left", "above"])
        end

        function tf = isStructOfStructs(data)
            names = fieldnames(data);
            tf = ~isempty(names) && all(structfun(@(v) isstruct(v) && isscalar(v), data));
        end

        function plugins = wrapPluginList(plugins)
            if isempty(plugins)
                plugins = {};
            elseif ~iscell(plugins)
                plugins = {plugins};
            end
        end
    end

    methods (Access = ?matlab.uitest.TestCase)
        function hControl = getComponent(comp, controlName)
            hControl = comp.(controlName);
        end
    end
end
