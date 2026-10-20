---
type: Project Backlog
title: VBD Formalization Backlog
description: Tracks the current goal-first proof program with explicit dependencies and acceptance criteria.
tags: [backlog, roadmap, lean4, theorem-status]
timestamp: 2026-10-20T00:00:00Z
---

# Project scope

The project studies VBD in exact arithmetic, including finite-iteration state and residual errors. Floating-point rounding, errors from approximate local solves, and GPU implementation verification are outside its scope.

# Status vocabulary

- `next`: first eligible work.
- `planned`: scoped but blocked by dependencies or an applicability decision.
- `research`: requires a focused API or theorem assessment.
- `deferred`: intentionally postponed by the roadmap.
- `done`: acceptance criteria satisfied and documented; formal deliverables compile.

# Project maintenance

| ID | Status | Deliverable | Acceptance criteria |
|---|---|---|---|
| KB-01 | done | Refactor root `AGENTS.md` after OKF initialization | Always-on file points to the bundle, requires backlog/log maintenance, preserves core invariants, and omits detailed roadmap mathematics |
| KB-02 | done | Configure strict OKF pre-commit validation | Versioned manifest and executable hook exist, this checkout uses `.githooks`, and an end-to-end hook run passes |
| KB-03 | done | Simplify bundle project management | Project plans and backlog share one directory; redundant snapshot, scope, and policy concepts are removed |
| KB-04 | done | Adopt scoped OKF update logs | Every indexed scope has a conformant `log.md`, and strict reserved-file linting passes |
| KB-05 | done | Complete Lean development checks | The versioned pre-commit hook runs strict OKF validation and `lake build`; narrow-development commands are documented |
| RS-01 | done | Assess `optsuite/optlib` | Mathlib is the sole direct dependency; Optlib serves as a reference for descent-oriented two-block PALM arguments |

# Phase 1 — implicit Euler mathematics

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| IE-01 | done | State-space and mass-operator skeleton | none | Compiles as a basis-free real inner-product construction using generic Mathlib types |
| IE-02 | done | Define inertia and `G_IE` | IE-01 | Definition carries positive-timestep and self-adjoint-mass constraints |
| IE-03 | done | Gradient of inertia | IE-02 | `HasGradientAt` theorem gives `M(x-y)/h²` |
| IE-04 | done | Gradient of `G_IE` | IE-03 | Sum rule identifies the canonical gradient under explicit assumptions |
| IE-05 | done | Implicit-Euler residual identity | IE-04 | Roots of the energy gradient represent the implicit-Euler equation |
| IE-06 | done | Select Hessian representation | IE-04 | Source documentation explains the derivative-of-gradient choice |
| IE-07 | done | Hessian of `G_IE` | IE-06 | Sum formula compiles under explicit twice-differentiability assumptions |

# Phase 2 — block-state and update-operator algebra

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| BS-01 | done | `BlockSum B` and block operations | none | Heterogeneous product, native block access, injections, and replacement laws compile using Mathlib |
| BS-02 | done | Write support for state-update operators | BS-01 | Write support is the set of block indices changed for some input; containment in a supplied set is equivalent to preservation outside it; identity has empty support and composition has support bounded by the union |
| BS-03 | done | Write support of finite compositions | BS-02 | Ordinary finite products of self-maps preserve blocks outside the union of their write-support bounds; composition algebra uses Mathlib |
| BS-04 | done | Commutation and reordering | BS-03 | Mathlib’s product reordering theorem supplies order independence for pairwise-commuting finite operator families |
| BS-05 | done | Simultaneous and color-batch algebra | BS-02, BS-04 | Pairwise-disjoint write-support bounds define a simultaneous merge whose support is the union of the constituent supports, including for noncommuting operators; pairwise commutation makes the merge equal every sequential ordering |
| BS-06 | done | Continuous-linear block representation | BS-01 | Finite heterogeneous continuous-linear entries assemble and reconstruct operators, and identity and composition satisfy the block-matrix formulas |

# Phase 3 — contractive fixed-point iteration

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| CT-01 | done | Pinned Mathlib contraction API assessment | none | Exact reusable `ContractingWith`, restricted-map, fixed-point, and iterate-bound declarations are recorded |
| CT-02 | done | Local invariant-set contraction wrapper | CT-01 | A contraction on a forward-invariant complete subset yields a unique local fixed point and iterate convergence |
| CT-03 | done | Finite-iteration distance bound | CT-02 | The public theorem exposes a geometric `q^k` bound suitable for a fixed iteration budget |
| CT-04 | done | Derivative-bound bridge | CT-02, AP-03 | A uniform derivative/operator-norm bound on a stated convex neighborhood yields the Lipschitz contraction needed by the AP-03 route |

