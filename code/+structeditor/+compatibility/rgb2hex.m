function hex = rgb2hex(rgb)
% rgb2hex - Compatibility wrapper for rgb2hex function
%
% Uses MATLAB's built-in rgb2hex if available (R2024a+), otherwise falls
% back to external implementation.

    % Check if MATLAB's built-in rgb2hex is available
    if exist('rgb2hex', 'file') == 2
        % Use MATLAB's built-in function
        hex = rgb2hex(rgb);
    else
        % Fall back to external implementation
        hex = structeditor.external.fex.rgb2hex(rgb);
    end
end
