---
type: Mathematical Specification
title: Applicability of VBD to Coupled Axial Spring Chains
description: Gives analytic neighborhood and residual certificates, reproducible diagnostics, and coverage limits for quadratic and nonlinear axial chains.
tags: [applicability, vbd, contraction, residual, springs]
timestamp: 2026-09-14T00:00:00Z
---

# Family and evaluation contract (AP-01)

The selected family consists of `n ≥ 2` masses constrained to a straight rail, with adjacent
elastic springs and free endpoints. Write physical positions as rest positions plus `L u_i`.
Rest spacing is `L = 0.1 m`; displacement differences are spring extensions divided by `L`.
The incremental energy, divided by `m_min L²/h²`, is

```
G(u) = Σ_i a_i (u_i-y_i)²/2 + Σ_edges b_e [d_e²/2 + η d_e⁴/4],
a_i = m_i/m_min ≥ 1,   b_e = h² k_e/m_min > 0,   d_e = u_i-u_j.
```

`η = 0` is the coupled quadratic baseline; `0 < η ≤ 1` is a hardening nonlinear spring.
The quartic law is a chosen constitutive test model, not a claim to reproduce the paper's
Neo-Hookean materials. These are scalar vertex blocks, a constrained mechanical specialization
of the full block-Newton rule. There is no damping, contact, friction, acceleration of iterations,
or line search. Locality is the path graph; positive curvature follows separately from this law.

The physical calibration uses `m_min = 0.001 kg`, `k_max` from `1` to `10⁴ N/m`, timesteps
from `10⁻⁴` to `0.04 s`, and mass ratios from `1` to `1000`. Spring stiffness contrasts extend
to `10⁴`. These are explicit synthetic engineering ranges: stiffness has force/length units and
`√(m_min/k_max)` is the single-spring inertial timescale. They are not measured material data.
The primary paper motivates spring systems, high mass ratios, stiffness contrasts, and inertia
initialization, but supplies no calibration for this quartic law; see its [curated reference](/references/vbd-paper.md).
The certificate therefore establishes applicability to this mechanical family, not to arbitrary
production meshes or the paper's large-deformation benchmarks.

The evaluation contract fixes `Y = 0.05`, the box radius `B = 0.1`, tolerance `10⁻⁶`, and a
budget of **20 sweeps**. The predictor is the physical inertia position relative to rest,
`y = (x_old + h v_old + h² a_ext - x_rest)/L`, with `‖y‖∞ ≤ Y`.
The warm start is `u⁰ = y`; it includes any previous state, velocity and external acceleration
satisfying that explicit predictor condition, without knowledge of the new solution. It covers
5 mm predictor displacement, with a 10 mm intermediate-state box. The chosen tolerance means
0.1 micrometers for the corresponding displacement scale; this is a research accuracy target,
not an empirically established perceptual requirement or wall-clock budget.

The diagnostic grid fixes `n ∈ {4,16,64}`, `α = h² k_max/m_min ∈ {0.01,0.1,0.2,0.25,1,10,100}`,
`η ∈ {0,1}`, mass ratios `{1,1000}`, and stiffness contrasts `{1,10000}`. Alternating heavy
masses and alternating stiff/soft edges expose both contrasts. Every grid value has a physical
realization in the calibration ranges (for example `k_max = 100 N/m` and
`h = √(α m_min/k_max)`). The deterministic predictor is `y_i = Y cos(1.7 i)`.
All parameter choices and targets are constants in the diagnostic artifact, independent of its
measured convergence. A separate large-amplitude stress example uses `η = 100`, `Y = 1`.

# Actual maps and observables

Let `f = ∇G`, `H = Df`, and `D_i = H_ii`. A visit replaces only coordinate `i` by
`u_i - f_i(u)/D_i(u)` when `|D_i| > ε`; otherwise it leaves the coordinate unchanged.
The scalar determinant threshold is `ε = 10⁻¹²` in these normalized units. This is an explicit
study threshold, not an asserted numerical value from the paper. In physical scalar units it
corresponds to `10⁻¹² m_min/h² N/m`. The regular family has `D_i ≥ a_i ≥ 1`, hence no skips.

