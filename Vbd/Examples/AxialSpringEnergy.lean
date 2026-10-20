/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpring

/-!
# Axial-spring energy and implicit Euler

Symmetric spring coefficients give the polynomial force imbalance as the gradient of the
quadratic-plus-quartic component energy. A diagonal inertial operator places this energy in
the Phase-1 implicit-Euler interface. The actual polynomial Newton data then coincide with the
production IE constructor. Positivity and contraction are separate hypotheses.
-/

noncomputable section

open scoped Gradient InnerProductSpace NNReal

namespace Vbd.AxialSpring

variable {ι : Type*} [Fintype ι]

/-- Quadratic-plus-hardening spring potential, with each unoriented pair counted once. -/
def potential (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) : ℝ :=
  (1 / 2) * ∑ i, ∑ j, b i j * ((u i - u j) ^ 2 / 2 + η * (u i - u j) ^ 4 / 4)

/-- The derivative of the pair-summed potential before symmetry identifies its gradient. -/
def potentialDerivative (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) : State ι →L[ℝ] ℝ :=
  (1 / 2 : ℝ) • ∑ i, ∑ j, (b i j * ((u i - u j) + η * (u i - u j) ^ 3)) •
    ((BlockSum.projection i : State ι →L[ℝ] ℝ) - BlockSum.projection j)

omit [Fintype ι] in
private theorem hasFDerivAt_potentialTerm [Finite ι] (b : Matrix ι ι ℝ) (η : ℝ)
    (u : State ι) (i j : ι) :
    HasFDerivAt (fun x : State ι ↦ b i j * ((x i - x j) ^ 2 / 2 + η * (x i - x j) ^ 4 / 4))
      ((b i j * ((u i - u j) + η * (u i - u j) ^ 3)) •
        ((BlockSum.projection i : State ι →L[ℝ] ℝ) - BlockSum.projection j)) u := by
  let : Fintype ι := Fintype.ofFinite ι
  have hs : HasDerivAt (fun d : ℝ ↦ b i j * (d ^ 2 / 2 + η * d ^ 4 / 4))
      (b i j * ((u i - u j) + η * (u i - u j) ^ 3)) (u i - u j) := by
    convert ((((hasDerivAt_id (u i - u j)).pow 2).div_const 2).add
      ((((hasDerivAt_id (u i - u j)).pow 4).const_mul η).div_const 4)).const_mul (b i j)
      using 1
    all_goals first | rfl | (dsimp; ring)
  exact hs.comp_hasFDerivAt (f := fun x : State ι ↦ x i - x j) u
    ((BlockSum.projection i : State ι →L[ℝ] ℝ).hasFDerivAt.sub
      (BlockSum.projection j).hasFDerivAt)

/-- The potential has the pair-sum derivative at every state. -/
theorem hasFDerivAt_potential (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) :
    HasFDerivAt (potential b η) (potentialDerivative b η u) u := by
  convert (HasFDerivAt.sum (u := Finset.univ) fun i _ ↦
    HasFDerivAt.sum (u := Finset.univ) fun j _ ↦
      hasFDerivAt_potentialTerm b η u i j).const_mul (1 / 2) using 1
  all_goals first | rfl | exact funext (fun x ↦ by simp [potential, Finset.sum_apply])

