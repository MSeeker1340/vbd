/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.VBD
import Vbd.Block.Contraction
import Mathlib.Analysis.Calculus.FDeriv.CompCLM
import Mathlib.Analysis.Calculus.FDeriv.Mul

/-!
# VBD derivatives at residual roots

The local derivative uses a differentiable residual, a differentiable local Hessian-block map,
and strict acceptance by the production determinant test at the root. These hypotheses keep
the skip branch locally inactive. The inverse-stiffness derivative is multiplied by the residual
and vanishes at the root. Ordered composition uses the Phase-6 chain rule on the invariant
singleton containing that root.
-/

noncomputable section

open Filter Set Topology
open scoped NNReal

namespace Vbd.BlockNewtonData

variable {ι : Type*} {B : ι → Type*} [Finite ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]
  [∀ i, FiniteDimensional ℝ (B i)]
  (d : BlockNewtonData B)

/-- A local enumeration supplies finite-product norms in the root calculus. -/
private local instance rootIndexFintype : Fintype ι := Fintype.ofFinite ι

/-- The root linearization of one update, before identifying its local solve matrix with
the corresponding exact diagonal block of the residual derivative. -/
def rootDerivative (H : BlockSum B →L[ℝ] BlockSum B) (p : BlockSum B) (i : ι) :
    BlockSum B →L[ℝ] BlockSum B :=
  ContinuousLinearMap.id ℝ _ - (BlockSum.inclusion i).comp
    ((d.diagonal i p).inverse.comp ((BlockSum.projection i).comp H))

omit [Finite ι] in
private theorem update_eq_sub_inclusion {i : ι} {x : BlockSum B} (h : d.Regular i x) :
    d.update i x = x - BlockSum.inclusion (𝕜 := ℝ) i
      ((d.diagonal i x).inverse (d.residual x i)) := by
  rw [d.update_of_regular h, BlockSum.replace_eq_add_inject, sub_sub_cancel_left]
  simp only [← BlockSum.inclusion_apply (𝕜 := ℝ), map_neg, sub_eq_add_neg]

omit [Finite ι] [DecidableEq ι] in
private theorem eventually_regular {i : ι} {p : BlockSum B} (h : d.Regular i p)
    (hK : ContinuousAt (d.diagonal i) p) : ∀ᶠ x in 𝓝 p, d.Regular i x := by
  exact continuousAt_const.eventually_lt
    ((ContinuousLinearMap.continuous_det.continuousAt.comp hK).abs) h

omit [DecidableEq ι] in
private theorem differentiableAt_inverse_diagonal {i : ι} {p : BlockSum B}
    (h : d.Regular i p) (hK : DifferentiableAt ℝ (d.diagonal i) p) :
    DifferentiableAt ℝ (fun x ↦ (d.diagonal i x).inverse) p := by
  obtain ⟨e, he⟩ := d.isInvertible_of_regular h
  simpa only [ContinuousLinearMap.ringInverse_eq_inverse] using hK.inverse ⟨e.toUnit, he⟩

/-- The full-step production update has the Newton row derivative at a regular residual root.
Differentiability of the local Hessian-block map is an explicit smoothness premise. -/
theorem hasFDerivAt_update_root {H : BlockSum B →L[ℝ] BlockSum B} {p : BlockSum B} {i : ι}
    (hR : HasFDerivAt d.residual H p) (hroot : d.residual p = 0) (hreg : d.Regular i p)
    (hK : DifferentiableAt ℝ (d.diagonal i) p) :
    HasFDerivAt (d.update i) (d.rootDerivative H p i) p := by
  have hInv := d.differentiableAt_inverse_diagonal hreg hK
  have hsolve : HasFDerivAt (fun x ↦ (d.diagonal i x).inverse (d.residual x i))
      ((d.diagonal i p).inverse.comp ((BlockSum.projection i).comp H)) p := by
    simpa [hroot] using hInv.hasFDerivAt.clm_apply
      ((BlockSum.projection (𝕜 := ℝ) i).hasFDerivAt.comp p hR)
  exact ((hasFDerivAt_id p).sub ((BlockSum.inclusion (𝕜 := ℝ) i).hasFDerivAt.comp p hsolve))
    |>.congr_of_eventuallyEq ((d.eventually_regular hreg hK.continuousAt).mono
      fun _ hx ↦ d.update_eq_sub_inclusion hx)

omit [Finite ι] [DecidableEq ι] [∀ i, FiniteDimensional ℝ (B i)] in
private theorem orderedDerivative_const {κ : Type*}
    (U : κ → Function.End (BlockSum B)) (A : κ → BlockSum B →L[ℝ] BlockSum B)
    (order : List κ) (x : BlockSum B) :
    BlockContraction.orderedDerivative U (fun i _ ↦ A i) order x = (order.map A).prod := by
  induction order with
  | nil => rfl
  | cons i order ih =>
      simp only [BlockContraction.orderedDerivative, ih, List.map_cons, List.prod_cons,
        ContinuousLinearMap.mul_def]

