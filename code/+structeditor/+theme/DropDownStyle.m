classdef DropDownStyle < ...
        structeditor.theme.mixin.HasBackgroundColor & ...
        structeditor.theme.mixin.HasFontStyle & ...
        structeditor.theme.mixin.HasFontColor

    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.DropDownStyle();
            style.BackgroundColor = colorModel.SecondaryColorA;
            style.FontColor = colorModel.TextColor;
        end
    end
end