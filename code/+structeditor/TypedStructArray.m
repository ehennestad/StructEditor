classdef TypedStructArray < handle

    % Inspired by a categorial, this data type holds a list of structs,
    % where the struct is part of a set with prefdefined types/categories.

    properties
        StructData (1,:) cell
    end

    properties (Dependent)
        TypeNames (1,:) string 
    end

    properties (SetAccess = immutable)
        StructTypes (1,:) structeditor.TypedStruct
    end

    methods % Constructor
        function obj = TypedStructArray(structData, types, typeNames)
            arguments
                structData (1,:) cell
                types
                typeNames (1,:) string = missing
            end
            
            obj.StructData = structData;

            if isa(types, 'structeditor.TypedStruct')
                obj.StructTypes = types;
            else
                % Assume cell array of structs.
                for i = 1:numel(types)
                    obj.StructTypes(i) = structeditor.TypedStruct("Data", types{i}, "Type", typeNames(i) );
                end
            end
        end
    end

    methods 
        function s = getType(obj, typeName)
            isMatch = strcmp(obj.TypeNames, typeName);
            s = obj.StructTypes(isMatch).Data;
        end
    end

    methods
        function names = get.TypeNames(obj)
            names = [obj.StructTypes.Type];
        end
    end
end