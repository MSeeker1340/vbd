/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBDDerivative
import Vbd.Integrator.VBDCurvature

/-!
# Coupling bounds for the production root derivative

Diagonal inverse bounds and off-diagonal block bounds control each changed Gauss–Seidel row.
The Phase-6 comparison product propagates that estimate through the externally supplied serial
order, including repeated visits when every block is covered. The resulting operator norm is in
the block maximum norm. No dimension factor enters this conjugated state norm.

These are bounds on the derivative at a residual root. Uniform off-root estimates must also
control the inverse-variation term and intermediate states.
-/

noncomputable section

namespace Vbd.BlockContraction

variable {ι : Type*} {B : ι → Type*} [Fintype ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]

/-- Maximum-norm state error is bounded by `ℓ²` block-sum error with constant `1`. -/
theorem toMax_norm_le (x : BlockSum B) : ‖toMax x‖ ≤ ‖x‖ := by
  exact (pi_norm_le_iff_of_nonneg (norm_nonneg x)).mpr (PiLp.norm_apply_le x)

/-- `ℓ²` block-sum error is at most `sqrt(card ι)` times maximum-norm state error.
This conversion is separate from the maximum-norm contraction factor. -/
theorem norm_le_sqrt_card_mul_toMax (x : BlockSum B) :
    ‖x‖ ≤ Real.sqrt (Fintype.card ι) * ‖toMax x‖ := by
  have h := (PiLp.lipschitzWith_toLp 2 B).norm_sub_le (toMax x) 0
  have heq : WithLp.toLp 2 (toMax x) = x := rfl
  simpa [heq, NNReal.coe_rpow, Real.sqrt_eq_rpow] using h

end Vbd.BlockContraction

namespace Vbd.GaussSeidel

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]

/-- The comparison row of an exact Newton step; unwritten rows are identity rows. -/
def comparison (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) : Matrix ι ι ℝ :=
  fun k j ↦ if k = i then
    if j = i then 0 else ‖(BlockSum.entry H i i).inverse.comp (BlockSum.entry H i j)‖
  else (1 : Matrix ι ι ℝ) k j

omit [Fintype ι] in
/-- Invertibility gives exact diagonal cancellation in the comparison certificate. -/
theorem dominates_comparison [Finite ι] (H : BlockSum B →L[ℝ] BlockSum B) (i : ι)
    (hI : (BlockSum.entry H i i).IsInvertible) :
    BlockContraction.Dominates (comparison H i) (step H i) := by
  intro k j
  by_cases hk : k = i
  · subst k
    by_cases hj : i = j
    · subst j
      simp [comparison, entry_step_diagonal H i hI]
    · simp [comparison, Ne.symm hj, entry_step_offDiagonal H i j hj]
  · simpa only [comparison, ite_eq_right hk, entry_step_of_ne H i j hk] using
      (BlockContraction.dominates_id (B := B) k j)

/-- A normalized off-diagonal row bound is a Phase-6 changed-row certificate. -/
theorem comparison_rowStep (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) {q : ℝ}
    (hrow : ∑ j ∈ Finset.univ.erase i,
      ‖(BlockSum.entry H i i).inverse.comp (BlockSum.entry H i j)‖ ≤ q) :
    BlockContraction.RowStep (comparison H i) {i} q := by
  refine ⟨?_, ?_, ?_⟩
  · intro k j
    simp only [comparison, Matrix.one_apply]
    positivity
  · exact fun k hk j ↦ by simp [comparison, show k ≠ i from hk]
  · rintro k (rfl : k = i)
    simpa [comparison, Finset.sum_ite, Finset.filter_ne'] using hrow

/-- The supplied chronological sweep has the corresponding ordered comparison product. -/
theorem dominates_sweep (H : BlockSum B →L[ℝ] BlockSum B) (order : List ι)
    (hI : ∀ i ∈ order, (BlockSum.entry H i i).IsInvertible) :
    BlockContraction.Dominates (order.reverse.map (comparison H)).prod (sweep H order) := by
  have hIr : ∀ i ∈ order.reverse, (BlockSum.entry H i i).IsInvertible :=
    fun i hi ↦ hI i (List.mem_reverse.mp hi)
  unfold sweep
  generalize order.reverse = visits at hIr ⊢
  induction visits with
  | nil => exact BlockContraction.dominates_id
  | cons i visits ih =>
      simpa only [List.map_cons, List.prod_cons, ContinuousLinearMap.mul_def] using
        (dominates_comparison H i (hIr i List.mem_cons_self)).comp
          (ih (fun j hj ↦ hIr j (List.mem_cons_of_mem i hj)))

/-- Complete serial execution bounds its root error operator whenever every normalized
off-diagonal row has sum at most `q ≤ 1`. The bound is independent of block count and dimension. -/
theorem max_sweep_opNorm_le (H : BlockSum B →L[ℝ] BlockSum B) (order : List ι)
    {q : ℝ} (hq : 0 ≤ q) (hq1 : q ≤ 1) (hcover : ∀ i, i ∈ order)
    (hI : ∀ i ∈ order, (BlockSum.entry H i i).IsInvertible)
    (hrow : ∀ i ∈ order, ∑ j ∈ Finset.univ.erase i,
      ‖(BlockSum.entry H i i).inverse.comp (BlockSum.entry H i j)‖ ≤ q) :
    ‖(BlockContraction.toMax (B := B)).toContinuousLinearMap.comp
      ((sweep H order).comp (BlockContraction.toMax (B := B)).symm.toContinuousLinearMap)‖ ≤ q := by
  apply (dominates_sweep H order hI).max_opNorm_le hq
  exact BlockContraction.rowSum_prod_le_of_cover (comparison H) (fun i ↦ {i}) order.reverse hq1
    (fun i hi ↦ comparison_rowStep H i (hrow i (List.mem_reverse.mp hi)))
    (fun i ↦ ⟨i, List.mem_reverse.mpr (hcover i), Set.mem_singleton i⟩)

end Vbd.GaussSeidel

namespace Vbd.BlockCurvature

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, InnerProductSpace ℝ (B i)]
  [∀ i, FiniteDimensional ℝ (B i)]

/-- Coercivity and off-diagonal component estimates bound the normalized coupling row. -/
theorem normalized_row_le (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) {μ : ℝ}
    (hμ : 0 < μ)
    (hK : ∀ v, μ * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry H i i v))
    (c : ι → ℝ) (hc : ∀ j ≠ i, ‖BlockSum.entry H i j‖ ≤ c j) :
    ∑ j ∈ Finset.univ.erase i, ‖(BlockSum.entry H i i).inverse.comp (BlockSum.entry H i j)‖ ≤
      μ⁻¹ * ∑ j ∈ Finset.univ.erase i, c j := by
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun j hj ↦ ?_
  exact (ContinuousLinearMap.opNorm_comp_le _ _).trans
    (mul_le_mul (norm_inverse_le hμ hK) (hc j (Finset.mem_erase.mp hj).1)
      (norm_nonneg _) (inv_nonneg.mpr hμ.le))

end Vbd.BlockCurvature
