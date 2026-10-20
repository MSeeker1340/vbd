---
type: Library Inventory
title: Pinned Mathlib API Inventory
description: Records calculus, block-product, graph-coloring, and fixed-point APIs confirmed in the repository's pinned Mathlib checkout.
resource: ../../.lake/packages/mathlib/Mathlib
tags: [mathlib, lean4, gradient, block-product, graph-coloring, contraction]
timestamp: 2026-10-20T00:00:00Z
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

For the production root derivative, `HasFDerivAt.clm_apply` in
`Mathlib.Analysis.Calculus.FDeriv.CompCLM` supplies the operator/vector product rule.
`DifferentiableAt.inverse` in `Mathlib.Analysis.Calculus.FDeriv.Mul` supplies local inversion
regularity for units, with `ContinuousLinearMap.ringInverse_eq_inverse` identifying the operator
inverse. `ContinuousLinearMap.continuous_det` and `ContinuousAt.eventually_lt` keep a strictly
accepted determinant test valid near the root.

For the full off-root derivative, `hasFDerivAt_ringInverse` gives the explicit map
`-ContinuousLinearMap.mulLeftRight` at a unit. `ContinuousLinearEquiv.toUnit` and
`ContinuousLinearMap.inverse_equiv` identify its inverse with the production operator inverse.
`ContinuousLinearMap.opNorm_flip`, `ContinuousLinearMap.le_opNorm`, and
`ContinuousLinearMap.norm_smulRight_apply` bound the operator-valued stiffness variation.
The scalar nonlinear neighborhood uses `pi_norm_le_iff_of_nonneg`, `convex_closedBall`, and
`Real.abs_cos_le_one` for its maximum-norm box and selected predictor membership.

The scalar spring instantiation uses `HasDerivAt.comp_hasFDerivAt`, `HasFDerivAt.sum`,
and `hasFDerivWithinAt_piLp` from `Mathlib.Analysis.Calculus.FDeriv.WithLp` for its polynomial
residual derivative. Quantitative state norm conversions use `PiLp.norm_apply_le` and
`PiLp.lipschitzWith_toLp`; the latter exposes the cardinality power that becomes `sqrt(card ι)`
for `p = 2`.

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

Quantitative finite-dimensional block inverse bounds use `real_inner_le_norm`,
`LinearMap.ker_eq_bot`, `LinearMap.ker_eq_bot'`, `LinearEquiv.ofInjectiveEndo`, and
`LinearEquiv.toContinuousLinearEquiv`. The operator-norm step uses
`ContinuousLinearMap.opNorm_le_bound` and `ContinuousLinearMap.IsInvertible.self_apply_inverse`
for the totalized inverse. `LinearMap.det_ring` identifies a scalar block determinant with its
value on `1`, supplying the positive-threshold bridge. These APIs are available through the
existing Mathlib imports.

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

# Simple graphs and vertex coloring

The pinned `Mathlib/Combinatorics/SimpleGraph/Basic.lean` and
`Mathlib/Combinatorics/SimpleGraph/Coloring/Vertex.lean` supply the Phase-4 graph and coloring
foundation. `SimpleGraph.fromRel` constructs a simple undirected graph from a binary relation,
automatically symmetrizing it and removing loops. The support-induced graph is therefore a project
definition only at the boundary from a finite family of supports to the relation

$$
i,j\longmapsto\exists S\in A,\;\{i,j\}\subseteq S.
$$

For a graph $G$, `G.Coloring (Fin m)` is Mathlib's proper vertex-coloring type with the numbered
colors required by a VBD sweep. `SimpleGraph.Coloring.mk` constructs a coloring from a vertex-to-
color function and an adjacent-vertices-have-distinct-colors proof. `Coloring.valid` supplies that
proof as a reusable theorem, and `Coloring.colorClass` gives the set of blocks assigned a fixed
color. `Coloring.isIndepSet_colorClass` and `Coloring.colorClasses_isPartition` provide the
independence and partition facts for color classes.

`Mathlib/Combinatorics/SimpleGraph/Partition.lean` also provides `SimpleGraph.Partition` and its
equivalence with colorings. Phase 4 uses `G.Coloring (Fin m)` as its primary representation because
the `Fin m` labels directly give the numbered outer execution order. The project proves only the
support-specific bridge lemmas: characterization of adjacency by a common support, equivalence
between a Mathlib coloring and injectivity on each support, and monotonicity under changing the
support family.

`Vbd/Integrator/LocalPotential.lean` compiles this reuse boundary. Its project-local declarations
are limited to support-indexed potentials, their locality and cancellation facts, the
support-induced graph, and bridges between support-wise injectivity and Mathlib colorings.

