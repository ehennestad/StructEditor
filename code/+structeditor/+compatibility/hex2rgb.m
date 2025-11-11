function rgb = hex2rgb(hex, range)
% hex2rgb - Compatibility wrapper for hex2rgb function
%
% Uses MATLAB's built-in hex2rgb if available (R2024a+), otherwise falls
% back to external implementation.

    % Check if MATLAB's built-in hex2rgb is available
    if exist('hex2rgb', 'file') == 2
        % Use MATLAB's built-in function
        if nargin == 1
            rgb = hex2rgb(hex);
        else
            % Built-in returns 0-1 range, scale if needed
            rgb = hex2rgb(hex);
            if range == 256 || range == 255
                rgb = rgb * 255;
            end
        end
    else
        % Fall back to external implementation
        if nargin == 1
            rgb = structeditor.external.fex.hex2rgb(hex);
        else
            rgb = structeditor.external.fex.hex2rgb(hex, range);
        end
    end
end
