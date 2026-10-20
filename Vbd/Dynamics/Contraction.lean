/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Mathlib.Topology.MetricSpace.Contracting
import Mathlib.Analysis.Calculus.MeanValue

/-!
# Iteration on invariant sets

Ambient-space interfaces to Mathlib's contraction theory. `Set.MapsTo` supplies forward
invariance and `LipschitzOnWith` supplies the metric estimate on the certified set. The
restriction to the subtype is handled inside the proofs; the ambient space need not be complete.
Mathlib supplies existence and uniqueness, and its Lipschitz iteration API supplies the finite
bounds. Convergence to a supplied fixed point follows from the geometric bound without a
completeness assumption. Closed subsets of complete metric spaces, including nonempty closed
balls, use `IsClosed.isComplete` with `exists_fixedPoint`. The normed-space derivative bridge
uses Mathlib's mean-value inequality on convex regions and keeps invariance separate.
-/

namespace Vbd.Contraction

open Filter Function Set Topology
open scoped NNReal

variable {X : Type*} [MetricSpace X] {T : X → X} {S : Set X} {q : ℝ≥0}

/-- Pairwise finite-iterate bound on an invariant set, valid for every Lipschitz factor. -/
theorem dist_iterate_le (hS : MapsTo T S S) (hT : LipschitzOnWith q T S)
    {x y : X} (hx : x ∈ S) (hy : y ∈ S) (k : ℕ) :
    dist (T^[k] x) (T^[k] y) ≤ (q : ℝ) ^ k * dist x y := by
  simpa only [MapsTo.iterate_restrict, Subtype.dist_eq, MapsTo.val_restrict_apply,
    NNReal.coe_pow] using ((hT.mapsToRestrict hS).iterate k).dist_le_mul
      (⟨x, hx⟩ : S) (⟨y, hy⟩ : S)

/-- Distance to a supplied fixed point after a finite iteration budget.
Completeness and strict contraction are unnecessary for this estimate. -/
theorem dist_iterate_fixedPoint_le (hS : MapsTo T S S) (hT : LipschitzOnWith q T S)
    {x p : X} (hx : x ∈ S) (hp : p ∈ S) (hfix : IsFixedPt T p) (k : ℕ) :
    dist (T^[k] x) p ≤ (q : ℝ) ^ k * dist x p := by
  simpa only [(hfix.iterate k).eq] using dist_iterate_le hS hT hx hp k

/-- Convergence to a supplied fixed point under local contraction, without completeness. -/
theorem tendsto_iterate (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hq : q < 1)
    {x p : X} (hx : x ∈ S) (hp : p ∈ S) (hfix : IsFixedPt T p) :
    Tendsto (fun k ↦ T^[k] x) atTop (𝓝 p) := by
  apply tendsto_iff_dist_tendsto_zero.mpr
  refine squeeze_zero (fun _ ↦ dist_nonneg) (dist_iterate_fixedPoint_le hS hT hx hp hfix) ?_
  simpa using (tendsto_pow_atTop_nhds_zero_of_lt_one q.coe_nonneg
    (NNReal.coe_lt_one.mpr hq)).mul_const (dist x p)

/-- Fixed points in the certified set are unique; no completeness assumption is needed. -/
theorem fixedPoint_unique (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hq : q < 1)
    {x y : X} (hx : x ∈ S) (hy : y ∈ S) (hfix : IsFixedPt T x) (hfix' : IsFixedPt T y) :
    x = y :=
  congrArg Subtype.val
    ((show ContractingWith q (hS.restrict T S S) from ⟨hq, hT.mapsToRestrict hS⟩).fixedPoint_unique'
      (x := ⟨x, hx⟩) (y := ⟨y, hy⟩) (Subtype.ext hfix) (Subtype.ext hfix'))

/-- The current sweep defect bounds distance to a supplied fixed point.
Apply this at an iterate using `hS.iterate k hx` for the a posteriori stopping estimate. -/
theorem dist_fixedPoint_le (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hq : q < 1)
    {x p : X} (hx : x ∈ S) (hp : p ∈ S) (hfix : IsFixedPt T p) :
    dist x p ≤ dist x (T x) / (1 - (q : ℝ)) :=
  (show ContractingWith q (hS.restrict T S S) from ⟨hq, hT.mapsToRestrict hS⟩).dist_le_of_fixedPoint
    (⟨x, hx⟩ : S) (y := ⟨p, hp⟩) (Subtype.ext hfix)

/-- Banach's theorem on a nonempty complete invariant subset, with an ambient-space
fixed point and uniqueness within that subset. Existence is supplied by Mathlib's
`ContractingWith.exists_fixedPoint'`; ambient completeness is unnecessary. -/
theorem exists_fixedPoint (hcomplete : IsComplete S) (hne : S.Nonempty)
    (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hq : q < 1) :
    ∃ p ∈ S, IsFixedPt T p ∧ ∀ y ∈ S, IsFixedPt T y → y = p := by
  obtain ⟨x, hx⟩ := hne
  obtain ⟨p, hp, hfix, _⟩ :=
    (show ContractingWith q (hS.restrict T S S) from ⟨hq, hT.mapsToRestrict hS⟩).exists_fixedPoint'
      hcomplete hS hx (edist_ne_top x (T x))
  exact ⟨p, hp, hfix, fun y hy hfy ↦ fixedPoint_unique hS hT hq hy hp hfy hfix⟩

end Vbd.Contraction

namespace Vbd.Contraction
open scoped NNReal

variable {E F : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
  [NormedAddCommGroup F] [NormedSpace ℝ F]

/-- Uniform derivative bounds on a convex region give the metric estimate used by
our invariant-set iteration theorems. Boundary points use within-set derivatives. -/
theorem lipschitzOnWith_of_derivative_bound {f : E → F} {D : E → E →L[ℝ] F}
    {S : Set E} {q : ℝ≥0} (hS : Convex ℝ S)
    (hD : ∀ x ∈ S, HasFDerivWithinAt f (D x) S x)
    (hbound : ∀ x ∈ S, ‖D x‖ ≤ q) : LipschitzOnWith q f S :=
  hS.lipschitzOnWith_of_nnnorm_hasFDerivWithin_le hD hbound

end Vbd.Contraction