/-- The chronological production sweep differentiates to the corresponding ordered row product
at a regular residual root. No invariant neighborhood or contraction premise is needed here. -/
theorem hasFDerivAt_serial_root (order : List ι)
    {H : BlockSum B →L[ℝ] BlockSum B} {p : BlockSum B}
    (hR : HasFDerivAt d.residual H p) (hroot : d.residual p = 0)
    (hreg : ∀ i ∈ order, d.Regular i p)
    (hK : ∀ i ∈ order, DifferentiableAt ℝ (d.diagonal i) p) :
    HasFDerivAt (d.serial order) (order.reverse.map (d.rootDerivative H p)).prod p := by
  simpa only [serial, orderedDerivative_const] using
    (BlockContraction.hasFDerivAt_prod d.update (fun i _ ↦ d.rootDerivative H p i) order.reverse
      (R := {p})
      (fun i _ ↦ mapsTo_singleton.mpr (mem_singleton_iff.mpr
        (d.update_of_residual_eq_zero (congrArg (fun z : BlockSum B ↦ z i) hroot))))
      (fun i hi x hx ↦ by
        simpa only [mem_singleton_iff.mp hx] using
          d.hasFDerivAt_update_root hR hroot (hreg i (List.mem_reverse.mp hi))
            (hK i (List.mem_reverse.mp hi))) (mem_singleton p))

end Vbd.BlockNewtonData

namespace Vbd.GaussSeidel

variable {ι : Type*} {B : ι → Type*} [Finite ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]

/-- A local enumeration supplies the finite block row sum. -/
private local instance gaussSeidelIndexFintype : Fintype ι := Fintype.ofFinite ι

/-- One homogeneous block Gauss–Seidel error update for `H v = 0`, represented as an
identity-minus-row correction. Its forward-substitution equation is proved below. -/
def step (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) : BlockSum B →L[ℝ] BlockSum B :=
  ContinuousLinearMap.id ℝ _ - (BlockSum.inclusion i).comp
    ((BlockSum.entry H i i).inverse.comp ((BlockSum.projection i).comp H))

@[simp] theorem step_apply_same (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) (v : BlockSum B) :
    step H i v i = v i - (BlockSum.entry H i i).inverse (H v i) := by
  simp [step]

@[simp] theorem step_apply_of_ne (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) (v : BlockSum B)
    {k : ι} (hk : k ≠ i) : step H i v k = v k := by
  simp [step, hk]

/-- The changed row is the identity row minus the normalized Hessian row. -/
theorem entry_step_same (H : BlockSum B →L[ℝ] BlockSum B) (i j : ι) :
    BlockSum.entry (step H i) i j =
      BlockSum.entry (ContinuousLinearMap.id ℝ (BlockSum B)) i j -
        (BlockSum.entry H i i).inverse.comp (BlockSum.entry H i j) := by
  ext v
  simp [BlockSum.entry_apply]

theorem entry_step_of_ne (H : BlockSum B →L[ℝ] BlockSum B) (i j : ι) {k : ι}
    (hk : k ≠ i) : BlockSum.entry (step H i) k j =
      BlockSum.entry (ContinuousLinearMap.id ℝ (BlockSum B)) k j := by
  ext v
  simp [BlockSum.entry_apply, hk]

/-- Exact Newton cancellation makes the changed diagonal entry zero. -/
theorem entry_step_diagonal (H : BlockSum B →L[ℝ] BlockSum B) (i : ι)
    (hI : (BlockSum.entry H i i).IsInvertible) : BlockSum.entry (step H i) i i = 0 := by
  simp [entry_step_same, hI.inverse_comp_self]

/-- A changed off-diagonal entry is the negative normalized coupling block. -/
theorem entry_step_offDiagonal (H : BlockSum B →L[ℝ] BlockSum B) (i j : ι) (hij : i ≠ j) :
    BlockSum.entry (step H i) i j =
      -(BlockSum.entry H i i).inverse.comp (BlockSum.entry H i j) := by
  simp [entry_step_same, hij]

/-- The changed component solves the homogeneous block row with other components held fixed.
This is the block Gauss–Seidel forward-substitution rule. -/
theorem step_apply_same_eq_neg_sum (H : BlockSum B →L[ℝ] BlockSum B) (i : ι)
    (hI : (BlockSum.entry H i i).IsInvertible) (v : BlockSum B) :
    step H i v i = -(BlockSum.entry H i i).inverse
      (∑ j ∈ Finset.univ.erase i, BlockSum.entry H i j (v j)) := by
  rw [step_apply_same, BlockSum.apply_eq_sum_entry,
    ← Finset.add_sum_erase Finset.univ (fun j ↦ BlockSum.entry H i j (v j)) (Finset.mem_univ i)]
  simp only [map_add, hI.inverse_apply_self, sub_add_cancel_left]

