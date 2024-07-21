% UIControlContainer
classdef UIControlContainer < handle & matlab.mixin.SetGetExactNames & structeditor.mixin.HasTheme
    
    % Todo:
    %   Setting for label position, i.e left or above

    properties (Dependent)
        Data (1,1) struct
        Visible (1,1) matlab.lang.OnOffSwitchState
    end

    properties
        ValueChangedFcn
        LabelPosition (1,1) string {mustBeMember(LabelPosition, ["left", "above"])} = "left"
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
        UILabels matlab.ui.control.Label
        Parent
        UIGridLayout
    end

    properties (Access = private)
        IsConstructed = false;
        Visible_ (1,1) matlab.lang.OnOffSwitchState = 'on'
    end

    properties (SetAccess = immutable, GetAccess = private) %?
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
            end
            % if isfield(propValues, 'Theme')
            %     superArgs = {'Theme', propValues.Theme};
            %     propValues = rmfield(propValues, 'Theme');
            % else
            %     superArgs = {};
            % end
            % obj = obj@structeditor.mixin.HasTheme(superArgs{:})
            
            obj.set(propValues);

            obj.Parent = hParent;
            [obj.DataModified, obj.DataOriginal] = deal(data);
            
            if ~isempty(obj.LoadingHtmlSource)
                g = uigridlayout(hParent, 'ColumnWidth', {'1x'},'RowHeight', {'1x'}, 'Padding', 75 );
                h = uihtml(g, "HTMLSource", obj.LoadingHtmlSource);
            end

            % Todo: Assign property values

            % Todo: Create grid layout
            obj.createGridLayout()

            % Todo:
            obj.createUIControls

            % Todo:
            obj.IsConstructed = true;
            obj.UIGridLayout.Visible = obj.Visible_;
            if ~isempty(obj.LoadingHtmlSource)
                delete(h); delete(g)
            end
        end
    end

    methods 
        function reset(obj)
            
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
            obj.LabelPosition = value;
            obj.postSetLabelPosition()
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
                            hControl.Value = newValues{i};
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
                config = obj.getConfigField(obj.DataModified, name);

                if isequal(config, 'hidden')
                    continue
                end

                obj.createLabel(i, name)
                hControl = obj.createControl(i, name, value, config);
                obj.UIControls.(name) = hControl;
            end
        end

        function config = getConfigField(obj, data, name)
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

            if nargin < 4; config = []; end
            
            parentContainer = obj.UIGridLayout;

            % Create custom control / widget
            if ~isempty(config) % TODO.
                if ischar( config )
                    hControl = feval(config, parentContainer);
                elseif isa( config, 'function_handle' )
                    hControl = config(parentContainer);
                    hControl.BackgroundColor = 'w'; %todo?
                end
               
            % Create standard control / widget
            else 
                switch class(value)
                    case 'string'
                        hControl = uieditfield(parentContainer);
    
                    case 'char'
                        hControl = uieditfield(parentContainer);
    
                    case {'single', 'double'}
                        hControl = uieditfield(parentContainer, 'numeric');
    
                    case {'uint8'}
                        hControl = uispinner(parentContainer, 'Limits', [0,255]);
                        value = double(value);
    
                    case {'uint16'}
                        hControl = uispinner(parentContainer, 'Limits', [0,2^16-1]);
                        value = double(value);
    
                    case 'categorical'
                        hControl = uidropdown(parentContainer);
                        hControl.Items = categories(value);
                        value = char(value);
    
                    case 'logical'
                        hControl = uicheckbox(parentContainer);
                        hControl.Text = '';

                    case 'datetime'
                        hControl = uidatepicker(parentContainer);
                        if isempty(value)
                            value = NaT;
                        end
                end
            end

            obj.placeUIControl(hControl, iRow)

            hControl.Tag = name;
             
            if isprop(hControl, 'BackgroundColor')
                %hControl.BackgroundColor = obj.Theme.ColorModel.BackgroundColor;
            end
            if isprop(hControl, 'FontColor')
                hControl.FontColor = obj.Theme.ColorModel.TextColor;
                hControl.FontName = obj.FontName;
                hControl.FontSize = obj.FontSize;
            end

            if isprop(hControl, 'Value')
                hControl.Value = value;
                hControl.ValueChangedFcn = @obj.onFieldValueChanged;
            end

            try
                drawnow
                %ccTools.compCustomization(hControl, 'borderRadius', "5px")
            end
        end
    end

    methods
        function onFieldValueChanged(obj, src, evt)

            fieldName = src.Tag;
            
            oldValue = obj.DataModified.(fieldName);
            newValue = evt.Value;

            obj.DataModified.(fieldName) = newValue;

            % Todo: Value changed...
            if ~isempty(obj.ValueChangedFcn)
                evtData = structeditor.eventdata.ValueChanged(...
                    fieldName, oldValue, newValue);
                obj.ValueChangedFcn(obj, evtData)
            end
        end

        function onFieldValueChanging(obj, src, evt)
            % Todo.
            % Todo. look at the decorators from weblab, i.e throttle and
            % debounce
        end
    end
end
