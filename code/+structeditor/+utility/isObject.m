function tf = isObject(value)

    if isstruct(value)
        tf = true;
    elseif isobject(value)
        if ishandle(value)
            tf = true;
        elseif isenum(value)
            tf = false;
        elseif isdatetime(value)
            tf = false;
        else
            if ~isempty(properties(value))
                tf = true;
            else
                tf = false;
            end
        end
    else
        tf = false;
    end
end