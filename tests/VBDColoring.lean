/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringColoring

/-! Compile with `lake lean tests/VBDColoring.lean`.
Checks shared-neighbor snapshot equivalence, nonlinear endpoint contraction, skip branches,
and the component-energy bridge with vector blocks and three-block supports. -/

noncomputable section

open scoped NNReal

namespace Vbd.Tests

private def chainEdges : Matrix (Fin 4) (Fin 4) ℝ := fun i j ↦
  if i.val + 1 = j.val ∨ j.val + 1 = i.val then 1 / 4 else 0

private theorem chainEdges_nonneg (i j : Fin 4) : 0 ≤ chainEdges i j := by
  dsimp [chainEdges]
  split_ifs <;> norm_num

private theorem chainEdges_support (i j : Fin 4) (hij : i.val + 1 ≠ j.val)
    (hji : j.val + 1 ≠ i.val) : chainEdges i j = 0 := by simp [chainEdges, hij, hji]

private theorem chain_incident (i : Fin 4) : ∑ j, chainEdges i j ≤ (1 : ℝ) / 2 := by
  fin_cases i <;> norm_num [chainEdges, Fin.sum_univ_succ]

private def chainData := AxialSpring.newtonData (fun _ : Fin 4 ↦ 1) chainEdges 1
  (AxialSpring.cosinePredictor 4) ⟨1 / 10 ^ 12, by positivity⟩

private theorem chainData_local : chainData.LocalOn (AxialSpring.chainSupports 4) :=
  AxialSpring.newtonData_localOn _ _ _ _ _ _ (AxialSpring.chain_supports chainEdges_support)

-- Blocks 0 and 2 both read block 1; disjoint reads are unnecessary.
-- Reversing the enumeration within either color preserves the full buffered map.
example : chainData.buffered [{0, 2}, {1, 3}] = chainData.serial [2, 0, 3, 1] := by
  simpa [Finset.pair_comm] using chainData.buffered_eq_serial_of_color chainData_local
    (AxialSpring.chainColoring 4)
    [[2, 0], [3, 1]] (by simp)
    (by
      intro order ho
      simp only [List.mem_cons, List.not_mem_nil, or_false] at ho
      rcases ho with rfl | rfl
      · exact ⟨0, by
          intro i hi
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
          rcases hi with rfl | rfl <;> rfl⟩
      · exact ⟨1, by
          intro i hi
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hi
          rcases hi with rfl | rfl <;> rfl⟩)

example : LipschitzOnWith (318 / 625 : ℝ≥0)
    (BlockContraction.maxMap (chainData.colored (AxialSpring.chainColoring 4) [0, 1]))
      AxialSpring.stateBox := by
  exact AxialSpring.lipschitzOnWith_chain_colored (by intro i; norm_num) chainEdges_nonneg
    (by norm_num) (by norm_num) chain_incident (AxialSpring.cosinePredictor_bound 4)
    _ (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num) chainEdges_support

example (k : ℕ) : (BlockContraction.maxMap
    (chainData.colored (AxialSpring.chainColoring 4) [0, 1]))^[k]
      (BlockContraction.toMax (AxialSpring.cosinePredictor 4)) ∈ AxialSpring.stateBox := by
  have hm := AxialSpring.chain_colored_preserves_box (η := 1) (by intro i; norm_num)
    chainEdges_nonneg (by norm_num) (by norm_num) chain_incident
    (AxialSpring.cosinePredictor_bound 4) (⟨1 / 10 ^ 12, by positivity⟩ : ℝ≥0)
    (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num) chainEdges_support
  exact hm.iterate k (AxialSpring.cosinePredictor_mem_stateBox 4)

-- Complete color execution supplies the independent fixed-point/root consistency premise.
example (x : AxialSpring.State (Fin 4)) :
    chainData.colored (AxialSpring.chainColoring 4) [0, 1] x = x ↔ chainData.residual x = 0 := by
  apply chainData.colored_fixed_iff_residual_eq_zero _ _ (by decide)
    (by intro color; fin_cases color <;> simp)
  exact fun i ↦ AxialSpring.regular_newtonData (by intro i; norm_num) chainEdges_nonneg
    (by norm_num) _ _ _ (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num) i

