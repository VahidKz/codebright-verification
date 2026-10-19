function [b, closure] = aperture_barton_bandis(stress, b0, Vm, Kni)
% APERTURE_BARTON_BANDIS Hyperbolic normal closure used as a hydraulic proxy.
% Inputs: compression stress [Pa], b0/Vm [m], initial stiffness Kni [Pa/m].
% Outputs: full hydraulic aperture b [m], normal closure [m].
% Reference: Bandis et al. (1983), closure=stress*Vm/(Kni*Vm+stress).
    require_positive(b0,'b0'); require_positive(Vm,'Vm'); require_positive(Kni,'Kni');
    assert(Vm < b0 && isreal(stress) && all(isfinite(stress(:))) && all(stress(:) >= 0));
    closure = Vm*stress./(Kni*Vm+stress);
    b = b0-closure;
end
