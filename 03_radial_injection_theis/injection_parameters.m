function p = injection_parameters()
% INJECTION_PARAMETERS Illustrative uncalibrated confined-layer properties in SI.
% Input: none. Output: k [m2], phi [-], mu [Pa s], ct [1/Pa], h [m], q [m3/s], D [m2/s].
% Reference: Theis pressure diffusion, D=k/(phi*mu*ct).
    p.k = 1e-13; p.phi = 0.15; p.mu = 5e-4; p.ct = 1e-9;
    p.h = 50; p.q = 0.01; p.rw = 0.1; p.R = 40000;
    p.D = p.k/(p.phi*p.mu*p.ct); p.tmax = 30*86400;
end
