/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Block.Basic

/-!
# Continuous-linear block matrices

A finite family of heterogeneous normed blocks represents continuous linear maps by basis-free
block entries. Blocks may be infinite-dimensional. The scalar field is arbitrary; no inner product,
completeness, curvature, or differentiability hypotheses are needed.
-/

namespace Vbd
namespace BlockSum

variable {ι : Type*} {B : ι → Type*} {𝕜 : Type*}
variable [NontriviallyNormedField 𝕜] [DecidableEq ι]
variable [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace 𝕜 (B i)]

/-- Continuous projection onto a whole block. -/
def projection (i : ι) : BlockSum B →L[𝕜] B i := PiLp.proj 2 B i

/-- Continuous inclusion of a whole block. -/
def inclusion (i : ι) : B i →L[𝕜] BlockSum B :=
  (PiLp.continuousLinearEquiv 2 𝕜 B).symm.toContinuousLinearMap.comp
    (ContinuousLinearMap.single 𝕜 B i)

omit [DecidableEq ι] in
@[simp] theorem projection_apply (i : ι) (x : BlockSum B) :
    projection (𝕜 := 𝕜) i x = x i := rfl

@[simp] theorem inclusion_apply (i : ι) (v : B i) :
    inclusion (𝕜 := 𝕜) i v = inject i v := rfl

/-- The `(i,j)` entry maps input block `j` to output block `i`. -/
def entry (A : BlockSum B →L[𝕜] BlockSum B) (i j : ι) : B j →L[𝕜] B i :=
  (projection i).comp (A.comp (inclusion j))

@[simp] theorem entry_apply (A : BlockSum B →L[𝕜] BlockSum B) (i j : ι) (v : B j) :
    entry A i j v = A (inject j v) i := rfl

section Assembly

variable [Fintype ι]

/-- Assemble finitely many continuous-linear block entries. -/
def assemble (M : (i j : ι) → B j →L[𝕜] B i) : BlockSum B →L[𝕜] BlockSum B :=
  (PiLp.continuousLinearEquiv 2 𝕜 B).symm.toContinuousLinearMap.comp
    (ContinuousLinearMap.pi fun i ↦ ∑ j, (M i j).comp (projection j))

omit [DecidableEq ι] in
@[simp] theorem assemble_apply (M : (i j : ι) → B j →L[𝕜] B i) (x : BlockSum B) (i : ι) :
    assemble M x i = ∑ j, M i j (x j) := by
  simp [assemble, projection]

@[simp] theorem entry_assemble (M : (i j : ι) → B j →L[𝕜] B i) (i j : ι) :
    entry (assemble M) i j = M i j := by
  ext v
  simp only [entry_apply, assemble_apply]
  rw [Finset.sum_eq_single j]
  all_goals simp +contextual

/-- Reconstruct each output block from a row of entries. -/
theorem apply_eq_sum_entry (A : BlockSum B →L[𝕜] BlockSum B) (x : BlockSum B) (i : ι) :
    A x i = ∑ j, entry A i j (x j) := by
  conv_lhs => rw [← sum_inject x]
  simp [map_sum, WithLp.ofLp_sum, Finset.sum_apply]

@[simp] theorem assemble_entry (A : BlockSum B →L[𝕜] BlockSum B) :
    assemble (entry A) = A := by
  ext x i
  exact (assemble_apply (entry A) x i).trans (apply_eq_sum_entry A x i).symm

/-- Composition has the heterogeneous block-matrix multiplication formula. -/
theorem entry_comp (A C : BlockSum B →L[𝕜] BlockSum B) (i j : ι) :
    entry (A.comp C) i j = ∑ k, (entry A i k).comp (entry C k j) := by
  ext v
  simpa only [entry_apply, ContinuousLinearMap.comp_apply, sum_apply] using
    apply_eq_sum_entry A (C (inject j v)) i

end Assembly

section Finite

variable [Finite ι]

/-- A local `Fintype` instance supplies the finite-product norm from a finite index type. -/
noncomputable local instance : Fintype ι := Fintype.ofFinite ι

/-- Equality of operators is equality of all block entries. -/
theorem entry_ext {A C : BlockSum B →L[𝕜] BlockSum B}
    (h : ∀ i j, entry A i j = entry C i j) : A = C := by
  rw [← assemble_entry A, ← assemble_entry C,
    show entry A = entry C from funext fun i ↦ funext (h i)]

omit [Finite ι] in
@[simp] theorem entry_id_same (i : ι) :
    entry (ContinuousLinearMap.id 𝕜 (BlockSum B)) i i = ContinuousLinearMap.id 𝕜 (B i) := by
  ext v
  simp

omit [Finite ι] in
@[simp] theorem entry_id_of_ne {i j : ι} (h : i ≠ j) :
    entry (ContinuousLinearMap.id 𝕜 (BlockSum B)) i j = 0 := by
  ext v
  simp [h]

@[simp] theorem entry_add (A C : BlockSum B →L[𝕜] BlockSum B) (i j : ι) :
    entry (A + C) i j = entry A i j + entry C i j := by
  ext v
  rfl

@[simp] theorem entry_sub (A C : BlockSum B →L[𝕜] BlockSum B) (i j : ι) :
    entry (A - C) i j = entry A i j - entry C i j := by
  ext v
  rfl

omit [Finite ι] in
@[simp] theorem entry_zero (i j : ι) :
    entry (0 : BlockSum B →L[𝕜] BlockSum B) i j = 0 := by
  ext v
  rfl

@[simp] theorem entry_smul (c : 𝕜) (A : BlockSum B →L[𝕜] BlockSum B) (i j : ι) :
    entry (c • A) i j = c • entry A i j := by
  ext v
  rfl

/-- A preserved block is exactly an identity block row. Together with
`BlockUpdate.writeSupport_subset_iff`, this characterizes linear write-support bounds. -/
theorem preserves_iff_entry_row (A : BlockSum B →L[𝕜] BlockSum B) (i : ι) :
    (∀ x, A x i = x i) ↔
      ∀ j, entry A i j = entry (ContinuousLinearMap.id 𝕜 (BlockSum B)) i j := by
  constructor
  · intro h j
    ext v
    exact h (inject j v)
  · intro h x
    rw [apply_eq_sum_entry A x i]
    simpa only [h, ContinuousLinearMap.id_apply] using
      (apply_eq_sum_entry (ContinuousLinearMap.id 𝕜 (BlockSum B)) x i).symm

/-- The changed rows of a linear update are the nonzero rows of its difference from identity. -/
theorem preserves_iff_entry_sub_id_eq_zero (A : BlockSum B →L[𝕜] BlockSum B) (i : ι) :
    (∀ x, A x i = x i) ↔
      ∀ j, entry (A - ContinuousLinearMap.id 𝕜 (BlockSum B)) i j = 0 := by
  simp only [entry_sub, sub_eq_zero, preserves_iff_entry_row]

end Finite

end BlockSum
end Vbd
