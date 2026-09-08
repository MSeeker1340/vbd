/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/

import Mathlib.Analysis.Normed.Lp.PiLp

/-!
# Heterogeneous block states

This module defines the objective-independent coordinate algebra used by block updates. For a
block family `B : ι → Type*`, the dependent function type `(i : ι) → B i` stores one value of
the possibly different type `B i` at each coordinate. Mathlib's `PiLp 2 B` is a type copy of this
dependent function space that carries the finite-product `L²` geometry when the blocks have the
required analytic structures. It coerces back to a function, so a state coordinate is read as
`x i`. Single-coordinate injection additionally requires zero values in the block family.

Context: `knowledge/mathematics/block-coordinate.md`
-/

open scoped ENNReal

namespace Vbd

/-- A copy of the dependent function type `(i : ι) → B i`, equipped with Mathlib's
finite-product `L²` structure whenever the block family has the corresponding analytic structure. -/
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B

namespace BlockSum

variable {ι : Type*} {B : ι → Type*}

section Injection

variable [DecidableEq ι] [(i : ι) → Zero (B i)]

/-- Inject a block value into a state which is zero away from that coordinate. -/
def inject (i : ι) (b : B i) : BlockSum B := PiLp.single 2 i b

@[simp]
theorem inject_apply_same (i : ι) (b : B i) : inject i b i = b := by
  simp [inject]

@[simp]
theorem inject_apply_of_ne {i j : ι} (h : j ≠ i) (b : B i) : inject i b j = 0 := by
  simp [inject, h]

end Injection

section Replacement

variable [DecidableEq ι]

/-- Replace coordinate `i` of `x` by `b`, leaving all other coordinates unchanged. -/
def replace (x : BlockSum B) (i : ι) (b : B i) : BlockSum B :=
  WithLp.toLp 2 (Function.update (WithLp.ofLp x) i b)

@[simp]
theorem replace_apply_same (x : BlockSum B) (i : ι) (b : B i) : replace x i b i = b := by
  simp [replace]

@[simp]
theorem replace_apply_of_ne (x : BlockSum B) {i j : ι} (h : j ≠ i) (b : B i) :
    replace x i b j = x j := by
  simp [replace, h]

@[simp]
theorem replace_self (x : BlockSum B) (i : ι) : replace x i (x i) = x := by
  simp [replace]

@[simp]
theorem replace_replace (x : BlockSum B) (i : ι) (b c : B i) :
    replace (replace x i b) i c = replace x i c := by
  simp [replace]

theorem replace_comm (x : BlockSum B) {i j : ι} (h : i ≠ j) (b : B i) (c : B j) :
    replace (replace x i b) j c = replace (replace x j c) i b := by
  simp [replace, Function.update_comm h]

end Replacement

/-- A finite state is the sum of its single-block injections. -/
theorem sum_inject [Fintype ι] [DecidableEq ι] [∀ i, AddCommGroup (B i)]
    (x : BlockSum B) : ∑ i, inject i (x i) = x := by
  apply PiLp.ext
  simp [inject, WithLp.ofLp_sum, Finset.sum_apply]

/-- Replacement as addition of a single-block change. -/
theorem replace_eq_add_inject [DecidableEq ι] [∀ i, AddCommGroup (B i)]
    (x : BlockSum B) (i : ι) (v : B i) :
    replace x i v = x + inject i (v - x i) := by
  apply PiLp.ext
  intro j
  by_cases h : j = i
  · subst j
    simp only [replace_apply_same, WithLp.ofLp_add, Pi.add_apply, inject_apply_same,
      add_sub_cancel]
  · simp only [replace_apply_of_ne x h, WithLp.ofLp_add, Pi.add_apply,
      inject_apply_of_ne h, add_zero]

end BlockSum
end Vbd
