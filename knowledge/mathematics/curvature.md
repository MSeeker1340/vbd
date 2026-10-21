---
type: Mathematical Specification
title: Curvature, Coupling, and VBD Contraction
description: Records how the implicit-Euler Hessian controls block inverses, cross-block sensitivity, and local sweep contraction.
tags: [curvature, coupling, hessian, contraction]
timestamp: 2026-10-21T02:02:26Z
---

# Implicit-Euler Hessian

For

```math
G(x)=\frac12\langle x-y,A(x-y)\rangle+P(x),
```

Phase 1 gives

```math
\nabla^2G(x)=A+\nabla^2P(x).
```

In the standard implicit-Euler specialization, `A = M / h²`. VBD analysis combines this identity
with the concrete block-update operators, potential-component supports, externally supplied execution
plan, and selected norm.

# Block inverse bounds

For every block direction $`v`$, suppose the mass and potential bounds are

```math
m_i\|v\|^2\le\langle v,M_{ii}v\rangle,
\qquad
-\kappa_i\|v\|^2\le\langle v,(\nabla^2P(x))_{ii}v\rangle.
```

The implicit-Euler identity gives

```math
\mu_i=\frac{m_i}{h^2}-\kappa_i,
\qquad
\mu_i\|v\|^2\le\langle v,H_{ii}(x)v\rangle.
```

When $`\mu_i>0`$, Cauchy–Schwarz gives $`\mu_i\|v\|\le\|H_{ii}(x)v\|`$.
For finite-dimensional real Hilbert blocks, this establishes invertibility and

```math
\|H_{ii}(x)^{-1}\|\le\mu_i^{-1}.
```

Uniform mass and potential bounds yield this same explicit estimate throughout any supplied
state region. Bounded negative potential curvature is allowed; nonnegative potential curvature
uses $`\kappa_i=0`$. These inverse estimates do not require sparsity or symmetry assumptions.
`Integrator/VBDCurvature.lean` implements the quadratic-form, invertibility, and uniform
inverse-norm conclusions for the actual IE Newton blocks.

In a scalar block, the determinant is the coefficient itself, so
$`\varepsilon<\mu_i`$ guarantees the production regular branch throughout the region.
The implemented scalar certificate supplies the regularity premise of the fixed-point and root
linearization results. For higher-dimensional blocks, acceptance by a positive determinant
threshold requires a determinant comparison in addition to invertibility.

# Coupling and the contraction factor

The derivative of a block-Newton update contains normalized off-diagonal blocks such as

```math
H_{ii}(x)^{-1}H_{ij}(x).
```

The contraction factor of a serial or colored execution depends on these terms and on the actual
ordered-composition or simultaneous-batch semantics. A Gauss–Seidel contraction theorem combines
diagonal positivity with quantitative off-diagonal coupling propagated through that composition.

A quantitative contraction proof bounds the diagonal inverses and off-diagonal component coupling
separately, composes them according to the external execution plan, and proves `q < 1` in a stated
block norm.

For coercivity constants $`\mu_i>0`$ and off-diagonal bounds $`\|H_{ij}\|\le c_{ij}`$,

```math
\sum_{j\ne i}\|H_{ii}^{-1}H_{ij}\|
\le\mu_i^{-1}\sum_{j\ne i}c_{ij}.
```

A common row bound $`q\le1`$ propagates through a serial Gauss–Seidel error sweep when the
visit order covers every block. For $`q<1`$, the sweep's root error operator contracts in the
block maximum norm. `Integrator/VBDCoupling.lean` implements this inference using the
Phase-6 changed-row comparison product, including repeated visits and heterogeneous vector blocks.
The norm conversion constants are explicit:

```math
\|x\|_{\max}\le\|x\|_2\le\sqrt{n}\,\|x\|_{\max}.
```

The maximum-norm factor concerns the conjugated state operator; the conversion to $`\ell^2`$
error is a separate estimate.

For the scalar hardening spring law in the accepted radius-$`0.1`$ box, write
$`w_{ij}=b_{ij}[1+3\eta(u_i-u_j)^2]`$ and $`s_i=\sum_j w_{ij}`$.
With $`0\le\eta\le1`$, nonnegative edge coefficients with zero diagonal, $`a_i\ge1`$, and
$`\sum_j b_{ij}\le a_i/2`$,

```math
s_i\le\frac{14}{25}a_i,
\qquad
\sum_{j\ne i}\|H_{ii}^{-1}H_{ij}\|
\le\frac{s_i}{a_i+s_i}\le\frac{14}{39}<1.
```

