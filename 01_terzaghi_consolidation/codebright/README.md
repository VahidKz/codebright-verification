# CODE_BRIGHT comparison: pending genuine run

**No CODE_BRIGHT model or output is present.** This folder provides a planned physical specification and a tested comparison interface. It is not evidence of software installation or a successful CODE_BRIGHT calculation. No element types, menu paths, parameter identifiers, versions, or solver behavior are invented here.

Obtain GiD and CODE_BRIGHT from the [official UPC/CIMNE site](https://deca.upc.edu/en/projects/code_bright) and [downloads page](https://deca.upc.edu/en/projects/code_bright/downloads). Follow the documentation matching the installed versions; run the first official tutorial unchanged and retain an original screenshot. Do not redistribute the downloaded tutorials, manuals, binaries, or runtime libraries in this repository.

## Target physical problem

Build an own 2D strip of height 10 m under oedometric conditions, using the [module's parameters and equations](../README.md). Specify lateral rollers, a vertically fixed bottom, impermeable sides/bottom, drained top, and an instantaneous uniform top load of 0.1 MPa. Work in saturated, linear elastic hydro-mechanics with gravity absent or with consistently defined excess pressure. The strip width is arbitrary for this laterally confined uniform test; record it and check uniformity laterally.

Match incompressible constituents and coefficient one as closely as the solver allows. Record actual fluid/grain compressibilities, elasticity, permeability convention (intrinsic m² versus hydraulic conductivity), viscosity, pressure reference, initial stress, load schedule, and units. **Consult the user's guide for exact input names and unit conversions.** Do not silently substitute MPa for Pa. A finite loading ramp, compressible constituents, or an inconsistent initial state changes the reference problem.

Use several mesh sizes and time-step refinements; confirm the output stabilizes before attributing a discrepancy to constitutive physics. Sample pressure at several depths, including the interior, over $T_v=0.001$ to 2. Export downward top settlement. Inspect actual initial pressure immediately after loading before drainage, and document how that value is obtained.

This is a **proposed model**, not a record of settings already used. After a real run, replace this paragraph with the actual setup and place original own project/input files under `model/`, original screenshots under `screenshots/`, and processed exports under `results/`. Keep raw exports with their units and conversion notes for auditability. The model and screenshots are human evidence; the importer cannot authenticate their origin.

## CSV comparison contract

Convert own exports into these exact numeric SI schemas. These are **repository-defined exchange formats**, not claims about CODE_BRIGHT's native file format. Headers have no spaces; all values must be finite.

`results/pressure.csv`:

```csv
time_s,depth_m,excess_pressure_pa,reference_initial_pressure_pa
```

Each row is one time/depth pair, with depth measured **down from the drained top**. Times are nonnegative, depths lie in [0,10] m, and pairs must be unique. The reference initial pressure is strictly positive and is taken from the actual modeled undrained interior state, not the zero-pressure drained boundary. Document any depth dependence. The comparison uses $u/u_{0,\mathrm{run}}$; subtract the initial hydrostatic pressure if necessary before exporting excess pressure.

`results/settlement.csv`:

```csv
time_s,settlement_m
```

Times must be strictly increasing. Settlement is the downward-positive top displacement relative to the pre-load state. The importer compares it directly with $UqH/M$ and reports the maximum absolute difference divided by $qH/M$.

Create `run_provenance.md` by completing [the template](run_provenance.template.md). Supply **both CSVs plus provenance together**. No example numerical rows are supplied, to avoid confusing synthetic fixture data with genuine solver output. The only synthetic importer fixture lives temporarily in a test directory and is deleted after testing.

From the repository root run:

```matlab
run_all_tests
run_all
```

With no evidence files the status remains `PENDING`. A partial set fails explicitly. A complete set produces pressure, settlement, and degree overlays under the module's `figures/`, plus `results/comparison_errors.csv` here. Pressure error is a maximum **absolute normalized** error, not pointwise relative error near zero. Only finite-difference convergence currently has automatic acceptance thresholds; the imported solver discrepancy must be assessed alongside the actual constitutive settings and refinement evidence. A successful import alone is not a passed CODE_BRIGHT verification.

Normalization by the model's own initial pressure does not correct mismatched storage, diffusivity, or settlement assumptions. Document and explain such differences; do not tune the exported normalization to hide them.
