/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringChain

/-! Compile with `lake lean tests/VBDFinite.lean`.
Checks the complete physical-input pipeline at the timestep endpoint, large mass/stiffness
contrasts, nonlinear and quadratic cases, and a force-unit normalization anchor. -/

noncomputable section

open scoped NNReal

namespace Vbd.Tests

/-- Alternating masses and spring stiffnesses at the admitted physical timestep endpoint. -/
private def nonlinearChain (n : ℕ) : AxialSpring.ChainSystem n where
  mass := fun i ↦ if i.val % 2 = 0 then 1 / 1000 else 1
  spring := fun i j ↦ if i.val + 1 = j.val ∨ j.val + 1 = i.val then
    (if min i.val j.val % 2 = 0 then 250 else 1 / 40) else 0
  minMass := 1 / 1000
  minMass_pos := by norm_num
  mass_lower := by intro i; split_ifs <;> norm_num
  maxSpring := 250
  maxSpring_nonneg := by norm_num
  spring_nonneg := by intro i j; split_ifs <;> norm_num
  spring_upper := by intro i j; split_ifs <;> norm_num
  spring_symm := by intro i j; simp only [min_comm, or_comm]
  spring_support := by intro i j hij hji; simp [hij, hji]
  h := 1 / 1000
  h_pos := by norm_num
  length := 1 / 10
  length_pos := by norm_num
  η := 1
  η_nonneg := by norm_num
  η_le_one := by norm_num
  timestep_bound := by norm_num

-- The fixture realizes α = 1/4, mass ratio 1000, and stiffness ratio 10000.
example : (nonlinearChain 4).α = 1 / 4 := by norm_num [nonlinearChain, AxialSpring.ChainSystem.α]

example : (nonlinearChain 4).a 1 = 1000 := by norm_num [nonlinearChain, AxialSpring.ChainSystem.a]

example : (nonlinearChain 4).spring 0 1 / (nonlinearChain 4).spring 1 2 = 10000 := by
  norm_num [nonlinearChain]

-- There is no supplied root, contraction, invariant-set, or residual-regularity premise.
example (n : ℕ) : ∃ p, (nonlinearChain n).Certificate p := (nonlinearChain n).end_to_end

-- Both production plans solve the same physical IE equation and meet the 20-sweep target.
example : ∃ p, (nonlinearChain 64).physicalStep.energyGradient
    ((nonlinearChain 64).length • p) = 0 ∧
    ‖(nonlinearChain 64).physicalScaledResidual ((nonlinearChain 64).length •
      (nonlinearChain 64).serial^[20] (AxialSpring.cosinePredictor 64))‖ < 1 / 10 ^ 6 ∧
    ‖(nonlinearChain 64).physicalScaledResidual ((nonlinearChain 64).length •
      (nonlinearChain 64).colored^[20] (AxialSpring.cosinePredictor 64))‖ < 1 / 10 ^ 6 := by
  obtain ⟨p, hp⟩ := (nonlinearChain 64).end_to_end
  exact ⟨p, hp.physical_root, hp.serial_twenty.trans (by norm_num),
    hp.colored_twenty.trans (by norm_num)⟩

private def quadraticChain (n : ℕ) : AxialSpring.ChainSystem n :=
  { nonlinearChain n with η := 0, η_nonneg := by norm_num, η_le_one := by norm_num }

example : ∃ p, (quadraticChain 4).Certificate p := (quadraticChain 4).end_to_end

private def displaced : AxialSpring.State (Fin 2) :=
  WithLp.toLp 2 fun i ↦ if i = 0 then 1 / 10 else -1 / 10

-- At the first bead the physical inertia force is 5 and the nonlinear spring force is 5.2.
example : (nonlinearChain 2).physicalStep.energyGradient
    ((nonlinearChain 2).length • displaced) 0 = 51 / 5 := by
  rw [AxialSpring.ChainSystem.physical_gradient]
  norm_num [nonlinearChain, AxialSpring.ChainSystem.a, AxialSpring.ChainSystem.b,
    AxialSpring.residual, AxialSpring.cosinePredictor, displaced, Fin.sum_univ_two]

-- The physical spring energy counts the symmetric pair once, with the stated length units.
example : (nonlinearChain 2).physicalStep.E
    ((nonlinearChain 2).length • displaced) = 51 / 1000 := by
  norm_num [AxialSpring.ChainSystem.physicalStep, AxialSpring.normalizedStep,
    AxialSpring.potential, nonlinearChain, displaced, Fin.sum_univ_two]

example : (nonlinearChain 2).physicalScaledResidual
    ((nonlinearChain 2).length • displaced) 0 = 51 / 500 := by
  rw [AxialSpring.ChainSystem.physicalScaledResidual_eq]
  norm_num [AxialSpring.scaledResidual, nonlinearChain, AxialSpring.ChainSystem.a,
    AxialSpring.ChainSystem.b, AxialSpring.residual, AxialSpring.cosinePredictor, displaced,
    Fin.sum_univ_two, BlockContraction.toMax]

end Vbd.Tests
