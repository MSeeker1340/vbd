/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpring
import Vbd.Integrator.VBDNonlinear

/-!
# The axial-spring nonlinear neighborhood

The admitted state box has radius `1/10` in the maximum norm, and the predictor bound is `1/20`.
Uniform comparison rows retain the incident spring contribution to the diagonal denominator.
They include the force-dependent inverse-variation term and give a factor `318/625 < 0.512`.
Every production visit preserves the box, so ordered composition evaluates each derivative
inside the certified region.
-/

noncomputable section

open scoped NNReal

namespace Vbd.AxialSpring

variable {ι : Type*} [Fintype ι]

/-- Derivative of a local scalar stiffness, before multiplying by the scalar block identity. -/
def diagonalRowDerivative (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) (i : ι) :
    State ι →L[ℝ] ℝ :=
  ∑ j, (6 * η * b i j * (u i - u j)) •
    ((BlockSum.projection i : State ι →L[ℝ] ℝ) - BlockSum.projection j)

/-- Derivative of the actual continuous-linear Newton block. -/
def diagonalBlockDerivative (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) (i : ι) :
    State ι →L[ℝ] ℝ →L[ℝ] ℝ :=
  (diagonalRowDerivative b η u i).smulRight (ContinuousLinearMap.id ℝ ℝ)

omit [Fintype ι] in
/-- The derivative of one spring's contribution to the local stiffness. -/
private theorem hasFDerivAt_stiffness [Finite ι] (b : Matrix ι ι ℝ) (η : ℝ)
    (u : State ι) (i j : ι) :
    HasFDerivAt (fun x : State ι ↦ stiffness b η x i j)
      ((6 * η * b i j * (u i - u j)) •
        ((BlockSum.projection i : State ι →L[ℝ] ℝ) - BlockSum.projection j)) u := by
  let : Fintype ι := Fintype.ofFinite ι
  have hs : HasDerivAt (fun d : ℝ ↦ b i j * (1 + 3 * η * d ^ 2))
      (6 * η * b i j * (u i - u j)) (u i - u j) := by
    convert (((hasDerivAt_const (u i - u j) 1).add
      (((hasDerivAt_id (u i - u j)).pow 2).const_mul (3 * η))).const_mul (b i j)) using 1
    all_goals first | rfl | (dsimp; ring)
  exact hs.comp_hasFDerivAt (f := fun x : State ι ↦ x i - x j) u
    ((BlockSum.projection i : State ι →L[ℝ] ℝ).hasFDerivAt.sub
      (BlockSum.projection j).hasFDerivAt)

/-- The local scalar stiffness has the explicit variation derivative. -/
theorem hasFDerivAt_diagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (u : State ι) (i : ι) :
    HasFDerivAt (fun x : State ι ↦ diagonal a b η x i) (diagonalRowDerivative b η u i) u := by
  convert (HasFDerivAt.sum (u := Finset.univ)
    (fun j _ ↦ hasFDerivAt_stiffness b η u i j)).const_add (a i) using 1
  all_goals first | rfl | exact funext (fun x ↦ by simp [diagonal, Finset.sum_apply])

/-- The actual block matrix derivative required by the generic nonlinear update theorem. -/
theorem hasFDerivAt_newton_diagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y u : State ι) (threshold : ℝ≥0) (i : ι) :
    HasFDerivAt ((newtonData a b η y threshold).diagonal i)
      (diagonalBlockDerivative b η u i) u := by
  exact (hasFDerivAt_diagonal a b η u i).smul_const (ContinuousLinearMap.id ℝ ℝ)

/-- Total incident spring coefficient, before the state-dependent hardening factor. -/
def incident (b : Matrix ι ι ℝ) (i : ι) : ℝ := ∑ j, b i j

/-- The uniform lower bound on local stiffness, including the incident spring contribution. -/
def lowerDiagonal (a : ι → ℝ) (b : Matrix ι ι ℝ) (i : ι) : ℝ := a i + incident b i

