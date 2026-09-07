---
type: Mathematical Specification
title: Curvature, Coupling, and VBD Contraction
description: Records how the implicit-Euler Hessian controls block inverses, cross-block sensitivity, and local sweep contraction.
tags: [curvature, coupling, hessian, contraction]
timestamp: 2026-09-07T00:00:00Z
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
with the concrete block-update operators, interaction supports, externally supplied execution
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

A quantitative contraction proof bounds the diagonal inverses and off-diagonal interaction coupling
separately, composes them according to the external execution plan, and proves `q < 1` in a stated
block norm.

# Nonlinear neighborhood

A certified radius in the original norm follows from a pointwise derivative bound together with
control of Hessian or sweep-derivative variation on a neighborhood:

$$
\sup_{x\in N}\|DS(x)\|\le q<1.
$$

Together with invariance of `N`, generic fixed-point theory then supplies local convergence and
finite-sweep error bounds.

# Secondary consequences

The same lower curvature bounds may imply convexity, strong convexity, uniqueness, or a descent
direction under their usual extra hypotheses. Control of Hessian variation or a line search can
additionally establish full-step energy decrease.

# Citations

[1] [Mathlib contractive-map API](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Topology/MetricSpace/Contracting.lean)
[2] [Mathlib positive-definite matrices](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
