function handle = new_figure()
% NEW_FIGURE Invisible, consistent scientific figure for both runtimes.
% Input: none. Output: figure handle. Reference: infrastructure only.
    handle = figure('visible', 'off', 'color', 'w', 'position', [80 80 1000 680]);
    set(0, 'defaultaxesfontsize', 11, 'defaultlinelinewidth', 1.5);
end
