function [updatedData, wasAborted] = uiform(data, options)

    arguments
        data
        options.Title = "Edit Struct"
        options.OkButtonText = "Ok"
        options.Theme = ""
        options.Height
        options.Width
        options.Description
    end

    nvPairs = namedargs2cell(options);
    hForm = structeditor.StructEditorApp(data, ...
        nvPairs{:});
   
    hForm.OkButtonText = options.OkButtonText;

    uiwait(hForm, true)

    wasAborted = hForm.FinishState ~= "Finished";
    updatedData = hForm.Data;
    hForm.delete();
end
