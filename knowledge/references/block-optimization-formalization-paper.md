---
type: Paper Transcript
title: Formalization of Algorithms for Optimization with Block Structures — Agent-readable Full Text
description: LaTeX-source-derived Markdown rendering of the Lean 4 BCD and ADMM formalization paper.
resource: https://arxiv.org/pdf/2503.18806
tags: [lean4, optlib, paper, full-text, markdown, block-coordinate-descent]
timestamp: 2026-10-21T02:29:26Z
---

# Conversion provenance

- Mathematics uses protected inline delimiters and `$$` displays; equation labels use Markdown anchors.
- Canonical source: [arXiv 2503.18806](https://arxiv.org/abs/2503.18806).
- Downloaded PDF SHA-256: `3a5e8c91b863144e4395deefce96884e2c7130a62c62f0c373ff60b72d3ee2b6`.
- Rendering: official arXiv LaTeX source converted with Pandoc 3.10.2 and a presentation-cleanup filter.
- Figures were omitted; source code, prose, sections, references, and TeX mathematics were retained where supported by Pandoc.
- This local rendering is for agent search and reading. Use the canonical paper for citation and visual verification.

# Converted paper

# Introduction

Large-scale optimization problems with block structures play a central role in numerous fields, including machine learning, signal processing, and image processing. Efficiently solving these problems is essential for theoretical advancement and practical applications. Two prominent algorithms addressing these challenges are the block coordinate descent (BCD) method and the alternating direction method of multipliers (ADMM). The BCD algorithm solves optimization problems with objective functions comprising both separable and nonseparable components by updating the variable blocks by blocks. The ADMM algorithm primarily addresses optimization problems involving multi-blocks connected with coupling constraints, iteratively minimizing the augmented Lagrangian function for each block and updating the multipliers to enforce constraint satisfaction. Despite their methodological differences, both approaches share the fundamental strategy of decomposing complex optimization problems into simpler subproblems.

The convergence analysis of algorithms for optimization problems with block structures has been widely studied. For the BCD method, Powell [@powell1973search] demonstrated the challenges of nonconvex optimization through examples of non-convergence in nonconvex objective functions. Tseng [@tseng2001convergence] proposes a robust convergence framework for nondifferentiable convex minimization problems. To address these complexities in nonsmooth and nonconvex analysis, additional conditions, such as the Kurdyka-Łojasiewicz (KL) property, become necessary. The KL property can trace back to Łojasiewicz's work on gradient inequalities [@lojasiewicz1963propriete]. The convergence of the BCD algorithm in nonconvex settings with the KL property is given by [@bolte2014proximal]. The ADMM method also gains significant attention due to its applicability in high-dimensional data problems and distributed optimization [@boyd2011distributed]. The classical ADMM method is introduced in [@glowinski1975approximation] and [@gabay1976dual]. Glowinski provides an introduction to the historical development in [@Glowinski2014]. The convergence analysis of the ADMM algorithm under certain conditions is established in [@gabay1976dual; @glowinski2013numerical; @fortin2000augmented]. Fankel et al. give the convergence proof of a computationally more attractive large step-length version of the ADMM method in [@Fazel2013hankelmatrix].

Several efforts have been made to formalize numerical algorithms using various formalization languages such as Coq [@huet1997coq], Isabelle [@Nipkow2002APA], and Lean [@de2015lean]. Tekriwal et al. formalize the convergence of the Jacobi method for linear systems in Coq [@Tekriwal2023Verified], and the formalization of asymptotic convergence for stationary iterative methods such as Gauss-Seidel method is explored in [@Tekriwal2024Formalizatioin]. The analysis of floating-point errors in numerical algorithms is formalized in Coq [@Appel2024VCFloat; @Kellison2024Numerical]. Additionally, the formalization of convergence rates for various first-order optimization methods is presented in Lean4 [@li2024formalization].

The Lean4 language and its theorem library mathlib[@mathlibcommunity] offers a flexible formalization tool for mathematicians, enabling precise reasoning about mathematical concepts through a machine-verified framework. Lean4 is based on the dependent type theory, allowing for the expression of refined mathematical properties directly in the type system. In this setting, proofs are constructed as objects of a specific type, ensuring that every step is logically sound and verifiable. This approach enables the construction of rigorous formalizations across various fields of mathematics. For example, the Gagliardo-Nirenberg-Sobolev inequality is formalized by Doorn and Macbeth [@vandoorn_et_al:LIPIcs.ITP.2024.37]. Dupuis et al. explore the formalization of functional analysis with semilinear maps [@dupuis_et_al:LIPIcs.ITP.2022.10]. Moreover, a formalization of Doob's martingale convergence theorems in mathlib is provided by Ying et al. [@Ying2023Doob].

We presents a formalized convergence analysis of the BCD and ADMM algorithms within the Lean4 theorem proving environment. Our contributions are structured as follows.

1.  **Subdifferential theory in Hilbert spaces.** The Fréchet and limiting subdifferentials are formalized, extending the formalization of the differential structure of nonsmooth functions. Basic theorems are presented, including equivalent definitions, subdifferential calculus, and optimality conditions of nonsmooth unconstrained optimization.

2.  **The KL property and KL functions.** The formalization of the KL property and KL functions is established. The sufficient conditions of the KL property are formally proved. The uniformized KL property is derived through extensions on compact sets, enabling convergence analysis in nonsmooth and nonconvex optimization problems.

3.  **Algorithm frameworks and convergence analysis.** i) A formal framework is provided for the proximal alternating linearized minimization in two-block problems [@bolte2014proximal]. Formalized convergence theorems such as critical point analysis through subdifferential characterizations and finite-length convergence under the KL property are provided. ii) A type of the ADMM algorithm is formalized for composite convex optimization problems with a linear constraint connecting two distinct components according to [@Fazel2013hankelmatrix; @chen2017note]. Essential assumptions, including lower semicontinuity, convexity, and solvability of subproblems, are formally established to ensure systematic convergence analysis. Moreover, the error reduction bounds are formally presented, and global convergence of the ADMM method to KKT points is proved.

