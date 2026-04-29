function config = normalizeFieldConfig(rawConfig)
%NORMALIZEFIELDCONFIG Normalize legacy field customization metadata.

    config = struct( ...
        "Kind", "auto", ...
        "Hidden", false, ...
        "Choices", {{}}, ...
        "Action", [], ...
        "Args", {{}});

    if isempty(rawConfig)
        return
    end

    if iscell(rawConfig)
        config.Kind = "dropdown";
        config.Choices = rawConfig;
        return
    end

    if isa(rawConfig, "function_handle")
        config.Kind = "custom";
        config.Action = rawConfig;
        return
    end

    if ischar(rawConfig) || isstring(rawConfig)
        value = lower(string(rawConfig));
        switch value
            case {"ignore", "internal", "hidden"}
                config.Kind = "hidden";
                config.Hidden = true;

            case {"uigetdir", "uigetfile", "uiputfile"}
                config.Kind = "browse";
                config.Action = char(value);

            case "uisetcolor"
                config.Kind = "color";
                config.Action = char(value);

            otherwise
                config.Kind = "action";
                config.Action = rawConfig;
        end
        return
    end

    if isstruct(rawConfig) && isfield(rawConfig, "type")
        config.Kind = lower(string(rawConfig.type));
        if isfield(rawConfig, "args")
            config.Args = rawConfig.args;
        end
        if isfield(rawConfig, "choices")
            config.Choices = rawConfig.choices;
        end
        if isfield(rawConfig, "items")
            config.Choices = rawConfig.items;
        end
        if isfield(rawConfig, "callback")
            config.Action = rawConfig.callback;
        elseif isfield(rawConfig, "Callback")
            config.Action = rawConfig.Callback;
        end
    end
end
