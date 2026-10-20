/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Block.Operator
import Vbd.Block.Update
import Vbd.Integrator.FixedPoint
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.Normed.Module.FiniteDimension
import Mathlib.LinearAlgebra.Determinant

/-!
# Exact block-Newton updates and VBD execution

`BlockNewtonData` supplies a residual, local Hessian blocks, and a nonnegative determinant
threshold. Its full Newton update preserves every other block and skips precisely when the
absolute determinant is at most the threshold, as in the VBD paper's local solver (§3.2).
Finite-dimensional blocks make this determinant test meaningful; positivity is not required.
The IE constructor supplies the energy gradient and exact diagonal Hessian blocks.

Execution lists are chronological. Serial execution reverses the list before taking the
`Function.End` product, whose rightmost factor acts first. A buffered pass merges singleton
writes evaluated at one snapshot; the list of passes is likewise chronological. Definitions
allow partial or repeated visits. Coverage, uniqueness of visits, regularity, and physical
commutation are separate theorem hypotheses.

Complete regular serial or disjoint buffered sweeps fix exactly the residual roots, independently
of contraction. Every execution preserves roots, including skipped and repeated visits. The
consistency theorems supply Phase 5's `UnbiasedOn` premise for the concrete production maps.
-/

noncomputable section

open scoped NNReal

namespace Vbd

variable {ι : Type*} {B : ι → Type*}

section Normed

variable
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]
  [∀ i, FiniteDimensional ℝ (B i)]

/-- Data for an exact local Newton solve. The IE constructor identifies the supplied matrices
with the diagonal Hessian blocks; generic algebra uses only their declared linear action. -/
structure BlockNewtonData (B : ι → Type*) [∀ i, NormedAddCommGroup (B i)]
    [∀ i, NormedSpace ℝ (B i)] [∀ i, FiniteDimensional ℝ (B i)] where
  /-- The residual with the gradient sign convention. -/
  residual : BlockSum B → BlockSum B
  /-- Local Hessian blocks, evaluated at the current state. -/
  diagonal : (i : ι) → BlockSum B → B i →L[ℝ] B i
  /-- Updates with absolute determinant at most this threshold are skipped. -/
  threshold : ℝ≥0

namespace BlockNewtonData

variable [DecidableEq ι] (d : BlockNewtonData B)

/-- The production determinant test accepts this block at this state. -/
def Regular (i : ι) (x : BlockSum B) : Prop :=
  (d.threshold : ℝ) < |(d.diagonal i x).toLinearMap.det|

open scoped Classical in
/-- Full Newton replacement, with the production near-singular skip branch. -/
def update (i : ι) : Function.End (BlockSum B) := fun x ↦
  if d.Regular i x then
    BlockSum.replace x i (x i - (d.diagonal i x).inverse (d.residual x i))
  else x

theorem update_of_regular {i : ι} {x : BlockSum B} (h : d.Regular i x) :
    d.update i x =
      BlockSum.replace x i (x i - (d.diagonal i x).inverse (d.residual x i)) := by
  simp [update, h]

theorem update_of_skip {i : ι} {x : BlockSum B}
    (h : |(d.diagonal i x).toLinearMap.det| ≤ d.threshold) : d.update i x = x := by
  simp [update, Regular, not_lt.mpr h]

@[simp] theorem update_apply_of_ne (i : ι) (x : BlockSum B) {j : ι} (h : j ≠ i) :
    d.update i x j = x j := by
  by_cases hr : d.Regular i x
  all_goals simp [update, hr, h]

theorem writeSupport_update (i : ι) : BlockUpdate.writeSupport (d.update i) ⊆ {i} := by
  exact BlockUpdate.writeSupport_subset_iff.mpr fun x j hj ↦ d.update_apply_of_ne i x hj

