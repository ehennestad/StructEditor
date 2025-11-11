# StructEditor
A MATLAB app for interactively editing structure data in a dialog-style window. The app will build uicontrols based on the data types of the struct fields and supports custom uicontrols via an optional configuration field.

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/05566c97-9c79-4eb8-96fa-9e970ac10c4e">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/ea31a3c6-ff66-4580-a96d-4a0c8a650795">
    <img alt="uiform example" src="https://github.com/user-attachments/assets/ea31a3c6-ff66-4580-a96d-4a0c8a650795" title="uiform" align="centre" width="672" height="440"​>
  </picture>
  <br>
  <em>Figure: Screenshot showing the result of running <code>uiform(struct("givenName", "Joe", "familyName", "Doe"))</code>.</em>
</p>

___

## Installation and Requirements
**Option 1**: Install via MATLAB's Add-On Manager.

**Option 2**: Clone this repository and add the `code` directory to MATLAB's search path

## Examples

### Example 1: Edit a basic structure
Todo: 

### Example 2: Use custom field configuration
Todo: 

### Example 3: Use external custom components
Todo: 

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
