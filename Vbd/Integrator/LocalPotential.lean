/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/

import Vbd.Block.Basic
import Vbd.Integrator.ImplicitEulerEnergy
import Mathlib.Combinatorics.SimpleGraph.Coloring.Vertex

/-!
# Finite-support local potentials and graph coloring

This module connects finite-support components of an implicit-Euler potential to Mathlib's simple
graphs and proper vertex colorings. It defines only the support-specific data and bridge lemmas;
`SimpleGraph.Coloring (Fin m)` remains Mathlib's representation of numbered proper colorings.

Context: `knowledge/mathematics/local-decomposition-and-coloring.md`
-/

open scoped BigOperators

namespace Vbd

variable {ι : Type*} {B : ι → Type*}

/-- A scalar component potential is local on `S` when its value is determined by the blocks indexed
by `S`. -/
def ComponentLocal (S : Finset ι) (f : BlockSum B → ℝ) : Prop :=
  ∀ ⦃x z : BlockSum B⦄, (∀ i, i ∈ S → x i = z i) → f x = f z

/-- A finite-support decomposition of a potential on a heterogeneous block state. Equal-support
summands are represented by one component function. -/
structure LocalPotential where
  /-- Supports of the component potentials. -/
  supports : Finset (Finset ι)
  /-- Component potential indexed by a possible support. -/
  component : Finset ι → BlockSum B → ℝ
  /-- Every selected component is local on its support. -/
  component_local : ∀ S, S ∈ supports → ComponentLocal S (component S)

namespace LocalPotential

/-- The potential obtained by summing all selected component potentials. -/
def energy (P : LocalPotential (B := B)) (x : BlockSum B) : ℝ :=
  ∑ S ∈ P.supports, P.component S x

/-- Two states agree off `J` when they have equal blocks outside `J`. -/
def AgreeOff (J : Finset ι) (x z : BlockSum B) : Prop :=
  ∀ i, i ∉ J → x i = z i

/-- A component on a support disjoint from the changed blocks has the same value at both states. -/
theorem component_eq_of_agreeOff_of_disjoint (P : LocalPotential (B := B)) {J S : Finset ι}
    {x z : BlockSum B} (hagree : AgreeOff J x z) (hS : S ∈ P.supports)
    (hdisjoint : Disjoint S J) : P.component S x = P.component S z := by
  apply P.component_local S hS
  intro i hi
  apply hagree i
  exact fun hj ↦ (Finset.disjoint_left.mp hdisjoint hi hj)

variable [DecidableEq ι]

/-- The supports whose components can change when only blocks in `J` are replaced. -/
def affectedSupports (P : LocalPotential (B := B)) (J : Finset ι) : Finset (Finset ι) :=
  P.supports.filter fun S ↦ ¬Disjoint S J

/-- Components outside `affectedSupports P J` cancel from an energy change supported in `J`. -/
theorem energy_sub_eq_sum_affected (P : LocalPotential (B := B)) {J : Finset ι}
    {x z : BlockSum B} (hagree : AgreeOff J x z) :
    P.energy z - P.energy x =
      ∑ S ∈ P.affectedSupports J, (P.component S z - P.component S x) := by
  rw [energy, energy, ← Finset.sum_sub_distrib]
  rw [affectedSupports, Finset.sum_filter]
  apply Finset.sum_congr rfl
  intro S hS
  by_cases hdisjoint : Disjoint S J
  · simp [hdisjoint, (P.component_eq_of_agreeOff_of_disjoint hagree hS hdisjoint).symm]
  · simp [hdisjoint]

end LocalPotential

/-- The component interaction graph induced by a finite family of supports. -/
def componentGraph (A : Finset (Finset ι)) : SimpleGraph ι :=
  SimpleGraph.fromRel fun i j ↦ ∃ S ∈ A, i ∈ S ∧ j ∈ S

