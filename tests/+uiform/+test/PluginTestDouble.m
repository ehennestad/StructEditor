classdef PluginTestDouble < handle

    properties
        Attached (1,1) logical = false
        DataChangedCount (1,1) double = 0
        FinishChangedCount (1,1) double = 0
        LastDataChangedEvent
        LastFinishState
        HeaderLabel
    end

    methods
        function attach(obj, editor)
            parent = editor.getAttachmentContainer("header");
            obj.HeaderLabel = uilabel(parent, "Text", "Plugin");
            obj.Attached = true;
        end

        function onDataChanged(obj, ~, evt)
            obj.DataChangedCount = obj.DataChangedCount + 1;
            obj.LastDataChangedEvent = evt;
        end

        function onFinishStateChanged(obj, ~, evt)
            obj.FinishChangedCount = obj.FinishChangedCount + 1;
            obj.LastFinishState = evt.FinishState;
        end
    end
end
