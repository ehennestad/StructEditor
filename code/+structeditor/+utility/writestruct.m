function writestruct(S, filePath)
% writestruct - Writes a structure to a JSON file (compatibility version)
%
% Syntax:
%   structeditor.utility.writestruct(S, filePath) Writes the structure S to the
%   specified filePath in JSON format.
%
% Input Arguments:
%   S - The structure to be written to a JSON file.
%   filePath - The path to the file where the JSON will be saved.
%
% Output Arguments:
%   None

    arguments
        S struct
        filePath (1,1) string
    end

    if isMATLABReleaseOlderThan('R2023b') && endsWith(filePath, '.json')
        fid = fopen(filePath, 'w');
        fileCleanup = onCleanup(@() fclose(fid));
        fwrite(fid, jsonencode(S, 'PrettyPrint', true) );
    else
        writestruct(S, filePath);
    end
end
