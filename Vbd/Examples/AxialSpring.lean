/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBDCoupling
import Mathlib.Analysis.Calculus.FDeriv.WithLp

/-!
# Scalar axial-spring Newton sweeps

The residual uses positive inertial coefficients `a`, nonnegative edge coefficients `b`, and
cubic hardening `η`. Zero diagonal edge coefficients make the supplied Newton blocks exact.
Symmetric coefficients describe the mechanical spring family; the derivative and coupling
estimates also hold for directed nonnegative coefficients.

The maximum-norm root estimate uses the accepted box radius `1/10`, hardening at most `1`,
and incident stiffness at most half the inertial coefficient. The physical chain's degree and
timestep bound discharge this last condition. Nonlinear neighborhood invariance and off-root
inverse variation are separate obligations.
-/

noncomputable section

open scoped NNReal

namespace Vbd.AxialSpring

variable {ι : Type*} [Fintype ι]

/-- Scalar displacements in the existing Hilbert block representation. -/
abbrev State (ι : Type*) := BlockSum (fun _ : ι ↦ ℝ)

/-- The spring contribution to a diagonal Hessian block. -/
def stiffness (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) (i j : ι) : ℝ :=
  b i j * (1 + 3 * η * (u i - u j) ^ 2)

/-- Inertia plus all incident spring stiffnesses. -/
def diagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) (i : ι) : ℝ :=
  a i + ∑ j, stiffness b η u i j

/-- The normalized implicit-Euler force imbalance of the axial spring law. -/
def residual (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y u : State ι) : State ι :=
  WithLp.toLp 2 fun i ↦ a i * (u i - y i) +
    ∑ j, b i j * ((u i - u j) + η * (u i - u j) ^ 3)

/-- A residual derivative row, before extracting its matrix entries. -/
def derivativeRow (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) (i : ι) :
    State ι →L[ℝ] ℝ :=
  a i • BlockSum.projection i +
    ∑ j, stiffness b η u i j • ((BlockSum.projection i : State ι →L[ℝ] ℝ) - BlockSum.projection j)

/-- The Jacobian assembled from the derivative rows. -/
def jacobian (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) :
    State ι →L[ℝ] State ι :=
  (BlockContraction.toMax (B := fun _ : ι ↦ ℝ)).symm.toContinuousLinearMap.comp
    (ContinuousLinearMap.pi (derivativeRow a b η u))

/-- The actual full-step Newton data, retaining the production determinant test. -/
def newtonData (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y : State ι)
    (threshold : ℝ≥0) : BlockNewtonData (fun _ : ι ↦ ℝ) where
  residual := residual a b η y
  diagonal := fun i u ↦ diagonal a b η u i • ContinuousLinearMap.id ℝ ℝ
  threshold := threshold

omit [Fintype ι] in
/-- Differentiation of one directed spring contribution. -/
private theorem hasFDerivAt_forceTerm [Finite ι] (b : Matrix ι ι ℝ) (η : ℝ)
    (u : State ι) (i j : ι) :
    HasFDerivAt (fun x : State ι ↦ b i j * ((x i - x j) + η * (x i - x j) ^ 3))
      (stiffness b η u i j •
        ((BlockSum.projection i : State ι →L[ℝ] ℝ) - BlockSum.projection j)) u := by
  let : Fintype ι := Fintype.ofFinite ι
  have hs : HasDerivAt (fun d : ℝ ↦ b i j * (d + η * d ^ 3))
      (stiffness b η u i j) (u i - u j) := by
    convert (((hasDerivAt_id (u i - u j)).add
      (((hasDerivAt_id (u i - u j)).pow 3).const_mul η)).const_mul (b i j)) using 1
    all_goals first | rfl | (dsimp [stiffness]; ring)
  exact hs.comp_hasFDerivAt (f := fun x : State ι ↦ x i - x j) u
    ((BlockSum.projection i : State ι →L[ℝ] ℝ).hasFDerivAt.sub
      (BlockSum.projection j).hasFDerivAt)

