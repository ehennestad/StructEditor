function treeStruct = getTreeStruct(object)
% getTreeStruct - Get a structure representation of a nested object

    if ~isa(object, 'struct') && ~isobject(object)
        error('Unsupported type "%s"', class(object))
    end
    
    treeStruct = struct(...
            "name", "root", ...
        'fullName', "", ...
        "children", {{}} ...
        );

    treeStruct = addChildren(treeStruct, object, "");

    function treeStruct = addChildren(treeStruct, treeNode, fullNodeName)
        
        if isa(treeNode, 'struct')
            names = fieldnames(treeNode);
        elseif structeditor.utility.isObject(treeNode)
            names = properties(treeNode);
        else
            names = {};
        end

        for i = 1:numel(names)
            iName = names{i};
            iValue = treeNode.(iName);

            if structeditor.utility.isObject(iValue)
                newNode = struct(...
                        "name", iName, ...
                    'fullName', getFullName(iName, fullNodeName), ...
                    "children", {{}} ...
                    );
                newNode = addChildren(newNode, iValue, newNode.fullName);
                treeStruct.children{end+1} = newNode;
            else
                % pass
            end
        end
    end
end

function fullName = getFullName(shortName, parentName)
    if isempty(char(parentName))
        fullName = shortName;
    else
        fullName = sprintf("%s.%s", parentName, shortName);
    end
end