/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Block.Operator
import Vbd.Block.Update
import Vbd.Dynamics.Contraction
import Mathlib.Data.Matrix.Mul

/-!
# Comparison bounds for exact block executions

Comparison matrices have real nonnegative entries bounding whole-block operator norms.
Matrix multiplication and `List.prod` use the same convention as `Function.End`: the
rightmost factor acts first. Derivative factors are evaluated at the actual intermediate
states. `toMax` transports the finite `ℓ²` representation to Mathlib's dependent function
space with its maximum norm; no dimension-dependent norm conversion enters the certificate.
All block spaces may be heterogeneous and infinite-dimensional.
-/

namespace Vbd.BlockContraction

open scoped BigOperators

variable {ι : Type*} {B : ι → Type*} [Fintype ι] [DecidableEq ι]
  [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]

/-- The explicit change of norm used throughout this bridge. -/
noncomputable def toMax : BlockSum B ≃L[ℝ] ((i : ι) → B i) :=
  PiLp.continuousLinearEquiv 2 ℝ B

/-- A nonnegative matrix dominating all whole-block entries. Nonnegativity follows
from the norm bound, including for zero or trivial blocks. -/
def Dominates (C : Matrix ι ι ℝ) (A : BlockSum B →L[ℝ] BlockSum B) : Prop :=
  ∀ i j, ‖BlockSum.entry A i j‖ ≤ C i j

omit [Fintype ι] in
theorem Dominates.nonneg {C : Matrix ι ι ℝ} {A : BlockSum B →L[ℝ] BlockSum B}
    (h : Dominates C A) (i j : ι) : 0 ≤ C i j :=
  (norm_nonneg _).trans (h i j)

omit [Fintype ι] in
/-- Pointwise block-action bounds give a comparison matrix without a separate
operator-norm calculation in the model-specific layer. -/
theorem dominates_of_apply_bound {C : Matrix ι ι ℝ}
    {A : BlockSum B →L[ℝ] BlockSum B} (hC : ∀ i j, 0 ≤ C i j)
    (h : ∀ i j (v : B j), ‖BlockSum.entry A i j v‖ ≤ C i j * ‖v‖) :
    Dominates C A :=
  fun i j ↦ ContinuousLinearMap.opNorm_le_bound _ (hC i j) (h i j)

/-- Reconstruction gives a componentwise comparison before any global norm is chosen. -/
theorem Dominates.apply {C : Matrix ι ι ℝ} {A : BlockSum B →L[ℝ] BlockSum B}
    (h : Dominates C A) (x : BlockSum B) (i : ι) :
    ‖A x i‖ ≤ ∑ j, C i j * ‖x j‖ := by
  calc
    ‖A x i‖ = ‖∑ j, BlockSum.entry A i j (x j)‖ :=
      congrArg norm (BlockSum.apply_eq_sum_entry A x i)
    _ ≤ ∑ j, ‖BlockSum.entry A i j (x j)‖ := norm_sum_le _ _
    _ ≤ ∑ j, C i j * ‖x j‖ := Finset.sum_le_sum fun j _ ↦
      (ContinuousLinearMap.le_opNorm _ _).trans
        (mul_le_mul_of_nonneg_right (h i j) (norm_nonneg _))

/-- Comparison factors multiply in the same order as the linear operators. -/
theorem Dominates.comp {C D : Matrix ι ι ℝ}
    {A F : BlockSum B →L[ℝ] BlockSum B} (hC : Dominates C A) (hD : Dominates D F) :
    Dominates (C * D) (A.comp F) := by
  intro i j
  calc
    ‖BlockSum.entry (A.comp F) i j‖ =
        ‖∑ k, (BlockSum.entry A i k).comp (BlockSum.entry F k j)‖ :=
      congrArg norm (BlockSum.entry_comp A F i j)
    _ ≤ ∑ k, ‖(BlockSum.entry A i k).comp (BlockSum.entry F k j)‖ := norm_sum_le _ _
    _ ≤ ∑ k, C i k * D k j := Finset.sum_le_sum fun k _ ↦
      (ContinuousLinearMap.opNorm_comp_le _ _).trans
        (mul_le_mul (hC i k) (hD k j) (norm_nonneg _) (hC.nonneg i k))
    _ = (C * D) i j := rfl

