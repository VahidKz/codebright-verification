# Implementation and scientific self-review

Reviewed 20 October 2026. These are implementation self-reviews, not external peer review or experimental validation. The exact CI result is attached to each GitHub commit through the workflow badge and Actions history.

## Senior Engineer check — PASS WITH NOTES

Scope: independent repository, original MATLAB/Octave code, synthetic parameters, tests, reproducible artifacts, and a documented CODE_BRIGHT exchange interface. The surrounding profile repository, employer code, and application documents are untouched. No external runtime services, credentials, downloaded datasets, CODE_BRIGHT distribution files, or proprietary inputs are needed by the numerical scripts.

The numerical solvers use sparse matrices and direct solves, not explicit inverses. Inputs reject tensile fracture stresses and invalid physical values; loops have explicit bounds where very small times or step growth could be impractical. Pressure/export units and sign conventions are documented. Plot defaults are scoped to each figure rather than mutating the user's global graphics defaults.

Fixed during review: numeric CSV reading previously relied on a reader that could silently convert malformed text to zero. The importer now checks each finite real numeric field and exact column count, rejects empty data, and rejects incomplete provenance placeholders. Tests cover malformed rows and missing/partial evidence. Provenance validation checks documentation structure; it cannot authenticate solver origin.

## Scientific QA check — PASS WITH NOTES

Five assert-based test groups pass under GNU Octave 10.3.0. Full reproduction separately asserts spatial/temporal orders, fine-grid pressure error, Theis error, parameter recovery, conservation, and outer-boundary sensitivity. Figures were generated from actual solves and visually inspected for labels, trends, matching references, and the early-time CN undershoot.

Independent checks include tabulated consolidation degrees; integrated Fourier pressure versus average degree; a semidiscrete matrix exponential for time refinement; finite-difference differentiation of hyperbolic closure; a hand-computed cubic-law flow; Theis versus finite volume; and parameter recovery from numerical data. Additional finite-volume checks exercise a leaking outer boundary, reversed injection, and zero flow, ensuring that volume balance is not tested only where outflow is negligible.

Review clarifications: $b^3/12$ has units m³, while hydraulic transmissivity includes density, gravity, and viscosity. The two fracture laws have different residual apertures, so differences cannot be attributed solely to functional form. The radial spatial refinement reaches a temporal/interpolation floor; no unsupported second-order claim is made. Error and inverse-fit windows use different Theis-argument thresholds and are disclosed. Synthetic ground truth is used to select the fit window, not supplied to the inverse-fit function.

## Outstanding evidence

- **Actual CODE_BRIGHT verification is incomplete.** No GiD/CODE_BRIGHT installation, tutorial run, own model, export, or comparison error is claimed. The importer is tested using an explicitly synthetic temporary fixture, which is deleted and never published as solver data. Genuine run evidence is required before describing module 01 as a three-way solver verification.
- MATLAB is a compatibility target, not a tested runtime. Local execution used GNU Octave 10.3.0; CI uses the distribution's available Octave version and archives its runtime record.
- Constitutive parameters are illustrative and uncalibrated. No experimental validation, full poroelastic displacement solve, geochemistry, heat transport, fracture network, propagation, shear, or seismicity prediction is provided.

No unresolved must-fix issue remains within the implemented numerical scope. The missing CODE_BRIGHT run remains a visible deliverable gap, not a passing solver result.
