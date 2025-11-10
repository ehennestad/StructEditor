classdef DatePickerStyle < ...
        structeditor.theme.mixin.HasBackgroundColor & ...
        structeditor.theme.mixin.HasFontStyle & ...
        structeditor.theme.mixin.HasFontColor

    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.DatePickerStyle();
            style.BackgroundColor = colorModel.BackgroundColorEdit;
            style.FontColor = colorModel.TextColor;
        end
    end
end