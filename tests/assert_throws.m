function assert_throws(callback)
% ASSERT_THROWS Require a callback to reject an invalid model input.
% Input: function handle. Output: assertion on missing exception.
% Reference: test infrastructure only.
    caught = false;
    try, callback(); catch, caught = true; end
    assert(caught, 'Expected an exception.');
end
