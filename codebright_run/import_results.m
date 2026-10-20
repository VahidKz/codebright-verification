function import_results(run_directory, repository_root)
% IMPORT_RESULTS Extract our native CODE_BRIGHT result into normalized SI CSV.
% Inputs: fresh run directory and repo root (char). Outputs: measured CSV/figure.
% Reference: pinned UPC example; post-result time is hours, pressure is MPa.
% Concentrations use a common species reference at node 1's first output.
    root = repository_root; setup_paths();
    case_name = 'Ex_CHE_MECH_eq_CB26_02'; nodes = 21;
    metadata_path = fullfile(run_directory,'run_metadata.json');
    assert(exist(metadata_path,'file') == 2,'Run the checked PowerShell runner first.');
    metadata = fileread(metadata_path);
    assert(~isempty(regexp(metadata,'"matches_distributed_reference"\s*:\s*true','once')));
    mesh = fileread(fullfile(run_directory,[case_name,'.post.msh']));
    lines = regexp(mesh,'\r?\n','split'); coordinates = zeros(nodes,2);
    start = find(strcmp(strtrim(lines),'Coordinates'),1)+1;
    assert(~isempty(start)); count = 0;
    for i = start:numel(lines)
        if strcmpi(strtrim(lines{i}),'End coordinates'), break; end
        row = sscanf(lines{i},'%f');
        assert(numel(row) == 3 && row(1) == count+1 && all(isfinite(row)));
        count = count+1; assert(count <= nodes); coordinates(count,:) = row(2:3)';
    end
    assert(count == nodes,'Unexpected example mesh.');
    file = fopen(fullfile(run_directory,[case_name,'.post.res']),'r');
    assert(file >= 0); cleanup = onCleanup(@() fclose(file));
    times = []; pressure = zeros(nodes,0); first = pressure; second = pressure;
    seen = false(3,0); line = fgetl(file);
    while ischar(line)
        match = regexp(line,['^Result\s+(Liquid_Pressure|Concentration_1|Concentration_2)', ...
            '\s+Isochrones\s+(\S+)\s+Scalar\s+onNodes\s*$'],'tokens','once');
        if ~isempty(match)
            time = str2double(match{2})*3600; % This example writes GiD result time in hours.
            assert(isfinite(time) && time > 0);
            index = find(times == time,1);
            if isempty(index)
                assert(strcmp(match{1},'Liquid_Pressure'));
                times(end+1) = time; index = numel(times);
                pressure(:,index) = NaN; first(:,index) = NaN; second(:,index) = NaN;
                seen(:,index) = false;
            end
            fields = {'Liquid_Pressure','Concentration_1','Concentration_2'};
            field = find(strcmp(fields,match{1})); assert(~seen(field,index));
            assert(strcmp(strtrim(fgetl(file)),'Values')); values = zeros(nodes,1);
            for node = 1:nodes
                row = sscanf(fgetl(file),'%f');
                assert(numel(row) == 2 && row(1) == node && all(isfinite(row)));
                values(node) = row(2);
            end
            assert(strcmp(strtrim(fgetl(file)),'End Values'));
            if field == 1, pressure(:,index) = values*1e6;
            elseif field == 2, first(:,index) = values;
            else, second(:,index) = values; end
            seen(field,index) = true;
        end
        line = fgetl(file);
    end
    assert(numel(times) == 105 && all(diff(times) > 0) && times(end) == 720000000);
    assert(all(seen(:)) && all(first(:) > 0) && all(second(:) > 0));
    pressure_range = max(pressure(:))-min(pressure(:)); assert(pressure_range < 1e-8);
    normalized_first = first/first(1,1);
    normalized_second = second/second(1,1);
    data = zeros(nodes*numel(times),8);
    for i = 1:numel(times)
        rows = (i-1)*nodes+(1:nodes);
        data(rows,:) = [times(i)*ones(nodes,1),(1:nodes)',coordinates,pressure(:,i), ...
            normalized_first(:,i),normalized_second(:,i),i*ones(nodes,1)];
    end
    folder = fullfile(root,'codebright_run','results');
    write_csv(fullfile(folder,'nodal_history.csv'), ...
        'time_s,node_id,x_m,y_m,pressure_pa,C1_over_reference,C2_over_reference,output_index',data);
    write_csv(fullfile(folder,'metrics.csv'), ...
        'nodes,elements,time_steps,output_frames,final_time_s,uniform_pressure_pa,pressure_range_pa', ...
        [nodes,24,2074,numel(times),times(end),pressure(1,1),pressure_range]);
    copyfile(metadata_path,fullfile(folder,'run_metadata.json'));
    copyfile(fullfile(run_directory,'completion.txt'),fullfile(folder,'completion.txt'));
    plot_results(root);
end