# Early applicability study

Execution order is CT-01–CT-03, AP-01–AP-03, then the selected derivative bridge and
Phase 4–7 formalization. AP-03 is a research decision dependency, not a Lean import. Every
Phase 4–7 item and CT-04 requires an AP-03 proceed decision for its route in addition to
its listed dependencies. A completed revise decision keeps dependent formalization gated until
an updated assessment supports proceeding. The [roadmap](./roadmap.md#applicability-gate-and-work-order)
defines the evidence standard and the response to an ineffective certificate.

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| AP-01 | done | Representative mechanical family and evaluation targets | CT-03 | A parameterized family has substantive cross-block coupling, a quadratic baseline and nonlinear case, exact serial and proper-color sweep semantics, skip threshold, justified parameter ranges, defined warm starts, separately defined physical residual and sweep defect with norms/scaling, and target error/sweep budgets selected before certificate evaluation |
| AP-02 | done | Comparison of state-contraction and physical-residual certificates | AP-01 | Derive the sweep linearization and candidate neighborhood bounds; assess fixed-point/root consistency including skips independently of contraction; compare state contraction, qualitative physical-residual progress and quantitative residual reduction over the same selected range; report timestep, radius, warm-start coverage, iteration budget where supported, system-size dependence and objective-increase cases, separating analytic guarantees from numerical evidence and sweep-defect decrease |
| AP-03 | done | Proceed or revise decision with an explicit guarantee level | AP-02 | Record the selected norm, family, execution scope, route, coverage and proof obligations; quantitative proceed requires an analytically supported parameter range, relevant warm-start membership and target budget; qualitative proceed authorizes only a scoped physical-residual progress milestone; assess sharper bounds, alternative norms or several-sweep contraction when needed, and synchronize downstream targets/dependencies for the selected route before implementation |

The [axial-spring contraction analysis](/mathematics/axial-spring-contraction.md) and
[proceed decision](./applicability-decision.md) discharge the research gate for the selected
exact-execution chain theorem. They do not discharge its Lean proof obligations or establish general production applicability.
Generic bridge and synthesis lemmas must remain usable with vector blocks and other potential-component
supports; model-specific chain lemmas instantiate them. The
[reuse contract](./applicability-decision.md#project-scope-and-reuse-contract) is part of the
acceptance criteria for BC-01–BC-05 and VB-01–VB-08.

# Phase 4 — finite-support potential components and coloring

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| LI-01 | done | Finite-support potential components | IE-07, BS-01 | `LocalPotential` exposes arbitrary finite supports, local component functions, their finite-sum energy, and exact cancellation outside affected supports |
| LI-02 | done | Component-overlap graph and proper coloring | LI-01 | Component supports induce a `SimpleGraph`; Mathlib's `Coloring (Fin m)` represents the proper coloring, with a proved equivalence to support-wise injectivity |
| LI-03 | done | Pairwise and multi-vertex examples | LI-02 | Compiled two-block and three-block support examples have valid numbered Mathlib colorings |
| LI-04 | done | Component-set coloring boundary | LI-02 | Restriction to a smaller support family and the exact support-wise criterion for extending a fixed coloring both compile |

# Phase 5 — implicit-Euler fixed-point goals

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| IF-01 | done | Solver-independent unbiased IE fixed-point theorem | IE-05, CT-02 | A contraction in the selected state metric on a nonempty complete invariant region whose fixed points are IE roots has a unique solver fixed point, and that point represents an IE solution |
| IF-02 | done | Finite-iteration IE error | IF-01, CT-03 | Iterates have an explicit geometric distance bound to the IE solution selected by IF-01 |
| IF-03 | done | Distance-to-residual bound | IF-02, quantitative regularity of `R_IE` | A stated cross-norm Lipschitz bound converts iterate error in the selected state metric into a residual bound in an independently chosen codomain norm |

# Phase 6 — contraction of composed updates

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| BC-01 | done | Blockwise derivative-factor bounds | BS-06, CT-04 | Bounds on each block entry of each supplied update derivative produce nonnegative comparison matrices |
| BC-02 | done | Ordered composition bound | BS-03, BC-01 | Comparison matrices compose in the same externally supplied order as the update operators |
| BC-03 | done | Commuting color-batch bound | BS-04, BS-05, BC-02 | A commuting batch has an order-independent derivative and an explicit block-norm bound |
| BC-04 | deferred | Buffered simultaneous-batch bound | BS-05, BC-01 | Same-color coupling is bounded using the actual simultaneous snapshot semantics |
| BC-05 | done | Exact-execution contraction bounds | BC-02, BC-03 | Serial and proper-color execution maps obtain explicit maximum-norm contraction bounds |

# Phase 7 — production VBD synthesis

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| VB-01 | done | Production VBD update operators and execution plans | LI-01, BS-03, BS-05 | Supplied block-Newton operators and externally controlled serial or buffered plans match the paper, including singular-block skipping |
| VB-02 | done | Regular fixed-point consistency | VB-01, IE-05 | A complete skip-free sweep fixes exactly an IE root in the stated regular region, with block coverage and execution assumptions explicit; the equivalence is proved independently of contraction |
| VB-03 | done | Execution derivative and block entries | VB-01, BS-06, BC-02 | The derivative at an IE root is derived from the externally ordered operator composition and identified with the corresponding Gauss-Seidel error operator |
| VB-04 | done | Inertia-based block inverse bounds | IE-07, VB-01 | `M/h² + ∇²P` yields explicit coercivity and inverse-norm bounds on a neighborhood |
| VB-05 | done | Serial coupling and contraction factor | VB-03, VB-04, BC-02 | Off-diagonal component bounds produce an explicit `q < 1` for the actual serial execution over the AP-03 parameter range, with norm-conversion constants stated |
| VB-06 | done | Nonlinear contraction neighborhood | VB-05, CT-04 | Hessian variation produces an explicit invariant radius with a uniform contraction bound and a proved initial-state membership condition instantiated for the selected warm starts |
| VB-07 | done | Proper-color VBD | LI-04, VB-06, BC-03 | Component separation discharges commutation and snapshot equivalence for the selected proper colors; same-color coupling requires a further applicability decision |
| VB-08 | next | End-to-end finite-sweep theorem | VB-02, VB-06, VB-07, IF-03 | The AP-03 parameterized coupled family, including its nonlinear case, has Lean-proved system-to-certificate and finite-sweep bounds meeting the selected accuracy budget; quantitative parameter ranges and warm-start coverage are instantiated, conservatism and exclusions are assessed reproducibly, and any non-descent coverage claim has a certified objective-increase example |

# Deferred by the current route

| ID | Status | Deliverable | Reactivation condition |
|---|---|---|---|
| EN-01 | deferred | Energy-descent and line-search theory | A named production or safeguarded-solver theorem requires it |
| PR-01 | deferred | Probabilistic convergence | A concrete source of randomness and verifiable drift hypothesis are identified |
| GL-01 | deferred | Global convergence outside a contractive neighborhood | Suitable global hypotheses matching the production update are identified |
| ER-01 | deferred | Solver-error accumulation across timesteps | The single-step finite-sweep theorem VB-08 is stable |
| ER-02 | deferred | Separate discretization and solver error | Both error components have independent definitions and bounds |
| DC-01 | deferred | Fully dynamic collision scheduling | The first static/hybrid colored theorem is complete |
| MM-01 | deferred | Generalized non-diagonal mass specialization | The first accepted production theorem identifies the needed locality assumptions |

# Open decisions

1. Continuous linear operator versus matrix as the primary mass representation in Phase 7.

The [AP-03 decision](./applicability-decision.md) fixes the first certificate to the maximum norm
and static proper colors. Its scalar nonlinear chain, predictor box, and 20-sweep residual target
instantiate VB-05–VB-08. CT-04, the exact-execution Phase 6 bridge, and VB-01–VB-07 are implemented;
VB-08 is next. The nonlinear serial and proper-color factor is `318/625 < 0.512` on the
invariant radius-`0.1` box, with the selected cosine predictor and rest-state warm starts covered.
BC-04 requires a further applicability assessment for same-color coupling in exact arithmetic.

Every resolved project-wide architecture decision should become an Architecture Decision concept
and be removed from this list in the same change. Source-local representation choices belong in
the relevant Lean module documentation.
