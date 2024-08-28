classdef Theme < handle & structeditor.theme.Theme
% Theme enumeration - Provide some themes as enumeration values.

% Note: The themes are defined in the resources folder, and a folder for a
% given theme must have a matching name.

    enumeration
        Light('light')
        Dark('dark')
        DarkAubergine('dark-aubergine')
        NDI('ndi')
    end

    properties (SetAccess = immutable, GetAccess = private)
        Name
    end
    
    methods
        function obj = Theme(name)
            colorModel = structeditor.enum.Theme.loadTheme(name);
            obj = obj@structeditor.theme.Theme(colorModel)
            
            obj.Name = name;
        end

        function saveColorModel(obj)
            themeFolder = structeditor.utility.getThemeFolder(obj.Name);
            colorModelFilePath = fullfile(themeFolder, 'DualColorModel.json');
            structeditor.utility.writestruct(obj.ColorModel, colorModelFilePath);
        end
    end

    methods (Static)
        function colorModel = loadTheme(name)
            themeFolder = structeditor.utility.getThemeFolder(name);
            colorModelFilePath = fullfile(themeFolder, 'DualColorModel.json');

            if isfile(colorModelFilePath)
                S = jsondecode( fileread(colorModelFilePath) );
                colorModel = S;
            end
        end
    end
end
