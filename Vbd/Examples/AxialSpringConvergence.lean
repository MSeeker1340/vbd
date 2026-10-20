/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringResidual
import Vbd.Examples.AxialSpringColoring

/-!
# Finite-sweep axial-spring convergence

The prepared Banach, consistency, and cross-norm residual interfaces combine with the physical
spring estimates. Certificates include a unique residual root, predictor-box root location,
convergence of the actual production iterates, and explicit finite state and scaled-residual
bounds. Serial and proper-color plans supply the same hypotheses.
-/

noncomputable section

open Filter Function Set Topology
open scoped NNReal

namespace Vbd.AxialSpring

variable {ι : Type*} [Fintype ι]

/-- The quantitative conclusion for an actual spring sweep and its selected stationary point. -/
structure SweepCertificate (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y : State ι)
    (T : State ι → State ι) (p : State ι) : Prop where
  /-- The fixed point solves the physical polynomial force equation. -/
  stationary : residual a b η y p = 0
  /-- The root lies inside the predictor bounds. -/
  root_bound : ∀ i, |p i| ≤ 1 / 20
  /-- Every force-balanced state is this root. -/
  unique_root : ∀ z, residual a b η y z = 0 → z = p
  /-- Production iterates from the selected predictor converge in the maximum norm. -/
  converges : Tendsto (fun k ↦ BlockContraction.toMax (T^[k] y)) atTop
    (𝓝 (BlockContraction.toMax p))
  /-- Finite state error for every sweep budget. -/
  state_error : ∀ k, dist (BlockContraction.toMax (T^[k] y)) (BlockContraction.toMax p) ≤
    (1 / 10) * (318 / 625 : ℝ) ^ k
  /-- Finite physical-residual error with mass scaling and its maximum norm. -/
  residual_error : ∀ k, ‖scaledResidual a b η y (BlockContraction.toMax (T^[k] y))‖ ≤
    (53 / 250) * (318 / 625 : ℝ) ^ k

omit [Fintype ι] in
private theorem iterate_toMax (T : State ι → State ι) (u : State ι) (k : ℕ) :
    (BlockContraction.maxMap T)^[k] (BlockContraction.toMax u) =
      BlockContraction.toMax (T^[k] u) := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [Function.iterate_succ_apply', Function.iterate_succ_apply', ih]
    simp only [BlockContraction.maxMap, Function.comp_apply,
      ContinuousLinearEquiv.symm_apply_apply]