/-- Uniform force bound for state radius `1/10` and predictor radius `1/20`. -/
def forceBound (a : ι → ℝ) (b : Matrix ι ι ℝ) (i : ι) : ℝ :=
  (3 / 20) * a i + (26 / 125) * incident b i

variable [DecidableEq ι]

/-- The diagonal stiffness variation receives all incident edges; other columns receive one. -/
def variationWeight (b : Matrix ι ι ℝ) (i j : ι) : ℝ :=
  if j = i then incident b i else b i j

/-- A uniform bound on the changed nonlinear Newton row throughout the admitted box. -/
def nonlinearCoupling (a : ι → ℝ) (b : Matrix ι ι ℝ) (i j : ι) : ℝ :=
  (if j = i then 0 else (28 / 25) * b i j / lowerDiagonal a b i) +
    forceBound a b i / lowerDiagonal a b i ^ 2 * ((6 / 5) * variationWeight b i j)

omit [DecidableEq ι] in
/-- Positive inertia gives a strictly positive uniform diagonal denominator. -/
theorem lowerDiagonal_pos {a : ι → ℝ} {b : Matrix ι ι ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (i : ι) :
    0 < lowerDiagonal a b i :=
  add_pos_of_pos_of_nonneg (lt_of_lt_of_le zero_lt_one (ha i))
    (Finset.sum_nonneg fun j _ ↦ hb i j)

omit [DecidableEq ι] in
/-- The diagonal retains the full nonnegative linear spring stiffness. -/
theorem lowerDiagonal_le_diagonal {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (u : State ι) (i : ι) :
    lowerDiagonal a b i ≤ diagonal a b η u i := by
  change a i + ∑ j, b i j ≤ a i + ∑ j, stiffness b η u i j
  apply add_le_add le_rfl (Finset.sum_le_sum fun j _ ↦ ?_)
  dsimp [stiffness]
  nlinarith [mul_nonneg (hb i j) (mul_nonneg hη (sq_nonneg (u i - u j)))]

omit [DecidableEq ι] in
/-- The actual inverse is bounded by the retained diagonal denominator. -/
theorem norm_inverse_diagonal_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η)
    (y u : State ι) (threshold : ℝ≥0) (i : ι) :
    ‖((newtonData a b η y threshold).diagonal i u).inverse‖ ≤
      (lowerDiagonal a b i)⁻¹ := by
  apply BlockCurvature.norm_inverse_le (lowerDiagonal_pos ha hb i)
  intro v
  simpa only [newtonData, smul_apply, ContinuousLinearMap.id_apply,
    real_inner_smul_right, real_inner_self_eq_norm_sq] using
    mul_le_mul_of_nonneg_right (lowerDiagonal_le_diagonal hb hη u i) (sq_nonneg ‖v‖)

omit [Fintype ι] [DecidableEq ι] in
/-- The box bounds every edge extension and its square. -/
private theorem extension_bounds {u : State ι} (hu : ∀ i, |u i| ≤ 1 / 10) (i j : ι) :
    |u i - u j| ≤ 1 / 5 ∧ (u i - u j) ^ 2 ≤ 1 / 25 := by
  have hd : |u i - u j| ≤ 1 / 5 := by
    calc
      _ ≤ |u i| + |u j| := by simpa using abs_sub_le (u i) 0 (u j)
      _ ≤ _ := by linarith [hu i, hu j]
  refine ⟨hd, ?_⟩
  have hs := (sq_le_sq₀ (abs_nonneg (u i - u j))
    (by norm_num : (0 : ℝ) ≤ 1 / 5)).mpr hd
  norm_num only [sq_abs] at hs
  exact hs

omit [Fintype ι] [DecidableEq ι] in
private theorem hardening_bounds {η : ℝ} {u : State ι} (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hu : ∀ i, |u i| ≤ 1 / 10) (i j : ι) :
    0 ≤ η * (u i - u j) ^ 2 ∧ η * (u i - u j) ^ 2 ≤ 1 / 25 :=
  ⟨mul_nonneg hη (sq_nonneg _),
    (mul_le_mul_of_nonneg_right hη1 (sq_nonneg _)).trans (by
      simpa using (extension_bounds hu i j).2)⟩

omit [DecidableEq ι] in
/-- State and predictor bounds control the actual force imbalance, including hardening. -/
theorem residual_le_forceBound {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y u : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hy : ∀ i, |y i| ≤ 1 / 20) (hu : ∀ i, |u i| ≤ 1 / 10) (i : ι) :
    |residual a b η y u i| ≤ forceBound a b i := by
  have ha0 : 0 ≤ a i := zero_le_one.trans (ha i)
  have hs : ∀ j, |(u i - u j) + η * (u i - u j) ^ 3| ≤ 26 / 125 := by
    intro j
    rw [show (u i - u j) + η * (u i - u j) ^ 3 =
      (u i - u j) * (1 + η * (u i - u j) ^ 2) by ring, abs_mul,
      abs_of_nonneg (by positivity : 0 ≤ 1 + η * (u i - u j) ^ 2)]
    have he := (extension_bounds hu i j).1
    have hh := hardening_bounds hη hη1 hu i j
    nlinarith [mul_le_mul he (show 1 + η * (u i - u j) ^ 2 ≤ 26 / 25 by linarith)
      (show 0 ≤ 1 + η * (u i - u j) ^ 2 by positivity) (by norm_num : (0 : ℝ) ≤ 1 / 5)]
  change |a i * (u i - y i) + ∑ j, b i j * ((u i - u j) + η * (u i - u j) ^ 3)| ≤ _
  calc
    _ ≤ |a i * (u i - y i)| + ∑ j, |b i j * ((u i - u j) + η * (u i - u j) ^ 3)| :=
      (abs_add_le _ _).trans (add_le_add le_rfl (Finset.abs_sum_le_sum_abs _ _))
    _ ≤ a i * (3 / 20) + ∑ j, b i j * (26 / 125) := by
      apply add_le_add
      · rw [abs_mul, abs_of_nonneg ha0]
        apply mul_le_mul_of_nonneg_left _ ha0
        calc
          _ ≤ |u i| + |y i| := by simpa using abs_sub_le (u i) 0 (y i)
          _ ≤ _ := by linarith [hu i, hy i]
      · apply Finset.sum_le_sum
        intro j _
        rw [abs_mul, abs_of_nonneg (hb i j)]
        exact mul_le_mul_of_nonneg_left (hs j) (hb i j)
    _ = _ := by simp only [forceBound, incident, ← Finset.sum_mul]; ring

private theorem diagonalBlockDerivative_comp_inclusion (b : Matrix ι ι ℝ) (η : ℝ)
    (u : State ι) (i j : ι) :
    (diagonalBlockDerivative b η u i).comp (BlockSum.inclusion j) =
      ((if j = i then ∑ k, 6 * η * b i k * (u i - u k)
        else -(6 * η * b i j * (u i - u j))) • ContinuousLinearMap.id ℝ ℝ).smulRight
          (ContinuousLinearMap.id ℝ ℝ) := by
  apply ContinuousLinearMap.ext
  intro v
  apply ContinuousLinearMap.ext
  intro w
  by_cases hj : j = i
  · subst j
    simp [diagonalBlockDerivative, diagonalRowDerivative, BlockSum.inject,
      mul_sub, Finset.sum_sub_distrib, Finset.sum_mul]
    simp [← Finset.sum_mul, Finset.sum_sub_distrib]
  · simp [diagonalBlockDerivative, diagonalRowDerivative, BlockSum.inject, hj, Ne.symm hj,
      mul_sub]
    ring

/-- The actual block derivative has a uniform per-column variation bound. -/
theorem norm_diagonalBlockDerivative_le {b : Matrix ι ι ℝ} {η : ℝ} {u : State ι}
    (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hu : ∀ i, |u i| ≤ 1 / 10) (i j : ι) :
    ‖(diagonalBlockDerivative b η u i).comp (BlockSum.inclusion j)‖ ≤
      (6 / 5) * variationWeight b i j := by
  have hc : ∀ k, |6 * η * b i k * (u i - u k)| ≤ (6 / 5) * b i k := by
    intro k
    have hb0 := hb i k
    rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ 6 * η * b i k)]
    calc
      _ ≤ (6 * η * b i k) * (1 / 5) :=
        mul_le_mul_of_nonneg_left (extension_bounds hu i k).1 (by positivity)
      _ ≤ (6 / 5) * b i k := by nlinarith [mul_le_mul_of_nonneg_right hη1 (hb i k)]
  rw [diagonalBlockDerivative_comp_inclusion, ContinuousLinearMap.norm_smulRight_apply,
    ContinuousLinearMap.norm_id, mul_one, norm_smul,
    ContinuousLinearMap.norm_id, mul_one, Real.norm_eq_abs]
  by_cases hj : j = i
  · subst j
    simp only [variationWeight, ite_true]
    calc
      _ ≤ ∑ k, |6 * η * b i k * (u i - u k)| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ k, (6 / 5) * b i k := Finset.sum_le_sum fun k _ ↦ hc k
      _ = _ := (Finset.mul_sum ..).symm
  · simpa [hj, variationWeight] using hc j