Serial execution visits `0,…,n-1` once each. Proper-color execution reads one snapshot for all
even vertices, writes that batch, then does the same for all odd vertices. Same-color vertices
share no edge, so those updates commute and equal any serial ordering within their batch.
Every coordinate is visited exactly once per complete sweep. Repeated-coordinate schedules
require a separate consistency argument; disjoint writes alone do not prove commutation.

The four observables are distinct:

* State distance: `‖u-u*‖∞`, where the analytic root is unique and a numerical root is independently solved.
* Physical IE residual: `r_IE(u) = max_i |f_i(u)|/a_i = max_i h² |F_IE,i(x)|/(m_i L)`.
  This is a weighted maximum norm on physical force, with fixed per-system scaling. A tolerance
  of `10⁻⁶` implies force imbalance `≤ m_i L 10⁻⁶/h²` on every mass.
* Sweep defect: `r_T(u) = ‖T(u)-u‖∞`.
* Objective: the dimensionless `G(u)` above.

# Consistency and existence independent of contraction

The Hessian is `diag(a) +` a weighted path Laplacian with positive edge weights
`w_e = b_e(1+3η d_e²)`. Thus `G` is coercive and strongly convex and has a unique root.
At a maximum coordinate of a root, every outgoing elastic force is nonnegative, so
`u_i* ≤ max y`; the minimum argument gives `‖u*‖∞ ≤ Y`.
These convexity conclusions are properties of this family, not assumptions of the generic IE foundation.

A root is preserved by every update. Conversely, if a complete skip-free sweep fixes its input,
each once-written coordinate must have received zero increment. Induction through the visits
then shows that every intermediate state equals the input and every component of `f` is zero.
The same reasoning applies to proper-color batches. This argument uses coverage and the
nonsingular branch, independently of any metric estimate.

Skipping can create spurious fixed points: take two masses, `a_i=b=1`, `η=0`, `y=(1,-1)`,
`u=(0,0)` and `ε=2`. Both diagonal entries equal `2`, both visits skip, and the nonzero residual
is frozen. This exact example explains why the quantitative scope explicitly certifies the branch.

# Uniform nonlinear certificate (AP-02)

All following inequalities are analytic real-arithmetic derivations; they remain Lean proof
obligations. Put `C = {u : ‖u‖∞ ≤ B}`, and assume `b_e ≤ α`, `0 ≤ η ≤ 1`.
Each vertex has degree at most two. On `C`, `|d_e| ≤ 2B`. Define

```
S = 2α(1+12ηB²),
P = B+Y+4αB(1+4ηB²),
c = S/(1+S),
t = 24αηBP,
q = c+t,
L_F = 1+4α(1+12ηB²).
```

## Intermediate-state invariance

The updated coordinate has numerator
`a_i y_i + Σ_j b_ij [u_j + η d_ij²(2u_i+u_j)]` and denominator
`a_i + Σ_j b_ij(1+3η d_ij²)`.
Its absolute value is at most
`[a_i Y + Σ_j b_ij(B+12ηB³)]/[a_i+Σ_j b_ij]`.
Consequently every individual update preserves `C` whenever
`24αηB³ ≤ B-Y`. Proper-color batches preserve it coordinatewise too.
For `α ≤ 1/4`, `η ≤ 1`, the left side is at most `0.006`, below `0.05`.
This controls all intermediate states before using the chain rule; it avoids assuming that
invariance of a complete sweep suffices to bound its factors.

## Derivative and comparison matrices

The changed row of the derivative is exactly

```
(DU_i)_ij = δ_ij - H_ij/D_i + f_i (∂_j D_i)/D_i².
```

The last term vanishes only at a root. At a root the ordered product is the corresponding
Gauss-Seidel error matrix: writing `H = D + L + R` in the visit order gives
`DT(u*) = -(D+L)⁻¹ R`. Proper colors use their color-contiguous order.
This is a linearization at the root, not a formula for the full nonlinear map.

