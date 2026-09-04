---
type: Library Inventory
title: Pinned Mathlib API Inventory
description: Records calculus, block-product, and fixed-point APIs confirmed in the repository's pinned Mathlib checkout.
resource: ../.lake/packages/mathlib/Mathlib
tags: [mathlib, lean4, gradient, block-product, contraction]
timestamp: 2026-09-04T00:00:00Z
---

# Audit basis

This inventory was checked against the local Mathlib revision locked by `lake-manifest.json`.
Each first use receives compile-time confirmation.

# Differentiation and gradients

`Mathlib/Analysis/Calculus/Gradient/Basic.lean` provides:

- `HasGradientAtFilter`, `HasGradientWithinAt`, and `HasGradientAt`;
- totalized `gradientWithin` and `gradient` definitions;
- equivalences with `HasFDerivAt` and conversions in both directions;
- uniqueness and recovery lemmas such as `HasGradientAt.gradient` and `gradient_eq`;
- `HasGradientAt.fderiv_apply` for converting gradient witnesses to derivative evaluation.

The total `gradient` is zero at nondifferentiable points, so derivative hypotheses should remain explicit in correctness theorems.

For second derivatives, Mathlib has `fderiv`, differentiability of continuous-linear and bilinear
maps, and `iteratedFDeriv`. The project represents a Hessian as the Fréchet derivative of the
gradient.

# Convexity and extrema

`Mathlib/Analysis/Convex/Strong.lean` provides `StrongConvexOn`, defined through uniform convexity with modulus `m/2 * r²`, plus:

- `strongConvexOn_iff_convex` in real inner-product spaces;
- monotonicity in the modulus;
- `StrongConvexOn.strictConvexOn` when `0 < m`.

`Mathlib/Analysis/Convex/Function.lean` includes uniqueness of minimizers for strictly convex functions (`StrictConvexOn.eq_of_isMinOn`). `Mathlib/Analysis/Convex/Extrema.lean` connects local and global minima for convex functions. `Mathlib/Analysis/Convex/Deriv.lean` contains derivative-based convexity/minimum results, with many scalar-domain theorems.

# Positive operators and matrices

`Mathlib/LinearAlgebra/Matrix/PosDef.lean` provides `Matrix.PosSemidef` and `Matrix.PosDef`, including Hermitian content, sums of semidefinite matrices, positive-definite principal submatrices, and invertibility/unit consequences. `Mathlib/Analysis/Matrix/PosDef.lean` and `Mathlib/Analysis/InnerProductSpace/Positive.lean` connect matrix positivity and positive continuous linear maps in analytic settings.

`PosDef` supplies qualitative positivity. Quantitative strong-convexity statements additionally
use an explicit positive lower bound.

# Finite products and sums

The project defines `BlockSum B := PiLp 2 B`, where `B : ι → Type*` is the heterogeneous block
family and `X` remains reserved for a total space. `PiLp 2 B` is a type copy of the dependent
function space `(i : ι) → B i`; its type formation accepts an arbitrary block family, and it
coerces back to a function for native coordinate application. Block replacement is `WithLp.toLp 2` applied
to `Function.update` of `WithLp.ofLp`; its same-coordinate and other-coordinate laws simplify
directly. Mathlib's `Function.update_self`, `Function.update_of_ne`, and update commutation lemmas
provide the underlying API.

For analytic results, `Mathlib.Analysis.InnerProductSpace.PiL2` gives `BlockSum B` finite-product
normed-additive, inner-product, and completeness instances when `ι` is finite and every `B i` has
the corresponding structure. `PiLp.proj` is the continuous coordinate projection. A continuous
single-coordinate inclusion can be formed by composing `ContinuousLinearMap.single` with the
inverse of `PiLp.continuousLinearEquiv`; `PiLp.single` is its pointwise value-level counterpart. The
analytic boundary retains the same representation. Exact finite-factor results support
infinite-dimensional blocks.

# Contractive fixed points

`Mathlib/Topology/MetricSpace/Contracting.lean` defines `ContractingWith K f` as `K < 1` together
with `LipschitzWith K f`. It provides Banach fixed points on complete metric spaces, convergence of
iterates, a priori distance estimates, and restriction to forward-invariant subsets. Phase 3 wraps
the declarations needed for the project's local-ball, derivative-bound, and perturbation
interfaces.

The existing API is norm-agnostic. The later block-contraction layer turns a spectral-radius bound
into a convergence result through a direct norm bound, an appropriate equivalent norm, or a
suitable iterate result.

# Citations

[1] [Mathlib gradient documentation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Calculus/Gradient/Basic.html)
[2] [Mathlib strong-convexity source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Analysis/Convex/Strong.lean)
[3] [Mathlib positive-definite matrix source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
[4] [Mathlib contractive-map source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Topology/MetricSpace/Contracting.lean)
