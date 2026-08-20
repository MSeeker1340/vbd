---
type: Mathematical Specification
title: Implicit Euler as Optimization
description: Specifies the incremental objective and the stationarity equivalence targeted in Phase 1.
tags: [implicit-euler, gradient, hessian, stationary-point]
timestamp: 2026-08-20T00:00:00Z
---

# Data

Let `X` be a finite-dimensional real inner-product space, `h > 0` a timestep, `y : X` a predicted position, `M : X → X` a self-adjoint mass operator, and `E : X → ℝ` a potential energy. Define the weighted quadratic form by

$$
\lVert z\rVert_M^2 = \langle z, Mz\rangle
$$

and the incremental objective

$$
G_{\mathrm{IE}}(x)
=\frac{1}{2h^2}\langle x-y,M(x-y)\rangle+E(x).
$$

The derivative identity requires self-adjointness of `M` to simplify the derivative of the quadratic term to `M(x-y)/h²`. Positive definiteness is not needed for this identity; it belongs to [curvature strengthening](/mathematics/curvature.md).

# Phase-1 theorem targets

Under differentiability of `E` at `x`, prove

$$
\nabla G_{\mathrm{IE}}(x)
=\frac{1}{h^2}M(x-y)+\nabla E(x).
$$

Define the implicit-Euler residual by

$$
R_{\mathrm{IE}}(x)=\frac{1}{h^2}M(x-y)+\nabla E(x),
$$

then prove the pointwise equivalence

$$
R_{\mathrm{IE}}(x)=0
\iff
\nabla G_{\mathrm{IE}}(x)=0.
$$

This is an equivalence with stationarity, not with global minimization.

Under twice differentiability, represent and prove

$$
\nabla^2G_{\mathrm{IE}}(x)=\frac{1}{h^2}M+\nabla^2E(x).
$$

# Assumption ledger

| Claim | Needed assumptions |
|---|---|
| Definition of `G_IE` | inner product, scalar `h ≠ 0`, linear `M` |
| Simplified gradient formula | differentiability of `E`, continuity of `M`, self-adjoint `M`, `h ≠ 0` |
| Residual iff stationarity | gradient formula only |
| Hessian sum formula | a selected second-derivative representation and twice differentiability of `E` |
| Strict/strong convexity | a positive curvature lower bound |
| Unique minimizer | existence plus strict convexity, or a suitable strong-convexity theorem |

# Formalization notes

Use `HasGradientAt`/`HasFDerivAt` witnesses to prove the derivative formula, then derive an equality for Mathlib's total `gradient`. For the first version, a continuous linear operator is likely more natural than a matrix because it keeps the theorem basis-free; add matrix corollaries later. The local particle-mass formula belongs in VBD specialization, not here.

# Citations

[1] [Vertex Block Descent](https://arxiv.org/abs/2403.06321)
[2] [Mathlib gradient API](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Calculus/Gradient/Basic.html)
