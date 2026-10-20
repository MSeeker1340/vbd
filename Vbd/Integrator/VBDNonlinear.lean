/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBDCoupling

/-!
# Uniform nonlinear VBD certificates

The full update derivative includes inverse variation. Uniform bounds on its changed block row,
together with per-update invariance, give a maximum-norm contraction for any covered serial
order. Block spaces and all analytic bounds remain parameters.
-/

noncomputable section

open scoped NNReal

namespace Vbd.BlockNewtonData

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]
  [∀ i, FiniteDimensional ℝ (B i)] (d : BlockNewtonData B)

/-- A static comparison row for a nonlinear update, with exact identity rows elsewhere. -/
def rowComparison (c : Matrix ι ι ℝ) (i : ι) : Matrix ι ι ℝ :=
  fun k j ↦ if k = i then c i j else (1 : Matrix ι ι ℝ) k j

omit [Fintype ι] in
/-- The derivative preserves every block not written by this update. -/
theorem entry_updateDerivative_of_ne [Finite ι] (H : BlockSum B →L[ℝ] BlockSum B) (x : BlockSum B)
    (i j : ι) (K' : BlockSum B →L[ℝ] B i →L[ℝ] B i) {k : ι} (hk : k ≠ i) :
    BlockSum.entry (d.updateDerivative H x i K') k j =
      BlockSum.entry (ContinuousLinearMap.id ℝ (BlockSum B)) k j := by
  ext v
  simp [updateDerivative, rootDerivative, hk]

omit [Fintype ι] in
/-- Exact Newton cancellation and inverse variation bound the full changed derivative row. -/
theorem norm_entry_updateDerivative_le [Finite ι] (H : BlockSum B →L[ℝ] BlockSum B) (x : BlockSum B)
    (i j : ι) (K' : BlockSum B →L[ℝ] B i →L[ℝ] B i)
    (hreg : d.Regular i x) (hdiag : d.diagonal i x = BlockSum.entry H i i) :
    ‖BlockSum.entry (d.updateDerivative H x i K') i j‖ ≤
      (if j = i then 0 else ‖(d.diagonal i x).inverse.comp (BlockSum.entry H i j)‖) +
        ‖(d.diagonal i x).inverse‖ * ‖(d.diagonal i x).inverse (d.residual x i)‖ *
          ‖K'.comp (BlockSum.inclusion j)‖ := by
  let : Fintype ι := Fintype.ofFinite ι
  let s := (d.diagonal i x).inverse (d.residual x i)
  let V := (d.diagonal i x).inverse.comp ((K'.comp (BlockSum.inclusion j)).flip s)
  have he : BlockSum.entry (d.updateDerivative H x i K') i j =
      BlockSum.entry (d.rootDerivative H x i) i j + V := by
    ext v
    simp [updateDerivative, V, s]
  have hb : ‖BlockSum.entry (d.rootDerivative H x i) i j‖ ≤
      if j = i then 0 else ‖(d.diagonal i x).inverse.comp (BlockSum.entry H i j)‖ := by
    rw [d.rootDerivative_eq_gaussSeidel_step hdiag]
    by_cases hj : j = i
    · subst j
      simp [GaussSeidel.entry_step_diagonal H i (hdiag ▸ d.isInvertible_of_regular hreg)]
    · simp [GaussSeidel.entry_step_offDiagonal H i j (Ne.symm hj), hj, hdiag]
  have hv : ‖V‖ ≤ ‖(d.diagonal i x).inverse‖ * ‖s‖ * ‖K'.comp (BlockSum.inclusion j)‖ := by
    calc
      ‖V‖ ≤ ‖(d.diagonal i x).inverse‖ * ‖(K'.comp (BlockSum.inclusion j)).flip s‖ :=
        ContinuousLinearMap.opNorm_comp_le _ _
      _ ≤ ‖(d.diagonal i x).inverse‖ * (‖(K'.comp (BlockSum.inclusion j)).flip‖ * ‖s‖) :=
        mul_le_mul_of_nonneg_left (ContinuousLinearMap.le_opNorm _ _) (norm_nonneg _)
      _ = _ := by rw [ContinuousLinearMap.opNorm_flip]; ring
  rw [he]
  exact (norm_add_le _ _).trans (add_le_add hb hv)

/-- Uniform changed-row bounds feed the prepared ordered-composition and mean-value bridge.
The hypotheses retain actual intermediate states through per-update invariance. -/
theorem lipschitzOnWith_serial_of_row_bounds
    (H : BlockSum B → BlockSum B →L[ℝ] BlockSum B)
    (K' : (i : ι) → BlockSum B → BlockSum B →L[ℝ] B i →L[ℝ] B i)
    (c : Matrix ι ι ℝ) (order : List ι) {S : Set ((i : ι) → B i)} {q : ℝ≥0}
    (hq : q < 1) (hS : Convex ℝ S) (hcover : ∀ i, i ∈ order)
    (hU : ∀ i ∈ order, Set.MapsTo (d.update i)
      (BlockContraction.toMax ⁻¹' S) (BlockContraction.toMax ⁻¹' S))
    (hR : ∀ x, BlockContraction.toMax x ∈ S → HasFDerivAt d.residual (H x) x)
    (hreg : ∀ i ∈ order, ∀ x, BlockContraction.toMax x ∈ S → d.Regular i x)
    (hK : ∀ i ∈ order, ∀ x, BlockContraction.toMax x ∈ S →
      HasFDerivAt (d.diagonal i) (K' i x) x)
    (hc : ∀ i j, 0 ≤ c i j) (hrow : ∀ i, ∑ j, c i j ≤ q)
    (hbound : ∀ i ∈ order, ∀ x, BlockContraction.toMax x ∈ S → ∀ j,
      ‖BlockSum.entry (d.updateDerivative (H x) x i (K' i x)) i j‖ ≤ c i j) :
    LipschitzOnWith q (BlockContraction.maxMap (d.serial order)) S := by
  have hstep : ∀ i, BlockContraction.RowStep (rowComparison c i) {i} q := by
    intro i
    refine ⟨?_, ?_, ?_⟩
    · intro k j
      by_cases hk : k = i
      · simpa [rowComparison, hk] using hc i j
      · simp only [rowComparison, ite_eq_right hk, Matrix.one_apply]
        positivity
    · exact fun k hk j ↦ by simp [rowComparison, show k ≠ i from hk]
    · rintro k (rfl : k = i)
      simpa [rowComparison] using hrow k
  have hC : ∀ i ∈ order, ∀ x, BlockContraction.toMax x ∈ S →
      BlockContraction.Dominates (rowComparison c i)
        (d.updateDerivative (H x) x i (K' i x)) := by
    intro i hi x hx k j
    by_cases hk : k = i
    · subst k
      simpa [rowComparison] using hbound i hi x hx j
    · simpa only [d.entry_updateDerivative_of_ne (H x) x i j (K' i x) hk,
        rowComparison, ite_eq_right hk] using (BlockContraction.dominates_id (B := B) k j)
  simpa only [serial] using BlockContraction.lipschitzOnWith_prod_of_cover d.update
    (fun i x ↦ d.updateDerivative (H x) x i (K' i x)) (rowComparison c) (fun i ↦ {i})
    order.reverse hq hS
    (fun i hi ↦ hU i (List.mem_reverse.mp hi))
    (fun i hi x hx ↦ d.hasFDerivAt_update (hR x hx)
      (hreg i (List.mem_reverse.mp hi) x hx) (hK i (List.mem_reverse.mp hi) x hx))
    (fun i hi ↦ hC i (List.mem_reverse.mp hi)) (fun i _ ↦ hstep i)
    (fun i ↦ ⟨i, List.mem_reverse.mpr (hcover i), Set.mem_singleton i⟩)

end Vbd.BlockNewtonData
