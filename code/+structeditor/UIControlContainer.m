% UIControlContainer
classdef UIControlContainer < handle & matlab.mixin.SetGetExactNames & structeditor.mixin.HasTheme
    
    % Todo:
    %   Setting for label position, i.e left or above

    properties (Dependent)
        Data (1,1) struct
    end

    properties
        ValueChangedFcn
    end

    properties (Access = private)
        DataName (1,1) string = missing
        DataModified (1,1) struct
        DataOriginal (1,1) struct
    end

    properties (Constant, Hidden = true) % Move to appwindow superclass
        DEFAULT_THEME = nansen.theme.getThemeColors('dark-purple');
    end

    properties (Dependent)
        IsClean
    end

    properties %(Access = private)
        UIControls
        Parent
        UIGridLayout
    end

    properties (Access = private)
        IsConstructed = false;
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
            end
            % if isfield(propValues, 'Theme')
            %     superArgs = {'Theme', propValues.Theme};
            %     propValues = rmfield(propValues, 'Theme');
            % else
            %     superArgs = {};
            % end
            % obj = obj@structeditor.mixin.HasTheme(superArgs{:})

            propNvPairs = namedargs2cell(propValues);
            obj.set(propNvPairs{:});

            obj.Parent = hParent;
            [obj.DataModified, obj.DataOriginal] = deal(data);
            
            % Todo: Assign property values

            % Todo: Create grid layout
            obj.createGridLayout()

            % Todo:
            obj.createUIControls

            % Todo:
            obj.IsConstructed = true;
            obj.UIGridLayout.Visible = 'on';
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
            value = obj.DataModified();
        end

        function value = get.IsClean(obj)
            value = isequal(obj.DataModified, obj.DataOriginal);
        end
    end

    % Property post set methods
    methods
        function postSetData(obj, oldData, newData)
            % Pre - construction
            if ~obj.IsConstructed
                return
            end

            % Find which field changed.
            fieldNames = fieldnames(oldData);

            oldValues = struct2cell(oldData);
            newValues = struct2cell(newData);

            for i = 1:numel(fieldNames)
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

    % Component creation
    methods (Access = private)
        function createGridLayout(obj)
            obj.UIGridLayout = uigridlayout(obj.Parent);
            obj.UIGridLayout.Visible = 'off';
            
            obj.UIGridLayout.ColumnWidth = {'1x', 200, 30};

            numRows = numel( fieldnames(obj.DataModified) );
            obj.UIGridLayout.RowHeight = repmat({obj.RowHeight}, 1, numRows);

            obj.UIGridLayout.ColumnSpacing = obj.ColumnSpacing;
            obj.UIGridLayout.RowSpacing = obj.RowSpacing;
        
            obj.UIGridLayout.BackgroundColor = obj.Theme.ColorModel.BackgroundColor;
            obj.UIGridLayout.Scrollable = true;
        end
    
        function createUIControls(obj) % Todo: Should be method of abstract superclass
            fieldNames = string( fieldnames(obj.DataModified) );

            for i = 1:numel(fieldNames)
                name = fieldNames(i);
                value = obj.DataModified.(name);

                obj.createLabel(i, name)
                hControl = obj.createControl(i, name, value);
                obj.UIControls.(name) = hControl;
            end
        end

        function createLabel(obj, iRow, name)
            hLabel = uilabel( obj.UIGridLayout );
            hLabel.Text = [utility.string.varname2label(char(name)), ':'];
            %hLabel.FontWeight = 'bold';
            hLabel.FontColor = obj.Theme.ColorModel.TextColor;
            hLabel.FontName = obj.FontName;
            hLabel.FontSize = obj.FontSize;
            hLabel.Layout.Row = iRow;
            hLabel.Layout.Column = 1;
            hLabel.HorizontalAlignment = 'right';
            hLabel.Tag = name;
        end

        function hControl = createControl(obj, iRow, name, value, config)

            if nargout < 4; config = []; end
            
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
                end
            end

            hControl.Layout.Column = 2; 
            hControl.Layout.Row = iRow;
            hControl.Tag = name;
             
            if isprop(hControl, 'BackgroundColor')
                hControl.BackgroundColor = obj.Theme.ColorModel.BackgroundColor;
            end
            hControl.FontColor = obj.Theme.ColorModel.TextColor;
            hControl.FontName = obj.FontName;
            hControl.FontSize = obj.FontSize;

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
