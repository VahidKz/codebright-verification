function p = consolidation_parameters()
% CONSOLIDATION_PARAMETERS Illustrative, uncalibrated oedometric column in SI.
% Input: none. Output: struct H [m], E/M/q [Pa], k [m2], mu [Pa s], cv [m2/s].
% Reference: Terzaghi (1943), cv=k*M/mu, constrained isotropic elastic modulus.
    p.H = 10; p.E = 10e6; p.nu = 0.3; p.k = 1e-14; p.mu = 1e-3; p.q = 1e5;
    p.M = p.E*(1-p.nu)/((1+p.nu)*(1-2*p.nu));
    p.cv = p.k*p.M/p.mu;
    p.settlement_final = p.q*p.H/p.M;
end
