---
type: Module Plan
title: Lean Module Map
description: Maps the goal-first roadmap to small Lean modules and explicit dependency boundaries.
tags: [lean4, modules, architecture, implementation-plan]
timestamp: 2026-09-16T00:00:00Z
---

# Foundation modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P1 | `Integrator/ImplicitEulerEnergy.lean` | Implemented incremental objective, gradient/residual, and Hessian identities | none |
| P2 | `Block/Basic.lean` | `BlockSum B`, native coordinate access, injections, and replacements | none |
| P2 | `Block/Update.lean` | Write support under composition and simultaneous merging | `Block/Basic` |
| P2 | `Block/Operator.lean` | Continuous block entries, finite assembly and reconstruction, and block-matrix arithmetic | `Block/Basic` |
| P3 | `Dynamics/Contraction.lean` | Implemented local fixed-point and finite-iterate interfaces; derivative extension is next; perturbation extension is deferred | none |

# Bridge and synthesis modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P4 | `Integrator/LocalPotential.lean` | Implemented finite-support potential components, exact cancellation, and support-to-Mathlib-graph/coloring bridge lemmas | `ImplicitEulerEnergy`, `Block/Basic` |
| P5 | `Integrator/FixedPoint.lean` | Solver-independent convergence from a contractive map to a known [implicit-Euler stationary fixed point](/mathematics/implicit-euler-fixed-points.md) | `ImplicitEulerEnergy`, `Dynamics/Contraction` |
| P6 | `Block/Contraction.lean` | Derivative-factor bounds, ordered comparison composition, proper-color estimates, and deferred perturbation extensions | `Block/Update`, `Block/Operator`, `Dynamics/Contraction` |
| P7 | `Integrator/VBD.lean` | Production block-Newton operators, externally controlled serial and buffered executions, derivative bounds, and end-to-end finite-sweep result | P4, P5, P6 modules |

These paths are the current module boundaries recorded in the central
[roadmap](/project/roadmap.md) and [backlog](/project/backlog.md).

# Initial build order

Phases 1 and 2 are complete. `Block/Update.lean` and `Block/Operator.lean` each depend only on
`Block/Basic.lean` within the project.
Phase 3 has an implemented, block-independent core covering CT-01–CT-03 and reusing the pinned
Mathlib contraction API. The [axial-spring contraction analysis](/mathematics/axial-spring-contraction.md) and
[AP-03 decision](/project/applicability-decision.md) authorize CT-04 and the exact-execution
Phase 4–7 route. CT-05 and same-color coupling estimates are deferred. Exploratory derivations and diagnostic scripts
introduce no cross-foundation Lean imports; the module dependency boundaries stay in force.

The three foundations may be implemented independently:

```text
Integrator/ImplicitEulerEnergy
Block/Basic -> Block/Update
           -> Block/Operator
Dynamics/Contraction
```

Bridge modules introduce cross-foundation imports. `Block/*` contains block-state and
block-operator declarations; `Dynamics/Contraction` contains generic metric and normed-space
fixed-point declarations.

# Representation and norm boundary

Phase 1 retains `X` as an abstract real Hilbert-space parameter. Phase 2 uses `B : ι → Type*` and
`BlockSum B := PiLp 2 B`. Coordinate algebra states its typeclass requirements declaration by
declaration. P6 uses a theorem-local maximum norm or equivalent metric for the accepted chain certificate,
with explicit transport to the existing finite `ℓ²` block representation. Generic derivative
lemmas remain norm-polymorphic; weighted and energy norms are options for later assessments.

# Reuse acceptance condition

CT-04, IF-01–IF-03 and BC-01–BC-03/BC-05 expose generic norm, residual-regularity and
block-comparison hypotheses. They must support vector-valued blocks and finite component-support
systems without embedding the chain's degree, constitutive coefficients or scalar sign lemmas.
P7 separates the general block-Newton map, skip-free consistency and derivative identities
from the chain's concrete inverse, box-invariance and accuracy instantiations. The chain is the
first application; these generic results are required deliverables in the same theorem route.
The [adaptation analysis](/mathematics/axial-spring-contraction.md#reuse-beyond-the-chain) specifies
which hypotheses richer models must discharge and which friction/contact extensions need new
interfaces. Source file splitting within P7 follows this boundary when implementation warrants it.

# Documentation boundary

Document module APIs, assumptions, representation choices, and proof details in the corresponding
Lean source. Keep this bundle focused on cross-module architecture, current roadmap state,
mathematical specifications, dependency assessments, and external references.

# Implementation status

`Integrator/ImplicitEulerEnergy.lean` implements Phase 1. The three Phase 2 modules implement
heterogeneous block operations, exact write support under ordinary composition, disjoint
snapshot merging with commuting sequential equivalence, and continuous-linear block-matrix
assembly, reconstruction, and arithmetic. Preserved linear output blocks are characterized by
identity block rows. All implemented foundation modules are exported by `Vbd.lean`.

`Dynamics/Contraction.lean` implements CT-01–CT-03 using Mathlib contraction and Lipschitz
iteration results. It supplies local fixed-point existence and uniqueness, convergence to a
supplied fixed point, finite-iterate distance bounds, and a defect-based error estimate, with
no project imports. AP-01–AP-03 are complete research deliverables. CT-04 is next; exact-execution P4–P7 follows
the accepted route, while CT-05 and hybrid coupling are deferred.

`Integrator/LocalPotential.lean` implements Phase 4. It sums support-indexed local components,
proves cancellation outside the affected supports of a block change, constructs the component
interaction graph, and uses Mathlib's numbered proper colorings for the support-local coloring
bridges. It is exported by `Vbd.lean`.
