---
type: Project Roadmap
title: VBD Formalization Roadmap
description: Defines the phased theorem program and the required initial implementation order.
tags: [roadmap, implicit-euler, block-coordinate, vbd]
timestamp: 2026-08-21T00:00:00Z
---

# Phase 1 — Implicit Euler as optimization

Define the [implicit-Euler objective](/mathematics/implicit-euler.md), prove its gradient and second-derivative identities, and prove that the implicit-Euler residual equation is equivalent to stationarity. Use stationary points as the default solution concept; add minimum or uniqueness conclusions only under stated curvature hypotheses.

Status: complete. The implementation and its assumptions are documented in `Vbd/Integrator/ImplicitEulerEnergy.lean`.

# Phase 2 — Generic local block optimization

Develop, independently of mechanics:

1. local/global objective-change equivalence for one block update;
2. locality of block gradients and block Hessians;
3. local descent implies global descent;
4. monotone descent across sequential Gauss–Seidel sweeps;
5. local Newton descent under suitable block-Hessian and line-search assumptions;
6. stationary/global convergence under separately stated nonconvex, convex, and strongly convex assumptions;
7. commuting independent block updates and graph-colored parallel classes.

Prefer instantiating reusable convergence results when their hypotheses match. The [Tseng reference](/references/tseng-2001.md) and [Lean 4 Optlib assessment](/references/optlib-lean4.md) are starting points, not automatic imports.

# Phase 2B — Curvature strengthening

For `G = Q + R` with

$$
Q(x)=\frac12(x-y)^T A(x-y), \qquad A\succ0,
$$

prove the Hessian sum rule and derive strong convexity from a lower bound `∇²R(x) ⪰ -B` together with `A-B ≻ 0`. Do not assume `A` is diagonal unless required by a downstream specialization.

# Phase 3 — VBD specialization

Instantiate the theory for the implicit-Euler objective. Targets include particle-coordinate mass locality, curvature contributed by `M/h²`, locality-preserving non-diagonal masses where feasible, VBD block-Hessian and conditioning results, finite-sweep error, per-step solver error, accumulation across timesteps, and separation of time-discretization error from finite-optimization error.

# Required initial order

```text
ImplicitEulerEnergy
→ LocalObjective
→ BlockCoordinate
→ GaussSeidel
→ Coloring
```

Convergence rates, timestep-error accumulation, and generalized mass matrices remain deferred until these definitions and basic descent lemmas stabilize. Current status and acceptance criteria live in the [backlog](/project/backlog.md).