/-- The static nonlinear comparison has row sum at most `318/625`, uniformly over AP-03. -/
theorem nonlinearCoupling_row_le {a : ι → ℝ} {b : Matrix ι ι ℝ}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (i : ι) :
    ∑ j, nonlinearCoupling a b i j ≤ 318 / 625 := by
  have hW : ∑ j, variationWeight b i j = 2 * incident b i := by
    simp [variationWeight, Finset.sum_ite, Finset.filter_ne',
      Finset.sum_erase_eq_sub, hzero, incident, two_mul, Finset.filter_eq']
  have hsum : ∑ j, nonlinearCoupling a b i j =
      (28 / 25) * incident b i / lowerDiagonal a b i +
        forceBound a b i / lowerDiagonal a b i ^ 2 * ((12 / 5) * incident b i) := by
    have he : ∀ j, (if j = i then 0 else (28 / 25) * b i j / lowerDiagonal a b i) =
        (28 / 25) * b i j / lowerDiagonal a b i := by
      intro j
      split_ifs with h
      · subst j; simp [hzero]
      · rfl
    simp only [nonlinearCoupling, he, Finset.sum_add_distrib, ← Finset.sum_div,
      ← Finset.mul_sum, hW]
    dsimp [incident]
    ring
  have ha0 : 0 < a i := lt_of_lt_of_le zero_lt_one (ha i)
  have hs0 : 0 ≤ incident b i := Finset.sum_nonneg fun j _ ↦ hb i j
  have hs : incident b i ≤ a i / 2 := hrow i
  have hA : 0 < lowerDiagonal a b i := add_pos_of_pos_of_nonneg ha0 hs0
  have hbase : (28 / 25) * incident b i / lowerDiagonal a b i ≤ 28 / 75 := by
    apply (div_le_iff₀ hA).mpr
    dsimp [lowerDiagonal]
    linarith
  have hF : forceBound a b i ≤ (127 / 500) * a i := by
    dsimp [forceBound]
    linarith
  have hratio : a i * incident b i / lowerDiagonal a b i ^ 2 ≤ 2 / 9 := by
    apply (div_le_iff₀ (sq_pos_of_pos hA)).mpr
    dsimp [lowerDiagonal]
    nlinarith [mul_nonneg (show 0 ≤ a i - 2 * incident b i by linarith)
      (show 0 ≤ 2 * a i - incident b i by linarith)]
  rw [hsum]
  calc
    _ ≤ 28 / 75 + ((127 / 500) * a i / lowerDiagonal a b i ^ 2) *
        ((12 / 5) * incident b i) :=
      add_le_add hbase (mul_le_mul_of_nonneg_right
        (div_le_div_of_nonneg_right hF (sq_nonneg _)) (by positivity))
    _ = 28 / 75 + ((127 / 500) * (12 / 5)) *
        (a i * incident b i / lowerDiagonal a b i ^ 2) := by ring
    _ ≤ 28 / 75 + ((127 / 500) * (12 / 5)) * (2 / 9) := by gcongr
    _ = 318 / 625 := by norm_num

omit [DecidableEq ι] in
/-- The admitted maximum-norm neighborhood is centered at the zero displacement. -/
def stateBox : Set (ι → ℝ) := Metric.closedBall 0 (1 / 10)

omit [DecidableEq ι] in
/-- Coordinate bounds are precisely membership in the admitted maximum-norm box. -/
theorem mem_stateBox_iff (u : State ι) :
    BlockContraction.toMax u ∈ stateBox ↔ ∀ i, |u i| ≤ 1 / 10 := by
  simp [stateBox, Metric.mem_closedBall, dist_zero_right, pi_norm_le_iff_of_nonneg,
    BlockContraction.toMax, Real.norm_eq_abs]

omit [DecidableEq ι] in
/-- The numerator of the scalar block Newton replacement. -/
def updateNumerator (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y u : State ι) (i : ι) : ℝ :=
  a i * y i + ∑ j, b i j * (u j + η * (u i - u j) ^ 2 * (2 * u i + u j))

omit [DecidableEq ι] in
private theorem updateNumerator_eq (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ)
    (y u : State ι) (i : ι) :
    diagonal a b η u i * u i - residual a b η y u i = updateNumerator a b η y u i := by
  change (a i + ∑ j, stiffness b η u i j) * u i -
    (a i * (u i - y i) + ∑ j, b i j * ((u i - u j) + η * (u i - u j) ^ 3)) = _
  simp only [add_mul, Finset.sum_mul, updateNumerator]
  rw [show a i * u i + ∑ j, stiffness b η u i j * u i -
      (a i * (u i - y i) + ∑ j, b i j * ((u i - u j) + η * (u i - u j) ^ 3)) =
      a i * y i + ((∑ j, stiffness b η u i j * u i) -
        ∑ j, b i j * ((u i - u j) + η * (u i - u j) ^ 3)) by ring,
    ← Finset.sum_sub_distrib]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  dsimp [stiffness]
  ring

omit [DecidableEq ι] in
private theorem updateNumerator_bound {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y u : State ι} (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2)
    (hy : ∀ i, |y i| ≤ 1 / 20) (hu : ∀ i, |u i| ≤ 1 / 10) (i : ι) :
    |updateNumerator a b η y u i| ≤ (1 / 10) * diagonal a b η u i := by
  have ha0 : 0 ≤ a i := zero_le_one.trans (ha i)
  have hn : ∀ j, |u j + η * (u i - u j) ^ 2 * (2 * u i + u j)| ≤ 14 / 125 := by
    intro j
    have hh := hardening_bounds hη hη1 hu i j
    have hl : |2 * u i + u j| ≤ 3 / 10 := by
      calc
        _ ≤ |2 * u i| + |u j| := abs_add_le _ _
        _ ≤ _ := by rw [abs_mul]; norm_num; linarith [hu i, hu j]
    calc
      _ ≤ |u j| + |η * (u i - u j) ^ 2 * (2 * u i + u j)| := abs_add_le _ _
      _ = |u j| + (η * (u i - u j) ^ 2) * |2 * u i + u j| := by
        rw [abs_mul, abs_of_nonneg hh.1]
      _ ≤ 1 / 10 + (1 / 25) * (3 / 10) :=
        add_le_add (hu j) (mul_le_mul hh.2 hl (abs_nonneg _) (by norm_num))
      _ = _ := by norm_num
  calc
    |updateNumerator a b η y u i| ≤ |a i * y i| +
        ∑ j, |b i j * (u j + η * (u i - u j) ^ 2 * (2 * u i + u j))| :=
      (abs_add_le _ _).trans (add_le_add le_rfl (Finset.abs_sum_le_sum_abs _ _))
    _ ≤ a i * (1 / 20) + ∑ j, b i j * (14 / 125) := by
      apply add_le_add
      · rw [abs_mul, abs_of_nonneg ha0]
        exact mul_le_mul_of_nonneg_left (hy i) ha0
      · apply Finset.sum_le_sum
        intro j _
        rw [abs_mul, abs_of_nonneg (hb i j)]
        exact mul_le_mul_of_nonneg_left (hn j) (hb i j)
    _ ≤ (1 / 10) * lowerDiagonal a b i := by
      rw [← Finset.sum_mul]
      dsimp [lowerDiagonal, incident]
      linarith [hrow i]
    _ ≤ (1 / 10) * diagonal a b η u i :=
      mul_le_mul_of_nonneg_left (lowerDiagonal_le_diagonal hb hη u i) (by norm_num)

/-- A production visit preserves the admitted box for every predictor in the selected box. -/
theorem update_preserves_box {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y u : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hy : ∀ i, |y i| ≤ 1 / 20)
    (hu : ∀ i, |u i| ≤ 1 / 10) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1) (i : ι) :
    ∀ j, |(newtonData a b η y threshold).update i u j| ≤ 1 / 10 := by
  intro j
  by_cases hj : j = i
  · subst j
    have hreg := regular_newtonData ha hb hη y u threshold ht i
    have hsolve := (newtonData a b η y threshold).diagonal_inverse_residual hreg
    have he : diagonal a b η u i * (newtonData a b η y threshold).update i u i =
        updateNumerator a b η y u i := by
      rw [(newtonData a b η y threshold).update_of_regular hreg,
        BlockSum.replace_apply_same, mul_sub]
      rw [show diagonal a b η u i *
          ((newtonData a b η y threshold).diagonal i u).inverse
            ((newtonData a b η y threshold).residual u i) = residual a b η y u i from hsolve]
      exact updateNumerator_eq a b η y u i
    have hD : 0 < diagonal a b η u i :=
      add_pos_of_pos_of_nonneg (lt_of_lt_of_le zero_lt_one (ha i))
        (Finset.sum_nonneg fun k _ ↦ stiffness_nonneg hb hη u i k)
    have hn := updateNumerator_bound ha hb hη hη1 hrow hy hu i
    rw [← he, abs_mul, abs_of_pos hD] at hn
    nlinarith
  · simpa only [BlockNewtonData.update_apply_of_ne _ _ _ hj] using hu j

