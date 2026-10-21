---
type: Mathematical Specification
title: Implicit-Euler Solver Consistency and Fixed-Point Convergence
description: Specifies the unbiasedness condition that identifies contractive solver fixed points with implicit-Euler solutions and transports state error to residual error.
tags: [implicit-euler, fixed-points, contraction, residual, solver-consistency]
timestamp: 2026-10-21T02:29:26Z
---

The [implicit-Euler formulation](./implicit-euler.md) supplies the equation to solve, while
[contractive fixed-point iteration](./contractive-fixed-point-iteration.md) supplies convergence
facts for an arbitrary self-map. This specification identifies the additional solver-consistency
property that connects those independent layers. It applies to any solver map; Phase 7 supplies
the concrete regular VBD sweep consistency proof.

# Three layers of a solver guarantee

Let `X` be a real normed space, let `ie` be an implicit-Euler step, and write

$$
F(x)=R_{\mathrm{IE}}(x)=\nabla G_{\mathrm{IE}}(x)
=\mathrm{energyGradient}_{ie}(x).
$$

The Phase-1 gradient identity gives the displayed equality. An implicit-Euler solution is a point
`p` with `F(p) = 0`; it is a stationary point of `G_IE`. No minimization or uniqueness of such
points is implicit in this terminology.

For a block representation of this same $`X`$, Phase 2 separately supplies induced block-product
norms $`\lVert\cdot\rVert_p`$ for solver state error. The fixed-point statements below are
metric-generic: a later block certificate instantiates their state metric with a selected
$`\lVert\cdot\rVert_p`$. The implicit-Euler energy retains its Hilbert inner-product geometry, and
the vector residual $`R_{\mathrm{IE}}`$ is measured in the physical norm $`\lVert\cdot\rVert_X`$.

For a solver map `T : X → X` and a certified region `S ⊆ X`, the guarantees form a strict chain:

| Available property | Supported conclusion |
|---|---|
| `T` is only a self-map | Iteration is defined; it has no general convergence or equation-solving guarantee. |
| `T(S) ⊆ S` and `T` contracts on complete nonempty `S` | A unique solver fixed point exists in `S`; iterates converge geometrically to it with a state-distance bound. The fixed point need not solve `F(x) = 0`. |
| The contraction premises and `T` is unbiased for `F` on `S` | The unique solver fixed point is an implicit-Euler solution. A Lipschitz bound for `F` further turns state error into a residual bound. |

The second layer is entirely objective-free. The third is the first point at which the solver map
is connected to the equation it is intended to solve.

# Unbiasedness

The map `T` is **unbiased for `F` on `S`** when every fixed point in its certified region solves
the equation:

$$
\mathrm{UnbiasedOn}(F,T,S)
\quad\Longleftrightarrow\quad
\forall x\in S,\quad T(x)=x\ \Longrightarrow\ F(x)=0.
$$

This is a consistency condition, not a convergence condition. It says that the solver has no
spurious fixed point in `S`; it does not say that a solution exists, that `T` is continuous, or
that the iteration converges. The converse,

$$
F(x)=0\ \Longrightarrow\ T(x)=x,
$$

is **root preservation**. It is useful when describing all roots and fixed points, but it is not
needed to identify the Banach fixed point as a solution. A later concrete solver theorem may
establish either or both directions; the generic Phase-5 theorem requires only unbiasedness.

# Unbiased contractive convergence

Suppose `S` is nonempty and complete in its induced metric, `T(S) ⊆ S`, and

$$
\lVert T(x)-T(y)\rVert\le q\lVert x-y\rVert
\qquad(x,y\in S),\qquad 0\le q<1.
$$

If `T` is unbiased for `F` on `S`, then there is a point `p ∈ S` such that

$$
T(p)=p,
\qquad F(p)=0,
$$

and `p` is the unique **solver fixed point** in `S`. For every `x₀ ∈ S`, with
`x_k = T^k(x₀)`,

$$
\lVert x_k-p\rVert\le q^k\lVert x_0-p\rVert,
\qquad x_k\longrightarrow p.
$$

