# VBD Formalization Project

## Goal

Formalize the mathematical core of **Vertex Block Descent (VBD)** in Lean 4:

$$
\text{implicit Euler as optimization}
\rightarrow
\text{generic local block optimization}
\rightarrow
\text{VBD-specific theory}.
$$

This is primarily a **proof/formalization project**, not a verified simulation implementation.

## Foundations

Use:

* **Mathlib** as the primary Lean 4 foundation for analysis, derivatives, linear algebra, matrices, convexity, finite sums, etc.
* **Optlib** (`verified-optimization/optlib`) as a reference base for existing formalizations of optimization results.

Important: the current public Optlib is written in **Lean 3**. Reuse its mathematical organization and results where useful, but port/adapt them to Mathlib/Lean 4 rather than introducing a Lean 3 dependency.

Before proving standard analysis or optimization results, search Mathlib and Optlib for reusable definitions or theorems.

## Core abstraction

The generic optimization layer uses a locally decomposed scalar objective

$$
G(x)=\sum_{e\in\mathcal E}G_e(x_{N(e)}),
$$

with block variables

$$
x=(x_1,\dots,x_N).
$$

Keep two structures distinct:

* **locality/sparsity** → efficient block computation;
* **positive curvature** → stronger analytical guarantees.

The implicit-Euler inertia/potential decomposition is a later specialization, not an assumption of the generic block theory.

## Development guidelines

For commits substantially produced by you, append an "Assisted-by: <agent name>" trailer to the commit message, for example "Assisted-by: OpenAI Codex". **DO NOT** produce overly-long commit messages nor stick too strictly to oneliner --- use your own judgements.

Maintain a project-local knowledgebase consolidating module docs, worklogs and long-term task tracking in the form of an [OKF bundle](https://okf.md/) using the official `okf-open-knowledge-format` skill.

## Roadmap

### Phase 1 — Implicit Euler as optimization

Define

$$
G_{\mathrm{IE}}(x) = \frac{1}{2h^2}|x-y|_M^2+E(x)
$$

and prove

$$
\nabla G_{\mathrm{IE}}(x) = \frac{M}{h^2}(x-y)+\nabla E(x)
$$

hence

$$
x^{n+1}\text{ solves implicit Euler}
\iff
\nabla G_{\mathrm{IE}}(x^{n+1})=0.
$$

Also derive

$$
\nabla^2G_{\mathrm{IE}} = \frac{M}{h^2}+\nabla^2E
$$

Use **stationary points** as the generic solution concept. Introduce minimum/uniqueness claims only under additional curvature assumptions.

### Phase 2 — Generic local block optimization

Formalize independently of mechanics:

1. local/global objective-change equivalence for a single block update;
2. locality of block gradients and block Hessians;
3. local descent implies global descent;
4. sequential Gauss–Seidel block sweeps give monotone descent;
5. local Newton descent under suitable block-Hessian and line-search assumptions;
6. stationary/global convergence under appropriate nonconvex, convex, and strongly convex assumptions;
7. graph coloring: independent blocks commute, so a color class can be updated in parallel.

Prefer instantiating established block-coordinate convergence theory rather than reproving it unnecessarily.

### Phase 2B — Curvature strengthening

For

$$
G(x)=Q(x)+R(x),
\qquad
Q(x)=\frac12(x-y)^TA(x-y),
\qquad
A\succ0
$$

use

$$
\nabla^2G=A+\nabla^2R
$$

In particular, from

$$
\nabla^2R(x)\succeq-B,
\qquad
A-B\succ0
$$

derive strong convexity and appropriate consequences such as uniqueness and stronger convergence guarantees.

Do not assume (A) is diagonal unless required.

### Phase 3 — VBD specialization

Instantiate the generic results on

$$
G_{\mathrm{IE}}(x) = \frac{1}{2h^2}|x-y|_M^2+E(x)
$$

Target:

* locality of particle-coordinate mass terms;
* positive curvature supplied by (M/h^2);
* locality-preserving non-diagonal mass matrices where feasible;
* VBD block-Hessian and conditioning results;
* error after finitely many VBD sweeps;
* per-timestep finite-solve error;
* accumulation of solver error over timesteps;
* separation of
  $$
  \text{time-discretization error}
  \quad\text{and}\quad
  \text{finite-optimization error}
  $$

## Suggested modules

```text
Optimization/
  LocalObjective.lean
  BlockCoordinate.lean
  GaussSeidel.lean
  BlockNewton.lean
  Coloring.lean
  Convergence.lean
  Curvature.lean

Integrator/
  ImplicitEulerEnergy.lean
  VBD.lean
```

Dependency direction:

```text
generic optimization theory
        ↓
implicit-Euler specialization
        ↓
VBD-specific theory
```

Do not allow VBD-specific implementation assumptions to leak upward.

## Formalization policy

* Keep assumptions explicit and as weak as practical.
* Do not replace “stationary point” by “minimum” without justification.
* Keep nonconvex, convex, and strongly convex results separate.
* Prefer small reusable lemmas over monolithic VBD theorems.
* Separate mathematics from implementation choices such as 3D particles, diagonal masses, coloring heuristics, or GPU kernels.
* Do not develop generic numerical-ODE infrastructure unless a target theorem actually requires it.
* Reuse or port Mathlib/Optlib results before proving standard optimization theory from scratch.

## Initial implementation order

```text
ImplicitEulerEnergy
→ LocalObjective
→ BlockCoordinate
→ GaussSeidel
→ Coloring
```

Postpone convergence rates, timestep-error accumulation, and generalized mass matrices until these definitions and basic descent lemmas stabilize.

## References

1. **Chen, A. H., Liu, Z., Yang, Y., Yuksel, C. — “Vertex Block Descent.”**
   Primary VBD reference. Defines VBD as block-coordinate descent on the variational implicit-Euler objective using vertex-level Gauss–Seidel iterations. arXiv:2403.06321.

2. **Lean Prover Community — Mathlib.**
   Repository: `leanprover-community/mathlib4`. Primary Lean 4 mathematical foundation for this project.

3. **Verified Optimization — Optlib.**
   Repository: `verified-optimization/optlib`. Lean 3 collection of formalized mathematical-optimization results. Use as a source for definitions/proofs to port or adapt to Lean 4/Mathlib.

4. **Verified Optimization — CvxLean.**
   Repository: `verified-optimization/CvxLean`. Lean 4 convex-optimization formalization built on Mathlib; useful for understanding the current successor ecosystem around Optlib.

5. **Tseng, P. — “Convergence of a Block Coordinate Descent Method for Nondifferentiable Minimization.”**
   *Journal of Optimization Theory and Applications*, 109(3), 2001, pp. 475–494. Standard convergence reference for block-coordinate descent; use as a starting point when determining which convergence theorem should be formalized or instantiated.

The project roadmap itself is maintained in the VBD formalization project notes and should take precedence over broader claims suggested by these references.
