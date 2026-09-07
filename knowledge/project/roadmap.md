---
type: Project Roadmap
title: VBD Formalization Roadmap
description: Defines the current goal-first phase structure, theorem targets, dependencies, and acceptance gates.
tags: [roadmap, implicit-euler, block-operators, contraction, vbd]
timestamp: 2026-09-07T00:00:00Z
---

# Current phase status

| Phase | Status | Current boundary |
|---|---|---|
| Phase 1 — implicit Euler mathematics | complete | `Vbd/Integrator/ImplicitEulerEnergy.lean` provides the basis-free objective, gradient, and Hessian identities |
| Phase 2 — block-state and update-operator algebra | active | `BS-02`: define write locality for general state-update operators |
| Phase 3 — contractive fixed-point iteration | planned | begins after the narrow Mathlib contraction API wrapper is scoped |
| Phase 4 — local interactions and coloring | planned | combines the Phase 1 potential with Phase 2 block states and derives physical conflict structure |
| Phase 5 — implicit-Euler fixed-point goals | planned | combines Phase 1 stationary solutions with Phase 3 solver-independent iteration bounds |
| Phase 6 — contraction of composed updates | planned | combines Phase 2 update composition and block linearization with Phase 3 contraction theory |
| Phase 7 — production VBD synthesis | planned | combines the bridge phases to analyze the actual serial and colored VBD sweep |

The [backlog](/project/backlog.md) is authoritative for item-level status and acceptance criteria.

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

# Phase 1 — Implicit Euler mathematics

Status: complete. Module: `Vbd/Integrator/ImplicitEulerEnergy.lean`.

Phase 1 supplies the incremental objective `G_IE`, its canonical gradient, and its Hessian:

$$
F_{IE}(x)=\nabla G_{IE}(x),
\qquad
DF_{IE}(x)=\frac{M}{h^2}+\nabla^2P(x).
$$

Its solution concept is stationarity of `G_IE`, equivalently a root of `F_IE`. Its scope consists of
the objective and its differential identities.

# Phase 2 — Block-state and update-operator algebra

Status: active. Modules: `Vbd/Block/Basic.lean`, `Vbd/Block/Update.lean`, and
`Vbd/Block/Operator.lean`.

Reserve `X` for a total space, use `B : ι → Type*` for heterogeneous block spaces, and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Phase 2 develops the objective-independent algebra of block-indexed states and externally
controlled update operators:

1. native coordinate access, single-coordinate injection, and replacement;
2. write-locality predicates for general state-update operators, with block updates as the
   singleton-write specialization;
3. identity, composition, and finite execution sequences whose order is supplied externally;
4. commutation and invariance of finite composition under reordering;
5. simultaneous merging for disjoint write supports and its equality with sequential composition
   for commuting families, giving the generic color-batch algebra;
6. continuous-linear block entries, finite assembly, and block-matrix arithmetic for linear update
   operators and derivatives.

`BlockSum.replace` is the primitive coordinate write. The phase vocabulary consists of block
states, state-update operators, external execution data, and continuous linear operators. External
execution data assigns positions to update operators. Concrete VBD update formulas, physical
independence proofs, and production serial or buffered execution enter through later bridge and
synthesis phases.
Algebraic and analytic assumptions remain local to the declarations that use them, and the core
results support infinite-dimensional blocks.

Acceptance gate: later modules can supply concrete update operators and an external serial or
color-batched execution plan, reduce commuting batches to order-independent composition, and
represent the resulting linear operators or derivatives by heterogeneous block matrices.

# Phase 3 — Contractive fixed-point iteration

Status: planned. Module: `Vbd/Dynamics/Contraction.lean`.

Reuse Mathlib's `ContractingWith` and Banach fixed-point results. Add the project-relevant
bridges that are absent or awkward at the call site:

1. contraction on a forward-invariant complete subset or closed ball;
2. explicit finite-iterate distance bounds;
3. derivative bounds on a convex neighborhood implying a Lipschitz contraction there;
4. local convergence to a known fixed point;
5. persistent, vanishing, and summable perturbation bounds.

Use direct Lipschitz or operator-norm bounds first. A spectral-radius hypothesis enters through an
appropriate equivalent norm or an iterate theorem.

