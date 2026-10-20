/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringConvergence

/-!
# The physical finite-chain certificate

Positive mass, nearest-neighbor symmetric spring coefficients, hardening in `[0,1]`, and
`h² k_max / m_min ≤ 1/4` discharge the nonlinear serial and even/odd certificates. The initial
state is the selected cosine predictor and the normalized determinant threshold is `10⁻¹²`.
The physical IE gradient and its mass-scaled residual retain explicit length and timestep units.
-/

noncomputable section

open scoped Gradient NNReal

namespace Vbd.AxialSpring

/-- Physical assumptions of the accepted one-timestep finite-chain family. -/
structure ChainSystem (n : ℕ) where
  /-- Per-vertex masses. -/
  mass : Fin n → ℝ
  /-- Symmetric nearest-neighbor spring stiffnesses. -/
  spring : Matrix (Fin n) (Fin n) ℝ
  /-- A positive lower mass bound. -/
  minMass : ℝ
  minMass_pos : 0 < minMass
  mass_lower : ∀ i, minMass ≤ mass i
  /-- A nonnegative upper spring-stiffness bound. -/
  maxSpring : ℝ
  maxSpring_nonneg : 0 ≤ maxSpring
  spring_nonneg : ∀ i j, 0 ≤ spring i j
  spring_upper : ∀ i j, spring i j ≤ maxSpring
  spring_symm : ∀ i j, spring i j = spring j i
  spring_support : ∀ i j, i.val + 1 ≠ j.val → j.val + 1 ≠ i.val → spring i j = 0
  /-- Physical timestep. -/
  h : ℝ
  h_pos : 0 < h
  /-- Rest spacing, used to convert normalized displacement to length. -/
  length : ℝ
  length_pos : 0 < length
  /-- Dimensionless quartic hardening. -/
  η : ℝ
  η_nonneg : 0 ≤ η
  η_le_one : η ≤ 1
  /-- The quantitative timestep range selected by AP-03. -/
  timestep_bound : h ^ 2 * maxSpring / minMass ≤ 1 / 4

namespace ChainSystem

variable {n : ℕ} (s : ChainSystem n)

/-- Mass relative to the selected lower mass bound. -/
def a (i : Fin n) : ℝ := s.mass i / s.minMass

/-- Spring stiffness relative to the inertial timestep scale. -/
def b (i j : Fin n) : ℝ := s.h ^ 2 * s.spring i j / s.minMass

/-- The uniform normalized stiffness bound. -/
def α : ℝ := s.h ^ 2 * s.maxSpring / s.minMass

/-- Normalized masses satisfy the accepted inertial lower bound. -/
theorem a_ge_one (i : Fin n) : 1 ≤ s.a i := by
  exact (one_le_div₀ s.minMass_pos).mpr (s.mass_lower i)

/-- Normalized spring coefficients are nonnegative. -/
theorem b_nonneg (i j : Fin n) : 0 ≤ s.b i j :=
  div_nonneg (mul_nonneg (sq_nonneg _) (s.spring_nonneg i j)) s.minMass_pos.le

/-- Symmetry of physical springs gives an energy-gradient residual. -/
theorem b_symm (i j : Fin n) : s.b i j = s.b j i := by
  simp only [b, s.spring_symm i j]

/-- Normalization preserves nearest-neighbor support. -/
theorem b_support (i j : Fin n) (hij : i.val + 1 ≠ j.val) (hji : j.val + 1 ≠ i.val) :
    s.b i j = 0 := by
  simp [b, s.spring_support i j hij hji]

/-- Every normalized edge coefficient is bounded by the physical timestep parameter. -/
theorem b_le_alpha (i j : Fin n) : s.b i j ≤ s.α :=
  div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left (s.spring_upper i j) (sq_nonneg _))
    s.minMass_pos.le

/-- The exact neighbor set of a finite chain vertex. -/
def neighbors (i : Fin n) : Finset (Fin n) :=
  Finset.univ.filter fun j ↦ i.val + 1 = j.val ∨ j.val + 1 = i.val

/-- Every finite-chain vertex has at most two neighbors, including endpoints. -/
theorem neighbors_card_le_two (i : Fin n) : (neighbors i).card ≤ 2 := by
  have hs : (neighbors i).image Fin.val ⊆ {i.val + 1, i.val - 1} := by
    intro k hk
    obtain ⟨j, hj, rfl⟩ := Finset.mem_image.mp hk
    have he := (Finset.mem_filter.mp hj).2
    simp only [Finset.mem_insert, Finset.mem_singleton]
    omega
  calc
    (neighbors i).card = ((neighbors i).image Fin.val).card :=
      (Finset.card_image_of_injective _ Fin.val_injective).symm
    _ ≤ ({i.val + 1, i.val - 1} : Finset ℕ).card := Finset.card_le_card hs
    _ ≤ 2 := (Finset.card_insert_le _ _).trans (by simp)

