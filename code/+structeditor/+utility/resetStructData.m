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

        elseif isdatetime(iValue)
            S.(iFieldName) = datetime.empty(1,0);

        elseif isa(iValue, 'function_handle')
            continue

        else
            try
                S.(iFieldName) = feval(sprintf("%s.empty", class(iValue)) );
            catch
                warning('No routines for reseting value of type %s', class(iValue))
            end
        end
    end
end