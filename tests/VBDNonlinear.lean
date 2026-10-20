/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringNeighborhood

/-! Compile with `lake lean tests/VBDNonlinear.lean`.
Checks an off-root inverse-variation contribution, the nonlinear degree-two endpoint,
repeated visits, invariant warm starts, and a vector-block use of the full derivative. -/

noncomputable section

open scoped NNReal

namespace Vbd.Tests

private def chainEdges : Matrix (Fin 3) (Fin 3) ℝ := fun i j ↦
  if i.val + 1 = j.val ∨ j.val + 1 = i.val then 1 / 4 else 0

private theorem chainEdges_nonneg (i j : Fin 3) : 0 ≤ chainEdges i j := by
  dsimp [chainEdges]
  split_ifs <;> norm_num

private theorem chainEdges_zero (i : Fin 3) : chainEdges i i = 0 := by simp [chainEdges]

private theorem chain_incident (i : Fin 3) : ∑ j, chainEdges i j ≤ (1 : ℝ) / 2 := by
  fin_cases i <;> norm_num [chainEdges, Fin.sum_univ_succ]

private def chainData := AxialSpring.newtonData (fun _ : Fin 3 ↦ 1) chainEdges 1
  (AxialSpring.cosinePredictor 3) ⟨1 / 10 ^ 12, by positivity⟩

-- All model hypotheses are discharged at α = 1/4, η = 1, with a repeated covered order.
example : LipschitzOnWith (318 / 625 : ℝ≥0)
    (BlockContraction.maxMap (chainData.serial [0, 1, 1, 2])) AxialSpring.stateBox := by
  apply AxialSpring.lipschitzOnWith_serial_of_degree_two
    (by intro i; norm_num) chainEdges_nonneg chainEdges_zero (by norm_num) (by norm_num)
    (fun i ↦ Finset.univ.erase i) (by intro i; fin_cases i <;> decide)
    (by intro i j hj; simp_all [chainEdges, ne_comm])
    (α := 1 / 4) (by intro i j _; dsimp [chainEdges]; split_ifs <;> norm_num)
    (by norm_num) (by norm_num) (AxialSpring.cosinePredictor_bound 3)
    _ (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num)
    _ (by intro i; fin_cases i <;> simp)

-- The selected predictor remains in the certified box after any number of sweeps.
example (k : ℕ) : (BlockContraction.maxMap (chainData.serial [0, 1, 2]))^[k]
    (BlockContraction.toMax (AxialSpring.cosinePredictor 3)) ∈ AxialSpring.stateBox := by
  have hmaps := AxialSpring.serial_preserves_box (η := 1) (by intro i; norm_num) chainEdges_nonneg
    (by norm_num) (by norm_num) chain_incident (AxialSpring.cosinePredictor_bound 3)
    (⟨1 / 10 ^ 12, by positivity⟩ : ℝ≥0)
    (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num) [0, 1, 2]
  exact hmaps.iterate k (AxialSpring.cosinePredictor_mem_stateBox 3)

private def boundaryState : AxialSpring.State (Fin 3) :=
  WithLp.toLp 2 fun i ↦ if i = 1 then 1 / 10 else -1 / 10

-- The boundary is covered even though the force imbalance there is nonzero.
example : chainData.residual boundaryState ≠ 0 := by
  intro h
  have hi := congrArg (fun x : AxialSpring.State (Fin 3) ↦ x 1) h
  have hc := AxialSpring.cosinePredictor_bound 3 1
  norm_num [chainData, AxialSpring.newtonData, AxialSpring.residual, chainEdges,
    boundaryState, Fin.sum_univ_succ] at hi
  norm_num [AxialSpring.cosinePredictor] at hi hc
  norm_num [show (2 : Fin 3) ≠ 1 by decide] at hi
  rw [abs_le] at hc
  linarith

example (i j : Fin 3) : |chainData.update i boundaryState j| ≤ 1 / 10 := by
  apply AxialSpring.update_preserves_box (by intro i; norm_num) chainEdges_nonneg
    (by norm_num) (by norm_num) chain_incident (AxialSpring.cosinePredictor_bound 3)
    (by intro i; dsimp [boundaryState]; split_ifs <;> norm_num)
    _ (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num)

-- At a non-root boundary state the changed diagonal derivative is nonzero.
-- Dropping inverse variation would incorrectly make this entry zero.
example :
    let d := AxialSpring.newtonData (fun _ : Fin 3 ↦ 1) chainEdges 1 0 0
    BlockSum.entry (d.updateDerivative (AxialSpring.jacobian (fun _ ↦ 1) chainEdges 1
      boundaryState) boundaryState 1 (AxialSpring.diagonalBlockDerivative chainEdges 1
        boundaryState 1)) 1 1 1 = 17 / 338 := by
  let d := AxialSpring.newtonData (fun _ : Fin 3 ↦ 1) chainEdges 1 0 0
  have hreg := AxialSpring.regular_newtonData (a := fun _ : Fin 3 ↦ 1)
    (by intro i; norm_num) chainEdges_nonneg
    (by norm_num : (0 : ℝ) ≤ 1) (0 : AxialSpring.State (Fin 3)) boundaryState 0
    (by norm_num) 1
  have hI : ∀ r, ((39 / 25 : ℝ) • ContinuousLinearMap.id ℝ ℝ).inverse r =
      (25 / 39) * r := by
    intro r
    have hs := (d.isInvertible_of_regular hreg).self_apply_inverse r
    norm_num [d, AxialSpring.newtonData, AxialSpring.diagonal, AxialSpring.stiffness,
      chainEdges, boundaryState, Fin.sum_univ_succ, show (2 : Fin 3) ≠ 1 by decide] at hs
    linarith
  norm_num [BlockSum.entry_apply, BlockNewtonData.updateDerivative, BlockNewtonData.rootDerivative,
    hI, d, AxialSpring.newtonData, AxialSpring.residual, AxialSpring.diagonalBlockDerivative,
    AxialSpring.diagonalRowDerivative, AxialSpring.jacobian_apply, AxialSpring.stiffness,
    AxialSpring.diagonal,
    BlockSum.inject, chainEdges, boundaryState, Fin.sum_univ_succ,
    show (2 : Fin 3) ≠ 1 by decide]

private abbrev VectorBlock := EuclideanSpace ℝ (Fin 2)
private abbrev VectorState := BlockSum (fun _ : Fin 2 ↦ VectorBlock)

private def vectorData : BlockNewtonData (fun _ : Fin 2 ↦ VectorBlock) where
  residual := id
  diagonal := fun _ _ ↦ ContinuousLinearMap.id ℝ VectorBlock
  threshold := 0

-- The full derivative interface supports vector-valued blocks at arbitrary, non-root states.
example (x : VectorState) : HasFDerivAt (vectorData.update 0)
    (vectorData.updateDerivative (ContinuousLinearMap.id ℝ VectorState) x 0 0) x := by
  apply vectorData.hasFDerivAt_update (hasFDerivAt_id (𝕜 := ℝ) x)
    (by norm_num [vectorData, BlockNewtonData.Regular])
  exact hasFDerivAt_const (𝕜 := ℝ) (ContinuousLinearMap.id ℝ VectorBlock) x

end Vbd.Tests