-- Locality and commutation hold at arbitrary thresholds, even outside the contraction range.
private def mixedData := AxialSpring.newtonData
  (fun i : Fin 4 ↦ if i = 0 then 1 else 3) chainEdges 1 (WithLp.toLp 2 fun _ ↦ 1) 2

private theorem mixed_local : mixedData.LocalOn (AxialSpring.chainSupports 4) :=
  AxialSpring.newtonData_localOn _ _ _ _ _ _ (AxialSpring.chain_supports chainEdges_support)

example : mixedData.update 0 (0 : AxialSpring.State (Fin 4)) = 0 := by
  apply mixedData.update_of_skip
  norm_num [mixedData, AxialSpring.newtonData, AxialSpring.diagonal, AxialSpring.stiffness,
    chainEdges, Fin.sum_univ_succ]

example : mixedData.residual (0 : AxialSpring.State (Fin 4)) 0 = -1 := by
  norm_num [mixedData, AxialSpring.newtonData, AxialSpring.residual, chainEdges,
    Fin.sum_univ_succ]

example : mixedData.Regular 2 (0 : AxialSpring.State (Fin 4)) := by
  norm_num [mixedData, AxialSpring.newtonData, BlockNewtonData.Regular, AxialSpring.diagonal,
    AxialSpring.stiffness, chainEdges, Fin.sum_univ_succ, show (2 : Fin 4) ≠ 0 by decide]

example : mixedData.batch {0, 2} = mixedData.serial [2, 0] := by
  apply mixedData.batch_eq_serial_of_color mixed_local (AxialSpring.chainColoring 4) 0
    _ _ [2, 0] (by simp) (by simp [or_comm])
  intro i hi
  simp only [Finset.mem_insert, Finset.mem_singleton] at hi
  rcases hi with rfl | rfl <;> rfl

private abbrev VectorBlock := EuclideanSpace ℝ (Fin 2)
private abbrev VectorState := BlockSum (fun _ : Fin 5 ↦ VectorBlock)

private def tripleSupports : Finset (Finset (Fin 5)) := {{0, 1, 2}, {2, 3, 4}}

private def tripleColor (i : Fin 5) : Fin 3 :=
  if i = 0 ∨ i = 3 then 0 else if i = 1 ∨ i = 4 then 1 else 2

private def tripleColoring : (componentGraph tripleSupports).Coloring (Fin 3) :=
  coloringOfInjectiveOnSupports _ tripleColor (by
    intro S hS i j hi hj hc
    simp only [tripleSupports, Finset.mem_insert, Finset.mem_singleton] at hS
    rcases hS with rfl | rfl <;>
      fin_cases i <;> fin_cases j <;> simp_all [tripleColor])

-- Two-dimensional blocks in distinct three-block components may share the unchanged block 2.
-- The locality premise comes from the potential energy and block-diagonal mass.
example (ie : ImplicitEulerStep VectorState) (P : LocalPotential (B := fun _ : Fin 5 ↦ VectorBlock))
    (hE : ie.E = P.energy) (hS : P.supports = tripleSupports)
    (hM : ie.M = ContinuousLinearMap.id ℝ VectorState) (threshold : ℝ≥0) :
    (ie.blockNewtonData threshold).batch {0, 3} =
      (ie.blockNewtonData threshold).serial [3, 0] := by
  have hl : (ie.blockNewtonData threshold).LocalOn tripleSupports := by
    simpa only [hS] using ie.blockNewtonData_localOn P hE
      (by intro i j hij; simp [hM, hij]) threshold
  apply BlockNewtonData.batch_eq_serial_of_color _ hl tripleColoring 0 _ _ [3, 0]
    (by simp) (by simp [or_comm])
  intro i hi
  simp only [Finset.mem_insert, Finset.mem_singleton] at hi
  rcases hi with rfl | rfl <;> rfl

end Vbd.Tests