Acceptance gate: the results apply to an arbitrary self-map of a complete metric or normed space
using the generic dynamics layer and Mathlib.

# Phase 4 — Local interactions and coloring

Status: planned. Module: `Vbd/Integrator/LocalInteractions.lean`.

Dependencies: Phase 1 + Phase 2.

Represent the potential as finitely many finite-support interactions. Supports form a hypergraph;
the conflict graph joins two blocks when a live interaction contains both. Pairwise systems are the
two-element-support specialization, while triangle, tetrahedron, bending, and other multi-vertex
elements remain covered.

Derive the physical conflict graph and concrete coloring validity conditions. Newly introduced
collision interactions may invalidate a static coloring and must remain visible in the production
colored-sweep proof.

Acceptance gate: at least one pairwise and one multi-vertex example has a proved valid coloring,
and the effect of adding a live interaction is stated exactly.

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
bounds. Phase 5 takes the solver map and its designated fixed point as parameters. Phase 7 supplies
the concrete VBD map and its fixed-point identification.

Acceptance gate: the theorem is solver-independent and uses the Phase 1 and Phase 3 interfaces.

# Phase 6 — Contraction of composed updates

Status: planned. Module: `Vbd/Block/Contraction.lean`.

Dependencies: Phase 2 + Phase 3.

For an externally ordered differentiable update sequence, record block bounds for each derivative
factor through nonnegative matrices `C⁽ʳ⁾` satisfying

$$
\|(DU_r(x_{r-1}))_{ij}v_j\| \le C^{(r)}_{ij}\|v_j\|.
$$

Prove:

1. reconstruction of global operator bounds from block-entry bounds;
2. propagation of comparison bounds through externally ordered composition;
3. bounds for commuting color batches using their order-independent composition;
4. separate bounds for buffered simultaneous batches with same-color coupling;
5. an explicit contraction criterion in a stated block norm;
6. perturbation bounds for approximate derivatives or execution maps.

Acceptance gate: explicit block-entry bounds for supplied serial or color-batched update operators
compose according to their actual execution semantics and produce a `q < 1` contraction
certificate using the block and dynamics foundations.

# Phase 7 — Production VBD synthesis

Status: planned. Initial module: `Vbd/Integrator/VBD.lean`.

Dependencies: Phases 4, 5, and 6.

Define the actual unsafeguarded VBD block-update operators. External serial and buffered colored
execution plans apply those operators. The block computation is the full block-Newton update

$$
H_{ii}(x)p_i=-F_{IE,i}(x),
\qquad
U_i(x)=x+\iota_i p_i,
$$

including the production skip behavior when a block Hessian is judged singular. Each complete
execution is exposed as a map on `BlockSum B`; controller ordering and buffer semantics remain
explicit inputs to its construction. The required result chain is:

1. identify regular states where every block update follows the nonsingular branch;
2. show that a regular fixed point of a complete sweep is an implicit-Euler solution;
3. differentiate the externally ordered serial composition and identify its derivative with the
   corresponding block Gauss-Seidel error operator;
4. use `M / h² + ∇²P` to prove block invertibility and quantitative inverse bounds;
5. bound cross-block coupling and obtain an explicit contraction factor `q`;
6. control Hessian variation on a neighborhood so the linear bound extends to the nonlinear sweep;
7. prove commutation of concrete same-color operators under a valid static coloring, relate their
   simultaneous batches to serial composition, and analyze the buffered map when live collision
   interactions create same-color coupling;
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

Each convergence theorem includes the external serial or colored execution plan and its
off-diagonal coupling in addition to any positive-definiteness or condition-number assumptions.

Acceptance gate: at least one concrete finite-support implicit-Euler system instantiates the whole
chain for the production full-step update, with all regularity, coloring, and neighborhood
hypotheses explicit.

# Secondary and deferred routes

Energy-change identities, local or sweep monotonicity, line search, convex minimization, and KL
arguments form secondary routes activated by a named target theorem or compatible solver variant.

Deferred work includes global behavior beyond a certified contractive neighborhood, probabilistic
convergence after a concrete randomness model is selected, fully dynamic collision scheduling,
floating-point and GPU execution error, optimization-error accumulation across time steps,
discretization error, and generalized mass-matrix specializations beyond the first accepted
production theorem.
