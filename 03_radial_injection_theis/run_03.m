function metrics = run_03(root)
% RUN_03 Regenerate radial FV/Theis verification, convergence and numerical-data inversion.
% Input: root (char). Output: measured metrics struct, SI CSVs and PNG figures.
% Reference: Theis (1935); Cooper & Jacob (1946); conservative annular FV.
    folder = fullfile(root,'03_radial_injection_theis'); p = injection_parameters();
    result = radial_diffusion_fv(p,600,1.01); radii = [10 100 1000];
    numerical = observe_radial(result,radii);
    [exact,u] = theis_pressure(radii,result.time,p.k,p.phi,p.mu,p.ct,p.h,p.q);
    colors = lines(3); f = new_figure();
    for j = 1:3
        semilogx(result.time(2:end)/86400,exact(j,2:end)/1e6,'-','color',colors(j,:),'displayname',sprintf('r=%g m',radii(j))); hold on;
        ids = 2:20:numel(result.time);
        semilogx(result.time(ids)/86400,numerical(j,ids)/1e6,'o','markersize',3,'color',colors(j,:),'handlevisibility','off');
    end
    grid on; xlabel('Time (days)'); ylabel('Pressure rise (MPa)');
    title('Theis lines and conservative finite-volume markers'); legend('location','northwest');
    save_figure(f,fullfile(folder,'figures','pressure.png'));
    f = new_figure(); sample_days = [0.1 1 10 30];
    for j = 1:4
        [~,index] = min(abs(result.time-sample_days(j)*86400));
        semilogx(result.r,result.pressure(:,index)/1e6,'displayname',sprintf('t=%.3g d',result.time(index)/86400)); hold on;
    end
    xlabel('Radius (m)'); ylabel('Pressure rise (MPa)'); legend('location','northeast'); grid on;
    title('Radial injection in a homogeneous confined layer'); save_figure(f,fullfile(folder,'figures','profiles.png'));
    f = new_figure(); errors = [];
    for j = 1:3
        mask = u(j,:) <= 0.1; relative = abs(numerical(j,mask)./exact(j,mask)-1);
        errors = [errors relative];
        semilogx(result.time(mask)/86400,100*relative,'color',colors(j,:),'displayname',sprintf('r=%g m',radii(j))); hold on;
        write_csv(fullfile(folder,'results',sprintf('qualified_error_%dm.csv',radii(j))), ...
            'time_s,u,relative_pressure_error',[result.time(mask)',u(j,mask)',relative']);
    end
    xlabel('Time (days)'); ylabel('Relative error (%)'); title('Verification window u <= 0.1; early tail excluded');
    legend('location','northeast'); grid on; save_figure(f,fullfile(folder,'figures','error.png'));
    metrics.max_qualified_error = max(errors); metrics.mass_error = result.mass_error; metrics.D = p.D;
    window = u(2,:) < 0.005;
    fit = cooper_jacob_fit(result.time(window),numerical(2,window),100,p.q,p.mu,p.h);
    metrics.recovered_k = fit.k; metrics.recovered_phi_ct = fit.phi_ct;
    metrics.k_error = abs(fit.k/p.k-1); metrics.storage_error = abs(fit.phi_ct/(p.phi*p.ct)-1);
    f = new_figure(); semilogx(result.time(window)/86400,numerical(2,window)/1e6,'o', ...
        result.time(window)/86400,fit.predicted/1e6,'-');
    xlabel('Time (days); fit uses seconds internally'); ylabel('Pressure rise at 100 m (MPa)');
    legend('Numerical data','Cooper-Jacob fit','location','northwest'); grid on;
    title(sprintf('Recovered k=%.4g m^2; input k=%.4g m^2',fit.k,p.k));
    save_figure(f,fullfile(folder,'figures','recovery.png'));
    write_csv(fullfile(folder,'results','parameter_recovery.csv'),'input_k_m2,recovered_k_m2,relative_k_error,input_phi_ct_1_pa,recovered_phi_ct_1_pa,relative_storage_error,fit_start_s,fit_end_s', ...
        [p.k,fit.k,metrics.k_error,p.phi*p.ct,fit.phi_ct,metrics.storage_error,fit.time_start_s,fit.time_end_s]);
    write_csv(fullfile(folder,'results','observations.csv'),'time_s,dp10_numerical_pa,dp100_numerical_pa,dp1000_numerical_pa,dp10_theis_pa,dp100_theis_pa,dp1000_theis_pa', ...
        [result.time',numerical',exact']);
    write_csv(fullfile(folder,'results','mass_balance.csv'),'time_s,injected_m3,stored_m3,outer_outflow_m3', ...
        [result.time',result.injected',result.storage',result.outer_outflow']);
    fine_time = 1.002; counts = [50 100 200 400]; space_error = zeros(size(counts));
    final_exact = theis_pressure(100,p.tmax,p.k,p.phi,p.mu,p.ct,p.h,p.q);
    for j = 1:numel(counts)
        sample = radial_diffusion_fv(p,counts(j),fine_time);
        value = observe_radial(sample,100); space_error(j) = abs(value(end)/final_exact-1);
    end
    factors = [1.08 1.04 1.02 1.01]; time_error = zeros(size(factors));
    for j = 1:numel(factors)
        sample = radial_diffusion_fv(p,800,factors(j)); value = observe_radial(sample,100);
        time_error(j) = abs(value(end)/final_exact-1);
    end
    f = new_figure(); subplot(1,2,1); loglog(counts,space_error,'o-'); grid on;
    xlabel('Radial cells'); ylabel('Relative error at 100 m, 30 d'); title('Fixed time factor 1.002: temporal floor retained');
    subplot(1,2,2); loglog(factors-1,time_error,'o-'); grid on;
    xlabel('Time-step growth factor minus 1'); ylabel('Relative error at 100 m, 30 d'); title('Fixed 800 cells');
    save_figure(f,fullfile(folder,'figures','convergence.png'));
    write_csv(fullfile(folder,'results','spatial_convergence.csv'),'cells,time_factor,relative_error',[counts',fine_time*ones(4,1),space_error']);
    write_csv(fullfile(folder,'results','temporal_convergence.csv'),'cells,time_factor,relative_error',[800*ones(4,1),factors',time_error']);
    metrics.diffusion_length_m = sqrt(4*p.D*p.tmax); metrics.outer_radius_m = p.R;
    metrics.outer_to_diffusion_length = p.R/metrics.diffusion_length_m;
    metrics.analytic_outer_pressure_pa = theis_pressure(p.R,p.tmax,p.k,p.phi,p.mu,p.ct,p.h,p.q);
    extended = p; extended.R = 2*p.R;
    more_cells = round(600*log(extended.R/p.rw)/log(p.R/p.rw));
    comparison = radial_diffusion_fv(extended,more_cells,1.01);
    boundary = observe_radial(comparison,radii);
    metrics.outer_extension_relative_change = max(abs(boundary(:,end)./numerical(:,end)-1));
    assert(metrics.max_qualified_error < 0.02 && metrics.mass_error < 0.01);
    assert(metrics.k_error < 0.02 && metrics.storage_error < 0.02);
    assert(metrics.outer_extension_relative_change < 0.001);
end
