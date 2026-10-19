function test_03_theis()
% TEST_03_THEIS Monotonicity, late-time limit, FV conservation, numerical-data inversion.
% Input/output: none. Reference: Theis (1935), Cooper & Jacob (1946).
    p = injection_parameters();
    [values,u] = theis_pressure([10 100 1000],[1e4 1e5 1e6],p.k,p.phi,p.mu,p.ct,p.h,p.q);
    assert(all(values(:) > 0) && all(all(diff(values,1,2) > 0)) && all(all(diff(values,1,1) < 0)));
    late = u < 0.01;
    approximation = p.q*p.mu/(4*pi*p.k*p.h)*(-log(u)-0.5772156649015329);
    assert(max(abs(approximation(late)./values(late)-1)) < 0.01);
    result = radial_diffusion_fv(p,600,1.01);
    assert(result.mass_error < 0.01);
    numerical = observe_radial(result,[10 100 1000]);
    [exact,u] = theis_pressure([10 100 1000],result.time,p.k,p.phi,p.mu,p.ct,p.h,p.q);
    qualified = u <= 0.1;
    assert(max(abs(numerical(qualified)./exact(qualified)-1)) < 0.02);
    window = u(2,:) < 0.005;
    fit = cooper_jacob_fit(result.time(window),numerical(2,window),100,p.q,p.mu,p.h);
    assert(abs(fit.k/p.k-1) < 0.02);
    assert(abs(fit.phi_ct/(p.phi*p.ct)-1) < 0.02);
    assert_throws(@() theis_pressure(0,1,p.k,p.phi,p.mu,p.ct,p.h,p.q));
    assert_throws(@() radial_diffusion_fv(p,10,1));
end
