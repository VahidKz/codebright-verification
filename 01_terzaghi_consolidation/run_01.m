function metrics = run_01(root)
% RUN_01 Regenerate analytical/FD pressure, degree, settlement, convergence and startup figures.
% Input: repository root (char). Output: measured metrics struct; PNG/CSV files.
% Reference: Terzaghi (1943); Rannacher (1984) diffusion startup.
    folder = fullfile(root,'01_terzaghi_consolidation'); p = consolidation_parameters();
    scale = p.H^2/p.cv; Tv = [0.001 0.01 0.05 0.2 0.5 1 2];
    solution = consolidation_fd(p.H,p.cv,p.q,120,1e-4*scale,Tv*scale,'BE');
    exact = terzaghi_pressure(solution.z,Tv*scale,p.H,p.cv,p.q);
    f = new_figure(); colors = lines(numel(Tv));
    for j = 1:numel(Tv)
        plot(exact(:,j)/p.q,solution.z/p.H,'-','color',colors(j,:),'displayname',sprintf('Tv=%.3g',Tv(j))); hold on;
        plot(solution.pressure(1:5:end,j)/p.q,solution.z(1:5:end)/p.H,'o','color',colors(j,:),'handlevisibility','off');
    end
    set(gca,'ydir','reverse'); xlabel('Excess pressure u/u0'); ylabel('Depth z/H');
    title('Single-drained consolidation: analytical lines, FD markers'); legend('location','eastoutside'); grid on;
    save_figure(f,fullfile(folder,'figures','pressure.png'));
    curve = logspace(-3,log10(2),90); analytical_degree = terzaghi_degree(curve);
    evolution = consolidation_fd(p.H,p.cv,p.q,120,1e-4*scale,curve*scale,'BE');
    f = new_figure(); semilogx(curve,analytical_degree,'-',curve,evolution.degree,'o','markersize',3);
    xlabel('Time factor Tv'); ylabel('Degree of consolidation U'); grid on;
    legend('Analytical','Own finite difference','location','southeast'); title('Average consolidation: analytical and own finite differences');
    save_figure(f,fullfile(folder,'figures','degree.png'));
    f = new_figure(); plot(curve*scale/86400,analytical_degree*p.settlement_final*1000,'-', ...
        curve*scale/86400,evolution.degree*p.settlement_final*1000,'o','markersize',3);
    xlabel('Time (days)'); ylabel('Top settlement (mm)'); legend('Analytical','Own FD','location','southeast'); grid on;
    title('Linear oedometric settlement; illustrative parameters'); save_figure(f,fullfile(folder,'figures','settlement.png'));
    write_csv(fullfile(folder,'results','evolution.csv'),'time_s,Tv,U_analytical,U_fd,settlement_analytical_m,settlement_fd_m', ...
        [curve'*scale,curve',analytical_degree',evolution.degree',analytical_degree'*p.settlement_final,evolution.degree'*p.settlement_final]);
    intervals = [20 40 80 160]; spatial_error = zeros(size(intervals));
    for j = 1:numel(intervals)
        s = consolidation_fd(1,1,1,intervals(j),2e-5,0.2,'CN',2);
        spatial_error(j) = l2_error(s.z,s.pressure,terzaghi_pressure(s.z,0.2,1,1,1));
    end
    dt = [0.04 0.02 0.01 0.005]; be_error = zeros(size(dt)); cn_error = be_error;
    [z,operator] = consolidation_operator(1,1,160);
    reference = [0;expm(full(0.2*operator))*ones(160,1)];
    for j = 1:numel(dt)
        s = consolidation_fd(1,1,1,160,dt(j),0.2,'BE'); be_error(j) = l2_error(z,s.pressure,reference);
        s = consolidation_fd(1,1,1,160,dt(j),0.2,'CN',2); cn_error(j) = l2_error(z,s.pressure,reference);
    end
    metrics.spatial_order = observed_order(1./intervals,spatial_error);
    metrics.be_time_order = observed_order(dt,be_error);
    metrics.cn_time_order = observed_order(dt,cn_error);
    metrics.relative_l2 = spatial_error(end); metrics.cv = p.cv; metrics.M = p.M;
    f = new_figure(); subplot(1,2,1); loglog(1./intervals,spatial_error,'o-');
    xlabel('Normalized grid spacing'); ylabel('Relative L2 pressure error'); title(sprintf('Spatial order %.3f',metrics.spatial_order)); grid on;
    subplot(1,2,2); loglog(dt,be_error,'o-',dt,cn_error,'s-'); grid on;
    xlabel('Normalized time step'); ylabel('Relative error vs exact semidiscrete evolution');
    legend('BE','CN + Rannacher','location','northwest'); title(sprintf('Time orders %.2f / %.2f',metrics.be_time_order,metrics.cn_time_order));
    save_figure(f,fullfile(folder,'figures','convergence.png'));
    write_csv(fullfile(folder,'results','spatial_convergence.csv'),'intervals,dz_over_H,relative_l2_error', ...
        [intervals',1./intervals',spatial_error']);
    write_csv(fullfile(folder,'results','temporal_convergence.csv'),'dt_normalized,BE_relative_error,CN_Rannacher_relative_error',[dt',be_error',cn_error']);
    be = consolidation_fd(1,1,1,160,0.001,0.001,'BE');
    cn = consolidation_fd(1,1,1,160,0.001,0.001,'CN');
    ran = consolidation_fd(1,1,1,160,0.001,0.001,'CN',2);
    f = new_figure(); plot(be.z,terzaghi_pressure(be.z,0.001,1,1,1),'-',be.z,be.pressure,'--', ...
        cn.z,cn.pressure,':',ran.z,ran.pressure,'-.'); xlim([0 .15]); grid on;
    xlabel('Depth z/H'); ylabel('Excess pressure u/u0'); title('Early-time CN oscillation and two half-step BE remedy');
    legend('Analytical','BE','CN without startup','CN + Rannacher','location','southeast');
    save_figure(f,fullfile(folder,'figures','startup.png'));
    metrics.cn_minimum = min(cn.pressure); metrics.rannacher_minimum = min(ran.pressure);
    assert(metrics.relative_l2 < 0.01 && metrics.spatial_order > 1.8 && metrics.spatial_order < 2.2);
    assert(metrics.be_time_order > 0.85 && metrics.be_time_order < 1.15);
    assert(metrics.cn_time_order > 1.8 && metrics.cn_time_order < 2.2);
    metrics.codebright = compare_codebright(root,p);
end
