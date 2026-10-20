/-
Copyright (c) 2026 VBD Formalization Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: VBD contributors
-/
import Vbd.Examples.AxialSpringNeighborhood
import Vbd.Integrator.VBDColoring

/-!
# Proper-color axial-spring execution

Spring supports determine every read of the polynomial residual and its exact Newton block.
Proper component colors therefore commute, including on the production skip branch. Buffered
color execution inherits the uniform nonlinear serial bound on the accepted box. The finite
nearest-neighbor chain has an explicit even/odd Mathlib coloring.
-/

noncomputable section

open scoped NNReal

namespace Vbd.AxialSpring

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [DecidableEq ι] in
/-- Spring component supports determine both actual local Newton inputs. -/
theorem newtonData_localOn (a : ι → ℝ) (b : Matrix ι ι ℝ) (η : ℝ) (y : State ι)
    (threshold : ℝ≥0) (A : Finset (Finset ι))
    (hs : ∀ i j, b i j ≠ 0 → ∃ S ∈ A, i ∈ S ∧ j ∈ S) :
    (newtonData a b η y threshold).LocalOn A := by
  classical
  intro i x z h
  have hi : x i = z i := h i (Or.inl rfl)
  have he : ∀ j, b i j ≠ 0 → x j = z j := by
    intro j hj
    obtain ⟨S, hS, hiS, hjS⟩ := hs i j hj
    exact h j (Or.inr ⟨S, hS, hiS, hjS⟩)
  constructor
  · change a i * (x i - y i) + ∑ j, b i j * ((x i - x j) + η * (x i - x j) ^ 3) =
      a i * (z i - y i) + ∑ j, b i j * ((z i - z j) + η * (z i - z j) ^ 3)
    congr 1
    · rw [hi]
    · apply Finset.sum_congr rfl
      intro j _
      by_cases hj : b i j = 0
      · simp [hj]
      · rw [hi, he j hj]
  · change diagonal a b η x i • ContinuousLinearMap.id ℝ ℝ =
      diagonal a b η z i • ContinuousLinearMap.id ℝ ℝ
    congr 1
    apply congrArg (a i + ·)
    apply Finset.sum_congr rfl
    intro j _
    by_cases hj : b i j = 0
    · simp [stiffness, hj]
    · simp only [stiffness, hi, he j hj]

/-- Proper-color buffered sweeps inherit the AP-03 nonlinear serial contraction factor. -/
theorem lipschitzOnWith_colored {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hzero : ∀ i, b i i = 0)
    (hη : 0 ≤ η) (hη1 : η ≤ 1) (hrow : ∀ i, ∑ j, b i j ≤ a i / 2)
    (hy : ∀ i, |y i| ≤ 1 / 20) (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (A : Finset (Finset ι)) (hs : ∀ i j, b i j ≠ 0 → ∃ S ∈ A, i ∈ S ∧ j ∈ S)
    {m : ℕ} (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m))
    (hcover : ∀ color, color ∈ colors) :
    LipschitzOnWith (318 / 625 : ℝ≥0)
      (BlockContraction.maxMap ((newtonData a b η y threshold).colored c colors)) stateBox := by
  rw [BlockNewtonData.colored_eq_serial _ (newtonData_localOn a b η y threshold A hs)]
  exact lipschitzOnWith_serial ha hb hzero hη hη1 hrow hy threshold ht _
    (BlockNewtonData.mem_flatten_colorOrders c colors hcover)