/-- The actual off-root derivative is dominated by the fixed nonlinear comparison matrix. -/
theorem norm_entry_updateDerivative_le {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ}
    {y u : State ι} (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j)
    (hzero : ∀ i, b i i = 0) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hy : ∀ i, |y i| ≤ 1 / 20) (hu : ∀ i, |u i| ≤ 1 / 10)
    (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1) (i j : ι) :
    ‖BlockSum.entry ((newtonData a b η y threshold).updateDerivative
      (jacobian a b η u) u i (diagonalBlockDerivative b η u i)) i j‖ ≤
      nonlinearCoupling a b i j := by
  let d := newtonData a b η y threshold
  have hA := lowerDiagonal_pos ha hb i
  have hF : 0 ≤ forceBound a b i := by
    have ha0 := zero_le_one.trans (ha i)
    have hs0 : 0 ≤ incident b i := Finset.sum_nonneg fun j _ ↦ hb i j
    dsimp [forceBound]
    positivity
  have hI := norm_inverse_diagonal_le ha hb hη y u threshold i
  have hsolve : ‖(d.diagonal i u).inverse (d.residual u i)‖ ≤
      forceBound a b i / lowerDiagonal a b i := by
    calc
      _ ≤ ‖(d.diagonal i u).inverse‖ * ‖d.residual u i‖ :=
        ContinuousLinearMap.le_opNorm _ _
      _ ≤ (lowerDiagonal a b i)⁻¹ * forceBound a b i :=
        mul_le_mul hI (by simpa [d, newtonData, Real.norm_eq_abs] using
          residual_le_forceBound ha hb hη hη1 hy hu i) (norm_nonneg _) (inv_nonneg.mpr hA.le)
      _ = _ := by ring
  have hbase : (if j = i then 0 else
      ‖(d.diagonal i u).inverse.comp (BlockSum.entry (jacobian a b η u) i j)‖) ≤
      (if j = i then 0 else (28 / 25) * b i j / lowerDiagonal a b i) := by
    split_ifs with hj
    · rfl
    · calc
        _ ≤ ‖(d.diagonal i u).inverse‖ *
            ‖BlockSum.entry (jacobian a b η u) i j‖ := ContinuousLinearMap.opNorm_comp_le _ _
        _ ≤ (lowerDiagonal a b i)⁻¹ * ((28 / 25) * b i j) := by
          apply mul_le_mul hI _ (norm_nonneg _) (inv_nonneg.mpr hA.le)
          calc
            _ ≤ stiffness b η u i j := by
              simp [entry_jacobian_offDiagonal a b η u (Ne.symm hj), norm_smul,
                Real.norm_eq_abs, abs_of_nonneg (stiffness_nonneg hb hη u i j)]
            _ ≤ _ := stiffness_le_on_box hb hη1 hu i j
        _ = _ := by ring
  refine (d.norm_entry_updateDerivative_le (jacobian a b η u) u i j
    (diagonalBlockDerivative b η u i) (regular_newtonData ha hb hη y u threshold ht i)
    (entry_jacobian_diagonal a b η u hzero i).symm).trans ?_
  have hprod := mul_le_mul (mul_le_mul hI hsolve (norm_nonneg _)
      (inv_nonneg.mpr hA.le))
    (norm_diagonalBlockDerivative_le hb hη hη1 hu i j) (norm_nonneg _)
    (mul_nonneg (inv_nonneg.mpr hA.le) (div_nonneg hF hA.le))
  dsimp [nonlinearCoupling]
  convert add_le_add hbase hprod using 1 <;> first | rfl | ring