omit [DecidableEq ι] in
/-- Passing the determinant test certifies an exact inverse, independently of curvature. -/
theorem isInvertible_of_regular {i : ι} {x : BlockSum B} (h : d.Regular i x) :
    (d.diagonal i x).IsInvertible := by
  have hdet : (d.diagonal i x).toLinearMap.det ≠ 0 :=
    abs_pos.mp (d.threshold.coe_nonneg.trans_lt h)
  have hu : IsUnit (d.diagonal i x).toLinearMap :=
    (LinearMap.isUnit_iff_isUnit_det _).mpr (isUnit_iff_ne_zero.mpr hdet)
  exact ⟨(LinearEquiv.ofBijective _ ((Module.End.isUnit_iff _).mp hu)).toContinuousLinearEquiv,
    rfl⟩

omit [DecidableEq ι] in
/-- The accepted local displacement solves the Newton equation exactly. -/
theorem diagonal_inverse_residual {i : ι} {x : BlockSum B} (h : d.Regular i x) :
    d.diagonal i x ((d.diagonal i x).inverse (d.residual x i)) = d.residual x i := by
  exact (d.isInvertible_of_regular h).self_apply_inverse _

/-- A zero block residual is preserved by both branches of the production update. -/
theorem update_of_residual_eq_zero {i : ι} {x : BlockSum B} (h : d.residual x i = 0) :
    d.update i x = x := by
  by_cases hr : d.Regular i x
  all_goals simp [update, hr, h]

/-- At a regular block, no displacement is equivalent to a zero block residual. -/
theorem update_apply_eq_self_iff {i : ι} {x : BlockSum B} (h : d.Regular i x) :
    d.update i x i = x i ↔ d.residual x i = 0 := by
  rw [d.update_of_regular h, BlockSum.replace_apply_same, sub_eq_self]
  exact map_eq_zero_iff _ (d.isInvertible_of_regular h).inverse.injective

/-- The externally supplied visit order is chronological. -/
def serial (order : List ι) : Function.End (BlockSum B) :=
  (order.reverse.map (β := Function.End (BlockSum B)) d.update).prod

@[simp] theorem serial_nil : d.serial [] = id := rfl

@[simp] theorem serial_cons (i : ι) (order : List ι) (x : BlockSum B) :
    d.serial (i :: order) x = d.serial order (d.update i x) := by
  simp only [serial, List.reverse_cons]
  rw [List.map_append, List.prod_append]
  rfl

/-- Visits outside a block leave it unchanged, regardless of their read dependencies. -/
theorem serial_apply_of_not_mem {order : List ι} {i : ι} (hi : i ∉ order)
    (x : BlockSum B) : d.serial order x i = x i := by
  exact BlockUpdate.prod_preserves _ i (List.forall_mem_map.mpr fun j hj z ↦
    d.update_apply_of_ne j z (fun h ↦ hi (h.symm ▸ List.mem_reverse.mp hj))) x

/-- For a once-per-vertex serial plan, fixed points have zero residual on precisely the visited
blocks. Regularity is needed only at the candidate fixed point: every visit then sees that state. -/
theorem serial_fixed_iff (order : List ι) (x : BlockSum B) (hn : order.Nodup)
    (hreg : ∀ i ∈ order, d.Regular i x) :
    d.serial order x = x ↔ ∀ i ∈ order, d.residual x i = 0 := by
  induction order with
  | nil => simp
  | cons i order ih =>
      refine ⟨fun hfix ↦ ?_, fun hres ↦ ?_⟩
      · have hfirst : d.update i x i = x i :=
          (d.serial_apply_of_not_mem (List.nodup_cons.mp hn).1 (d.update i x)).symm.trans
            (congrArg (fun z : BlockSum B ↦ z i) ((d.serial_cons i order x).symm.trans hfix))
        have hRi : d.residual x i = 0 :=
          (d.update_apply_eq_self_iff (hreg i List.mem_cons_self)).mp hfirst
        exact List.forall_mem_cons.mpr ⟨hRi,
          (ih (List.nodup_cons.mp hn).2 (fun j hj ↦ hreg j (List.mem_cons_of_mem i hj))).mp
            ((congrArg (d.serial order) (d.update_of_residual_eq_zero hRi)).symm.trans
              ((d.serial_cons i order x).symm.trans hfix))⟩
      · exact (d.serial_cons i order x).trans
          ((congrArg (d.serial order)
            (d.update_of_residual_eq_zero (hres i List.mem_cons_self))).trans
              ((ih (List.nodup_cons.mp hn).2
                (fun j hj ↦ hreg j (List.mem_cons_of_mem i hj))).mpr
                  (fun j hj ↦ hres j (List.mem_cons_of_mem i hj))))

