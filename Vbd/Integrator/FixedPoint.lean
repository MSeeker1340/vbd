/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Dynamics.Contraction
import Vbd.Integrator.ImplicitEulerEnergy

/-!
# Implicit-Euler solver consistency

This module combines the implicit-Euler residual with the objective-independent contraction
interfaces. `UnbiasedOn` identifies solver fixed points with roots of a supplied residual; the
concrete VBD theorem that discharges this premise belongs in the later synthesis layer.
Its generic fixed-point and residual estimates keep the metric state space separate from the
normed residual codomain. For a state representation `e : Y ≃ X`, use the residual
`ie.energyGradient ∘ e`: `Y` carries the solver metric and `X` retains the Hilbert geometry
used to define the gradient. A scaled residual may likewise use its own normed codomain and
Lipschitz constant. The IE specializations below retain the original same-space interface.

Context: `knowledge/mathematics/implicit-euler-fixed-points.md`
-/

open Filter Function Set Topology
open scoped NNReal

noncomputable section

namespace Vbd

/-- A solver has no spurious fixed point in `S` relative to `F`. -/
def UnbiasedOn {X Y : Type*} [Zero Y] (F : X → Y) (T : X → X) (S : Set X) : Prop :=
  ∀ ⦃x : X⦄, x ∈ S → IsFixedPt T x → F x = 0

namespace UnbiasedOn

variable {X Y : Type*} [MetricSpace X] {F : X → Y} {T : X → X} {S : Set X}
  {q L : ℝ≥0}

/-- A contraction has a unique solver fixed point, and unbiasedness makes it a residual root.
The state metric and residual codomain are independent; only the certified set must be complete. -/
theorem exists_fixedPoint [Zero Y] (hU : UnbiasedOn F T S)
    (hcomplete : IsComplete S) (hne : S.Nonempty)
    (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hq : q < 1) :
    ∃ p ∈ S, IsFixedPt T p ∧ F p = 0 ∧ ∀ y ∈ S, IsFixedPt T y → y = p := by
  obtain ⟨p, hp, hfix, hunique⟩ := Contraction.exists_fixedPoint hcomplete hne hS hT hq
  exact ⟨p, hp, hfix, hU hp hfix, hunique⟩

/-- A Lipschitz residual into an independently normed space transports the state-distance bound.
In particular, the state may use an `ℓᵖ` norm while the residual uses a Hilbert norm.
Neither strict contraction nor completeness is needed for this finite-iterate estimate. -/
theorem norm_iterate_le [SeminormedAddCommGroup Y] (hU : UnbiasedOn F T S)
    (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hF : LipschitzOnWith L F S)
    {x p : X} (hx : x ∈ S) (hp : p ∈ S) (hfix : IsFixedPt T p) (k : ℕ) :
    ‖F (T^[k] x)‖ ≤ (L : ℝ) * (q : ℝ) ^ k * dist x p := by
  rw [← dist_zero_right, ← hU hp hfix]
  refine (hF.dist_le_mul _ (hS.iterate k hx) _ hp).trans ?_
  rw [mul_assoc]
  exact mul_le_mul_of_nonneg_left
    (Contraction.dist_iterate_fixedPoint_le hS hT hx hp hfix k) L.coe_nonneg

omit [MetricSpace X] in
/-- Re-express a solver and residual on an equivalent state type. This algebraic consistency
transport needs no relation between the norms of the two representations. -/
theorem comp_equiv {Z : Type*} [Zero Y] (hU : UnbiasedOn F T S) (e : Z ≃ X) :
    UnbiasedOn (F ∘ e) (e.symm ∘ T ∘ e) (e ⁻¹' S) := by
  exact fun _ hz hfix ↦ hU hz ((e.apply_symm_apply _).symm.trans (congrArg e hfix))

end UnbiasedOn

namespace ImplicitEulerStep

variable {X : Type*} [NormedAddCommGroup X] [InnerProductSpace ℝ X] [CompleteSpace X]
  {ie : ImplicitEulerStep X} {T : X → X} {S : Set X} {q L : ℝ≥0}

/-- An unbiased solver fixed point is an implicit-Euler stationary point. -/
theorem energyGradient_eq_zero_of_unbiased_fixedPoint
    (hU : UnbiasedOn ie.energyGradient T S) {p : X} (hp : p ∈ S) (hfix : IsFixedPt T p) :
    ie.energyGradient p = 0 := by
  exact hU hp hfix

/-- Banach existence and unbiasedness produce an implicit-Euler solution that is the unique solver
fixed point in the certified region. -/
theorem exists_unbiased_fixedPoint (hcomplete : IsComplete S) (hne : S.Nonempty)
    (hS : MapsTo T S S) (hT : LipschitzOnWith q T S) (hq : q < 1)
    (hU : UnbiasedOn ie.energyGradient T S) :
    ∃ p ∈ S, IsFixedPt T p ∧ ie.energyGradient p = 0 ∧
      ∀ y ∈ S, IsFixedPt T y → y = p := by
  exact hU.exists_fixedPoint hcomplete hne hS hT hq

omit [InnerProductSpace ℝ X] [CompleteSpace X] in
/-- Finite iterate state error relative to a supplied solver fixed point. -/
theorem dist_iterate_fixedPoint_le (hS : MapsTo T S S) (hT : LipschitzOnWith q T S)
    {x p : X} (hx : x ∈ S) (hp : p ∈ S)
    (hfix : IsFixedPt T p) (k : ℕ) :
    dist (T^[k] x) p ≤ (q : ℝ) ^ k * dist x p := by
  exact Contraction.dist_iterate_fixedPoint_le hS hT hx hp hfix k

omit [InnerProductSpace ℝ X] [CompleteSpace X] in
/-- A supplied solver fixed point is the limit of iterates in its contractive region. -/
theorem tendsto_iterate_fixedPoint (hS : MapsTo T S S) (hT : LipschitzOnWith q T S)
    (hq : q < 1) {x p : X}
    (hx : x ∈ S) (hp : p ∈ S) (hfix : IsFixedPt T p) :
    Tendsto (fun k ↦ T^[k] x) atTop (𝓝 p) := by
  exact Contraction.tendsto_iterate hS hT hq hx hp hfix

/-- A Lipschitz implicit-Euler residual transports the contractive state error to a residual
error bound. -/
theorem norm_energyGradient_iterate_le (hS : MapsTo T S S) (hT : LipschitzOnWith q T S)
    (hU : UnbiasedOn ie.energyGradient T S) (hF : LipschitzOnWith L ie.energyGradient S)
    {x p : X} (hx : x ∈ S) (hp : p ∈ S) (hfix : IsFixedPt T p) (k : ℕ) :
    ‖ie.energyGradient (T^[k] x)‖ ≤
      (L : ℝ) * (q : ℝ) ^ k * dist x p := by
  exact hU.norm_iterate_le hS hT hF hx hp hfix k

end ImplicitEulerStep
end Vbd
