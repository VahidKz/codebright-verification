function run_all_tests()
% RUN_ALL_TESTS Execute real assert-based physics tests; errors propagate to CI.
% Input/output: none. Reference: repository verification contracts.
    setup_paths();
    tests = {@test_helpers,@test_01_terzaghi,@test_02_fracture,@test_03_theis,@test_codebright_import};
    for i = 1:numel(tests)
        fprintf('Testing %s ... ',func2str(tests{i}));
        tests{i}(); fprintf('PASS\n');
    end
    fprintf('All %d test groups passed.\n',numel(tests));
end