/-- The physical system assumptions discharge the coefficient row bound used by VB-06. -/
theorem incident_le (i : Fin n) : ∑ j, s.b i j ≤ s.a i / 2 := by
  apply incident_bound_of_degree_two s.a_ge_one neighbors neighbors_card_le_two
    (α := s.α)
  · intro i j hj
    apply s.b_support i j
    · exact fun h ↦ hj (by simp [neighbors, h])
    · exact fun h ↦ hj (by simp [neighbors, h])
  · exact fun i j _ ↦ s.b_le_alpha i j
  · exact div_nonneg (mul_nonneg (sq_nonneg _) s.maxSpring_nonneg) s.minMass_pos.le
  · exact s.timestep_bound

/-- The accepted scalar determinant threshold in normalized stiffness units. -/
def threshold : ℝ≥0 := ⟨1 / 10 ^ 12, by positivity⟩

/-- Serial production execution in increasing vertex order. -/
def serial : State (Fin n) → State (Fin n) :=
  (newtonData s.a s.b s.η (cosinePredictor n) threshold).serial (List.finRange n)

/-- Buffered even/odd production execution. -/
def colored : State (Fin n) → State (Fin n) :=
  (newtonData s.a s.b s.η (cosinePredictor n) threshold).colored (chainColoring n) [0, 1]

/-- The parameterized physical chain has a serial finite-sweep certificate. -/
theorem serial_certificate : ∃ p, SweepCertificate s.a s.b s.η (cosinePredictor n) s.serial p := by
  apply serial_sweepCertificate s.a_ge_one s.b_nonneg (fun i ↦ s.b_support i i (by omega)
    (by omega)) s.η_nonneg s.η_le_one s.incident_le (cosinePredictor_bound n)
    threshold (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num) (List.finRange n)
    (List.nodup_finRange n) (List.mem_finRange ·)

/-- The parameterized physical chain has a proper-color finite-sweep certificate. -/
theorem colored_certificate :
    ∃ p, SweepCertificate s.a s.b s.η (cosinePredictor n) s.colored p := by
  apply colored_sweepCertificate s.a_ge_one s.b_nonneg (fun i ↦ s.b_support i i (by omega)
    (by omega)) s.η_nonneg s.η_le_one s.incident_le (cosinePredictor_bound n)
    threshold (by change (1 / 10 ^ 12 : ℝ) < 1; norm_num) (chainSupports n)
    (chain_supports s.b_support) (chainColoring n) [0, 1] (by decide)
    (by intro color; fin_cases color <;> simp)

/-- Both accepted execution plans converge to the same unique mechanical stationary point. -/
theorem common_certificate : ∃ p,
    SweepCertificate s.a s.b s.η (cosinePredictor n) s.serial p ∧
      SweepCertificate s.a s.b s.η (cosinePredictor n) s.colored p := by
  obtain ⟨p, hp⟩ := s.serial_certificate
  obtain ⟨z, hz⟩ := s.colored_certificate
  have he : z = p := hp.unique_root z hz.stationary
  exact ⟨p, hp, he ▸ hz⟩

/-- The physical implicit-Euler problem on displacements from the rest configuration. -/
def physicalStep : ImplicitEulerStep (State (Fin n)) :=
  { normalizedStep s.mass s.spring (s.η / s.length ^ 2)
      (s.length • cosinePredictor n) s.spring_symm with
    h := s.h
    h_pos := s.h_pos }

