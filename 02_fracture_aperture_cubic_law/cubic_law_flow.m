function [Q, capacity, permeability, hydraulic_transmissivity] = cubic_law_flow(b, width, mu, gradient, rho)
% CUBIC_LAW_FLOW Smooth parallel-plate flow using FULL hydraulic aperture.
% Inputs: b [m], width [m], mu [Pa s], signed dp/dx [Pa/m], rho [kg/m3].
% Outputs: Q [m3/s], capacity b^3/12 [m3], permeability [m2], T_h [m2/s].
% Reference: Witherspoon et al. (1980); Q=-width*b^3/(12*mu)*dp/dx.
    if nargin < 5, rho = 1000; end
    require_positive(b,'b'); require_positive(width,'width'); require_positive(mu,'mu');
    require_positive(rho,'rho'); assert(isreal(gradient) && all(isfinite(gradient(:))));
    capacity = b.^3/12; permeability = b.^2/12;
    Q = -width*capacity.*gradient/mu;
    hydraulic_transmissivity = rho*9.81*capacity/mu;
end
