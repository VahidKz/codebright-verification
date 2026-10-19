function values = read_numeric_csv(path, expected_header)
% READ_NUMERIC_CSV Validate an explicit user-export schema before reading numeric rows.
% Inputs: path/header (char). Output: finite numeric matrix in header SI units.
% Reference: repository export contract; not a CODE_BRIGHT native file format.
    file = fopen(path,'r'); assert(file >= 0,'Cannot open exported CSV.');
    header = fgetl(file); fclose(file);
    assert(ischar(header) && strcmp(strtrim(header),expected_header),'Unexpected CSV header or units.');
    values = dlmread(path,',',1,0);
    columns = 1+sum(expected_header == ',');
    assert(~isempty(values) && size(values,2) == columns && all(isfinite(values(:))), ...
        'Expected finite numeric export rows.');
end