For the uniform changed-row bound, the off-diagonal first term sums to
`Σ w_e/(a_i+Σ w_e) ≤ c`; its diagonal is zero. Also
`|f_i|/D_i ≤ P` and `Σ_j |∂_j D_i| ≤ 24αηB`.
Since `D_i ≥ 1`, the remaining row sum is at most `t`.
All unchanged rows are identity rows. Nonnegative comparison matrices have these unchanged
identity rows and changed rows summing to at most `q`.

When `q < 1`, processing each row exactly once makes the full comparison product's row sums
at most `q`: before a visit every current error component is bounded by the initial maximum;
a visited row becomes bounded by `q` times that maximum and stays fixed thereafter.
The argument applies to serial order and proper-color snapshots. Convexity of `C`, the chain
rule and the derivative bound give `‖T(u)-T(v)‖∞ ≤ q ‖u-v‖∞` throughout `C`.
Completeness, invariance and the root bound give the state-contraction route.

## Radius, timestep and budget

For `α ≤ 1/4` and `η ≤ 1`,

```
q ≤ 0.511375 < 0.512,    L_F ≤ 2.12,
h ≤ 0.5 √(m_min/k_max),
‖T^s(y)-u*‖∞ ≤ 0.1 (0.512)^s,
r_IE(T^s(y)) ≤ 0.212 (0.512)^s.
```

The safe rounded residual bound at 20 sweeps is below `3.25 × 10⁻⁷`, meeting `10⁻⁶`.
The invariant neighborhood is the explicit box `C`; it contains a radius-`0.05` maximum-norm
ball around the root, and the predictor belongs to `C` without a root solve. At the chosen
mass, stiffnesses `1`, `100`, `10000 N/m` allow timesteps up to approximately `15.81`, `1.581`,
`0.1581 ms`, respectively. This is a substantive but inertia-dominated range: at the endpoint
an interior vertex has elastic diagonal up to `0.56` against minimum inertia `1`.
The full sweep box theorem covers all starts in `C`; the stated `0.1` initial-error budget uses
the predictor restriction (general box starts use `B+Y = 0.15`).

## Physical-residual routes

Integrating the Hessian along a segment gives `r_IE(u) ≤ L_F ‖u-u*‖∞` on `C`.
At a coordinate maximizing the absolute error, the signed Laplacian contribution to
`f(u)-f(u*)` is nonnegative. Hence `‖u-u*‖∞ ≤ r_IE(u)` even without contraction.
Together these yield the genuine stepwise estimate

```
r_IE(T(u)) ≤ θ r_IE(u),    θ = L_F q.
```

For `α ≤ 0.2`, `η ≤ 1`, `θ ≤ 0.799 < 1`: quantitative residual reduction and strict
qualitative progress both hold at every non-root in `C`, with root preservation already proved.
At `α=0.25`, this estimate is `1.0842`, so it establishes neither strict residual progress nor
stepwise reduction there. State contraction still gives the 20-sweep residual bound above.
The failure of this sufficient bound is not proof that residual progress fails at that endpoint.
Sweep-defect contraction follows from state contraction but does not replace these physical-force arguments.

# Reproducible numerical assessment

Run [the diagnostic script](../../experiments/applicability/study.py) using
[its environment instructions](../../experiments/applicability/README.md).
[Full results](../../experiments/applicability/results.csv),
[trajectories](../../experiments/applicability/trajectories.csv), and
[summary](../../experiments/applicability/summary.json) are checked-in artifacts.
The script evaluates 336 cases; all 192 cases with `α ≤ 0.25` reach tolerance in at most six
sweeps. The worst 20-sweep residual there is about `1.22 × 10⁻¹⁷` (roundoff scale).
Finite-difference checks of the nonlinear sweep derivative at non-root predictors have maximum
entry discrepancy below `8 × 10⁻¹²`. These are floating-point checks, not proofs of a uniform bound.

For `n=16`, equal masses and stiffnesses, and `η=1`:

