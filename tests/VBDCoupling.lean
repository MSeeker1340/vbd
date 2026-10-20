/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpring

/-! Coupled nonlinear and vector-block checks for the serial root coupling certificate.
Run with `lake lean tests/VBDCoupling.lean`. -/

noncomputable section

open scoped NNReal

namespace Vbd.Tests

private def springEdges : Matrix (Fin 2) (Fin 2) ℝ := fun i j ↦ if i = j then 0 else 1 / 4

private def springRoot : AxialSpring.State (Fin 2) :=
  WithLp.toLp 2 fun i ↦ if i = 0 then 1 / 40 else -1 / 40

private def springPredictor : AxialSpring.State (Fin 2) :=
  WithLp.toLp 2 fun i ↦ if i = 0 then 1201 / 32000 else -1201 / 32000

-- Nonzero spring extension exercises the hardening contribution at the root.
private theorem springRoot_eq_zero :
    AxialSpring.residual (fun _ ↦ 1) springEdges 1 springPredictor springRoot = 0 := by
  ext i
  fin_cases i <;> norm_num [AxialSpring.residual, springEdges, springRoot, springPredictor,
    Fin.sum_univ_two]

-- The bound comes from coefficients, degree and the actual polynomial residual.
-- Regularity and local-Hessian differentiability are discharged by the model theorem.
example : ∃ D : (Fin 2 → ℝ) →L[ℝ] (Fin 2 → ℝ),
    HasFDerivAt (BlockContraction.maxMap
      ((AxialSpring.newtonData (fun _ ↦ 1) springEdges 1 springPredictor
        ⟨1 / 10 ^ 12, by positivity⟩).serial [0, 1])) D (BlockContraction.toMax springRoot) ∧
      ‖D‖ < 1 := by
  obtain ⟨D, hD, hbound⟩ := AxialSpring.serial_root_bound_of_degree_two
    (a := fun _ : Fin 2 ↦ 1) (b := springEdges) (η := 1) (α := 1 / 4)
    (by intro i; norm_num)
    (by intro i j; by_cases h : i = j <;> norm_num [springEdges, h])
    (by intro i; simp [springEdges]) (by norm_num) (by norm_num)
    (fun i ↦ Finset.univ.erase i) (by intro i; fin_cases i <;> decide)
    (by intro i j hj; simp_all [springEdges, ne_comm])
    (by intro i j _; by_cases h : i = j <;> norm_num [springEdges, h])
    (by norm_num) (by norm_num) springPredictor ⟨1 / 10 ^ 12, by positivity⟩
    (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num)
    [0, 1] (by intro i; fin_cases i <;> simp)
    (by intro i; fin_cases i <;> norm_num [springRoot]) springRoot_eq_zero
  exact ⟨D, hD, hbound.trans_lt (by norm_num)⟩

private abbrev Plane := EuclideanSpace ℝ (Fin 2)
private abbrev VectorState := BlockSum (fun _ : Fin 2 ↦ Plane)

private def vectorHessian : VectorState →L[ℝ] VectorState :=
  BlockSum.assemble fun i j ↦ if i = j then (2 : ℝ) • ContinuousLinearMap.id ℝ Plane
    else -ContinuousLinearMap.id ℝ Plane

private theorem vectorHessian_coercive (i : Fin 2) (v : Plane) :
    2 * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry vectorHessian i i v) := by
  simp [vectorHessian, real_inner_smul_right]

-- Two vector blocks, each with two components, use the same coupling certificate.
example : ‖(BlockContraction.toMax (B := fun _ : Fin 2 ↦ Plane)).toContinuousLinearMap.comp
    ((GaussSeidel.sweep vectorHessian [0, 1]).comp
      (BlockContraction.toMax (B := fun _ : Fin 2 ↦ Plane)).symm.toContinuousLinearMap)‖ ≤
        1 / 2 := by
  apply GaussSeidel.max_sweep_opNorm_le _ [0, 1] (by norm_num) (by norm_num)
    (by intro i; fin_cases i <;> simp)
  · exact fun i _ ↦ BlockCurvature.isInvertible (by norm_num : (0 : ℝ) < 2)
      (vectorHessian_coercive i)
  · intro i _
    have h := BlockCurvature.normalized_row_le vectorHessian i (by norm_num : (0 : ℝ) < 2)
      (vectorHessian_coercive i) (fun _ ↦ 1) (by
        intro j hj
        simp [vectorHessian, Ne.symm hj])
    simpa using h

end Vbd.Tests
