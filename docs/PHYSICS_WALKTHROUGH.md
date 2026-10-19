# Physics and implementation walkthrough

Read this beside the linked source, then attempt the [questions](INTERVIEW_PRACTICE.md) without the answer key. Equations and assumptions are in the module READMEs. The explanations below follow each physics function's executable statements in source order; plotting and CSV plumbing are separate from the solvers.

## Consolidation: pressure diffusion and displacement

Darcy drainage has flux $v=-k u_z/\mu$. For oedometric elastic compression, a pressure decrease transfers load to the skeleton, giving strain increment $d\epsilon=-du/M$ under fixed total load (compression positive). Conservation then gives $u_t=(kM/\mu)u_{zz}$. This reduction assumes incompressible constituents, coefficient one, small strain, and constant properties. It is not the general compressible Biot system.

[consolidation_parameters.m](../01_terzaghi_consolidation/consolidation_parameters.m): the assignments specify SI inputs, compute the constrained rather than Young's modulus, combine Darcy mobility with elastic stiffness into diffusivity, and compute final settlement from the effective load after complete drainage.

[terzaghi_terms.m](../01_terzaghi_consolidation/terzaghi_terms.m): input checks exclude nonpositive time/tolerance. `count=8` starts with eight odd modes. `next=pi*(count+0.5)` is the first omitted wavenumber. Consecutive exponentials have ratios no larger than `exp(-(2*pi*next+pi^2)*Tv)`; the decreasing coefficient $2/M$ further reduces them. Thus `first_omitted/(1-ratio)` bounds the absolute tail. Return when the bound is small enough; otherwise double the count, rejecting an impractically large expansion. This controls normalized absolute pressure error, not relative error at a drained boundary.

[terzaghi_pressure.m](../01_terzaghi_consolidation/terzaghi_pressure.m): validate the domain and output times; reshape depth as a column and time as a row so the result is depth-by-time. At zero time return the uniform interior pressure with the drained top set to zero. At positive time compute $T_v$, obtain the bounded term count, build odd half-wave wavenumbers, multiply the sine basis by decaying coefficients, then scale by initial pressure. Each mode vanishes at the top and has zero derivative at the bottom. The code does not infer the source from a discretized solution.

[terzaghi_degree.m](../01_terzaghi_consolidation/terzaghi_degree.m): preserve the input time-factor shape, return exactly zero at zero, and at positive time subtract the integrated pressure series from one. The same term bound is sufficient because $2/M_m^2\leq2/M_m$. Multiplying by final settlement connects the pressure solution to the displacement observable.

[consolidation_operator.m](../01_terzaghi_consolidation/consolidation_operator.m): create nodes from zero to $H$ and retain only unknowns below the drained node. The interior stencil is $c_v(1,-2,1)/\Delta z^2$. At the bottom, reflect the ghost value across the sealed boundary: $u_{N+1}=u_{N-1}$, so the lower coefficient in the last row doubles. The zero top condition contributes no forcing. This matrix has units s⁻¹ and acts on pressure to give its time derivative.

[consolidation_fd.m](../01_terzaghi_consolidation/consolidation_fd.m), statement by statement:

1. Defaults choose BE and no startup; validation enforces a positive time step, pressure, ordered nonnegative output times, and recognized method.
2. `consolidation_operator` supplies the mesh and sparse diffusion matrix $L$. The unknown initial pressure vector is uniform; the top is excluded from it.
3. The outer loop chooses the next requested output time. The inner loop clips each step so it lands on that time rather than interpolating in time.
4. `theta=1` means BE; `theta=0.5` means CN. During each requested startup coarse step, two BE half steps replace a CN step.
5. Form $A=I-\theta\Delta t L$ and $B=I+(1-\theta)\Delta t L$. The update solves $Au^{n+1}=Bu^n$.
6. Sparse LU factors are reused when step size and theta are unchanged. With four-output sparse LU, the permutation matrices must be applied in the shown order; do not replace the solve with an explicit inverse.
7. Advance the physical time only after all substeps, count the coarse step, and prepend the prescribed zero top value when storing a profile.
8. Integrate pressure by depth: $U=1-\int u\,dz/(Hu_0)$. The isolated initial instant uses its exact continuum value rather than trapezoidal boundary-jump quadrature.

The spatial refinement compares against the Fourier solution. The time refinement instead uses `expm(t*L)` to isolate the error of integrating an already discretized system. These two references answer different questions. CN's high-frequency amplification approaches −1 at large stiffness, producing alternating signs; BE half steps damp those modes before CN resumes.

[compare_codebright.m](../01_terzaghi_consolidation/compare_codebright.m): missing all three evidence files means pending; a partial set fails. The importer validates provenance/schema/ranges, computes analytical and FD references at actual export times/depths, and normalizes exported pressure by the documented initial pressure. Settlement uses the theoretical final settlement as its error scale. It writes comparisons only when requested. It is an exchange/verification tool, not a CODE_BRIGHT launcher or evidence-authentication tool.

## Fracture closure, tangent stiffness, and flow

[aperture_exponential.m](../02_fracture_aperture_cubic_law/aperture_exponential.m): validate nonnegative compression and positive parameters with $b_r<b_0$, then evaluate the elementwise decaying exponential. The stress coefficient must be Pa⁻¹ if stress is Pa. At zero stress $b=b_0$; at large compression $b\to b_r$.

