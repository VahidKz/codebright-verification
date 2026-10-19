function result = consolidation_fd(H, cv, u0, intervals, dt, times, method, startup_steps)
% CONSOLIDATION_FD Sparse theta-method column solver; optional Rannacher start.
% Inputs: H [m], cv [m2/s], u0 [Pa], intervals, dt [s], output times [s],
% method 'BE' or 'CN', startup_steps (CN coarse steps replaced by two half BE steps).
% Outputs: struct z [m], time [s], pressure [Pa], degree [-].
% Reference: Terzaghi diffusion PDE; theta=1 (BE), 1/2 (CN); Rannacher (1984).
    if nargin < 7, method = 'BE'; end
    if nargin < 8, startup_steps = 0; end
    require_positive(dt, 'dt'); require_positive(u0, 'u0');
    assert(isscalar(startup_steps) && startup_steps >= 0 && startup_steps == fix(startup_steps));
    times = times(:)';
    assert(~isempty(times) && all(isfinite(times)) && all(times >= 0) && all(diff(times) > 0));
    assert(strcmp(method,'BE') || strcmp(method,'CN'), 'Use BE or CN.');
    [z, operator] = consolidation_operator(H, cv, intervals);
    identity = speye(intervals); pressure = u0*ones(intervals,1);
    output = zeros(intervals+1,numel(times)); now = 0; coarse_steps = 0;
    last_step = -1; last_theta = -1;
    for j = 1:numel(times)
        target = times(j);
        while target-now > 1e-12*max(target,dt)
            step = min(dt,target-now); theta = 1;
            if strcmp(method,'CN'), theta = 0.5; end
            subdivisions = 1;
            if strcmp(method,'CN') && coarse_steps < startup_steps
                theta = 1; subdivisions = 2;
            end
            substep = step/subdivisions;
            for part = 1:subdivisions
                if abs(substep-last_step) > 1e-10*substep || theta ~= last_theta
                    A = identity-theta*substep*operator;
                    B = identity+(1-theta)*substep*operator;
                    [lower,upper,rowperm,colperm] = lu(A);
                    last_step = substep; last_theta = theta;
                end
                pressure = colperm*(upper\(lower\(rowperm*(B*pressure))));
            end
            now = now+step; coarse_steps = coarse_steps+1;
        end
        output(:,j) = [0;pressure];
    end
    result.z = z; result.time = times; result.pressure = output;
    result.degree = 1-trapz(z,output,1)/(H*u0);
    result.degree(times == 0) = 0; % Exact integral at the isolated discontinuous initial instant.
end
