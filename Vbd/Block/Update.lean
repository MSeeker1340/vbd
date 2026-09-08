/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Block.Basic
import Mathlib.Data.List.Perm.Basic

/-!
# Write support and externally ordered updates

An update is an ordinary self-map. `execute U order` applies the operators in list order,
including repeated positions. Write bounds constrain outputs only; reads may use the whole state.
`merge` selects disjoint output blocks evaluated at one common input. Its definition requires
neither commutation nor algebraic structure on the blocks.
-/

namespace Vbd
namespace BlockUpdate

variable {ι : Type*} {B : ι → Type*}

/-- The blocks changed at some input. -/
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

section Execution
variable {X : Type*} {κ : Type*}

/-- External positions are applied from left to right. -/
def execute (U : κ → X → X) (order : List κ) (x : X) : X :=
  order.foldl (fun z r ↦ U r z) x

@[simp] theorem execute_nil (U : κ → X → X) : execute U [] = id := rfl

@[simp] theorem execute_cons (U : κ → X → X) (r : κ) (order : List κ) :
    execute U (r :: order) = execute U order ∘ U r := rfl

@[simp] theorem execute_singleton (U : κ → X → X) (r : κ) :
    execute U [r] = U r := rfl

theorem execute_append (U : κ → X → X) (a b : List κ) :
    execute U (a ++ b) = execute U b ∘ execute U a := by
  funext x
  exact List.foldl_append

/-- The state after the first `n` positions; out-of-range prefixes give the final state. -/
def intermediate (U : κ → X → X) (order : List κ) (x : X) (n : ℕ) : X :=
  execute U (order.take n) x

theorem intermediate_zero (U : κ → X → X) (order : List κ) (x : X) :
    intermediate U order x 0 = x := rfl

theorem intermediate_succ (U : κ → X → X) (order : List κ) (x : X)
    (n : ℕ) (h : n < order.length) :
    intermediate U order x (n + 1) = U order[n] (intermediate U order x n) := by
  unfold intermediate
  rw [List.take_succ_eq_append_getElem h, execute_append]
  rfl

/-- Once every position has executed, every longer prefix gives the final state. -/
theorem intermediate_eq_execute (U : κ → X → X) (order : List κ) (x : X)
    {n : ℕ} (h : order.length ≤ n) : intermediate U order x n = execute U order x := by
  simp only [intermediate, List.take_of_length_le h]

/-- Adjacent commuting updates may be exchanged inside an arbitrary execution. -/
theorem execute_swap (U : κ → X → X) (before after : List κ) (r s : κ)
    (h : Function.Commute (U r) (U s)) :
    execute U (before ++ r :: s :: after) = execute U (before ++ s :: r :: after) := by
  simp only [execute_append, execute_cons]
  exact funext fun x ↦ congrArg (execute U after) (h (execute U before x)).symm

/-- Permutations preserve execution when the participating operators commute. -/
theorem execute_perm (U : κ → X → X) {a b : List κ} (h : a.Perm b)
    (hc : ∀ r ∈ a, ∀ s ∈ a, Function.Commute (U r) (U s)) :
    execute U a = execute U b := by
  funext x
  exact h.foldl_eq' (f := fun z r ↦ U r z) (fun r hr s hs z ↦ (hc r hr s hs z).symm) x

end Execution

variable {κ : Type*}

theorem execute_preserves (U : κ → BlockSum B → BlockSum B) (order : List κ)
    (i : ι) (h : ∀ r ∈ order, ∀ x, U r x i = x i) (x : BlockSum B) :
    execute U order x i = x i := by
  induction order generalizing x with
  | nil => rfl
  | cons r order ih =>
      exact (ih (fun s hs ↦ h s (List.mem_cons_of_mem r hs)) (U r x)).trans
        (h r List.mem_cons_self x)

theorem writeSupport_execute_subset (U : κ → BlockSum B → BlockSum B)
    (order : List κ) (W : κ → Set ι) (h : ∀ r ∈ order, writeSupport (U r) ⊆ W r) :
    writeSupport (execute U order) ⊆ ⋃ r ∈ order, W r := by
  rw [writeSupport_subset_iff]
  exact fun x i hi ↦ execute_preserves U order i
    (fun r hr z ↦ writeSupport_subset_iff.mp (h r hr) z i (by aesop)) x

theorem writeSupport_execute (U : κ → BlockSum B → BlockSum B) (order : List κ) :
    writeSupport (execute U order) ⊆ ⋃ r ∈ order, writeSupport (U r) :=
  writeSupport_execute_subset U order _ (fun _ _ ↦ Set.Subset.rfl)

/-- Select outputs from supplied write bounds. Under disjointness the owner is unique.
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

/-- Every enumeration of a commuting disjoint batch implements its snapshot merge. -/
theorem merge_eq_execute (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s))
    (hc : ∀ r ∈ K, ∀ s ∈ K, Function.Commute (U r) (U s))
    (order : List κ) (hn : order.Nodup) (he : ∀ r, r ∈ order ↔ r ∈ K) :
    merge U K W = execute U order := by
  classical
  funext x
  apply PiLp.ext
  intro i
  by_cases h : ∃ r, r ∈ K ∧ i ∈ W r
  · obtain ⟨r, hr, hi⟩ := h
    rw [merge_apply_of_mem U K W hd hr hi,
      execute_perm U (List.perm_cons_erase ((he r).mpr hr))
        (fun r hr s hs ↦ hc r ((he r).mp hr) s ((he s).mp hs)), execute_cons]
    exact (execute_preserves U (order.erase r) i (fun s hs z ↦
      writeSupport_subset_iff.mp (hb s ((he s).mp (List.mem_of_mem_erase hs))) z i
        (fun his ↦ Set.disjoint_left.mp
          (hd s ((he s).mp (List.mem_of_mem_erase hs)) r hr
            (hn.mem_erase_iff.mp hs).1) his hi)) (U r x)).symm
  · rw [merge_apply_of_not_mem U K W (by aesop)]
    exact (execute_preserves U order i (fun r hr z ↦
      writeSupport_subset_iff.mp (hb r ((he r).mp hr)) z i (by aesop)) x).symm

/-- The support bound for a batch can be reused when that batch is an execution step. -/
theorem writeSupport_merge_subset (U : κ → BlockSum B → BlockSum B) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s)) :
    writeSupport (merge U K W) ⊆ ⋃ r ∈ K, W r := by
  rw [writeSupport_merge U K W hb hd]
  exact Set.iUnion₂_mono hb

/-- On additive blocks, snapshot merging sums the changes computed from the original state. -/
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
