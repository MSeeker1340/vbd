/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBD

/-!
# Inertia-based bounds for VBD block solves

Lower quadratic-form bounds on a mass block and a potential Hessian block give the explicit
coercivity constant `m / h² - κ`. Positive coercivity controls the actual totalized inverse used
by `BlockNewtonData.update`, in any finite block dimension. Symmetry is unnecessary for these
bounds. The assumptions can hold pointwise or uniformly on any supplied state region.

Invertibility alone does not imply acceptance by a positive determinant threshold. For scalar
blocks, coercivity above the threshold also certifies the production regular branch.
-/

noncomputable section

open scoped NNReal

namespace Vbd
namespace BlockCurvature

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  {K : E →L[ℝ] E} {μ : ℝ}

/-- Cauchy–Schwarz turns a quadratic-form lower bound into a lower image-norm bound. -/
theorem norm_image_lower_bound (hK : ∀ v, μ * ‖v‖ ^ 2 ≤ inner ℝ v (K v)) (v : E) :
    μ * ‖v‖ ≤ ‖K v‖ := by
  by_cases hv : v = 0
  · simp [hv]
  · apply (mul_le_mul_iff_right₀ (norm_pos_iff.mpr hv)).mp
    nlinarith [hK v, real_inner_le_norm v (K v)]

/-- A coercive finite-dimensional block solve is invertible. -/
theorem isInvertible [FiniteDimensional ℝ E] (hμ : 0 < μ)
    (hK : ∀ v, μ * ‖v‖ ^ 2 ≤ inner ℝ v (K v)) : K.IsInvertible := by
  have hinj : Function.Injective K := by
    apply LinearMap.ker_eq_bot.mp (LinearMap.ker_eq_bot'.mpr ?_)
    intro v hv
    have h := norm_image_lower_bound hK v
    change K v = 0 at hv
    rw [hv, norm_zero] at h
    exact norm_eq_zero.mp (le_antisymm (by nlinarith) (norm_nonneg v))
  exact ⟨(LinearEquiv.ofInjectiveEndo K.toLinearMap hinj).toContinuousLinearEquiv, rfl⟩

/-- Quantitative control of the exact inverse used by production VBD, including trivial blocks. -/
theorem norm_inverse_le [FiniteDimensional ℝ E] (hμ : 0 < μ)
    (hK : ∀ v, μ * ‖v‖ ^ 2 ≤ inner ℝ v (K v)) : ‖K.inverse‖ ≤ μ⁻¹ := by
  refine K.inverse.opNorm_le_bound (inv_nonneg.mpr hμ.le) ?_
  intro v
  apply (le_inv_mul_iff₀ hμ).mpr
  simpa only [(isInvertible hμ hK).self_apply_inverse] using
    norm_image_lower_bound hK (K.inverse v)

end BlockCurvature

namespace BlockNewtonData

variable {ι : Type*}

/-- In a scalar block the determinant is its value on `1`, so coercivity strictly above the
production threshold proves that the update will execute its Newton branch. -/
theorem regular_of_scalar_coercivity (d : BlockNewtonData (fun _ : ι ↦ ℝ))
    {i : ι} {x : BlockSum (fun _ : ι ↦ ℝ)} {μ : ℝ}
    (hthreshold : (d.threshold : ℝ) < μ)
    (hK : ∀ v, μ * ‖v‖ ^ 2 ≤ inner ℝ v (d.diagonal i x v)) : d.Regular i x := by
  have h := hK 1
  change (d.threshold : ℝ) < |(d.diagonal i x).toLinearMap.det|
  rw [LinearMap.det_ring]
  exact hthreshold.trans_le
    ((show μ ≤ d.diagonal i x 1 from by simpa using h).trans (le_abs_self _))

end BlockNewtonData

namespace ImplicitEulerStep

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, InnerProductSpace ℝ (B i)]
  [∀ i, CompleteSpace (B i)] [∀ i, FiniteDimensional ℝ (B i)]