/-- A row-sum certificate bounds the operator in the maximum norm, via explicit conjugation. -/
theorem Dominates.max_opNorm_le {C : Matrix ι ι ℝ}
    {A : BlockSum B →L[ℝ] BlockSum B} (h : Dominates C A) {q : ℝ}
    (hq : 0 ≤ q) (hrow : ∀ i, ∑ j, C i j ≤ q) :
    ‖(toMax (B := B)).toContinuousLinearMap.comp
      (A.comp (toMax (B := B)).symm.toContinuousLinearMap)‖ ≤ q := by
  apply ContinuousLinearMap.opNorm_le_bound _ hq
  intro x
  exact (pi_norm_le_iff_of_nonneg (mul_nonneg hq (norm_nonneg x))).mpr fun i ↦
    (h.apply ((toMax (B := B)).symm x) i).trans <|
      (Finset.sum_le_sum fun j _ ↦ mul_le_mul_of_nonneg_left
        (norm_le_pi_norm x j) (h.nonneg i j)).trans <|
      (Finset.sum_mul ..).symm.le.trans (mul_le_mul_of_nonneg_right (hrow i) (norm_nonneg x))

/-- Maximum-norm realization of a state map. Iteration results apply directly to this map. -/
noncomputable def maxMap (T : BlockSum B → BlockSum B) : ((i : ι) → B i) → ((i : ι) → B i) :=
  toMax ∘ T ∘ (toMax (B := B)).symm

open scoped NNReal

/-- Block derivative entries with uniformly bounded row sums certify a contraction estimate
on a convex region in the maximum-norm state space. Invariance is a separate obligation. -/
theorem lipschitzOnWith_of_block_derivative {T : BlockSum B → BlockSum B}
    {D : BlockSum B → BlockSum B →L[ℝ] BlockSum B}
    {S : Set ((i : ι) → B i)} {q : ℝ≥0}
    (hS : Convex ℝ S)
    (hD : ∀ x, toMax x ∈ S → HasFDerivAt T (D x) x)
    (C : BlockSum B → Matrix ι ι ℝ)
    (hC : ∀ x, toMax x ∈ S → Dominates (C x) (D x))
    (hrow : ∀ x, toMax x ∈ S → ∀ i, ∑ j, C x i j ≤ q) :
    LipschitzOnWith q (maxMap T) S := by
  apply Vbd.Contraction.lipschitzOnWith_of_derivative_bound hS
    (D := fun x ↦ (toMax (B := B)).toContinuousLinearMap.comp
      ((D ((toMax (B := B)).symm x)).comp (toMax (B := B)).symm.toContinuousLinearMap))
  · exact fun x hx ↦ ((toMax (B := B)).hasFDerivAt.comp x
      ((hD _ (by simpa using hx)).comp x
        (toMax (B := B)).symm.hasFDerivAt)).hasFDerivWithinAt
  · exact fun x hx ↦ (hC _ (by simpa using hx)).max_opNorm_le q.coe_nonneg
      (hrow _ (by simpa using hx))

omit [Fintype ι] in
/-- The identity comparison includes trivial block spaces. -/
theorem dominates_id : Dominates (1 : Matrix ι ι ℝ)
    (ContinuousLinearMap.id ℝ (BlockSum B)) := by
  intro i j
  by_cases h : i = j
  · subst j
    simpa only [BlockSum.entry_id_same, Matrix.one_apply_eq] using
      (ContinuousLinearMap.norm_id_le (𝕜 := ℝ) (E := B i))
  · simp [h, BlockSum.entry_id_of_ne h]

variable {κ : Type*}

/-- Derivative of an externally ordered execution. The list's rightmost update executes first,
as in `BlockUpdate`'s `Function.End` products. -/
noncomputable def orderedDerivative (U : κ → Function.End (BlockSum B))
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B) :
    List κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B
  | [], _ => ContinuousLinearMap.id ℝ _
  | r :: rs, x => (D r ((rs.map U).prod x)).comp (orderedDerivative U D rs x)

omit [Fintype ι] [DecidableEq ι] [∀ i, NormedAddCommGroup (B i)]
  [∀ i, NormedSpace ℝ (B i)] in
/-- Intermediate states stay in a supplied region preserved by every executed factor. -/
theorem prod_mapsTo (U : κ → Function.End (BlockSum B)) (order : List κ)
    {R : Set (BlockSum B)} (hU : ∀ r ∈ order, Set.MapsTo (U r) R R) :
    Set.MapsTo (order.map U).prod R R := by
  induction order with
  | nil => exact fun _ hx ↦ hx
  | cons r rs ih =>
      exact (hU r List.mem_cons_self).comp (ih (fun s hs ↦ hU s (List.mem_cons_of_mem r hs)))

