---
type: Project Roadmap
title: VBD Formalization Roadmap
description: Defines the current goal-first phase structure, theorem targets, dependencies, and acceptance gates.
tags: [roadmap, implicit-euler, block-operators, contraction, vbd]
timestamp: 2026-09-04T00:00:00Z
---

# Current phase status

| Phase | Status | Current boundary |
|---|---|---|
| Phase 1 — implicit Euler mathematics | complete | `Vbd/Integrator/ImplicitEulerEnergy.lean` provides the basis-free objective, gradient, and Hessian identities |
| Phase 2 — block sums and update algebra | active | `BS-02`: define one-block maps and the law that every other coordinate is unchanged |
| Phase 3 — contractive fixed-point iteration | planned | begins after the narrow Mathlib contraction API wrapper is scoped |
| Phase 4 — local interactions and coloring | planned | combines the Phase 1 potential with Phase 2 finite-support interaction structure |
| Phase 5 — implicit-Euler fixed-point goals | planned | combines Phase 1 stationary solutions with Phase 3 solver-independent iteration bounds |
| Phase 6 — contraction of block-composed operators | planned | combines Phase 2 update algebra with Phase 3 contraction theory |
| Phase 7 — production VBD synthesis | planned | combines the bridge phases to analyze the actual serial and colored VBD sweep |

The [backlog](/project/backlog.md) is authoritative for item-level status and acceptance criteria.

# Goal and dependency graph

The production-facing target is a quantitative theorem for the actual unsafeguarded VBD sweep:
on an explicitly described neighborhood of an implicit-Euler solution, the serial or colored sweep
is contractive with factor `q < 1`, giving a finite-sweep error bound. Energy descent is not a
foundation of this route because the production block-Newton step does not guarantee it.

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

# Phase 1 — Implicit Euler mathematics

Status: complete. Module: `Vbd/Integrator/ImplicitEulerEnergy.lean`.

Phase 1 supplies the incremental objective `G_IE`, its canonical gradient, and its Hessian:

$$
F_{IE}(x)=\nabla G_{IE}(x),
\qquad
DF_{IE}(x)=\frac{M}{h^2}+\nabla^2P(x).
$$

Its solution concept is stationarity of `G_IE`, equivalently a root of `F_IE`. It contains no
block schedules, coloring, iteration maps, or convergence theory.

# Phase 2 — Block sums and update algebra

Status: active. Initial modules: `Vbd/Block/Basic.lean`, `Vbd/Block/Update.lean`, and
`Vbd/Block/Coloring.lean`.

Reserve `X` for a total space, use `B : ι → Type*` for heterogeneous block spaces, and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Phase 2 develops only the structure of block-indexed states and maps:

1. coordinate projection, injection, and one-block replacement;
2. one-block maps and the law that other coordinates are unchanged;
3. ordered schedules, prefix states, folds, and composition of schedules;
4. simultaneous updates on distinct coordinate sets;
5. abstract read-dependencies, conflicts, and proper colorings;
6. commutation of independent state-dependent updates;
7. equivalence of an independent parallel color-class update with any sequential ordering of the
   class.

Phase 2 does not mention objectives, energy, gradients, Hessians, Newton steps, stationarity,
implicit Euler, or convergence. It adds algebraic or analytic assumptions only to the declarations
that require them; finite-dimensional blocks are not a phase-wide requirement.

Acceptance gate: a later module can construct serial, independent-parallel, and generally
simultaneous colored sweep maps without importing an optimization or mechanics module.

# Phase 3 — Contractive fixed-point iteration

Status: planned. Module: `Vbd/Dynamics/Contraction.lean`.

Reuse Mathlib's `ContractingWith` and Banach fixed-point results. Add only the project-relevant
bridges that are absent or awkward at the call site:

1. contraction on a forward-invariant complete subset or closed ball;
2. explicit finite-iterate distance bounds;
3. derivative bounds on a convex neighborhood implying a Lipschitz contraction there;
4. local convergence to a known fixed point;
5. persistent, vanishing, and summable perturbation bounds.

Use direct Lipschitz or operator-norm bounds first. A spectral-radius hypothesis requires an
appropriate equivalent norm or an iterate theorem and is not silently interchangeable with
contraction in the existing norm.

Acceptance gate: the results apply to an arbitrary self-map of a complete metric or normed space
and import neither Phase 1 nor Phase 2.

# Phase 4 — Local interactions and coloring

Status: planned. Module: `Vbd/Integrator/LocalInteractions.lean`.

Dependencies: Phase 1 + Phase 2.

