---
type: Mathematical Specification
title: Curvature, Coupling, and VBD Contraction
description: Records how the implicit-Euler Hessian controls block inverses, cross-block sensitivity, and local sweep contraction.
tags: [curvature, coupling, hessian, contraction]
timestamp: 2026-09-15T00:00:00Z
---

# Implicit-Euler Hessian

For

$$
G(x)=\frac12\langle x-y,A(x-y)\rangle+P(x),
$$

Phase 1 gives

$$
\nabla^2G(x)=A+\nabla^2P(x).
$$

In the standard implicit-Euler specialization, `A = M / h²`. VBD analysis combines this identity
with the concrete block-update operators, potential-component supports, externally supplied execution
plan, and selected norm.

# Block inverse bounds

A lower bound

$$
H_{ii}(x)\succeq \mu_i I,
\qquad \mu_i>0,
$$

establishes invertibility of the local Newton system and controls `‖Hᵢᵢ(x)⁻¹‖`. A sufficiently
strong inertia contribution may therefore certify a neighborhood where the production update uses
the regular branch.

# Coupling and the contraction factor

The derivative of a block-Newton update contains normalized off-diagonal blocks such as

$$
H_{ii}(x)^{-1}H_{ij}(x).
$$

The contraction factor of a serial or colored execution depends on these terms and on the actual
ordered-composition or simultaneous-batch semantics. A Gauss–Seidel contraction theorem combines
diagonal positivity with quantitative off-diagonal coupling propagated through that composition.

A quantitative contraction proof bounds the diagonal inverses and off-diagonal component coupling
separately, composes them according to the external execution plan, and proves `q < 1` in a stated
block norm.

# Derivative of a block-Newton update

For differentiable block residuals $R_i(x)$ and differentiable local solve operators $K_i(x)$
that are invertible on the region under consideration, the update replaces $x_i$ by
$x_i-K_i(x)^{-1}R_i(x)$. Differentiating this expression in block direction $v_j$ gives

$$
(DU_i)_{ij}[v_j]=\delta_{ij}v_j-K_i^{-1}D_jR_i[v_j]
 +K_i^{-1}\bigl(D_jK_i[v_j]\bigr)K_i^{-1}R_i.
$$

For exact Newton blocks, $K_i=D_iR_i$, the diagonal cancellation gives the sufficient bound

$$
\sum_{j\ne i}\|K_i^{-1}D_jR_i\|
 +\|K_i^{-1}\|\,\|K_i^{-1}R_i\|\sum_j\|D_jK_i\|\le q<1.
$$

These are operator and block-vector norms, with state norm $\max_i\|x_i\|$.
Uniform estimates and intermediate-state invariance let the same ordered-composition proof
apply in any block dimension. An approximate solve matrix contributes the additional term
$\|I-K_i^{-1}D_iR_i\|$; it can persist even at a root. Root consistency still follows
from invertibility and once-per-block execution, but the exact Gauss–Seidel identification
requires exact derivative blocks.

These are general analytic bounds for the planned derivative and comparison interfaces.
Their Lean implementation remains TODO in VB-03 and BC-01–BC-05, with CT-04 supplying the
uniform derivative-to-contraction bridge. The
[spring-chain example](./axial-spring-contraction.md) calculates concrete values for these bounds.

# Nonlinear neighborhood

A certified radius in the original norm follows from a pointwise derivative bound together with
control of Hessian or sweep-derivative variation on a neighborhood:

$$
\sup_{x\in N}\|DS(x)\|\le q<1.
$$

On a convex `N`, the derivative bound gives a Lipschitz contraction. Together with invariance
and completeness of a nonempty `N`, [contractive fixed-point iteration](./contractive-fixed-point-iteration.md)
then supplies a unique fixed point in `N`, local convergence, and finite-sweep error bounds.

# Worked example

The [spring-chain example](./axial-spring-contraction.md) instantiates these bounds for quadratic and
quartic springs. It retains the off-root derivative term `f_i ∂D_i/D_i²`, controls every
intermediate block state, and gives a maximum-norm factor below `0.512` for
`h² k_max/m_min ≤ 1/4` on its explicit box. The result supports the selected 20-sweep
physical-residual target; generic nonconvex and collision cases require separate bounds.

# Secondary consequences

The same lower curvature bounds may imply convexity, strong convexity, uniqueness, or a descent
direction under their usual extra hypotheses. Control of Hessian variation or a line search can
additionally establish full-step energy decrease.

# Citations

[1] [Mathlib contractive-map API](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Topology/MetricSpace/Contracting.lean)
[2] [Mathlib positive-definite matrices](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
