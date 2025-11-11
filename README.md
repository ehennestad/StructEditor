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

## Features

- **Automatic UI Generation**: Automatically creates appropriate UI controls based on field data types
- **Custom Components**: Use function handles to specify custom UI components with full control over properties
- **Configuration Fields**: Customize any field's UI component using the `fieldname_` pattern
- **Theme Support**: Built-in light and dark themes that adapt to your preferences
- **Multiple Data Types**: Native support for strings, numbers, logicals, categorical, datetime, and more
- **External Components**: Integrate custom components from MATLAB File Exchange or your own libraries

## Quick Start

```matlab
% Simple example - struct in, edited struct out
S = struct("name", "Jane", "age", 25, "active", true);
S = uiform(S);
```

## Installation and Requirements

**Requirements**: MATLAB R2020b or later

**Option 1**: Install via MATLAB's Add-On Manager.

**Option 2**: Clone this repository and add the `code` directory to MATLAB's search path:
```matlab
addpath('path/to/StructEditor/code');
savepath; % Optional: save path for future sessions
```

## Supported Data Types

The following MATLAB data types are automatically supported with appropriate UI controls:

| Data Type | UI Control | Example |
|-----------|------------|---------|
| `char` / `string` | Edit Field | `'John Doe'` |
| `double` / `single` | Numeric Edit Field | `42.5` |
| `int8` / `int16` / `int32` / `int64` | Numeric Edit Field | `int32(100)` |
| `uint8` / `uint16` / `uint32` / `uint64` | Numeric Edit Field | `uint8(255)` |
| `logical` | Checkbox | `true` |
| `categorical` | Dropdown | `categorical({'Option1'})` |
| `datetime` | Date Picker | `datetime('2020-01-15')` |

Use configuration fields (see Example 2) to override the default UI control for any data type.

## Usage

### Basic Syntax
```matlab
outputStruct = uiform(inputStruct)
outputStruct = uiform(inputStruct, Name, Value, ...)
```

### Name-Value Arguments

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `Title` | `string` | Window title | `'Edit Struct'` |
| `Description` | `string` | Descriptive text shown at the top | `''` |
| `Height` | `numeric` | Window height in pixels | `400` |
| `Theme` | `string` | Theme name (`'light'`, `'dark'`, etc.) | System default |

### Return Value
Returns the edited structure if the user clicks "OK", or the original structure if "Cancel" is clicked.

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
This example demonstrates how to customize UI components using configuration fields (field name + underscore) with function handles and name-value pairs.

```matlab
userProfile = struct();
userProfile.Username = 'johndoe';
userProfile.Username_ = @(parent) uieditfield(parent, 'text', ...
    'Placeholder', 'Enter username...');

userProfile.Bio = 'Tell us about yourself';
userProfile.Bio_ = @(parent) uitextarea(parent, ...
    'Placeholder', 'Write your bio here...');

userProfile.SkillLevel = 5;
userProfile.SkillLevel_ = @(parent) uislider(parent, ...
    'Limits', [1 10], ...
    'MajorTicks', 1:10, ...
    'MinorTicks', []);

userProfile.NotifyByEmail = true;
userProfile.NotifyBySMS = false;

updatedProfile = uiform(userProfile, ...
    "Title", "User Profile", ...
    "Description", "Customize your profile settings", ...
    "Height", 450);
```
<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/735a0706-4fb6-47f7-95f3-05f8c9e3317e">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/45a5ec6d-2d35-4e76-80c3-58ef8471ac50">
    <img alt="uiform example 2" src="https://github.com/user-attachments/assets/45a5ec6d-2d35-4e76-80c3-58ef8471ac50" title="uiform example 2" align="centre" width="672" height="590"​>
  </picture>
</p>

This example shows how configuration fields allow you to:

- Use function handles to specify custom UI components
- Pass name-value pairs to customize component properties
- Add interactive behaviors like placeholders

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
