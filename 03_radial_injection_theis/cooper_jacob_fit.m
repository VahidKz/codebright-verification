function fit = cooper_jacob_fit(time, pressure, radius, q, mu, h)
% COOPER_JACOB_FIT Recover permeability and phi*ct from numerical late-time data.
% Inputs: selected late times [s], pressure rise [Pa], radius [m], q [m3/s],
% viscosity [Pa s], layer thickness [m]. Output: k [m2], phi_ct [1/Pa], fit diagnostics.
% Reference: Cooper & Jacob (1946), slope=ln(10)*q*mu/(4*pi*k*h).
    require_positive(time,'time'); require_positive(radius,'radius'); require_positive(q,'q');
    require_positive(mu,'mu'); require_positive(h,'h');
    time = time(:); pressure = pressure(:);
    assert(numel(time) >= 3 && numel(time) == numel(pressure) && all(diff(time) > 0));
    assert(all(isfinite(pressure)) && isreal(pressure));
    coefficients = polyfit(log10(time),pressure,1); slope = coefficients(1);
    assert(slope > 0, 'Positive-injection recovery requires a positive semilog slope.');
    A = slope/log(10);
    fit.k = q*mu/(4*pi*h*A);
    fit.phi_ct = 4*fit.k/(radius^2*mu)*exp(-0.5772156649015329-coefficients(2)/A);
    fit.slope_pa_per_decade = slope; fit.intercept_pa = coefficients(2);
    fit.predicted = polyval(coefficients,log10(time));
    fit.relative_rms = norm(pressure-fit.predicted)/norm(pressure);
    fit.time_start_s = time(1); fit.time_end_s = time(end);
end
