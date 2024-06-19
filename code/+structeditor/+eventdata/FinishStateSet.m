classdef (ConstructOnLoad) FinishStateSet < event.EventData
    
    properties
        FinishState
    end
    
    methods
        function data = FinishStateSet(finishState)
            data.FinishState = finishState;
        end
    end
end