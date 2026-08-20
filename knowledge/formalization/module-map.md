---
type: Module Plan
title: Lean Module Map
description: Maps the mathematical roadmap to small Lean modules and explicit dependency boundaries.
tags: [lean4, modules, architecture, implementation-plan]
timestamp: 2026-08-20T00:00:00Z
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
| `Integrator/ImplicitEulerEnergy.lean` | Incremental objective, gradient/Hessian formulas, stationarity equivalence | generic analysis; no VBD |
| `Integrator/VBD.lean` | Vertex blocks, incident force factors, VBD instantiations | optimization modules, `ImplicitEulerEnergy` |

# Initial build order

Although generic optimization is architecturally upstream of the mechanics specialization, the required implementation order begins with `ImplicitEulerEnergy` to stabilize derivative and state-space choices, then builds `LocalObjective`, `BlockCoordinate`, `GaussSeidel`, and `Coloring`. This does not authorize `ImplicitEulerEnergy` assumptions to enter generic modules.

# Module documentation template

Each real Lean module should eventually have a corresponding OKF concept under `formalization/modules/` containing:

- purpose and non-goals;
- public definitions and main theorems;
- mathematical assumptions;
- direct imports and downstream consumers;
- proof status and known gaps;
- links to the relevant mathematical specification and scoped entry in the [formalization update log](/formalization/log.md).

Do not create empty module concepts before the source modules exist.

# First implementation spike

Create a minimal `Integrator/ImplicitEulerEnergy.lean` that tests:

1. the chosen finite-dimensional real inner-product space assumptions;
2. a self-adjoint continuous linear mass operator;
3. differentiation of `x ↦ (2*h^2)⁻¹ * ⟪x-y, M (x-y)⟫_ℝ`;
4. composition with an abstract `E` through a `HasGradientAt` hypothesis.

The spike is accepted when it compiles without introducing mechanics-specific types or an unreviewed dependency.
