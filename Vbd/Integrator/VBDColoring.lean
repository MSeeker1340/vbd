/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Integrator.LocalPotential
import Vbd.Integrator.VBDNonlinear

/-!
# Proper-color production VBD

Component-local Newton data read only the visited block and the supports containing it.
Local potentials with differentiable gradients and block-diagonal inertia supply this locality.
Proper colors separate these reads from other same-color writes. The resulting
commutation includes determinant-threshold skipping and identifies buffered passes with their
serial enumerations. Curvature and contraction remain separate hypotheses.
-/

noncomputable section

namespace Vbd

variable {ι : Type*} {B : ι → Type*}

/-- The blocks read by a component-based local system at `i`, including its inertial block. -/
def componentNeighborhood (A : Finset (Finset ι)) (i : ι) : Set ι :=
  {k | k = i ∨ ∃ S ∈ A, i ∈ S ∧ k ∈ S}

namespace LocalPotential

section Algebra

variable [DecidableEq ι] [∀ i, AddCommGroup (B i)]

/-- The local energy increment depends only on the supports containing the visited block. -/
theorem energy_increment_eq (P : LocalPotential (B := B)) {i : ι} {x z : BlockSum B}
    (h : ∀ k, k ∈ componentNeighborhood P.supports i → x k = z k) (v : B i) :
    P.energy (x + BlockSum.inject i v) - P.energy x =
      P.energy (z + BlockSum.inject i v) - P.energy z := by
  have hx : AgreeOff {i} x (x + BlockSum.inject i v) := by
    intro k hk
    simp only [Finset.mem_singleton] at hk
    change x k = x k + BlockSum.inject i v k
    rw [BlockSum.inject_apply_of_ne hk, add_zero]
  have hz : AgreeOff {i} z (z + BlockSum.inject i v) := by
    intro k hk
    simp only [Finset.mem_singleton] at hk
    change z k = z k + BlockSum.inject i v k
    rw [BlockSum.inject_apply_of_ne hk, add_zero]
  rw [P.energy_sub_eq_sum_affected hx, P.energy_sub_eq_sum_affected hz]
  apply Finset.sum_congr rfl
  intro S hS
  have hs : S ∈ P.supports ∧ i ∈ S := by
    simpa [affectedSupports] using hS
  have he : P.component S x = P.component S z :=
    P.component_local S hs.1 (fun k hk ↦ h k (Or.inr ⟨S, hs.1, hs.2, hk⟩))
  have he' : P.component S (x + BlockSum.inject i v) =
      P.component S (z + BlockSum.inject i v) := by
    apply P.component_local S hs.1
    intro k hk
    simp only [WithLp.ofLp_add, Pi.add_apply, h k (Or.inr ⟨S, hs.1, hs.2, hk⟩)]
  rw [he, he']

end Algebra

section Calculus

open scoped Gradient InnerProductSpace

variable [Fintype ι] [DecidableEq ι] [∀ i, NormedAddCommGroup (B i)]
  [∀ i, InnerProductSpace ℝ (B i)] [∀ i, CompleteSpace (B i)]

omit [DecidableEq ι] in
/-- Support-local energy increments determine the same block gradient at agreeing states. -/
theorem gradient_apply_eq (P : LocalPotential (B := B))
    (hE : Differentiable ℝ P.energy) {i : ι} {x z : BlockSum B}
    (h : ∀ k, k ∈ componentNeighborhood P.supports i → x k = z k) :
    (∇ P.energy x) i = (∇ P.energy z) i := by
  classical
  have hd : ∀ w : BlockSum B,
      HasFDerivAt (fun v : B i ↦ P.energy (w + BlockSum.inclusion (𝕜 := ℝ) i v) - P.energy w)
        (((InnerProductSpace.toDual ℝ (BlockSum B)) (∇ P.energy w)).comp
          (BlockSum.inclusion i)) 0 := by
    intro w
    convert (((hE (w + BlockSum.inclusion (𝕜 := ℝ) i 0)).hasGradientAt.hasFDerivAt).comp
      (0 : B i) ((BlockSum.inclusion (𝕜 := ℝ) i).hasFDerivAt.const_add w)).sub_const
        (P.energy w) using 1
    all_goals first | rfl | simp only [map_zero, add_zero]
  have he : (fun v : B i ↦ P.energy (x + BlockSum.inclusion (𝕜 := ℝ) i v) - P.energy x) =
      (fun v : B i ↦ P.energy (z + BlockSum.inclusion (𝕜 := ℝ) i v) - P.energy z) :=
    funext fun v ↦ P.energy_increment_eq h v
  have he' := (he ▸ hd x).unique (hd z)
  apply ext_inner_right ℝ
  intro v
  have hv := congrArg (fun L : B i →L[ℝ] ℝ ↦ L v) he'
  have hs : ∀ w : BlockSum B, inner ℝ w (BlockSum.inject i v) = inner ℝ (w i) v := by
    intro w
    rw [PiLp.inner_apply, Finset.sum_eq_single i]
    · rw [BlockSum.inject_apply_same]
    · intro k _ hk
      rw [BlockSum.inject_apply_of_ne hk, inner_zero_right]
    · simp
  change inner ℝ (∇ P.energy x) (BlockSum.inject i v) =
    inner ℝ (∇ P.energy z) (BlockSum.inject i v) at hv
  simpa only [hs] using hv

/-- Differentiating the local block gradient identifies the local diagonal Hessian reads. -/
theorem hessian_entry_eq (P : LocalPotential (B := B))
    (hE : Differentiable ℝ P.energy) (hG : Differentiable ℝ (∇ P.energy))
    {i : ι} {x z : BlockSum B}
    (h : ∀ k, k ∈ componentNeighborhood P.supports i → x k = z k) :
    BlockSum.entry (ImplicitEulerStep.hessian P.energy x) i i =
      BlockSum.entry (ImplicitEulerStep.hessian P.energy z) i i := by
  have hs : (fun v : B i ↦ (∇ P.energy (x + BlockSum.inclusion (𝕜 := ℝ) i v)) i) =
      (fun v : B i ↦ (∇ P.energy (z + BlockSum.inclusion (𝕜 := ℝ) i v)) i) := by
    funext v
    apply P.gradient_apply_eq hE
    intro k hk
    simp only [WithLp.ofLp_add, Pi.add_apply, h k hk]
  have hd : ∀ w : BlockSum B,
      HasFDerivAt (fun v : B i ↦ (∇ P.energy (w + BlockSum.inclusion (𝕜 := ℝ) i v)) i)
        (BlockSum.entry (ImplicitEulerStep.hessian P.energy w) i i) 0 := by
    intro w
    convert (((BlockSum.projection i : BlockSum B →L[ℝ] B i).hasFDerivAt.comp
      (w + BlockSum.inclusion (𝕜 := ℝ) i 0) (hG _).hasFDerivAt).comp (0 : B i)
        ((BlockSum.inclusion (𝕜 := ℝ) i).hasFDerivAt.const_add w)) using 1
    all_goals first | rfl | (simp only [map_zero, add_zero]; rfl)
  exact (hs ▸ hd x).unique (hd z)

end Calculus
end LocalPotential

namespace BlockNewtonData

variable [DecidableEq ι] [∀ i, NormedAddCommGroup (B i)] [∀ i, NormedSpace ℝ (B i)]
  [∀ i, FiniteDimensional ℝ (B i)] (d : BlockNewtonData B)

/-- The residual and solve matrix of each visit depend only on its component neighborhood. -/
def LocalOn (A : Finset (Finset ι)) : Prop :=
  ∀ i ⦃x z : BlockSum B⦄, (∀ k, k ∈ componentNeighborhood A i → x k = z k) →
    d.residual x i = d.residual z i ∧ d.diagonal i x = d.diagonal i z

/-- Changing an unread block preserves the output of this production visit, including skips. -/
theorem update_apply_replace_of_local {A : Finset (Finset ι)} (hl : d.LocalOn A)
    {i j : ι} (hj : j ∉ componentNeighborhood A i) (x : BlockSum B) (v : B j) :
    d.update i (BlockSum.replace x j v) i = d.update i x i := by
  have hji : i ≠ j := fun h ↦ hj (h ▸ Or.inl rfl)
  have he := hl i (x := BlockSum.replace x j v) (z := x)
    (fun k hk ↦ BlockSum.replace_apply_of_ne x
      (show k ≠ j from fun h ↦ hj (h ▸ hk)) v)
  have hr : d.Regular i (BlockSum.replace x j v) ↔ d.Regular i x := by
    simp only [Regular, he.2]
  by_cases hreg : d.Regular i x
  · simp [update, hr, hreg, he.1, he.2, hji]
  · simp [update, hr, hreg, hji]

/-- Every production visit is replacement by its computed output, on either skip branch. -/
theorem update_eq_replace_output (i : ι) (x : BlockSum B) :
    d.update i x = BlockSum.replace x i (d.update i x i) := by
  apply PiLp.ext
  intro k
  by_cases hk : k = i
  · subst k; simp
  · simp [hk]

/-- Distinct visits that do not read each other's blocks commute on both production branches. -/
theorem commute_of_local {A : Finset (Finset ι)} (hl : d.LocalOn A) {i j : ι}
    (hji : j ∉ componentNeighborhood A i) (hij : i ∉ componentNeighborhood A j) :
    Function.Commute (d.update i) (d.update j) := by
  have hne : i ≠ j := fun h ↦ hji (h ▸ Or.inl rfl)
  intro x
  apply PiLp.ext
  intro k
  by_cases hki : k = i
  · subst k
    rw [d.update_apply_of_ne j _ hne, d.update_eq_replace_output j x,
      d.update_apply_replace_of_local hl hji]
  · by_cases hkj : k = j
    · subst k
      rw [d.update_apply_of_ne i _ (Ne.symm hne), d.update_eq_replace_output i x,
        d.update_apply_replace_of_local hl hij]
    · simp only [d.update_apply_of_ne _ _ hki, d.update_apply_of_ne _ _ hkj]

/-- Proper component colors discharge the production commutation premise. -/
theorem commute_of_same_color {A : Finset (Finset ι)} (hl : d.LocalOn A) {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) {i j : ι} (hc : c i = c j) :
    Function.Commute (d.update i) (d.update j) := by
  by_cases h : i = j
  · subst j; exact Function.Commute.refl _
  · apply d.commute_of_local hl
    · rintro (he | ⟨S, hS, hi, hj⟩)
      · exact h he.symm
      · exact h (coloring_injectiveOnSupports c hS hi hj hc)
    · rintro (he | ⟨S, hS, hj, hi⟩)
      · exact h he
      · exact h (coloring_injectiveOnSupports c hS hi hj hc)

/-- A proper-color snapshot pass equals every once-per-vertex serial enumeration of that pass. -/
theorem batch_eq_serial_of_color {A : Finset (Finset ι)} (hl : d.LocalOn A) {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (color : Fin m) (vertices : Finset ι)
    (hv : ∀ i ∈ vertices, c i = color) (order : List ι) (hn : order.Nodup)
    (he : ∀ i, i ∈ order ↔ i ∈ vertices) : d.batch vertices = d.serial order :=
  d.batch_eq_serial vertices order hn he (fun i hi j hj ↦
    d.commute_of_same_color hl c ((hv i hi).trans (hv j hj).symm))

/-- Concatenating chronological orders composes their executions in the same chronology. -/
theorem serial_append (first second : List ι) :
    d.serial (first ++ second) = d.serial second ∘ d.serial first := by
  simp only [serial, List.reverse_append, List.map_append, List.prod_append]
  rfl

/-- Buffered proper-color passes equal the chronological concatenation of their enumerations. -/
theorem buffered_eq_serial_of_color {A : Finset (Finset ι)} (hl : d.LocalOn A) {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (orders : List (List ι))
    (hn : ∀ order ∈ orders, order.Nodup)
    (hc : ∀ order ∈ orders, ∃ color : Fin m, ∀ i ∈ order, c i = color) :
    d.buffered (orders.map List.toFinset) = d.serial orders.flatten := by
  induction orders with
  | nil => rfl
  | cons order orders ih =>
    obtain ⟨color, hcolor⟩ := hc order List.mem_cons_self
    have he := d.batch_eq_serial_of_color hl c color order.toFinset
      (fun i hi ↦ hcolor i (List.mem_toFinset.mp hi)) order
      (hn order List.mem_cons_self) (fun i ↦ List.mem_toFinset.symm)
    funext x
    simp only [List.map_cons, buffered_cons, List.flatten_cons, serial_append,
      he]
    exact congrFun (ih (fun l hl ↦ hn l (List.mem_cons_of_mem order hl))
      (fun l hl ↦ hc l (List.mem_cons_of_mem order hl))) _

section FiniteColors

variable [Fintype ι]

/-- The buffered vertices of one numbered Mathlib color class. -/
def colorVertices {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (color : Fin m) : Finset ι :=
  Finset.univ.filter fun i ↦ c i = color

/-- One serial enumeration per supplied color, used to compare the buffered execution. -/
def colorOrders {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m)) : List (List ι) :=
  colors.map fun color ↦ (colorVertices c color).toList

/-- Proper-color production execution retains the externally supplied chronological color order. -/
def colored {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m)) :
    Function.End (BlockSum B) := d.buffered (colors.map (colorVertices c))

/-- Every proper-color buffered execution has its exact serial interpretation. -/
theorem colored_eq_serial {A : Finset (Finset ι)} (hl : d.LocalOn A) {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m)) :
    d.colored c colors = d.serial (colorOrders c colors).flatten := by
  have he := d.buffered_eq_serial_of_color hl c (colorOrders c colors)
    (by intro order ho; obtain ⟨color, _, rfl⟩ := List.mem_map.mp ho; exact Finset.nodup_toList _)
    (by
      intro order ho
      obtain ⟨color, _, rfl⟩ := List.mem_map.mp ho
      exact ⟨color, fun i hi ↦ (Finset.mem_filter.mp (Finset.mem_toList.mp hi)).2⟩)
  simpa only [colored, colorOrders, List.map_map, Function.comp_def, Finset.toList_toFinset]
    using he

omit [DecidableEq ι] in
/-- Covering every numbered color covers every block in the corresponding serial interpretation. -/
theorem mem_flatten_colorOrders {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m))
    (hcover : ∀ color, color ∈ colors) (i : ι) : i ∈ (colorOrders c colors).flatten := by
  classical
  apply List.mem_flatten.mpr
  refine ⟨(colorVertices c (c i)).toList, List.mem_map.mpr ⟨c i, hcover _, rfl⟩, ?_⟩
  simp [colorVertices]

