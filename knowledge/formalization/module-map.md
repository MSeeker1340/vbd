---
type: Module Plan
title: Lean Module Map
description: Maps the goal-first roadmap to small Lean modules and explicit dependency boundaries.
tags: [lean4, modules, architecture, implementation-plan]
timestamp: 2026-09-07T00:00:00Z
---

# Foundation modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P1 | `Integrator/ImplicitEulerEnergy.lean` | Implemented incremental objective, gradient/residual, and Hessian identities | none |
| P2 | `Block/Basic.lean` | `BlockSum B`, native coordinate access, injections, and replacements | none |
| P2 | `Block/Update.lean` | Write-local update operators, external finite composition, commutation, and simultaneous batches | `Block/Basic` |
| P2 | `Block/Operator.lean` | Continuous block entries, finite assembly and reconstruction, and block-matrix arithmetic | `Block/Basic` |
| P3 | `Dynamics/Contraction.lean` | Thin wrappers for local invariant contractions, finite-iterate bounds, derivative criteria, and perturbations | none |

# Bridge and synthesis modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P4 | `Integrator/LocalInteractions.lean` | Finite-support physical interactions, conflict graph, and concrete coloring conditions | `ImplicitEulerEnergy`, `Block/Basic` |
| P5 | `Integrator/FixedPoint.lean` | Solver-independent convergence from a contractive map to a known implicit-Euler stationary fixed point | `ImplicitEulerEnergy`, `Dynamics/Contraction` |
| P6 | `Block/Contraction.lean` | Derivative-factor bounds, ordered comparison composition, color-batch estimates, and perturbations | `Block/Update`, `Block/Operator`, `Dynamics/Contraction` |
| P7 | `Integrator/VBD.lean` | Production block-Newton operators, externally controlled serial and buffered executions, derivative bounds, and end-to-end finite-sweep result | P4, P5, P6 modules |

These paths are the current module boundaries recorded in the central
[roadmap](/project/roadmap.md) and [backlog](/project/backlog.md).

# Initial build order

Phase 1 and `Block/Basic.lean` are complete. The next implementation defines write locality and
externally controlled composition in `Block/Update.lean`. The independent continuous-linear entry
layer follows in `Block/Operator.lean`.
Phase 3 begins after confirmation of the pinned Mathlib contraction API and remains independent of
the block modules.

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
declaration. P6 selects the norm stated by its contraction theorem; the existing finite `ℓ²`
structure is the initial candidate, while weighted or energy norms remain theorem-local options.

# Documentation boundary

Document module APIs, assumptions, representation choices, and proof details in the corresponding
Lean source. Keep this bundle focused on cross-module architecture, current roadmap state,
mathematical specifications, dependency assessments, and external references.

# Implementation status

`Integrator/ImplicitEulerEnergy.lean` implements Phase 1. `Block/Basic.lean` implements
`BlockSum B`, native coordinate application, zero-supported injection, and replacement laws using
Mathlib. The remainder of P2 and all P3–P7 modules in this map are planned; write-local update
operators in `Block/Update.lean` are next.