omit [Fintype ι] [DecidableEq ι] in
/-- Chain rule for the actual externally ordered execution on an invariant region. -/
theorem hasFDerivAt_prod [Finite ι] (U : κ → Function.End (BlockSum B))
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B)
    (order : List κ) {R : Set (BlockSum B)}
    (hU : ∀ r ∈ order, Set.MapsTo (U r) R R)
    (hD : ∀ r ∈ order, ∀ x ∈ R, HasFDerivAt (U r) (D r x) x)
    {x : BlockSum B} (hx : x ∈ R) :
    HasFDerivAt (order.map U).prod (orderedDerivative U D order x) x := by
  let := Fintype.ofFinite ι
  induction order with
  | nil => simpa [orderedDerivative, Function.End.one_def] using hasFDerivAt_id x
  | cons r rs ih =>
      exact (hD r List.mem_cons_self _
        (prod_mapsTo U rs (fun s hs ↦ hU s (List.mem_cons_of_mem r hs)) hx)).comp x
        (ih (fun s hs ↦ hU s (List.mem_cons_of_mem r hs))
          (fun s hs ↦ hD s (List.mem_cons_of_mem r hs)))

/-- Uniform factor comparisons propagate through execution at intermediate states. -/
theorem dominates_orderedDerivative (U : κ → Function.End (BlockSum B))
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B)
    (C : κ → Matrix ι ι ℝ) (order : List κ) {R : Set (BlockSum B)}
    (hU : ∀ r ∈ order, Set.MapsTo (U r) R R)
    (hC : ∀ r ∈ order, ∀ x ∈ R, Dominates (C r) (D r x))
    {x : BlockSum B} (hx : x ∈ R) :
    Dominates (order.map C).prod (orderedDerivative U D order x) := by
  induction order with
  | nil => exact dominates_id
  | cons r rs ih =>
      exact (hC r List.mem_cons_self _
        (prod_mapsTo U rs (fun s hs ↦ hU s (List.mem_cons_of_mem r hs)) hx)).comp
        (ih (fun s hs ↦ hU s (List.mem_cons_of_mem r hs))
          (fun s hs ↦ hC s (List.mem_cons_of_mem r hs)))

/-- Exact serial execution certificate. The region is stated in the maximum norm;
each supplied update must preserve it, and the ordered matrix product must have row sums ≤ `q`.
For `q < 1` this is the contraction premise of the generic dynamics foundation. -/
theorem lipschitzOnWith_prod (U : κ → Function.End (BlockSum B))
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B)
    (C : κ → Matrix ι ι ℝ) (order : List κ)
    {S : Set ((i : ι) → B i)} {q : ℝ≥0} (hS : Convex ℝ S)
    (hU : ∀ r ∈ order, Set.MapsTo (U r) (toMax ⁻¹' S) (toMax ⁻¹' S))
    (hD : ∀ r ∈ order, ∀ x, toMax x ∈ S → HasFDerivAt (U r) (D r x) x)
    (hC : ∀ r ∈ order, ∀ x, toMax x ∈ S → Dominates (C r) (D r x))
    (hrow : ∀ i, ∑ j, (order.map C).prod i j ≤ q) :
    LipschitzOnWith q (maxMap (order.map U).prod) S :=
  lipschitzOnWith_of_block_derivative hS
    (fun _ hx ↦ hasFDerivAt_prod U D order hU hD hx)
    (fun _ ↦ (order.map C).prod)
    (fun _ hx ↦ dominates_orderedDerivative U D C order hU hC hx)
    (fun _ _ ↦ hrow)

omit [DecidableEq ι] in
/-- Commuting disjoint-write batches inherit the bound of any supplied enumeration.
The hypotheses are algebraic; physical locality discharges them in the production layer. -/
theorem lipschitzOnWith_merge (U : κ → Function.End (BlockSum B)) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, BlockUpdate.writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s))
    (hc : ∀ r ∈ K, ∀ s ∈ K, Function.Commute (U r) (U s))
    (order : List κ) (hn : order.Nodup) (he : ∀ r, r ∈ order ↔ r ∈ K)
    {S : Set ((i : ι) → B i)} {q : ℝ≥0}
    (h : LipschitzOnWith q (maxMap (order.map U).prod) S) :
    LipschitzOnWith q (maxMap (BlockUpdate.merge U K W)) S := by
  simpa only [BlockUpdate.merge_eq_prod U K W hb hd hc order hn he] using h

