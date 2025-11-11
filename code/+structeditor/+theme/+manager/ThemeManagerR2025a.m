classdef ThemeManagerR2025a < structeditor.abstract.AbstractThemeManager
    %THEMEMANAGERR2025A Theme manager for MATLAB R2025a and later
    %   This class provides theme management using MATLAB's built-in
    %   theme support introduced in R2025a. It uses the figure's Theme
    %   property and ThemeChangedFcn callback for automatic theme updates.
    %
    %   Example:
    %       % Create a theme manager
    %       tm = structeditor.theme.manager.ThemeManagerR2025a();
    %       
    %       % Create a figure and attach theme manager
    %       fig = uifigure();
    %       tm.attachToFigure(fig);
    %       
    %       % Set theme
    %       tm.setTheme('dark');
    %       
    %       % Add custom callback for theme changes
    %       tm.addThemeChangedCallback(@(src,evt) disp('Theme changed!'));
    %
    %   See also: structeditor.abstract.AbstractThemeManager, createThemeManager
    
    properties (SetAccess = protected)
        IsSupported
    end
    
    properties
        CurrentTheme = "light"
    end
    
    properties (Access = private)
        ManagedFigures (:,1) matlab.ui.Figure = matlab.ui.Figure.empty(0,1)
        ThemeChangedCallbacks (:,1) cell = {}
        OriginalCallbacks containers.Map % Store original ThemeChangedFcn
    end
    
    methods
        function obj = ThemeManagerR2025a()
            %THEMEMANAGERR2025A Construct a theme manager for R2025a+
            
            % Check if running R2025a or later
            obj.IsSupported = obj.checkSupport();
            
            if ~obj.IsSupported
                warning('ThemeManagerR2025a:UnsupportedVersion', ...
                    'MATLAB R2025a or later is required for built-in theme support. This theme manager will have limited functionality.');
            end
            
            % Initialize storage for original callbacks
            obj.OriginalCallbacks = containers.Map('KeyType', 'double', 'ValueType', 'any');
        end
        
        function attachToFigure(obj, figureHandle)
            %attachToFigure Attach theme manager to a figure
            
            if ~isvalid(figureHandle)
                error('ThemeManagerR2025a:InvalidFigure', 'Invalid figure handle.');
            end
            
            % Check if figure is already managed
            if any(obj.ManagedFigures == figureHandle)
                return;
            end
            
            % Add to managed figures
            obj.ManagedFigures(end+1) = figureHandle;
            
            if obj.IsSupported
                % Store original callback if it exists
                if ~isempty(figureHandle.ThemeChangedFcn)
                    obj.OriginalCallbacks(double(figureHandle)) = figureHandle.ThemeChangedFcn;
                end
                
                % Set up theme changed callback
                figureHandle.ThemeChangedFcn = @(src, evt) obj.onThemeChanged(src, evt);
                
                % Update current theme from figure
                if isprop(figureHandle, 'Theme') && ~isempty(figureHandle.Theme)
                    obj.CurrentTheme = string(figureHandle.Theme.BaseColorStyle);
                end

                % Set initial theme if not default
                if obj.CurrentTheme ~= "default"
                    %theme(figureHandle, obj.CurrentTheme);
                end
                
            end
        end
        
        function detachFromFigure(obj, figureHandle)
            %detachFromFigure Remove theme manager from a figure
            
            if ~isvalid(figureHandle)
                return;
            end
            
            % Remove from managed figures
            obj.ManagedFigures(obj.ManagedFigures == figureHandle) = [];
            
            if obj.IsSupported
                % Restore original callback if it existed
                figKey = double(figureHandle);
                if isKey(obj.OriginalCallbacks, figKey)
                    figureHandle.ThemeChangedFcn = obj.OriginalCallbacks(figKey);
                    remove(obj.OriginalCallbacks, figKey);
                else
                    figureHandle.ThemeChangedFcn = [];
                end
            end
        end
        
        function setTheme(obj, themeName)
            %setTheme Set the theme for all managed figures
            
            arguments
                obj
                themeName (1,1) string {mustBeMember(themeName, ["light", "dark", "default"])}
            end
            
            obj.CurrentTheme = themeName;
            
            if ~obj.IsSupported
                warning('ThemeManagerR2025a:ThemeNotSupported', ...
                    'Theme setting is not supported in this MATLAB version.');
                return;
            end
            
            % Apply theme to all managed figures
            for i = 1:numel(obj.ManagedFigures)
                if isvalid(obj.ManagedFigures(i))
                    if themeName == "default"
                        % Remove explicit theme to use system default
                        obj.ManagedFigures(i).Theme = [];
                    else
                        theme(obj.ManagedFigures(i), char(themeName));
                    end
                end
            end
        end
        
        function themeName = getTheme(obj, figureHandle)
            %getTheme Get the current theme of a figure
            
            if ~obj.IsSupported
                themeName = "unsupported";
                return;
            end
            
            if nargin < 2 || isempty(figureHandle)
                % Return current theme setting
                themeName = obj.CurrentTheme;
            else
                % Get theme from specific figure
                if isvalid(figureHandle) && isprop(figureHandle, 'Theme') && ~isempty(figureHandle.Theme)
                    themeName = string(figureHandle.Theme.BaseColorStyle);
                else
                    themeName = "default";
                end
            end
        end
        
        function addThemeChangedCallback(obj, callback)
            %addThemeChangedCallback Add callback for theme changes
            
            if ~isa(callback, 'function_handle')
                error('ThemeManagerR2025a:InvalidCallback', ...
                    'Callback must be a function handle.');
            end
            
            % Add callback to list if not already present
            if ~any(cellfun(@(c) isequal(c, callback), obj.ThemeChangedCallbacks))
                obj.ThemeChangedCallbacks{end+1} = callback;
            end
        end
        
        function removeThemeChangedCallback(obj, callback)
            %removeThemeChangedCallback Remove theme change callback
            
            % Find and remove callback
            matches = cellfun(@(c) isequal(c, callback), obj.ThemeChangedCallbacks);
            obj.ThemeChangedCallbacks(matches) = [];
        end
        
        function delete(obj)
            %delete Cleanup when object is deleted
            
            % Detach from all managed figures
            figs = obj.ManagedFigures; % Copy to avoid modification during iteration
            for i = 1:numel(figs)
                if isvalid(figs(i))
                    obj.detachFromFigure(figs(i));
                end
            end
        end
    end
    
    methods (Access = protected)
        function onThemeChanged(obj, src, event)
            %onThemeChanged Internal handler for theme changes
            
            % Update current theme
            if isprop(src, 'Theme') && ~isempty(src.Theme)
                newTheme = string(src.Theme.BaseColorStyle);
                obj.CurrentTheme = newTheme;
            end
            
            % Call original callback if it existed
            figKey = double(src);
            if isKey(obj.OriginalCallbacks, figKey)
                originalCallback = obj.OriginalCallbacks(figKey);
                if ~isempty(originalCallback)
                    if isa(originalCallback, 'function_handle')
                        originalCallback(src, event);
                    elseif iscell(originalCallback)
                        feval(originalCallback{1}, src, event, originalCallback{2:end});
                    end
                end
            end
            
            % Execute all registered callbacks
            for i = 1:numel(obj.ThemeChangedCallbacks)
                try
                    callback = obj.ThemeChangedCallbacks{i};
                    callback(src, event);
                catch ME
                    warning('ThemeManagerR2025a:CallbackError', ...
                        'Error executing theme changed callback: %s', ME.message);
                end
            end
        end
        
        function tf = checkSupport(~)
            %checkSupport Check if current MATLAB version supports themes
            
            % R2025a is version 9.14
            % Check if theme function exists and figure has Theme property
            tf = exist('theme', 'file') == 2;
            
            if tf
                % Additional check: verify Figure has Theme property
                try
                    mc = ?matlab.ui.Figure;
                    propNames = {mc.PropertyList.Name};
                    tf = any(strcmp(propNames, 'Theme'));
                catch
                    tf = false;
                end
            end
        end
    end
end
