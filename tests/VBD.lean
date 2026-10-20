/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBD
import Vbd.Block.Contraction

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

section CrossNorm

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, InnerProductSpace ℝ (B i)]
  [∀ i, CompleteSpace (B i)] [∀ i, FiniteDimensional ℝ (B i)]

-- The production consistency proof discharges unbiasedness before passing to Phase 5.
-- Solver existence uses Phase 6's maximum-norm state and yields a physical IE root.
example (ie : ImplicitEulerStep (BlockSum B)) (threshold : ℝ≥0) (order : List ι)
    (hn : order.Nodup) (hcover : ∀ i, i ∈ order) {S : Set (BlockSum B)} {q : ℝ≥0}
    (hreg : ∀ x ∈ S, ∀ i, (ie.blockNewtonData threshold).Regular i x)
    (hcomplete : IsComplete ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    (hne : ((BlockContraction.toMax (B := B)).symm ⁻¹' S).Nonempty)
    (hS : Set.MapsTo (BlockContraction.maxMap ((ie.blockNewtonData threshold).serial order))
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    (hT : LipschitzOnWith q
      (BlockContraction.maxMap ((ie.blockNewtonData threshold).serial order))
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S)) (hq : q < 1) :
    ∃ p ∈ (BlockContraction.toMax (B := B)).symm ⁻¹' S,
      Function.IsFixedPt (BlockContraction.maxMap ((ie.blockNewtonData threshold).serial order)) p ∧
      ie.energyGradient ((BlockContraction.toMax (B := B)).symm p) = 0 ∧
      ∀ y ∈ (BlockContraction.toMax (B := B)).symm ⁻¹' S,
        Function.IsFixedPt
          (BlockContraction.maxMap ((ie.blockNewtonData threshold).serial order)) y →
          y = p := by
  exact (((ie.blockNewtonData threshold).unbiasedOn_serial order hn hcover hreg).comp_equiv
    (BlockContraction.toMax (B := B)).symm.toEquiv).exists_fixedPoint hcomplete hne hS hT hq

end CrossNorm

end Vbd.Tests