/-- Every covered production serial order contracts uniformly throughout the admitted box. -/
theorem lipschitzOnWith_serial {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2)
    (hy : ∀ i, |y i| ≤ 1 / 20) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (order : List ι) (hcover : ∀ i, i ∈ order) :
    LipschitzOnWith (318 / 625 : ℝ≥0)
      (BlockContraction.maxMap ((newtonData a b η y threshold).serial order)) stateBox := by
  apply (newtonData a b η y threshold).lipschitzOnWith_serial_of_row_bounds
    (jacobian a b η) (fun i u ↦ diagonalBlockDerivative b η u i) (nonlinearCoupling a b)
    order (by norm_num) (convex_closedBall 0 _) hcover
  · intro i _ u hu
    exact (mem_stateBox_iff _).mpr
      (update_preserves_box ha hb hη hη1 hrow hy ((mem_stateBox_iff u).mp hu) threshold ht i)
  · exact fun u _ ↦ hasFDerivAt_residual a b η y u
  · exact fun i _ u _ ↦ regular_newtonData ha hb hη y u threshold ht i
  · exact fun i _ u _ ↦ hasFDerivAt_newton_diagonal a b η y u threshold i
  · intro i j
    have ha0 := zero_le_one.trans (ha i)
    have hb0 := hb i j
    have hs0 : 0 ≤ incident b i := Finset.sum_nonneg fun j _ ↦ hb i j
    dsimp [nonlinearCoupling, forceBound, lowerDiagonal, variationWeight]
    split_ifs <;> positivity
  · exact fun i ↦ nonlinearCoupling_row_le ha hb hzero hrow i
  · exact fun i _ u hu j ↦ norm_entry_updateDerivative_le ha hb hzero hη hη1 hy
      ((mem_stateBox_iff u).mp hu) threshold ht i j

