classdef FinishButtonsTest < matlab.uitest.TestCase
    % Test class for FinishButtons component using App Testing Framework
    
    properties
        App
        Component
        OkButton
        CancelButton
    end
    
    methods (TestMethodSetup)
        function launchApp(testCase)
            % Create a UI figure for testing (must use uifigure for uitest)
            testCase.App = uifigure('Visible', 'on');
            % Create the component under test
            testCase.Component = structeditor.component.FinishButtons('Parent', testCase.App);
            testCase.OkButton = testCase.Component.getControl('OkButton');
            testCase.CancelButton = testCase.Component.getControl('CancelButton');
        end
    end
    
    methods (TestMethodTeardown)
        function closeApp(testCase)
            % Clean up
            delete(testCase.App);
        end
    end
    
    methods (Test)
        %% Property Tests
        function testDefaultPropertyValues(testCase)
            % Verify default property values
            testCase.verifyEqual(testCase.Component.OkButtonText, "OK");
            testCase.verifyEqual(testCase.Component.CancelButtonText, "Cancel");
            testCase.verifyEqual(testCase.Component.OkButtonType, ...
                structeditor.enum.ButtonType.DefaultButton);
            testCase.verifyEqual(testCase.Component.CancelButtonType, ...
                structeditor.enum.ButtonType.DefaultButton);
        end
        
        function testSetButtonText(testCase)
            % Test changing button text
            testCase.Component.OkButtonText = "Confirm";
            testCase.verifyEqual(testCase.OkButton.Text, 'Confirm');
            
            testCase.Component.CancelButtonText = "Abort";
            testCase.verifyEqual(testCase.CancelButton.Text, 'Abort');
        end
        
        function testSetButtonIcons(testCase)
            % Test setting button icons
            testCase.Component.OkButtonIcon = "success";
            testCase.verifyEqual(testCase.OkButton.Icon,  'success');
            
            testCase.Component.CancelButtonIcon = "error";
            testCase.verifyEqual(testCase.CancelButton.Icon, 'error');
        end
        
        function testSetButtonTypes(testCase)
            % Test changing button types
            testCase.Component.OkButtonType = ...
                structeditor.enum.ButtonType.PrimaryButton;
            testCase.verifyEqual(testCase.Component.OkButtonType, ...
                structeditor.enum.ButtonType.PrimaryButton);
            
            testCase.Component.CancelButtonType = ...
                structeditor.enum.ButtonType.PrimaryButton;
            testCase.verifyEqual(testCase.Component.CancelButtonType, ...
                structeditor.enum.ButtonType.PrimaryButton);
        end
        
        function testSetTheme(testCase)
            % Test changing theme
            testCase.Component.Theme = structeditor.enum.Theme.Dark;
            testCase.verifyEqual(testCase.Component.Theme, ...
                structeditor.enum.Theme.Dark);
        end
        
        %% Interactive Button Press Tests
        function testPressOkButton(testCase)
            % Test pressing OK button using app testing framework
            callbackExecuted = false;
            finishState = '';
            
            % Set up callback
            testCase.Component.FinishButtonPushedFcn = ...
                @(src, evt) captureCallback(src, evt);
            
            % Press the OK button using app testing framework
            testCase.press(testCase.OkButton);
            
            % Verify callback was executed with correct state
            testCase.verifyTrue(callbackExecuted, ...
                'OK button callback was not executed');
            testCase.verifyEqual(finishState, 'Finished', ...
                'Finish state should be "Finished"');
            
            function captureCallback(~, eventData)
                callbackExecuted = true;
                finishState = eventData.FinishState;
            end
        end
        
        function testPressCancelButton(testCase)
            % Test pressing Cancel button using app testing framework
            callbackExecuted = false;
            finishState = '';
            
            % Set up callback
            testCase.Component.FinishButtonPushedFcn = ...
                @(src, evt) captureCallback(src, evt);
            
            % Press the Cancel button using app testing framework
            testCase.press(testCase.CancelButton);
            
            % Verify callback was executed with correct state
            testCase.verifyTrue(callbackExecuted, ...
                'Cancel button callback was not executed');
            testCase.verifyEqual(finishState, 'Canceled', ...
                'Finish state should be "Canceled"');
            
            function captureCallback(~, eventData)
                callbackExecuted = true;
                finishState = eventData.FinishState;
            end
        end
        
        function testMultipleButtonPresses(testCase)
            % Test multiple button presses
            pressCount = 0;
            lastState = '';
            
            testCase.Component.FinishButtonPushedFcn = ...
                @(~, evt) countPresses(evt);
            
            % Press OK button
            testCase.press(testCase.OkButton);
            testCase.verifyEqual(pressCount, 1);
            testCase.verifyEqual(lastState, 'Finished');
            
            % Press Cancel button
            testCase.press(testCase.CancelButton);
            testCase.verifyEqual(pressCount, 2);
            testCase.verifyEqual(lastState, 'Canceled');
            
            % Press OK button again
            testCase.press(testCase.OkButton);
            testCase.verifyEqual(pressCount, 3);
            testCase.verifyEqual(lastState, 'Finished');
            
            function countPresses(eventData)
                pressCount = pressCount + 1;
                lastState = eventData.FinishState;
            end
        end
        
        function testNoCallbackAssigned(testCase)
            % Test that pressing buttons without callback doesn't error
            testCase.Component.FinishButtonPushedFcn = [];
            
            testCase.verifyWarningFree(...
                @() testCase.press(testCase.OkButton));
            testCase.verifyWarningFree(...
                @() testCase.press(testCase.CancelButton));
        end
        
        %% Component Structure Tests
        function testComponentCreated(testCase)
            % Verify component was created
            testCase.verifyClass(testCase.Component, ...
                'structeditor.component.FinishButtons');
        end
        
        function testButtonsExist(testCase)
            % Verify buttons were created
            testCase.verifyNotEmpty(testCase.OkButton);
            testCase.verifyNotEmpty(testCase.CancelButton);
        end

        %% Visual/Style Tests
        function testThemeAffectsBackgroundColor(testCase)
            % Verify theme changes affect visual appearance
            testCase.Component.Theme = structeditor.enum.Theme.Light;
            lightBgColor = testCase.Component.BackgroundColor;
            
            testCase.Component.Theme = structeditor.enum.Theme.Dark;
            darkBgColor = testCase.Component.BackgroundColor;
            
            testCase.verifyNotEqual(lightBgColor, darkBgColor, ...
                'Theme change should affect background color');
        end
        
        function testButtonStyleChanges(testCase)
            % Test that button style changes with button type
            testCase.Component.OkButtonType = ...
                structeditor.enum.ButtonType.DefaultButton;
            pause(0.1); % Allow UI to update
            
            defaultColor = testCase.OkButton.BackgroundColor;
            
            testCase.Component.OkButtonType = ...
                structeditor.enum.ButtonType.PrimaryButton;
            pause(0.1); % Allow UI to update
            primaryColor = testCase.OkButton.BackgroundColor;
            
            testCase.verifyNotEqual(defaultColor, primaryColor, ...
                'Button type should affect background color');
        end
    end
end
