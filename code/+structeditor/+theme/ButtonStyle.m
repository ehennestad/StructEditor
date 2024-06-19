classdef ButtonStyle < ...
        structeditor.theme.mixin.HasBackgroundColor & ...
        structeditor.theme.mixin.HasFontStyle & ...
        structeditor.theme.mixin.HasFontColor

    methods (Static)

        function style = defaultButtonStyleFromColorModel(colorModel)
            style = structeditor.theme.ButtonStyle();
            style.BackgroundColor = colorModel.SecondaryColorA;
            style.FontColor = colorModel.PrimaryColorA;
        end
        function style = primaryButtonStyleFromColorModel(colorModel)
            style = structeditor.theme.ButtonStyle();
            style.BackgroundColor = colorModel.PrimaryColorA;
            style.FontColor = colorModel.SecondaryColorA;
        end
        function style = dashedButtonStyleFromColorModel(colorModel)
            style = structeditor.theme.ButtonStyle();
            % Todo...
        end
            
        function style = buttonStyleFromJson(jsonFilePath)

        end
    end
end