classdef UIControlContainer < handle ...
        & matlab.mixin.SetGetExactNames ...
        & structeditor.mixin.ComponentHasTheme
% UIControlContainer - Container for laying out and creating uicontrols for
% a data structure

    properties (Dependent)
        Data (1,1) struct
        Visible (1,1) matlab.lang.OnOffSwitchState
        Enabled (1,1) matlab.lang.OnOffSwitchState
        Editable (1,1) matlab.lang.OnOffSwitchState
    end

    properties
        ValueChangedFcn
        LabelPosition (1,1) string = "left"
        LoadingHtmlSource
    end

    properties
        ValuePreSetFcn % E.g validation
        ValuePostSetFcn % E.g conversion to correct type
        CustomConstructorFcn
    end

    properties (Access = private)
        DataName (1,1) string = missing
        DataModified (1,1) struct
        DataOriginal (1,1) struct
    end

    properties (Dependent)
        IsClean
    end

    properties %(Access = private)
        UIControls
        UIControlButtons
        UILabels matlab.ui.control.Label
        Parent
        UIGridLayout
    end

    properties (Access = private)
        IsConstructed = false;
        Visible_ (1,1) matlab.lang.OnOffSwitchState = 'on'
        Enabled_ (1,1) matlab.lang.OnOffSwitchState = 'on'
        Editable_ (1,1) matlab.lang.OnOffSwitchState = 'on'
    end

    properties (SetAccess = protected, GetAccess = private) %?
        FontName = 'Avenir Next'
        FontSize = 14
        RowHeight = 25; % Height of row in pixels
        RowSpacing = 15; % Spacing between rows in pixels
        ColumnSpacing = 10; % Spacing between columns in pixels
    end

    methods
        function obj = UIControlContainer(hParent, data, propValues)
            arguments
                hParent
                data
                propValues.RowHeight
                propValues.RowSpacing
                propValues.ColumnSpacing
                propValues.Theme
                propValues.LoadingHtmlSource
                propValues.LabelPosition
            end
            
            if isfield(propValues, 'Theme')
                superArgs = {'Theme', propValues.Theme};
                propValues = rmfield(propValues, 'Theme');
            else
                superArgs = {};
            end
            obj = obj@structeditor.mixin.ComponentHasTheme(superArgs{:})

            obj.set(propValues);

            obj.Parent = hParent;
            [obj.DataModified, obj.DataOriginal] = deal(data);
            
            if ~isempty(obj.LoadingHtmlSource)
                g = uigridlayout(hParent, 'ColumnWidth', {'1x'},'RowHeight', {'1x'}, 'Padding', 75 );
                h = uihtml(g, "HTMLSource", obj.LoadingHtmlSource);
            end

            % Create grid layout
            obj.createGridLayout()

            obj.createUIControls()

            obj.IsConstructed = true;
            obj.UIGridLayout.Visible = obj.Visible_;
            if ~isempty(obj.LoadingHtmlSource)
                delete(h); delete(g)
            end
        end
    end

    methods 
        function reset(obj)
            hControls = struct2cell(obj.UIControls);
            hControls = [hControls{:}];
            for i = 1:numel(hControls)
                if isa(hControls(i), 'matlab.ui.control.Label') || ...
                        isa(hControls(i), 'matlab.ui.control.Button') || ...
                            isa(hControls(i), 'matlab.ui.control.StateButton')
                    continue
                elseif isa(hControls(i), 'matlab.ui.control.DropDown')
                    hControls(i).Value = hControls(i).Items{1};
                else
                    if isprop(hControls(i), 'Value')
                        if isa(hControls(i), 'matlab.ui.control.TextArea')
                            hControls(i).Value(:) = {''};
                        elseif isa(hControls(i), 'matlab.ui.control.DatePicker')
                            hControls(i).Value(:) = NaT;
                        elseif isa(hControls(i), 'matlab.ui.control.CheckBox')
                            hControls(i).Value(:) = false;
                        else
                            hControls(i).Value(:) = [];
                        end
                    else
                        warning([...
                            'Could not reset control for "%s" because ', ...
                            'controls of type `%s` does not have a Value ', ...
                            'property'], ...
                            hControls(i).Tag, class(hControls(i)))
                    end
                end
            end
            obj.resetData();
        end

        function resetData(obj)
            % Reset all data fields to empty values
            fieldNames = fieldnames(obj.DataModified);
            [fieldNames, ~] = structeditor.utility.popConfigFields(fieldNames);
            
            for i = 1:numel(fieldNames)
                fieldName = fieldNames{i};
                currentValue = obj.DataModified.(fieldName);
                
                % Set to appropriate empty value based on type
                switch class(currentValue)
                    case {'char', 'string'}
                        obj.DataModified.(fieldName) = '';
                    case {'single', 'double', 'uint8', 'uint16'}
                        obj.DataModified.(fieldName) = [];
                    case 'logical'
                        obj.DataModified.(fieldName) = false;
                    case 'categorical'
                        % Keep the categories but select first one
                        cats = categories(currentValue);
                        obj.DataModified.(fieldName) = categorical(cats(1), cats);
                    case 'datetime'
                        obj.DataModified.(fieldName) = NaT;
                    otherwise
                        % For unknown types, try to set to empty
                        try
                            obj.DataModified.(fieldName) = [];
                        catch
                            warning('Could not reset field "%s" of type %s', ...
                                fieldName, class(currentValue));
                        end
                end
            end
            
            % Update the UI controls to reflect the empty values
            obj.Data = obj.DataModified;
        end
    end

    % Property set / get methods
    methods
        function set.Data(obj, value)
            oldData = obj.DataModified;
            newData = value;
            
            assert( isequal( fieldnames(oldData), fieldnames(newData) ), ...
                'Adding or removing fields from Data is not supported' )

            obj.DataModified = newData;
            obj.postSetData(oldData, newData)
        end
        function value = get.Data(obj)
            value = obj.DataModified;
        end
        
        function set.Visible(obj, value)
            obj.Visible_ = value;
            if ~isempty(obj.UIGridLayout)
                obj.UIGridLayout.Visible = value;
            end
        end
        function value = get.Visible(obj)
            if ~isempty(obj.UIGridLayout)
                value = obj.UIGridLayout.Visible;
            else
                value = obj.Visible_;
            end
        end

        function value = get.IsClean(obj)
            value = isequal(obj.DataModified, obj.DataOriginal);
        end

        function set.LabelPosition(obj, value)
            obj.LabelPosition = structeditor.StructEditorApp.normalizeLabelPosition(value);
            obj.postSetLabelPosition()
        end

        function set.Enabled(obj, value)
            obj.Enabled_ = value;
            if obj.IsConstructed
                obj.updateControlsEnabled()
            end
        end
        function value = get.Enabled(obj)
            value = obj.Enabled_;
        end

        function set.Editable(obj, value)
            obj.Editable_ = value;
            if obj.IsConstructed
                obj.updateControlsEditable()
            end
        end
        function value = get.Editable(obj)
            value = obj.Editable_;
        end

        function set.RowSpacing(obj, value)
            obj.RowSpacing = value;
            obj.postSetRowSpacing()
        end
       
        function set.ColumnSpacing(obj, value)
            obj.ColumnSpacing = value;
            obj.postSetColumnSpacing()
        end
    end

    % Property post set methods
    methods (Access = private)
        function postSetData(obj, oldData, newData)
            % Pre - construction
            if ~obj.IsConstructed
                return
            end

            % Find which field changed.
            fieldNames = fieldnames(oldData);
            [fieldNames, ~] = structeditor.utility.popConfigFields(fieldNames);
            fieldNames = cellstr(fieldNames);

            oldValues = struct2cell(oldData);
            newValues = struct2cell(newData);

            for i = 1:numel(fieldNames)
                if isfield(obj.UIControls, fieldNames{i})
                    hControl = obj.UIControls.(fieldNames{i});
                    if ~isequal(oldValues{i}, newValues{i})
                        if isprop(hControl, 'Value')
                            fieldValue = obj.formatValueForControl(newValues{i});
                            hControl.Value = fieldValue;
                            % Todo: Callback
                        end
                    end
                end
            end
        end

        function postSetLabelPosition(obj)
            if ~isempty(obj.UIGridLayout)
                obj.updateGridLayoutSize()
                obj.updateUIControlPositions()
            end
        end

        function postSetRowSpacing(obj)
            if ~isempty(obj.UIGridLayout)
                obj.updateGridLayoutSize()
            end
        end

        function postSetColumnSpacing(obj)
            if ~isempty(obj.UIGridLayout)
                obj.updateGridLayoutSize()
            end
        end

        function updateControlsEnabled(obj)
            % Update the enabled state of all controls
            if isempty(obj.UIControls)
                return
            end
            
            controlNames = fieldnames(obj.UIControls);
            for i = 1:numel(controlNames)
                hControl = obj.UIControls.(controlNames{i});
                if isprop(hControl, 'Enable')
                    hControl.Enable = obj.Enabled_;
                end
            end
        end

        function updateControlsEditable(obj)
            % Update the enabled state of all controls
            if isempty(obj.UIControls)
                return
            end
            
            controlNames = fieldnames(obj.UIControls);
            for i = 1:numel(controlNames)
                hControl = obj.UIControls.(controlNames{i});
                if isprop(hControl, 'Editable')
                    hControl.Editable = obj.Editable_;
                end
            end
        end
    end

    % Component creation
    methods (Access = private)
        function createGridLayout(obj)
            obj.UIGridLayout = uigridlayout(obj.Parent);
            obj.UIGridLayout.Visible = 'off';
            
            obj.updateGridLayoutSize()

            obj.UIGridLayout.ColumnSpacing = obj.ColumnSpacing;
            %obj.UIGridLayout.RowSpacing = obj.RowSpacing;
        
            obj.UIGridLayout.BackgroundColor = obj.Theme.ColorModel.BackgroundColor;
            obj.UIGridLayout.Scrollable = true;
        end

        function updateGridLayoutSize(obj)
            numRows = numel( fieldnames(obj.DataModified) );

            switch obj.LabelPosition
                case 'left'
                    obj.UIGridLayout.ColumnWidth = {200, '1x', 25, 1};
                    obj.UIGridLayout.RowHeight = repmat({obj.RowHeight}, 1, numRows);
                    obj.UIGridLayout.RowSpacing = obj.RowSpacing;

                case 'above'
                    obj.UIGridLayout.ColumnWidth = {'1x', 25, 1};
                    obj.UIGridLayout.RowHeight = repmat({20, obj.RowHeight, obj.RowSpacing}, 1, numRows);                    
                    obj.UIGridLayout.RowSpacing = 0;
            end
        end

        function updateUIControlPositions(obj)
            dataFieldNames = fieldnames(obj.DataModified);
            numRows = numel( dataFieldNames );
    
            for i = 1:numRows
                hControl = obj.UIControls.(dataFieldNames{i});
                obj.placeUIControl(hControl, i);
                obj.placeUILabel(obj.UILabels(i), i);
            end
        end

        function placeUILabel(obj, hLabel, rowNumber)
            switch obj.LabelPosition
                case 'left'
                    hLabel.Layout.Row = rowNumber;
                    hLabel.Layout.Column = 1;
                    hLabel.HorizontalAlignment = 'right';
                    hLabel.VerticalAlignment = 'center';

                case 'above'
                    hLabel.Layout.Row = rowNumber*3-2;
                    hLabel.Layout.Column = 1;
                    hLabel.HorizontalAlignment = 'left';
                    hLabel.VerticalAlignment = 'top';
            end
        end

        function placeUIControl(obj, hControl, rowNumber)
            switch obj.LabelPosition
                case 'left'
                    hControl.Layout.Column = 2; 
                    hControl.Layout.Row = rowNumber;
                case 'above'
                    hControl.Layout.Column = 1; 
                    hControl.Layout.Row = rowNumber*3-1;
            end
            
            % Todo: Make this configurable through preferences
            if isa(hControl, 'matlab.ui.control.TextArea')
                obj.UIGridLayout.RowHeight{ hControl.Layout.Row } = 64;
            end

            if isprop(hControl, 'HasButton')
                hControl.Layout.Column = hControl.Layout.Column + [0,1]; 
            end
        end

        function createUIControls(obj) % Todo: Should be method of abstract superclass
            fieldNames = string( fieldnames(obj.DataModified) );

            [fieldNames, ~] = structeditor.utility.popConfigFields(fieldNames);

            for i = 1:numel(fieldNames)
                name = fieldNames(i);
                value = obj.DataModified.(name);
                config = structeditor.config.normalizeFieldConfig(...
                    obj.getConfigField(obj.DataModified, name));

                if config.Hidden
                    continue
                end

                obj.createLabel(i, name)
                hControl = obj.createControl(i, name, value, config);
                obj.UIControls.(name) = hControl;
            end
        end

        function config = getConfigField(~, data, name) % Todo: static?
            if isfield(data, name+"_")
                config = data.(name+"_");
            else
                config = [];
            end
        end

        function createLabel(obj, iRow, name)
            hLabel = uilabel( obj.UIGridLayout );
            hLabel.Text = [structeditor.utility.varname2label(char(name)), ':'];
            %hLabel.FontWeight = 'bold';
            hLabel.FontColor = obj.Theme.ColorModel.TextColor;
            hLabel.FontName = obj.FontName;
            hLabel.FontSize = obj.FontSize;
            hLabel.Tag = name;

            obj.placeUILabel(hLabel, iRow)
            obj.UILabels(iRow) = hLabel;
        end

        function hControl = createControl(obj, iRow, name, value, config)

            if nargin < 5
                config = structeditor.config.normalizeFieldConfig([]);
            end
            
            parentContainer = obj.UIGridLayout;

            % Create custom control / widget
            if config.Kind ~= "auto"
                hControl = obj.createConfiguredControl(parentContainer, iRow, name, value, config);
               
            % Create standard control / widget
            else 
                hControl = obj.createAutoControl(parentContainer, value);
            end
            if isnumeric(value) && isempty(value)
                value = []; % 0x1 and 1x0 not supported in numeric controls.
            end

            obj.placeUIControl(hControl, iRow)

            hControl.Tag = name;
             
            if isprop(hControl, 'BackgroundColor')
                hControl.BackgroundColor = obj.Theme.ColorModel.BackgroundColor;
            end
            if isprop(hControl, 'FontColor')
                hControl.FontColor = obj.Theme.ColorModel.TextColor;
                hControl.FontName = obj.FontName;
                hControl.FontSize = obj.FontSize;
            end

            if isprop(hControl, 'Value')
                fieldValue = obj.formatValueForControl(value);
                hControl.Value = fieldValue;
                hControl.ValueChangedFcn = @obj.onFieldValueChanged;
            end

            if isprop(hControl, 'Enable')
                hControl.Enable = obj.Enabled_;
            end
            
            % try Consider integrating
            %     % drawnow
            %     %ccTools.compCustomization(hControl, 'borderRadius', "5px")
            % end
        end

        function hControl = createAutoControl(obj, parentContainer, value)
            switch class(value)
                case 'string'
                    hControl = uieditfield(parentContainer);

                case 'char'
                    hControl = uieditfield(parentContainer);

                case {'single', 'double'}
                    if isscalar(value) || isempty(value)
                        hControl = uieditfield(parentContainer, 'numeric', 'AllowEmpty', 'on');
                    else
                        hControl = uieditfield(parentContainer);
                    end

                case {'uint8', 'uint16', 'uint32', 'uint64', 'int8', 'int16', 'int32', 'int64'}
                    if isscalar(value) || isempty(value)
                        lowerLimit = intmin(class(value));
                        upperLimit = intmax(class(value));
                        limits = double([lowerLimit, upperLimit]);
                        hControl = uispinner(parentContainer, ...
                            'Limits', limits, ...
                            'AllowEmpty', 'on', ...
                            'ValueDisplayFormat', '%d');
                    else
                        hControl = uieditfield(parentContainer);
                    end

                case 'categorical'
                    hControl = uidropdown(parentContainer);
                    hControl.Items = categories(value);

                case 'logical'
                    hControl = uicheckbox(parentContainer);
                    hControl.Text = '';

                case 'datetime'
                    hControl = uidatepicker(parentContainer);

                case 'cell'
                    hControl = uieditfield(parentContainer);

                otherwise
                    error("structeditor:UnsupportedFieldType", ...
                        "Field type %s is not supported.", class(value))
            end
        end

        function hControl = createConfiguredControl(obj, parentContainer, iRow, name, value, config)
            switch config.Kind
                case "dropdown"
                    hControl = uidropdown(parentContainer);
                    obj.configureDropdown(hControl, value, config.Choices)

                case "custom"
                    hControl = config.Action(parentContainer);

                case {"browse", "color", "action"}
                    hControl = obj.createAutoControl(parentContainer, value);
                    hButton = uibutton(parentContainer, ...
                        "Text", "...", ...
                        "Tag", name, ...
                        "ButtonPushedFcn", @(src, evt) obj.onActionButtonPushed(src, evt, config));
                    obj.UIControlButtons.(name) = hButton;

                case "slider"
                    hControl = uislider(parentContainer, config.Args{:});

                case {"button", "pushbutton"}
                    hControl = uibutton(parentContainer, "push", config.Args{:});

                case "togglebutton"
                    hControl = uibutton(parentContainer, "state", config.Args{:});

                case "multilinechar"
                    hControl = uitextarea(parentContainer);

                otherwise
                    error("structeditor:UnsupportedFieldConfig", ...
                        "Field config type %s is not supported.", config.Kind)
            end

            if isfield(obj.UIControlButtons, name)
                obj.placeUIControl(obj.UIControlButtons.(name), iRow)
                obj.UIControlButtons.(name).Layout.Column = 3;
            end
        end

        function configureDropdown(~, hControl, value, choices)
            if isempty(choices)
                choices = cellstr(string(value));
            end

            if all(cellfun(@(v) ischar(v) || isstring(v), choices))
                items = cellstr(string(choices));
                hControl.Items = items;
            else
                items = cellstr(string([choices{:}]));
                hControl.Items = items;
                hControl.ItemsData = [choices{:}];
            end
        end
    
        function value = formatValueForControl(obj, value) %#ok<INUSD>
            if isnumeric(value) && isempty(value)
                value = []; % 0x1 and 1x0 not supported in numeric controls.
                return
            end

            switch class(value)
                case {'uint8', 'uint16', 'uint32', 'uint64', 'int8', 'int16', 'int32', 'int64'}
                    value = double(value);

                case 'categorical'
                    value = char(value);
                                    
                case 'datetime'
                    if isempty(value)
                        value = NaT;
                    end

                case 'cell'
                    if all(cellfun(@ischar, value)) || all(cellfun(@isstring, value))
                        value = strjoin(cellstr(string(value)), ", ");
                    elseif all(cellfun(@isnumeric, value))
                        value = strjoin(cellfun(@num2str, value, "UniformOutput", false), " ");
                    end
            end

            if isnumeric(value) && ~isscalar(value)
                value = mat2str(value);
            end
        end
    end

    methods
        function onFieldValueChanged(obj, src, evt)

            fieldName = src.Tag;
            
            oldValue = obj.DataModified.(fieldName);
            newValue = evt.Value;

            newValue = obj.convertControlValue(newValue, oldValue);
            obj.DataModified.(fieldName) = newValue;

            % Todo: Value changed...
            if ~isempty(obj.ValueChangedFcn)
                evtData = structeditor.eventdata.ValueChanged(...
                    fieldName, oldValue, newValue, src);
                obj.ValueChangedFcn(obj, evtData)
            end
        end

        function onFieldValueChanging(~, ~, ~)
            % Todo. Not implemented yet
            % Todo. Look at the decorators from weblab, i.e throttle and
            % debounce
        end

        function onActionButtonPushed(obj, src, ~, config)
            fieldName = src.Tag;
            oldValue = obj.DataModified.(fieldName);

            switch config.Kind
                case "browse"
                    newValue = obj.getPathFromDialog(config.Action, oldValue);

                case "color"
                    newValue = uisetcolor(oldValue);
                    if isequal(newValue, 0)
                        return
                    end

                case "action"
                    if isa(config.Action, "function_handle")
                        newValue = config.Action(obj.DataModified);
                    else
                        return
                    end
            end

            if isequal(newValue, oldValue)
                return
            end

            newData = obj.DataModified;
            newData.(fieldName) = obj.convertControlValue(newValue, oldValue);
            obj.Data = newData;
        end

        function value = convertControlValue(~, value, oldValue)
            switch class(oldValue)
                case {'single', 'double'}
                    if ischar(value) || isstring(value)
                        value = str2num(char(value)); %#ok<ST2NM>
                    end
                    value = cast(value, 'like', oldValue);

                case {'uint8', 'uint16', 'uint32', 'uint64', 'int8', 'int16', 'int32', 'int64'}
                    if ischar(value) || isstring(value)
                        value = str2num(char(value)); %#ok<ST2NM>
                    end
                    value = cast(value, 'like', oldValue);

                case 'categorical'
                    value = categorical(cellstr(string(value)), categories(oldValue));

                case 'cell'
                    if all(cellfun(@ischar, oldValue)) || all(cellfun(@isstring, oldValue))
                        value = strtrim(split(string(value), ","));
                        value = cellstr(value(value ~= ""));
                    elseif all(cellfun(@isnumeric, oldValue))
                        numericValue = str2num(char(value)); %#ok<ST2NM>
                        value = num2cell(numericValue);
                    end

                case 'string'
                    value = string(value);

                case 'char'
                    value = char(value);
            end
        end

        function pathString = getPathFromDialog(~, action, oldValue)
            if isempty(oldValue)
                initPath = pwd;
            else
                initPath = char(oldValue);
            end

            switch action
                case 'uigetfile'
                    [fileName, folderPath] = uigetfile({'*', 'All Files (*.*)'}, '', initPath);
                    if isequal(fileName, 0)
                        pathString = oldValue;
                    else
                        pathString = fullfile(folderPath, fileName);
                    end

                case 'uiputfile'
                    [fileName, folderPath] = uiputfile({'*', 'All Files (*.*)'}, '', initPath);
                    if isequal(fileName, 0)
                        pathString = oldValue;
                    else
                        pathString = fullfile(folderPath, fileName);
                    end

                case 'uigetdir'
                    selectedPath = uigetdir(initPath);
                    if isequal(selectedPath, 0)
                        pathString = oldValue;
                    else
                        pathString = selectedPath;
                    end
            end
        end
    end
end
