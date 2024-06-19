classdef FigureStyle

    properties
        Color = [0.94,0.94,0.94]
    end

    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.FigureStyle();
            style.Color = colorModel.BackgroundColor;
        end
    end
end