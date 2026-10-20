---
type: Project Roadmap
title: VBD Formalization Roadmap
description: Defines the current goal-first phase structure, theorem targets, dependencies, and acceptance gates.
tags: [roadmap, implicit-euler, block-operators, contraction, vbd]
timestamp: 2026-10-20T00:00:00Z
---

# Project scope

The project studies VBD in exact arithmetic, including finite-iteration state and residual errors. Floating-point rounding, errors from approximate local solves, and GPU implementation verification are outside its scope.

# Current phase status

| Phase | Status | Current boundary |
|---|---|---|
| Phase 1 — implicit Euler mathematics | complete | `Vbd/Integrator/ImplicitEulerEnergy.lean` provides the basis-free objective, gradient, and Hessian identities |
| Phase 2 — block-state and update-operator algebra | complete | `Block/Basic`, `Block/Update`, and `Block/Operator` implement BS-01–BS-06 |
| Phase 3 — contractive fixed-point iteration | complete | CT-01–CT-04 are implemented |
| Applicability study — AP-01–AP-03 | complete | Quantitative proceed for nonlinear axial chains in the maximum norm with serial and proper-color execution |
| Phase 4 — finite-support potential components and coloring | complete | `Integrator/LocalPotential.lean` provides component locality, exact cancellation, and support-to-Mathlib-graph/coloring bridges |
| Phase 5 — implicit-Euler fixed-point goals | complete | `Integrator/FixedPoint.lean` supplies unbiased fixed-point identification, finite state error, and residual transport |
| Phase 6 — contraction of composed updates | complete | `Block/Contraction.lean` supplies comparison composition, commuting batches, and maximum-norm sweep certificates; BC-04 remains deferred |
| Phase 7 — production VBD synthesis | planned | combines the bridge phases to analyze the actual serial and colored VBD sweep |

The [backlog](/project/backlog.md) is authoritative for item-level status and acceptance criteria.

The accepted [applicability decision](./applicability-decision.md) selects the
[axial-chain certificate](/mathematics/axial-spring-contraction.md): `h² k_max/m_min ≤ 1/4`,
`0 ≤ η ≤ 1`, the stated predictor box, and a physical residual below `10⁻⁶` in 20 sweeps.
The first theorem uses maximum-norm state contraction and static proper colors. Hybrid
execution with same-color coupling requires a further applicability decision.

