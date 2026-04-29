classdef StructEditorContractTest < matlab.uitest.TestCase

    methods (Test)
        function testEntrypointReturnsStructEditorApp(testCase)
            data = struct("Name", "A", "Value", 1);
            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            testCase.verifyClass(app, "structeditor.StructEditorApp")
            testCase.verifyEqual(app.Data, data)
            testCase.verifyEqual(app.OriginalData, data)
        end

        function testPromptAndFigureSizeAliases(testCase)
            app = structeditor(struct("Value", 1), ...
                "Prompt", "Edit values", ...
                "CustomFigureSize", [640 480], ...
                "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            testCase.verifyEqual(app.Description, "Edit values")
            testCase.verifyEqual(app.Width, 640)
            testCase.verifyEqual(app.Height, 480)
        end

        function testLabelPositionAliases(testCase)
            appLeft = structeditor(struct("Value", 1), ...
                "LabelPosition", "Left", ...
                "CloseOnExit", false);
            testCase.addTeardown(@() delete(appLeft));

            appOver = structeditor(struct("Value", 1), ...
                "LabelPosition", "Over", ...
                "CloseOnExit", false);
            testCase.addTeardown(@() delete(appOver));

            testCase.verifyEqual(appLeft.LabelPosition, "left")
            testCase.verifyEqual(appOver.LabelPosition, "above")
        end

        function testWaitforAliasExists(testCase)
            app = structeditor(struct("Value", 1), "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            testCase.verifyTrue(any(strcmp(methods(app), "waitfor")))
        end

        function testOkPreservesOriginalData(testCase)
            data = struct("Name", "A", "Value", 1);
            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            controlContainer = app.getComponent("UIControlContainers");
            footer = app.getComponent("Footer");

            testCase.type(controlContainer.UIControls.Name, "B");
            testCase.press(footer.getControl("OkButton"));
            drawnow; pause(0.1)

            testCase.verifyEqual(app.FinishState, "Finished")
            testCase.verifyEqual(app.Data.Name, "B")
            testCase.verifyEqual(app.OriginalData, data)
            testCase.verifyFalse(app.wasCanceled)
            testCase.verifyEqual(app.dataEdit, app.Data)
            testCase.verifyEqual(app.dataOrig, app.OriginalData)
        end

        function testCancelLeavesDataAtOriginalData(testCase)
            data = struct("Name", "A", "Value", 1);
            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            controlContainer = app.getComponent("UIControlContainers");
            footer = app.getComponent("Footer");

            testCase.type(controlContainer.UIControls.Name, "B");
            testCase.press(footer.getControl("CancelButton"));
            drawnow; pause(0.1)

            testCase.verifyEqual(app.FinishState, "Canceled")
            testCase.verifyEqual(app.Data.Name, "B")
            testCase.verifyEqual(app.OriginalData, data)
            testCase.verifyTrue(app.wasCanceled)
        end

        function testReplaceDataSetsNewBaseline(testCase)
            app = structeditor(struct("Name", "A"), "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            updatedData = struct("Name", "B");
            app.replaceData(updatedData)

            testCase.verifyEqual(app.Data, updatedData)
            testCase.verifyEqual(app.OriginalData, updatedData)
        end

        function testCellArrayGroupSwitching(testCase)
            data = {struct("Value", 1), struct("Value", 2)};
            app = structeditor(data, "Name", {"A", "B"}, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            groupDropDown = app.getComponent("GroupDropDown");
            testCase.choose(groupDropDown, "B")

            controlContainer = app.getComponent("UIControlContainers");
            footer = app.getComponent("Footer");
            testCase.type(controlContainer.UIControls.Value, 42)
            testCase.press(footer.getControl("OkButton"));
            drawnow; pause(0.1)

            testCase.verifyEqual(app.Data{1}.Value, 1)
            testCase.verifyEqual(app.Data{2}.Value, 42)
        end

        function testStructOfStructsGroupSwitching(testCase)
            data = struct("A", struct("Value", 1), "B", struct("Value", 2));
            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            groupDropDown = app.getComponent("GroupDropDown");
            testCase.choose(groupDropDown, "B")

            controlContainer = app.getComponent("UIControlContainers");
            footer = app.getComponent("Footer");
            testCase.type(controlContainer.UIControls.Value, 42)
            testCase.press(footer.getControl("OkButton"));
            drawnow; pause(0.1)

            testCase.verifyEqual(app.Data.A.Value, 1)
            testCase.verifyEqual(app.Data.B.Value, 42)
        end

        function testDropdownAndHiddenConfig(testCase)
            data = struct( ...
                "Choice", "a", ...
                "Choice_", {{'a', 'b'}}, ...
                "Internal", "secret", ...
                "Internal_", "hidden");

            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            controlContainer = app.getComponent("UIControlContainers");
            testCase.verifyTrue(isfield(controlContainer.UIControls, "Choice"))
            testCase.verifyFalse(isfield(controlContainer.UIControls, "Internal"))
        end

        function testHiddenConfigAliases(testCase)
            configValues = ["ignore", "internal", "hidden"];

            for i = 1:numel(configValues)
                config = structeditor.config.normalizeFieldConfig(configValues(i));
                testCase.verifyTrue(config.Hidden)
                testCase.verifyEqual(config.Kind, "hidden")
            end
        end

        function testBrowseAndColorConfigCreateButtons(testCase)
            data = struct( ...
                "Folder", "/tmp", ...
                "Folder_", "uigetdir", ...
                "Color", [1 0 0], ...
                "Color_", "uisetcolor");

            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            controlContainer = app.getComponent("UIControlContainers");
            testCase.verifyTrue(isfield(controlContainer.UIControls, "Folder"))
            testCase.verifyTrue(isfield(controlContainer.UIControls, "Color"))
            testCase.verifyTrue(isfield(controlContainer.UIControlButtons, "Folder"))
            testCase.verifyTrue(isfield(controlContainer.UIControlButtons, "Color"))
        end

        function testStructConfigControls(testCase)
            data = struct( ...
                "Gain", 0.5, ...
                "Gain_", struct("type", "slider", "args", {{'Limits', [0 1]}}), ...
                "Run", false, ...
                "Run_", struct("type", "togglebutton"), ...
                "Notes", "line one", ...
                "Notes_", struct("type", "multilinechar"));

            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            controlContainer = app.getComponent("UIControlContainers");
            testCase.verifyClass(controlContainer.UIControls.Gain, "matlab.ui.control.Slider")
            testCase.verifyClass(controlContainer.UIControls.Run, "matlab.ui.control.StateButton")
            testCase.verifyClass(controlContainer.UIControls.Notes, "matlab.ui.control.TextArea")
        end

        function testVectorAndCellValueTypes(testCase)
            data = struct( ...
                "Vector", [1 2 3], ...
                "Integer", int32(4), ...
                "CellText", {{'a', 'b'}}, ...
                "CellNumbers", {{1, 2, 3}});

            app = structeditor(data, "CloseOnExit", false);
            testCase.addTeardown(@() delete(app));

            controlContainer = app.getComponent("UIControlContainers");
            footer = app.getComponent("Footer");

            testCase.type(controlContainer.UIControls.Vector, "[4 5 6]")
            testCase.type(controlContainer.UIControls.Integer, 8)
            testCase.type(controlContainer.UIControls.CellText, "c, d")
            testCase.type(controlContainer.UIControls.CellNumbers, "7 8 9")
            testCase.press(footer.getControl("OkButton"));
            drawnow; pause(0.1)

            testCase.verifyEqual(app.Data.Vector, [4 5 6])
            testCase.verifyEqual(app.Data.Integer, int32(8))
            testCase.verifyEqual(app.Data.CellText, {'c'; 'd'})
            testCase.verifyEqual(app.Data.CellNumbers, {7, 8, 9})
        end

        function testValueChangedEventFields(testCase)
            capturedEvent = [];
            data = {struct("Value", 1), struct("Value", 2)};
            app = structeditor(data, ...
                "Name", {"A", "B"}, ...
                "CloseOnExit", false, ...
                "ValueChangedFcn", @captureEvent);
            testCase.addTeardown(@() delete(app));

            groupDropDown = app.getComponent("GroupDropDown");
            testCase.choose(groupDropDown, "B")

            controlContainer = app.getComponent("UIControlContainers");
            testCase.type(controlContainer.UIControls.Value, 42)

            testCase.verifyEqual(capturedEvent.Name, "Value")
            testCase.verifyEqual(capturedEvent.OldValue, 2)
            testCase.verifyEqual(capturedEvent.NewValue, 42)
            testCase.verifyEqual(capturedEvent.GroupName, "B")
            testCase.verifyEqual(capturedEvent.GroupIndex, 2)
            testCase.verifyNotEmpty(capturedEvent.Control)

            function captureEvent(~, evt)
                capturedEvent = evt;
            end
        end

        function testPluginLifecycleHooks(testCase)
            plugin = uiform.test.PluginTestDouble();
            app = structeditor(struct("Value", 1), ...
                "CloseOnExit", false, ...
                "Plugin", plugin);
            testCase.addTeardown(@() delete(app));

            testCase.verifyTrue(plugin.Attached)
            testCase.verifyNotEmpty(plugin.HeaderLabel)

            controlContainer = app.getComponent("UIControlContainers");
            footer = app.getComponent("Footer");
            testCase.type(controlContainer.UIControls.Value, 2)

            testCase.verifyEqual(plugin.DataChangedCount, 1)
            testCase.verifyEqual(plugin.LastDataChangedEvent.Name, "Value")
            testCase.verifyEqual(app.Data.Value, 2)

            testCase.press(footer.getControl("OkButton"));
            drawnow; pause(0.1)

            testCase.verifyEqual(plugin.FinishChangedCount, 1)
            testCase.verifyEqual(string(plugin.LastFinishState), "Finished")
        end
    end
end
