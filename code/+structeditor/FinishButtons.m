classdef FinishButtons < matlab.ui.componentcontainer.ComponentContainer

    % Properties that correspond to underlying components
    properties (Access = private, Transient, NonCopyable)
        GridLayout    matlab.ui.container.GridLayout
        CancelButton  %matlab.ui.control.Button
        OkButton      %matlab.ui.control.Button
    end

    % % % Events with associated public callbacks
    % % events (HasCallbackProperty, NotifyAccess = private)
    % %     FinishButtonPushed
    % % end

    properties (Access = public)
        CancelButtonIcon string
        CancelButtonText (1,1) string = "Cancel";
        CancelButtonType (1,1) structeditor.enum.ButtonType = 'DefaultButton';
        OkButtonIcon string
        OkButtonText (1,1) string = "OK";
        OkButtonType (1,1) structeditor.enum.ButtonType = "DefaultButton";
        Theme (1,1) structeditor.enum.Theme = "Light";
        FinishButtonPushedFcn
    end
    
    methods
        function set.Theme(comp, value)
            comp.Theme = value;
            comp.postSetTheme()
        end

        function set.CancelButtonType(comp, value)
            comp.CancelButtonType = value;
            comp.postSetCancelButtonType()
        end

        function set.OkButtonType(comp, value)
            comp.OkButtonType = value;
            comp.postSetOkButtonType()
        end

        function set.CancelButtonText(comp, value)
            comp.CancelButtonText = value;
            comp.postSetCancelButtonText()
        end
        
        function set.OkButtonText(comp, value)
            comp.OkButtonText = value;
            comp.postSetOkButtonText()
        end
    end
    
    methods (Access = private)
        function postSetCancelButtonText(comp)
            comp.CancelButton.Text = comp.CancelButtonText;
        end
        
        function postSetOkButtonText(comp)
            comp.OkButton.Text = comp.OkButtonText;
        end

        function postSetTheme(comp)
            comp.BackgroundColor = comp.Theme.PanelStyle.BackgroundColor;
            comp.GridLayout.BackgroundColor = comp.Theme.GridLayoutStyle.BackgroundColor;

            comp.updateButtonStyle(comp.CancelButton, comp.CancelButtonType)
            comp.updateButtonStyle(comp.OkButton, comp.OkButtonType)
        end

        function postSetCancelButtonType(comp)
            comp.updateButtonStyle(comp.CancelButton, comp.CancelButtonType)
        end

        function postSetOkButtonType(comp)
            comp.updateButtonStyle(comp.OkButton, comp.OkButtonType)
        end
    end

    methods (Access = private)
        function updateButtonStyle(comp, buttonHandle, buttonType)
            switch buttonType
                case "DefaultButton"
                    foregroundColor = comp.Theme.DefaultButtonStyle.FontColor;
                    backgroundColor = comp.Theme.DefaultButtonStyle.BackgroundColor;
                case "PrimaryButton"
                    foregroundColor = comp.Theme.PrimaryButtonStyle.FontColor;
                    backgroundColor = comp.Theme.PrimaryButtonStyle.BackgroundColor;
            end

            if isa( buttonHandle, 'ccTools.Button' )
                buttonHandle.tFontColor = uim.utility.rgb2hex(foregroundColor);
            else
                buttonHandle.FontColor = foregroundColor;
            end
            buttonHandle.BackgroundColor = backgroundColor;
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: CancelButton
        function CancelButtonPushed(comp, src, event)
            finishState = 'Canceled';
            eventData = structeditor.eventdata.FinishStateSet(finishState);

            if ~isempty(comp.FinishButtonPushedFcn)
                comp.FinishButtonPushedFcn(comp, eventData)
            end
        end

        % Button pushed function: OkButton
        function OkButtonPushed(comp, src, event)
            finishState = 'Finished';
            eventData = structeditor.eventdata.FinishStateSet(finishState);

            if ~isempty(comp.FinishButtonPushedFcn)
                comp.FinishButtonPushedFcn(comp, eventData)
            end
        end
    end

    methods (Access = protected)
        
        % Code that executes when the value of a public property is changed
        function update(comp)
            % Use this function to update the underlying components

        end

        % Create the underlying components
        function setup(comp)

            comp.Position = [1 1 471 56];
            comp.BackgroundColor = [0.94 0.94 0.94];

            % Create GridLayout
            comp.GridLayout = uigridlayout(comp);
            comp.GridLayout.RowHeight = {'1x', 25, '1x'};
            comp.GridLayout.ColumnSpacing = 30;
            comp.GridLayout.RowSpacing = 0;

            useCcTools = false;
            if ~useCcTools
                % Create OkButton
                comp.OkButton = uibutton(comp.GridLayout, 'push');
                comp.OkButton.ButtonPushedFcn = @comp.OkButtonPushed;
                comp.OkButton.Layout.Row = 2;
                comp.OkButton.Layout.Column = 1;
                comp.OkButton.Text = 'OK';
    
                % Create CancelButton
                comp.CancelButton = uibutton(comp.GridLayout, 'push');
                comp.CancelButton.ButtonPushedFcn = @comp.CancelButtonPushed;
                comp.CancelButton.Layout.Row = 2;
                comp.CancelButton.Layout.Column = 2;
                comp.CancelButton.Text = 'Cancel';

            else

                comp.OkButton = ccTools.Button(comp.GridLayout);
                comp.OkButton.Text = 'OK';
                comp.OkButton.Model = 'Text';
                comp.OkButton.Description = '';
                comp.OkButton.IconAlignment = 'left';
                comp.OkButton.HorizontalAlign = 'center';
                comp.OkButton.BorderWidth = 1;
                comp.OkButton.BorderRadius = '5px';
                comp.OkButton.BorderPadding = 0;
                %comp.OkButton.FontFamily = 'Gigi';
                comp.OkButton.ButtonPushedFcn = @comp.OkButtonPushed;
                comp.OkButton.Layout.Row = 2;
                comp.OkButton.Layout.Column = 1;
    
                comp.CancelButton = ccTools.Button(comp.GridLayout);
                comp.CancelButton.Text = 'Cancel';
                comp.CancelButton.Model = 'Text';
                comp.CancelButton.Description = '';
                comp.CancelButton.HorizontalAlign = 'center';
                comp.CancelButton.BorderWidth = 1;
                comp.CancelButton.BorderRadius = '5px';
                comp.CancelButton.BorderPadding = 0;
                %comp.CancelButton.FontFamily = 'Gigi';
                comp.CancelButton.ButtonPushedFcn = @comp.CancelButtonPushed;
                comp.CancelButton.Layout.Row = 2;
                comp.CancelButton.Layout.Column = 2;
            end
        end
    end
end