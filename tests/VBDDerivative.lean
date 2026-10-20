/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBDDerivative

/-! Compile with `lake lean tests/VBDDerivative.lean`.
Checks chronological Gauss–Seidel error propagation and nonlinear root cancellation. -/

noncomputable section

namespace Vbd.Tests

private abbrev TwoBlocks := BlockSum (fun _ : Fin 2 ↦ ℝ)

private def coupledHessian : TwoBlocks →L[ℝ] TwoBlocks :=
  BlockSum.assemble fun i j ↦ if i = j then ContinuousLinearMap.id ℝ ℝ
    else (-(1 / 2) : ℝ) • ContinuousLinearMap.id ℝ ℝ

private def initialError : TwoBlocks := WithLp.toLp 2 fun i ↦ if i = 0 then 7 else 2

example : GaussSeidel.sweep coupledHessian [0, 1] initialError 1 = 1 / 2 := by
  norm_num [GaussSeidel.sweep_cons, GaussSeidel.sweep_nil, GaussSeidel.step,
    coupledHessian, initialError, BlockSum.assemble_apply, Fin.sum_univ_two]

example : GaussSeidel.sweep coupledHessian [1, 0] initialError 0 = 7 / 4 := by
  norm_num [GaussSeidel.sweep_cons, GaussSeidel.sweep_nil, GaussSeidel.step,
    coupledHessian, initialError, BlockSum.assemble_apply, Fin.sum_univ_two]

-- Gradient and diagonal Hessian of `‖x‖₂² / 2 + x₀⁴ / 4`.
-- The nonlinear Hessian map varies with the state; its derivative contribution vanishes at zero.
private def cubicData : BlockNewtonData (fun _ : Fin 2 ↦ ℝ) where
  residual := fun x ↦ x + BlockSum.inclusion (𝕜 := ℝ) 0 ((x 0) ^ 3)
  diagonal := fun i x ↦ if i = 0 then
    (1 + 3 * (x 0) ^ 2) • ContinuousLinearMap.id ℝ ℝ else ContinuousLinearMap.id ℝ ℝ
  threshold := 0

example : HasFDerivAt (cubicData.serial [0])
    (GaussSeidel.sweep (ContinuousLinearMap.id ℝ TwoBlocks) [0]) 0 := by
  have hR : HasFDerivAt cubicData.residual (ContinuousLinearMap.id ℝ TwoBlocks) 0 := by
    convert (hasFDerivAt_id (0 : TwoBlocks)).add
      ((BlockSum.inclusion (B := fun _ : Fin 2 ↦ ℝ) (𝕜 := ℝ) 0).hasFDerivAt.comp 0
        ((BlockSum.projection (B := fun _ : Fin 2 ↦ ℝ) (𝕜 := ℝ) 0).hasFDerivAt.pow 3)) using 1
    all_goals first | rfl | simp
  have hK : DifferentiableAt ℝ (cubicData.diagonal 0) (0 : TwoBlocks) := by
    change DifferentiableAt ℝ (fun x : TwoBlocks ↦
      (1 + 3 * (BlockSum.projection (𝕜 := ℝ) 0 x) ^ 2) • ContinuousLinearMap.id ℝ ℝ) 0
    fun_prop
  exact cubicData.hasFDerivAt_serial_gaussSeidel [0] hR (by simp [cubicData, BlockSum.inject])
    (by norm_num [cubicData, BlockNewtonData.Regular])
    (by simpa only [List.mem_singleton, forall_eq] using hK)
    (by simp [cubicData])

end Vbd.Tests
