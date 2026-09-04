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
| Phase 2 — block sums and linear operator algebra | active | `BS-02`: define continuous coordinate inclusions and block entries of linear operators |
| Phase 3 — contractive fixed-point iteration | planned | begins after the narrow Mathlib contraction API wrapper is scoped |
| Phase 4 — local interactions and coloring | planned | combines the Phase 1 potential with Phase 2 block states and derives physical conflict structure |
| Phase 5 — implicit-Euler fixed-point goals | planned | combines Phase 1 stationary solutions with Phase 3 solver-independent iteration bounds |
| Phase 6 — contraction from block-operator bounds | planned | combines Phase 2 linear operator algebra with Phase 3 contraction theory |
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

# Phase 2 — Block sums and linear operator algebra

Status: active. Modules: `Vbd/Block/Basic.lean` and `Vbd/Block/Operator.lean`.

Reserve `X` for a total space, use `B : ι → Type*` for heterogeneous block spaces, and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Phase 2 develops the objective-independent algebra of block-indexed states and continuous linear
operators:

1. native coordinate access, single-coordinate injection, and replacement;
2. continuous single-coordinate inclusions and `(i,j)` block entries of continuous linear maps;
3. assembly and reconstruction of operators from finite heterogeneous block matrices;
4. entrywise formulas for identity, addition, scalar multiplication, and composition;
5. diagonal, earlier-block, and later-block splitting relative to a finite order;
6. same-color and cross-color splitting relative to a finite coloring.

`BlockSum.replace` is the primitive coordinate write. The phase vocabulary consists of block
states and continuous linear operators. Concrete replacement-value computations and complete
serial or colored VBD sweeps enter in Phase 7. Algebraic and analytic assumptions remain local to
the declarations that use them, and the core results support infinite-dimensional blocks.

Acceptance gate: later derivative and contraction proofs can express a linearized sweep as a
finite heterogeneous block matrix and recover its ordered or colored splitting using the block
foundation alone.

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

# Phase 6 — Contraction from block-operator bounds

Status: planned. Module: `Vbd/Block/Contraction.lean`.

Dependencies: Phase 2 + Phase 3.

For a differentiable complete sweep map `S`, record the derivative's block entries through
nonnegative bounds of the form

$$
\|(DS(x))_{ij}v_j\| \le C_{ij}\|v_j\|.
$$

The nonnegative family `C` is a comparison operator. Prove:

1. reconstruction of a global derivative bound from block-entry bounds;
2. an explicit contraction criterion in a stated block norm;
3. bounds specialized to an ordered diagonal/earlier/later splitting;
4. bounds specialized to a same-color/cross-color splitting;
5. perturbation bounds for approximate derivatives or execution maps.

Acceptance gate: explicit block-entry bounds for an arbitrary differentiable self-map produce a
`q < 1` contraction certificate using the block and dynamics foundations.

# Phase 7 — Production VBD synthesis

Status: planned. Initial module: `Vbd/Integrator/VBD.lean`.

Dependencies: Phases 4, 5, and 6.

Define the actual unsafeguarded serial and buffered colored VBD sweeps. Their block computation is
the full block-Newton update

$$
H_{ii}(x)p_i=-F_{IE,i}(x),
\qquad
U_i(x)=x+\iota_i p_i,
$$

including the production skip behavior when a block Hessian is judged singular. A complete sweep
is exposed as a map on `BlockSum B`; implementation-local scheduling and buffer data may remain
encapsulated by its definition. The required result chain is:

1. identify regular states where every block update follows the nonsingular branch;
2. show that a regular fixed point of a complete sweep is an implicit-Euler solution;
3. differentiate the complete serial sweep and identify its derivative with the
   schedule-dependent block Gauss-Seidel error operator;
4. use `M / h² + ∇²P` to prove block invertibility and quantitative inverse bounds;
5. bound cross-block coupling and obtain an explicit contraction factor `q`;
6. control Hessian variation on a neighborhood so the linear bound extends to the nonlinear sweep;
7. relate the concrete buffered colored sweep to serial execution under a valid static coloring,
   and analyze the actual hybrid map when live collision interactions create same-color coupling;
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

Each convergence theorem includes the chosen serial or colored splitting and its off-diagonal
coupling in addition to any positive-definiteness or condition-number assumptions.

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
