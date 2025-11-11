classdef ThemeManagerLegacy < structeditor.abstract.AbstractThemeManager
    %THEMEMANAGERLEGACY Theme manager for pre-R2025a MATLAB versions
    %   This class provides theme management using the custom
    %   structeditor.theme.Theme system for MATLAB versions that don't
    %   have built-in theme support.
    %
    %   Example:
    %       % Create a legacy theme manager
    %       tm = structeditor.theme.manager.ThemeManagerLegacy();
    %       
    %       % Create a figure and attach theme manager
    %       fig = uifigure();
    %       tm.attachToFigure(fig);
    %       
    %       % Set theme using enum
    %       tm.setTheme('dark');
    %
    %   See also: structeditor.abstract.AbstractThemeManager, 
    %             ThemeManagerR2025a, createThemeManager
    
    properties (SetAccess = protected)
        IsSupported = true % Always supported
    end
    
    properties
        CurrentTheme = "light"
    end
    
    properties (Access = private)
        ManagedFigures (:,1) matlab.ui.Figure = matlab.ui.Figure.empty(0,1)
        FigureThemes containers.Map % Map figure handles to Theme objects
        ThemeChangedCallbacks (:,1) cell = {}
        ThemeEnumMap containers.Map % Map theme names to enums
    end
    
    methods
        function obj = ThemeManagerLegacy()
            %THEMEMANAGERLEGACY Construct a legacy theme manager
            
            % Initialize storage
            obj.FigureThemes = containers.Map('KeyType', 'double', 'ValueType', 'any');
            
            % Create mapping from theme names to structeditor.enum.Theme
            obj.ThemeEnumMap = containers.Map(...
                {'light', 'dark', 'dark-aubergine', 'default'}, ...
                {structeditor.enum.Theme.Light, ...
                 structeditor.enum.Theme.Dark, ...
                 structeditor.enum.Theme.DarkAubergine, ...
                 structeditor.enum.Theme.Light}); % default -> light
        end
        
        function attachToFigure(obj, figureHandle)
            %attachToFigure Attach theme manager to a figure
            
            if ~isvalid(figureHandle)
                error('ThemeManagerLegacy:InvalidFigure', 'Invalid figure handle.');
            end
            
            % Check if figure is already managed
            if any(obj.ManagedFigures == figureHandle)
                return;
            end
            
            % Add to managed figures
            obj.ManagedFigures(end+1) = figureHandle;
            
            % Create and store theme object for this figure
            if obj.ThemeEnumMap.isKey(char(obj.CurrentTheme))
                themeEnum = obj.ThemeEnumMap(char(obj.CurrentTheme));
            else
                themeEnum = structeditor.enum.Theme.Light;
            end
            
            obj.FigureThemes(double(figureHandle)) = themeEnum;
            
            % Apply theme to figure
            obj.applyThemeToFigure(figureHandle, themeEnum);
        end
        
        function detachFromFigure(obj, figureHandle)
            %detachFromFigure Remove theme manager from a figure
            
            if ~isvalid(figureHandle)
                return;
            end
            
            % Remove from managed figures
            obj.ManagedFigures(obj.ManagedFigures == figureHandle) = [];
            
            % Remove theme object
            figKey = double(figureHandle);
            if obj.FigureThemes.isKey(figKey)
                obj.FigureThemes.remove(figKey);
            end
        end
        
        function setTheme(obj, themeName)
            %setTheme Set the theme for all managed figures
            
            arguments
                obj
                themeName (1,1) string {mustBeMember(themeName, ["light", "dark", "dark-aubergine", "default", "ndi"])}
            end
            
            obj.CurrentTheme = themeName;
            
            % Get theme enum
            if obj.ThemeEnumMap.isKey(char(themeName))
                themeEnum = obj.ThemeEnumMap(char(themeName));
            else
                themeEnum = structeditor.enum.Theme.Light;
            end
            
            % Apply theme to all managed figures
            for i = 1:numel(obj.ManagedFigures)
                if isvalid(obj.ManagedFigures(i))
                    obj.FigureThemes(double(obj.ManagedFigures(i))) = themeEnum;
                    obj.applyThemeToFigure(obj.ManagedFigures(i), themeEnum);
                    
                    % Trigger callbacks
                    obj.onThemeChanged(obj.ManagedFigures(i), []);
                end
            end
        end
        
        function themeName = getTheme(obj, figureHandle)
            %getTheme Get the current theme of a figure
            
            if nargin < 2 || isempty(figureHandle)
                % Return current theme setting
                themeName = obj.CurrentTheme;
            else
                % Get theme from specific figure
                if isvalid(figureHandle)
                    figKey = double(figureHandle);
                    if obj.FigureThemes.isKey(figKey)
                        themeEnum = obj.FigureThemes(figKey);
                        % Convert enum back to string
                        themeName = obj.enumToThemeName(themeEnum);
                    else
                        themeName = "light";
                    end
                else
                    themeName = "light";
                end
            end
        end
        
        function addThemeChangedCallback(obj, callback)
            %addThemeChangedCallback Add callback for theme changes
            
            if ~isa(callback, 'function_handle')
                error('ThemeManagerLegacy:InvalidCallback', ...
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
        
        function themeObject = getThemeObject(obj, figureHandle)
            %getThemeObject Get the Theme object for a figure
            %   This is useful for classes that need direct access to the
            %   Theme object for custom component styling.
            
            if isvalid(figureHandle)
                figKey = double(figureHandle);
                if obj.FigureThemes.isKey(figKey)
                    themeObject = obj.FigureThemes(figKey);
                else
                    themeObject = structeditor.enum.Theme.Light;
                end
            else
                themeObject = [];
            end
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
        function onThemeChanged(obj, src, ~)
            %onThemeChanged Internal handler for theme changes
            
            % Create a synthetic event structure similar to R2025a
            eventData = struct();
            eventData.Source = src;
            eventData.EventName = 'ThemeChanged';
            
            if isvalid(src)
                figKey = double(src);
                if obj.FigureThemes.isKey(figKey)
                    themeEnum = obj.FigureThemes(figKey);
                    eventData.Theme = themeEnum;
                    eventData.ThemeName = obj.enumToThemeName(themeEnum);
                    eventData.BaseColorStyle = char(themeEnum);
                end
            end
            
            % Execute all registered callbacks
            for i = 1:numel(obj.ThemeChangedCallbacks)
                try
                    callback = obj.ThemeChangedCallbacks{i};
                    callback(src, eventData);
                catch ME
                    warning('ThemeManagerLegacy:CallbackError', ...
                        'Error executing theme changed callback: %s', ME.message);
                end
            end
        end
        
        function applyThemeToFigure(~, figureHandle, themeEnum)
            %applyThemeToFigure Apply theme to a figure and its components
            
            if ~isvalid(figureHandle)
                return;
            end
            
            % Get the Theme object
            themeObj = themeEnum;
            
            % Apply to figure
            themeObj.styleComponent(figureHandle);
            
            % Find and style all children
            uiComponents = findall(figureHandle);
            
            if isempty(uiComponents)
                return;
            end
            
            % Get unique component types
            componentTypes = arrayfun(@(h) class(h), uiComponents, 'UniformOutput', false);
            [uniqueTypes, ~, iC] = unique(componentTypes);
            
            % Style each type
            for i = 1:numel(uniqueTypes)
                componentHandles = uiComponents(iC == i);
                try
                    themeObj.styleComponent(componentHandles);
                catch ME
                    % Some components might not have style support
                    if getpref('StructEditor', 'dev', false)
                        fprintf('Warning styling %s: %s\n', uniqueTypes{i}, ME.message);
                    end
                end
            end
        end
        
        function themeName = enumToThemeName(obj, themeEnum)
            %enumToThemeName Convert theme enum to string name
            
            % Find matching key in map
            keys = obj.ThemeEnumMap.keys;
            values = obj.ThemeEnumMap.values;
            
            for i = 1:numel(values)
                if isequal(values{i}, themeEnum)
                    themeName = string(keys{i});
                    return;
                end
            end
            
            % Default to light
            themeName = "light";
        end
    end
end
