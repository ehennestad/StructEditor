function editor = structeditor(data, options)
%STRUCTEDITOR Open the standalone StructEditor app.

    arguments
        data
        options.Title
        options.Name
        options.Description
        options.Prompt
        options.Theme
        options.LoadingHtmlSource
        options.EnableNestedStruct
        options.Width
        options.Height
        options.CustomFigureSize
        options.LabelPosition
        options.OkButtonText
        options.CancelButtonText
        options.CloseOnExit
        options.ValueChangedFcn
        options.Callback
        options.Plugin
        options.Plugins
        options.ReferencePosition
        options.DataTips
        options.TabMode
        options.AdjustFigureSize
    end

    if isfield(options, "Prompt") && ~isfield(options, "Description")
        options.Description = options.Prompt;
    end
    if isfield(options, "Prompt")
        options = rmfield(options, "Prompt");
    end

    if isfield(options, "CustomFigureSize")
        figureSize = options.CustomFigureSize;
        options = rmfield(options, "CustomFigureSize");

        if isnumeric(figureSize) && numel(figureSize) == 2
            options.Width = figureSize(1);
            options.Height = figureSize(2);
        else
            error("structeditor:InvalidCustomFigureSize", ...
                "CustomFigureSize must be a two-element numeric vector [width height].")
        end
    end

    nvPairs = namedargs2cell(options);
    editor = structeditor.StructEditorApp(data, nvPairs{:});
end
