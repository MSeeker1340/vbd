/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBDCurvature

/-! Integration checks for physical inverse bounds, vector blocks, and strict skip thresholds.
Run with `lake lean tests/VBDCurvature.lean`. -/

noncomputable section

open scoped NNReal

namespace Vbd.Tests

section Physical

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, InnerProductSpace ℝ (B i)]
  [∀ i, CompleteSpace (B i)] [∀ i, FiniteDimensional ℝ (B i)]

-- Mass `2 I` and timestep `1/2` give curvature `8 I`. Even a concave potential with
-- Hessian `-I` leaves coercivity `7 I`, hence inverse norm at most `1/7` on the whole region.
example (ie : ImplicitEulerStep (BlockSum B)) (threshold : ℝ≥0)
    {S : Set (BlockSum B)} (hM : ie.M = (2 : ℝ) • ContinuousLinearMap.id ℝ (BlockSum B))
    (hh : ie.h = 1 / 2)
    (hP : ∀ x ∈ S, ie.potentialHessian x = -ContinuousLinearMap.id ℝ (BlockSum B)) :
    ∀ x ∈ S, ∀ i, ‖((ie.blockNewtonData threshold).diagonal i x).inverse‖ ≤ 1 / 7 := by
  have hbound := ie.blockNewtonData_inverse_bounds threshold (S := S) (fun _ ↦ 2) (fun _ ↦ 1)
  have hm : ∀ i v, 2 * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry ie.M i i v) := by
    intro i v
    simp [hM, real_inner_smul_right]
  have hp : ∀ x ∈ S, ∀ i v, -1 * ‖v‖ ^ 2 ≤
      inner ℝ v (BlockSum.entry (ie.potentialHessian x) i i v) := by
    intro x hx i v
    simp [hP x hx]
  intro x hx i
  convert (hbound hm hp (by norm_num [hh]) x hx i).2 using 1
  norm_num [hh]

end Physical

private abbrev Plane := BlockSum (fun _ : Fin 2 ↦ ℝ)

-- A two-dimensional block with distinct stiffnesses exercises operator inversion beyond scalars.
private def vectorStiffness : Plane →L[ℝ] Plane :=
  (2 : ℝ) • ContinuousLinearMap.id ℝ Plane +
    (3 : ℝ) • (BlockSum.inclusion 1).comp (BlockSum.projection 1)

private theorem vectorStiffness_coercive (v : Plane) :
    2 * ‖v‖ ^ 2 ≤ inner ℝ v (vectorStiffness v) := by
  rw [EuclideanSpace.real_norm_sq_eq, PiLp.inner_apply]
  simp [vectorStiffness, Fin.sum_univ_two, BlockSum.inject]
  nlinarith [sq_nonneg (v 1)]

example : ‖vectorStiffness.inverse‖ ≤ 1 / 2 := by
  simpa only [one_div] using
    BlockCurvature.norm_inverse_le (by norm_num : (0 : ℝ) < 2) vectorStiffness_coercive

-- The normalized scalar family has mass lower bound `1` and nonnegative potential curvature.
-- Those physical bounds, rather than an assumed regularity certificate, discharge VB-02's
-- skip-free premise at the selected positive production threshold.
example {ι : Type*} [Fintype ι] [DecidableEq ι]
    (ie : ImplicitEulerStep (BlockSum (fun _ : ι ↦ ℝ)))
    (order : List ι) (hn : order.Nodup) (hcover : ∀ i, i ∈ order)
    {S : Set (BlockSum (fun _ : ι ↦ ℝ))}
    (hM : ie.M = ContinuousLinearMap.id ℝ (BlockSum (fun _ : ι ↦ ℝ))) (hh : ie.h = 1)
    (hP : ∀ x ∈ S, ∀ i v, 0 ≤ inner ℝ v (BlockSum.entry (ie.potentialHessian x) i i v)) :
    UnbiasedOn ie.energyGradient
      ((ie.blockNewtonData ⟨1 / 10 ^ 12, by positivity⟩).serial order) S := by
  apply (ie.blockNewtonData ⟨1 / 10 ^ 12, by positivity⟩).unbiasedOn_serial order hn hcover
  exact ie.blockNewtonData_regular_of_scalar_curvature _ (fun _ ↦ 1) (fun _ ↦ 0)
    (fun i v ↦ by simp [hM]) (fun x hx i v ↦ by simpa using hP x hx i v)
    (by
      intro i
      change (1 / 10 ^ 12 : ℝ) < 1 / ie.h ^ 2 - 0
      norm_num [hh])

end Vbd.Tests
