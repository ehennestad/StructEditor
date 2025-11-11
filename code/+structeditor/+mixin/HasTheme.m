classdef HasTheme < handle
    %HASTHEME Mixin class for theme management using ThemeManager
    %   This mixin provides theme management capabilities to classes by
    %   incorporating a ThemeManager instance. It automatically selects
    %   the appropriate ThemeManager implementation based on MATLAB version:
    %   - R2025a+: Uses built-in MATLAB theme support
    %   - Pre-R2025a: Uses custom structeditor.theme.Theme system
    %
    %   Classes using this mixin should:
    %   1. Have a UIFigure property (or call setFigure() after creation)
    %   2. Call initializeTheme() after UI is created
    %   3. Call cleanupTheme() in their delete method
    %
    %   Example:
    %       classdef MyApp < handle & structeditor.mixin.HasTheme
    %           properties
    %               UIFigure
    %           end
    %           
    %           methods
    %               function obj = MyApp()
    %                   obj.UIFigure = uifigure();
    %                   obj.initializeTheme();
    %               end
    %               
    %               function delete(obj)
    %                   obj.cleanupTheme();
    %               end
    %           end
    %       end
    %
    %   See also: AbstractThemeManager, ThemeManagerR2025a, ThemeManagerLegacy

    properties (Access = private)
        % ThemeManager instance (version-appropriate)
        ThemeManager %structeditor.abstract.AbstractThemeManager
        
        % Figure handle for theme management
        ManagedFigure matlab.ui.Figure
    end

    properties (Dependent)
        % Theme - Current theme name ('light', 'dark', 'dark-aubergine', 'default')
        Theme (1,1) string
        
        % ThemeObject - For legacy compatibility, returns Theme object
        ThemeObject
    end

    properties (Access = protected)
        % Allow subclasses to store custom callbacks
        CustomThemeChangedCallback function_handle
    end

    methods
        function initializeTheme(obj, figureHandle, initialTheme)
            %initializeTheme Initialize theme management
            %   initializeTheme(obj) initializes with default figure and theme
            %   initializeTheme(obj, figureHandle) uses specified figure
            %   initializeTheme(obj, figureHandle, themeName) sets initial theme
            
            arguments
                obj
                figureHandle = []
                initialTheme (1,1) string = ""
            end
            
            % Get figure handle
            if isempty(figureHandle)
                % Try to find UIFigure property
                if isprop(obj, 'UIFigure') && ~isempty(obj.UIFigure) %#ok<MCNPN>
                    figureHandle = obj.UIFigure; %#ok<MCNPN>
                else
                    error('HasTheme:NoFigure', ...
                        'No figure handle provided and no UIFigure property found.');
                end
            end
            
            obj.ManagedFigure = figureHandle;
            
            % Create appropriate theme manager
            obj.ThemeManager = structeditor.theme.createThemeManager();
            
            if isempty(obj.ThemeManager)
                warning('HasTheme:NoThemeManager', ...
                    'No theme manager available. Theme management disabled.');
                return;
            end
            
            % Attach to figure
            obj.ThemeManager.attachToFigure(figureHandle);
            
            % Set initial theme
            if initialTheme ~= ""
                obj.ThemeManager.setTheme(initialTheme);
            end
            
            % Register internal callback
            obj.ThemeManager.addThemeChangedCallback(@obj.onThemeChangedInternal);
        end
        
        function setFigure(obj, figureHandle)
            %setFigure Set or change the managed figure
            
            if ~isempty(obj.ThemeManager) && ~isempty(obj.ManagedFigure)
                % Detach from old figure
                obj.ThemeManager.detachFromFigure(obj.ManagedFigure);
            end
            
            obj.ManagedFigure = figureHandle;
            
            if ~isempty(obj.ThemeManager) && ~isempty(figureHandle)
                obj.ThemeManager.attachToFigure(figureHandle);
            end
        end
        
        function cleanupTheme(obj)
            %cleanupTheme Cleanup theme management resources
            
            if ~isempty(obj.ThemeManager) && ~isempty(obj.ManagedFigure)
                if isvalid(obj.ManagedFigure)
                    obj.ThemeManager.detachFromFigure(obj.ManagedFigure);
                end
            end
        end
        
        function setTheme(obj, themeName)
            %setTheme Set the current theme
            
            arguments
                obj
                themeName (1,1) string {mustBeMember(themeName, ["light", "dark", "dark-aubergine", "default"])}
            end
            
            if ~isempty(obj.ThemeManager)
                obj.ThemeManager.setTheme(themeName);
            end
        end
        
        function addThemeChangedCallback(obj, callback)
            %addThemeChangedCallback Add custom callback for theme changes
            %   The callback will be called with signature: callback(src, event)
            
            obj.CustomThemeChangedCallback = callback;
        end
    end
    
    methods % Dependent property accessors
        function value = get.Theme(obj)
            %get.Theme Get current theme name
            
            if ~isempty(obj.ThemeManager)
                value = obj.ThemeManager.CurrentTheme;
            else
                value = "light";
            end
        end
        
        function set.Theme(obj, value)
            %set.Theme Set current theme name
            
            obj.setTheme(lower(value));
        end
        
        function value = get.ThemeObject(obj)
            %get.ThemeObject Get Theme object (for legacy compatibility)
            %   Returns the structeditor.theme.Theme object if using
            %   legacy theme manager, or creates one for the current theme.
            
            if ~isempty(obj.ThemeManager)
                % Check if it's a legacy theme manager with getThemeObject method
                if isa(obj.ThemeManager, 'structeditor.theme.manager.ThemeManagerLegacy')
                    value = obj.ThemeManager.getThemeObject(obj.ManagedFigure);
                else
                    % For R2025a+, create Theme object from current theme
                    themeName = obj.ThemeManager.CurrentTheme;
                    switch themeName
                        case 'dark'
                            value = structeditor.enum.Theme.Dark;
                        case 'dark-aubergine'
                            value = structeditor.enum.Theme.DarkAubergine;
                        otherwise
                            value = structeditor.enum.Theme.Light;
                    end
                end
            else
                value = structeditor.enum.Theme.Light;
            end
        end
    end
    
    methods (Access = protected)
        function updateTheme(obj, figureHandle)
            %updateTheme Update theme styling (legacy method for compatibility)
            %   This method is kept for backward compatibility but theme
            %   updates are now handled automatically by ThemeManager.
            
            if nargin < 2
                figureHandle = obj.ManagedFigure;
            end
            
            if isempty(figureHandle) || ~isvalid(figureHandle)
                return;
            end
            
            % Get current theme object
            themeObj = obj.ThemeObject;
            
            if isempty(themeObj)
                return;
            end
            
            % Apply to all components
            uiComponents = findall(figureHandle);
            
            if isempty(uiComponents)
                return;
            end
            
            componentTypes = arrayfun(@(h) class(h), uiComponents, 'UniformOutput', false);
            [uniqueTypes, ~, iC] = unique(componentTypes);
            
            for i = 1:numel(uniqueTypes)
                componentHandles = uiComponents(iC == i);
                try
                    themeObj.styleComponent(componentHandles);
                catch
                    % Some components might not have style support
                end
            end
        end
        
        function onThemeChangedInternal(obj, src, event)
            %onThemeChangedInternal Internal callback for theme changes
            
            % Call user-defined callback if set
            if ~isempty(obj.CustomThemeChangedCallback)
                try
                    obj.CustomThemeChangedCallback(src, event);
                catch ME
                    warning('HasTheme:CallbackError', ...
                        'Error in custom theme changed callback: %s', ME.message);
                end
            end
            
            % Call subclass hook if it exists
            if ismethod(obj, 'onThemeChanged')
                try
                    obj.onThemeChanged(src, event);
                catch ME
                    warning('HasTheme:CallbackError', ...
                        'Error in onThemeChanged method: %s', ME.message);
                end
            end
        end
    end
end