/-- Every intermediate visit and the resulting serial sweep remain in the admitted box. -/
theorem serial_preserves_box {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hy : ∀ i, |y i| ≤ 1 / 20)
    (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1) (order : List ι) :
    Set.MapsTo (BlockContraction.maxMap ((newtonData a b η y threshold).serial order))
      stateBox stateBox := by
  have hs : ∀ order : List ι, ∀ u : State ι, (∀ i, |u i| ≤ 1 / 10) →
      ∀ i, |(newtonData a b η y threshold).serial order u i| ≤ 1 / 10 := by
    intro order
    induction order with
    | nil => exact fun u hu ↦ hu
    | cons i order ih =>
      intro u hu
      rw [BlockNewtonData.serial_cons]
      exact ih _ (update_preserves_box ha hb hη hη1 hrow hy hu threshold ht i)
  intro x hx
  exact (mem_stateBox_iff _).mpr (hs order (BlockContraction.toMax.symm x)
    ((mem_stateBox_iff _).mp (by simpa using hx)))

/-- The accepted degree-two timestep range gives the uniform nonlinear sweep contraction. -/
theorem lipschitzOnWith_serial_of_degree_two {a : ι → ℝ} {b : Matrix ι ι ℝ} {η α : ℝ}
    {y : State ι} (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j)
    (hzero : ∀ i, b i i = 0) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (N : ι → Finset ι) (hdegree : ∀ i, (N i).card ≤ 2)
    (hsupport : ∀ i j, j ∉ N i → b i j = 0)
    (hcoeff : ∀ i j, j ∈ N i → b i j ≤ α) (hα : 0 ≤ α) (hα1 : α ≤ 1 / 4)
    (hy : ∀ i, |y i| ≤ 1 / 20) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (order : List ι) (hcover : ∀ i, i ∈ order) :
    LipschitzOnWith (318 / 625 : ℝ≥0)
      (BlockContraction.maxMap ((newtonData a b η y threshold).serial order)) stateBox :=
  lipschitzOnWith_serial ha hb hzero hη hη1
    (incident_bound_of_degree_two ha N hdegree hsupport hcoeff hα hα1)
    hy threshold ht order hcover

