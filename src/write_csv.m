function write_csv(path, header, values)
% WRITE_CSV Write finite numeric data with an explicit SI-unit header.
% Inputs: path and header (char), values (numeric matrix). Output: CSV.
% Reference: infrastructure helper; no physical equation.
    assert(isnumeric(values) && all(isfinite(values(:))), 'CSV values must be finite.');
    parent = fileparts(path);
    if ~exist(parent, 'dir'), mkdir(parent); end
    file = fopen(path, 'w');
    assert(file >= 0, 'Cannot open CSV output.');
    cleanup = onCleanup(@() fclose(file));
    fprintf(file, '%s\n', header);
    format = [repmat('%.16g,', 1, size(values, 2)-1), '%.16g\n'];
    fprintf(file, format, values.');
end
