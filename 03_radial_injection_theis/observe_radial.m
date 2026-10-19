function pressure = observe_radial(result, radii)
% OBSERVE_RADIAL Interpolate cell-centred pressure linearly in log radius.
% Inputs: radial solver struct, observation radii [m]. Output: pressure [Pa], rows=radii.
% Reference: logarithmic near-well spatial variation of radial Darcy flow.
    require_positive(radii,'radii');
    assert(all(radii(:) >= result.r(1) & radii(:) <= result.r(end)), 'No extrapolation.');
    pressure = interp1(log(result.r),result.pressure,log(radii(:)),'linear');
end
