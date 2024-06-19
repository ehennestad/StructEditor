classdef NumericEditFieldStyle < ...
        structeditor.theme.mixin.HasBackgroundColor & ...
        structeditor.theme.mixin.HasFontStyle & ...
        structeditor.theme.mixin.HasFontColor

    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.NumericEditFieldStyle();
            style.BackgroundColor = 'white';
            style.FontColor = colorModel.PrimaryColorA;
        end
    end
end