/-- The polynomial force imbalance has the stated Jacobian at every state. -/
theorem hasFDerivAt_residual (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y u : State ι) :
    HasFDerivAt (residual a b η y) (jacobian a b η u) u := by
  rw [← hasFDerivWithinAt_univ, hasFDerivWithinAt_piLp]
  intro i
  change HasFDerivWithinAt (fun x : State ι ↦ a i * (x i - y i) +
    ∑ j, b i j * ((x i - x j) + η * (x i - x j) ^ 3))
    (derivativeRow a b η u i) Set.univ u
  convert ((((BlockSum.projection i : State ι →L[ℝ] ℝ).hasFDerivAt.sub_const (y i)).const_mul
    (a i)).add (HasFDerivAt.sum (u := Finset.univ)
      (fun j _ ↦ hasFDerivAt_forceTerm b η u i j))).hasFDerivWithinAt
    using 1 <;> first | rfl | exact funext (fun x ↦ by simp [Finset.sum_apply])

@[simp] theorem jacobian_apply (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (u v : State ι) (i : ι) :
    jacobian a b η u v i = a i * v i + ∑ j, stiffness b η u i j * (v i - v j) := by
  simp [jacobian, derivativeRow, BlockContraction.toMax]

variable [DecidableEq ι]

/-- With no self-edge, the Newton block is exactly the diagonal Jacobian entry. -/
theorem entry_jacobian_diagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι)
    (hzero : ∀ i, b i i = 0) (i : ι) :
    BlockSum.entry (jacobian a b η u) i i =
      diagonal a b η u i • ContinuousLinearMap.id ℝ ℝ := by
  apply ContinuousLinearMap.ext
  intro v
  simp [diagonal, BlockSum.inject, mul_sub, Finset.sum_sub_distrib,
    stiffness, hzero]
  simp only [add_mul, Finset.sum_mul]

/-- An off-diagonal derivative is the negative spring stiffness. -/
theorem entry_jacobian_offDiagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι)
    {i j : ι} (hij : i ≠ j) :
    BlockSum.entry (jacobian a b η u) i j =
      -stiffness b η u i j • ContinuousLinearMap.id ℝ ℝ := by
  apply ContinuousLinearMap.ext
  intro v
  simp [BlockSum.inject, hij, mul_ite]

omit [Fintype ι] [DecidableEq ι] in
/-- Nonnegative spring coefficients and hardening give nonnegative stiffness contributions. -/
theorem stiffness_nonneg {b : Matrix ι ι ℝ} {η : ℝ} (hb : ∀ i j, 0 ≤ b i j)
    (hη : 0 ≤ η) (u : State ι) (i j : ι) : 0 ≤ stiffness b η u i j := by
  exact mul_nonneg (hb i j) (by positivity)

omit [Fintype ι] [DecidableEq ι] in
/-- On the accepted box, hardening increases each spring stiffness by at most `28/25`. -/
theorem stiffness_le_on_box {b : Matrix ι ι ℝ} {η : ℝ} {u : State ι}
    (hb : ∀ i j, 0 ≤ b i j) (hη1 : η ≤ 1)
    (hu : ∀ i, |u i| ≤ 1 / 10) (i j : ι) : stiffness b η u i j ≤ (28 / 25) * b i j := by
  have hd : |u i - u j| ≤ 1 / 5 := by
    calc
      |u i - u j| ≤ |u i| + |u j| := by simpa using abs_sub_le (u i) 0 (u j)
      _ ≤ 1 / 5 := by linarith [hu i, hu j]
  have hs : (u i - u j) ^ 2 ≤ (1 / 5 : ℝ) ^ 2 := by
    simpa only [sq_abs] using
      (sq_le_sq₀ (abs_nonneg (u i - u j)) (by norm_num : (0 : ℝ) ≤ 1 / 5)).mpr hd
  calc
    stiffness b η u i j ≤ b i j * (28 / 25) :=
      mul_le_mul_of_nonneg_left
        (by nlinarith [mul_le_mul_of_nonneg_right hη1 (sq_nonneg (u i - u j))]) (hb i j)
    _ = (28 / 25) * b i j := mul_comm _ _

omit [DecidableEq ι] in
/-- Incident stiffness at most half the inertia gives the uniform hardening row bound. -/
theorem stiffness_row_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {u : State ι}
    (hb : ∀ i j, 0 ≤ b i j) (hη1 : η ≤ 1)
    (hu : ∀ i, |u i| ≤ 1 / 10) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (i : ι) :
    ∑ j, stiffness b η u i j ≤ (14 / 25) * a i := by
  calc
    ∑ j, stiffness b η u i j ≤ ∑ j, (28 / 25) * b i j :=
      Finset.sum_le_sum fun j _ ↦ stiffness_le_on_box hb hη1 hu i j
    _ = (28 / 25) * ∑ j, b i j := (Finset.mul_sum ..).symm
    _ ≤ (28 / 25) * (a i / 2) := mul_le_mul_of_nonneg_left (hrow i) (by norm_num)
    _ = (14 / 25) * a i := by ring

