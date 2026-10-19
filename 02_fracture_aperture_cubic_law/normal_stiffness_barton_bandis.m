function stiffness = normal_stiffness_barton_bandis(stress, Vm, Kni)
% NORMAL_STIFFNESS_BARTON_BANDIS Tangent d(stress)/d(closure).
% Inputs: stress [Pa], Vm [m], Kni [Pa/m]. Output: tangent stiffness [Pa/m].
% Reference: derivative of Bandis et al. (1983) hyperbolic closure.
    require_positive(Vm,'Vm'); require_positive(Kni,'Kni');
    assert(isreal(stress) && all(isfinite(stress(:))) && all(stress(:) >= 0));
    stiffness = Kni*(1+stress/(Kni*Vm)).^2;
end
