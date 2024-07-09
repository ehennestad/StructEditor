classdef ListItemSelectedData < event.EventData
    properties
        OldIndex
        NewIndex
        Name
    end
    
    methods
        function data = ListItemSelectedData(oldIndex, newIndex, name)
            data.OldIndex = oldIndex;
            data.NewIndex = newIndex;
            data.Name = name;
        end
    end
end