/-- The accepted coefficients bound each normalized off-diagonal derivative row by `14/39`. -/
theorem normalized_row_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {u : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hu : ∀ i, |u i| ≤ 1 / 10)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (i : ι) :
    ∑ j ∈ Finset.univ.erase i,
      ‖(BlockSum.entry (jacobian a b η u) i i).inverse.comp
        (BlockSum.entry (jacobian a b η u) i j)‖ ≤ 14 / 39 := by
  have hD : 0 < diagonal a b η u i :=
    add_pos_of_pos_of_nonneg (lt_of_lt_of_le zero_lt_one (ha i))
      (Finset.sum_nonneg fun j _ ↦ stiffness_nonneg hb hη u i j)
  have hK : ∀ v, diagonal a b η u i * ‖v‖ ^ 2 ≤
      inner ℝ v (BlockSum.entry (jacobian a b η u) i i v) := by
    intro v
    simp only [entry_jacobian_diagonal a b η u hzero, smul_apply,
      ContinuousLinearMap.id_apply, real_inner_smul_right, real_inner_self_eq_norm_sq, le_refl]
  have hc : ∀ j ≠ i, ‖BlockSum.entry (jacobian a b η u) i j‖ ≤ stiffness b η u i j := by
    intro j hj
    simp [entry_jacobian_offDiagonal a b η u (Ne.symm hj), norm_smul,
      Real.norm_eq_abs, abs_of_nonneg (stiffness_nonneg hb hη u i j)]
  have hsum : ∑ j ∈ Finset.univ.erase i, stiffness b η u i j ≤ ∑ j, stiffness b η u i j := by
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.erase_subset i _)
      (fun j _ _ ↦ stiffness_nonneg hb hη u i j)
  refine (BlockCurvature.normalized_row_le _ i hD hK (stiffness b η u i) hc).trans
    ((mul_le_mul_of_nonneg_left hsum (inv_nonneg.mpr hD.le)).trans ?_)
  apply (inv_mul_le_iff₀ hD).mpr
  dsimp [diagonal]
  linarith [stiffness_row_le hb hη1 hu hrow i]

omit [DecidableEq ι] in
/-- Positive inertia keeps every visit on the regular production branch in this convex family. -/
theorem regular_newtonData {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η)
    (y u : State ι) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1) (i : ι) :
    (newtonData a b η y threshold).Regular i u := by
  have hD : a i ≤ diagonal a b η u i :=
    le_add_of_nonneg_right (Finset.sum_nonneg fun j _ ↦ stiffness_nonneg hb hη u i j)
  simpa [BlockNewtonData.Regular, newtonData, LinearMap.det_ring] using
    ht.trans_le ((ha i).trans (hD.trans (le_abs_self _)))

omit [DecidableEq ι] in
/-- The polynomial diagonal block map has the smoothness required by the production derivative. -/
theorem differentiable_newton_diagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (i : ι) :
    Differentiable ℝ (fun u : State ι ↦ diagonal a b η u i • ContinuousLinearMap.id ℝ ℝ) := by
  change Differentiable ℝ (fun u : State ι ↦
    (a i + ∑ j, b i j * (1 + 3 * η *
      ((BlockSum.projection i : State ι →L[ℝ] ℝ) u -
        (BlockSum.projection j : State ι →L[ℝ] ℝ) u) ^ 2)) •
        ContinuousLinearMap.id ℝ ℝ)
  fun_prop

/-- Exact production serial execution has the spring Gauss–Seidel root derivative. -/
theorem hasFDerivAt_serial_root {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0) (hη : 0 ≤ η)
    (y : State ι) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (order : List ι) {p : State ι} (hroot : residual a b η y p = 0) :
    HasFDerivAt ((newtonData a b η y threshold).serial order)
      (GaussSeidel.sweep (jacobian a b η p) order) p := by
  refine (newtonData a b η y threshold).hasFDerivAt_serial_gaussSeidel order
    (hasFDerivAt_residual a b η y p) hroot
    (fun i _ ↦ regular_newtonData ha hb hη y p threshold ht i)
    (fun i _ ↦ differentiable_newton_diagonal a b η i p) ?_
  exact fun i _ ↦ (entry_jacobian_diagonal a b η p hzero i).symm

