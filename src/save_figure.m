function save_figure(handle, path)
% SAVE_FIGURE Write a headless MATLAB/Octave-compatible PNG artifact.
% Inputs: graphics handle, output path (char). Output: PNG on disk.
% Reference: plotting helper; no physical equation.
    parent = fileparts(path);
    if ~exist(parent, 'dir'), mkdir(parent); end
    set(handle, 'paperpositionmode', 'auto');
    print(handle, path, '-dpng', '-r150');
    close(handle);
end
