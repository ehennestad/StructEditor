classdef StructEditorEmployeeTest < matlab.uitest.TestCase
    % StructEditorEmployeeTest - Unit tests for StructEditorApp with employee data
    %
    % Tests the basic functionality of editing employee information using
    % the StructEditorApp with various data types including uint8, int64,
    % categorical, datetime, and logical fields.
    
    properties
        App structeditor.StructEditorApp
        OriginalData struct
    end
    
    methods (TestMethodSetup)
        function createApp(testCase)
            % Create the employee data structure
            employee = struct();
            employee.Name = 'John Doe';
            employee.Age = uint8(30);
            employee.Email = 'john.doe@example.com';
            employee.IsActive = true;
            employee.Department = categorical({'Engineering'}, ...
                {'Engineering', 'Sales', 'Marketing', 'HR'});
            employee.StartDate = datetime('2020-01-15');
            employee.Salary = int64(75000);
            
            testCase.OriginalData = employee;
            
            % Create the app
            testCase.App = structeditor.StructEditorApp(employee, ...
                "Title", "Employee Info", ...
                "Description", "Edit employee details:", ...
                "Height", 480, ...
                "CloseOnExit", false);
            
            % Wait for the app to be ready
            testCase.addTeardown(@()delete(testCase.App));
            drawnow;
        end
    end
    
    methods (Test)
        function testAppCreation(testCase)
            % Verify that the app was created successfully
            testCase.verifyTrue(testCase.App.hasFigure(), ...
                'App figure should be created');
            testCase.verifyEqual(testCase.App.Title, "Employee Info");
            testCase.verifyEqual(testCase.App.Description, "Edit employee details:");
        end
        
        function testInitialDataValues(testCase)
            % Verify that initial data is correctly loaded
            testCase.verifyEqual(testCase.App.Data.Name, 'John Doe');
            testCase.verifyEqual(testCase.App.Data.Age, uint8(30));
            testCase.verifyEqual(testCase.App.Data.Email, 'john.doe@example.com');
            testCase.verifyTrue(testCase.App.Data.IsActive);
            testCase.verifyEqual(char(testCase.App.Data.Department), 'Engineering');
            testCase.verifyEqual(testCase.App.Data.StartDate, datetime('2020-01-15'));
            testCase.verifyEqual(testCase.App.Data.Salary, int64(75000));
        end
        
        function testEditNameField(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Get the Name edit field
            nameField = controlContainer.UIControls.('Name');
            
            % Change the name
            testCase.type(nameField, 'Jane Smith');
            
            % Verify the change in the container's data
            testCase.verifyEqual(controlContainer.Data.Name, 'Jane Smith');
        end
        
        function testEditAgeField(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Get the Age numeric field
            ageField = controlContainer.UIControls.('Age');
            
            % Change the age
            testCase.type(ageField, 35);
            
            % Verify the change in the container's data
            testCase.verifyEqual(controlContainer.Data.Age, uint8(35));
        end
        
        function testEditEmailField(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Get the Email edit field
            emailField = controlContainer.UIControls.('Email');
            
            % Change the email
            testCase.type(emailField, 'jane.smith@example.com');
            
            % Verify the change in the container's data
            testCase.verifyEqual(controlContainer.Data.Email, 'jane.smith@example.com');
        end
        
        function testToggleIsActiveField(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Get the IsActive checkbox
            isActiveField = controlContainer.UIControls.('IsActive');
            
            % Toggle the checkbox
            testCase.press(isActiveField);
            
            % Verify the change in the container's data
            testCase.verifyFalse(controlContainer.Data.IsActive);
            
            % Toggle back
            testCase.press(isActiveField);
            testCase.verifyTrue(controlContainer.Data.IsActive);
        end
        
        function testChangeDepartmentField(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Get the Department dropdown
            departmentField = controlContainer.UIControls.('Department');
            
            % Change the department
            testCase.choose(departmentField, 'Sales');
            
            % Verify the change in the container's data
            testCase.verifyEqual(char(controlContainer.Data.Department), 'Sales');
        end
        
        function testEditSalaryField(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Get the Salary numeric field
            salaryField = controlContainer.UIControls.('Salary');
            
            % Change the salary
            testCase.type(salaryField, 85000);
            
            % Verify the change in the container's data
            testCase.verifyEqual(controlContainer.Data.Salary, int64(85000));
        end
        
        function testOkButtonUpdatesData(testCase)
            % Get the control container and footer
            controlContainer = testCase.App.getComponent('UIControlContainers');
            footer = testCase.App.getComponent('Footer');
            
            % Make some changes
            nameField = controlContainer.UIControls.('Name');
            testCase.type(nameField, 'Jane Smith');
            
            ageField = controlContainer.UIControls.('Age');
            testCase.type(ageField, 35);
            
            % Get the OK button and press it
            okButton = footer.getControl('OkButton');
            testCase.press(okButton);
            
            % Wait for data to be updated
            drawnow; pause(0.1);
            
            % Verify that app data was updated
            testCase.verifyEqual(testCase.App.Data.Name, 'Jane Smith');
            testCase.verifyEqual(testCase.App.Data.Age, uint8(35));
            
            % Verify finish state
            testCase.verifyEqual(testCase.App.FinishState, "Finished");
        end
        
        function testCancelButtonDoesNotUpdateData(testCase)
            % Get the control container and footer
            controlContainer = testCase.App.getComponent('UIControlContainers');
            footer = testCase.App.getComponent('Footer');
            
            % Store original name
            originalName = testCase.App.Data.Name;
            
            % Make a change
            nameField = controlContainer.UIControls.('Name');
            testCase.type(nameField, 'Jane Smith');
            
            % Verify container data changed
            testCase.verifyEqual(controlContainer.Data.Name, 'Jane Smith');
            
            % Get the Cancel button and press it
            cancelButton = footer.getControl('CancelButton');
            testCase.press(cancelButton);
            
            % Wait for processing
            drawnow; pause(0.1);
            
            % Verify that app data was NOT updated (should still be original)
            testCase.verifyEqual(testCase.App.Data.Name, originalName);
            
            % Verify finish state
            testCase.verifyEqual(testCase.App.FinishState, "Canceled");
        end
        
        function testResetFunctionality(testCase)
            % Get the control container
            controlContainer = testCase.App.getComponent('UIControlContainers');
            
            % Make some changes
            nameField = controlContainer.UIControls.('Name');
            testCase.type(nameField, 'Jane Smith');
            
            ageField = controlContainer.UIControls.('Age');
            testCase.type(ageField, 35);
            
            % Reset the app
            testCase.App.reset();
            
            % Verify data is reset to original values
            testCase.verifyEqual(controlContainer.Data.Name, '');
            testCase.verifyEqual(controlContainer.Data.Age, []);
            
            % Verify finish state is cleared
            testCase.verifyEqual(testCase.App.FinishState, "");
        end
        
        function testMultipleFieldEdits(testCase)
            % Get the control container and footer
            controlContainer = testCase.App.getComponent('UIControlContainers');
            footer = testCase.App.getComponent('Footer');
            
            % Edit multiple fields
            testCase.type(controlContainer.UIControls.('Name'), 'Alice Johnson');
            testCase.type(controlContainer.UIControls.('Age'), 42);
            testCase.type(controlContainer.UIControls.('Email'), 'alice.j@company.com');
            testCase.press(controlContainer.UIControls.('IsActive'));  % Toggle to false
            testCase.choose(controlContainer.UIControls.('Department'), 'Marketing');
            testCase.type(controlContainer.UIControls.('StartDate'), datetime(2022,04,05));
            testCase.type(controlContainer.UIControls.('Salary'), 92000);
            
            % Press OK button
            testCase.press(footer.getControl('OkButton'));
            drawnow; pause(0.1);
            
            % Verify all changes were applied
            testCase.verifyEqual(testCase.App.Data.Name, 'Alice Johnson');
            testCase.verifyEqual(testCase.App.Data.Age, uint8(42));
            testCase.verifyEqual(testCase.App.Data.Email, 'alice.j@company.com');
            testCase.verifyFalse(testCase.App.Data.IsActive);
            testCase.verifyEqual(char(testCase.App.Data.Department), 'Marketing');
            testCase.verifyEqual(testCase.App.Data.Salary, int64(92000));
        end
        
        function testDataTypesPreserved(testCase)
            % Verify that data types are preserved after editing
            controlContainer = testCase.App.getComponent('UIControlContainers');
            footer = testCase.App.getComponent('Footer');
            
            % Make changes
            testCase.type(controlContainer.UIControls.('Age'), 50);
            testCase.type(controlContainer.UIControls.('Salary'), 100000);
            
            % Press OK
            testCase.press(footer.getControl('OkButton'));
            drawnow; pause(0.1);
            
            % Verify data types are preserved
            testCase.verifyClass(testCase.App.Data.Age, 'uint8');
            testCase.verifyClass(testCase.App.Data.Salary, 'int64');
            testCase.verifyClass(testCase.App.Data.Department, 'categorical');
            testCase.verifyClass(testCase.App.Data.StartDate, 'datetime');
            testCase.verifyClass(testCase.App.Data.IsActive, 'logical');
        end
    end
end
