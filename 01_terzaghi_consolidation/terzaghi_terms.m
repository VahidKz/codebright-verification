function count = terzaghi_terms(Tv, tolerance)
% TERZAGHI_TERMS Bound the omitted normalized pressure Fourier-series tail.
% Inputs: Tv>0 and tolerance>0 [dimensionless]. Output: number of odd modes.
% Reference: geometric upper bound on 2/Mm*exp(-Mm^2*Tv), Mm=pi*(m+1/2).
    require_positive(Tv, 'Tv'); require_positive(tolerance, 'tolerance');
    assert(isscalar(Tv) && isscalar(tolerance) && tolerance < 1);
    count = 8;
    while true
        next = pi*(count+0.5);
        ratio = exp(-(2*pi*next+pi^2)*Tv);
        bound = 2/next*exp(-next^2*Tv)/max(1-ratio, realmin);
        if bound <= tolerance, return; end
        count = 2*count;
        assert(count <= 262144, 'Series too long; increase positive time or relax tolerance.');
    end
end
