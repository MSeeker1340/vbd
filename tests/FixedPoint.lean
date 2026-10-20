/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Block.Contraction
import Vbd.Integrator.FixedPoint
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
Compile with `lake lean tests/FixedPoint.lean`.

These integration checks use Phase 6's actual maximum-norm solver representation and an IE
residual valued in the original heterogeneous Hilbert block sum. The solver state carries no
inner-product instance. All physical and execution premises remain explicit inputs.
-/

open Function Set
open scoped NNReal

namespace Vbd.Tests

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, InnerProductSpace ℝ (B i)]
  [∀ i, CompleteSpace (B i)]
  (ie : ImplicitEulerStep (BlockSum B)) {T : BlockSum B → BlockSum B}
  {S : Set (BlockSum B)} {q L : ℝ≥0}

-- Banach existence uses the maximum-norm metric; unbiasedness identifies the physical IE root.
example (hU : UnbiasedOn ie.energyGradient T S)
    (hcomplete : IsComplete ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    (hne : ((BlockContraction.toMax (B := B)).symm ⁻¹' S).Nonempty)
    (hS : MapsTo (BlockContraction.maxMap T)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    (hT : LipschitzOnWith q (BlockContraction.maxMap T)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S)) (hq : q < 1) :
    ∃ p ∈ (BlockContraction.toMax (B := B)).symm ⁻¹' S,
      IsFixedPt (BlockContraction.maxMap T) p ∧
      ie.energyGradient ((BlockContraction.toMax (B := B)).symm p) = 0 ∧
      ∀ y ∈ (BlockContraction.toMax (B := B)).symm ⁻¹' S,
        IsFixedPt (BlockContraction.maxMap T) y → y = p := by
  exact (hU.comp_equiv (BlockContraction.toMax (B := B)).symm.toEquiv).exists_fixedPoint
    hcomplete hne hS hT hq

-- The left side uses the Hilbert residual norm; the right side uses maximum-norm state distance.
example (hU : UnbiasedOn ie.energyGradient T S)
    (hS : MapsTo (BlockContraction.maxMap T)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    (hT : LipschitzOnWith q (BlockContraction.maxMap T)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    (hF : LipschitzOnWith L
      (ie.energyGradient ∘ (BlockContraction.toMax (B := B)).symm)
      ((BlockContraction.toMax (B := B)).symm ⁻¹' S))
    {x p : (i : ι) → B i}
    (hx : x ∈ (BlockContraction.toMax (B := B)).symm ⁻¹' S)
    (hp : p ∈ (BlockContraction.toMax (B := B)).symm ⁻¹' S)
    (hfix : IsFixedPt (BlockContraction.maxMap T) p) (k : ℕ) :
    ‖ie.energyGradient ((BlockContraction.toMax (B := B)).symm
      ((BlockContraction.maxMap T)^[k] x))‖ ≤
        (L : ℝ) * (q : ℝ) ^ k * dist x p := by
  exact (hU.comp_equiv (BlockContraction.toMax (B := B)).symm.toEquiv).norm_iterate_le
    hS hT hF hx hp hfix k

end Vbd.Tests