omit [Fintype ι] [DecidableEq ι] in
/-- The derivative of a commuting merge is the ordered derivative for every enumeration. -/
theorem hasFDerivAt_merge [Finite ι] (U : κ → Function.End (BlockSum B)) (K : Finset κ)
    (W : κ → Set ι) (hb : ∀ r ∈ K, BlockUpdate.writeSupport (U r) ⊆ W r)
    (hd : ∀ r ∈ K, ∀ s ∈ K, r ≠ s → Disjoint (W r) (W s))
    (hc : ∀ r ∈ K, ∀ s ∈ K, Function.Commute (U r) (U s))
    (order : List κ) (hn : order.Nodup) (he : ∀ r, r ∈ order ↔ r ∈ K)
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B) {R : Set (BlockSum B)}
    (hU : ∀ r ∈ order, Set.MapsTo (U r) R R)
    (hD : ∀ r ∈ order, ∀ x ∈ R, HasFDerivAt (U r) (D r x) x)
    {x : BlockSum B} (hx : x ∈ R) :
    HasFDerivAt (BlockUpdate.merge U K W) (orderedDerivative U D order x) x := by
  simpa only [BlockUpdate.merge_eq_prod U K W hb hd hc order hn he] using
    hasFDerivAt_prod U D order hU hD hx

section RowSums

omit [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]

omit [DecidableEq ι] in
/-- Row sums commute with multiplication by a comparison matrix. -/
theorem rowSum_mul (C F : Matrix ι ι ℝ) (i : ι) :
    ∑ j, (C * F) i j = ∑ k, C i k * ∑ j, F k j := by
  exact (Finset.sum_comm).trans (by simp only [Finset.mul_sum])

omit [DecidableEq ι] in
/-- Nonnegative comparisons preserve a uniform row-sum bound under multiplication. -/
theorem rowSum_mul_le {C F : Matrix ι ι ℝ} {b : ℝ}
    (hC : ∀ i j, 0 ≤ C i j) (hF : ∀ i, ∑ j, F i j ≤ b) (i : ι) :
    ∑ j, (C * F) i j ≤ (∑ k, C i k) * b := by
  calc
    ∑ j, (C * F) i j = ∑ k, C i k * ∑ j, F k j := rowSum_mul C F i
    _ ≤ ∑ k, C i k * b := Finset.sum_le_sum fun k _ ↦
      mul_le_mul_of_nonneg_left (hF k) (hC i k)
    _ = (∑ k, C i k) * b := (Finset.sum_mul ..).symm

/-- An identity row preserves the corresponding row of every later product. -/
theorem rowSum_mul_of_identity_row {C F : Matrix ι ι ℝ} {i : ι}
    (h : ∀ j, C i j = (1 : Matrix ι ι ℝ) i j) :
    ∑ j, (C * F) i j = ∑ j, F i j := by
  simp [Matrix.mul_apply, h, Matrix.one_apply]

/-- A changed-row comparison is nonnegative, preserves unwritten rows exactly, and
has the supplied bound on each written row. A batch may write several whole blocks. -/
structure RowStep (C : Matrix ι ι ℝ) (W : Set ι) (q : ℝ) : Prop where
  nonneg : ∀ i j, 0 ≤ C i j
  unchanged : ∀ i, i ∉ W → ∀ j, C i j = (1 : Matrix ι ι ℝ) i j
  changed : ∀ i, i ∈ W → ∑ j, C i j ≤ q

/-- Every prefix remains nonexpansive, and every row visited by the execution has
bound `q`. Repeated visits are permitted; complete coverage gives a strict sweep
certificate when `q < 1`. -/
theorem rowSum_prod_of_steps (C : κ → Matrix ι ι ℝ) (W : κ → Set ι)
    (order : List κ) {q : ℝ} (hq : q ≤ 1)
    (hstep : ∀ r ∈ order, RowStep (C r) (W r) q) :
    (∀ i, ∑ j, (order.map C).prod i j ≤ 1) ∧
      (∀ i, (∃ r ∈ order, i ∈ W r) → ∑ j, (order.map C).prod i j ≤ q) := by
  induction order with
  | nil => simp [Matrix.one_apply]
  | cons r rs ih =>
      have ht := ih (fun s hs ↦ hstep s (List.mem_cons_of_mem r hs))
      have hhead := hstep r List.mem_cons_self
      classical
      have hb : ∀ i, ∑ j, C r i j ≤ 1 := fun i ↦
        if hi : i ∈ W r then (hhead.changed i hi).trans hq
        else by simp [hhead.unchanged i hi, Matrix.one_apply]
      refine ⟨fun i ↦ ?_, fun i hi ↦ ?_⟩
      · simpa only [List.map_cons, List.prod_cons, mul_one] using
          (rowSum_mul_le hhead.nonneg ht.1 i).trans (by simpa using hb i)
      · by_cases hmem : i ∈ W r
        · simpa only [List.map_cons, List.prod_cons, mul_one] using
            (rowSum_mul_le hhead.nonneg ht.1 i).trans
              (by simpa using hhead.changed i hmem)
        · simpa only [List.map_cons, List.prod_cons,
            rowSum_mul_of_identity_row (hhead.unchanged i hmem)] using
              ht.2 i (by aesop)