The chain is the first worked instance of a reusable theorem interface. The generic foundation,
bridge and block-Newton results remain parameterized by block dimension, potential-component support
and physical bound data. The [adaptation analysis](/mathematics/axial-spring-contraction.md#reuse-beyond-the-chain)
gives a quantified vector extension and explicit obligations for geometric elasticity, contact
and friction. The first-family gate is complete; applicability to general production models
remains open and requires further model-specific evidence.

# Goal and dependency graph

The production-facing target is a quantitative theorem for the actual unsafeguarded VBD sweep:
on an explicitly described neighborhood of an implicit-Euler solution, the serial or colored sweep
is contractive with factor `q < 1`, giving a finite-sweep error bound. The main route uses direct
operator estimates; energy-descent results form a secondary route for compatible solver variants.

```text
P1 implicit Euler          P2 block algebra          P3 contraction theory
       |                         |                          |
       +----------- P4 ---------+                          |
       |                                                    |
       +------------------- P5 -----------------------------+
                                 |                          |
                                 +----------- P6 -----------+
                                              |
                                  P7 production VBD synthesis
```

Phases 1, 2, and 3 are independent foundations. Phases 4, 5, and 6 are pairwise bridges. Phase 7
is the first layer allowed to depend on the complete chain.

# Applicability gate and work order

The research target is a conditional, quantitative convergence theorem for a meaningful family
of actual VBD sweeps. Its hypotheses must be connected to physical parameters and relevant
initial states. The initial guarantee concerns one timestep's nonlinear solve; simulation
stability across timesteps and convergence from arbitrary initial configurations require
separate results.

Work proceeds through the thin Phase 3 core CT-01–CT-03, then the bounded applicability study
AP-01–AP-03, before CT-04 or Phase 4–7 formalization. The study anticipates production
mathematics through derivations and reproducible diagnostic experiments. It introduces no
cross-foundation Lean imports and requires no general simulation infrastructure.

1. **AP-01 — Select the test family.** Specify a parameterized mechanical family with nonzero
   cross-block coupling, a coupled quadratic baseline, and a nonlinear case. Define the actual
   full-step serial sweep, skip threshold, and at least one proper-color execution. Document
   parameter ranges and their physical or published provenance, warm-start construction, and
   target error and sweep budgets before assessing the certificate. Define the physical residual
   `r_IE(x) = ‖R_IE(x)‖`, its norm and scaling, and the sweep defect `r_T(x) = d(x,T(x))`
   separately. Include timestep, stiffness,
   mass-ratio, and coupling variation sufficient to expose restrictive assumptions.
2. **AP-02 — Compare the certificates.** Derive the actual sweep linearization and candidate
   neighborhood estimates. Compare observed iteration behavior, the sweep derivative's spectral
   radius and operator norms, and the proposed comparison-matrix bounds. Assess the certified
   timestep range, invariant radius, warm-start membership, and predicted iteration budget.
   Evaluate loss from absolute-value bounds and norm conversions, including dependence on system
   size. Evaluate direct physical-residual progress on the same systems, parameter ranges,
   and initial states using the guarantee levels below. Assess fixed-point/root consistency
   independently of contraction, including the effect of skipped blocks and execution semantics.
   Track state distance where a root is available, physical residual, sweep defect, and objective
   separately. Test objective-increasing updates as a distinct coverage question. Clearly separate
   analytic guarantees from sampled or floating-point evidence: a derivative at one point or
   successful trajectories do not certify uniform contraction on a neighborhood.
3. **AP-03 — Decide the theorem route.** Compare the coverage and proof obligations of state
   contraction with consistency, qualitative physical-residual progress, and quantitative
   physical-residual reduction. Record the selected family, guarantee level, coverage,
   remaining proof obligations, norm, and execution scope. A quantitative proceed decision
   requires analytic estimates supporting a nonempty parameter range justified by AP-01,
   relevant warm starts, and the stated accuracy budget. A qualitative proceed decision may
   authorize a scoped residual-progress theorem with explicit covered initial states and region;
   it does not satisfy the quantitative end-to-end acceptance gate. If the certificate is
   ineffective, assess a better norm, sharper bounds,
   or contraction over several sweeps, including intermediate-iterate control. If these remain
   ineffective, revise the target or convergence tool before extending the formalization.

The evaluation distinguishes these guarantee levels:

| Route | Analytic target on the stated invariant region | Supported conclusion |
|---|---|---|
| State contraction and consistency | Uniform `q < 1`, completeness and nonemptiness, and fixed-point/root consistency | Unique fixed point in the region, geometric state convergence, and physical-residual convergence under continuity; residual error bounds additionally use quantitative regularity |
| Qualitative physical-residual progress | `r_IE(T(x)) < r_IE(x)` at every non-root, with preservation of zero residual | Every further sweep improves the physical residual until it is zero; this alone supplies neither an arbitrary-accuracy guarantee nor an iteration budget |
| Quantitative physical-residual reduction | `r_IE(T(x)) ≤ θ r_IE(x)` with uniform `0 ≤ θ < 1`, or an explicit decrease recurrence sufficient for the target tolerance | A proved finite-sweep physical-residual bound without requiring pairwise contraction of states; state convergence needs separate hypotheses |

Strict distance shrinking implies strict decrease of `r_T` away from fixed points. This is a
separate diagnostic guarantee; identifying its practical meaning requires a proved relationship
to `r_IE`. Bounds comparing two residuals do not automatically transfer stepwise monotonicity.
Contraction toward a true root can allow intermediate physical-residual increases while still
forcing that residual to vanish by continuity. Strict physical-residual decrease at every
non-root itself excludes spurious fixed points, although root preservation remains an obligation.

The Phase 4–7 theorem chain below specifies the state-contraction route. Selecting a residual
route or a qualitative milestone requires AP-03 to synchronize the downstream deliverables and
dependencies before implementing them. A useful qualitative result can be accepted as a scoped
milestone while the quantitative project target remains open.

AP-03 can be completed with either a proceed or revise conclusion. Dependent formalization
requires a proceed conclusion for its selected route; a revise conclusion leaves that work
gated until an updated assessment supports it. The assessment and its reproducible artifacts
belong with the relevant mathematics/reference concepts and scoped logs. Experimental results
guide theorem selection; Lean proofs discharge the accepted analytic obligations.

The applicability gate requires substantive coupling and a nonlinear family. An isolated
diagonal example, an unspecified sufficiently small timestep, or an unquantified neighborhood
does not establish practical coverage. Coverage of non-descent behavior requires a certified
example within the selected mechanical family where an actual update increases the objective.
If that coverage is unavailable, AP-03 must state the limitation and bound the theorem's claims.

# Phase 1 — Implicit Euler mathematics

Status: complete. Module: `Vbd/Integrator/ImplicitEulerEnergy.lean`.

Phase 1 supplies the incremental objective `G_IE`, its canonical gradient, and its Hessian:

$$
R_{IE}(x)=\nabla G_{IE}(x),
\qquad
DR_{IE}(x)=\frac{M}{h^2}+\nabla^2P(x).
$$

Its solution concept is stationarity of `G_IE`, equivalently a root of `R_IE`. Its scope consists of
the objective and its differential identities.

# Phase 2 — Block-state and update-operator algebra

Status: complete. Modules: `Vbd/Block/Basic.lean`, `Vbd/Block/Update.lean`, and
`Vbd/Block/Operator.lean`.

Reserve `X` for a total space, use `B : ι → Type*` for heterogeneous block spaces, and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Phase 2 develops the objective-independent algebra of block-indexed states and operators:

1. native block access, single-block injection, and replacement;
2. the write support of an operator as the set of block indices it can change, with containment
   characterizing supplied support bounds and union bounds for composition;
3. write-support bounds for finite compositions of operators and multi-block batches;
4. Mathlib’s composition and commutation laws, including reordering of commuting factors;
5. simultaneous merging for disjoint write supports and its equality with sequential composition
   for commuting families, giving the generic color-batch algebra;
6. continuous-linear block entries, finite assembly, and block-matrix arithmetic for linear update
   operators and derivatives.

Mathematically, the same block decomposition carries the Hilbert inner product of the
implicit-Euler formulation and its induced physical norm $\lVert\cdot\rVert_X$. The modeler also
specifies a calibrated norm on each whole block; these induce the finite block-product norms
$\lVert\cdot\rVert_p$. Phase 2 records this norm family before any contraction theorem chooses a
particular $p$; its update and support algebra remains norm-independent. The `PiLp 2` declaration
above is the current Lean representation, not a choice of every later analytic norm.

Write support contains exactly those block indices at which the operator changes some input
state. A write-support bound is any set containing that support. These bounds express preservation
across compositions and batches with arbitrary sets of affected blocks; reads may depend on the
entire state. Concrete block writes use `BlockSum.replace`, whose block access laws already
describe the preserved blocks. Block indices identify whole blocks, each with its own internal
degrees of freedom.

The phase vocabulary consists of block states, state-update operators, composition, simultaneous
merging, and continuous linear operators. Ordinary function composition and Mathlib’s monoid
algebra supply identity, associativity, and finite products. Concrete VBD update formulas, physical
independence proofs, and production serial or buffered execution enter through later bridge and
synthesis phases.
Algebraic and analytic assumptions remain local to the declarations that use them, and the core
results support infinite-dimensional blocks.

Acceptance gate: later modules can track sets of preserved blocks through compositions, merge disjoint writes into simultaneous batches, reduce commuting batches to
order-independent composition, and represent linear operators or derivatives by heterogeneous
block matrices. Simultaneous merging is available for noncommuting operators as well.

# Phase 3 — Contractive fixed-point iteration

Status: complete (CT-01–CT-04). Module: `Vbd/Dynamics/Contraction.lean`.

The [contractive iteration specification](/mathematics/contractive-fixed-point-iteration.md)
provides the mathematical interface. CT-01–CT-03 supply the initial API assessment, invariant-set
wrapper, and finite-iterate bound. The implemented metric-space interface also exposes convergence
to a supplied fixed point and the defect bound, with completeness required only for existence.
The derivative bridge serves the accepted maximum-norm route. The foundation remains
independent of VBD assumptions.

Reuse Mathlib's `ContractingWith` and Banach fixed-point results. Add the project-relevant
bridges that are absent or awkward at the call site:

1. contraction on a forward-invariant complete subset or closed ball;
2. explicit finite-iterate distance bounds;
3. derivative bounds on a convex neighborhood implying a Lipschitz contraction there;
4. local convergence to a known fixed point.

Use direct Lipschitz or operator-norm bounds first. A spectral-radius hypothesis enters through an
appropriate equivalent norm or an iterate theorem.

Acceptance gate: the results apply to an arbitrary self-map of a complete metric or normed space
using the generic dynamics layer and Mathlib.

# Phase 4 — Finite-support potential components and coloring

Status: complete. Module: `Vbd/Integrator/LocalPotential.lean`.

Dependencies: Phase 1 + Phase 2.

`LocalPotential` represents the potential as a finite sum of finite-support components and proves
exact cancellation for components disjoint from a block change. Its component-overlap graph uses
Mathlib's `SimpleGraph.fromRel`, while numbered proper colorings use `G.Coloring (Fin m)`. The
module proves common-support adjacency, support-wise injectivity of proper colorings, construction
of a coloring from that condition, restriction to smaller support families, and the exact criterion
for extending a fixed coloring. Compiled two-block and three-block examples witness the pairwise
and higher-arity cases.

# Phase 5 — Implicit-Euler fixed-point goals

Status: complete. Module: `Vbd/Integrator/FixedPoint.lean`.

Dependencies: Phase 1 + Phase 3.

The [implicit-Euler solver-consistency specification](/mathematics/implicit-euler-fixed-points.md)
defines an **unbiased** solver as one whose fixed points solve the IE residual. For an arbitrary
solver map `T : X → X`, `Integrator/FixedPoint.lean` proves that an unbiased forward-invariant
local contraction on a nonempty complete region has a unique solver fixed point, that this point
is an implicit-Euler solution, and that the corresponding finite-iteration bound is

$$
\|T^{k}(x)-x^*\|\le q^k\|x-x^*\|.
$$

Where quantitative regularity of `R_IE` is available, it transports distance bounds to residual
bounds. For a block-product state metric, this regularity has the explicit cross-norm form
$\lVert R_{\mathrm{IE}}(x)-R_{\mathrm{IE}}(y)\rVert_X \le L\lVert x-y\rVert_p$.
The implemented bridge accepts an arbitrary metric solver state and a separately normed residual
codomain; algebraic equivalence transport connects it to the Hilbert-space IE representation.
The module takes the solver map and unbiasedness proof as
parameters. Phase 7 supplies the concrete VBD map and proves unbiasedness on its stated regular
branch.

Acceptance gate: satisfied. The theorem is solver-independent, uses only the Phase 1 and Phase 3
interfaces, and is exported by `Vbd.lean`.

# Phase 6 — Contraction of composed updates

Status: complete for BC-01–BC-03 and BC-05; BC-04 remains deferred. Module: `Vbd/Block/Contraction.lean`.

Dependencies: Phase 2 + Phase 3.

Formalization follows the [AP-03 proceed decision](./applicability-decision.md): nonnegative
comparison matrices with changed-row sum bounds in the block maximum norm support the
selected chain and parameter range. A broader certificate or several-sweep route requires an
updated applicability assessment and synchronized theorem targets before implementation.

For an externally ordered differentiable update sequence, block bounds for each derivative
factor use nonnegative matrices `C⁽ʳ⁾` satisfying

$$
\|(DU_r(x_{r-1}))_{ij}v_j\| \le C^{(r)}_{ij}\|v_j\|.
$$

The exact-execution results comprise:

1. reconstruction of global operator bounds from block-entry bounds;
2. propagation of comparison bounds through externally ordered composition;
3. bounds for commuting color batches using their order-independent composition;
4. deferred bounds for buffered simultaneous batches with same-color coupling;
5. an explicit contraction criterion in a stated block norm.

Acceptance gate: satisfied for the accepted exact-execution route. Explicit block-entry bounds
compose through derivatives evaluated at the actual intermediate states. Uniform nonnegative
comparison matrices with identity rows outside each write set and changed-row sums at most
`q < 1` give a maximum-norm contraction when the execution covers every block. Commuting,
disjoint-write batches inherit the estimate of any enumeration and have an order-independent
derivative. Region invariance and convexity are explicit premises. The maximum-norm state map
uses an explicit continuous-linear equivalence with the finite `BlockSum` representation and
feeds the generic dynamics layer. Concrete VBD update formulas, commutation, and physical
certificates are Phase 7 obligations.

# Phase 7 — Production VBD synthesis

Status: planned. Initial module: `Vbd/Integrator/VBD.lean`.

Dependencies: Phases 4, 5, and 6.

Define the actual unsafeguarded VBD block-update operators. External serial and buffered colored
execution plans apply those operators. The block computation is the full block-Newton update

$$
H_{ii}(x)p_i=-R_{IE,i}(x),
\qquad
U_i(x)=x+\iota_i p_i,
$$

including the production skip behavior when a block Hessian is judged singular. Each complete
execution is exposed as a map on `BlockSum B`; controller ordering and buffer semantics remain
explicit inputs to its construction. The required result chain is:

1. identify regular states where every block update follows the nonsingular branch;
2. prove that the regular complete sweep is unbiased for the stated IE residual, and prove root
   preservation where the exact fixed-point equivalence is required;
3. differentiate the externally ordered serial composition and identify its derivative with the
   corresponding block Gauss-Seidel error operator;
4. use `M / h² + ∇²P` to prove block invertibility and quantitative inverse bounds;
5. bound cross-block coupling and obtain an explicit contraction factor `q`;
6. control Hessian variation on a neighborhood so the linear bound extends to the nonlinear sweep;
7. prove commutation of concrete same-color operators under a valid static coloring and relate their
   simultaneous batches to serial composition; hybrid collision coupling requires a further assessment;
8. conclude convergence and the selected finite-sweep physical-residual bound through Phase 5,
   including IF-03 quantitative distance-to-residual transport.

Curvature is part of this synthesis because it controls block inverses and relative coupling. The
intended quantitative chain is

```text
smaller timestep / stronger mass term
  -> stronger block diagonal bounds
  -> smaller normalized cross-block coupling
  -> improved contraction factor and certified neighborhood
  -> smaller error after a fixed number of sweeps
```

Each convergence theorem includes the external serial or colored execution plan and its
off-diagonal coupling in addition to any positive-definiteness or condition-number assumptions.

Acceptance gate: the parameterized, coupled mechanical family accepted by AP-03, including its
nonlinear case, instantiates the whole chain for the production full-step update. The theorem
derives the certificate from explicit system assumptions, with quantitative timestep and parameter
ranges, block regularity, execution semantics, invariant radius, and a proved initial-state
membership condition instantiated for the selected warm starts. It supplies error and iteration
bounds meeting the AP-01 target on the accepted range. A reproducible assessment reports the
conservatism of these bounds against observed behavior and identifies excluded regimes. Claims
of non-descent coverage require the corresponding certified objective-increase example; sampling
alone does not establish it. All analytic certificate obligations are proved in Lean.

# Secondary and deferred routes

One potential engineering extension is an offline configuration analyzer that selects parameter
ranges for a VBD solver and emits a lightweight adaptive iteration loop. Symbolic estimates or
validated numerical bounds could certify contraction over a stated family of configurations and
state regions; sampling supplies empirical guidance rather than a uniform certificate. A known
factor can be compiled into a displacement threshold for a requested solution-error tolerance,
leaving the expensive analysis outside runtime. Runtime validity requires either an offline
guarantee covering evolving states and contacts or checks with a fallback outside the certified
range. Analysis failure should be distinguished from demonstrated noncontraction, and performance
depends on certificate conservatism and monitoring cost. This extension is outside the active
roadmap; the [adaptive VBD reference note](/references/adaptive-vbd-iterations.md) describes
related mechanisms and the distinction between heuristic stopping and certified accuracy.

Energy-change identities, local or sweep monotonicity, line search, convex minimization, and KL
arguments form secondary routes activated by a named target theorem or compatible solver variant.

Deferred work includes global behavior beyond a certified contractive neighborhood, probabilistic
convergence after a concrete randomness model is selected, fully dynamic collision scheduling,
optimization-error accumulation across time steps,
discretization error, and generalized mass-matrix specializations beyond the first accepted
production theorem.
