function test_01_terzaghi()
% TEST_01_TERZAGHI Tabulated degrees, independent series checks, PDE convergence.
% Input/output: none. Reference: Terzaghi U50/U90 and second-order central differences.
    assert(abs(terzaghi_degree(0.197)-0.5) < 0.005);
    assert(abs(terzaghi_degree(0.848)-0.9) < 0.005);
    assert(terzaghi_degree(0) == 0 && terzaghi_degree(20) > 1-1e-12);
    assert(terzaghi_degree(1e-8) < 0.001);
    z = linspace(0,1,81)';
    a = terzaghi_pressure(z,0.02,1,1,1,1e-8);
    b = terzaghi_pressure(z,0.02,1,1,1,1e-12);
    assert(max(abs(a-b)) < 1e-8);
    degree_integral = 1-trapz(z,terzaghi_pressure(z,0.2,1,1,1));
    assert(abs(degree_integral-terzaghi_degree(0.2)) < 1e-4);
    steps = 1./[20 40 80 160]; errors = zeros(size(steps));
    for i = 1:numel(steps)
        result = consolidation_fd(1,1,1,round(1/steps(i)),2e-5,0.2,'CN',2);
        exact = terzaghi_pressure(result.z,0.2,1,1,1);
        errors(i) = l2_error(result.z,result.pressure,exact);
    end
    assert(errors(end) < 0.01);
    order = observed_order(steps,errors);
    assert(order > 1.8 && order < 2.2);
    steady = consolidation_fd(1,1,1,40,0.01,[0 1 10],'BE');
    assert(all(steady.pressure(1,:) == 0));
    assert(max(abs(steady.pressure(:,end))) < 1e-9);
    assert_throws(@() terzaghi_pressure(-1,1,1,1,1));
    assert_throws(@() terzaghi_degree(-1));
    assert_throws(@() consolidation_fd(1,1,1,10,0.1,1,'unknown'));
end