/-- A complete regular serial sweep fixes exactly the residual roots, without contraction. -/
theorem serial_fixed_iff_residual_eq_zero (order : List ι) (hn : order.Nodup)
    (hcover : ∀ i, i ∈ order) (x : BlockSum B) (hreg : ∀ i, d.Regular i x) :
    d.serial order x = x ↔ d.residual x = 0 := by
  exact (d.serial_fixed_iff order x hn (fun i _ ↦ hreg i)).trans
    ⟨fun h ↦ PiLp.ext fun i ↦ h i (hcover i), fun h i _ ↦ congrArg (fun z : BlockSum B ↦ z i) h⟩

/-- Residual roots are preserved even by incomplete, repeated, or skipped serial visits. -/
theorem serial_of_residual_eq_zero (order : List ι) {x : BlockSum B} (h : d.residual x = 0) :
    d.serial order x = x := by
  induction order with
  | nil => rfl
  | cons i order ih =>
      exact (d.serial_cons i order x).trans
        ((congrArg (d.serial order) (d.update_of_residual_eq_zero
          (congrArg (fun z : BlockSum B ↦ z i) h))).trans ih)

/-- A buffered pass evaluates every selected vertex at the same snapshot. -/
def batch (vertices : Finset ι) : Function.End (BlockSum B) :=
  BlockUpdate.merge d.update vertices (fun i ↦ {i})

theorem batch_apply_of_mem {vertices : Finset ι} {i : ι} (hi : i ∈ vertices)
    (x : BlockSum B) : d.batch vertices x i = d.update i x i := by
  exact BlockUpdate.merge_apply_of_mem d.update vertices (fun j ↦ {j})
    (fun _ _ _ _ hrs ↦ Set.disjoint_left.mpr fun _ ha hb ↦ hrs (ha.symm.trans hb))
    hi rfl x

theorem batch_apply_of_not_mem {vertices : Finset ι} {i : ι} (hi : i ∉ vertices)
    (x : BlockSum B) : d.batch vertices x i = x i := by
  exact BlockUpdate.merge_apply_of_not_mem d.update vertices (fun j ↦ {j})
    (i := i) (fun j hj hij ↦ hi ((Set.mem_singleton_iff.mp hij).symm ▸ hj)) x

/-- A regular snapshot pass fixes precisely when its selected block residuals vanish.
No independence between the selected blocks is required. -/
theorem batch_fixed_iff (vertices : Finset ι) (x : BlockSum B)
    (hreg : ∀ i ∈ vertices, d.Regular i x) :
    d.batch vertices x = x ↔ ∀ i ∈ vertices, d.residual x i = 0 := by
  refine ⟨fun hfix i hi ↦ (d.update_apply_eq_self_iff (hreg i hi)).mp
    ((d.batch_apply_of_mem hi x).symm.trans (congrArg (fun z : BlockSum B ↦ z i) hfix)),
    fun hres ↦ PiLp.ext fun i ↦ ?_⟩
  exact if hi : i ∈ vertices then (d.batch_apply_of_mem hi x).trans
    (congrArg (fun z : BlockSum B ↦ z i) (d.update_of_residual_eq_zero (hres i hi)))
    else d.batch_apply_of_not_mem hi x

/-- Both branches preserve residual roots in every buffered snapshot pass. -/
theorem batch_of_residual_eq_zero (vertices : Finset ι) {x : BlockSum B}
    (h : d.residual x = 0) : d.batch vertices x = x := by
  exact PiLp.ext fun i ↦ if hi : i ∈ vertices then (d.batch_apply_of_mem hi x).trans
    (congrArg (fun z : BlockSum B ↦ z i)
      (d.update_of_residual_eq_zero (congrArg (fun z : BlockSum B ↦ z i) h)))
    else d.batch_apply_of_not_mem hi x

