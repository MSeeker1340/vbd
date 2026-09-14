# Applicability diagnostics

Run from any directory with Python 3.11+ and NumPy 2.4.3:

```sh
uv venv /tmp/vbd-applicability-venv
uv pip install --python /tmp/vbd-applicability-venv/bin/python numpy==2.4.3
/tmp/vbd-applicability-venv/bin/python experiments/applicability/study.py
```

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
