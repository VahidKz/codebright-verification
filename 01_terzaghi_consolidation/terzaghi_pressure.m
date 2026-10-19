function [pressure, counts] = terzaghi_pressure(z, time, H, cv, u0, tolerance)
% TERZAGHI_PRESSURE Exact single-drained Terzaghi excess pore pressure.
% Inputs: depth z in [0,H] [m], time>=0 [s], H [m], cv [m2/s], u0 [Pa], tol [-].
% Outputs: pressure [Pa], rows=depths/columns=times; counts, retained modes.
% Reference: Terzaghi (1943), sum 2*u0/Mm*sin(Mm*z/H)*exp(-Mm^2*Tv).
    if nargin < 6, tolerance = 1e-10; end
    require_positive(H, 'H'); require_positive(cv, 'cv'); require_positive(u0, 'u0');
    z = z(:); time = time(:)';
    assert(all(isfinite([z; time'])) && all(z >= 0 & z <= H) && all(time >= 0));
    require_positive(tolerance, 'tolerance'); assert(isscalar(tolerance) && tolerance < 1);
    pressure = zeros(numel(z), numel(time)); counts = zeros(size(time));
    for j = 1:numel(time)
        Tv = cv*time(j)/H^2;
        if Tv == 0
            pressure(:,j) = u0; pressure(z == 0,j) = 0;
        else
            count = terzaghi_terms(Tv, tolerance); counts(j) = count;
            modes = pi*((0:count-1)+0.5);
            coefficients = (2./modes).*exp(-modes.^2*Tv);
            pressure(:,j) = u0*sin((z/H)*modes)*coefficients';
            pressure(z == 0,j) = 0;
        end
    end
end
