function b = aperture_exponential(stress, b0, br, alpha)
% APERTURE_EXPONENTIAL Illustrative effective-compression hydraulic closure.
% Inputs: stress>=0 [Pa], b0/br [m], alpha [1/Pa]. Output: full aperture [m].
% Reference: exponential stress-aperture family, Rutqvist et al. (2002).
    require_positive(b0,'b0'); require_positive(br,'br'); require_positive(alpha,'alpha');
    assert(br <= b0 && isreal(stress) && all(isfinite(stress(:))) && all(stress(:) >= 0));
    b = br+(b0-br)*exp(-alpha*stress);
end
