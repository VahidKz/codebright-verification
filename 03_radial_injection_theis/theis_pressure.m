function [pressure, u] = theis_pressure(radius, time, k, phi, mu, ct, h, q)
% THEIS_PRESSURE Infinite-domain line-source pressure rise under constant injection.
% Inputs: radius>0 [m], time>=0 [s], k [m2], phi [-], mu [Pa s], ct [1/Pa],
% layer h [m], signed injection q [m3/s]. Outputs: pressure [Pa], u [-]; rows=radii.
% Reference: Theis (1935), dp=q*mu/(4*pi*k*h)*E1(r^2*phi*mu*ct/(4*k*t)).
    require_positive(radius,'radius'); require_positive(k,'k'); require_positive(phi,'phi');
    require_positive(mu,'mu'); require_positive(ct,'ct'); require_positive(h,'h');
    assert(isscalar(q) && isfinite(q) && isreal(q));
    time = time(:)'; radius = radius(:);
    assert(isreal(time) && all(isfinite(time)) && all(time >= 0));
    u = inf(numel(radius),numel(time)); pressure = zeros(size(u));
    positive = time > 0;
    u(:,positive) = (radius.^2)*(phi*mu*ct./(4*k*time(positive)));
    pressure(:,positive) = q*mu/(4*pi*k*h)*expint(u(:,positive));
end
