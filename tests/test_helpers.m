function test_helpers()
% TEST_HELPERS Verify shared numerical diagnostics with independently known values.
% Input/output: none; assertions throw on failure. Reference: L2 norm, E=C*h^p.
    x = linspace(0, 1, 11)';
    assert(abs(l2_error(x, 2*ones(size(x)), ones(size(x))) - 1) < 1e-14);
    assert(abs(observed_order([1 .5 .25], [1 .25 .0625]) - 2) < 1e-12);
    assert_throws(@() observed_order([1 1], [1 2]));
    assert_throws(@() require_positive(0, 'length'));
end
