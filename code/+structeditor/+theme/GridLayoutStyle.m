classdef GridLayoutStyle < ...
        structeditor.theme.mixin.HasBackgroundColor
    
    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.GridLayoutStyle();
            style.BackgroundColor = colorModel.BackgroundColor;
        end
    end
end