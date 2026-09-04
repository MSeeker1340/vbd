---
type: Project Backlog
title: VBD Formalization Backlog
description: Tracks the current goal-first proof program with explicit dependencies and acceptance criteria.
tags: [backlog, roadmap, lean4, theorem-status]
timestamp: 2026-09-04T00:00:00Z
---

# Status vocabulary

- `next`: first eligible work.
- `planned`: scoped but blocked by earlier definitions.
- `research`: requires a focused API or theorem assessment.
- `deferred`: intentionally postponed by the roadmap.
- `done`: compiled and documented.

# Project maintenance

| ID | Status | Deliverable | Acceptance criteria |
|---|---|---|---|
| KB-01 | done | Refactor root `AGENTS.md` after OKF initialization | Always-on file points to the bundle, requires backlog/log maintenance, preserves core invariants, and omits detailed roadmap mathematics |
| KB-02 | done | Configure strict OKF pre-commit validation | Versioned manifest and executable hook exist, this checkout uses `.githooks`, and an end-to-end hook run passes |
| KB-03 | done | Simplify bundle project management | Project plans and backlog share one directory; redundant snapshot, scope, and policy concepts are removed |
| KB-04 | done | Adopt scoped OKF update logs | Every indexed scope has a conformant `log.md`, and strict reserved-file linting passes |
| KB-05 | done | Complete Lean development checks | The versioned pre-commit hook runs strict OKF validation and `lake build`; narrow-development commands are documented |
| RS-01 | done | Assess `optsuite/optlib` | Mathlib remains the only dependency; Optlib's descent-oriented two-block PALM layer is reference-only and is not on the current contraction route |

# Phase 1 — implicit Euler mathematics

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| IE-01 | done | State-space and mass-operator skeleton | none | Compiles with basis-free real inner-product assumptions and no VBD types |
| IE-02 | done | Define inertia and `G_IE` | IE-01 | Definition carries positive-timestep and self-adjoint-mass constraints |
| IE-03 | done | Gradient of inertia | IE-02 | `HasGradientAt` theorem gives `M(x-y)/h²` |
| IE-04 | done | Gradient of `G_IE` | IE-03 | Sum rule identifies the canonical gradient under explicit assumptions |
| IE-05 | done | Implicit-Euler residual identity | IE-04 | Roots of the energy gradient represent the implicit-Euler equation |
| IE-06 | done | Select Hessian representation | IE-04 | Source documentation explains the derivative-of-gradient choice |
| IE-07 | done | Hessian of `G_IE` | IE-06 | Sum formula compiles under explicit twice-differentiability assumptions |

# Phase 2 — block sums and update algebra

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| BS-01 | done | `BlockSum B` and coordinate operations | none | Heterogeneous product, native coordinate access, injections, and replacement laws compile without objective or mechanics imports |
| BS-02 | next | One-block maps | BS-01 | A small predicate states exactly which coordinate an arbitrary state-dependent map may change |
| BS-03 | planned | Ordered schedules and sweep folds | BS-02 | Prefix states, concatenation, and composition laws retain order and repeated blocks |
| BS-04 | planned | Simultaneous coordinate updates | BS-01 | Updates on a finite set of distinct coordinates have an explicit parallel semantics |
| BS-05 | planned | Read-dependencies, conflicts, and colorings | BS-02 | Generic dependencies induce a symmetric conflict relation and proper-color predicate |
| BS-06 | planned | Independent update commutation | BS-03, BS-05 | Independent state-dependent updates commute and a proper color-class map equals any sequential ordering |

# Phase 3 — contractive fixed-point iteration

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| CT-01 | planned | Pinned Mathlib contraction API assessment | none | Exact reusable `ContractingWith`, restricted-map, fixed-point, and iterate-bound declarations are recorded |
| CT-02 | planned | Local invariant-set contraction wrapper | CT-01 | A contraction on a forward-invariant complete subset yields a unique local fixed point and iterate convergence |
| CT-03 | planned | Finite-iteration distance bound | CT-02 | The public theorem exposes a geometric `q^k` bound suitable for a fixed iteration budget |
| CT-04 | planned | Derivative-bound bridge | CT-02 | A uniform derivative/operator-norm bound on a stated neighborhood yields the required Lipschitz contraction |
| CT-05 | planned | Perturbed contraction bounds | CT-03 | Persistent, vanishing, and summable perturbations have explicitly separated conclusions |

# Phase 4 — local interactions and coloring

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| LI-01 | planned | Finite-support interaction hypergraph | IE-07, BS-05 | Multi-block interactions expose supports without restricting them to pairs |
| LI-02 | planned | Physical read-dependencies and conflict graph | LI-01 | Shared interactions discharge the abstract Phase 2 conflict relation |
| LI-03 | planned | Pairwise and multi-vertex examples | LI-02, BS-06 | One pairwise and one triangle/tetrahedron-style system have proved coloring independence |
| LI-04 | planned | Static-color validity boundary | LI-02 | New collision interactions are shown to preserve or invalidate the static independence premise explicitly |

