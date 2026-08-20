---
type: Mathematical Specification
title: Generic Block-Coordinate Descent
description: Specifies block updates, Gauss–Seidel sweeps, local Newton descent, and separated convergence regimes.
tags: [block-coordinate-descent, gauss-seidel, newton, convergence]
timestamp: 2026-08-20T00:00:00Z
---

# Update hierarchy

Build the theory in increasing strength:

1. A block update changes one coordinate and leaves all others fixed.
2. A locally descending update does not increase the global objective by the [local/global identity](/mathematics/local-decomposition.md).
3. A finite sequential fold of descending updates is a Gauss–Seidel sweep and is globally monotone.
4. A local Newton direction gives descent only under explicit assumptions on the block derivative, block Hessian, and step selection.

The basic sweep theorem should accept an abstract update rule satisfying a descent predicate. Exact block minimization and Newton/line-search updates should be later instances, not baked into the sweep definition.

# Stationarity notions

Keep these distinct:

- **Blockwise minimum**: no single-block replacement lowers the objective.
- **Coordinatewise stationarity**: every block derivative is zero or has no feasible descending direction.
- **Stationarity**: the full derivative vanishes, or all directional derivatives are nonnegative in a nonsmooth formulation.
- **Global minimum**: the objective is no larger than at any state.

For differentiable objectives on a product space whose block injections span the full space, vanishing of all block derivatives should imply full stationarity. For nonsmooth objectives, Tseng requires a regularity bridge; see the [Tseng notes](/references/tseng-2001.md).

# Local Newton descent

For block gradient `gᵢ` and self-adjoint positive-definite block Hessian `Hᵢ`, the Newton direction `pᵢ = -Hᵢ⁻¹gᵢ` satisfies

$$
\langle g_i,p_i\rangle<0
$$

when `gᵢ ≠ 0`. Turning that direction into objective decrease additionally needs a line-search or local model theorem. The VBD implementation's choice to skip an update when its local Hessian is unsuitable is an algorithmic specialization, not a generic analytical theorem.

# Convergence strata

Formalize convergence claims in separate layers:

- **Nonconvex**: under compactness/level-boundedness, continuity, selection fairness, sufficient decrease, and a stationarity bridge, prove cluster-point stationarity where justified.
- **Convex**: add convexity to turn suitable stationary points into global minimizers.
- **Strongly convex**: add positive modulus to obtain uniqueness and then rates only with the further smoothness/error-bound assumptions actually used.

Do not infer whole-sequence convergence or a rate from monotone objective values alone.

# Citations

[1] [Tseng, Convergence of a Block Coordinate Descent Method for Nondifferentiable Minimization](https://www.mit.edu/~dimitrib/PTseng/papers/archive/bcr_jota.pdf)
[2] [Formalization of Algorithms for Optimization with Block Structures](https://arxiv.org/abs/2503.18806)
