function result = radial_diffusion_fv(p, cells, factor, initial_dt)
% RADIAL_DIFFUSION_FV Cell-centred, conservative log-radial backward-Euler solver.
% Inputs: p from injection_parameters (SI), cells>=4, timestep growth factor>1,
% initial_dt [s]. Outputs: r [m], time [s], pressure [Pa], storage/injected/outflow [m3].
% Reference: integral radial Darcy balance; G=2*pi*k*h/(mu*log(r2/r1)).
    if nargin < 4, initial_dt = 0.1; end
    assert(isscalar(cells) && cells >= 4 && cells == fix(cells));
    assert(isscalar(factor) && isfinite(factor) && factor > 1);
    for field = {'k','phi','mu','ct','h','rw','R','tmax'}
        require_positive(p.(field{1}),field{1});
    end
    assert(p.R > p.rw && isscalar(p.q) && isreal(p.q) && isfinite(p.q));
    require_positive(initial_dt,'initial_dt');
    edges = logspace(log10(p.rw),log10(p.R),cells+1)';
    radius = sqrt(edges(1:end-1).*edges(2:end));
    capacity = p.phi*p.ct*pi*p.h*(edges(2:end).^2-edges(1:end-1).^2);
    conductance = 2*pi*p.k*p.h./(p.mu*diff(log(radius)));
    outer = 2*pi*p.k*p.h/(p.mu*log(p.R/radius(end)));
    diagonal = [conductance;0]+[0;conductance]; diagonal(end) = diagonal(end)+outer;
    operator = spdiags(diagonal,0,cells,cells) ...
        +sparse(1:cells-1,2:cells,-conductance,cells,cells) ...
        +sparse(2:cells,1:cells-1,-conductance,cells,cells);
    count = ceil(log(1+(factor-1)*p.tmax/initial_dt)/log(factor))+3;
    assert(count <= 100000, 'Too many time steps; increase growth factor.');
    pressure = zeros(cells,count); times = zeros(1,count);
    storage = zeros(1,count); escaped = zeros(1,count);
    state = zeros(cells,1); now = 0; dt = initial_dt; index = 1;
    while now < p.tmax
        step = min(dt,p.tmax-now);
        lhs = spdiags(capacity/step,0,cells,cells)+operator;
        rhs = capacity.*state/step; rhs(1) = rhs(1)+p.q;
        state = lhs\rhs;
        now = now+step; index = index+1;
        pressure(:,index) = state; times(index) = now;
        storage(index) = capacity'*state;
        escaped(index) = escaped(index-1)+step*outer*state(end);
        dt = dt*factor;
    end
    result.r = radius; result.time = times(1:index); result.pressure = pressure(:,1:index);
    result.storage = storage(1:index); result.outer_outflow = escaped(1:index);
    result.injected = p.q*result.time;
    denominator = max(abs(p.q)*p.tmax,realmin);
    result.mass_error = max(abs(result.storage+result.outer_outflow-result.injected))/denominator;
    result.cells = cells; result.factor = factor;
end
