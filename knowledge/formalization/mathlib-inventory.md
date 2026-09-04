---
type: Library Inventory
title: Pinned Mathlib API Inventory
description: Records calculus, block-product, and fixed-point APIs confirmed in the repository's pinned Mathlib checkout.
resource: ../.lake/packages/mathlib/Mathlib
tags: [mathlib, lean4, gradient, block-product, contraction]
timestamp: 2026-09-04T00:00:00Z
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

The project defines `BlockSum B := PiLp 2 B`, where `B : ι → Type*` is the heterogeneous block
family and `X` remains reserved for a total space. `PiLp 2 B` is a type copy of the dependent
function space `(i : ι) → B i`; it can be formed without norm or topology instances and coerces
back to a function for native coordinate application. Block replacement is `WithLp.toLp 2` applied
to `Function.update` of `WithLp.ofLp`; its same-coordinate and other-coordinate laws simplify
directly. Mathlib's `Function.update_self`, `Function.update_of_ne`, and update commutation lemmas
provide the underlying API.

For analytic results, `Mathlib.Analysis.InnerProductSpace.PiL2` gives `BlockSum B` finite-product
normed-additive, inner-product, and completeness instances when `ι` is finite and every `B i` has
the corresponding structure. `PiLp.proj` is the continuous coordinate projection. A continuous
single-coordinate inclusion can be formed by composing `ContinuousLinearMap.single` with the
inverse of `PiLp.continuousLinearEquiv`; `PiLp.single` is its pointwise value-level counterpart. No
representation conversion is required at the analytic boundary, and exact finite-factor results
do not require finite-dimensional blocks.

# Contractive fixed points

`Mathlib/Topology/MetricSpace/Contracting.lean` defines `ContractingWith K f` as `K < 1` together
with `LipschitzWith K f`. It provides Banach fixed points on complete metric spaces, convergence of
iterates, a priori distance estimates, and restriction to forward-invariant subsets. Phase 3 should
wrap these declarations only where the project needs a more convenient local-ball,
derivative-bound, or perturbation interface.

The existing API is norm-agnostic. A spectral-radius bound for a linearized sweep is not directly a
`ContractingWith` proof in the current norm; the later block-contraction layer must establish a
direct norm bound, choose an appropriate equivalent norm, or prove a suitable iterate result.

# Citations

[1] [Mathlib gradient documentation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Calculus/Gradient/Basic.html)
[2] [Mathlib strong-convexity source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Analysis/Convex/Strong.lean)
[3] [Mathlib positive-definite matrix source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
[4] [Mathlib contractive-map source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Topology/MetricSpace/Contracting.lean)
