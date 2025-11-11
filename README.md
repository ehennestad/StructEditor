# StructEditor
A MATLAB app for interactively editing structure data in a dialog-style window. The app will build uicontrols based on the data types of the struct fields and supports custom uicontrols via an optional configuration field.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/97049414-44f8-4ad8-b5d4-ac027649a2a1">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/ea31a3c6-ff66-4580-a96d-4a0c8a650795">
    <img alt="uiform example" src="https://github.com/user-attachments/assets/ea31a3c6-ff66-4580-a96d-4a0c8a650795" title="uiform" align="centre" width="672" height="440"​>
  </picture>
  <br>
  <em>Figure: Screenshot showing the result of running:</em>
  <br>
  <code>uiform(struct("givenName", "Joe", "familyName", "Doe"))</code>
</p>

___

## Installation and Requirements
**Option 1**: Install via MATLAB's Add-On Manager.

**Option 2**: Clone this repository and add the `code` directory to MATLAB's search path

## Examples

### Example 1: Edit a basic structure
```matlab
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
```
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/364e840c-0a97-49c2-87cb-f5184be4da01">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/17b92420-4a62-4957-8e37-93e7d93c8076">
    <img alt="uiform example 1" src="https://github.com/user-attachments/assets/17b92420-4a62-4957-8e37-93e7d93c8076" title="uiform example 1" align="centre" width="672" height="620"​>
  </picture>
</p>

### Example 2: Use custom field configuration
Todo: 

### Example 3: Use external custom components
This example uses a custom component from FileExchange called [Rating](https://se.mathworks.com/matlabcentral/fileexchange/166231-rating-app-component).

```matlab
feedback = struct();
feedback.Rating = [];
feedback.Rating_ = @Rating;
feedback.Feedback = '';
feedback.Feedback_ = @uitextarea;

completedFeedback = uiform(feedback, ...
    "Title", "Feedback", ...
    "Description", "Please leave a rating and provide feedback", ...
    "Height", 300);
```

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/0e6764fb-3e2f-4389-b431-699f5deda624">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/bb661451-8220-4038-8374-ed692de238b5">
    <img alt="uiform example 3" src="https://github.com/user-attachments/assets/bb661451-8220-4038-8374-ed692de238b5" title="uiform example 3" align="centre" width="672" height="440"​>
  </picture>
</p>


## Related Projects
- https://github.com/ehennestad/WidgetTable
- https://github.com/ehennestad/openMINDS-MATLAB-GUI

## Contributing
- Have ideas for how to improve the **uiform**? Please create an issue.
- Want to help fix bugs or implement features? Create a fork and start a PR

## Future Ideas
- Edit class objects
- Edit nested structures / class objects
- Improved theme management
- Support live field validation
- Support field tooltips / descriptions 
