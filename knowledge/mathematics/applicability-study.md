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
v = 2α,
S = v(1+12ηB²),
P = B+Y+2Bv(1+4ηB²),
c = S/(1+S),
t = 24ηBvP/(1+v)²,
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
`Σ w_e/(a_i+Σ w_e) ≤ c`; its diagonal is zero. For the variation term put `v_i = Σ_j b_ij/a_i ≤ v`. Then
`D_i ≥ a_i(1+v_i)`, `|f_i| ≤ a_i[B+Y+2Bv_i(1+4ηB²)]`, and
`Σ_j |∂_j D_i| ≤ 24ηB a_i v_i`.
The remaining row sum is at most
`24ηB v_i[B+Y+2Bv_i(1+4ηB²)]/(1+v_i)² ≤ t`.
The last inequality uses monotonicity: for `p=B+Y=0.15` and
`r=2B(1+4ηB²)≥0.2`, the derivative of `v(p+rv)/(1+v)²` has numerator
`p+(2r-p)v≥0`. Both factors of the local inverse are retained in this estimate.
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
q ≤ 0.494442 < 0.512,    L_F ≤ 2.12,
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

For `α ≤ 0.2`, `η ≤ 1`, `θ ≤ 0.804 < 1`: quantitative residual reduction and strict
qualitative progress both hold at every non-root in `C`, with root preservation already proved.
At `α=0.25`, this estimate is `1.0483`, so it establishes neither strict residual progress nor
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

# Reuse beyond the chain

The chain is the first end-to-end instance of a general block-update theory. The reusable
result takes a mechanical residual, local solve operators, an execution order, an invariant
region, and quantitative bounds as inputs. Its output is a finite-sweep guarantee. The chain
supplies concrete witnesses for those inputs. The scalar spring law, degree two, predictor
construction, and numerical constants belong to that instance.

| Layer | Reusable result | What a richer model must supply |
|---|---|---|
| P1 | Basis-free IE energy, gradient and Hessian identities | Potential and mass operator; a residual extension for forces outside that potential |
| P2 | Heterogeneous block writes, composition, snapshot merging and block operators | Vertex block spaces and the actual local update |
| P3 | Contraction, invariant-set and iteration bounds | A complete invariant region and a contraction constant |
| P4 | Finite-support interactions and proper-color commutation | Interaction supports, including live contact dependencies |
| P5 | State convergence and quantitative residual transport | Root consistency and a Lipschitz bound for the chosen physical residual |
| P6 | Ordered derivative comparison in a block maximum norm | Local inverse, coupling and derivative-variation bounds |
| P7 | Regular block-Newton consistency and sweep linearization | The concrete force law, solve matrix, branch conditions and execution semantics |

The generic declarations quantify over block dimensions and interaction supports. Chain-specific
lemmas instantiate them at the application boundary. The [module map](/formalization/module-map.md)
requires that separation as an acceptance condition for the upcoming formalization.

## General block estimate

Let `R_i(x)` be the residual on a finite-dimensional block and `K_i(x)` the invertible matrix
actually used for its local solve. The changed coordinate is `x_i - K_i(x)⁻¹ R_i(x)`.
For a perturbation in block `j`, its derivative is

```
(DU_i)_ij[v] = δ_ij v - K_i⁻¹ (D_j R_i)[v]
              + K_i⁻¹ ((D_j K_i)[v]) K_i⁻¹ R_i.
```

Here `δ_ij v` means identity on the diagonal and zero otherwise. With an exact Newton block,
`K_i = D_i R_i`, the first two diagonal terms cancel. A sufficient changed-row bound is

```
Σ_(j≠i) ‖K_i⁻¹ D_j R_i‖
  + ‖K_i⁻¹‖ ‖K_i⁻¹ R_i‖ Σ_j ‖D_j K_i‖ ≤ q < 1.
```

All norms are operator or block-vector norms; the state norm is `max_i ‖x_i‖`.
Uniform bounds and preservation of the region at every intermediate visit let the existing
row-composition argument apply in any block dimension. For an approximate solve matrix, add
`‖I-K_i⁻¹ D_i R_i‖` to the row bound. This term can survive even at a root: the Gauss-Seidel
identification requires exact derivative blocks. Invertibility and once-per-block execution
still give root consistency for either choice when the update uses the stated residual.
These are mathematical interfaces and derivations, not additional implemented Lean results.

## A quantified vector extension

One explicit extension takes `u_i ∈ ℝ^d` on a finite simple graph and uses

```
G(u) = Σ_i a_i ‖u_i-y_i‖²/2
       + Σ_edges b_e [‖u_i-u_j‖²/2 + η ‖u_i-u_j‖⁴/4].
```

This is an isotropic displacement-difference spring model. It couples vector coordinates through
the quartic term; it is not merely independent copies of the scalar quartic solve.
It is also distinct from a geometric nonzero-rest-length spring energy based on actual vertex
separation. Set `‖y_i‖ ≤ Y`, `‖u_i‖ ≤ B`, and
`z = max_i Σ_(e incident i) b_e/a_i`. In physical units,
`z = max_i h² Σ_(e incident i) k_e/m_i`; a maximum-degree bound `Δ` gives
`z ≤ Δ h² k_max/m_min`. Thus connectivity, not just spatial dimension, affects coverage.