/-- Covering every block turns changed-row bounds into a full maximum-norm bound. -/
theorem rowSum_prod_le_of_cover (C : κ → Matrix ι ι ℝ) (W : κ → Set ι)
    (order : List κ) {q : ℝ} (hq : q ≤ 1)
    (hstep : ∀ r ∈ order, RowStep (C r) (W r) q)
    (hcover : ∀ i, ∃ r ∈ order, i ∈ W r) :
    ∀ i, ∑ j, (order.map C).prod i j ≤ q :=
  fun i ↦ (rowSum_prod_of_steps C W order hq hstep).2 i (hcover i)

end RowSums

/-- Complete serial or batch execution contracts when each changed row has sum at most
`q < 1` and the execution covers all blocks. The operators may write multiple blocks,
and need not commute. For proper-color batches use `hasFDerivAt_merge` to supply `hD`. -/
theorem lipschitzOnWith_prod_of_cover (U : κ → Function.End (BlockSum B))
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B)
    (C : κ → Matrix ι ι ℝ) (W : κ → Set ι) (order : List κ)
    {S : Set ((i : ι) → B i)} {q : ℝ≥0} (hq : q < 1) (hS : Convex ℝ S)
    (hU : ∀ r ∈ order, Set.MapsTo (U r) (toMax ⁻¹' S) (toMax ⁻¹' S))
    (hD : ∀ r ∈ order, ∀ x, toMax x ∈ S → HasFDerivAt (U r) (D r x) x)
    (hC : ∀ r ∈ order, ∀ x, toMax x ∈ S → Dominates (C r) (D r x))
    (hstep : ∀ r ∈ order, RowStep (C r) (W r) q)
    (hcover : ∀ i, ∃ r ∈ order, i ∈ W r) :
    LipschitzOnWith q (maxMap (order.map U).prod) S :=
  lipschitzOnWith_prod U D C order hS hU hD hC
    (rowSum_prod_le_of_cover C W order (NNReal.coe_le_coe.mpr hq.le) hstep hcover)

omit [Fintype ι] [DecidableEq ι] in
/-- Forward invariance transports through the same explicit change of norm. -/
theorem mapsTo_maxMap {T : BlockSum B → BlockSum B} {S : Set ((i : ι) → B i)}
    (h : Set.MapsTo T (toMax ⁻¹' S) (toMax ⁻¹' S)) : Set.MapsTo (maxMap T) S S :=
  fun x hx ↦ h (show toMax ((toMax (B := B)).symm x) ∈ S by simpa using hx)

omit [Fintype ι] [DecidableEq ι] in
/-- Equal execution maps have equal ordered derivatives. In particular, two enumerations
of a commuting merge have the same derivative, by `BlockUpdate.merge_eq_prod`. -/
theorem orderedDerivative_eq_of_prod_eq [Finite ι]
    (U : κ → Function.End (BlockSum B))
    (D : κ → BlockSum B → BlockSum B →L[ℝ] BlockSum B)
    (a b : List κ) {R : Set (BlockSum B)}
    (hUa : ∀ r ∈ a, Set.MapsTo (U r) R R)
    (hUb : ∀ r ∈ b, Set.MapsTo (U r) R R)
    (hDa : ∀ r ∈ a, ∀ x ∈ R, HasFDerivAt (U r) (D r x) x)
    (hDb : ∀ r ∈ b, ∀ x ∈ R, HasFDerivAt (U r) (D r x) x)
    (heq : (a.map U).prod = (b.map U).prod) {x : BlockSum B} (hx : x ∈ R) :
    orderedDerivative U D a x = orderedDerivative U D b x := by
  let := Fintype.ofFinite ι
  exact (show HasFDerivAt (b.map U).prod (orderedDerivative U D a x) x from
    heq ▸ hasFDerivAt_prod U D a hUa hDa hx).unique (hasFDerivAt_prod U D b hUb hDb hx)

omit [Fintype ι] [DecidableEq ι] in
/-- Iteration in the maximum norm represents the original execution at every finite budget. -/
theorem iterate_maxMap (T : BlockSum B → BlockSum B) (k : ℕ) (x : BlockSum B) :
    (maxMap T)^[k] (toMax x) = toMax (T^[k] x) :=
  ((show Function.Semiconj (toMax (B := B)) T (maxMap T) from
    fun _ ↦ by simp [maxMap]).iterate_right k x).symm

end Vbd.BlockContraction
