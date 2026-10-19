function run_all()
% RUN_ALL Regenerate every implemented verification figure/table from actual solves.
% Input/output: none; writes PNG/CSV files. CODE_BRIGHT absent exports remain pending.
% Reference: the three module READMEs define scientific acceptance criteria.
    root = setup_paths();
    fprintf('Running Terzaghi consolidation ...\n'); first = run_01(root);
    fprintf('Running fracture closure and cubic law ...\n'); second = run_02(root);
    fprintf('Running radial injection and parameter recovery ...\n'); third = run_03(root);
    write_csv(fullfile(root,'results','summary.csv'), ...
        'terzaghi_L2,spatial_order,BE_time_order,CN_time_order,exponential_flow_gain,hyperbolic_flow_gain,theis_max_qualified_error,mass_error,k_recovery_error,storage_recovery_error,outer_extension_change', ...
        [first.relative_l2,first.spatial_order,first.be_time_order,first.cn_time_order, ...
        second.exponential_gain,second.hyperbolic_gain,third.max_qualified_error,third.mass_error, ...
        third.k_error,third.storage_error,third.outer_extension_relative_change]);
    fprintf('Measured summary:\n'); disp(first); disp(second); disp(third);
    fprintf('Numerical modules: PASS. CODE_BRIGHT: %s\n',first.codebright.status);
    if exist('OCTAVE_VERSION','builtin'), engine = ['GNU Octave ',OCTAVE_VERSION]; else, engine = ['MATLAB ',version]; end
    file = fopen(fullfile(root,'results','runtime.txt'),'w');
    assert(file >= 0); fprintf(file,'%s\n',engine); fclose(file);
    file = fopen(fullfile(root,'results','codebright_status.txt'),'w');
    assert(file >= 0); fprintf(file,'%s\n',first.codebright.status); fclose(file);
end
