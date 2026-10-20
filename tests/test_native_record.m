function test_native_record()
% TEST_NATIVE_RECORD Validate real committed native-run measurements and provenance.
% Input/output: none. Reference: the pinned UPC example's completed native replay.
    root = fileparts(fileparts(mfilename('fullpath')));
    folder = fullfile(root,'codebright_run','results');
    data = read_numeric_csv(fullfile(folder,'nodal_history.csv'), ...
        'time_s,node_id,x_m,y_m,pressure_pa,C1_over_reference,C2_over_reference,output_index');
    assert(size(data,1) == 2205 && numel(unique(data(:,1))) == 105);
    assert(size(unique(data(:,[1 2]),'rows'),1) == 2205);
    assert(min(data(:,1)) == 0.36 && max(data(:,1)) == 720000000);
    assert(all(data(:,5) == 110000) && all(all(data(:,6:7) > 0)));
    reference = data(:,8) == 1 & data(:,2) == 1;
    assert(all(data(reference,6:7) == 1));
    assert(max(abs(data(:,6)-1)) > 0.01 && max(abs(data(:,7)-1)) > 0.01);
    for i = 1:105
        assert(isequal(sort(data(data(:,8) == i,2)),(1:21)'));
    end
    metadata = fileread(fullfile(folder,'run_metadata.json'));
    assert(~isempty(regexp(metadata,'"exit_code"\s*:\s*0','once')));
    assert(~isempty(regexp(metadata,'"matches_distributed_reference"\s*:\s*true','once')));
    assert(~isempty(strfind(metadata,'ba29d16081cb3125776868b2b8f15e8eee2e2e2393d9373e67cf26d71d11bc5d')));
end