The rest of this paper is organized as follows. The formalization of the subdifferential of general functions is given in Section [2](#sec: subdifferential). KL property and KL functions are formalized in Section [3](#sec: KL). We discuss the formalization of the scheme and the convergence analysis of the BCD and ADMM algorithms in Section [4](#sec: BCD) and Section [5](#sec: ADMM), respectively.

# Subdifferential Structure of General Function

## Definitions

In this subsection, we review the definition and properties of subdifferential and the first-order optimality condition for general functions. These are particularly useful for analyzing nondifferentiable and nonconvex functions. Recall that for a convex function $`f`$ defined on a Hilbert space $`E`$, the subgradient $`u`$ provides a global lower bound for $`f`$. For all $`y \in E`$, the inequality $`f(y)\geq f(x)+\langle u,y-x\rangle`$ holds at every point in the domain. However, when $`f`$ is nonconvex, this property is only expected to hold in a limiting sense. The definition of subdifferential is as follows.

For a function $`f : E  \to \mathbb{R}`$ defined on a Hilbert space $`E`$, and a given point $`x \in E`$, the *Fréchet subdifferential* is defined as

$$
\begin{aligned}
    \hat{\partial} f(x) = \left\{u\in\mathbb{R}^n \mid \liminf_{y \to x, y \neq x} \frac{f(y) - f(x) - \langle u, y - x \rangle}{\|y - x\|} \geq 0\right\}.
\end{aligned}
$$

For convenience, we introduce the notion of *f-attentive convergence*. The term $`x^n \underset{f}{\to} x`$ denotes that a sequence $`\{x^n\}`$ satisfies that $`x^n \to x`$ with $`f(x^n) \to f(x)`$ as $`n \to \infty`$. The limiting subdifferential is defined as follows.

The *limiting subdifferential* of $`f`$ at $`x\in E`$ is defined as

<a name="def-limit-subdiff1"></a>

$$
\partial f(x) = \left\{u \in \mathbb{R}^n  \mid\exists x^k\underset{f}{\to} x, u^k \in \hat{\partial} f(x^k)\to u, \text{ as } k \to \infty\right\},
$$

 where $`u`$ is called a (general) subgradient of $`f`$ at $`x`$.

Additional assumptions on the domain space are required to formalize these definitions. We assume the following instances for the space variable from this subsection.

    variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

The assumptions in brackets give the properties of the space $`E`$, claiming that `E` is a normed additive commutative group and an inner product space on $`\mathbb{R}`$. These assumptions can be automatically checked when using the related theorems. For example, when discussing functions on $`\mathbb{R}^n`$, Lean4 identifies that $`\mathbb{R}^n`$ is a normed add commutative group and an inner product space on $`\mathbb{R}`$. Hence, the theorems proved for general space $`E`$ work well for concrete space such as $`\mathbb{R}^n`$.

The Fréchet subdifferential and limiting subdifferential in Lean are defined as follows.

    def differential_fun (x : E) (f : E → ℝ) (u : E) :=
        fun y ↦ Real.toEReal ((f y - f x - inner u (y - x)) / ‖ y - x ‖)

    def f_subdifferential (f : E → ℝ) (x : E) : Set E :=
        {v : E | liminf (differential_fun x f v) (nhds[≠] x) ≥ 0}

    def subdifferential (f : E → ℝ) (x : E) : Set E :=
        {v₀ : E | ∃ u : ℕ → E, Tendsto u atTop (nhds x) ∧ Tendsto (fun n ↦ f (u n)) atTop (nhds (f x)) ∧ (∃ v : ℕ → E, ∀ n, v n ∈ f_subdifferential f (u n) ∧ Tendsto v atTop (nhds v₀))}

The function `Real.toEReal` is introduced to convert real numbers into extended real numbers (`EReal`). This conversion is necessary for correctly applying the operator $`\liminf`$ in the definition of `f_subdifferential`. Specifically, the limit infimum can attain infinite values only within extended real numbers. In contrast, within Lean's real number type ($`\mathbb{R}`$), the limit infimum defaults to zero when it would otherwise take an infinite value.

We can define the active domain of a function $`f(x)`$ using subdifferential, which consists of points whose subdifferential is not empty. The formalized definition is given as below.

    def active_domain (f : E → ℝ) : Set E := {x | subdifferential f x ≠ ∅}

In the above definitions, the regular subgradient uses the concept of `liminf` in Lean. We can get an equal description using little-o notation through mathematical reformulation:

$$
\begin{aligned}
    f(y) \geq f(x) + \langle u, y - x \rangle + o(\|y - x\|), \quad \text{as}\; \|y-x\| \to 0.
\end{aligned}
$$

 We can reformulate the definition using the concept of a filter to avoid explicitly managing Taylor expansions or infinitesimals, which brings convenience in some cases. An equivalent expression for the Fréchet subdifferential is defined in the following statement.

For a given $`x \in \mathrm{dom} f`$, $`u \in \hat{\partial} f(x)`$ if and only if for any $`\varepsilon > 0`$ and every $`y`$ in the neighborhood of x, it holds that

$$
\begin{aligned}
    f(y) - f(x) - \langle u, y - x \rangle \geq -\varepsilon \|y - x\|.
\end{aligned}
$$

The above theorem is formalized as follows.

    theorem has_f_subdiff_iff : u ∈ f_subdifferential f x ↔ ∀ ε > 0,
    (nhds x).Eventually fun x => f y - f x - inner u (y - x) ≥ -ε * ‖ y - x ‖

To state the next theorem, we define:

$$
\begin{aligned}
G (f,\hat{\partial} f) & := \left\{ (x,f(x),u)|x \in \mathbb{R}^n,u \in \hat{\partial} f(x)\right\},\\
G (\partial f) & := \left\{ (x,u)|x \in \mathbb{R}^n,u \in \partial f(x)\right\}.
\end{aligned}
$$

 We next introduce a more streamlined description of the subdifferential by leveraging the closure of the subdifferential graph. This reformulation provides an intuitive geometric interpretation by directly relating the subdifferential to the closure of its graph. The following theorem states the closedness of the subdifferential graph. This property is also used in the proof of the KL property.

Let $`(x_k,x_k^{\ast})\in G (\partial f)`$ be a sequence that converges to $`(x,x^{\ast})`$. If $`f(x_k)`$ converges to $`f(x)`$, then $`(x,x^{\ast})\in G(\partial f)`$. Or equivalently,

<a name="eq-subdifferential-definition-2"></a>

$$
\begin{aligned}
        \partial f(x) = \left\{ u \in \mathbb{R}^n | (x, f(x), u) \in \overline{G (f, \hat{\partial} f)}  \right\}.
\end{aligned}
$$

The theorem is formalized as below.

    def subdifferential_Graph (f : E → ℝ) :=
    {(x, u) : E × E | u ∈ subdifferential f x}

    theorem GraphOfSubgradientIsClosed {f : E → ℝ} {xn un : ℕ → E} {x u : E}
    (hx : ∀ n , (xn n, un n) ∈ subdifferential_Graph f)
    (hconv : Tendsto (fun n => (xn n , un n)) atTop (nhds (x, u)))
    (hf : Tendsto (fun n => f (xn n)) atTop (nhds (f x))) :
    (x, u) ∈ subdifferential_Graph f

## Properties of Subdifferentials

These definitions of subdifferentials enable the derivation of the first-order optimality condition of general functions. For general functions, the first-order condition is stated as follows.

If $`x^{\ast}`$ is a local minimum point of $`f`$, then $`0 \in \partial f (x^{\ast})`$.

In Lean, we formalize this as follows.

    theorem first_order_optimality_condition (f : E → ℝ) (x₀ : E)
    (hx : IsLocalMin f x₀) : (0 : E) ∈ f_subdifferential f x₀

The point $`y`$ satisfying $`0 \in \partial f(y)`$ is called a critical point of the function $`f(x)`$. The set of critical points of $`f(x)`$ is denoted as $`\mathrm{crit }f (x)`$. This is formalized as follows.

    def critial_point (f : E → ℝ) : Set E := {x | 0 ∈ subdifferential f x}

It is evident that a local minimum must be a critical point of the objective function.

Notably, both the Fréchet subdifferential and the limiting subdifferential reduce to the gradient of $`f`$ at points where the function $`f`$ is smooth. Several theorems will be introduced to state the equivalence between subdifferential and gradient for differentiable functions. Since the gradient of the function is considered, we additionally assume `[CompleteSpace E]` to align with the assumptions regarding the existence of the gradient. To begin with, we present the following theorem to show the definition of Fréchet differential is the same as the gradient when the function is differentiable.

The following two statements are equivalent:

1.  $`f`$ is differentiable at $`x`$ with a gradient $`u`$.

2.  $`u \in \hat{\partial}f(x)`$ and $`-u \in \hat{\partial}(-f)(x)`$.

The formalized version can be given as below.

    theorem HasGradientAt_iff_f_subdiff : HasGradientAt f u x ↔ u ∈ f_subdifferential f x ∧ -u ∈ f_subdifferential (-f) x

The proof of this proposition mainly utilizes the equivalent transformation of Fréchet subdifferential provided by `has_f_subdiff_iff` in Theorem [\[thm: equvilant subdifferential\]](#thm: equvilant subdifferential), thereby avoiding dealing with the lower limit in the definition of Fréchet subdifferential. The following property states the equivalence between gradient, Fréchet subdifferential, and limiting subdifferential.

Let $`f(x)`$ be a differentiable function with gradient $`\nabla f(x)`$ on a Hilbert space $`E`$. Then for every $`z \in E`$ , $`\hat{\partial}f(z)`$ is a singleton set with the element $`\nabla f(z)`$ .

The formalization of the theorem is given as follows.

    theorem f_subdiff_gradient (f' : E → E) (z : E) (hf : HasGradientAt f (f' z) z) : f_subdifferential f z = {f' z}

We prove this base on Theorem [\[thm: subdifferential diff\]](#thm: subdifferential diff). The conclusion $`\nabla f(z) \in \hat{\partial}f(z)`$ is a direct result from the proposition `HasGradientAt_iff_f_subdiff`. The theorem `f_subdiff_neg_f_subdiff_unique` is introduced to establish the connection between the subdifferentials of functions that are negatively correlated. Theorem [\[thm: singleton subdifferential\]](#thm: singleton subdifferential) can be deduced from these preparations.

The calculation rules of the subdifferential are also formalized. The following theorems show that under certain conditions, the Fréchet subdifferential of the sum of two functions can be converted into the sum of the Fréchet subdifferentials of the two functions separately.

Let $`f(x), g(x)`$ be two functions defined on $`E`$. If $`g(x)`$ is differentiable, then it holds that $`\hat{\partial}(f + g)(x) = \hat{\partial}f(x) + \hat{\partial}g(x)`$.

The formalized version of the theorem is as follows.

    theorem f_subdiff_add (f g : E → ℝ) (g' : E → E) (x : E) (hg : ∀ (x₁ : E), HasGradientAt g (g' x₁) x₁) (z : E) :
        z ∈ f_subdifferential (f + g) x ↔ ∃ zf ∈ f_subdifferential f x, ∃ zg ∈ f_subdifferential g x, z = zf + zg

With an extra condition that $`g`$ is continuously differentiable, Theorem [\[thm: f_subdifferential rule\]](#thm: f_subdifferential rule) also holds for the limiting subdifferential.

Let $`f, g`$ be two functions defined on $`E`$. If $`g`$ is continuous differentiable on $`E`$, it holds that $`{\partial}(f + g) = {\partial}f + {\partial}g`$.

The formalized theorem gives as follows.

    theorem subdiff_add (f g : E → ℝ) (g' : E → E) (x : E) (hg : ∀ (x₁ : E), HasGradientAt g (g' x₁) x₁) (gradcon : Continuous g') (z : E) : z ∈ subdifferential (f + g) x ↔ ∃ zf ∈ subdifferential f x, ∃ zg ∈ subdifferential g x, z = zf + zg

The proximal operator is also widely used in optimization algorithms, which addresses an optimization problem that balances maintaining proximity to a specified input point $`x`$ while also minimizing the function $`f`$. For general functions, the proximal operator maps a point to a set as follows.

The *proximal operator* for function $`f`$ at point $`x`$ is given as

<a name="eq-prox-def"></a>

$$
\begin{aligned}

    \text{prox}_f(x) = \underset{u}{\arg\min} \left\{ f(u) + \frac{1}{2}\|u-x\|^2 \right\}.
\end{aligned}
$$

The formalization of the proximal operator can be referred to [@li2024formalization]. The optimality condition of the optimization problem naturally links the proximal operator with the subdifferential. The connection is described in the following theorem.

If $`f(x)`$ is a function from a Hilbert space $`E`$ to $`\mathbb{R}`$, it holds that

<a name="eq-proximal-connection"></a>

$$
\begin{aligned}
    u \in \text{prox}_f(x) \quad \text{if and only if} \quad x - u \in \partial f(u).

\end{aligned}
$$

The theorem is formalized as below.

    theorem f_subdiff_prox {f : E → ℝ} {x y : E} (h : prox_prop f y x) : y - x ∈ f_subdifferential f x

A key step to prove the above propositions is to utilize first order optimality condition proven before to connect the minimality definition of the proximal operator and Fréchet subdifferential. The equivalence and operational properties of Fréchet subdifferential for certain functions also help to simplify the problem.

# The KL Property and KL Function

In the past few decades, the KL property has emerged as a versatile analytical framework for investigating convergence rates of first-order optimization methods, particularly when dealing with objectives that exhibit both nonsmoothness and nonconvexity, see [@attouch2013convergence; @bolte2014proximal; @bento2024convergence]. It is an extension to the Polyak-Łojasiewicz (PL) inequality developed by Polyak [@polyak1963gradient] and Łojasiewicz [@lojasiewicz1963propriete],

$$
\|\nabla f(x) \| \geq \mu \| f(x) - f(\bar x)\|^{\frac{1}{2}}, \quad \mu > 0,
$$

 where $`f`$ is an $`L`$-smooth function, and $`\bar x`$ is a global minimum of $`f`$. The linear convergence of the gradient descent algorithm can be established by this well-known inequality. It illustrates that the sub-optimality can be controlled by the vanishing of gradient norm and a special concave function $`\phi(t) = \mu t^{\frac{1}{2}}`$. Such functions are the so-called desingularizing functions in the context of the KL property.

For any $`\eta \in (0,+\infty)`$, if $`\phi`$ satisfies the following properties:

1.  $`\phi:[0,\eta) \to [0, \infty)`$ is continuous and concave;

2.  $`\phi(0) = 0`$;

3.  $`\phi`$ is continuously differentiable on $`(0,\eta)`$ with $`\phi'>0`$ on $`(0,\eta)`$,

then we call $`\phi`$ a desingularizing function and denote it as $`\phi \in \Phi_\eta`$.

The corresponding formalization of this family of functions is as follows.

    def desingularizing_function (η : ℝ) := {φ : ℝ → ℝ | (ConcaveOn ℝ (Ico 0 η) φ) ∧ (φ 0 = 0) ∧ (ContDiffOn ℝ 1 φ (Ioo 0 η)) ∧ (ContinuousAt φ 0) ∧ (∀ x ∈ Ioo 0 η, deriv φ x > 0)}

These desingularizing functions are essential to quantify the behavior of the objective $`f`$ near its critical points, enabling the analysis of the relationship between the subdifferential and the function values. We can define the KL property utilizing such functions. Still, all variables are considered in the Hilbert space $`E`$.

Let $`f: E \to \mathbb{R}`$ be a lower semicontinuous function. We say that $`f`$ satisfies the KL property at $`u\in \mathrm{dom}\partial f := \{ u \in E : \partial f (u) \neq \emptyset \}`$ if there exist $`\eta \in (0, \infty)`$, a neighborhood $`S`$ of $`u`$ and $`\phi\in \Phi_\eta`$ such that for any $`x \in S \cap [f(u) < f < f(u) + \eta]`$, the following inequality holds:

$$
\phi'(f(x)-f(u))\cdot \mathrm{dist}(0, \partial f(x)) \geq 1.
$$

 The point $`u`$ is called a KL point of $`f`$. If $`f`$ satisfies KL property at every point of $`\mathrm{dom} \partial f`$, we say that $`f`$ is a KL function.

We generalize the assumption of lower semicontinuity in Definition [\[def:KL\]](#def:KL) in formalization. Note that the KL property holds naturally if $`\partial f (\bar u) = \emptyset`$. Hence, the non-emptiness of subdifferential can also be omitted in formalization. These two assumptions need not be included in the formalization of the KL point and KL function. Consequently, $`\mathrm{dist}(0,\partial f(u))`$ might be infinity when $`\partial f(u)`$ is empty. We use `EMetric.infEdist` to keep the inequality on extended non-negative real numbers `ENNReal`, and `ENNReal.ofReal` to convert real numbers to `ENNReal`. The formalization of the KL point and KL function are as follows.

    def KL_point (f : E → ℝ) (u : E) : Prop := ∃ η ∈ Ioi 0, ∃ s ∈ nhds u, ∃ φ ∈ desingularizing_function η, ∀ x ∈ s ∩ {y | f u < f y ∧ f y < f u + η}, (ENNReal.ofReal (deriv φ (f x - f u))) * (EMetric.infEdist 0 (subdifferential f x)) ≥ ENNReal.ofReal 1

    def KL_function (f : E → ℝ) : Prop := ∀ u ∈ active_domain f, KL_point f u

It is shown in [@attouch2010proximal] that the KL property holds at noncritical points of $`f`$.

Suppose that $`f:E \to \mathbb{R}`$ is a lower semicontinuous function. The KL property holds at $`x`$, if it holds that $`0 \notin \partial f(x)`$.

This theorem is formalized as follows.

    theorem KL_property_at_noncritical_point (h_noncrit : 0 ∉ subdifferential f x) : KL_point f x

The uniformized KL property [@bolte2014proximal] is incorporated to deal with the case when the KL property holds at many different points.

Suppose $`\Omega`$ is a compact set and $`f:E \to \mathbb{R}`$ is a lower semicontinuous function. Suppose $`f`$ is constant on $`\Omega`$ and satisfies the KL property at every point of $`\Omega`$. Then there exist $`\epsilon>0, \eta>0`$, and a function $`\phi \in \Phi_\eta`$, such that for all $`u\in \Omega`$ and all $`x`$ satisfying $`\mathrm{dist}(x,\Omega) < \epsilon, f(u) < f (x) < f (u)+ \eta`$, it holds

$$
\phi'(f(x) - f(u)) \cdot \mathrm{dist}(0, \partial f (x)) \geq 1.
$$

    theorem uniformized_KL_property {f : E → ℝ} {Ω : Set E} (h_compact : IsCompact Ω) (h_Ω1 : ∀ x ∈ Ω, KL_point f x) (h_Ω2 : is_constant_on f Ω) : ∃ ε ∈ Ioi 0, ∃ η ∈ Ioi 0, ∃ φ ∈ desingularizing_function η, ∀ u ∈ Ω , ∀ x ∈ {y : E | (EMetric.infEdist y Ω).toReal < ε} ∩ {y | f u < f y ∧ f y < f u + η}, (ENNReal.ofReal (deriv φ (f x - f u))) * EMetric.infEdist 0 (subdifferential f x) ≥ 1

To prove this theorem, a finite open cover can be chosen based on the neighborhoods of the KL points using `IsCompact.elim_finite_subcover_image`. Then there exists an open ball in this finite cover from `IsCompact.exists_thickening_subset_open`. Furthermore, one can prove that the sum of the finite desingularizing functions on the finite cover will be in $`\Phi_\eta`$ for some $`\eta > 0`$ by checking Definition [\[def : desingularizing\]](#def : desingularizing). Finally, a uniformized neighborhood and a desingularizing function are constructed for the inequality.

# The Block Coordinate Descent Algorithm

In this section, we consider a special form of the BCD algorithm with proximal alternating linearized minimization following [@bolte2014proximal]. The BCD algorithm is applied to two-block optimization problems as:

<a name="eq-target-bcd"></a>

$$
\begin{aligned}
    \underset{x, y}{\min} \; \Psi(x,y) = f(x) + g(y) + H(x,y),

\end{aligned}
$$

 where $`f(x) : \mathbb{R}^n \to \mathbb{R}`$ and $`g(y) : \mathbb{R}^m \to \mathbb{R}`$ are separated parts for $`x`$ and $`y`$, respectively. $`H(x,y) : \mathbb{R}^n \times \mathbb{R}^m \to \mathbb{R}`$ is the composite part. The basic assumptions for this problem are listed as below.

**Assumption 1**.

1.  *The separated parts $`f(x)`$ and $`g(y)`$ are lower semicontinuous functions. $`f(x)`$, $`g(y)`$ and $`\Psi(x,y)`$ are all bounded below.*

2.  *$`H(x,y)`$ is a differentiable function with a Lipschitz continuous gradient. The Lipschitz constant of the gradient is $`l`$, i.e.

    $$
    \begin{aligned}
                    \left\| \left( \nabla_x H(x_1, y_1) - \nabla_x H(x_2, y_2), \nabla_y H(x_1, y_1) - \nabla_y H(x_2, y_2) \right) \right\| \leq l \left\| (x_1 - x_2, y_1 - y_2) \right\|.
        \end{aligned}
    $$

*

The BCD algorithm utilizes an alternating optimization method to update $`x`$ and $`y`$, where each update of $`y`$ integrates the latest value of $`x`$. In each iteration, the linear approximation of the smooth part $`H(x,y)`$ is used to approximate the local property of $`H(x,y)`$. Another penalty term with step size is added to balance the error of approximation. For the $`k`$-th iteration, we solve the following subproblems:

<a name="eq-bcd-update-ori"></a>

$$
\begin{aligned}
\begin{aligned}
    x^{k+1} &\in \underset{x}{\arg\min} \left\{f(x)+ \langle \nabla_x H(x^k, y^k), x - x ^k \rangle + \frac{c_k}{2} \|x-x^k\|^2  \right\}, \\
    y^{k+1} &\in \underset{y}{\arg\min}\left\{g(y) + \langle \nabla_y H(x^{k+1}, y^k), y - y^k \rangle + \frac{d_k}{2} \|y-y^k\|^2  \right\}.
\end{aligned}

\end{aligned}
$$

 The set of minimizers of the subproblem may not be a singleton. We select an arbitrary element to continue the iterations. The parameters $`c_k`$ and $`d_k`$ control the step sizes. Through the definition of the proximal operator [\[eq: prox_def\]](#eq-prox-def), the subproblems can be rewritten as

<a name="eq-bcd-update"></a>

$$
\begin{aligned}
\begin{aligned}
    x^{k+1} &\in \text{prox}_{c_k f} \left( x^k - c_k \nabla_x H(x^k, y^k) \right), \\
    y^{k+1} &\in \text{prox}_{d_k g} \left( y^k - d_k \nabla_y H(x^{k+1}, y^k) \right).
\end{aligned}

\end{aligned}
$$

## Formalization of the Update Scheme

For any numerical algorithm, the formalization can typically be decomposed into two primary components: the problem data and the update mechanism. The problem data encapsulate well-founded assumptions about the problem, whereas the update mechanism encompasses the initial point, sequence of updates, and the specific rules applied at each iteration. The formalized problem data is presented below:

    variable [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]
    variable [NormedAddCommGroup F] [InnerProductSpace ℝ F] [CompleteSpace F]
    structure ProblemData (f : E → ℝ) (g : F → ℝ) (H : (WithLp 2 (E × F)) → ℝ) (l : NNReal) : Prop where
      lbdf : BddBelow (f '' univ)     lbdg : BddBelow (g '' univ)
      hf : LowerSemicontinuous f     hg : LowerSemicontinuous g
      conf : ContDiff ℝ 1 H          lpos : l > (0 : ℝ)
      lip : LipschitzWith l (gradient H)

All assumptions are bundled into the structure problem data. This facilitates the identification and use of the problem conditions. The concrete space $`\mathbb{R}^n`$ is replaced by a Hilbert space `E`. This not only makes the analysis clearer in formalization, but also generalizes the current results on $`\mathbb{R}^n`$ to a general Hilbert space. It is essential to note that the function $`H`$ operates in the domain `WithLp 2 (E × F)`. Handling the product space $`(x, y)`$ is challenging. Within mathlib, two types of product spaces are defined: `E × F` and `WithLp 2 (E × F)`. Although the elements of these spaces can both be represented as $`(x, y)`$, their norms differ significantly. For `(x, y)` of type `E × F`, the norm is defined as $`\|(x, y)\| = \max \{\|x\|, \|y\|\}`$. However, for `WithLp 2 (E × F)`, it holds that $`\|(x, y)\| = \sqrt{\|x\|^2 + \|y\|^2}`$. The former space is merely normed and lacks an inner product structure, while the latter represents the typical inner product space used for product spaces. These norms are equivalent, each bounded by absolute constants. Since the usage of gradient requires that the domain is a Hilbert space, `WithLp 2 (E × F)` is a better choice choice for defining gradients due to its inner product space properties.

We give the formalized algorithm towards [\[eq : BCD update\]](#eq-bcd-update) using the `structure` type extending over `ProblemData`. The update scheme, predicated on the problem data, is structured as follows:

    structure BCD (f : E → ℝ) (g : F → ℝ) (H : (WithLp 2 (E × F)) → ℝ) (l : NNReal)(x0 : E) (y0 : F) extends ProblemData f g H l where
      (x : ℕ → E)  (y : ℕ → F)
      (x0 : x 0 = x0) (y0 : y 0 = y0) (c d : ℕ → ℝ)
      s₁ : ∀ k, prox_prop (c k • f) (x k - c k • (grad_fst H (y k) (x k))) (x (k + 1))
      s₂ : ∀ k, prox_prop (d k • g) (y k - d k • (grad_snd H (x (k + 1)) (y k))) (y (k + 1))

The definitions for $`f`$, $`g`$, and $`H`$ are directly inherited from the problem data. The term `prox_prop f x y` means that $`y \in \mathrm{prox}_f(x)`$. We introduce additional notations using the same namespace BCD as follows:

    def BCD.z {self : BCD f g H l x0 y0} : ℕ → WithLp 2 (E × F) :=
        fun n ↦ (WithLp.equiv 2 (E × F)).symm (self.x n, self.y n)

    def BCD.ψ {_ : BCD f g H l x0 y0} :=
        fun z : WithLp 2 (E × F) ↦ (f z.1 + g z.2 + H z)

These definitions are given in the local namespace as beginning with "`BCD.`". Hence, if we use `alg : BCD f g H l x0 y0` to define an algorithm, `alg.z` automatically turns to this definition, which gives convenience for complicated calculation.

## Convergence Analysis

For the analysis of the fixed step size version of BCD, we mainly follow [@bolte2014proximal] and the detailed proof is omitted in this paper. We set the step sizes $`c_k`$ and $`d_k`$ consistently as $`\frac{1}{\gamma l}`$, where $`\gamma`$ serves as a critical hyper-parameter. The parameter $`l`$ represents the Lipschitz constant of $`\nabla H`$. The conditions on the stepsizes are given in `variable` as follows and for simplicity we omit to claim them for each theorem in this subsection.

    variable (γ : ℝ) (hγ : γ > 1) (ck: ∀ k, alg.c k = 1 / (γ * l)) (dk: ∀ k, alg.d k = 1 / (γ * l))

To demonstrate the convergence of the algorithm, the analysis unfolds in several stages. Initially, we establish a sufficient descent condition showing that the function values decremented by the algorithm are monotonically decreasing.

Suppose that Assumption [1](#assumption: BCD) holds. Under the condition that the iterative sequence $`\{z^k = (x^k, y^k)\}`$ generated by updates [\[eq : BCD update\]](#eq-bcd-update) is bounded and the step sizes satisfy $`c_k = d_k = \frac{1}{\gamma l}`$ for $`\gamma > 1`$, the sequence exhibits the following characteristics.

1.  At each iteration, the decrement property holds:

    $$
    (\gamma - 1)l \|z^{k+1} - z^k\|^2 \leq H(z^k) - H(z^{k+1}), \quad \forall k \geq 0.
    $$

2.  The sequence $`\{\|z^{k+1} - z^k\|\}_{k=1}^\infty`$ is square summable:

    $$
    \sum_{k=1}^\infty \|z^{k+1} - z^k\|^2 < \infty,
    $$

 ensuring that $`\lim\limits_{k \to \infty} \|z^{k+1} - z^k\| = 0.`$

The following two statements formalize Theorem [\[thm: sufficient descent bcd\]](#thm: sufficient descent bcd).

    theorem Sufficient_Descent1 {alg : BCD f g H l x0 y0} :
        ∃ ρ₁ > 0, ρ₁ = (γ - 1) * l ∧ ∀ k, ρ₁ / 2 * ‖ alg.z (k+1) - alg.z k ‖ ^ 2 ≤ alg.ψ (alg.z k) - alg.ψ (alg.z (k + 1))

    theorem Sufficient_Descent2 {alg : BCD f g H l x0 y0} (lbdψ : BddBelow (alg.ψ '' univ)):
        Tendsto (fun k ↦ ‖ alg.z (k + 1) - alg.z k ‖) atTop (nhds 0)

Theorem `Sufficient_Descent1` establishes the non-increasing nature of the objective function. Theorem `Sufficient_Descent2` guarantees that the distances between successive updates converge to zero, ensuring update stabilization.

To gain a deeper understanding of the analysis, it is crucial to examine the behavior of the subdifferential at the update points. We can establish that the subdifferential at each iteration is upper-bounded by the norm of the difference between two consecutive points, which implies that the norm of the subdifferential tends to zero as the iterations progress.

Suppose that Assumptions [1](#assumption: BCD) holds. Suppose $`\{z^k\}`$ generated by scheme [\[eq : BCD update\]](#eq-bcd-update) is bounded and the step sizes satisfy $`c_k = d_k = \frac{1}{\gamma l}`$ for $`\gamma > 1`$. For each positive integer k, define

$$
\begin{aligned}
    A_x^k := c_{k-1} (x^{k-1} - x^k) + \nabla_x H(x^k, y^k) - \nabla_x H(x^{k-1}, y^k), \\
    A_y^k := d_{k-1} (y^{k-1} - y^k) + \nabla_y H(x^k, y^k) - \nabla_y H(x^k, y^{k-1}).
\end{aligned}
$$

 Then $`(A_x^k, A_y^k) \in \hat{\partial} \Psi(x^k, y^k)`$ and there exists $`M = (2\gamma+2)l > 0`$ such that

$$
\begin{aligned}
    \left\| (A_x^k, A_y^k) \right\| \leq \left\| A_x^k \right\| + \left\| A_y^k \right\| \leq M \left\| z^k - z^{k-1} \right\|, \quad \forall k \geq 1,
\end{aligned}
$$

The specific values of $`A_x^k`$ and $`A_y^k`$ for the Fréchet subdifferentials are not essential to the continuation of the proof. What matters is their existence and norm bound. Therefore, for simplicity, our formalized version of Lemma [\[lemma: BCD subdifferential\]](#lemma: BCD subdifferential) omits the explicit values of the subdifferentials and focuses solely on their existence and bound. In our proof, the values of $`A_x^k`$ and $`A_y^k`$ are used, and the membership relation is established by the calculation rule in Theorem [\[thm: f_subdifferential rule\]](#thm: f_subdifferential rule). One of the most difficult problem in formalization is to deal with the subdifferential with the product space. We establish calculation rules for block-wise subdifferential. The formalized version is provided below.

    theorem Ψ_subdiff_bound {alg : BCD f g H l x0 y0} :
        ∃ ρ > 0, ∀ k, ∃ dΨ ∈ f_subdifferential alg.ψ (alg.z (k + 1)), ‖dΨ‖ ≤ ρ * ‖ alg.z (k + 1) - alg.z k ‖

From this boundedness of the subdifferential, we obtain that the limit points of the update sequence $`\{z^k\}`$ constitute critical points of the objective function.

Suppose that Assumptions [1](#assumption: BCD) holds. Let $`\{z^k\}`$ generated by algorithm [\[eq : BCD update\]](#eq-bcd-update) be bounded and the step sizes satisfy $`c_k = d_k = \frac{1}{\gamma l}`$ for $`\gamma > 1`$. Denote the limit set of $`\{z^k\}`$ as $`\omega(z^0)`$. It holds that $`\emptyset \neq \omega(z^0) \subset \mathrm{crit} \Psi(z)`$ and the objective function $`\Psi(z)`$ is finite and constant on $`\omega(z^0)`$.

We add a definition of limit set in Lean using the function `MapClusterPt` in Mathlib4, which denotes the cluster point of a mapping. The formalized theorem is given as below.

    def limit_set (z : ℕ → E) := {x | MapClusterPt x atTop z}
    theorem limitset_property {alg : BCD f g H l x0 y0} (bd : Bornology.IsBounded (alg.z '' univ)) (lbdψ : BddBelow (alg.ψ '' univ)):
        (limit_set alg.z).Nonempty ∧ (limit_set alg.z) ⊆ critial_point alg.ψ ∧ ∃ (c : ℝ) , ∀ x ∈ (limit_set alg.z) , alg.ψ x = c

Theorem [\[thm: sufficient descent bcd\]](#thm: sufficient descent bcd) does not address the properties of the limit point of $`z^k`$. To ensure convergence to a critical point of the objective function $`\Psi(x, y)`$, it is assumed that the objective function $`\Psi(x,y)`$ exhibits the KL property near these critical points, strengthening conditions around the critical points of $`H(x, y)`$. We can obtain a stronger version of the convergence theorem.

<a name="thm-bounded-length-bcd"></a>

Suppose that Assumption [1](#assumption: BCD) holds. If $`\Psi(x,y)`$ is a KL function and the iterative sequence $`\{z^k\}`$ adheres to the updates [\[eq : BCD update\]](#eq-bcd-update), the following theorems hold.

1.  The sequence $`\{z^k\}`$ possesses a finite total variation:

    $$
    \sum_{k=1}^\infty \|z^{k+1} - z^k\| < +\infty,
    $$

2.  $`\{z^k\}`$ converges to a critical point $`z^{\ast} = (x^{\ast}, y^{\ast})`$ of $`\Psi`$.

We can prove the formalized version of Theorem [bounded length](#thm-bounded-length-bcd).

    theorem Limited_length {alg : BCD f g H l x0 y0} (bd : Bornology.IsBounded (alg.z '' univ)) (hψ : KL_function alg.ψ) (lbdψ : BddBelow (alg.ψ '' univ)): ∃ M : ℝ, ∀ n,
        ∑ k in Finset.range n, ‖alg.z (k + 1) - alg.z k‖ ≤ M

    theorem Convergence_to_critpt {alg : BCD f g H l x0 y0} (bd : Bornology.IsBounded (alg.z '' univ)) (hψ : KL_function alg.ψ) (lbdψ : BddBelow (alg.ψ '' univ)) :
        ∃ z_ : (WithLp 2 (E × F)), z_ ∈ (critial_point alg.ψ) ∧ Tendsto alg.z atTop (nhds z_)

The proofs of the aforementioned theorems rely on algebraic manipulations and basic analytical tools, including inequalities and continuity arguments, to establish the sufficiency and boundedness conditions. This rigorous framework supports a clear iterative convergence analysis and enables precise customization of the BCD algorithm for specific problem settings. Furthermore, the foundational structure naturally extends to a range of optimization challenges.

# The Alternating Direction Method of Multipliers

The ADMM method is frequently used to solve optimization problems comprising multiple components coupled by a linear constraint. In this paper, we focus on a certain kind of the ADMM method:

<a name="eq-admm-form"></a>

$$
\begin{aligned}
        \min_{x_1, x_2} & \quad f_1(x_1) + f_2(x_2), \\
        \text{s.t.} & \quad A_1 x_1 + A_2 x_2 = b,
    \end{aligned}
$$

 where $`f_1(x_1) : \mathbb{R}^n \to \mathbb{R}`$ and $`f_2(x_2) : \mathbb{R}^m \to \mathbb{R}`$ are two separated parts of the objective function. The matrices $`A_1 \in \mathbb{R}^{p \times n}`$ and $`A_2 \in \mathbb{R}^{p \times m}`$ link the variables via linear constraints, with $`b \in \mathbb{R}^p`$ representing a given vector. Our analysis of this algorithm mainly follows [@Fazel2013hankelmatrix; @chen2017note]. The assumptions of this problem are given below.

**Assumption 2**. * *

1.  *The separated parts $`f_1(x_1)`$ and $`f_2(x_2)`$ are lower semicontinuous convex functions.*

2.  *The solution set of problem [\[eq: admm form\]](#eq-admm-form) is nonempty and satisfies Slater's condition, i.e. there exists a feasible solution in the interior of the domain:

    $$
    \begin{aligned}
                    \exists (\tilde{x}_1, \tilde{x}_2) \in \text{int} ( \text{dom} f_1 \times \text{dom} f_2 ) \quad \text{s.t.} \quad A_1 \tilde{x}_1 + A_2 \tilde{x}_2 = b.
        \end{aligned}
    $$

*

The augmented Lagrangian function of problem [\[eq: admm form\]](#eq-admm-form) is given as:

<a name="eq-augmented-lagrangian"></a>

$$
\begin{aligned}
    L_{\rho}(x_1, x_2, y) = f_1(x_1) + f_2(x_2) + \left<y, A_1x_1 + A_2x_2 - b\right> + \frac {\rho} 2  \left\lVert A_1x_1 + A_2x_2 - b\right \rVert^2,

\end{aligned}
$$

 where $`\rho`$ is the penalty parameter. To solve the constraint optimization problem [\[eq: admm form\]](#eq-admm-form), the ADMM method sequentially minimizes the augmented Lagrangian function with respect to each variable, then updates the Lagrange multipliers. Based on [\[eq: augmented lagrangian\]](#eq-augmented-lagrangian), the iterative scheme of ADMM is as follows:

<a name="eq-admm-update-1"></a>

<a name="eq-admm-update-2"></a>

<a name="eq-admm-update-3"></a>

$$
\begin{aligned}
        x_{1}^{k+1} &= \underset{x_1}{\arg \min}\; L_{\rho}(x_1,x_2^k,y^k), \\
        x_{2}^{k+1} &= \underset{x_2}{\arg \min}\; L_{\rho}(x_1^{k+1},x_2,y^k), \\
        y^{k+1} &= y^k + \tau \rho (A_1x_1^{k+1} + A_2x_2^{k+1} - b),
\end{aligned}
$$

 where $`\tau`$ is a step size. The alternating minimization steps for $`x_1`$ and $`x_2`$ are followed by the iteration for the dual variable $`y`$. We have an additional assumption on the scheme [\[eq: admm update 1\]](#eq-admm-update-1)-[\[eq: admm update 3\]](#eq-admm-update-3) as below.

**Assumption 3**. *The subproblems [\[eq: admm update 1\]](#eq-admm-update-1) and [\[eq: admm update 2\]](#eq-admm-update-2) have a unique solution, respectively.*

The first item in Assumption [2](#assumption: ADMM) guarantees the convexity of the subproblems. Assumption [3](#assumption: ADMM 2) ensures the uniqueness of the solutions to the subproblems, which is crucial for well-defined iterations. This assumption, though seemingly strong, is necessary to ensure the convergence of iteration points to a KKT point of problem [\[eq: admm form\]](#eq-admm-form). Under the Slater's condition, the solution to problem [\[eq: admm form\]](#eq-admm-form) can be expressed as a KKT pair, enabling us to replace the solution with its corresponding KKT pair and simplify the analysis.

## Formalization of the Update Scheme

This subsection provides a detailed formalization of the ADMM method. First, we define the fundamental structure of the optimization problem, given by [\[eq: admm form\]](#eq-admm-form). This structure is formally represented using a `class` type in Lean as follows.

    class Opt_problem [FiniteDimensional ℝ E₁] [FiniteDimensional ℝ E₂] [FiniteDimensional ℝ F] where
      f₁ : E₁ → ℝ            f₂ : E₂ → ℝ
      A₁ : E₁ → L[ℝ] F       A₂ : E₂ → L[ℝ] F
      b  : F
      lscf₁ : LowerSemicontinuous f₁        lscf₂ : LowerSemicontinuous f₂
      cf₁ : ConvexOn ℝ univ f₁              cf₂ : ConvexOn ℝ univ f₂
      nonempty : ∃ x₁ x₂, (A₁ x₁) + (A₂ x₂) - b = 0 ∧ IsMinOn (fun (x₁, x₂) ↦ f₁ x₁ + f₂ x₂) univ (x₁, x₂)

The functions $`f_1`$ and $`f_2`$ are real-valued, lower semicontinuous (`lscf₁`, `lscf₂`), and convex (`cf₁`, `cf₂`). The domains of the functions are taken as the universe for simplicity. The property `nonempty` guarantees the second item in Assumption [2](#assumption: ADMM). Although $`A_1`$ and $`A_2`$ are originally defined as matrices, they are implemented as finite-dimensional linear maps in the code to enhance usability. The following definition captures the augmented Lagrangian function [\[eq: augmented lagrangian\]](#eq-augmented-lagrangian).

    def Augmented_Lagrangian_Function (opt : Opt_problem E₁ E₂ F) (ρ : ℝ) : E₁ × E₂ × F → ℝ :=  fun (x₁, x₂, y) => (opt.f₁ x₁) + (opt.f₂ x₂) + inner y ((opt.A₁ x₁) + (opt.A₂ x₂) - opt.b) + ρ / 2 * ‖(opt.A₁ x₁) + (opt.A₂ x₂) - opt.b ‖ ^ 2

ADMM alternately updates $`x_1`$ and $`x_2`$, minimizing one variable at a time while keeping the others fixed. To support this iterative process and prove convergence, we define the iteration structure and introduce auxiliary variables as follows.

    class ADMM extends (Opt_problem E₁ E₂ F) where
      x₁ : ℕ → E₁   x₂ : ℕ → E₂  y  : ℕ → F
      ρ  : ℝ        τ  : ℝ       hrho : ρ > 0
      htau : 0 < τ ∧ τ < (1 + sqrt 5) / 2
      iterx₁  : ∀ k, IsMinOn (fun x₁ ↦ (Augmented_Lagrangian_Function E₁ E₂ F toOpt_problem ρ) (x₁, x₂ k, y k)) univ (x₁ (k + 1))
      uiterx₁ : ∀ k, Admm_sub_Isunique (fun x₁ ↦ (Augmented_Lagrangian_Function E₁ E₂ F toOpt_problem ρ) (x₁, x₂ k, y k)) (x₁ (k + 1)) (iterx₁ k)
      iterx₂  : ∀ k, IsMinOn (fun x₂ ↦ (Augmented_Lagrangian_Function E₁ E₂ F toOpt_problem ρ) (x₁ (k + 1), x₂, y k)) univ (x₂ (k + 1))
      uiterx₂ : ∀ k, Admm_sub_Isunique (fun x₂ ↦ (Augmented_Lagrangian_Function E₁ E₂ F toOpt_problem ρ) (x₁ (k + 1), x₂, y k)) (x₂ (k + 1)) (iterx₂ k)
      itery   : ∀ k, y (k + 1) = y k + (τ * ρ) • ((A₁ $ x₁ (k + 1)) + (A₂ $ x₂ (k + 1)) - b)

The parameters $`\rho`$ and $`\tau`$ range within the intervals $`(0, \infty)`$ and $`\left(0, \frac{1 + \sqrt{5}}{2}\right)`$, respectively. The property `iterx₁` ensures that for any iteration index $`k`$, the point $`x_1^{(k+1)}`$ is a global minimizer of the function $`L(x_1, x_2^{(k)}, y^{(k)})`$. The uniqueness of this minimizer is established by `uiterx₁`. Similarly, `iterx₂` ensures that $`x_2^{(k+1)}`$ achieves global minimization for the function $`L(x_1^{(k+1)}, x_2, y^{(k)})`$, with its uniqueness established by `uiterx₂`. The iteration of the dual variable $`y`$ is defined by `itery`, which specifies the update formula for $`y^{(k)}`$ at each iteration.

The Karush-Kuhn-Tucker (KKT) conditions are necessary for optimality, given certain regularity assumptions. They are essential for determining the termination of the iterative process in the ADMM algorithm. For problem [\[eq: admm form\]](#eq-admm-form), these conditions have been adapted to align with the algorithm's framework and are expressed as follows:

<a name="eq-admm-kkt"></a>

$$
\begin{aligned}
  \begin{cases}
      &-A_1^Ty \in \nabla f_1(x_1), \\
     &-A_2^Ty \in \nabla f_2(x_2), \\
    &A_1x_1 + A_2x_2 = b.
  \end{cases}
  \end{aligned}
$$

 The formalization of the KKT conditions adheres to the structure of natural language and is presented below using the type `class`.

    class Convex_KKT (x₁ : E₁) (x₂ : E₂) (y : F) (opt : Opt_problem E₁ E₂ F) : Prop where
      subgrad₁ : -(ContinuousLinearMap.adjoint opt.A₁) y ∈ SubderivAt opt.f₁ x₁
      subgrad₂ : -(ContinuousLinearMap.adjoint opt.A₂) y ∈ SubderivAt opt.f₂ x₂
      eq : (opt.A₁ x₁) + (opt.A₂ x₂) = opt.b

## Convergence Analysis

This subsection describes the convergence of ADMM, with the convergence proof primarily based on [@Fazel2013hankelmatrix]. The proof is divided into two components: a lemma that verifies the descending property of an auxiliary sequence, and a theorem that establishes the convergence of the ADMM iterative sequence. We denote $`(x_1^{\ast}, x_2^{\ast}, y^{\ast})`$ as the KKT pair for the original problem and define the error vectors and auxiliary functions as follows:

$$
\begin{aligned}
    (e_1^k,e_2^k,e_y^k) &= (x_1^k,x_2^k,y^k) - (x_1^{\ast}, x_2^{\ast}, y^{\ast}),\\
    u^k &= -A_1^T[y^k + (1-\tau)\rho(A_1e_1^k + A_2e_2^k) + \rho A_2(x_2^{k-1} - x_2^k)],\\
    v^k &= -A_2^T[y^k + (1-\tau)\rho(A_1e_1^k + A_2e_2^k)],\\
    \Psi_k &= \frac{1}{\tau\rho}\|e_y^k\|^2 + \rho\|A_2e_2^k\|^2,\\
    \Phi_k &= \Psi_k + \max(1-\tau, 1-\tau^{-1})\rho\|A_1e_1^k + A_2e_2^k\|^2.
\end{aligned}
$$

 The functions $`u^k`$ and $`v^k`$ are related to the optimality conditions of each subproblem, $`\Psi_k`$ and $`\Phi_k`$ measure the errors $`(e_1^k, e_2^k, y^k)`$. All of these auxiliary variables are formalized using the `ADMM` namespace.

Our first step is to prove the descent of $`\Phi_k`$, implying the limits of the errors $`(e_1^k, e_2^k, y^k)`$ are zero.

Suppose that Assumptions [2](#assumption: ADMM) and [3](#assumption: ADMM 2) hold. Let $`\{(x_1^k,x_2^k,y^k)\}`$ be a sequence generated by the ADMM iterations [\[eq: admm update 1\]](#eq-admm-update-1) - [\[eq: admm update 3\]](#eq-admm-update-3). For each $`k \geqslant 1`$, it holds

$$
u^k \in \partial f_1(x_1^k),\quad v^k \in \partial f_2(x_2^k).
$$

 The error obtains a decrease as

<a name="eq-admm-theorem-1"></a>

$$
\begin{aligned}

    \begin{aligned}
        \Phi_k - \Phi_{k+1} \geqslant & \min(\tau, 1+\tau-\tau^2)\rho\|A_2(x_2^k - x_2^{k+1})\|^2 \\&+ \min(1, 1+\tau^{-1}-\tau)\rho\|A_1e_1^{k+1} + A_2e_2^{k+1}\|^2.
    \end{aligned}
\end{aligned}
$$

This lemma is formalized in Lean as below.

    lemma Φ_isdescending [Setting E₁ E₂ F admm admm_kkt] : ∀ n : ℕ+, (Φ n) - (Φ (n + 1)) ≥ (min τ (1 + τ - τ ^ 2)) * ρ * ‖A₂ (x₂ n - x₂ (n + 1))‖ ^ 2 + (min 1 (1 + 1 / τ - τ)) * ρ * ‖A₁ (e₁ (n + 1)) + A₂ (e₂ (n + 1))‖ ^ 2

We then outline the proof of this lemma, structured as follows:

1.  We prove that $`u^k`$ and $`v^k`$ belong to the subdifferentials of $`f_1`$ and $`f_2`$, respectively:

    $$
    \begin{aligned}
            u^{k+1} \in \partial f_1(x_1^{k+1}),  \quad  v^{k+1} \in \partial f_2(x_2^{k+1}).
          \end{aligned}
    $$

 This establishes that $`u^k, v^k`$ approximate the KKT pair and converge to it, due to the closed property of subgradients. The relevant proofs are provided in `uvBelongsToSubgradient`, `u_inthesubgradient`, and `v_inthesubgradient`.

2.  We establish an inequality that describes the lower bound of the difference in $`\Phi_k`$:

    $$
    \begin{aligned}
            &\frac{1}{\tau\rho} \left(\Vert e_y^k\Vert^2 - \Vert e_y^{k+1}\Vert^2\right)
            -(2 - \tau)\rho \Vert A_1x_1^{k+1} + A_2x_2^{k+1} - b\Vert^2\\
            &+2 M_{k+1} - \rho \Vert A_2(x_2^{k+1} - x_2^k)\Vert^2
            -\rho \Vert A_2e_2^{k+1}\Vert^2 + \rho \Vert A_2e_2^k\Vert ^2 \geqslant 0.
            \end{aligned}
    $$

3.  For cases where $`0<\tau<1`$ and $`\tau > 1`$, we categorize and discuss their properties. Finally, we can get the desired inequality [\[eq: admm theorem 1\]](#eq-admm-theorem-1).

This lemma provides the foundation for proving convergence. It establishes that the iterations generated by ADMM remain bounded throughout the process.

With the lemmas established above, we need only demonstrate the convergence of the series $`\{(x_1^k, x_2^k, y^k)\}`$. This can be achieved by proving the convergence of subsequences and using the monotonicity of the sequence.

Suppose that Assumptions [2](#assumption: ADMM) and [3](#assumption: ADMM 2) hold. Assuming that $`A_1`$ and $`A_2`$ have full rank and $`\tau \in \left(0,\frac{1+\sqrt{5}}{2}\right)`$, the series $`\{(x_1^k, x_2^k, y^k)\}`$ generated by the ADMM iterations [\[eq: admm update 1\]](#eq-admm-update-1) - [\[eq: admm update 3\]](#eq-admm-update-3) converge to a KKT pair of [\[eq: admm form\]](#eq-admm-form).

This theorem is defined in Lean as below.

    theorem ADMM_convergence [Setting E₁ E₂ F admm (admm_kkt₁ fullrank₁ fullrank₂ (admm_kkt := admm_kkt)] : ∃ (_x₁ : E₁) (_x₂ : E₂) (_y : F), Convex_KKT _x₁ _x₂ _y admm.toOpt_problem ∧ (Tendsto x₁ atTop (nhds _x₁) ∧ Tendsto x₂ atTop (nhds _x₂) ∧ Tendsto y atTop (nhds _y))

We hereby outline the key aspects of the proof, structured as follows:

1.  By Lemma [\[lemma: Lemma 20\]](#lemma: Lemma 20), the sequence $`\{(x_1^k, x_2^k, y^k)\}`$ is bounded. We can demonstrate that each of the sequences $`x_1^k, x_2^k, y^k, u^k, v^k`$ admits a convergent subsequence satisfying:

    $$
    \left(x_1^{\phi(k)}, x_2^{\phi(k)}, y^{\phi(k)}, u^{\phi(k)}, v^{\phi(k)}\right) \to (x_1'',x_2'',y'', -A_1^Ty'',-A_2^Ty''), \; \text{as} \; k \to \infty.
    $$

 Using monotonicity, we then prove the convergence of the entire sequence.

2.  The KKT conditions for problem [\[eq: admm form\]](#eq-admm-form) are given by [\[eq : ADMM KKT\]](#eq-admm-kkt). Based on the boundedness of the iterates and the diminishing residuals, we can conclude that the sequence $`\{x_1^k, x_2^k, y^k\}`$ converges to a point satisfying the KKT conditions:

    $$
    \begin{aligned}
          \begin{cases}
            &-A_1^Ty'' \in \partial f_1(x_1''),\\
            &-A_2^Ty'' \in \partial f_2(x_2''),\\
            &A_1(x_1'') + A_2(x_2'') = b.
          \end{cases}
          \end{aligned}
    $$

3.  We derive the convergence of the entire sequences $`x_1^k, x_2^k, y^k, u^k, v^k`$ from the descending property of $`\Phi^k`$.

Thus, under specified assumptions, the ADMM algorithm is guaranteed to converge to an optimal solution.

# Conclusion

In this paper, the formalization of two first-order optimization algorithms, BCD and ADMM, specifically targeting block-structured optimization problems, are provided in Lean4. To address nonsmooth and nonconvex objectives, the subdifferential and the KL property are formalized, together with related theorems crucial for convergence analysis. We give the formal update scheme of the numerical algorithms using the structure type. Building on these concepts, we prove that the BCD algorithm converges to the critical points, and the ADMM algorithm converges to the KKT points of the problem.

Our formalization framework can be naturally extended to derive further convergence results under alternative assumptions on the problem. Furthermore, numerous variations of BCD and ADMM documented in the literature can be formalized using our established methodology. For instance, various variants of the BCD algorithm, distinguished by slight modifications in their update schemes, can be systematically analyzed within this framework. Similarly, multiple versions of the ADMM algorithm are designed to accommodate specific problem structures. The formalization of these algorithms enables a more comprehensive study of the convergence properties of the ADMM method.

[^1]: corresponding author
