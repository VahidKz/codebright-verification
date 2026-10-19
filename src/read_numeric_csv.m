function values = read_numeric_csv(path, expected_header)
% READ_NUMERIC_CSV Validate an explicit user-export schema before reading numeric rows.
% Inputs: path/header (char). Output: finite numeric matrix in header SI units.
% Reference: repository export contract; not a CODE_BRIGHT native file format.
    file = fopen(path,'r'); assert(file >= 0,'Cannot open exported CSV.');
    cleanup = onCleanup(@() fclose(file));
    header = fgetl(file);
    assert(ischar(header) && strcmp(strtrim(header),expected_header),'Unexpected CSV header or units.');
    columns = 1+sum(expected_header == ',');
    values = zeros(0,columns);
    line = fgetl(file);
    while ischar(line)
        tokens = strsplit(strtrim(line),',','CollapseDelimiters',false);
        assert(numel(tokens) == columns,'Unexpected number of CSV columns.');
        row = cellfun(@str2double,tokens);
        assert(isreal(row) && all(isfinite(row)),'Expected finite real numeric export rows.');
        values(end+1,:) = row;
        line = fgetl(file);
    end
    assert(~isempty(values),'Expected at least one numeric export row.');
end
