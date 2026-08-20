---
type: Library Inventory
title: Pinned Mathlib API Inventory
description: Records relevant APIs confirmed in the repository's pinned Mathlib checkout.
resource: ../.lake/packages/mathlib/Mathlib
tags: [mathlib, lean4, gradient, convexity, matrices]
timestamp: 2026-08-20T00:00:00Z
---

# Audit basis

This inventory was checked against the local Mathlib revision locked by `lake-manifest.json`, not only against moving online documentation. Names still need compile-time confirmation when first used.

# Differentiation and gradients

`Mathlib/Analysis/Calculus/Gradient/Basic.lean` provides:

- `HasGradientAtFilter`, `HasGradientWithinAt`, and `HasGradientAt`;
- totalized `gradientWithin` and `gradient` definitions;
- equivalences with `HasFDerivAt` and conversions in both directions;
- uniqueness and recovery lemmas such as `HasGradientAt.gradient` and `gradient_eq`;
- `HasGradientAt.fderiv_apply` for converting gradient witnesses to derivative evaluation.

The total `gradient` is zero at nondifferentiable points, so derivative hypotheses should remain explicit in correctness theorems.

For second derivatives, Mathlib has `fderiv`, differentiability of continuous-linear and bilinear maps, and `iteratedFDeriv`. No project-level `Hessian` abstraction was found in the initial audit. A Hessian representation is therefore an explicit design task.

# Convexity and extrema

`Mathlib/Analysis/Convex/Strong.lean` provides `StrongConvexOn`, defined through uniform convexity with modulus `m/2 * r²`, plus:

- `strongConvexOn_iff_convex` in real inner-product spaces;
- monotonicity in the modulus;
- `StrongConvexOn.strictConvexOn` when `0 < m`.

`Mathlib/Analysis/Convex/Function.lean` includes uniqueness of minimizers for strictly convex functions (`StrictConvexOn.eq_of_isMinOn`). `Mathlib/Analysis/Convex/Extrema.lean` connects local and global minima for convex functions. `Mathlib/Analysis/Convex/Deriv.lean` contains derivative-based convexity/minimum results, with many scalar-domain theorems.

# Positive operators and matrices

`Mathlib/LinearAlgebra/Matrix/PosDef.lean` provides `Matrix.PosSemidef` and `Matrix.PosDef`, including Hermitian content, sums of semidefinite matrices, positive-definite principal submatrices, and invertibility/unit consequences. `Mathlib/Analysis/Matrix/PosDef.lean` and `Mathlib/Analysis/InnerProductSpace/Positive.lean` connect matrix positivity and positive continuous linear maps in analytic settings.

Potential mismatch: qualitative `PosDef` is not itself a chosen coercivity modulus. Strong-convexity statements may require deriving or assuming an explicit positive lower bound.

# Finite products and sums

The generic locality layer can use `Finset`, finite sums, `Function.update`, and dependent function spaces. Before committing to dependent block types, compile-check the required finite Pi normed-space, complete-space, and inner-product instances. This is the main representation risk identified by the initial audit.

# Citations

[1] [Mathlib gradient documentation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Calculus/Gradient/Basic.html)
[2] [Mathlib strong-convexity source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Analysis/Convex/Strong.lean)
[3] [Mathlib positive-definite matrix source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