Degree at most two and $`b_{ij}\le\alpha\le1/4`$ supply the incident-stiffness condition.
`Examples/AxialSpring.lean` derives the polynomial residual Jacobian and exact Newton blocks,
proves production regularity for a threshold below $`1`$, and gives this bound for the derivative
of the actual covered serial sweep at a supplied root in the box. Uniform off-root contraction
and initial-state coverage require the nonlinear-neighborhood estimates below.

# Derivative of a block-Newton update

For differentiable block residuals $`R_i(x)`$ and differentiable local solve operators $`K_i(x)`$
that are invertible on the region under consideration, the update replaces $`x_i`$ by
$`x_i-K_i(x)^{-1}R_i(x)`$. Differentiating this expression in block direction $`v_j`$ gives

```math
(DU_i)_{ij}[v_j]=\delta_{ij}v_j-K_i^{-1}D_jR_i[v_j]
 +K_i^{-1}\bigl(D_jK_i[v_j]\bigr)K_i^{-1}R_i.
```

For exact Newton blocks, $`K_i=D_iR_i`$, the diagonal cancellation gives the sufficient bound

```math
\sum_{j\ne i}\|K_i^{-1}D_jR_i\|
 +\|K_i^{-1}\|\,\|K_i^{-1}R_i\|\sum_j\|D_jK_i\|\le q<1.
```

These are operator and block-vector norms, with state norm $`\max_i\|x_i\|`$.
Uniform estimates and intermediate-state invariance let the same ordered-composition proof
apply in any block dimension. An approximate solve matrix contributes the additional term
$`\|I-K_i^{-1}D_iR_i\|`$; it can persist even at a root. Root consistency still follows
from invertibility and once-per-block execution, but the exact Gauss–Seidel identification
requires exact derivative blocks.

At a regular residual root, the inverse-variation term vanishes. With $`H=DR(x^{\ast})`$ and exact
diagonal blocks, the local derivative is

```math
DU_i(x^{\ast})=I-\iota_i H_{ii}^{-1}\pi_i H.
```

Its unchanged rows are identity rows; its changed diagonal entry is zero, and its changed
off-diagonal entries are $`-H_{ii}^{-1}H_{ij}`$. Applied to an error vector $`v`$, the changed block
is $`-H_{ii}^{-1}\sum_{j\ne i}H_{ij}v_j`$. Chronological composition is therefore the block
Gauss–Seidel error sweep in the supplied visit order.

`Integrator/VBDDerivative.lean` implements the full regular-state derivative, its root
specialization, and ordered Gauss–Seidel identification under explicit residual and local-Hessian
differentiability hypotheses and strict acceptance of the production skip test.
`Integrator/VBDNonlinear.lean` implements the per-column inverse-variation estimate and combines
uniform changed-row bounds with per-visit invariance through Phase 6 and CT-04. These generic
interfaces support arbitrary finite-dimensional normed blocks. The
[spring-chain example](./axial-spring-contraction.md) instantiates the nonlinear bounds.

# Nonlinear neighborhood

A certified radius in the original norm follows from a pointwise derivative bound together with
control of Hessian or sweep-derivative variation on a neighborhood:

```math
\sup_{x\in N}\|DS(x)\|\le q<1.
```

On a convex `N`, the derivative bound gives a Lipschitz contraction. Together with invariance
and completeness of a nonempty `N`, [contractive fixed-point iteration](./contractive-fixed-point-iteration.md)
then supplies a unique fixed point in `N`, local convergence, and finite-sweep error bounds.

For the accepted spring range, `Examples/AxialSpringNeighborhood.lean` proves invariance of
the maximum-norm box centered at zero with radius `0.1`. Predictors bounded by `0.05` are
admitted. Static comparison rows retain the incident linear stiffness in the denominator and
bound the force-dependent inverse variation, giving a uniform covered serial factor
`318/625 = 0.5088 < 0.512`. The selected cosine predictor and rest-state warm starts belong to
this box. `Examples/AxialSpringColoring.lean` proves that proper-color buffered execution is
equal to a covered serial order and inherits the same factor, invariant box, and warm-start
coverage. The arbitrary-length nearest-neighbor chain uses its proved even/odd coloring.
VB-08 identifies the energy gradient and derives the physical-input certificate, including
the residual Lipschitz constant `53/25`, predictor-box root location, and residual below
`3.25 × 10⁻⁷ < 10⁻⁶` after 20 sweeps for both accepted execution plans.

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