# Contractive fixed points

The pinned `Mathlib/Topology/MetricSpace/Contracting.lean` supplies Banach theory, including
complete invariant subsets. `ContractingWith K f` is `K < 1 ∧ LipschitzWith K f`, with
`K : ℝ≥0`. Its foundation uses extended metric spaces; metric-space interfaces eliminate
finite-distance side conditions.

| Declarations | Assumptions and reusable result |
|---|---|
| `LipschitzOnWith.mapsToRestrict`, `Set.MapsTo.lipschitzOnWith_iff_restrict` | Turn a set-local Lipschitz bound and `MapsTo` into the Lipschitz bound on the subtype self-map |
| `ContractingWith.restrict` | Restricts an ambient contraction to an invariant subset; a set-local certificate instead uses the preceding Lipschitz bridge with `K < 1` |
| `ContractingWith.exists_fixedPoint'` | `IsComplete s`, invariance, contraction of the restricted map, a seed in `s`, and finite seed-to-image distance give an ambient fixed point in `s`, convergence from the seed, and a geometric `edist` bound |
| `ContractingWith.fixedPoint`, `fixedPoint_isFixedPt`, `fixedPoint_unique`, `tendsto_iterate_fixedPoint` | Chosen fixed point, uniqueness and convergence on a nonempty complete metric space |
| `ContractingWith.fixedPoint_unique'` | Uniqueness of two supplied fixed points in a metric space, without completeness |
| `ContractingWith.tendsto_iterate_efixedPoint'` | Ambient convergence to the selected fixed point of a complete invariant subset |
| `ContractingWith.apriori_dist_iterate_fixedPoint_le` | Distance at iteration `n` bounded by `dist x (f x) * K^n / (1-K)` on a nonempty complete metric space |
| `ContractingWith.aposteriori_dist_iterate_fixedPoint_le` | Distance at iteration `n` bounded by its next-step displacement divided by `1-K` |
| `ContractingWith.dist_le_of_fixedPoint` | Defect bound relative to any supplied fixed point, without completeness |
| `LipschitzWith.iterate`, `LipschitzWith.dist_iterate_succ_le_geometric` | Iteration has Lipschitz factor `K^n`; consecutive displacements have a geometric bound, without requiring `K < 1` |
| `Set.MapsTo.iterate`, `Set.MapsTo.iterate_restrict`, `Function.IsFixedPt.iterate` | Invariant iterates, agreement between subtype and ambient iteration, and preservation of a fixed point under iteration |
| `IsClosed.isComplete`, `Metric.isClosed_closedBall` | Closed sets and closed balls inherit completeness from a complete ambient space |
| `ContractingWith.dist_fixedPoint_fixedPoint_of_dist_le'` | Fixed-point stability under a uniformly bounded map discrepancy; the comparison map's fixed point is supplied |

`Vbd/Dynamics/Contraction.lean` uses these results for ambient-space local-set interfaces.
Completeness enters only for existence. A supplied fixed point has a finite-iterate bound for
any nonnegative Lipschitz factor; for a factor below one, convergence follows by squeezing that
bound with Mathlib's geometric-limit theorem. The source documents the individual wrappers.
The generic metric formulation leaves the choice of block norm to the later analysis.

The implemented CT-04 bridge uses
`Convex.lipschitzOnWith_of_nnnorm_hasFDerivWithin_le` from
`Mathlib.Analysis.Calculus.MeanValue`. It supports within-set derivatives at boundary points.
Phase 6 uses Mathlib's finite dependent-function maximum norm, continuous-linear equivalence
with `PiLp 2`, operator-norm estimates, matrix multiplication, and derivative chain rule.

# Citations

[1] [Mathlib gradient documentation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Calculus/Gradient/Basic.html)
[2] [Mathlib strong-convexity source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/Analysis/Convex/Strong.lean)
[3] [Mathlib positive-definite matrix source](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
[4] [Mathlib contractive-map source](https://github.com/leanprover-community/mathlib4/blob/de5ce8a9a66a4aa68a9bdbb35b63a06d34d9ca11/Mathlib/Topology/MetricSpace/Contracting.lean)
[5] [Pinned Mathlib simple-graph source](../../.lake/packages/mathlib/Mathlib/Combinatorics/SimpleGraph/Basic.lean)
[6] [Pinned Mathlib vertex-coloring source](../../.lake/packages/mathlib/Mathlib/Combinatorics/SimpleGraph/Coloring/Vertex.lean)
[7] [Pinned Mathlib graph-partition source](../../.lake/packages/mathlib/Mathlib/Combinatorics/SimpleGraph/Partition.lean)
