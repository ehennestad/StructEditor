function themeManager = createThemeManager()
    %createThemeManager Factory function to create appropriate theme manager
    %   themeManager = createThemeManager() creates and returns a theme
    %   manager instance appropriate for the current MATLAB version.
    %
    %   For MATLAB R2025a and later, returns a ThemeManagerR2025a instance
    %   that uses built-in theme support. For earlier versions, returns a
    %   ThemeManagerLegacy instance that uses the custom
    %   structeditor.theme.Theme system.
    %
    %   Example:
    %       % Create appropriate theme manager for current MATLAB version
    %       tm = structeditor.theme.createThemeManager();
    %       
    %       if ~isempty(tm) && tm.IsSupported
    %           fig = uifigure();
    %           tm.attachToFigure(fig);
    %           tm.setTheme('dark');
    %       end
    %
    %   See also: ThemeManagerR2025a, ThemeManagerLegacy, AbstractThemeManager
    
    if exist('isMATLABReleaseOlderThan', 'file') && isMATLABReleaseOlderThan("R2025a")
        themeManager = structeditor.theme.manager.ThemeManagerLegacy();
    else
        themeManager = structeditor.theme.manager.ThemeManagerR2025a();
    end
end
