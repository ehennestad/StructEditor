employee = struct();
employee.Name = 'John Doe';
employee.Age = uint8(30);
employee.Email = 'john.doe@example.com';
employee.IsActive = true;
employee.Department = categorical({'Engineering'}, {'Engineering', 'Sales', 'Marketing', 'HR'});
employee.StartDate = datetime('2020-01-15');
employee.Salary = int64(75000);

updatedEmployee = uiform(employee, ...
    "Title", "Employee Info", ...
    "Description", "Edit employee details:", ...
    "Height", 480);
