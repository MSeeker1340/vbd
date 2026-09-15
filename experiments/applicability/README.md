# VBD applicability experiment

A small Python module for one timestep's nonlinear scalar spring-chain solve. It executes
actual full-step VBD visits and computes derivative diagnostics alongside them. It is an
experiment, with dense assembly for inspection, rather than a simulation library or performance
benchmark. The [mathematical article](../../knowledge/mathematics/axial-spring-contraction.md)
defines the model and the [decision record](../../knowledge/project/applicability-decision.md)
explains the fixed study grid.

## Run with uv

From the repository root:

```sh
uv run --locked python -m experiments.applicability.study
```

`uv` uses the repository-root `pyproject.toml` and `uv.lock`, creating a shared root `.venv`
for Python experiments and scripts. It installs the locked dependency versions. Python 3.11 or newer
is required. The default is a quick 12-case grid. Results go to
`experiments/applicability/runs/latest/`, which is ignored by Git. A rerun replaces the named
outputs in that directory. Run these commands from the repository root.

Select a custom experiment:

```sh
uv run --locked python -m experiments.applicability.study \
  --n 8 32 --alpha 0.1 0.25 1 --eta 1 --mode serial color \
  --mass-ratio 1 1000 --sweeps 30 --tolerance 1e-7 --output experiments/applicability/runs/custom
```

Reproduce the 336-case study in a separate output directory:

```sh
uv run --locked python -m experiments.applicability.study \
  --preset study --output experiments/applicability/runs/study
```

Maintainers regenerate the checked-in baseline with
`--preset study --output experiments/applicability` from the repository root. This also replaces
the checked-in report and plot. Add `--help` to the module command for all options.

## Parameters

Each list-valued option replaces one preset axis; the experiment takes their Cartesian product.

| Option | Meaning |
|---|---|
| `--preset quick` / `--preset study` | Small inspection grid / full applicability grid |
| `--n` | Vertex counts, each at least two |
| `--alpha` | Positive normalized stiffness `h² k_max / m_min` |
| `--eta` | Nonnegative quartic hardening coefficient; zero gives the quadratic baseline |
| `--mass-ratio`, `--stiffness-ratio` | Alternating contrasts, at least one |
| `--mode serial color` | Serial visits or even/odd snapshot batches |
| `--sweeps`, `--tolerance` | Iteration budget and scaled physical-residual target |
| `--amplitude`, `--radius` | Predictor amplitude `Y` and certificate box radius `B`, with `0 ≤ Y ≤ B` |
| `--threshold` | Nonnegative normalized scalar Hessian skip threshold |
| `--output` | Output path relative to the current working directory (repository root in these commands) |
| `--table-limit` | Terminal row limit; zero prints all cases |
| `--plot-cases`, `--no-plots` | Number of representative cases (1–12), or disable plots |

An ineffective certificate or missed tolerance is a reported outcome, not a program failure.
Malformed arguments and unsuccessful reference solves produce a nonzero exit status.
CLI settings outside the article's parameter range do not broaden its accepted theorem.

## Read the outputs

The terminal prints a compact table; [report.md](report.md) contains the full table and
[convergence.png](convergence.png) plots. The plot reserves up to two lines for cases whose analytic bound meets the budget,
then fills the remaining slots with the largest terminal residuals. Labels give case IDs and
parameters; dotted residual curves show the corresponding uniform bounds. Four panels distinguish physical residual,
state error, sweep defect and objective. Logarithmic panels floor values at `1e-18` for display
only; CSV values are unmodified.

`results.csv` has one row per parameter/execution case. `rho`, `norm_inf`, and `norm_2` are
root-local sweep-derivative diagnostics; comparison columns multiply absolute local derivative
factors. `q_bound` is the uniform box candidate. `certificate_valid` additionally checks
intermediate-state invariance and the skip branch. `bound_final` appears only when all these
conditions hold, and need not meet the requested tolerance. `first_tolerance` is the first
observed successful sweep; an empty value means no hit within the budget.

`trajectories.csv` records every state, including sweep zero, for every case, with complete
parameter keys and a uniform residual envelope when valid. `summary.json` records the resolved
grid, settings, dependency versions, and aggregate counts. All results use float64 arithmetic;
they are not interval proofs. At a skip-branch boundary, derivative diagnostics describe the
executed branch only and do not establish differentiability across that boundary.

Each actual visit recomputes forces and Hessians from the current state and performs
`x_i -= f_i / H_ii` when the threshold permits it. Serial writes affect subsequent visits;
proper-color members read a shared snapshot. The trajectory starts from the inertia predictor,
not a reference root. A separate full Newton solve supplies that root for state-error measurement
and local matrix analysis. The terminal state gets a lookahead sweep only to measure its defect;
progress/increase statistics count transitions within the requested budget.

The checked-in study's “within six sweeps” is a measured tolerance hit over its 192 supported
cases; the analytic 20-sweep guarantee is a distinct neighborhood bound. The module includes
no contact/friction, vector model, GPU execution or multi-timestep loop.

## Checks

```sh
uv run --locked python -m unittest discover -s experiments/applicability/tests -v
```

The focused checks compare quadratic sweeps with independently constructed Gauss–Seidel
matrices, check nonlinear derivatives by finite differences, verify exact certificate arithmetic,
and exercise CLI validation, custom output and skip behavior. NumPy and Matplotlib are shared Python
script dependencies; no Lean dependency or general-purpose solver infrastructure is added.
