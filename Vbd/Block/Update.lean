/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Block.Basic
import Mathlib.Algebra.Group.End
import Mathlib.Algebra.BigOperators.Group.List.Lemmas

/-!
# Write support and simultaneous merging

Updates are ordinary self-maps, composed with `Function.comp`. Finite composition uses Mathlib's
`Function.End` monoid and `List.prod`: multiplication is composition, so the rightmost factor acts
first. Identity, associativity, and reordering of commuting factors use Mathlib's monoid laws.
Write-support bounds constrain output blocks; reads may use the whole state. Simultaneous merging
combines output blocks evaluated at a common input.
-/

namespace Vbd
namespace BlockUpdate

variable {ι : Type*} {B : ι → Type*}

/-- The set of block indices at which the update changes some input state. -/
def writeSupport (U : BlockSum B → BlockSum B) : Set ι :=
  {i | ∃ x, U x i ≠ x i}

theorem writeSupport_subset_iff {U : BlockSum B → BlockSum B} {W : Set ι} :
    writeSupport U ⊆ W ↔ ∀ x i, i ∉ W → U x i = x i := by
  classical
  simp only [Set.subset_def, writeSupport, Set.mem_ofPred]
  grind

@[simp]
theorem writeSupport_id : writeSupport (id : BlockSum B → BlockSum B) = ∅ := by
  ext i
  simp [writeSupport]

theorem writeSupport_comp (U V : BlockSum B → BlockSum B) :
    writeSupport (V ∘ U) ⊆ writeSupport U ∪ writeSupport V := by
  rw [writeSupport_subset_iff]
  simp only [Set.mem_union, not_or, writeSupport, Set.mem_ofPred, not_exists, not_not,
    Function.comp_apply]
  exact fun x i h ↦ (h.2 (U x)).trans (h.1 x)

theorem writeSupport_comp_subset {U V : BlockSum B → BlockSum B} {W Z : Set ι}
    (hU : writeSupport U ⊆ W) (hV : writeSupport V ⊆ Z) :
    writeSupport (V ∘ U) ⊆ W ∪ Z :=
  (writeSupport_comp U V).trans (Set.union_subset_union hU hV)

theorem writeSupport_replace [DecidableEq ι] (i : ι) (f : BlockSum B → B i) :
    writeSupport (fun x ↦ BlockSum.replace x i (f x)) ⊆ {i} := by
  apply writeSupport_subset_iff.mpr
  exact fun x j hj ↦ BlockSum.replace_apply_of_ne x hj (f x)

/-- A product of operators preserving a block preserves that block. -/
theorem prod_preserves (l : List (Function.End (BlockSum B))) (i : ι)
    (h : ∀ U ∈ l, ∀ x, U x i = x i) (x : BlockSum B) : l.prod x i = x i := by
  induction l with
  | nil => rfl
  | cons U l ih =>
      exact (h U List.mem_cons_self (l.prod x)).trans
        (ih (fun V hV ↦ h V (List.mem_cons_of_mem U hV)))

/-- Write support propagates through ordinary finite composition. -/
theorem writeSupport_prod (l : List (Function.End (BlockSum B))) :
    writeSupport l.prod ⊆ ⋃ U ∈ l, writeSupport U := by
  apply writeSupport_subset_iff.mpr
  exact fun x i hi ↦ prod_preserves l i (fun U hU z ↦
    writeSupport_subset_iff.mp (show writeSupport U ⊆ writeSupport U from Set.Subset.rfl)
      z i (by aesop)) x

variable {κ : Type*}

/-- Select output blocks using supplied write-support bounds. Pairwise disjoint bounds assign
at most one operator index to each block.
The finite set indexes operators, independently of the block index type. -/
noncomputable def merge (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (x : BlockSum B) : BlockSum B := by
  classical
  exact WithLp.toLp 2 fun i ↦ if h : ∃ r, r ∈ K ∧ i ∈ W r then U h.choose x i else x i

theorem merge_apply_of_mem (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s))
    {r : κ} (hr : r ∈ K) {i : ι} (hi : i ∈ W r) (x : BlockSum B) :
    merge U K W x i = U r x i := by
  classical
  have h : ∃ s, s ∈ K ∧ i ∈ W s := ⟨r, hr, hi⟩
  have he : h.choose = r := by
    exact by_contra fun hn ↦
      Set.disjoint_left.mp (hd _ h.choose_spec.1 r hr hn) h.choose_spec.2 hi
  simp only [merge, PiLp.toLp_apply, dite_eq_left h, he]

theorem merge_apply_of_not_mem (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) {i : ι} (hi : ∀ r ∈ K, i ∉ W r) (x : BlockSum B) :
    merge U K W x i = x i := by
  classical
  simp [merge, show ¬ (∃ r, r ∈ K ∧ i ∈ W r) from by aesop]

@[simp] theorem merge_empty (U : κ → BlockSum B → BlockSum B) (W : κ → Set ι) :
    merge U ∅ W = id := by
  funext x
  exact PiLp.ext fun i ↦ merge_apply_of_not_mem U ∅ W (by simp) x

