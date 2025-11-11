classdef (Abstract) AbstractThemeManager < handle
    %ABSTRACTTHEMEMANAGER Base class for theme management implementations
    %   This abstract class defines the interface for theme managers,
    %   allowing different implementations for different MATLAB versions.
    %   Concrete implementations should provide version-specific theme
    %   management capabilities.
    %
    %   See also: ThemeManagerR2025a, createThemeManager
    
    properties (Abstract, SetAccess = protected)
        % IsSupported - True if this theme manager is supported in current MATLAB version
        IsSupported (1,1) logical
    end
    
    properties (Abstract)
        % CurrentTheme - The current theme setting ('light', 'dark', or 'default')
        CurrentTheme (1,1) string
    end
    
    methods (Abstract)
        % attachToFigure - Attach theme manager to a figure
        %   attachToFigure(obj, figureHandle) sets up theme management
        %   for the specified figure, including any callbacks needed to
        %   respond to theme changes.
        attachToFigure(obj, figureHandle)
        
        % detachFromFigure - Remove theme manager from a figure
        %   detachFromFigure(obj, figureHandle) removes theme management
        %   from the specified figure and cleans up any callbacks.
        detachFromFigure(obj, figureHandle)
        
        % setTheme - Set the theme for managed figure(s)
        %   setTheme(obj, themeName) sets the theme to the specified
        %   value ('light', 'dark', or 'default').
        setTheme(obj, themeName)
        
        % getTheme - Get the current theme of a figure
        %   themeName = getTheme(obj, figureHandle) returns the current
        %   theme of the specified figure.
        themeName = getTheme(obj, figureHandle)
        
        % addThemeChangedCallback - Add callback for theme changes
        %   addThemeChangedCallback(obj, callback) registers a callback
        %   function to be executed when the theme changes. The callback
        %   should have the signature: callback(src, event)
        addThemeChangedCallback(obj, callback)
        
        % removeThemeChangedCallback - Remove theme change callback
        %   removeThemeChangedCallback(obj, callback) removes a previously
        %   registered theme change callback.
        removeThemeChangedCallback(obj, callback)
    end
    
    methods (Abstract, Access = protected)
        % onThemeChanged - Internal handler for theme changes
        %   onThemeChanged(obj, src, event) is called when the theme
        %   changes. Concrete implementations should override this to
        %   handle theme changes appropriately.
        onThemeChanged(obj, src, event)
    end
    
    methods (Static)
        function tf = isVersionSupported(requiredVersion)
            % isVersionSupported - Check if MATLAB version meets requirement
            %   tf = isVersionSupported(requiredVersion) returns true if
            %   the current MATLAB version is equal to or newer than the
            %   required version string (e.g., '9.14' for R2025a).
            
            matlabVersion = version('-release');
            % Extract year and version letter (e.g., '2025a')
            requiredRelease = obj.versionToRelease(requiredVersion);
            tf = strcmp(matlabVersion, requiredRelease) || ...
                 str2double(matlabVersion(1:4)) > str2double(requiredRelease(1:4));
        end
    end
    
    methods (Static, Access = protected)
        function release = versionToRelease(versionStr)
            % versionToRelease - Convert version number to release string
            %   Convert version number like '9.14' to release 'R2025a'
            %   This is a simplified mapping for common versions.
            
            versionMap = containers.Map(...
                {'9.14', '9.13', '9.12', '9.11', '9.10'}, ...
                {'2025a', '2024b', '2024a', '2023b', '2023a'});
            
            if isKey(versionMap, versionStr)
                release = versionMap(versionStr);
            else
                % For unknown versions, return current release
                release = version('-release');
            end
        end
    end
end