[aperture_barton_bandis.m](../02_fracture_aperture_cubic_law/aperture_barton_bandis.m): ensure $0<V_m<b_0$ so the residual aperture remains positive. Compute hyperbolic closure, then subtract it from zero-stress aperture. The product $K_{ni}V_m$ has pressure units and sets the half-closure stress. This is a mechanical closure formula used as an uncalibrated hydraulic-aperture proxy.

[normal_stiffness_barton_bandis.m](../02_fracture_aperture_cubic_law/normal_stiffness_barton_bandis.m): differentiate $\Delta V=V_m\sigma/(K_{ni}V_m+\sigma)$ to get $d\Delta V/d\sigma=K_{ni}V_m^2/(K_{ni}V_m+\sigma)^2$, then invert. The resulting stiffness increases as contact closes, with units Pa/m. A central finite-difference derivative in the tests provides an independent algebra check.

[cubic_law_flow.m](../02_fracture_aperture_cubic_law/cubic_law_flow.m): validate positive full aperture, viscosity, width, density, and a finite signed pressure gradient. Calculate geometric capacity $b^3/12$, equivalent permeability $b^2/12$, signed discharge $-w(b^3/12)p_x/\mu$, and hydraulic transmissivity $\rho g(b^3/12)/\mu$. Elementwise powers support stress sweeps. Doubling aperture makes capacity and discharge eight times larger, and permeability four times larger. Reversing the gradient reverses flow.

`run_02` sweeps effective stress and then prescribes $\sigma_n=30$ MPa with pressure 10–28 MPa. It does not update a spatial pressure field from the changed conductance. Normal stiffness is only used for interpretation; it is not a solved displacement equation. Separate residual apertures mean that the two curves compare parameterizations as well as functional forms.

## Radial diffusion, finite-volume balance, and inversion

[injection_parameters.m](../03_radial_injection_theis/injection_parameters.m) defines SI inputs and diffusivity. Here $\phi c_t$ is bulk storage per pressure, whereas aquifer storativity expressed in hydraulic head is a different quantity.

[theis_pressure.m](../03_radial_injection_theis/theis_pressure.m): validate positive radii/properties and nonnegative time; shape radius as a column and time as a row. Set pressure at zero time to zero directly. At positive time compute dimensionless $u=r^2\phi\mu c_t/(4kt)$ and multiply `expint(u)` by the rate/mobility scale $q\mu/(4\pi kh)$. Positive injection increases pressure; the sign reverses for extraction.

[radial_diffusion_fv.m](../03_radial_injection_theis/radial_diffusion_fv.m), statement by statement:

1. Check the grid, growth factor, properties, radii, rate, and initial time step. `logspace` gives cell edges; the geometric mean locates centers halfway in log radius.
2. `capacity` is $\phi c_t$ times each ring volume, with units m³/Pa. This is the amount of stored fluid volume per pressure increment.
3. `conductance` integrates steady Darcy flow between two radial centers, giving $2\pi kh/(\mu\ln(r_j/r_i))$ in m³/(Pa s). `outer` applies the same formula to the fixed-pressure outer boundary.
4. Assemble a positive diagonal, negative off-diagonal matrix. An internal face flux leaving one cell enters the next; those terms cancel when all rows are summed. Only the outer conductance remains as external loss.
5. Estimate the geometric time-step count and allocate history arrays. Initialize all pressure rises and volume changes to zero.
6. Clip the step at the final time. Add $C/\Delta t$ to the operator; form the previous-state storage term and add prescribed total inflow to the first cell. Solving gives the new pressure.
7. Store $C^T p$ as accumulated stored volume. Add `step*outer*state(end)` to cumulative escaped volume using the implicit boundary flux. Grow the next time step.
8. Return injected volume $qt$ and the largest absolute defect $|V_{stored}+V_{out}-V_{in}|$, normalized by total injected magnitude. This explicitly includes outer leakage, even though it is tiny in the default case.

[observe_radial.m](../03_radial_injection_theis/observe_radial.m) interpolates each numerical time profile at observation radii in log radius, requiring them inside the cell-center domain. It does not extrapolate to the well or boundary.

[cooper_jacob_fit.m](../03_radial_injection_theis/cooper_jacob_fit.m), statement by statement:

1. Validate positive ordered selected times and physical properties, reshape vectors, and require at least three finite pressure data.
2. Fit pressure to $a\log_{10}(t)+b$, where time is seconds. Require a positive slope for injection.
3. Convert the per-decade slope to a natural-log coefficient $A=a/\ln 10$. Recover $k=q\mu/(4\pi hA)$.
4. Using $p=A[\ln t+\ln(4k/(r^2\mu\phi c_t))-\gamma]$, solve the intercept relation for $\phi c_t$. The time unit matters inside the intercept; changing to days without changing the formula corrupts storage recovery.
5. Return fitted pressures, residual diagnostics, and selected time bounds for inspection. No true permeability/storage enters this function.

`run_03` selects a late-time window using known synthetic $u<0.005$. A real inverse problem would need independent window diagnostics and sensitivity/uncertainty analysis. Its forward-error window $u\leq0.1$ is less restrictive and serves a different purpose: excluding vanishing early tails from pointwise relative error.

## Interpreting the checks

`l2_error` integrates squared error and squared reference over the coordinate and takes their ratio's square root. `observed_order` regresses log error on log step, using all specified refinements. Neither a low residual nor conservation alone proves an accurate pressure field: both are assessed alongside analytical errors and refinement studies. Likewise a successful CSV import cannot prove that CODE_BRIGHT produced it. The current repository makes no such claim.