The conclusion does not claim that `p` is the unique implicit-Euler stationary point in `S`.
That requires root preservation as well, or an independent uniqueness theorem for the residual.
Completeness is used only to obtain an unknown fixed point. When a fixed point is already supplied,
the geometric state estimate needs neither completeness nor unbiasedness; unbiasedness adds the
equation-solving interpretation.

# Residual transport

Suppose in addition that `F` is `L`-Lipschitz on `S`:

$$
\lVert F(x)-F(y)\rVert\le L\lVert x-y\rVert
\qquad(x,y\in S).
$$

Unbiasedness gives `F(p)=0`, so the contraction estimate yields

$$
\lVert F(x_k)\rVert
\le L\lVert x_k-p\rVert
\le Lq^k\lVert x_0-p\rVert.
$$

Thus `Lq^kR ≤ ε` certifies residual at most `ε` whenever the initial state error is at most `R`.
A physically scaled residual requires its own Lipschitz bound. A derivative operator-norm bound
for `F` on a convex region is one route to the required Lipschitz premise.

When the contraction state metric is an induced block norm $`\lVert\cdot\rVert_p`$, the corresponding
residual-regularity premise is explicitly

$$
\lVert R_{\mathrm{IE}}(x)-R_{\mathrm{IE}}(y)\rVert_X
\le L\lVert x-y\rVert_p.
$$

It is a cross-norm residual-regularity condition. It does not assert that contraction in
$`\lVert\cdot\rVert_p`$ is contraction in $`\lVert\cdot\rVert_X`$.

This is an upper bound on residual from state error. It supplies neither a reverse state-error
bound nor per-sweep residual decrease. Those stronger results need a residual lower bound or a
separate model-specific argument.

# Formalization interface

`Vbd.Integrator.FixedPoint` imports only `Vbd.Integrator.ImplicitEulerEnergy` and
`Vbd.Dynamics.Contraction`. Its generic interface takes a metric solver state `Z` and a residual
`F : Z → Y` with an independently normed codomain. For a representation `e : Z ≃ X`, use
`F = energyGradient ie ∘ e` and the solver conjugated by `e`. The residual keeps the Hilbert norm
on `X`, and `Z` carries the selected solver metric. Unbiasedness transports along the equivalence
without any norm assumption. Completeness and invariance are premises in the selected state metric.

The module implements:

| Backlog item | Premises added at the bridge | Conclusion |
|---|---|---|
| IF-01 | Complete nonempty invariant contraction region and `UnbiasedOn F T S` | The unique solver fixed point in `S` exists and is a residual root; an IE residual identifies its represented state as stationary. |
| IF-02 | IF-01 and `x₀ ∈ S` | The iterates converge to that solution with the geometric distance bound. |
| IF-03 | IF-02 and `LipschitzOnWith L F S` between the selected state metric and residual norm | The residual has the displayed geometric upper bound. |

The generic declarations are `UnbiasedOn.exists_fixedPoint`, `UnbiasedOn.norm_iterate_le`, and
`UnbiasedOn.comp_equiv`. The module also exports the same-space IE specializations
`energyGradient_eq_zero_of_unbiased_fixedPoint`,
`exists_unbiased_fixedPoint`, `dist_iterate_fixedPoint_le`, `tendsto_iterate_fixedPoint`, and
`norm_energyGradient_iterate_le`. The generic module does not prove unbiasedness for a particular
update formula. `Integrator/VBD` proves it for the regular concrete sweep; its result discharges
the IF-01 premise. Metric distance stays at the contraction boundary, with `dist_eq_norm` used
only for the normed residual statement. No block decomposition, coloring, Hessian inverse, chain
coefficient, or concrete execution order belongs in the generic bridge.

The [physical finite-chain certificate](./axial-spring-contraction.md#instantiating-the-formal-results)
instantiates this separation with the maximum-norm solver state and a mass-scaled maximum residual,
while identifying roots through the physical Hilbert-space energy gradient. Its residual regularity
constant is `53/25`, and its predictor-to-root distance is at most `1/10`; these multiply the
geometric state factor to give the finite-sweep physical-residual budget.
