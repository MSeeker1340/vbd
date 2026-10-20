/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringEnergy
import Vbd.Examples.AxialSpringNeighborhood

/-!
# Root location and the physical residual norm

The mass-scaled residual is measured in the maximum norm, independently of the Hilbert geometry
used for the energy gradient. On the admitted box its Lipschitz constant is `53/25`. A scalar
maximum principle places every residual root inside the predictor bounds.
-/

noncomputable section

open scoped NNReal

namespace Vbd.AxialSpring

variable {ι : Type*} [Fintype ι]

/-- The physical residual in dimensionless displacement units, with its own maximum norm. -/
def scaledResidual (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y : State ι)
    (x : ι → ℝ) : ι → ℝ :=
  fun i ↦ residual a b η y (BlockContraction.toMax.symm x) i / a i

/-- The derivative of the mass-scaled maximum-norm residual. -/
def scaledJacobian (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) :
    (ι → ℝ) →L[ℝ] (ι → ℝ) :=
  (ContinuousLinearMap.pi fun i ↦ (a i)⁻¹ • derivativeRow a b η u i).comp
    (BlockContraction.toMax (B := fun _ : ι ↦ ℝ)).symm.toContinuousLinearMap

@[simp] theorem scaledJacobian_apply (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (u : State ι) (v : ι → ℝ) (i : ι) :
    scaledJacobian a b η u v i = (a i)⁻¹ *
      (a i * v i + ∑ j, stiffness b η u i j * (v i - v j)) := by
  simp [scaledJacobian, derivativeRow, BlockContraction.toMax]
  ring

/-- Differentiating the actual scaled residual keeps its maximum-norm codomain explicit. -/
theorem hasFDerivAt_scaledResidual (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y : State ι) (x : ι → ℝ) :
    HasFDerivAt (scaledResidual a b η y)
      (scaledJacobian a b η (BlockContraction.toMax.symm x)) x := by
  apply hasFDerivAt_pi'.mpr
  intro i
  have hd := (((BlockSum.projection i : State ι →L[ℝ] ℝ).hasFDerivAt.comp
    (BlockContraction.toMax.symm x)
    (hasFDerivAt_residual a b η y (BlockContraction.toMax.symm x))).const_mul
      ((a i)⁻¹)).comp x (BlockContraction.toMax (B := fun _ : ι ↦ ℝ)).symm.hasFDerivAt
  convert hd using 1
  all_goals first | rfl | (ext v; simp [scaledResidual, BlockContraction.toMax,
    div_eq_mul_inv, mul_comm])

/-- The accepted spring range gives a size-independent physical-residual Lipschitz constant. -/
theorem norm_scaledJacobian_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {u : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hu : ∀ i, |u i| ≤ 1 / 10) :
    ‖scaledJacobian a b η u‖ ≤ 53 / 25 := by
  apply ContinuousLinearMap.opNorm_le_bound _ (by norm_num)
  intro v
  apply (pi_norm_le_iff_of_nonneg (mul_nonneg (by norm_num) (norm_nonneg v))).mpr
  intro i
  have ha0 : 0 < a i := lt_of_lt_of_le zero_lt_one (ha i)
  have hv : ∀ j, |v j| ≤ ‖v‖ := fun j ↦ by
    simpa only [Real.norm_eq_abs] using norm_le_pi_norm v j
  have he : ∀ j, |v i - v j| ≤ 2 * ‖v‖ := by
    intro j
    calc
      _ ≤ |v i| + |v j| := by simpa using abs_sub_le (v i) 0 (v j)
      _ ≤ _ := by linarith [hv i, hv j]
  have ht : ∀ j, |stiffness b η u i j * (v i - v j)| ≤
      stiffness b η u i j * (2 * ‖v‖) := by
    intro j
    rw [abs_mul, abs_of_nonneg (stiffness_nonneg hb hη u i j)]
    exact mul_le_mul_of_nonneg_left (he j) (stiffness_nonneg hb hη u i j)
  have hf : |a i * v i + ∑ j, stiffness b η u i j * (v i - v j)| ≤
      (53 / 25) * a i * ‖v‖ := by
    calc
      _ ≤ |a i * v i| + ∑ j, |stiffness b η u i j * (v i - v j)| :=
        (abs_add_le _ _).trans (add_le_add le_rfl (Finset.abs_sum_le_sum_abs _ _))
      _ ≤ a i * ‖v‖ + ∑ j, stiffness b η u i j * (2 * ‖v‖) :=
        add_le_add (by rw [abs_mul, abs_of_pos ha0]; exact
          mul_le_mul_of_nonneg_left (hv i) ha0.le) (Finset.sum_le_sum fun j _ ↦ ht j)
      _ = a i * ‖v‖ + (∑ j, stiffness b η u i j) * (2 * ‖v‖) := by rw [Finset.sum_mul]
      _ ≤ a i * ‖v‖ + ((14 / 25) * a i) * (2 * ‖v‖) :=
        add_le_add le_rfl (mul_le_mul_of_nonneg_right (stiffness_row_le hb hη1 hu hrow i)
          (by positivity))
      _ = _ := by ring
  rw [scaledJacobian_apply, Real.norm_eq_abs, abs_mul, abs_inv, abs_of_pos ha0]
  calc
    _ ≤ (a i)⁻¹ * ((53 / 25) * a i * ‖v‖) :=
      mul_le_mul_of_nonneg_left hf (inv_nonneg.mpr ha0.le)
    _ = _ := by field_simp

/-- Uniform derivative control feeds the prepared cross-norm state-to-residual bridge. -/
theorem lipschitzOnWith_scaledResidual {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (y : State ι) :
    LipschitzOnWith (53 / 25 : ℝ≥0) (scaledResidual a b η y) stateBox := by
  apply Contraction.lipschitzOnWith_of_derivative_bound (convex_closedBall 0 _)
    (fun x _ ↦ (hasFDerivAt_scaledResidual a b η y x).hasFDerivWithinAt)
  exact fun x hx ↦ norm_scaledJacobian_le ha hb hη hη1 hrow ((mem_stateBox_iff _).mp hx)

/-- Every residual root lies between the predictor bounds, without a contraction hypothesis. -/
theorem abs_root_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η Y : ℝ} {y p : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η)
    (hy : ∀ i, |y i| ≤ Y) (hroot : residual a b η y p = 0) : ∀ i, |p i| ≤ Y := by
  classical
  intro i
  obtain ⟨hi, _, hmax⟩ := Finset.exists_max_image Finset.univ (fun k ↦ p k)
    ⟨i, Finset.mem_univ i⟩
  obtain ⟨lo, _, hmin⟩ := Finset.exists_min_image Finset.univ (fun k ↦ p k)
    ⟨i, Finset.mem_univ i⟩
  have hhi : 0 ≤ ∑ j, b hi j * ((p hi - p j) + η * (p hi - p j) ^ 3) := by
    apply Finset.sum_nonneg
    intro j _
    apply mul_nonneg (hb hi j)
    rw [show (p hi - p j) + η * (p hi - p j) ^ 3 =
      (p hi - p j) * (1 + η * (p hi - p j) ^ 2) by ring]
    exact mul_nonneg (sub_nonneg.mpr (hmax j (Finset.mem_univ j))) (by positivity)
  have hlo : (∑ j, b lo j * ((p lo - p j) + η * (p lo - p j) ^ 3)) ≤ 0 := by
    apply Finset.sum_nonpos
    intro j _
    apply mul_nonpos_of_nonneg_of_nonpos (hb lo j)
    rw [show (p lo - p j) + η * (p lo - p j) ^ 3 =
      (p lo - p j) * (1 + η * (p lo - p j) ^ 2) by ring]
    exact mul_nonpos_of_nonpos_of_nonneg (sub_nonpos.mpr (hmin j (Finset.mem_univ j)))
      (by positivity)
  have hrhi := congrArg (fun x : State ι ↦ x hi) hroot
  have hrlo := congrArg (fun x : State ι ↦ x lo) hroot
  change a hi * (p hi - y hi) + ∑ j, b hi j * ((p hi - p j) + η * (p hi - p j) ^ 3) = 0
    at hrhi
  change a lo * (p lo - y lo) + ∑ j, b lo j * ((p lo - p j) + η * (p lo - p j) ^ 3) = 0
    at hrlo
  have hpmax : p hi ≤ y hi := by nlinarith [ha hi]
  have hpmin : y lo ≤ p lo := by nlinarith [ha lo]
  exact abs_le.mpr ⟨((abs_le.mp (hy lo)).1.trans hpmin).trans
      (hmin i (Finset.mem_univ i)),
    (hmax i (Finset.mem_univ i)).trans (hpmax.trans (abs_le.mp (hy hi)).2)⟩

end Vbd.AxialSpring