omit [DecidableEq ι] in
/-- Distinct numbered color classes write disjoint block sets. -/
theorem colorVertices_disjoint {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) {r s : Fin m} (hrs : r ≠ s) :
    Disjoint (colorVertices c r) (colorVertices c s) := by
  classical
  apply Finset.disjoint_left.mpr
  intro i hi hj
  exact hrs ((Finset.mem_filter.mp hi).2.symm.trans (Finset.mem_filter.mp hj).2)

/-- A complete once-per-color plan fixes exactly the residual roots on the regular branch.
This consistency result is independent of component locality and contraction. -/
theorem colored_fixed_iff_residual_eq_zero {A : Finset (Finset ι)} {m : ℕ}
    (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m)) (hn : colors.Nodup)
    (hcover : ∀ color, color ∈ colors) (x : BlockSum B) (hreg : ∀ i, d.Regular i x) :
    d.colored c colors x = x ↔ d.residual x = 0 := by
  apply d.buffered_fixed_iff_residual_eq_zero _ _ _ x hreg
  · exact List.pairwise_map.mpr (hn.imp fun h ↦ colorVertices_disjoint c h)
  · intro i
    exact ⟨colorVertices c (c i), List.mem_map.mpr ⟨c i, hcover _, rfl⟩, by
      simp [colorVertices]⟩