# Phase 5 — implicit-Euler fixed-point goals

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| IF-01 | planned | Solver-independent IE fixed-point theorem | IE-05, CT-02 | A known IE stationary fixed point of an arbitrary local contraction is the unique fixed point in its certified region |
| IF-02 | planned | Finite-iteration IE error | IF-01, CT-03 | Iterates have an explicit geometric distance bound to the IE solution |
| IF-03 | planned | Distance-to-residual bound | IF-02, quantitative regularity of `F_IE` | A stated Lipschitz bound converts iterate error into an IE residual bound |

# Phase 6 — contraction of block-composed operators

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| BC-01 | planned | Cross-block sensitivity bounds | BS-02, CT-04 | A nonnegative coupling family bounds every output block by input-block differences |
| BC-02 | planned | Serial sweep composition bound | BC-01, BS-03 | Schedule order produces an explicit Gauss-Seidel-style global Lipschitz bound |
| BC-03 | planned | Properly colored sweep bound | BC-01, BS-06 | Independent same-color updates preserve sequential semantics and yield an explicit contraction certificate |
| BC-04 | planned | Hybrid colored sweep bound | BC-01, BS-04 | Same-color coupling is represented as Jacobi-style sensitivity rather than assumed absent |
| BC-05 | planned | Approximate and weak-conflict bounds | BC-02, BC-04, CT-05 | Perturbed serial or colored maps inherit stated convergence or error-neighborhood guarantees |

# Phase 7 — production VBD synthesis

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| VB-01 | planned | Production full block-Newton update and skip | LI-01, BS-02 | The map matches the paper's unsafeguarded update and exposes the singular-block skip branch |
| VB-02 | planned | Regular fixed-point consistency | VB-01, IF-01 | A complete skip-free sweep fixes exactly an IE root in the stated regular region |
| VB-03 | planned | Sweep derivative and block splitting | VB-01, BC-02 | The derivative at an IE root is identified with the schedule-dependent block Gauss-Seidel error operator |
| VB-04 | planned | Inertia-based block inverse bounds | IE-07, VB-01 | `M/h² + ∇²P` yields explicit coercivity and inverse-norm bounds on a neighborhood |
| VB-05 | planned | Serial coupling and contraction factor | VB-03, VB-04, BC-02 | Off-diagonal interaction bounds produce an explicit `q < 1` for the actual serial sweep |
| VB-06 | planned | Nonlinear contraction neighborhood | VB-05, CT-04 | Hessian variation produces a forward-invariant neighborhood with a uniform contraction bound |
| VB-07 | planned | Proper and hybrid colored VBD | LI-04, VB-06, BC-03, BC-04 | Static colors preserve the serial result; collision-induced same-color coupling has a separate explicit bound |
| VB-08 | planned | End-to-end finite-sweep theorem | VB-02, VB-06, VB-07, IF-02 | A concrete finite-support IE system obtains distance or residual error after a fixed number of production sweeps |

# Deferred by the current route

| ID | Status | Deliverable | Reactivation condition |
|---|---|---|---|
| EN-01 | deferred | Energy-descent and line-search theory | A named production or safeguarded-solver theorem requires it |
| PR-01 | deferred | Probabilistic convergence | A concrete source of randomness and verifiable drift hypothesis are identified |
| GL-01 | deferred | Global convergence outside a contractive neighborhood | Suitable global hypotheses matching the production update are identified |
| ER-01 | deferred | Solver-error accumulation across timesteps | The single-step finite-sweep theorem VB-08 is stable |
| ER-02 | deferred | Separate discretization and solver error | Both error components have independent definitions and bounds |
| DC-01 | deferred | Fully dynamic collision scheduling | The first static/hybrid colored theorem is complete |
| FP-01 | deferred | Floating-point and GPU execution error | The exact-arithmetic production map and contraction result are stable |
| MM-01 | deferred | Generalized non-diagonal mass specialization | The first accepted production theorem identifies the needed locality assumptions |

# Open decisions

1. Continuous linear operator versus matrix as the primary mass representation in Phase 7.
2. The first block norm used for an explicit contraction certificate: the existing finite `ℓ²`
   norm, a weighted maximum norm, or a system-dependent energy norm.
3. Whether the first production synthesis excludes same-color collision coupling or proves a small
   perturbation bound in the same milestone.

Every resolved project-wide architecture decision should become an Architecture Decision concept
and be removed from this list in the same change. Source-local representation choices belong in
the relevant Lean module documentation.
