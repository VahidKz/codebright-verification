function value = l2_error(x, numerical, reference)
% L2_ERROR Relative integrated L2 error, with trapezoidal spatial weights.
% Inputs: x [m], numerical and reference [same units], equal-length vectors.
% Output: dimensionless ||numerical-reference||_L2 / ||reference||_L2.
% Reference: continuous L2 norm approximated by trapz.
    x = x(:); numerical = numerical(:); reference = reference(:);
    assert(numel(x) >= 2 && numel(x) == numel(numerical) && numel(x) == numel(reference));
    assert(all(isfinite([x; numerical; reference])) && all(diff(x) > 0));
    denominator = trapz(x, reference.^2);
    assert(denominator > 0, 'Reference norm must be nonzero.');
    value = sqrt(trapz(x, (numerical-reference).^2) / denominator);
end