/-- Symmetric edge coefficients identify the potential gradient with the spring forces. -/
theorem hasGradientAt_potential {b : Matrix ι ι ℝ} (hsym : ∀ i j, b i j = b j i)
    (η : ℝ) (u : State ι) :
    HasGradientAt (potential b η) (residual (fun _ ↦ 0) b η 0 u) u := by
  rw [hasGradientAt_iff_hasFDerivAt]
  refine (hasFDerivAt_potential b η u).congr_fderiv ?_
  apply ContinuousLinearMap.ext
  intro v
  have he : (∑ i, ∑ j, (b i j * ((u i - u j) + η * (u i - u j) ^ 3)) * v j) =
      -(∑ i, ∑ j, (b i j * ((u i - u j) + η * (u i - u j) ^ 3)) * v i) := by
    rw [Finset.sum_comm]
    simp only [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    rw [hsym j i]
    ring
  change (potentialDerivative b η u) v = inner ℝ (residual (fun _ ↦ 0) b η 0 u) v
  simp only [potentialDerivative, smul_apply, sum_apply, sub_apply,
    BlockSum.projection_apply, smul_eq_mul, PiLp.inner_apply, residual,
    zero_mul, sub_self, zero_add, Real.inner_apply, mul_sub, Finset.sum_sub_distrib,
    Finset.sum_mul]
  rw [he]
  ring

/-- The potential gradient is the spring part of the force imbalance. -/
theorem gradient_potential {b : Matrix ι ι ℝ} (hsym : ∀ i j, b i j = b j i) (η : ℝ) :
    ∇ (potential b η) = residual (fun _ ↦ 0) b η 0 :=
  funext fun u ↦ (hasGradientAt_potential hsym η u).gradient


/-- The diagonal normalized inertial operator. -/
def massOperator (a : ι → ℝ) : State ι →L[ℝ] State ι :=
  (BlockContraction.toMax (B := fun _ : ι ↦ ℝ)).symm.toContinuousLinearMap.comp
    (ContinuousLinearMap.pi fun i ↦ a i • (BlockSum.projection i : State ι →L[ℝ] ℝ))

omit [Fintype ι] in
@[simp] theorem massOperator_apply (a : ι → ℝ) (u : State ι) (i : ι) :
    massOperator a u i = a i * u i := by
  simp [massOperator, BlockContraction.toMax]

/-- A real diagonal mass operator is self-adjoint, independently of its curvature. -/
theorem massOperator_selfAdjoint (a : ι → ℝ) : IsSelfAdjoint (massOperator a) := by
  apply ContinuousLinearMap.isSelfAdjoint_iff_isSymmetric.mpr
  intro u v
  simp only [PiLp.inner_apply, Real.inner_apply]
  apply Finset.sum_congr rfl
  intro i _
  change (massOperator a u i) * v i = u i * (massOperator a v i)
  rw [massOperator_apply, massOperator_apply]
  ring

/-- The normalized mechanical energy as a Phase-1 implicit-Euler problem.
The timestep and energy units are normalized; physical mass/timestep scaling is explicit
in the system-to-certificate specialization. -/
def normalizedStep (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y : State ι)
    (hsym : ∀ i j, b i j = b j i) : ImplicitEulerStep (State ι) where
  M := massOperator a
  mass_self_adjoint := massOperator_selfAdjoint a
  E := potential b η
  E_differentiable := fun u ↦ (hasFDerivAt_potential b η u).differentiableAt
  gradient_differentiable := by
    rw [gradient_potential hsym]
    exact fun u ↦ (hasFDerivAt_residual (fun _ ↦ 0) b η 0 u).differentiableAt
  h := 1
  h_pos := by norm_num
  y := y

/-- The polynomial imbalance is exactly the IE energy gradient. -/
theorem normalizedStep_energyGradient (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y : State ι) (hsym : ∀ i j, b i j = b j i) :
    (normalizedStep a b η y hsym).energyGradient = residual a b η y := by
  funext u
  apply PiLp.ext
  intro i
  simp [normalizedStep, ImplicitEulerStep.energyGradient, ImplicitEulerStep.inertiaGradient,
    gradient_potential hsym, residual]
  ring

/-- The prepared polynomial Jacobian is the actual energy Hessian. -/
theorem normalizedStep_hessian (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y u : State ι) (hsym : ∀ i j, b i j = b j i) :
    ImplicitEulerStep.hessian (normalizedStep a b η y hsym).energy u = jacobian a b η u := by
  rw [ImplicitEulerStep.hessian, ImplicitEulerStep.gradient_energy, normalizedStep_energyGradient]
  exact (hasFDerivAt_residual a b η y u).fderiv

variable [DecidableEq ι]

/-- The polynomial production map uses exactly the IE gradient and diagonal Hessian blocks. -/
theorem newtonData_eq_blockNewtonData (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y : State ι) (hsym : ∀ i j, b i j = b j i) (hzero : ∀ i, b i i = 0)
    (threshold : ℝ≥0) :
    newtonData a b η y threshold = (normalizedStep a b η y hsym).blockNewtonData threshold := by
  unfold newtonData ImplicitEulerStep.blockNewtonData
  congr 1
  · exact (normalizedStep_energyGradient a b η y hsym).symm
  · funext i u
    rw [normalizedStep_hessian, entry_jacobian_diagonal a b η u hzero]

end Vbd.AxialSpring
