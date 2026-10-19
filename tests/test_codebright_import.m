function test_codebright_import()
% TEST_CODEBRIGHT_IMPORT Schema validation only; synthetic fixture is NOT a CODE_BRIGHT run.
% Input/output: none. Reference: user-export contract, temporary transport-test data.
    root = tempname(); folder = fullfile(root,'01_terzaghi_consolidation','codebright');
    mkdir(fullfile(folder,'results')); cleanup = onCleanup(@() rmdir(root,'s'));
    p = consolidation_parameters(); status = compare_codebright(root,p,false);
    assert(~isempty(strfind(status.status,'PENDING')));
    t = [0.1;0.2;0.4]*p.H^2/p.cv; pressure = terzaghi_pressure(5,t,p.H,p.cv,p.q);
    write_csv(fullfile(folder,'results','pressure.csv'), ...
        'time_s,depth_m,excess_pressure_pa,reference_initial_pressure_pa', ...
        [t,5*ones(3,1),pressure',p.q*ones(3,1)]);
    assert_throws(@() compare_codebright(root,p,false));
    write_csv(fullfile(folder,'results','settlement.csv'),'time_s,settlement_m', ...
        [t,terzaghi_degree(p.cv*t/p.H^2)*p.settlement_final]);
    file = fopen(fullfile(folder,'run_provenance.md'),'w');
    fprintf(file,'SYNTHETIC IMPORT TEST ONLY, NOT A CODE_BRIGHT RUN\n');
    fprintf(file,'Operator: fixture\nRun date: fixture\nCODE_BRIGHT version: fixture\nGiD version: fixture\n');
    fprintf(file,'Mesh: fixture\nTime stepping: fixture\nParameters and units: fixture\nInitial pressure reference: fixture\n'); fclose(file);
    status = compare_codebright(root,p,false);
    assert(status.pressure_max_normalized_error < 1e-12);
    assert(status.settlement_max_normalized_error < 1e-12);
    file = fopen(fullfile(folder,'results','settlement.csv'),'w');
    fprintf(file,'time_s,settlement_m\n1,not_a_number\n'); fclose(file);
    assert_throws(@() compare_codebright(root,p,false));
    file = fopen(fullfile(folder,'results','settlement.csv'),'w');
    fprintf(file,'time_s,settlement_m\n'); fclose(file);
    assert_throws(@() compare_codebright(root,p,false));
    file = fopen(fullfile(folder,'run_provenance.md'),'w');
    fprintf(file,'Operator: [required]\n'); fclose(file);
    assert_throws(@() compare_codebright(root,p,false));
end