/-- On the accepted range, a covered sweep's root derivative has maximum-norm bound `14/39 < 1`.
This differentiates the actual production map. It does not assert an off-root Lipschitz bound. -/
theorem serial_root_bound {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2)
    (y : State ι) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (order : List ι) (hcover : ∀ i, i ∈ order) {p : State ι}
    (hp : ∀ i, |p i| ≤ 1 / 10) (hroot : residual a b η y p = 0) :
    ∃ D : (ι → ℝ) →L[ℝ] (ι → ℝ),
      HasFDerivAt (BlockContraction.maxMap ((newtonData a b η y threshold).serial order)) D
        (BlockContraction.toMax p) ∧ ‖D‖ ≤ 14 / 39 := by
  let e := BlockContraction.toMax (B := fun _ : ι ↦ ℝ)
  refine ⟨e.toContinuousLinearMap.comp
    ((GaussSeidel.sweep (jacobian a b η p) order).comp e.symm.toContinuousLinearMap), ?_, ?_⟩
  · have hd := hasFDerivAt_serial_root ha hb hzero hη y threshold ht order hroot
    exact e.hasFDerivAt.comp (e p) (hd.comp (e p) e.symm.hasFDerivAt)
  · apply GaussSeidel.max_sweep_opNorm_le _ order (by norm_num) (by norm_num) hcover
    · intro i _
      rw [entry_jacobian_diagonal a b η p hzero]
      convert (newtonData a b η y threshold).isInvertible_of_regular
        (regular_newtonData ha hb hη y p threshold ht i) using 1 <;> rfl
    · exact fun i _ ↦ normalized_row_le ha hb hzero hη hη1 hp hrow i

omit [DecidableEq ι] in
/-- Degree at most two and `α ≤ 1/4` discharge the incident-stiffness condition of the root bound.
Here `aᵢ = mᵢ/m_min` and `bᵢⱼ = h² kᵢⱼ/m_min`; hence `α = h² k_max/m_min`. -/
theorem incident_bound_of_degree_two {a : ι → ℝ} {b : Matrix ι ι ℝ} {α : ℝ}
    (ha : ∀ i, 1 ≤ a i) (N : ι → Finset ι) (hdegree : ∀ i, (N i).card ≤ 2)
    (hsupport : ∀ i j, j ∉ N i → b i j = 0)
    (hb : ∀ i j, j ∈ N i → b i j ≤ α) (hα : 0 ≤ α) (hα1 : α ≤ 1 / 4) :
    ∀ i, ∑ j, b i j ≤ a i / 2 := by
  intro i
  rw [← Finset.sum_subset (Finset.subset_univ (N i))
    (fun j _ hj ↦ hsupport i j hj)]
  have hc : ((N i).card : ℝ) ≤ 2 := by exact_mod_cast hdegree i
  calc
    ∑ j ∈ N i, b i j ≤ (N i).card * α := by
      simpa only [nsmul_eq_mul] using Finset.sum_le_card_nsmul (N i) (fun j ↦ b i j) α (hb i)
    _ ≤ 2 * α := mul_le_mul_of_nonneg_right hc hα
    _ ≤ a i / 2 := by linarith [ha i]

/-- The AP-03 degree-two timestep range certifies the derivative of the actual nonlinear sweep.
The stationary point is supplied in the accepted box; its existence and warm-start coverage
belong to the nonlinear-neighborhood and fixed-point stages. -/
theorem serial_root_bound_of_degree_two {a : ι → ℝ} {b : Matrix ι ι ℝ} {η α : ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (N : ι → Finset ι) (hdegree : ∀ i, (N i).card ≤ 2)
    (hsupport : ∀ i j, j ∉ N i → b i j = 0)
    (hupper : ∀ i j, j ∈ N i → b i j ≤ α) (hα : 0 ≤ α) (hα1 : α ≤ 1 / 4)
    (y : State ι) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (order : List ι) (hcover : ∀ i, i ∈ order) {p : State ι}
    (hp : ∀ i, |p i| ≤ 1 / 10) (hroot : residual a b η y p = 0) :
    ∃ D : (ι → ℝ) →L[ℝ] (ι → ℝ),
      HasFDerivAt (BlockContraction.maxMap ((newtonData a b η y threshold).serial order)) D
        (BlockContraction.toMax p) ∧ ‖D‖ ≤ 14 / 39 := by
  exact serial_root_bound ha hb hzero hη hη1
    (incident_bound_of_degree_two ha N hdegree hsupport hupper hα hα1)
    y threshold ht order hcover hp hroot

end Vbd.AxialSpring
