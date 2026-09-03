/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/

import Mathlib.Analysis.Calculus.Gradient.Basic
import Mathlib.Analysis.InnerProductSpace.Adjoint
import Mathlib.Analysis.InnerProductSpace.Calculus

/-!
# Implicit Euler as optimization

The basis-free multivariate-calculus core of the implicit-Euler incremental energy.

Context: `knowledge/mathematics/implicit-euler.md`
-/

open scoped Gradient InnerProductSpace

noncomputable section

namespace Vbd

/-- The data defining one implicit-Euler timestep problem. -/
structure ImplicitEulerStep (X : Type*) [NormedAddCommGroup X] [InnerProductSpace ℝ X]
    [CompleteSpace X] where
  /-- The continuous linear mass operator. -/
  M : X →L[ℝ] X
  /-- The self-adjointness of the mass operator. -/
  mass_self_adjoint : IsSelfAdjoint M
  /-- The potential energy. -/
  E : X → ℝ
  /-- The global differentiability of the potential energy. -/
  E_differentiable : Differentiable ℝ E
  /-- The global differentiability of the potential gradient. -/
  gradient_differentiable : Differentiable ℝ (∇ E)
  /-- The timestep. -/
  h : ℝ
  /-- The positivity of the timestep. -/
  h_pos : 0 < h
  /-- The predicted state. -/
  y : X

variable {X : Type*} [NormedAddCommGroup X] [InnerProductSpace ℝ X] [CompleteSpace X]

namespace ImplicitEulerStep

/-! ## VBD-facing definitions -/

/-- The Hessian of `f` at `x`. -/
def hessian (f : X → ℝ) (x : X) : X →L[ℝ] X :=
  fderiv ℝ (∇ f) x

/-- The inertial term `(2 h²)⁻¹ ⟪x - y, M (x - y)⟫` of an implicit-Euler problem. -/
def inertia (ie : ImplicitEulerStep X) (x : X) : ℝ :=
  (2 * ie.h ^ 2)⁻¹ * ⟪x - ie.y, ie.M (x - ie.y)⟫_ℝ

/-- The implicit-Euler incremental energy `G = inertia + E`. -/
def energy (ie : ImplicitEulerStep X) (x : X) : ℝ :=
  inertia ie x + ie.E x

/-- The inertial-gradient vector `h⁻² • M (x - y)` of an implicit-Euler problem. -/
def inertiaGradient (ie : ImplicitEulerStep X) (x : X) : X :=
  (ie.h ^ 2)⁻¹ • ie.M (x - ie.y)

/-- The gradient of the implicit-Euler energy `inertiaGradient ie x + ∇ ie.E x`. -/
def energyGradient (ie : ImplicitEulerStep X) (x : X) : X :=
  inertiaGradient ie x + ∇ ie.E x

/-- The Hessian of the potential energy at `x`. -/
def potentialHessian (ie : ImplicitEulerStep X) (x : X) : X →L[ℝ] X :=
  hessian ie.E x

/-! ## Internal calculus lemmas -/

/-- The gradient certificate for the inertial term at `x`. -/
private theorem hasGradientAt_inertia (ie : ImplicitEulerStep X) (x : X) :
    HasGradientAt (inertia ie) (inertiaGradient ie x) x := by
  rw [hasGradientAt_iff_hasFDerivAt]
  let q' :=
    (fderivInnerCLM ℝ (x - ie.y, ie.M (x - ie.y))).comp
      ((ContinuousLinearMap.id ℝ X).prod ie.M)
  have hq : HasFDerivAt (fun z ↦ ⟪z - ie.y, ie.M (z - ie.y)⟫_ℝ) q' x :=
    ((hasFDerivAt_id x).sub_const ie.y).inner ℝ
      (ie.M.hasFDerivAt.comp x ((hasFDerivAt_id x).sub_const ie.y))
  have hs : HasFDerivAt (inertia ie) ((2 * ie.h ^ 2)⁻¹ • q') x := by
    convert hq.const_mul ((2 * ie.h ^ 2)⁻¹) using 1 <;> rfl
  have hd : (2 * ie.h ^ 2)⁻¹ • q' =
      (InnerProductSpace.toDual ℝ X) (inertiaGradient ie x) := by
    ext v
    simp [q', inertiaGradient, ie.mass_self_adjoint.isSymmetric]
    field_simp
    rw [← map_sub]
    rw [← inner_sub_left]
    have hv : ⟪v, ie.M (x - ie.y)⟫_ℝ = ⟪x - ie.y, ie.M v⟫_ℝ :=
      (ie.mass_self_adjoint.isSymmetric v (x - ie.y)).symm.trans
        (real_inner_comm (ie.M v) (x - ie.y)).symm
    rw [hv]
    ring
  rw [← hd]
  exact hs

/-- The derivative certificate for the inertial-gradient function at `x`. -/
private theorem hasFDerivAt_inertiaGradient (ie : ImplicitEulerStep X) (x : X) :
    HasFDerivAt (inertiaGradient ie) ((ie.h ^ 2)⁻¹ • ie.M) x := by
  have hbase : HasFDerivAt (fun z ↦ ie.M (z - ie.y)) ie.M x := by
    convert ie.M.hasFDerivAt.comp x ((hasFDerivAt_id x).sub_const ie.y) using 1
    · ext z
      simp
    · ext z
      simp
  convert hbase.const_smul ((ie.h ^ 2)⁻¹) using 1
  ext z
  simp [inertiaGradient]

/-! ## VBD-facing identities -/

/-- The incremental energy is globally differentiable. -/
theorem differentiable_energy (ie : ImplicitEulerStep X) : Differentiable ℝ (energy ie) := by
  intro x
  exact (hasGradientAt_inertia ie x).differentiableAt.add (ie.E_differentiable x)

/-- The gradient of the incremental energy. -/
theorem gradient_energy (ie : ImplicitEulerStep X) : ∇ (energy ie) = energyGradient ie := by
  apply gradient_eq
  intro x
  change HasGradientAt (energy ie) (inertiaGradient ie x + ∇ ie.E x) x
  rw [hasGradientAt_iff_hasFDerivAt]
  convert
    (hasGradientAt_inertia ie x).hasFDerivAt.add
      (ie.E_differentiable x).hasGradientAt.hasFDerivAt using 1 <;>
    first | rfl | exact map_add _ _ _

/-- The Hessian of the incremental energy at `x`. -/
theorem hessian_energy (ie : ImplicitEulerStep X) (x : X) :
    hessian (energy ie) x = (ie.h ^ 2)⁻¹ • ie.M + potentialHessian ie x := by
  unfold hessian
  rw [gradient_energy ie]
  change fderiv ℝ (energyGradient ie) x = (ie.h ^ 2)⁻¹ • ie.M + fderiv ℝ (∇ ie.E) x
  apply HasFDerivAt.fderiv
  convert (hasFDerivAt_inertiaGradient ie x).add
    (ie.gradient_differentiable x).hasFDerivAt using 1
  ext z
  rfl

end ImplicitEulerStep
end Vbd
