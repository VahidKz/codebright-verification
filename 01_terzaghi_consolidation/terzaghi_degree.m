function degree = terzaghi_degree(Tv, tolerance)
% TERZAGHI_DEGREE Average degree of consolidation, U=1-mean(u)/u0.
% Inputs: Tv>=0 [-], optional normalized series tolerance [-]. Output: U [-].
% Reference: Terzaghi (1943), U=1-sum(2/Mm^2*exp(-Mm^2*Tv)).
    if nargin < 2, tolerance = 1e-10; end
    assert(isreal(Tv) && all(isfinite(Tv(:))) && all(Tv(:) >= 0));
    require_positive(tolerance, 'tolerance'); assert(isscalar(tolerance) && tolerance < 1);
    degree = zeros(size(Tv));
    for j = 1:numel(Tv)
        if Tv(j) == 0, continue; end
        count = terzaghi_terms(Tv(j), tolerance);
        modes = pi*((0:count-1)+0.5);
        degree(j) = 1-sum(2./modes.^2.*exp(-modes.^2*Tv(j)));
    end
end
