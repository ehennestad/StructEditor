function writestruct(S, filePath)

    if isMATLABReleaseOlderThan('R2023b') && endsWith(filePath, '.json')
        fid = fopen(filePath, 'w');
        fwrite(fid, jsonencode(S, 'PrettyPrint', true) );
        fclose(fid);
    else
        writestruct(S, filePath);
    end
end