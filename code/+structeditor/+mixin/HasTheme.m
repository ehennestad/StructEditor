classdef HasTheme < handle

    properties
        Theme (1,1) structeditor.theme.Theme = structeditor.enum.Theme.Light
    end

    properties (Abstract, Constant, Access = protected)
        %DEFAULT_THEME % Todo
    end

    properties (Access = protected) % Cached UI components?
        StylableUIComponents
        ThemedUIComponents
    end

    properties (Constant, Access = private)
        %
    end

    methods
        function obj = HasTheme(propValues)
            arguments
                propValues.Theme
            end
            if isfield(propValues, 'Theme')
                obj.Theme = propValues.Theme;
            end
        end
    end

    methods
        function set.Theme(obj, value)
            obj.Theme = value;
            obj.postSetTheme()
        end
    end

    methods (Access = protected)
        function updateTheme(obj, figureHandle)
            
            % obj.Theme.styleFigure( figureHandle )

            % Find all children...
            uiComponents = findall(figureHandle);

            componentTypes = arrayfun(@(h) class(h), uiComponents, 'UniformOutput', 0);
            [uniqueTypes, ~, iC] = unique( componentTypes );

            for i = 1:numel(uniqueTypes)
                componentHandles = uiComponents(iC==i);
                obj.Theme.styleComponent(componentHandles)
            end
        end
    end

    methods (Access = private)
        function postSetTheme(obj)
            mc = metaclass(obj);
            
            % Find components to apply theme to.
            metaProperties = mc.PropertyList;

            isThemedComponentProperty = strcmp({metaProperties.Description}, ...
                "Themed UI Components");

            isStylableComponentProperty = strcmp({metaProperties.Description}, ...
                "Themed UI Components");

            if any(isThemedComponentProperty)
                obj.ThemedUIComponents = metaProperties(isThemedComponentProperty).Name;
            end
            if any(isStylableComponentProperty)
                obj.StylableUIComponents = metaProperties(isStylableComponentProperty).Name;
            end
            %obj.updateTheme()
        end
    end

end