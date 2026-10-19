function metrics = compare_codebright(root, p, make_plots)
% COMPARE_CODEBRIGHT Compare supplied, provenance-documented exports without inventing solver data.
% Inputs: root (char), column parameters (SI), optional make_plots logical.
% Outputs: status, measured pressure/settlement errors; optional comparison figures/CSV.
% Reference: Terzaghi normalized excess pressure and linear oedometric settlement.
    if nargin < 3, make_plots = true; end
    folder = fullfile(root,'01_terzaghi_consolidation','codebright');
    pressure_path = fullfile(folder,'results','pressure.csv');
    settlement_path = fullfile(folder,'results','settlement.csv');
    provenance_path = fullfile(folder,'run_provenance.md');
    supplied = [exist(pressure_path,'file') == 2,exist(settlement_path,'file') == 2,exist(provenance_path,'file') == 2];
    metrics.status = 'PENDING: no genuine CODE_BRIGHT exports supplied';
    if ~any(supplied), return; end
    assert(all(supplied),'Partial CODE_BRIGHT evidence: supply both CSV files and run_provenance.md.');
    text = fileread(provenance_path);
    for field = {'Operator:','Run date:','CODE_BRIGHT version:','GiD version:','Mesh:', ...
            'Time stepping:','Parameters and units:','Initial pressure reference:'}
        assert(~isempty(strfind(text,field{1})),['Missing provenance field ',field{1}]);
    end
    data = read_numeric_csv(pressure_path,'time_s,depth_m,excess_pressure_pa,reference_initial_pressure_pa');
    settlement = read_numeric_csv(settlement_path,'time_s,settlement_m');
    assert(all(data(:,1) >= 0) && all(data(:,2) >= 0 & data(:,2) <= p.H) && all(data(:,4) > 0));
    assert(all(settlement(:,1) >= 0) && all(diff(settlement(:,1)) > 0));
    assert(size(unique(data(:,1:2),'rows'),1) == size(data,1),'Duplicate time/depth export samples.');
    times = unique(data(:,1)); fd = consolidation_fd(p.H,p.cv,p.q,160,1e-4*p.H^2/p.cv,times,'BE');
    analytical = zeros(size(data,1),1); numerical = analytical;
    for i = 1:size(data,1)
        analytical(i) = terzaghi_pressure(data(i,2),data(i,1),p.H,p.cv,1);
        index = find(times == data(i,1),1);
        numerical(i) = interp1(fd.z,fd.pressure(:,index),data(i,2))/p.q;
    end
    supplied_pressure = data(:,3)./data(:,4);
    exact_settlement = terzaghi_degree(p.cv*settlement(:,1)/p.H^2)*p.settlement_final;
    own_settlement = consolidation_fd(p.H,p.cv,p.q,160,1e-4*p.H^2/p.cv,settlement(:,1),'BE');
    metrics.status = 'COMPARED: user-supplied run; see run_provenance.md';
    metrics.pressure_max_normalized_error = max(abs(supplied_pressure-analytical));
    metrics.settlement_max_normalized_error = max(abs(settlement(:,2)-exact_settlement))/p.settlement_final;
    if make_plots
        f = new_figure(); depths = unique(data(:,2)); colors = lines(numel(depths));
        for i = 1:numel(depths)
            mask = data(:,2) == depths(i); rows = find(mask); [~,order] = sort(data(mask,1)); rows = rows(order);
            plot(data(rows,1)/86400,analytical(rows),'-','color',colors(i,:),'displayname',sprintf('Analytical z=%g m',depths(i))); hold on;
            plot(data(rows,1)/86400,numerical(rows),'--','color',colors(i,:),'handlevisibility','off');
            plot(data(rows,1)/86400,supplied_pressure(rows),'o','color',colors(i,:),'handlevisibility','off');
        end
        xlabel('Time (days)'); ylabel('Normalized excess pore pressure'); grid on;
        title('Analytical lines / own-FD dashed / supplied CODE_BRIGHT markers'); legend('location','eastoutside');
        save_figure(f,fullfile(root,'01_terzaghi_consolidation','figures','codebright_pressure.png'));
        f = new_figure(); plot(settlement(:,1)/86400,exact_settlement*1000,'-', ...
            settlement(:,1)/86400,own_settlement.degree'*p.settlement_final*1000,'--', ...
            settlement(:,1)/86400,settlement(:,2)*1000,'o'); grid on;
        xlabel('Time (days)'); ylabel('Downward top settlement (mm)'); legend('Analytical','Own FD','Supplied CODE_BRIGHT');
        save_figure(f,fullfile(root,'01_terzaghi_consolidation','figures','codebright_settlement.png'));
        f = new_figure(); semilogx(p.cv*settlement(:,1)/p.H^2,exact_settlement/p.settlement_final,'-', ...
            p.cv*settlement(:,1)/p.H^2,own_settlement.degree,'--', ...
            p.cv*settlement(:,1)/p.H^2,settlement(:,2)/p.settlement_final,'o'); grid on;
        xlabel('Time factor Tv'); ylabel('Settlement-based degree U'); legend('Analytical','Own FD','Supplied CODE_BRIGHT');
        save_figure(f,fullfile(root,'01_terzaghi_consolidation','figures','codebright_degree.png'));
        write_csv(fullfile(folder,'results','comparison_errors.csv'),'pressure_max_normalized_error,settlement_max_normalized_error', ...
            [metrics.pressure_max_normalized_error,metrics.settlement_max_normalized_error]);
    end
end
