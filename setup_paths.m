function root = setup_paths()
% SETUP_PATHS Add repository modules independent of current directory.
% Input: none. Output: root, absolute repository path (char).
% Reference: infrastructure helper; no physical equation.
    root = fileparts(mfilename('fullpath'));
    addpath(fullfile(root, 'src'));
    addpath(fullfile(root, 'tests'));
    addpath(fullfile(root, '01_terzaghi_consolidation'));
    addpath(fullfile(root, '02_fracture_aperture_cubic_law'));
    addpath(fullfile(root, '03_radial_injection_theis'));
    addpath(fullfile(root, 'codebright_run'));
end