/-- Proper-color buffered sweeps preserve the same nonlinear box as their serial interpretation. -/
theorem colored_preserves_box {a : ι → ℝ} {b : Matrix ι ι ℝ} {η : ℝ} {y : State ι}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hy : ∀ i, |y i| ≤ 1 / 20)
    (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (A : Finset (Finset ι)) (hs : ∀ i j, b i j ≠ 0 → ∃ S ∈ A, i ∈ S ∧ j ∈ S)
    {m : ℕ} (c : (componentGraph A).Coloring (Fin m)) (colors : List (Fin m)) :
    Set.MapsTo (BlockContraction.maxMap ((newtonData a b η y threshold).colored c colors))
      stateBox stateBox := by
  rw [BlockNewtonData.colored_eq_serial _ (newtonData_localOn a b η y threshold A hs)]
  exact serial_preserves_box ha hb hη hη1 hrow hy threshold ht _

/-- The component supports of the finite nearest-neighbor chain. -/
def chainSupports (n : ℕ) : Finset (Finset (Fin n)) :=
  (Finset.univ.filter fun e : Fin n × Fin n ↦ e.1.val + 1 = e.2.val).image
    (fun e ↦ {e.1, e.2})

/-- Even and odd chain vertices have numbered colors `0` and `1`. -/
def parityColor (n : ℕ) (i : Fin n) : Fin 2 := ⟨i.val % 2, Nat.mod_lt _ (by decide)⟩

/-- Neighboring chain vertices have different parity, so every edge support is properly colored. -/
theorem parityColor_injectiveOnSupports (n : ℕ) :
    InjectiveOnSupports (chainSupports n) (parityColor n) := by
  intro S hS i j hi hj hc
  obtain ⟨⟨l, r⟩, he, rfl⟩ := Finset.mem_image.mp hS
  have hlr : l.val + 1 = r.val := (Finset.mem_filter.mp he).2
  simp only [Finset.mem_insert, Finset.mem_singleton] at hi hj
  have hmod : i.val % 2 = j.val % 2 := congrArg Fin.val hc
  rcases hi with rfl | rfl <;> rcases hj with rfl | rfl
  · rfl
  · omega
  · omega
  · rfl

/-- The accepted finite chain's even/odd coloring, in Mathlib's graph-coloring representation. -/
def chainColoring (n : ℕ) : (componentGraph (chainSupports n)).Coloring (Fin 2) :=
  coloringOfInjectiveOnSupports _ (parityColor n) (parityColor_injectiveOnSupports n)

/-- Every nonzero nearest-neighbor coefficient has a declared spring component support. -/
theorem chain_supports {n : ℕ} {b : Matrix (Fin n) (Fin n) ℝ}
    (hs : ∀ i j, i.val + 1 ≠ j.val → j.val + 1 ≠ i.val → b i j = 0) :
    ∀ i j, b i j ≠ 0 → ∃ S ∈ chainSupports n, i ∈ S ∧ j ∈ S := by
  intro i j hij
  have he : i.val + 1 = j.val ∨ j.val + 1 = i.val := by
    by_contra h
    exact hij (hs i j (not_or.mp h).1 (not_or.mp h).2)
  rcases he with he | he
  · refine ⟨{i, j}, Finset.mem_image.mpr ⟨(i, j), ?_, rfl⟩, by simp, by simp⟩
    simp [he]
  · refine ⟨{j, i}, Finset.mem_image.mpr ⟨(j, i), ?_, rfl⟩, by simp, by simp⟩
    simp [he]


/-- The accepted even/odd chain execution has the same uniform nonlinear contraction factor. -/
theorem lipschitzOnWith_chain_colored {n : ℕ} {a : Fin n → ℝ}
    {b : Matrix (Fin n) (Fin n) ℝ} {η : ℝ} {y : State (Fin n)}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hy : ∀ i, |y i| ≤ 1 / 20)
    (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (hs : ∀ i j, i.val + 1 ≠ j.val → j.val + 1 ≠ i.val → b i j = 0) :
    LipschitzOnWith (318 / 625 : ℝ≥0)
      (BlockContraction.maxMap ((newtonData a b η y threshold).colored
        (chainColoring n) [0, 1])) stateBox := by
  exact lipschitzOnWith_colored ha hb (fun i ↦ hs i i (by omega) (by omega))
    hη hη1 hrow hy threshold ht (chainSupports n) (chain_supports hs) (chainColoring n)
    [0, 1] (by intro color; fin_cases color <;> simp)

/-- The accepted even/odd chain execution preserves the nonlinear box. -/
theorem chain_colored_preserves_box {n : ℕ} {a : Fin n → ℝ}
    {b : Matrix (Fin n) (Fin n) ℝ} {η : ℝ} {y : State (Fin n)}
    (ha : ∀ i, 1 ≤ a i) (hb : ∀ i j, 0 ≤ b i j) (hη : 0 ≤ η) (hη1 : η ≤ 1)
    (hrow : ∀ i, ∑ j, b i j ≤ a i / 2) (hy : ∀ i, |y i| ≤ 1 / 20)
    (threshold : ℝ≥0) (ht : (threshold : ℝ) < 1)
    (hs : ∀ i j, i.val + 1 ≠ j.val → j.val + 1 ≠ i.val → b i j = 0) :
    Set.MapsTo (BlockContraction.maxMap ((newtonData a b η y threshold).colored
      (chainColoring n) [0, 1])) stateBox stateBox :=
  colored_preserves_box ha hb hη hη1 hrow hy threshold ht (chainSupports n)
    (chain_supports hs) (chainColoring n) [0, 1]

end Vbd.AxialSpring
