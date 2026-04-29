classdef (ConstructOnLoad) ValueChanged < event.EventData
    
    properties
        Name
        OldValue
        NewValue
        GroupName
        GroupIndex
        PageNumber
        Control
        UIControls
    end
    
    methods
        function data = ValueChanged(Name, OldValue, NewValue, control, pageNumber, groupName, groupIndex)
            if nargin < 4;  control = []; end
            if nargin < 5;  pageNumber = 1; end
            if nargin < 6;  groupName = missing; end
            if nargin < 7;  groupIndex = 1; end

            data.Name = string(Name);
            data.OldValue = OldValue;
            data.NewValue = NewValue;
            data.Control = control;
            data.UIControls = control;
            data.PageNumber = pageNumber;
            data.GroupName = string(groupName);
            data.GroupIndex = groupIndex;
        end
    end
end