/-- The physical spring hypotheses feed Phase 5's prepared fixed-point and residual bridges. -/
theorem exists_sweepCertificate {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hy : ∀ i, |y i| ≤ 1 / 20)
    (T : State ι → State ι)
    (hS : MapsTo (BlockContraction.maxMap T) stateBox stateBox)
    (hT : LipschitzOnWith (318 / 625 : ℝ≥0) (BlockContraction.maxMap T) stateBox)
    (hU : UnbiasedOn (residual a b η y ∘ BlockContraction.toMax.symm)
      (BlockContraction.maxMap T) stateBox)
    (hpres : ∀ p, residual a b η y p = 0 → T p = p) :
    ∃ p, SweepCertificate a b η y T p := by
  have hcomplete : IsComplete (stateBox : Set (ι → ℝ)) := Metric.isClosed_closedBall.isComplete
  obtain ⟨x, hx, hfix, hroot, huniq⟩ := hU.exists_fixedPoint hcomplete
    ⟨0, zero_mem_stateBox⟩ hS hT (by norm_num)
  let p : State ι := BlockContraction.toMax.symm x
  have hp : residual a b η y p = 0 := hroot
  have hpb : ∀ i, |p i| ≤ 1 / 20 := abs_root_le ha hb hη hy hp
  have hdist : dist (BlockContraction.toMax y) x ≤ 1 / 10 := by
    rw [dist_eq_norm]
    apply (pi_norm_le_iff_of_nonneg (by norm_num : (0 : ℝ) ≤ 1 / 10)).mpr
    intro i
    change |y i - p i| ≤ 1 / 10
    calc
      _ ≤ |y i| + |p i| := by simpa using abs_sub_le (y i) 0 (p i)
      _ ≤ _ := by linarith [hy i, hpb i]
  have hUF : UnbiasedOn (scaledResidual a b η y) (BlockContraction.maxMap T) stateBox := by
    intro z hz hfixed
    have hr := hU hz hfixed
    change residual a b η y (BlockContraction.toMax.symm z) = 0 at hr
    funext i
    simp [scaledResidual, hr]
  refine ⟨p, ⟨hp, hpb, ?_, ?_, ?_, ?_⟩⟩
  · intro z hz
    have hzbox : BlockContraction.toMax z ∈ stateBox :=
      (mem_stateBox_iff z).mpr fun i ↦ (abs_root_le ha hb hη hy hz i).trans (by norm_num)
    have hzfix : IsFixedPt (BlockContraction.maxMap T) (BlockContraction.toMax z) := by
      change BlockContraction.toMax (T (BlockContraction.toMax.symm
        (BlockContraction.toMax z))) = BlockContraction.toMax z
      rw [ContinuousLinearEquiv.symm_apply_apply, hpres z hz]
    have he := huniq _ hzbox hzfix
    exact (BlockContraction.toMax.symm_apply_apply z).symm.trans
      (congrArg BlockContraction.toMax.symm he)
  · simpa only [iterate_toMax, p, ContinuousLinearEquiv.apply_symm_apply] using
      Contraction.tendsto_iterate hS hT (by norm_num) (predictor_mem_stateBox hy) hx hfix
  · intro k
    have he := Contraction.dist_iterate_fixedPoint_le hS hT (predictor_mem_stateBox hy) hx hfix k
    have hd := he.trans (mul_le_mul_of_nonneg_left hdist (by positivity :
      0 ≤ (318 / 625 : ℝ) ^ k))
    simpa only [iterate_toMax, p, ContinuousLinearEquiv.apply_symm_apply, NNReal.coe_div,
      NNReal.coe_ofNat, mul_comm] using hd
  · intro k
    have he := hUF.norm_iterate_le hS hT (lipschitzOnWith_scaledResidual ha hb hη hη1 hrow y)
      (predictor_mem_stateBox hy) hx hfix k
    have hd := he.trans (mul_le_mul_of_nonneg_left hdist (by positivity :
      0 ≤ (53 / 25 : ℝ) * (318 / 625 : ℝ) ^ k))
    simpa only [iterate_toMax] using (show _ ≤ (53 / 250 : ℝ) * (318 / 625 : ℝ) ^ k from
      hd.trans_eq (by push_cast; ring))

/-- The state error also satisfies the convenient common factor `0.512` selected by AP-03. -/
theorem SweepCertificate.state_common_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y p : State ι} {T : State ι → State ι} (h : SweepCertificate a b η y T p) (k : ℕ) :
    dist (BlockContraction.toMax (T^[k] y)) (BlockContraction.toMax p) ≤
      (1 / 10) * (64 / 125 : ℝ) ^ k := by
  refine (h.state_error k).trans ?_
  exact mul_le_mul_of_nonneg_left
    (pow_le_pow_left₀ (by norm_num) (by norm_num : (318 / 625 : ℝ) ≤ 64 / 125) k)
    (by norm_num)

/-- The physical residual satisfies the common `0.212 (0.512)^k` finite-budget envelope. -/
theorem SweepCertificate.residual_common_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y p : State ι} {T : State ι → State ι} (h : SweepCertificate a b η y T p) (k : ℕ) :
    ‖scaledResidual a b η y (BlockContraction.toMax (T^[k] y))‖ ≤
      (53 / 250) * (64 / 125 : ℝ) ^ k := by
  refine (h.residual_error k).trans ?_
  exact mul_le_mul_of_nonneg_left
    (pow_le_pow_left₀ (by norm_num) (by norm_num : (318 / 625 : ℝ) ≤ 64 / 125) k)
    (by norm_num)

