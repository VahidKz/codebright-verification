function [z, operator] = consolidation_operator(H, cv, intervals)
% CONSOLIDATION_OPERATOR Sparse diffusion matrix with drained top/sealed bottom.
% Inputs: H [m], cv [m2/s], intervals>=2. Outputs: z [m], operator [1/s].
% Reference: central differences; bottom ghost value u(n+1)=u(n-1).
    require_positive(H, 'H'); require_positive(cv, 'cv');
    assert(isscalar(intervals) && intervals >= 2 && intervals == fix(intervals));
    z = linspace(0,H,intervals+1)';
    operator = spdiags([ones(intervals,1), -2*ones(intervals,1), ones(intervals,1)], ...
        [-1 0 1], intervals, intervals)*cv/(H/intervals)^2;
    operator(end,end-1) = 2*cv/(H/intervals)^2;
end
