function themeFolder = getThemeFolder(themeName)
    rootFolder = fileparts(fileparts(mfilename('fullpath')));
    themeFolder = fullfile(rootFolder, 'resources', 'theme', themeName);
end