classdef LabelStyle < ...
        structeditor.theme.mixin.HasFontStyle & ...
        structeditor.theme.mixin.HasFontColor

    methods (Static)
        function style = fromColorModel(colorModel)
            style = structeditor.theme.LabelStyle();
            style.FontColor = colorModel.PrimaryColorA;
            style.FontWeight = 'bold';
        end
    end
end