Represent the potential as finitely many finite-support interactions. Supports form a hypergraph;
the conflict graph joins two blocks when a live interaction reads both. Pairwise systems are the
two-element-support specialization, while triangle, tetrahedron, bending, and other multi-vertex
elements remain covered.

Derive the read-dependencies of physical block data, the induced conflict graph, and concrete
coloring validity conditions. A proper color makes simultaneous elastic updates equivalent to a
sequential ordering. Newly introduced collision interactions may invalidate a static coloring and
must remain visible rather than being treated as independent.

Acceptance gate: the interaction structure discharges the abstract Phase 2 independence
hypotheses for at least one pairwise and one multi-vertex example. No convergence claim is made.

# Phase 5 — Implicit-Euler fixed-point goals

Status: planned. Module: `Vbd/Integrator/FixedPoint.lean`.

Dependencies: Phase 1 + Phase 3.

For an arbitrary solver map `T : X → X` and an implicit-Euler stationary point `x*`, prove that a
forward-invariant local contraction with `T x* = x*` yields convergence to an implicit-Euler
solution and the corresponding finite-iteration bound

$$
\|T^{k}(x)-x^*\|\le q^k\|x-x^*\|.
$$

Where quantitative regularity of `F_IE` is available, transport distance bounds to residual
bounds. Phase 5 does not construct a block solver or assert that an arbitrary solver has the right
fixed point; those obligations are discharged only in the final synthesis.

Acceptance gate: the theorem is solver-independent and imports no Phase 2 declarations.

# Phase 6 — Contraction of block-composed operators

Status: planned. Module: `Vbd/Block/Contraction.lean`.

Dependencies: Phase 2 + Phase 3.

A one-block update is the identity on untouched coordinates and is therefore not expected to be a
strict contraction of the whole space. Record cross-block sensitivity through nonnegative bounds
of the form

$$
\|\pi_i(U_i(x)-U_i(y))\|
\le \sum_j C_{ij}\|\pi_j(x-y)\|.
$$

Prove how these bounds compose into:

1. a serial Gauss-Seidel sweep bound;
2. a properly colored sweep bound;
3. a Jacobi-within-color and Gauss-Seidel-between-colors bound;
4. a global contraction factor in a stated block norm;
5. perturbation bounds for weak same-color conflicts or approximate updates.

Acceptance gate: explicit local sensitivity and coupling hypotheses produce a `q < 1` contraction
certificate for both a serial schedule and a colored schedule. No objective or mechanics concept
is imported.

# Phase 7 — Production VBD synthesis

Status: planned. Initial module: `Vbd/Integrator/VBD.lean`.

Dependencies: Phases 4, 5, and 6.

Define the actual unsafeguarded block-Newton update

$$
H_{ii}(x)p_i=-F_{IE,i}(x),
\qquad
U_i(x)=x+\iota_i p_i,
$$

including the production skip behavior when a block Hessian is judged singular. The required result
chain is:

1. identify regular states where every block update is defined and no skip occurs;
2. show that a regular fixed point of a complete sweep is an implicit-Euler solution;
3. differentiate the block update and identify the derivative of a serial sweep with the
   schedule-dependent block Gauss-Seidel error operator;
4. use `M / h² + ∇²P` to prove block invertibility and quantitative inverse bounds;
5. bound cross-block coupling and obtain an explicit contraction factor `q`;
6. control Hessian variation on a neighborhood so the linear bound extends to the nonlinear sweep;
7. transfer the result to a proper static coloring and analyze the actual hybrid colored map when
   live collision interactions create same-color coupling;
8. conclude convergence and finite-sweep distance or residual bounds through Phase 5.

Curvature is part of this synthesis because it controls block inverses and relative coupling. The
intended quantitative chain is

```text
smaller timestep / stronger mass term
  -> stronger block diagonal bounds
  -> smaller normalized cross-block coupling
  -> improved contraction factor and certified neighborhood
  -> smaller error after a fixed number of sweeps
```

Positive definiteness or a better condition number alone is not reported as a convergence result;
the chosen serial or colored splitting and its off-diagonal coupling must appear in the theorem.

Acceptance gate: at least one concrete finite-support implicit-Euler system instantiates the whole
chain for the production full-step update, with all regularity, coloring, and neighborhood
hypotheses explicit.

# Secondary and deferred routes

Energy-change identities, local or sweep monotonicity, line search, convex minimization, and KL
arguments are not part of the main dependency chain. Add them only when a named target theorem or
solver variant needs them.

Deferred work includes global behavior outside a certified contractive neighborhood, a
probabilistic theory without an identified source of randomness, fully dynamic collision
scheduling, floating-point and GPU execution error, optimization-error accumulation across time
steps, discretization error, and generalized mass-matrix specializations beyond the first accepted
production theorem.