theorem writeSupport_merge (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s)) :
    writeSupport (merge U K W) = ⋃ r ∈ K, writeSupport (U r) := by
  classical
  ext i
  simp only [writeSupport, Set.mem_ofPred, Set.mem_iUnion]
  constructor
  · rintro ⟨x, hx⟩
    by_cases h : ∃ r, r ∈ K ∧ i ∈ W r
    · obtain ⟨r, hr, hi⟩ := h
      exact ⟨r, hr, x, (merge_apply_of_mem U K W hd hr hi x) ▸ hx⟩
    · exact False.elim (hx (merge_apply_of_not_mem U K W (by aesop) x))
  · rintro ⟨r, hr, x, hx⟩
    exact ⟨x, (merge_apply_of_mem U K W hd hr (hb r hr ⟨x, hx⟩) x).trans_ne hx⟩

/-- Every enumeration of a pairwise-commuting family with disjoint write-support bounds
implements its simultaneous merge. -/
theorem merge_eq_prod (U : κ → Function.End (BlockSum B)) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s))
    (hc : ∀ r ∈ K, ∀ s ∈ K, Function.Commute (U r) (U s))
    (order : List κ) (hn : order.Nodup) (he : ∀ r, r ∈ order ↔ r ∈ K) :
    merge U K W = (order.map U).prod := by
  classical
  funext x
  apply PiLp.ext
  intro i
  by_cases h : ∃ r, r ∈ K ∧ i ∈ W r
  · obtain ⟨r, hr, hi⟩ := h
    have hp : order.Perm (order.erase r ++ [r]) :=
      (List.perm_cons_erase ((he r).mpr hr)).trans (by simpa using
        (List.perm_append_comm (l₁ := [r]) (l₂ := order.erase r)))
    have hc' : (order.map U).Pairwise Commute := by
      exact List.pairwise_map.mpr (List.Pairwise.imp_of_mem
        (fun hs ht _ ↦ funext (hc _ ((he _).mp hs) _ ((he _).mp ht))) hn)
    rw [merge_apply_of_mem U K W hd hr hi, (hp.map U).prod_eq' hc',
      List.map_append, List.prod_append, List.map_singleton, List.prod_singleton]
    refine (prod_preserves ((order.erase r).map U) i ?_ (U r x)).symm
    simp only [List.forall_mem_map]
    exact fun s hs z ↦
      writeSupport_subset_iff.mp (hb s ((he s).mp (List.mem_of_mem_erase hs))) z i
        (fun his ↦ Set.disjoint_left.mp
          (hd s ((he s).mp (List.mem_of_mem_erase hs)) r hr
            (hn.mem_erase_iff.mp hs).1) his hi)
  · rw [merge_apply_of_not_mem U K W (by aesop)]
    refine (prod_preserves (order.map U) i ?_ x).symm
    exact List.forall_mem_map.mpr (fun r hr z ↦
      writeSupport_subset_iff.mp (hb r ((he r).mp hr)) z i (by aesop))

/-- The union of the supplied bounds bounds the write support of the simultaneous merge. -/
theorem writeSupport_merge_subset (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s)) :
    writeSupport (merge U K W) ⊆ ⋃ r ∈ K, W r := by
  rw [writeSupport_merge U K W hb hd]
  exact Set.iUnion₂_mono hb

/-- On additive blocks, simultaneous merging sums the changes computed from the original state. -/
theorem merge_eq_add_sum [∀ i, AddCommGroup (B i)]
    (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s)) (x : BlockSum B) :
    merge U K W x = x + ∑ r ∈ K, (U r x - x) := by
  classical
  apply PiLp.ext
  intro i
  simp only [WithLp.ofLp_add, Pi.add_apply, WithLp.ofLp_sum, Finset.sum_apply,
    WithLp.ofLp_sub, Pi.sub_apply]
  by_cases h : ∃ r, r ∈ K ∧ i ∈ W r
  · obtain ⟨r, hr, hi⟩ := h
    rw [merge_apply_of_mem U K W hd hr hi, Finset.sum_eq_single r]
    · exact (add_sub_cancel _ _).symm
    · exact fun s hs hsr ↦ sub_eq_zero.mpr (writeSupport_subset_iff.mp (hb s hs) x i
        (fun his ↦ Set.disjoint_left.mp (hd s hs r hr hsr) his hi))
    · exact fun h ↦ (h hr).elim
  · rw [merge_apply_of_not_mem U K W (by aesop)]
    have hz : ∀ r ∈ K, U r x i = x i := fun r hr ↦
      writeSupport_subset_iff.mp (hb r hr) x i (fun hi ↦ h ⟨r, hr, hi⟩)
    rw [Finset.sum_eq_zero (fun r hr ↦ sub_eq_zero.mpr (hz r hr)), add_zero]

end BlockUpdate
end Vbd
