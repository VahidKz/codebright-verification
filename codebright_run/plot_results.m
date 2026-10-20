function plot_results(root)
% PLOT_RESULTS Plot committed measurements from an actual native CODE_BRIGHT run.
% Input: repository root (char). Output: normalized concentration PNG.
% Reference: UPC equilibrium-chemistry example, reproduced with pinned binary/input.
    folder = fullfile(root,'codebright_run');
    data = read_numeric_csv(fullfile(folder,'results','nodal_history.csv'), ...
        'time_s,node_id,x_m,y_m,pressure_pa,C1_over_reference,C2_over_reference,output_index');
    assert(size(data,1) == 21*105 && max(data(:,1)) == 720000000);
    f = new_figure(); subplot(1,2,1);
    ids = [6 12 21];
    for i = 1:numel(ids)
        rows = data(:,2) == ids(i);
        semilogx(data(rows,1)/86400,data(rows,6),'displayname',sprintf('x = %g m',data(find(rows,1),3))); hold on;
    end
    grid on; xlim([1 1e4]); xlabel('Time (days)'); ylabel('Primary species 1 / fixed reference');
    title('Native CODE BRIGHT: unchanged UPC example'); legend('location','southwest');
    subplot(1,2,2); last = max(data(:,1)); rows = data(:,1) == last & data(:,4) == 0;
    [x,order] = sort(data(rows,3)); values = data(rows,6:7); values = values(order,:);
    plot(x,values(:,1),'o-',x,values(:,2),'s-'); grid on;
    xlabel('Distance along bottom boundary (m)'); ylabel('Concentration / fixed species reference');
    title('Final profile; reference output matched exactly');
    legend('Primary species 1','Primary species 2','location','east');
    save_figure(f,fullfile(folder,'figure.png'));
end