/-- The actual physical IE gradient is the normalized imbalance in force units. -/
theorem physical_gradient (u : State (Fin n)) (i : Fin n) :
    s.physicalStep.energyGradient (s.length • u) i =
      (s.minMass * s.length / s.h ^ 2) * residual s.a s.b s.η (cosinePredictor n) u i := by
  have hs : ∀ j, s.spring i j *
      ((s.length * u i - s.length * u j) + s.η / s.length ^ 2 *
        (s.length * u i - s.length * u j) ^ 3) =
      (s.minMass * s.length / s.h ^ 2) * (s.b i j *
        ((u i - u j) + s.η * (u i - u j) ^ 3)) := by
    intro j
    dsimp [b]
    field_simp [s.minMass_pos.ne', s.length_pos.ne', s.h_pos.ne']
  change (s.h ^ 2)⁻¹ * massOperator s.mass
      (s.length • u - s.length • cosinePredictor n) i +
      (∇ (potential s.spring (s.η / s.length ^ 2)) (s.length • u)) i = _
  rw [gradient_potential s.spring_symm]
  simp only [massOperator_apply, WithLp.ofLp_sub, WithLp.ofLp_smul, Pi.sub_apply,
    Pi.smul_apply, smul_eq_mul, residual, PiLp.toLp_apply, zero_mul, zero_add]
  rw [Finset.sum_congr rfl (fun j _ ↦ hs j), ← Finset.mul_sum]
  dsimp [a]
  field_simp [s.minMass_pos.ne', s.h_pos.ne']
  simp only [mul_comm s.η]


/-- The physical force imbalance in displacement units relative to the rest spacing. -/
def physicalScaledResidual (x : State (Fin n)) : Fin n → ℝ :=
  fun i ↦ s.h ^ 2 / (s.mass i * s.length) * s.physicalStep.energyGradient x i

/-- Mass and length normalization gives exactly the residual norm used by the finite theorem. -/
theorem physicalScaledResidual_eq (u : State (Fin n)) :
    s.physicalScaledResidual (s.length • u) =
      scaledResidual s.a s.b s.η (cosinePredictor n) (BlockContraction.toMax u) := by
  funext i
  rw [physicalScaledResidual, s.physical_gradient]
  simp only [scaledResidual, ContinuousLinearEquiv.symm_apply_apply]
  dsimp [a]
  field_simp [s.minMass_pos.ne', s.length_pos.ne', s.h_pos.ne',
    (s.minMass_pos.trans_le (s.mass_lower i)).ne']

/-- A normalized residual root is an actual physical implicit-Euler stationary state. -/
theorem physical_stationary {p : State (Fin n)}
    (hp : residual s.a s.b s.η (cosinePredictor n) p = 0) :
    s.physicalStep.energyGradient (s.length • p) = 0 := by
  apply PiLp.ext
  intro i
  rw [s.physical_gradient, hp]
  simp

/-- Every physical stationary state is the length-scaled normalized residual root. -/
theorem unique_physical_stationary {p : State (Fin n)}
    (hp : ∀ z, residual s.a s.b s.η (cosinePredictor n) z = 0 → z = p)
    {x : State (Fin n)} (hx : s.physicalStep.energyGradient x = 0) : x = s.length • p := by
  let u : State (Fin n) := s.length⁻¹ • x
  have hu : s.length • u = x := by
    dsimp [u]
    rw [smul_smul, mul_inv_cancel₀ s.length_pos.ne', one_smul]
  have hr : residual s.a s.b s.η (cosinePredictor n) u = 0 := by
    apply PiLp.ext
    intro i
    have he := s.physical_gradient u i
    rw [hu, hx] at he
    have hC : 0 < s.minMass * s.length / s.h ^ 2 := by
      exact div_pos (mul_pos s.minMass_pos s.length_pos) (sq_pos_of_pos s.h_pos)
    exact (mul_eq_zero.mp he.symm).resolve_left hC.ne'
  rw [← hu, hp u hr]

/-- End-to-end conclusions for both accepted production plans in physical units. -/
structure Certificate (p : State (Fin n)) : Prop where
  serial : SweepCertificate s.a s.b s.η (cosinePredictor n) s.serial p
  colored : SweepCertificate s.a s.b s.η (cosinePredictor n) s.colored p
  physical_root : s.physicalStep.energyGradient (s.length • p) = 0
  unique_physical_root : ∀ x, s.physicalStep.energyGradient x = 0 → x = s.length • p
  serial_twenty : ‖s.physicalScaledResidual (s.length • s.serial^[20] (cosinePredictor n))‖ <
    13 / 40000000
  colored_twenty : ‖s.physicalScaledResidual (s.length • s.colored^[20] (cosinePredictor n))‖ <
    13 / 40000000

/-- Positive masses, bounded nearest-neighbor springs, and the AP-03 timestep range yield
both physical finite-sweep certificates, with no supplied solution or contraction premises. -/
theorem end_to_end : ∃ p, s.Certificate p := by
  obtain ⟨p, hs, hc⟩ := s.common_certificate
  refine ⟨p, ⟨hs, hc, s.physical_stationary hs.stationary,
    fun x hx ↦ s.unique_physical_stationary hs.unique_root hx, ?_, ?_⟩⟩
  · rw [s.physicalScaledResidual_eq]
    exact hs.residual_twenty_lt
  · rw [s.physicalScaledResidual_eq]
    exact hc.residual_twenty_lt

end ChainSystem
end Vbd.AxialSpring