/-- For commuting vertices, the buffered snapshot pass equals any chronological enumeration.
Physical component separation is a separate VBD theorem supplying `hc`. -/
theorem batch_eq_serial (vertices : Finset ι) (order : List ι) (hn : order.Nodup)
    (he : ∀ i, i ∈ order ↔ i ∈ vertices)
    (hc : ∀ i ∈ vertices, ∀ j ∈ vertices, Function.Commute (d.update i) (d.update j)) :
    d.batch vertices = d.serial order := by
  exact BlockUpdate.merge_eq_prod d.update vertices (fun i ↦ {i})
    (fun i _ ↦ d.writeSupport_update i)
    (fun _ _ _ _ hrs ↦ Set.disjoint_left.mpr fun _ ha hb ↦ hrs (ha.symm.trans hb))
    hc order.reverse (List.nodup_reverse.mpr hn) (fun i ↦ List.mem_reverse.trans (he i))

/-- Externally controlled buffered passes, in chronological order. -/
def buffered (passes : List (Finset ι)) : Function.End (BlockSum B) :=
  (passes.reverse.map (β := Function.End (BlockSum B)) d.batch).prod

@[simp] theorem buffered_nil : d.buffered [] = id := rfl

@[simp] theorem buffered_cons (vertices : Finset ι) (passes : List (Finset ι))
    (x : BlockSum B) : d.buffered (vertices :: passes) x =
      d.buffered passes (d.batch vertices x) := by
  simp only [buffered, List.reverse_cons]
  rw [List.map_append, List.prod_append]
  rfl

/-- Residual roots are preserved by every buffered plan, including coupled or repeated passes. -/
theorem buffered_of_residual_eq_zero (passes : List (Finset ι)) {x : BlockSum B}
    (h : d.residual x = 0) : d.buffered passes x = x := by
  induction passes with
  | nil => rfl
  | cons vertices passes ih =>
      exact (d.buffered_cons vertices passes x).trans
        ((congrArg (d.buffered passes) (d.batch_of_residual_eq_zero vertices h)).trans ih)

/-- A buffered plan preserves every block absent from all its passes. -/
theorem buffered_apply_of_not_mem {passes : List (Finset ι)} {i : ι}
    (hi : ∀ vertices ∈ passes, i ∉ vertices) (x : BlockSum B) :
    d.buffered passes x i = x i := by
  exact BlockUpdate.prod_preserves _ i (List.forall_mem_map.mpr fun vertices hv z ↦
    d.batch_apply_of_not_mem (hi vertices (List.mem_reverse.mp hv)) z) x

/-- Disjoint buffered passes have the same fixed-point consistency as once-per-block serial
execution. Snapshot coupling within a pass does not affect this statement. -/
theorem buffered_fixed_iff (passes : List (Finset ι)) (x : BlockSum B)
    (hn : passes.Pairwise Disjoint) (hreg : ∀ i, d.Regular i x) :
    d.buffered passes x = x ↔ ∀ vertices ∈ passes, ∀ i ∈ vertices, d.residual x i = 0 := by
  induction passes with
  | nil => simp
  | cons vertices passes ih =>
      refine ⟨fun hfix ↦ ?_, fun hres ↦ ?_⟩
      · have hfirst : ∀ i ∈ vertices, d.residual x i = 0 := fun i hi ↦
          (d.update_apply_eq_self_iff (hreg i)).mp
            ((d.batch_apply_of_mem hi x).symm.trans
              ((d.buffered_apply_of_not_mem (fun other ho ↦
                Finset.disjoint_left.mp ((List.pairwise_cons.mp hn).1 other ho) hi)
                  (d.batch vertices x)).symm.trans
                    (congrArg (fun z : BlockSum B ↦ z i)
                      ((d.buffered_cons vertices passes x).symm.trans hfix))))
        exact List.forall_mem_cons.mpr ⟨hfirst,
          (ih (List.pairwise_cons.mp hn).2).mp
            ((congrArg (d.buffered passes)
              ((d.batch_fixed_iff vertices x (fun i _ ↦ hreg i)).mpr hfirst)).symm.trans
                ((d.buffered_cons vertices passes x).symm.trans hfix))⟩
      · exact (d.buffered_cons vertices passes x).trans
          ((congrArg (d.buffered passes)
            ((d.batch_fixed_iff vertices x (fun i _ ↦ hreg i)).mpr
              (hres vertices List.mem_cons_self))).trans
                ((ih (List.pairwise_cons.mp hn).2).mpr
                  (fun other ho ↦ hres other (List.mem_cons_of_mem vertices ho))))

