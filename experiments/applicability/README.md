# Applicability diagnostics

Run from the repository root with Python 3.11+ and NumPy 2.4.3:

```sh
uv venv /tmp/vbd-applicability-venv
uv pip install --python /tmp/vbd-applicability-venv/bin/python numpy==2.4.3
/tmp/vbd-applicability-venv/bin/python experiments/applicability/study.py
```

## What the script executes

`model(...).sweep(...)` implements the actual full-step VBD map for the specified scalar
spring model. Each visit recomputes the nonlinear force and Hessian at the current state,
checks the singularity threshold, and performs `x_i -= f_i / H_ii`. Serial visits immediately
expose their updated coordinate to subsequent visits. A color batch computes its even or odd
vertices from one snapshot and commits that batch together. A sweep visits every vertex once.

The trajectory starts at the inertia predictor `y` and advances through these actual updates.
The “at most six sweeps” result is the first observed sweep count reaching the specified scaled
physical-residual tolerance over the supported grid. It is not inferred from eigenvalues or
from repeatedly applying a matrix linearized at the solution. The analytic 20-sweep guarantee
is a separate bound valid throughout the certified region.

A separate full-system Newton solve produces a reference root for measuring state errors and
root-local matrix diagnostics. It does not supply updates or initialization to the VBD
trajectory. Derivative matrices, their spectral radii and comparison bounds are additional
analysis outputs. The last recorded state also receives a lookahead sweep to evaluate its
defect; this does not advance the recorded 20-sweep trajectory.

This is a small NumPy implementation of one timestep's nonlinear solve. Dense global assembly
and derivative tracking favor inspection over speed. It is not a real-time implementation,
GPU benchmark or multi-timestep simulator; it has no contact or friction code. The numeric
runs cover the scalar chain; the vector extension in the study is an analytic derivation.

## Outputs and checks

The script overwrites the adjacent CSV and JSON results. These are deterministic float64
experiments, not certified numerical bounds. No Lean or simulation dependency is added.
`results.csv` has one row per system/execution; `trajectories.csv` records all 21 states
(initial plus 20 sweeps) for the equal-mass, equal-stiffness 16-node subset.
An empty tolerance field means the target was not reached in 20 sweeps.
Root solves are independent full Newton solves with checked scaled residual below 1e-10.
Derivative checks use centered finite differences at non-root warm starts. The comparison
matrix column multiplies absolute derivative factors at the root, not a uniform box bound.
`max_energy_increase` refers to a block step or a simultaneous proper-color batch;
`max_residual_ratio` ignores denominators below 1e-12 to limit roundoff artifacts.

The analytic specification, parameter provenance, limitations, and decision are in
[the study](../../knowledge/mathematics/applicability-study.md) and
[the route decision](../../knowledge/project/applicability-decision.md).
