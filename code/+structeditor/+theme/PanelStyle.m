classdef PanelStyle < ...
        structeditor.theme.mixin.HasBackgroundColor & ...
        structeditor.theme.mixin.HasForegroundColor & ...
        structeditor.theme.mixin.HasFontStyle

    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.PanelStyle();
            style.BackgroundColor = colorModel.BackgroundColor;
        end
    end
end