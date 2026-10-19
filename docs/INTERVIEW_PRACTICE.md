# Explain the benchmark without the code open

Answer aloud, then inspect the source and answer key. These questions are practice prompts, not evidence that the repository author has completed an interview or a CODE_BRIGHT run.

1. Derive $c_v=kM/\mu$ from Darcy flow, constrained elasticity, and conservation. Why is $M$ different from $E$? What happens to drainage time if height doubles?
2. Which physical boundary conditions produce the odd half-wave Fourier modes? What is special about exactly $t=0$?
3. How does the code bound the neglected Fourier terms? Why use normalized absolute rather than relative pressure tolerance?
4. Write the bottom row of the diffusion operator from the reflected ghost node. Why does one coefficient double?
5. Derive the theta-method matrices. Why is stable CN capable of negative early pressures? What exactly do the two startup steps do?
6. Explain the two different references in the spatial and temporal convergence experiments. Why can time error mask spatial order?
7. What is the difference between code verification and experimental validation? What has actually been completed here with CODE_BRIGHT?
8. Why could a real CODE_BRIGHT run have $u_0\neq q$? Does dividing by measured $u_0$ make its entire solution equivalent to the incompressible reference?
9. Derive hyperbolic tangent stiffness by differentiating closure. What do $K_{ni}$ and $V_m$ mean, and how could laboratory loading/unloading constrain them?
10. List the units of $b^3/12$, $b^2/12$, hydraulic transmissivity, discharge per unit width, and total discharge. What changes when aperture doubles?
11. Why do the two closure laws predict different injection gains? Are their residual apertures matched? What is assumed when mechanical closure supplies hydraulic aperture?
12. Does the fracture calculation solve coupled mechanics and flow? What would be needed to add pressure feedback spatially?
13. Derive the ring storage and radial conductance formulas. Why do internal face fluxes cancel? Why must cumulative outer outflow appear in the balance?
14. State Theis assumptions. Why is its line source different from a finite-radius prescribed-flux well? How was outer-boundary sensitivity checked?
15. Why exclude early tails from relative pressure error? What is the difference between the $u\leq0.1$ forward-error window and $u<0.005$ inverse-fit window?
16. Recover $k$ and $\phi c_t$ from a semilog slope/intercept. Why can changing seconds to days corrupt the storage estimate? Can this fit separate porosity from compressibility?
17. Which information from the synthetic ground truth is used to choose the fit window? What would you do if it were unknown?
18. Why is pressure-only Coulomb stress change insufficient for fault-stability prediction? Why is that feature absent here?
19. How could chemical dissolution and mechanical weakening compete in a carbonate fracture? What data and equations would you need beyond this repository?
20. Describe sequential versus fully coupled chemistry–flow–mechanics. Which convergence and mass-balance checks would a sequential loop need?

<details>
<summary>Answer key and discussion points</summary>

1. Fixed-load strain change follows pressure transfer to the skeleton, with compliance $1/M$. Combining this storage with Darcy mobility gives diffusivity $kM/\mu$. Lateral confinement raises the effective stiffness relative to unconstrained $E$. Time scales as $H^2/c_v$, hence fourfold for doubled height.
2. Sines enforce zero pressure at the top; zero derivative at the bottom gives $\cos M_m=0$. The initial interior pressure has a boundary jump. Its exact continuum integral differs from a coarse trapezoidal approximation at the isolated initial instant.
3. The first omitted term and an upper bound on the ratio of successive exponential tails give a geometric majorant. Relative error is undefined or misleading where the reference approaches zero.
4. $u_{N+1}=u_{N-1}$ leads to $u_{zz}(H)\simeq2(u_{N-1}-u_N)/\Delta z^2$.
5. $[I-\theta\Delta t L]u^{n+1}=[I+(1-\theta)\Delta t L]u^n$. CN barely damps stiff high-frequency modes and can alternate sign; two BE half steps per initial coarse step damp them strongly. BE is first-order but the finite startup treatment supports second-order CN convergence at positive time.
6. Spatial error uses the continuum Fourier solution; temporal error uses the exact fixed-mesh semidiscrete matrix exponential. Fixed temporal error eventually produces a refinement floor.
7. Verification checks numerical implementation against its equations. Validation compares a sufficiently specified physical model with observations. The current repository implements a guide/importer only for CODE_BRIGHT; no real solver run has been completed.
8. Fluid/grain compressibility, Skempton response, finite ramping, boundary drainage, and initial-state differences can alter $u_0$. Normalization alone cannot fix storage/diffusivity or displacement changes.
9. Differentiate $V_m\sigma/(K_{ni}V_m+\sigma)$ and invert. $K_{ni}$ is the initial tangent stiffness; $V_m$ is the limiting closure. Fit stress–closure data with attention to reference aperture, hysteresis, uncertainty, and hydraulic versus mechanical measurements.
10. Respectively m³, m², m²/s, m²/s, m³/s. Doubling aperture multiplies capacity/transmissivity/discharge by eight and intrinsic permeability by four at fixed fluid properties/gradient.
11. Both the closure shape and their uncalibrated parameters differ; residuals are 5 versus 10 μm. A hydraulic proxy assumes a connection between closure and conductance that roughness/contact can invalidate.
12. It prescribes pressures and stresses and evaluates constitutive laws. A spatial coupling needs conservation with pressure-dependent conductances, a nonlinear solve, appropriate boundary conditions, and independent checks; full mechanics also needs displacement equilibrium and constitutive laws.
13. Ring volume is $\pi h\Delta r^2$ and storage is volume times $\phi c_t$. Integrating radial Darcy flow yields a logarithmic resistance. Shared face fluxes have equal and opposite cell contributions. Any outer flux removes injected fluid that is no longer in storage.
14. Infinite homogeneous confined layer, constant properties/rate, radial saturated laminar Darcy flow, negligible wellbore storage, line source. A finite well differs near the well and early time. Here diffusion length is far below outer radius; doubling the radius with comparable resolution tests its influence.
15. Tiny exact early pressures amplify harmless absolute error. $u\leq0.1$ avoids that region; $u<0.005$ makes the logarithmic Cooper–Jacob approximation more accurate for inversion.
16. $A=a/\ln10$, $k=q\mu/(4\pi hA)$, $\phi c_t=4k\exp(-\gamma-b/A)/(r^2\mu)$. The intercept absorbs the time unit. Only the product is identifiable from this model.
17. True permeability/storage set $u$ when choosing the synthetic window; they are not passed into the fit. Field work would inspect semilog slopes/derivatives and estimate window sensitivity, noise, boundaries, heterogeneity, and uncertainty.
18. Poroelastic changes in total stress and thermal stress can affect fault stability alongside pressure. No displacement, heat, frictional slip, or fault geometry is solved here. See the Kivi et al. primary reference in module 03.
19. Dissolution can widen voids while weakened contacts increase closure under compression. Require measured reaction rates, surface area, transport, saturation state, contact evolution, and hydraulic/mechanical aperture calibration. Do not equate bulk strength loss directly with joint-stiffness loss.
20. Sequential schemes exchange fields between separate solvers, with fixed-point iterations if strongly coupled; fully coupled schemes solve the combined nonlinear system. Check species/fluid balances, interface consistency, iteration tolerances, time-step sensitivity, and limiting cases. Neither is implemented here.

</details>
