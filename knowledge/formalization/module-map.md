---
type: Module Plan
title: Lean Module Map
description: Maps the goal-first roadmap to small Lean modules and explicit dependency boundaries.
tags: [lean4, modules, architecture, implementation-plan]
timestamp: 2026-09-04T00:00:00Z
---

# Foundation modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P1 | `Integrator/ImplicitEulerEnergy.lean` | Implemented incremental objective, gradient/residual, and Hessian identities | none |
| P2 | `Block/Basic.lean` | `BlockSum B`, native coordinate access, injections, and replacements | none |
| P2 | `Block/Operator.lean` | Continuous block inclusions, block entries, reconstruction, arithmetic, and ordered or colored splittings | `Block/Basic` |
| P3 | `Dynamics/Contraction.lean` | Thin wrappers for local invariant contractions, finite-iterate bounds, derivative criteria, and perturbations | none |

# Bridge and synthesis modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P4 | `Integrator/LocalInteractions.lean` | Finite-support physical interactions, conflict graph, and concrete coloring conditions | `ImplicitEulerEnergy`, `Block/Basic` |
| P5 | `Integrator/FixedPoint.lean` | Solver-independent convergence from a contractive map to a known implicit-Euler stationary fixed point | `ImplicitEulerEnergy`, `Dynamics/Contraction` |
| P6 | `Block/Contraction.lean` | Derivative block-entry bounds, comparison-operator estimates, split bounds, and perturbations | `Block/Operator`, `Dynamics/Contraction` |
| P7 | `Integrator/VBD.lean` | Production serial and buffered colored maps, skip-free region, sweep derivative, inertia/coupling bounds, and end-to-end finite-sweep result | P4, P5, P6 modules |

These paths are the current module boundaries. Split a module only when implementation reveals a
stable reusable boundary; record any split in the central [roadmap](/project/roadmap.md) and
[backlog](/project/backlog.md).

# Initial build order

Phase 1 and `Block/Basic.lean` are complete. The next implementation is the continuous-linear block
entry layer in `Block/Operator.lean`, followed by finite reconstruction and operator arithmetic.
Phase 3 can begin once the pinned Mathlib contraction API has been confirmed, but it must remain
independent of the block modules.

The three foundations may be implemented independently:

```text
Integrator/ImplicitEulerEnergy
Block/Basic -> Block/Operator
Dynamics/Contraction
```

Only the bridge modules introduce cross-foundation imports. In particular, no objective, gradient,
stationarity, or mechanics declaration belongs in `Block/*`, and no block declaration belongs in
`Dynamics/Contraction`.

# Representation and norm boundary

Phase 1 retains `X` as an abstract real Hilbert-space parameter. Phase 2 uses `B : ι → Type*` and
`BlockSum B := PiLp 2 B`. Coordinate algebra adds no Hilbert requirement. P6 selects whatever norm
is stated by its contraction theorem; the existing finite `ℓ²` structure is the initial candidate,
while weighted or energy norms remain theorem-local options.

# Documentation boundary

Document module APIs, assumptions, representation choices, and proof details in the corresponding
Lean source. Keep this bundle focused on cross-module architecture, current roadmap state,
mathematical specifications, dependency assessments, and external references.

# Implementation status

`Integrator/ImplicitEulerEnergy.lean` implements Phase 1. `Block/Basic.lean` implements
`BlockSum B`, native coordinate application, zero-supported injection, and replacement laws without
objective or mechanics dependencies. The remainder of P2 and all P3–P7 modules in this map are
planned; continuous-linear block entries in `Block/Operator.lean` are next.
