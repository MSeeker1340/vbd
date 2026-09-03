---
type: Module Plan
title: Lean Module Map
description: Maps the mathematical roadmap to small Lean modules and explicit dependency boundaries.
tags: [lean4, modules, architecture, implementation-plan]
timestamp: 2026-09-02T00:00:00Z
---

# Planned modules

| Module | Responsibility | Direct project dependencies |
|---|---|---|
| `Optimization/LocalObjective.lean` | Factor supports, locality witnesses, affected factors, exact change identity | none |
| `Optimization/BlockCoordinate.lean` | One-block updates, descent predicates, stationarity bridges | `LocalObjective` |
| `Optimization/GaussSeidel.lean` | Sequential sweeps and monotone descent | `BlockCoordinate` |
| `Optimization/BlockNewton.lean` | Positive-definite block systems, descent direction, line-search interface | `BlockCoordinate` |
| `Optimization/Coloring.lean` | Conflict relation, proper colors, commutation, color-class updates | `LocalObjective`, `BlockCoordinate` |
| `Optimization/Convergence.lean` | Nonconvex, convex, and strongly convex convergence results | stable generic modules |
| `Optimization/Curvature.lean` | Quadratic derivatives, Hessian bounds, strong convexity | generic analysis only |
| `Integrator/ImplicitEulerEnergy.lean` | Implemented: incremental objective, gradient/Hessian formulas, stationarity equivalence | Mathlib analysis only; no VBD |
| `Integrator/VBD.lean` | Vertex blocks, incident force factors, VBD instantiations | optimization modules, `ImplicitEulerEnergy` |

# Initial build order

Although generic optimization is architecturally upstream of the mechanics specialization, the required implementation order begins with `ImplicitEulerEnergy` to stabilize derivative and state-space choices, then builds `LocalObjective`, `BlockCoordinate`, `GaussSeidel`, and `Coloring`. This does not authorize `ImplicitEulerEnergy` assumptions to enter generic modules.

Phase 1 retains a real Hilbert-space state because the calculus identities are basis-free. VBD's
particle algorithms operate after spatial discretization on a finite coordinate space, so Phase 2
must decide whether its block layer starts from that finite state space or preserves the Hilbert
abstraction through block maps. The abstraction has value only if an accepted target theorem
applies before spatial discretization or is reused beyond particle coordinates.

# Documentation boundary

Document module APIs, assumptions, representation choices, and proof details in the corresponding
Lean source, attaching local material to the closest declaration and reserving module docstrings
for module-wide context. Keep this bundle focused on cross-module plans, reusable mathematical
specifications, dependency assessments, external references, and project management; do not mirror
the source tree with one OKF concept per module.

# Implementation status

The first implementation spike grew into the complete Phase 1 module. Its `ImplicitEulerStep` record holds one timestep's physical data and proofs for a self-adjoint mass operator, twice-differentiable potential, and positive timestep. Its VBD-facing interface exports the incremental-energy definitions, global differentiability, gradient identity, and Hessian identity; derivative certificates used to prove these results remain module-private. A generic stationary-point predicate belongs in the optimization layer. It uses Mathlib's canonical potential gradient and a derivative-of-gradient Hessian representation documented in the source module. Curvature bounds remain a later VBD specialization target.
