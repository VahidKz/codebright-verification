function test_02_fracture()
% TEST_02_FRACTURE Limits, independent tangent derivative, cubic prefactor and signs.
% Input/output: none. Reference: Bandis et al. (1983), Witherspoon et al. (1980).
    b0 = 50e-6; Vm = 40e-6; Kni = 20e9;
    [b,closure] = aperture_barton_bandis([0 0.8e6 1e16],b0,Vm,Kni);
    assert(b(1) == b0 && closure(1) == 0);
    assert(abs(closure(2)/Vm-0.5) < 1e-12);
    assert(abs(closure(end)/Vm-1) < 1e-9);
    assert(normal_stiffness_barton_bandis(0,Vm,Kni) == Kni);
    stress = [1e5 1e6 10e6]; delta = 10;
    [~,plus] = aperture_barton_bandis(stress+delta,b0,Vm,Kni);
    [~,minus] = aperture_barton_bandis(stress-delta,b0,Vm,Kni);
    finite_difference = 2*delta./(plus-minus);
    tangent = normal_stiffness_barton_bandis(stress,Vm,Kni);
    assert(max(abs(finite_difference./tangent-1)) < 1e-6);
    assert(aperture_exponential(0,b0,5e-6,0.2e-6) == b0);
    assert(abs(aperture_exponential(1e12,b0,5e-6,0.2e-6)-5e-6) < 1e-15);
    Q = cubic_law_flow(1e-4,1,1e-3,-1000);
    assert(abs(Q-8.33333333333333e-8) < 1e-20);
    assert(abs(cubic_law_flow(2e-4,1,1e-3,-1000)/Q-8) < 1e-12);
    assert(cubic_law_flow(1e-4,1,1e-3,0) == 0);
    assert(cubic_law_flow(1e-4,1,1e-3,1000) < 0);
    assert_throws(@() aperture_barton_bandis(-1,b0,Vm,Kni));
    assert_throws(@() cubic_law_flow(0,1,1e-3,-1000));
end