/-- Complete disjoint buffered passes fix exactly the residual roots on the regular branch. -/
theorem buffered_fixed_iff_residual_eq_zero (passes : List (Finset ι))
    (hn : passes.Pairwise Disjoint) (hcover : ∀ i, ∃ vertices ∈ passes, i ∈ vertices)
    (x : BlockSum B) (hreg : ∀ i, d.Regular i x) :
    d.buffered passes x = x ↔ d.residual x = 0 := by
  refine (d.buffered_fixed_iff passes x hn hreg).trans ⟨fun h ↦ PiLp.ext fun i ↦ ?_,
    fun h _ _ i _ ↦ congrArg (fun z : BlockSum B ↦ z i) h⟩
  exact Exists.elim (hcover i) fun vertices hv ↦ h vertices hv.1 i hv.2

/-- Consistency of a complete serial plan supplies Phase 5's unbiasedness premise. -/
theorem unbiasedOn_serial (order : List ι) (hn : order.Nodup) (hcover : ∀ i, i ∈ order)
    {S : Set (BlockSum B)} (hreg : ∀ x ∈ S, ∀ i, d.Regular i x) :
    UnbiasedOn d.residual (d.serial order) S := by
  exact fun _ hx hfix ↦ (d.serial_fixed_iff_residual_eq_zero order hn hcover _ (hreg _ hx)).mp hfix

/-- Consistency of complete disjoint buffered passes supplies Phase 5's unbiasedness premise. -/
theorem unbiasedOn_buffered (passes : List (Finset ι)) (hn : passes.Pairwise Disjoint)
    (hcover : ∀ i, ∃ vertices ∈ passes, i ∈ vertices) {S : Set (BlockSum B)}
    (hreg : ∀ x ∈ S, ∀ i, d.Regular i x) : UnbiasedOn d.residual (d.buffered passes) S := by
  exact fun _ hx hfix ↦
    (d.buffered_fixed_iff_residual_eq_zero passes hn hcover _ (hreg _ hx)).mp hfix

end BlockNewtonData

end Normed

namespace ImplicitEulerStep

variable [Fintype ι] [DecidableEq ι] [∀ i, NormedAddCommGroup (B i)]
  [∀ i, InnerProductSpace ℝ (B i)] [∀ i, CompleteSpace (B i)]
  [∀ i, FiniteDimensional ℝ (B i)]

/-- Exact VBD data for an IE step, using the global gradient and diagonal Hessian blocks.
The local/global cancellation of component energies justifies these same local Newton systems. -/
def blockNewtonData (ie : ImplicitEulerStep (BlockSum B)) (threshold : ℝ≥0) :
    BlockNewtonData B where
  residual := ie.energyGradient
  diagonal := fun i x ↦ BlockSum.entry (hessian ie.energy x) i i
  threshold := threshold

/-- The supplied local Hessian has exactly the inertia-plus-potential diagonal from Phase 1. -/
theorem blockNewtonData_diagonal (ie : ImplicitEulerStep (BlockSum B)) (threshold : ℝ≥0)
    (i : ι) (x : BlockSum B) :
    (ie.blockNewtonData threshold).diagonal i x =
      (ie.h ^ 2)⁻¹ • BlockSum.entry ie.M i i +
        BlockSum.entry (ie.potentialHessian x) i i := by
  simp [blockNewtonData, hessian_energy]

end ImplicitEulerStep
end Vbd
