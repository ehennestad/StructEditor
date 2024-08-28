function exportToThemeFolder(themeName, themeObject, themeObjectName)
    
    % Assemble savepath.
    themeFolder = structeditor.utility.getThemeFolder(themeName);
    
    warningState = warning('off', 'MATLAB:structOnObject');
    S = struct(themeObject);
    warning(warningState)
    
    themeFilePath = fullfile(themeFolder, [themeObjectName, '.json']);
    structeditor.utility.writestruct(S, themeFilePath)
end