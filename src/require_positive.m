function require_positive(value, name)
% REQUIRE_POSITIVE Validate real, finite, strictly positive model inputs.
% Inputs: numeric value [caller units], name (char). Output: assertion on error.
% Reference: validation helper; no physical equation.
    assert(isnumeric(value) && isreal(value) && ~isempty(value) && all(isfinite(value(:))) ...
        && all(value(:) > 0), [name, ' must be finite, real, and positive.']);
end
