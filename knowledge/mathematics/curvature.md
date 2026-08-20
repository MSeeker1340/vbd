---
type: Mathematical Specification
title: Curvature Strengthening
description: Separates quadratic positive curvature from locality and records strong-convexity theorem targets.
tags: [curvature, strong-convexity, positive-definite, hessian]
timestamp: 2026-08-20T00:00:00Z
---

# Quadratic-plus-remainder model

Let

$$
G(x)=Q(x)+R(x),\qquad
Q(x)=\frac12\langle x-y,A(x-y)\rangle,
$$

where `A` is self-adjoint. Under the needed differentiability assumptions,

$$
\nabla Q(x)=A(x-y),\qquad
\nabla^2G(x)=A+\nabla^2R(x).
$$

# Lower-bound theorem target

Represent the Loewner-order hypotheses as nonnegativity of quadratic forms (or Mathlib's matrix/operator positivity API):

$$
\nabla^2R(x)\succeq-B,
\qquad
A-B\succ0.
$$

Then

$$
\nabla^2G(x)
=A+\nabla^2R(x)
\succeq A-B\succ0.
$$

The desired consequence is a strong-convexity statement with an explicit modulus. A qualitative `PosDef` fact alone may not expose a numerical modulus; in finite dimensions one may need a coercivity constant `m > 0` satisfying `m‖v‖² ≤ ⟨v,(A-B)v⟩`.

# Consequence ledger

| Curvature hypothesis | Intended consequence |
|---|---|
| Hessian positive semidefinite | convexity, given the required domain and smoothness theorem |
| Hessian bounded below by `m I`, `m > 0` | `StrongConvexOn` with modulus `m` |
| Strong convexity with `m > 0` | strict convexity |
| Strict convexity plus two minimizers | the minimizers are equal |
| Strong convexity plus existence/coercivity | unique minimizer |

# Formalization strategy

Mathlib already provides `StrongConvexOn`, its characterization by subtracting `m/2 * ‖x‖²`, and strict-convexity consequences. It also provides `Matrix.PosDef`, `Matrix.PosSemidef`, closure under sums for semidefinite matrices, positive-definite principal submatrices, and invertibility results. Decide early whether the main theorem is basis-free for continuous linear operators, with matrix corollaries, or matrix-native for finite coordinates.

No theorem in this layer should assume that `A` is diagonal. Locality-preserving sparsity of `A` is a separate VBD specialization question.

# Citations

[1] [Mathlib strong convexity](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Convex/Strong.html)
[2] [Mathlib positive-definite matrices](https://github.com/leanprover-community/mathlib4/blob/master/Mathlib/LinearAlgebra/Matrix/PosDef.lean)