/-- A chronological Gauss–Seidel error sweep. Interior block spaces and visit order remain
arbitrary; invertibility hypotheses on visited diagonal blocks justify the solve equations. -/
def sweep (H : BlockSum B →L[ℝ] BlockSum B) (order : List ι) :
    BlockSum B →L[ℝ] BlockSum B := (order.reverse.map (step H)).prod

@[simp] theorem sweep_nil (H : BlockSum B →L[ℝ] BlockSum B) :
    sweep H [] = ContinuousLinearMap.id ℝ _ := rfl

@[simp] theorem sweep_cons (H : BlockSum B →L[ℝ] BlockSum B) (i : ι) (order : List ι)
    (v : BlockSum B) : sweep H (i :: order) v = sweep H order (step H i v) := by
  simp [sweep, List.reverse_cons, List.map_append, List.prod_append]

end Vbd.GaussSeidel

namespace Vbd.BlockNewtonData

variable {ι : Type*} {B : ι → Type*} [Finite ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]
  [∀ i, FiniteDimensional ℝ (B i)] (d : BlockNewtonData B)

/-- A local enumeration supplies finite-product norms for exact root identification. -/
private local instance exactRootIndexFintype : Fintype ι := Fintype.ofFinite ι

/-- Exact local Hessian blocks identify the Newton root derivative with a Gauss–Seidel step. -/
theorem rootDerivative_eq_gaussSeidel_step {H : BlockSum B →L[ℝ] BlockSum B}
    {p : BlockSum B} {i : ι} (hdiag : d.diagonal i p = BlockSum.entry H i i) :
    d.rootDerivative H p i = GaussSeidel.step H i := by
  simp only [rootDerivative, GaussSeidel.step, hdiag]

/-- The derivative of the actual serial Newton sweep is the homogeneous block Gauss–Seidel
error operator in the externally supplied order. Exact diagonal blocks are explicit premises. -/
theorem hasFDerivAt_serial_gaussSeidel (order : List ι)
    {H : BlockSum B →L[ℝ] BlockSum B} {p : BlockSum B}
    (hR : HasFDerivAt d.residual H p) (hroot : d.residual p = 0)
    (hreg : ∀ i ∈ order, d.Regular i p)
    (hK : ∀ i ∈ order, DifferentiableAt ℝ (d.diagonal i) p)
    (hdiag : ∀ i ∈ order, d.diagonal i p = BlockSum.entry H i i) :
    HasFDerivAt (d.serial order) (GaussSeidel.sweep H order) p := by
  refine (d.hasFDerivAt_serial_root order hR hroot hreg hK).congr_fderiv ?_
  exact congrArg List.prod (List.map_congr_left fun i hi ↦
    d.rootDerivative_eq_gaussSeidel_step (hdiag i (List.mem_reverse.mp hi)))

end Vbd.BlockNewtonData

namespace Vbd.ImplicitEulerStep

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, InnerProductSpace ℝ (B i)]
  [∀ i, CompleteSpace (B i)] [∀ i, FiniteDimensional ℝ (B i)]

/-- The concrete IE sweep has the Gauss–Seidel error derivative at a regular stationary point.
The additional smoothness premise concerns the diagonal Hessian maps; the IE step's stored
differentiability assumptions already provide the residual derivative itself. -/
theorem hasFDerivAt_vbd_serial_root (ie : ImplicitEulerStep (BlockSum B))
    (threshold : ℝ≥0) (order : List ι) {p : BlockSum B} (hroot : ie.energyGradient p = 0)
    (hreg : ∀ i ∈ order, (ie.blockNewtonData threshold).Regular i p)
    (hK : ∀ i ∈ order, DifferentiableAt ℝ ((ie.blockNewtonData threshold).diagonal i) p) :
    HasFDerivAt ((ie.blockNewtonData threshold).serial order)
      (GaussSeidel.sweep (hessian ie.energy p) order) p := by
  have hd : DifferentiableAt ℝ ie.energyGradient p := by
    exact ((ie.M.differentiableAt.comp p (differentiableAt_id.sub_const ie.y)).const_smul
      ((ie.h ^ 2)⁻¹)).add (ie.gradient_differentiable p)
  have hR : HasFDerivAt ie.energyGradient (hessian ie.energy p) p := by
    simpa only [hessian, gradient_energy] using hd.hasFDerivAt
  exact (ie.blockNewtonData threshold).hasFDerivAt_serial_gaussSeidel order hR hroot hreg hK
    (fun _ _ ↦ rfl)

end Vbd.ImplicitEulerStep
