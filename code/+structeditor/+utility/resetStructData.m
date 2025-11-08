function S = resetStructData(S)
    % resetStructData - Resets the data in a structure to default values
    %
    % Syntax:
    %   S = structeditor.utility.resetStructData(S) Resets all fields of the
    %   structure S to their default values based on their data types.
    %
    % Input Arguments:
    %   S - The input structure whose fields need to be reset.
    %
    % Output Arguments:
    %   S - The structure with all fields reset to their default values.

    arguments
        S (1,1) struct
    end

    fieldNames = string(fieldnames(S))';

    for iFieldName = fieldNames

        iValue = S.(iFieldName);

        if isnumeric(iValue)
            S.(iFieldName) = 0;

        elseif islogical(iValue)
            S.(iFieldName) = false;

        elseif isstring(iValue)
            S.(iFieldName) = "";

        elseif ischar(iValue)
            S.(iFieldName) = '';

        elseif iscategorical(iValue)
            C = categories(iValue);
            S.(iFieldName) = categorical(C(1), C');

        elseif isdatetime(iValue)
            S.(iFieldName) = datetime.empty(1, 0);

        elseif isa(iValue, 'function_handle')
            continue

        else
            try
                S.(iFieldName) = feval(sprintf("%s.empty", class(iValue)));
            catch
                warning('No routines for resetting value of type %s', class(iValue))
            end
        end
    end
end
