function metrics = run_02(root)
% RUN_02 Generate closure, stiffness, cubic capacity and injection comparison artifacts.
% Input: root (char). Output: computed gain metrics; PNG and SI-unit CSVs.
% Reference: exponential/hyperbolic closure and full-aperture parallel-plate cubic law.
    folder = fullfile(root,'02_fracture_aperture_cubic_law');
    stress = linspace(0,30e6,301); b0 = 50e-6; br = 5e-6; alpha = 0.2e-6;
    Vm = 40e-6; Kni = 20e9; mu = 1e-3;
    exponential = aperture_exponential(stress,b0,br,alpha);
    hyperbolic = aperture_barton_bandis(stress,b0,Vm,Kni);
    stiffness = normal_stiffness_barton_bandis(stress,Vm,Kni);
    [flow_exp,capacity_exp,~,trans_exp] = cubic_law_flow(exponential,1,mu,-100);
    [flow_bb,capacity_bb,~,trans_bb] = cubic_law_flow(hyperbolic,1,mu,-100);
    f = new_figure(); plot(stress/1e6,exponential*1e6,stress/1e6,hyperbolic*1e6);
    xlabel('Effective normal compression (MPa)'); ylabel('Full hydraulic aperture (micrometres)');
    legend('Exponential','Barton-Bandis proxy'); grid on; title('Illustrative, uncalibrated closure laws');
    save_figure(f,fullfile(folder,'figures','aperture.png'));
    f = new_figure(); plot(stress/1e6,stiffness/1e9); grid on;
    xlabel('Effective normal compression (MPa)'); ylabel('Tangent normal stiffness (GPa/m)');
    title('Hyperbolic closure stiffens under compression'); save_figure(f,fullfile(folder,'figures','stiffness.png'));
    f = new_figure(); semilogy(stress/1e6,trans_exp,stress/1e6,trans_bb); grid on;
    xlabel('Effective normal compression (MPa)'); ylabel('Hydraulic transmissivity (m^2/s)');
    legend('Exponential','Barton-Bandis proxy'); title('Cubic sensitivity to hydraulic aperture');
    save_figure(f,fullfile(folder,'figures','transmissivity.png'));
    pressure = linspace(10e6,28e6,181); effective = 30e6-pressure;
    inj_exp = aperture_exponential(effective,b0,br,alpha);
    inj_bb = aperture_barton_bandis(effective,b0,Vm,Kni);
    [q_exp,~,~,T_exp] = cubic_law_flow(inj_exp,1,mu,-100);
    [q_bb,~,~,T_bb] = cubic_law_flow(inj_bb,1,mu,-100);
    f = new_figure(); subplot(2,2,1); plot(pressure/1e6,inj_exp*1e6,pressure/1e6,inj_bb*1e6);
    xlabel('Fluid pressure (MPa)'); ylabel('Aperture (micrometres)'); legend('Exponential','Hyperbolic','location','northwest'); grid on;
    subplot(2,2,2); plot(pressure/1e6,normal_stiffness_barton_bandis(effective,Vm,Kni)/1e9);
    xlabel('Fluid pressure (MPa)'); ylabel('Hyperbolic stiffness (GPa/m)'); grid on;
    subplot(2,2,3); semilogy(pressure/1e6,T_exp/T_exp(1),pressure/1e6,T_bb/T_bb(1));
    xlabel('Fluid pressure (MPa)'); ylabel('Hydraulic T / initial T'); grid on;
    subplot(2,2,4); semilogy(pressure/1e6,q_exp,pressure/1e6,q_bb);
    xlabel('Fluid pressure (MPa)'); ylabel('Flow Q (m^3/s), fixed gradient'); grid on;
    save_figure(f,fullfile(folder,'figures','injection.png'));
    metrics.exponential_gain = T_exp(end)/T_exp(1); metrics.hyperbolic_gain = T_bb(end)/T_bb(1);
    write_csv(fullfile(folder,'results','closure.csv'),'stress_pa,b_exponential_m,b_hyperbolic_m,Kn_pa_per_m,capacity_exp_m3,capacity_bb_m3,T_exp_m2_s,T_bb_m2_s,Q_exp_m3_s,Q_bb_m3_s', ...
        [stress',exponential',hyperbolic',stiffness',capacity_exp',capacity_bb',trans_exp',trans_bb',flow_exp',flow_bb']);
    write_csv(fullfile(folder,'results','injection.csv'),'pressure_pa,effective_stress_pa,b_exp_m,b_bb_m,T_exp_m2_s,T_bb_m2_s,Q_exp_m3_s,Q_bb_m3_s', ...
        [pressure',effective',inj_exp',inj_bb',T_exp',T_bb',q_exp',q_bb']);
end
