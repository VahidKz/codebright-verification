# Native CODE_BRIGHT run: official equilibrium-chemistry example

**Completed on 20 October 2026:** the unchanged UPC example `Ex_CHE_MECH_eq_CB26_02` ran natively on Windows with the official `CODE_BRIGHT_2026_10` executable. It reached **720000000 s in 2074 time steps**, exited with code **0**, and produced no stderr. The newly generated `.post.res` file is **byte-identical to the reference result distributed with the official example archive**.

This checks installation and reproduction of an existing reference calculation. It is not an independent analytical verification of CODE_BRIGHT, an original reactive-transport implementation, or experimental validation. The [own Terzaghi consolidation comparison](../01_terzaghi_consolidation/codebright/README.md) remains pending. This example is not the tutorial manual's first shallow-foundation exercise, and no completed GiD session is claimed.

![Normalized fields from the actual native solver output](figure.png)

The official case has a 3 m × 1 m planar mesh, 21 nodes, 24 triangular elements, and three nodal unknowns: liquid pressure and two primary chemical concentrations. Its chemistry defines four aqueous species and two equilibrium reactions, with no kinetic reactions. The recorded liquid pressure remains uniformly 110000 Pa. The plots show normalized primary concentrations; they make no claim about fracture mechanics or calibrated limestone chemistry.

## Reproduce the native run

Download the solver from the [official CODE_BRIGHT versions page](https://deca.upc.edu/en/projects/code_bright/downloads/Code_Bright_vX) and the [2026 CheMech example archive](https://deca.upc.edu/en/projects/code_bright/downloads/other-examples/2026-geochemistry/chemech/examples_chemech_cb26_02.zip). Keep them outside the repository. The recorded solver package is `CODE_BRIGHT_2026_10.gid`.

The executable requires Intel OpenMP `libiomp5md.dll`. This run used the runtime from Intel's [`intel-openmp` 2026.2.0 Windows distribution](https://pypi.org/project/intel-openmp/2026.2.0/), placed beside the executable with its license retained locally. Nothing was installed into system directories. No solver, runtime, manual, official input file, or archived reference result is redistributed here. This command uses the supplied GiD-generated inputs directly; GiD is not needed for this batch replay.

From PowerShell at the repository root, supply actual local paths and a **new** run directory:

```powershell
.\codebright_run\run_example.ps1 `
  -Solver 'C:\path\CODE_BRIGHT_2026_10.gid\CODE_BRIGHT.exe' `
  -ExampleArchive 'C:\path\examples_chemech_cb26_02.zip' `
  -RunDirectory 'C:\path\new-equilibrium-run'
```

The runner pins solver/input hashes, extracts **six input files only**, uses one OpenMP thread, limits execution to 120 seconds, checks the exit status and stderr, verifies final time/step count, and compares the new result hash with the archived reference **without extracting reference output into the run folder**. A reused directory or mismatched version fails explicitly. `run_metadata.json` records input hashes, execution times, runtime hash, completion metrics, and result/reference hashes.

Recorded SHA-256 values:

| File | SHA-256 |
|---|---|
| Official 2026 solver ZIP | `620166f9febab5ff9b0c9ca29022afecba0826189fe31e349db727b4c47242fe` |
| CODE_BRIGHT executable | `a04ba941accf6bbbc00b93c8b70365e164b51d564d3a2a37cb90c8c0e90d74e0` |
| Official example ZIP | `ef07758fc6e4a554d2332478414b65ef430578329801164cb51371555f8f2007` |
| New result and distributed reference | `ba29d16081cb3125776868b2b8f15e8eee2e2e2393d9373e67cf26d71d11bc5d` |

## Export and plot our measurements

In MATLAB/Octave from the root:

```matlab
setup_paths
import_results('C:\path\new-equilibrium-run', pwd)
```

Use the corresponding mounted path when running Octave under Linux/WSL. The importer reads the **newly generated** mesh, results, log metadata, and completion record. It converts the example's GiD result times from hours to seconds and pressure from MPa to Pa. The final result time, 200000 hours, agrees with the solver's 720000000-second completion time. Each species uses a **single common normalization reference**, its node-1 concentration at the first output (0.36 s), preserving spatial comparisons. No concentration unit or exact initial-time equilibrium value is inferred. The time panel focuses on times of at least one day; the CSV retains all output times.

Committed [nodal history](results/nodal_history.csv), [metrics](results/metrics.csv), [run metadata](results/run_metadata.json), and [completion excerpt](results/completion.txt) are derived from our execution. Only measured scalar values and our own visualization are published. The solver's full raw outputs and the downloaded archive remain local. The importer validates all 21 nodes at all 105 output frames, missing/duplicate fields, final time, and positive concentrations.

`run_all` regenerates this figure from committed measurements. It does **not** rerun the native Windows solver. CI tests the recorded data and plot alongside the independent analytical/numerical modules; the native execution is reproduced separately with the PowerShell command above.

Attribution: the model, chemistry, mesh, and distributed reference are by the CODE_BRIGHT developers at UPC/CIMNE. This repository contributes the checked runner, result extraction, visualization, and measured run record. See the [official example listing](https://deca.upc.edu/en/projects/code_bright/downloads/other-examples).
