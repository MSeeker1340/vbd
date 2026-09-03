---
type: Mathematical Specification
title: Curvature, Coupling, and VBD Contraction
description: Records how the implicit-Euler Hessian controls block inverses, cross-block sensitivity, and local sweep contraction.
tags: [curvature, coupling, hessian, contraction]
timestamp: 2026-09-03T00:00:00Z
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

In the standard implicit-Euler specialization, `A = M / h²`. This identity becomes analytically
useful only after the VBD block splitting, interaction supports, schedule, and norm have been fixed.

# Block inverse bounds

A lower bound

$$
H_{ii}(x)\succeq \mu_i I,
\qquad \mu_i>0,
$$

establishes invertibility of the local Newton system and controls `‖Hᵢᵢ(x)⁻¹‖`. A sufficiently
strong inertia contribution may therefore define a neighborhood in which the production
singular-Hessian skip cannot occur.

# Coupling, not condition number alone

The derivative of a block-Newton update contains normalized off-diagonal blocks such as

$$
H_{ii}(x)^{-1}H_{ij}(x).
$$

The contraction factor of a serial or colored sweep depends on these terms and on the chosen
splitting. Positive definiteness or a favorable global condition number alone is not reported as a
Gauss-Seidel contraction theorem.

The intended quantitative argument bounds the diagonal inverses and off-diagonal interaction
coupling separately, composes them according to the actual schedule, and proves `q < 1` in a stated
block norm.

# Nonlinear neighborhood

A contraction bound for the derivative at one stationary point does not by itself provide a
certified radius in the original norm. Control of Hessian or sweep-derivative variation on a
neighborhood should yield

$$
\sup_{x\in N}\|DS(x)\|\le q<1.
$$

Together with invariance of `N`, generic fixed-point theory then supplies local convergence and
finite-sweep error bounds.

# Secondary consequences

The same lower curvature bounds may imply convexity, strong convexity, uniqueness, or a descent
direction under their usual extra hypotheses. Full-step energy decrease additionally needs control
of Hessian variation or a line search. These are optional consequences rather than the main
production-analysis route.

# Citations

[1] [Mathlib contractive-map API](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Topology/MetricSpace/Contracting.lean)
[2] [Mathlib positive-definite matrices](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
