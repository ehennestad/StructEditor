function exportToThemeFolder(themeName, themeObject, themeObjectName)
    
    % Assemble savepath.
    themeFolder = structeditor.utility.getThemeFolder(themeName);
    
    S = warning('off', 'MATLAB:structOnObject');
    s = struct(themeObject);
    warning(S)
    
    writestruct(s, fullfile(themeFolder, [themeObjectName, '.json']), 'PrettyPrint', true )
end