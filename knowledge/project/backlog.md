---
type: Project Backlog
title: VBD Formalization Backlog
description: Tracks the ordered proof program with explicit dependencies and acceptance criteria.
tags: [backlog, roadmap, lean4, theorem-status]
timestamp: 2026-08-20T00:00:00Z
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
| KB-03 | done | Simplify bundle project management | Project plans and backlog share one directory; redundant snapshot, scope, and policy concepts and the incorrect Optlib reference are removed |
| KB-04 | done | Adopt scoped OKF update logs | Every indexed scope has a conformant `log.md`, standalone worklog concepts are removed, and strict reserved-file linting passes |
| KB-05 | done | Complete Lean development checks | The versioned pre-commit hook runs strict OKF validation and `lake build`; package linting and verified narrow-development commands are documented |

# Initial implementation sequence

| ID | Status | Deliverable | Depends on | Acceptance criteria |
|---|---|---|---|---|
| IE-01 | next | State-space and mass-operator skeleton | none | Compiles with basis-free real inner-product assumptions and no VBD types |
| IE-02 | planned | Define inertia and `G_IE` | IE-01 | Definition documents `h ≠ 0`, self-adjointness, and differentiability boundaries |
| IE-03 | planned | Gradient of inertia | IE-02 | `HasGradientAt` theorem with simplified `M(x-y)/h²` result |
| IE-04 | planned | Gradient of `G_IE` | IE-03 | Sum rule proved from an abstract gradient witness for `E` |
| IE-05 | planned | Residual iff stationary | IE-04 | Bidirectional theorem is a direct, reusable equivalence |
| IE-06 | research | Select Hessian representation | IE-04 | Decision compares derivative-of-gradient, second Fréchet derivative, and bilinear/operator forms |
| IE-07 | planned | Hessian of `G_IE` | IE-06 | Sum formula proved under explicit twice-differentiability assumptions |
| LO-01 | planned | Finite block/factor structure | IE-01 representation feedback | Supports finite factors, support sets, and extensional locality |
| LO-02 | planned | One-block replacement and affected factors | LO-01 | Other-block equality and support lemmas compile cleanly |
| LO-03 | planned | Exact local/global change identity | LO-02 | Equality theorem has no derivative or curvature assumptions |
| LO-04 | planned | Local descent corollaries | LO-03 | Non-strict, strict, and equality variants are small lemmas |
| BC-01 | planned | Abstract descending block update | LO-04 | Exact minimization is not built into the core definition |
| BC-02 | planned | Block derivative locality | BC-01, derivative API | Proves unaffected factor derivatives vanish or cancel under precise hypotheses |
| GS-01 | planned | Sequential sweep as finite fold | BC-01 | Update order is explicit and reusable |
| GS-02 | planned | Sweep monotonicity | GS-01 | Induction/fold theorem derives global nonincrease from per-step descent |
| CO-01 | planned | Conflict relation and independence | LO-01 | Symmetry and no-shared-factor characterization proved |
| CO-02 | planned | Independent update commutation | CO-01, BC-01 | Separates fixed replacement commutation from state-dependent update commutation |
| CO-03 | planned | Proper coloring and color-class update | CO-02, GS-01 | Pairwise-independent class has order-independent semantics |

# Later generic theory

| ID | Status | Deliverable | Notes |
|---|---|---|---|
| BN-01 | planned | Positive-definite block Hessian gives a descent direction | Requires a basis-free or matrix representation decision |
| BN-02 | planned | Line-search interface and local decrease | Keep concrete rules as instances |
| CV-01 | research | Evaluate `optsuite/optlib` BCD reuse | Follow the dependency-assessment gate |
| CV-02 | planned | Nonconvex cluster-point stationarity | State continuity, compactness, fairness, and regularity explicitly |
| CV-03 | planned | Convex stationary point implies global minimum | Reuse Mathlib where possible |
| CV-04 | planned | Strongly convex uniqueness | Derive through `StrongConvexOn` and strict convexity |
| CU-01 | planned | Quadratic gradient and Hessian library | Avoid diagonal assumptions |
| CU-02 | planned | Hessian lower bound implies strong convexity | May require explicit coercivity modulus |

# VBD specialization

| ID | Status | Deliverable | Notes |
|---|---|---|---|
| VB-01 | planned | Vertex blocks and incident-factor local energy | Instantiate generic local factors |
| VB-02 | planned | VBD local/global change and descent | Recover the paper's core argument |
| VB-03 | planned | Particle-coordinate mass locality | Start with the weakest convenient mass assumption |
| VB-04 | planned | VBD block Hessian and conditioning | Separate inertia curvature from potential curvature |
| VB-05 | planned | Static vertex-color parallelism | Dynamic collision factors remain outside initial theorem |

# Deferred by project policy

| ID | Status | Deliverable | Reactivation condition |
|---|---|---|---|
| ER-01 | deferred | Error after finitely many sweeps | Core sweep and convergence definitions stable |
| ER-02 | deferred | Per-timestep finite-solve error | ER-01 and implicit-Euler solution notion stable |
| ER-03 | deferred | Solver-error accumulation over timesteps | Concrete recurrence theorem identified |
| ER-04 | deferred | Separate discretization and optimization error | Both error components formalized independently |
| MM-01 | deferred | Generalized non-diagonal mass matrices | Diagonal/basis-free baseline complete |
| RT-01 | deferred | Convergence rates | Exact assumptions and reusable theorem selected |

# Open decisions

1. Dependent finite product versus abstract global Hilbert space with block maps.
2. Continuous linear operator versus matrix as the primary mass representation.
3. Project Hessian representation.
4. Whether `optsuite/optlib` should be imported, selectively adapted, or only cited.
5. The first convergence theorem whose assumptions genuinely match VBD updates.

Every resolved decision should become an Architecture Decision concept and be removed from this list in the same change.
