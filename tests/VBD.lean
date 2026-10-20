/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBD

/-! Concrete checks distinguishing chronological serial execution, coupled snapshot execution,
and determinant-threshold skipping. Run with `lake lean tests/VBD.lean`. -/

open scoped NNReal

noncomputable section

namespace Vbd.Tests

private abbrev TwoBlocks := BlockSum (fun _ : Fin 2 ↦ ℝ)

-- Gradient and diagonal Hessian of `(x₀ + x₁)² / 2 + x₀ + x₁`.
private def coupledData (threshold : ℝ≥0) : BlockNewtonData (fun _ : Fin 2 ↦ ℝ) where
  residual := fun x ↦ WithLp.toLp 2 fun _ ↦ x 0 + x 1 + 1
  diagonal := fun _ _ ↦ ContinuousLinearMap.id ℝ ℝ
  threshold := threshold

example : (coupledData 0).serial [0, 1] (0 : TwoBlocks) 0 = -1 := by
  norm_num [BlockNewtonData.serial_cons, BlockNewtonData.serial_nil, coupledData,
    BlockNewtonData.update, BlockNewtonData.Regular, BlockSum.replace]

example : (coupledData 0).serial [0, 1] (0 : TwoBlocks) 1 = 0 := by
  norm_num [BlockNewtonData.serial_cons, BlockNewtonData.serial_nil, coupledData,
    BlockNewtonData.update, BlockNewtonData.Regular, BlockSum.replace]

example : (coupledData 0).serial [1, 0] (0 : TwoBlocks) 1 = -1 := by
  norm_num [BlockNewtonData.serial_cons, BlockNewtonData.serial_nil, coupledData,
    BlockNewtonData.update, BlockNewtonData.Regular, BlockSum.replace]

example : (coupledData 0).batch {0, 1} (0 : TwoBlocks) 1 = -1 := by
  exact ((coupledData 0).batch_apply_of_mem (vertices := {0, 1}) (i := 1) (by simp) 0).trans
    (by norm_num [coupledData, BlockNewtonData.update, BlockNewtonData.Regular, BlockSum.replace])

-- Equality with the threshold skips an invertible block despite its nonzero residual.
example (x : TwoBlocks) : (coupledData 1).update 0 x = x := by
  exact BlockNewtonData.update_of_skip _ (by norm_num [coupledData])

end Vbd.Tests
