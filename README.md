# codebright-verification

[![Octave verification](https://github.com/VahidKz/codebright-verification/actions/workflows/ci.yml/badge.svg)](https://github.com/VahidKz/codebright-verification/actions/workflows/ci.yml)

Small, reproducible MATLAB/Octave benchmarks for consolidation, stress-dependent fracture flow, and radial injection. Analytical solutions, independent numerical solvers, convergence studies, and parameter recovery make the assumptions and errors inspectable. By [Vahid Keshavarz](https://www.researchgate.net/profile/Vahid-Keshavarz-2).

**Status:** all three numerical modules are implemented and tested. **Actual CODE_BRIGHT verification is pending:** no CODE_BRIGHT/GiD run, model, screenshot, or solver export is claimed. The [comparison interface and model guide](01_terzaghi_consolidation/codebright/README.md) are ready for genuine runs.

| Module | Verification | Measured result |
|---|---|---|
| [01 · Terzaghi consolidation](01_terzaghi_consolidation) | Fourier solution vs sparse finite differences; space/time refinement | Spatial order **2.001**; finest relative L2 error **0.000437%** |
| [02 · Fracture closure and flow](02_fracture_aperture_cubic_law) | Closure limits, stiffness derivative, cubic scaling | Illustrative injection gives **220.09× / 6.41×** flow gains for exponential / hyperbolic closure |
| [03 · Radial injection](03_radial_injection_theis) | Conservative finite volume vs Theis; Cooper–Jacob recovery from numerical data | Maximum qualified pressure error **0.118%**; permeability / storage recovery errors **0.209% / 0.945%** |

These rounded numbers come from [committed CSV results](results/summary.csv), generated with GNU Octave 10.3.0. The radial error includes only samples with Theis argument $u\leq0.1$, avoiding relative errors in near-zero early-time tails. The code asserts its acceptance criteria on every reproduction.

![Consolidation analytical and numerical pressure profiles](01_terzaghi_consolidation/figures/pressure.png)
![Pressure-driven aperture and flow changes for two closure laws](02_fracture_aperture_cubic_law/figures/injection.png)
![Theis and finite-volume pressure histories](03_radial_injection_theis/figures/pressure.png)

Run from the repository root in MATLAB or GNU Octave, with no toolboxes or external datasets:

```matlab
run_all_tests
run_all
```

Headless Octave:

```sh
octave --no-gui --quiet --eval "run_all_tests; run_all"
```

`run_all` regenerates module PNGs, CSVs, [summary metrics](results/summary.csv), and the runtime record. For a container installation:

```sh
docker run --rm --network none -e HOME=/tmp -v "$PWD:/work" -w /work \
  gnuoctave/octave:10.3.0 octave --no-gui --quiet --eval "run_all_tests; run_all"
```

Tested locally with **GNU Octave 10.3.0** on Linux, using gnuplot for headless PNGs. GitHub Actions independently installs Octave on `ubuntu-latest` and archives regenerated results. MATLAB compatibility is a design target; MATLAB execution has **not** been verified. CODE_BRIGHT and GiD versions are not listed because neither was run.

All parameters are **illustrative, not calibrated**. This is code verification against idealized equations, not validation against experiments. The fracture module prescribes normal stress and fluid pressure; it does not solve fully coupled poroelastic mechanics. No fracture networks, propagation, shear, geochemistry, thermal effects, or induced-seismicity prediction are implemented. Module READMEs state discretization and constitutive limitations.

For equations, see the module READMEs; for implementation explanations and questions, see the [physics walkthrough](docs/PHYSICS_WALKTHROUGH.md) and [interview practice](docs/INTERVIEW_PRACTICE.md). The [review record](docs/REVIEW.md) records verification scope and outstanding evidence.

Primary references: [Terzaghi (1943)](https://doi.org/10.1002/9780470172766), [Bandis et al. (1983)](https://doi.org/10.1016/0148-9062(83)90595-8), [Witherspoon et al. (1980)](https://doi.org/10.1029/WR016i006p01016), [Theis (1935)](https://doi.org/10.1029/TR016i002p00519), [Cooper & Jacob (1946)](https://doi.org/10.1029/TR027i004p00526), and the [official CODE_BRIGHT documentation](https://deca.upc.edu/en/projects/code_bright). Additional context appears in each module.

Original implementation released under the [MIT license](LICENSE). No CODE_BRIGHT/GiD distribution files are included.
