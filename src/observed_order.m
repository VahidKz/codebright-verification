function order = observed_order(steps, errors)
% OBSERVED_ORDER Least-squares slope of log(error) versus log(step).
% Inputs: steps [m or s], positive errors [consistent units].
% Output: dimensionless convergence order. Reference: E = C*step^p.
    steps = steps(:); errors = errors(:);
    assert(numel(steps) >= 2 && numel(steps) == numel(errors));
    assert(all(isfinite([steps; errors])) && all(steps > 0) && all(errors > 0));
    assert(numel(unique(steps)) > 1, 'Use distinct refinement steps.');
    coefficients = polyfit(log(steps), log(errors), 1);
    order = coefficients(1);
end