| α | Order | Root spectral radius | Root ∞ norm | Root 2 norm | Sweeps to tolerance |
|---|---|---|---|---|---|
| 0.25 | serial | 0.10825 | 0.20094 | 0.21061 | 6 |
| 0.25 | proper color | 0.10825 | 0.33420 | 0.34660 | 4 |
| 1 | serial | 0.43450 | 0.50043 | 0.55950 | 11 |
| 1 | proper color | 0.43450 | 0.66695 | 0.79445 | 11 |
| 10 | serial | 0.90192 | 0.90910 | 1.09641 | >20 |
| 10 | proper color | 0.90192 | 0.95238 | 1.36117 | >20 |
| 100 | serial | 0.98943 | 0.99010 | 1.21062 | >20 |
| 100 | proper color | 0.98943 | 0.99502 | 1.47277 | >20 |

An exact residual-progress counterexample in the quadratic stress range uses two masses,
`a_i=1`, `b=10`, `η=0`, `y=0`, and `u=(r,r)` with `0<r≤B`. The initial residual is `r`.
A serial sweep yields `(10r/11,100r/121)` and residual `210r/121 > r`, although the
quadratic sweep is a global maximum-norm contraction. Thus neither qualitative nor uniform
factor-below-one physical-residual reduction holds across the full stress range.

Five grid trajectories have a physical-residual increase above roundoff. For example the
four-node quadratic serial case at `α=10`, mass ratio `1000`, and equal stiffness has a sampled
successive residual ratio about `1.400`. Both residual routes over the entire stress grid are
therefore incompatible with those numerical observations. The CSV includes the scaled residual
map's derivative norm `‖A⁻¹ H DT H⁻¹ A‖∞` at the root as a distinct local diagnostic.

## Conservatism and alternatives

At the root all changed derivative rows are nonnegative for this spring law, so multiplying
absolute factors introduces **no** cancellation loss: the recorded comparison norms equal the
actual sweep norms. Away from the root, the `f_i ∂D_i` terms can have either sign; triangle
inequalities and independent maxima introduce loss. At the endpoint the uniform bound `0.512`
is appreciably larger than both observed root ∞ norms. Only the former certifies the whole box.

The maximum-norm estimate is independent of `n` for degree-two chains and depends on the minimum
mass and maximum spring stiffness. High mass and low stiffness only improve its inequalities;
it can be conservative for alternating contrasts. In the native unnormalized Euclidean norm,
`‖v‖∞ ≤ ‖v‖₂ ≤ √n ‖v‖∞`. Naively converting a one-sweep certificate gives `√n q`, already
above one at `n=4` for the nonlinear endpoint. Converting the final state-error bound instead
costs only `√n`; the per-vertex residual target is unchanged. The experiments include all three
sizes and do not establish mesh-refinement-independent coverage for graphs of increasing degree.

A weighted maximum norm using positive comparison-vector weights can improve a root estimate
when `Cw ≤ qw`; a spectral radius alone does not provide a uniform nonlinear certificate.
The unweighted norm already passes the stated budget. For the quadratic family the sharper
bound `q₀=2α/(1+2α)` holds globally, and SPD Gauss-Seidel also admits an energy-norm analysis.
At `α=10`, even `q₀≈0.9524` is too slow for this conservative 20-sweep budget; the trajectories
also miss it. Several-sweep contraction or an adapted norm may handle a one-step 2-norm above
one, but cannot establish a 20-sweep tolerance contradicted by the observed trajectory.
They remain options for a revised budget or stronger initial-state restrictions in the stiff
regime. Any nonlinear extension must retain the intermediate-state box proof.

# Objective-increase coverage

The same quartic family has an exact unsafeguarded objective-increasing step outside the
certified range: `n=2`, `a_0=a_1=b=1`, `η=100`, `y=(1,-1)`, `u=(0,0)`.
The first visit has `D_0=2`, `f_0=-1`, and gives `(1/2,0)`.
Direct rational evaluation gives `G(0,0)=1` and `G(1/2,0)=37/16`.
The script verifies that arithmetic exactly using fractions. This is an analytic example of
non-descent in the selected constitutive family, not a certified convergent non-descent example.
Its start is outside `C` and its nonlinear parameter exceeds the quantitative scope.
No objective increase was observed in the supported grid; the accepted theorem claims no
coverage of objective-increasing trajectories, indefinite curvature, or large deformation.

The [AP-03 decision](/project/applicability-decision.md) selects the scoped quantitative
state-contraction route and records the remaining formal proof obligations.
