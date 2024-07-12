classdef TypedStruct < handle & matlab.mixin.SetGet

    properties (SetAccess = private)
        Type (1,1) string % Type name
        Data (1,1) struct % Example struct with fields
    end

    methods
        function obj = TypedStruct(propValues)
            arguments
                propValues.Type (1,1) string % Type name
                propValues.Data (1,1) struct % Example struct with fields
            end

            obj.set(propValues)
        end
    end

    methods 
        function tf = isSameType(obj, testStruct)
            tf = false;
            fieldsA = fieldnames(obj.Data);
            fieldsB = fieldnames(testStruct);

            if numel(fieldsA) == numel(fieldsB)
                tf = isempty( setdiff(fieldsA, fieldsB) );
            end
        end
    end
end