/-- A mass lower bound dominates bounded negative potential curvature in the actual Newton block.
The constants are quadratic-form bounds on the diagonal entries, with no locality hypothesis. -/
theorem blockNewtonData_inner_lower_bound (ie : ImplicitEulerStep (BlockSum B))
    (threshold : ℝ≥0) (i : ι) (x : BlockSum B) (m κ : ℝ)
    (hM : ∀ v, m * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry ie.M i i v))
    (hP : ∀ v, -κ * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry (ie.potentialHessian x) i i v)) :
    ∀ v, (m / ie.h ^ 2 - κ) * ‖v‖ ^ 2 ≤
      inner ℝ v ((ie.blockNewtonData threshold).diagonal i x v) := by
  intro v
  rw [blockNewtonData_diagonal]
  simp only [add_apply, smul_apply, inner_add_right, inner_smul_right]
  have h := mul_le_mul_of_nonneg_left (hM v) (inv_nonneg.mpr (sq_nonneg ie.h))
  convert add_le_add h (hP v) using 1 <;> first | rfl | ring

/-- A uniform inertia-dominated curvature bound controls every local solve on a supplied region.
The region can be any neighborhood used by a subsequent contraction proof. Positive production
thresholds still require a determinant comparison; this conclusion concerns the inverse itself. -/
theorem blockNewtonData_inverse_bounds (ie : ImplicitEulerStep (BlockSum B))
    (threshold : ℝ≥0) {S : Set (BlockSum B)} (m κ : ι → ℝ)
    (hM : ∀ i v, m i * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry ie.M i i v))
    (hP : ∀ x ∈ S, ∀ i v, -κ i * ‖v‖ ^ 2 ≤
      inner ℝ v (BlockSum.entry (ie.potentialHessian x) i i v))
    (hμ : ∀ i, 0 < m i / ie.h ^ 2 - κ i) :
    ∀ x ∈ S, ∀ i, ((ie.blockNewtonData threshold).diagonal i x).IsInvertible ∧
      ‖((ie.blockNewtonData threshold).diagonal i x).inverse‖ ≤
        (m i / ie.h ^ 2 - κ i)⁻¹ := by
  intro x hx i
  have hK := ie.blockNewtonData_inner_lower_bound threshold i x (m i) (κ i) (hM i) (hP x hx i)
  exact ⟨BlockCurvature.isInvertible (hμ i) hK, BlockCurvature.norm_inverse_le (hμ i) hK⟩

end ImplicitEulerStep

namespace ImplicitEulerStep

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Uniform scalar curvature bounds certify skip-free execution throughout a supplied region.
In the normalized axial-chain family, `m / h² ≥ 1`, `κ = 0`, and the threshold is below `1`. -/
theorem blockNewtonData_regular_of_scalar_curvature
    (ie : ImplicitEulerStep (BlockSum (fun _ : ι ↦ ℝ))) (threshold : ℝ≥0)
    {S : Set (BlockSum (fun _ : ι ↦ ℝ))} (m κ : ι → ℝ)
    (hM : ∀ i v, m i * ‖v‖ ^ 2 ≤ inner ℝ v (BlockSum.entry ie.M i i v))
    (hP : ∀ x ∈ S, ∀ i v, -κ i * ‖v‖ ^ 2 ≤
      inner ℝ v (BlockSum.entry (ie.potentialHessian x) i i v))
    (hμ : ∀ i, (threshold : ℝ) < m i / ie.h ^ 2 - κ i) :
    ∀ x ∈ S, ∀ i, (ie.blockNewtonData threshold).Regular i x := by
  intro x hx i
  exact (ie.blockNewtonData threshold).regular_of_scalar_coercivity (hμ i)
    (ie.blockNewtonData_inner_lower_bound threshold i x (m i) (κ i) (hM i) (hP x hx i))

end ImplicitEulerStep
end Vbd