/-- Adjacency in the component interaction graph is exactly co-occurrence in a support. -/
theorem componentGraph_adj_iff (A : Finset (Finset ι)) {i j : ι} :
    (componentGraph A).Adj i j ↔ i ≠ j ∧ ∃ S ∈ A, i ∈ S ∧ j ∈ S := by
  rw [componentGraph, SimpleGraph.fromRel_adj]
  constructor
  · rintro ⟨hne, hrel⟩
    rcases hrel with hrel | hrel
    · exact ⟨hne, hrel⟩
    · rcases hrel with ⟨S, hS, hj, hi⟩
      exact ⟨hne, S, hS, hi, hj⟩
  · rintro ⟨hne, S, hS, hi, hj⟩
    exact ⟨hne, Or.inl ⟨S, hS, hi, hj⟩⟩

/-- Enlarging a support family enlarges its component interaction graph. -/
theorem componentGraph_mono {A M : Finset (Finset ι)} (hMA : M ⊆ A) :
    componentGraph M ≤ componentGraph A := by
  intro i j hij
  rw [componentGraph_adj_iff] at hij ⊢
  rcases hij with ⟨hne, S, hS, hi, hj⟩
  exact ⟨hne, S, hMA hS, hi, hj⟩

/-- A block-color assignment is injective on a support when blocks in that support have distinct
colors. -/
def InjectiveOnSupports (A : Finset (Finset ι)) {κ : Type*} (color : ι → κ) : Prop :=
  ∀ ⦃S : Finset ι⦄, S ∈ A → ∀ ⦃i j : ι⦄, i ∈ S → j ∈ S → color i = color j → i = j

/-- A Mathlib graph coloring is injective on every component support. -/
theorem coloring_injectiveOnSupports {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) : InjectiveOnSupports A c := by
  intro S hS i j hi hj hcolor
  by_contra hne
  exact c.valid (componentGraph_adj_iff A |>.mpr ⟨hne, S, hS, hi, hj⟩) hcolor

/-- A support-wise injective numbered color assignment is a Mathlib proper graph coloring. -/
def coloringOfInjectiveOnSupports (A : Finset (Finset ι)) {m : ℕ} (color : ι → Fin m)
    (hcolor : InjectiveOnSupports A color) : (componentGraph A).Coloring (Fin m) :=
  SimpleGraph.Coloring.mk color (by
    intro i j hij hsame
    rcases componentGraph_adj_iff A |>.mp hij with ⟨hne, S, hS, hi, hj⟩
    exact hne (hcolor hS hi hj hsame))

/-- Restrict a proper coloring to a smaller support family. -/
def restrictColoring {A M : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (hMA : M ⊆ A) :
    (componentGraph M).Coloring (Fin m) :=
  SimpleGraph.Coloring.mk c (by
    intro i j hij
    exact c.valid (componentGraph_mono hMA hij))

/-- A fixed color assignment extends to a larger support family exactly when it remains injective
on every added support. -/
theorem exists_coloring_extension_iff {A M : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph M).Coloring (Fin m)) :
    (∃ c' : (componentGraph A).Coloring (Fin m), ∀ i, c' i = c i) ↔
      InjectiveOnSupports A c := by
  constructor
  · rintro ⟨c', hc'⟩
    intro S hS i j hi hj hsame
    have hsame' : c' i = c' j := by
      rw [hc' i, hc' j]
      exact hsame
    exact coloring_injectiveOnSupports c' hS hi hj hsame'
  · intro hcolor
    refine ⟨coloringOfInjectiveOnSupports A c hcolor, ?_⟩
    intro i
    rfl

/-- A pairwise support family on two blocks has a valid two-coloring. -/
example : (componentGraph ({({0, 1} : Finset (Fin 2))})).Coloring (Fin 2) :=
  (componentGraph ({({0, 1} : Finset (Fin 2))})).selfColoring

/-- A three-block support family has a valid three-coloring. -/
example : (componentGraph ({({0, 1, 2} : Finset (Fin 3))})).Coloring (Fin 3) :=
  (componentGraph ({({0, 1, 2} : Finset (Fin 3))})).selfColoring

end Vbd