For an edge displacement `d_e`, its Hessian is
`b_e[(1+η‖d_e‖²)I + 2η d_e d_eᵀ]`.
On the product of radius-`B` balls, its norm is at most `b_e(1+12ηB²)` and its
variation has norm at most `6b_e η ‖d_e‖ ‖δd_e‖`.
Consequently `K_i ≽ (a_i+Σ b_e)I` and the block estimate above gives

```
P(z) = B+Y+2Bz(1+4ηB²),
q_vec ≤ z(1+12ηB²)/(1+z) + 24ηB z P(z)/(1+z)².
```

These expressions increase with `z≥0` and `0≤η≤1` at the chosen `B,Y`.
Intermediate-state preservation follows by writing `K_i u_i - R_i` as
`a_i y_i + Σ b_e[(1+η‖d_e‖²)u_j + 2η d_e⟨d_e,u_i⟩]`.
Its norm is at most `a_iY+Σ b_e(B+12ηB³)`. Hence
`12ηB³ z ≤ B-Y` suffices to preserve the product ball at each visit.
Strong convexity gives a unique root; taking the inner product of its equation with a
largest-norm root coordinate shows `max_i ‖u_i*‖ ≤ Y`.

At `B=0.1`, `Y=0.05`, `η≤1`, and `z≤0.5`, these estimates give
`q_vec ≤ 0.5088 < 0.512`, invariance, and Lipschitz constant
`1+2z(1+12ηB²) ≤ 2.12` for the scaled vector residual
`r_IE(u)=max_i ‖R_i(u)‖/a_i`. The same 20-sweep state and residual bounds therefore follow
analytically for `d=2`, `d=3`, or any finite `d`, with serial or proper-color execution.
This vector extension has an explicit mathematical certificate; the checked-in numerical
trajectories and the first planned Lean instance remain the scalar chain.
It demonstrates reuse of the argument without claiming coverage of general 3D materials.

## Geometric elasticity and higher-arity elements

For geometric springs or triangle/tetrahedron energies, interaction support, coloring, the
block derivative identity, and comparison composition still apply. The model must supply
bounds for local inverse matrices, mixed derivatives, and their variation on a deformation
region. Scalar division becomes a 2×2 or 3×3 local solve; scalar signs and the chain maximum
principle are not generic tools for matrix-valued elasticity. A root can instead be supplied,
or obtained from a complete invariant-region contraction and independent consistency.
Quantitative residual transport requires its own Lipschitz constant; stepwise residual progress
additionally needs an error-to-residual lower bound or a direct residual-map estimate.

A useful template is `H_ii ≽ (m_i/h²-κ_i)I` when local potential curvature is bounded below
by `-κ_i I`. Positive `m_i/h²-κ_i` gives an inverse bound, but contraction also requires
bounds on the mixed blocks. Near collapsed elements, those variation bounds may become
unbounded. Each accepted material therefore needs a specified deformation region, predictor
membership, timestep range and sweep budget. Increasing dimension alone does not establish
these physical hypotheses. The scalar threshold likewise becomes a dimension-dependent
determinant condition (or the actual implementation's singularity test) and needs explicit units.

## Contact, damping and friction

A smooth additional force law can use the same residual/update interface after its contribution
to the inverse, mixed derivative, variation, and residual-scaling bounds is included. A linear
viscous damping term, for example, becomes position-dependent through
`v_new=(x_new-x_old)/h`; a symmetric positive-semidefinite damping matrix contributes `C/h`
to the residual derivative. Off-diagonal damping can also increase coupling.

Contact changes both analysis and scheduling. On a region with a fixed smooth contact branch,
its derivative bounds can enter the same comparison matrices. Crossing activation boundaries
requires a direct Lipschitz or suitable piecewise argument rather than a smooth derivative
assumption across the boundary. A live contact can invalidate a material coloring; the actual
buffered map then needs BC-04. Lagged contact data and changing schedules require either an
augmented state or an explicitly varying-map theorem, rather than treating them as a fixed
function of positions alone.

The [VBD paper, §§3.5–3.6](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
uses regularized friction and an approximate local friction derivative, and omits differentiation
through contact normals. Accordingly, analysis must specify which quantities are frozen and
use the derivative of the **actual update map**. The general `K_i` formula above exposes both
the derivative mismatch and the derivatives of changing coefficients. A lagged friction
potential can support a conditional fixed-data theorem; identifying its root with the intended
fully coupled friction equation is a separate obligation.

Ideal sticking/sliding laws can require a nonsmooth inclusion or complementarity solution
concept. The existing energy-gradient identity cannot be assumed to represent such a law.
Block-update algebra and metric contraction remain reusable, while the smooth derivative bridge
and the IE root interpretation may need new results. CT-05 can handle bounded execution errors
only with a proved error bound and region preservation; it does not by itself turn friction
into a small perturbation or guarantee convergence to the same physical root.

## Applicability boundary

The supported chain and vector estimates establish a reusable route for a coupled smooth
mechanical family with explicit constants. Applicability to geometric 3D elasticity, dynamic
contact, and friction remains an open physical assessment. A model extension is accepted only
when its actual update and residual, invariant region, relevant initial states, and parameter
and accuracy budgets discharge the generic hypotheses. The first chain theorem is a milestone
in that program, not the final extent of the formal library or evidence that all VBD workloads
meet those hypotheses.

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