omit [DecidableEq ι] in
/-- Every admitted predictor is an initial state in the contraction neighborhood. -/
theorem predictor_mem_stateBox {y : State ι} (hy : ∀ i, |y i| ≤ 1 / 20) :
    BlockContraction.toMax y ∈ stateBox :=
  (mem_stateBox_iff y).mpr fun i ↦ (hy i).trans (by norm_num)

omit [DecidableEq ι] in
/-- A rest-state warm start belongs to the same nonlinear contraction neighborhood. -/
theorem zero_mem_stateBox : (0 : ι → ℝ) ∈ stateBox := by
  simp [stateBox]

/-- The deterministic nonuniform predictor selected by AP-03. -/
def cosinePredictor (n : ℕ) : State (Fin n) :=
  WithLp.toLp 2 fun i ↦ (1 / 20) * Real.cos ((17 / 10) * (i : ℝ))

/-- The selected predictor meets the parameter-independent predictor radius. -/
theorem cosinePredictor_bound (n : ℕ) (i : Fin n) : |cosinePredictor n i| ≤ 1 / 20 := by
  change |(1 / 20 : ℝ) * Real.cos ((17 / 10) * (i : ℝ))| ≤ 1 / 20
  rw [abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 1 / 20)]
  linarith [Real.abs_cos_le_one ((17 / 10) * (i : ℝ))]

/-- The selected inertia warm start lies in the uniform nonlinear contraction neighborhood. -/
theorem cosinePredictor_mem_stateBox (n : ℕ) :
    BlockContraction.toMax (cosinePredictor n) ∈ stateBox :=
  predictor_mem_stateBox (cosinePredictor_bound n)

end Vbd.AxialSpring