/-- The explicit 20-sweep estimate is below the selected conservative numerical budget. -/
theorem SweepCertificate.residual_twenty_lt {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y p : State ι} {T : State ι → State ι} (h : SweepCertificate a b η y T p) :
    ‖scaledResidual a b η y (BlockContraction.toMax (T^[20] y))‖ < 13 / 40000000 := by
  exact (h.residual_common_le 20).trans_lt (by norm_num)

/-- The model meets the `10⁻⁶` physical residual target after 20 complete sweeps. -/
theorem SweepCertificate.meets_target {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y p : State ι} {T : State ι → State ι} (h : SweepCertificate a b η y T p) :
    ‖scaledResidual a b η y (BlockContraction.toMax (T^[20] y))‖ < 1 / 10 ^ 6 :=
  h.residual_twenty_lt.trans (by norm_num)

omit [Fintype ι] in
private theorem fixedPoint_of_maxMap {T : State ι → State ι} {x : ι → ℝ}
    (h : IsFixedPt (BlockContraction.maxMap T) x) :
    IsFixedPt T (BlockContraction.toMax.symm x) := by
  change T (BlockContraction.toMax.symm x) = BlockContraction.toMax.symm x
  have he := congrArg BlockContraction.toMax.symm h
  simpa only [BlockContraction.maxMap, Function.comp_apply,
    ContinuousLinearEquiv.symm_apply_apply] using he

/-- Every certificate selects a stationary point of the actual implicit-Euler energy. -/
theorem SweepCertificate.energyGradient_eq_zero {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y p : State ι} {T : State ι → State ι} (h : SweepCertificate a b η y T p)
    (hsym : ∀ i j, b i j = b j i) :
    (normalizedStep a b η y hsym).energyGradient p = 0 := by
  rw [normalizedStep_energyGradient]
  exact h.stationary

variable [DecidableEq ι]

/-- A covered once-per-block serial plan discharges all analytic and consistency premises. -/
theorem serial_sweepCertificate {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2)
    (hy : ∀ i, |y i| ≤ 1 / 20) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (order : List ι) (hn : order.Nodup) (hcover : ∀ i, i ∈ order) :
    ∃ p, SweepCertificate a b η y ((newtonData a b η y threshold).serial order) p := by
  apply exists_sweepCertificate ha hb hη hη1 hrow hy _
    (serial_preserves_box ha hb hη hη1 hrow hy threshold ht order)
    (lipschitzOnWith_serial ha hb hzero hη hη1 hrow hy threshold ht order hcover)
  · intro x _ hfix
    exact ((newtonData a b η y threshold).serial_fixed_iff_residual_eq_zero order hn hcover _
      (fun i ↦ regular_newtonData ha hb hη y _ threshold ht i)).mp (fixedPoint_of_maxMap hfix)
  · exact fun p hp ↦ (newtonData a b η y threshold).serial_of_residual_eq_zero order hp

/-- Proper-color buffered execution meets the same finite-sweep physical-residual certificate. -/
theorem colored_sweepCertificate {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2)
    (hy : ∀ i, |y i| ≤ 1 / 20) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (A : Finset (Finset ι)) (hs : ∀ i j, b i j ≠ 0 → ∃ S ∈ A, i ∈ S ∧ j ∈ S)
    {m : ℕ} (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m))
    (hn : colors.Nodup) (hcover : ∀ color, color ∈ colors) :
    ∃ p, SweepCertificate a b η y ((newtonData a b η y threshold).colored c colors) p := by
  apply exists_sweepCertificate ha hb hη hη1 hrow hy _
    (colored_preserves_box ha hb hη hη1 hrow hy threshold ht A hs c colors)
    (lipschitzOnWith_colored ha hb hzero hη hη1 hrow hy threshold ht A hs c colors hcover)
  · intro x _ hfix
    exact ((newtonData a b η y threshold).colored_fixed_iff_residual_eq_zero c colors hn hcover _
      (fun i ↦ regular_newtonData ha hb hη y _ threshold ht i)).mp (fixedPoint_of_maxMap hfix)
  · exact fun p hp ↦ (newtonData a b η y threshold).buffered_of_residual_eq_zero _ hp

end Vbd.AxialSpring