end FiniteColors

end BlockNewtonData

namespace ImplicitEulerStep

open scoped Gradient

variable [Fintype ι] [DecidableEq ι] [∀ i, NormedAddCommGroup (B i)]
  [∀ i, InnerProductSpace ℝ (B i)] [∀ i, CompleteSpace (B i)]
  [∀ i, FiniteDimensional ℝ (B i)]

/-- Block-diagonal inertia and support-local potential energy give the actual Newton read sets.
This locality certificate requires no curvature, regularity, or contraction assumptions. -/
theorem blockNewtonData_localOn (ie : ImplicitEulerStep (BlockSum B))
    (P : LocalPotential (B := B)) (hE : ie.E = P.energy)
    (hM : ∀ i j, i ≠ j → BlockSum.entry ie.M i j = 0) (threshold : NNReal) :
    (ie.blockNewtonData threshold).LocalOn P.supports := by
  have hD : Differentiable ℝ P.energy := hE ▸ ie.E_differentiable
  have hG : Differentiable ℝ (∇ P.energy) := hE ▸ ie.gradient_differentiable
  intro i x z h
  have hrow : ∀ w : BlockSum B, ie.M w i = BlockSum.entry ie.M i i (w i) := by
    intro w
    rw [BlockSum.apply_eq_sum_entry, Finset.sum_eq_single i]
    · intro j _ hj
      rw [hM i j (Ne.symm hj), zero_apply]
    · simp
  constructor
  · change ie.energyGradient x i = ie.energyGradient z i
    simp only [energyGradient, inertiaGradient, WithLp.ofLp_add, WithLp.ofLp_smul,
      Pi.add_apply, Pi.smul_apply, hrow, WithLp.ofLp_sub, Pi.sub_apply,
      h i (Or.inl rfl), hE, P.gradient_apply_eq hD h]
  · simp only [blockNewtonData_diagonal, potentialHessian, hE, P.hessian_entry_eq hD hG h]

end ImplicitEulerStep

end Vbd
