function [fieldNames, hasConfigField] = popConfigFields(fieldNames)

    fieldNames = string(fieldNames);

    tentativeConfigFieldNames = fieldNames + '_';

    [~, iA] = intersect(fieldNames, tentativeConfigFieldNames, 'stable');

    configFieldNames = fieldNames(iA);
    fieldNames = setdiff(fieldNames, configFieldNames, 'stable');

    fieldWithConfigField = regexprep(configFieldNames, '_$', '');
    hasConfigField = ismember(fieldNames, fieldWithConfigField);
end