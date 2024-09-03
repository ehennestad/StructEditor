classdef Theme < handle

    % Brainstorm:
    %   - Should be able to construct a theme from a base set of primary
    %     and secondary colors..
    %   - Incorporate methods for setting border color/radius...
    
    % Todo: Update themes if more specific overrides exist...
    
    properties (Dependent)
        FigureStyle
        PanelStyle
        GridLayoutStyle        
        PrimaryButtonStyle
        DefaultButtonStyle
        %DashedButtonStyle
        %CheckBoxStyle
        DropDownStyle
        EditFieldStyle
        NumericEditFieldStyle
        SpinnerStyle
        LabelStyle
        %TableStyle
    end
    
    properties (Access = public)
        ColorModel % The color model or source data
    end
    
    methods % Constructor
        function obj = Theme(colorModel)
            obj.ColorModel = colorModel;
        end
    end

    methods % Get methods for dependent properties
        
        % Get methods for dependent properties

        function style = get.FigureStyle(obj)
            style = structeditor.theme.FigureStyle.fromColorModel(obj.ColorModel);
        end
        
        function style = get.GridLayoutStyle(obj)
            style = structeditor.theme.GridLayoutStyle.fromColorModel(obj.ColorModel);
        end
        
        function style = get.PanelStyle(obj)
            style = structeditor.theme.PanelStyle.fromColorModel(obj.ColorModel);
        end

        function style = get.PrimaryButtonStyle(obj)
            style = structeditor.theme.ButtonStyle.primaryButtonStyleFromColorModel(obj.ColorModel);
        end
        
        function style = get.DefaultButtonStyle(obj)
            style = structeditor.theme.ButtonStyle.defaultButtonStyleFromColorModel(obj.ColorModel);
        end

        function style = get.LabelStyle(obj)
            style = structeditor.theme.LabelStyle.fromColorModel(obj.ColorModel);
        end
        
        function style = get.DropDownStyle(obj)
            style = structeditor.theme.DropDownStyle.fromColorModel(obj.ColorModel);
        end
        
        function style = get.EditFieldStyle(obj)
            style = structeditor.theme.EditFieldStyle.fromColorModel(obj.ColorModel);
        end
        
        function style = get.NumericEditFieldStyle(obj)
            style = structeditor.theme.NumericEditFieldStyle.fromColorModel(obj.ColorModel);
        end
        
        function style = get.SpinnerStyle(obj)
            style = structeditor.theme.SpinnerStyle.fromColorModel(obj.ColorModel);
        end      
    end

    methods % Methods for styling...
        function styleFigure(obj, figureHandle)
            figureProps = properties( obj.FigureStyle );
            for i = 1:numel(figureProps)
                iName = figureProps{i};
                figureHandle.(iName) = obj.FigureStyle.(iName);
            end
        end

        function styleComponent(obj, componentHandles)
            className = class(componentHandles);
            shortName = regexp(className, '\w+$', 'match', 'once');

            styleName = sprintf('%sStyle', shortName);

            if isprop(obj, styleName)
                style = obj.(styleName);
    
                styleProps = properties( style );
    
                for i = 1:numel(styleProps)
                    iPropName = styleProps{i};
                    set(componentHandles, iPropName, style.(iPropName));
                end
            else
                if getpref('StructEditor', 'dev', false)
                    fprintf('No style available for "%s"\n', className)
                end
            end
        end
    end
end
