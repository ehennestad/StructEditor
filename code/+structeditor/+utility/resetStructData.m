function S = resetStructData(S)

    fieldNames = string( fieldnames(S) )';

    for iFieldName = fieldNames
        
        iValue = S.(iFieldName);

        if isnumeric(iValue)
            S.(iFieldName) = 0;

        elseif isstring(iValue)
            S.(iFieldName) = "";

        elseif ischar(iValue)
            S.(iFieldName) = '';

        
        elseif iscategorical(iValue)
            C = categories(iValue);
            S.(iFieldName) = categorical(C(1),C');

        elseif isa(iValue, 'function_handle')
            continue

        else
            warning('No routines for reseting value of type %s', class(iValue))

        end
    end
end