---
type: Mathematical Specification
title: Implicit-Euler Solver Consistency and Fixed-Point Convergence
description: Specifies the unbiasedness condition that identifies contractive solver fixed points with implicit-Euler solutions and transports state error to residual error.
tags: [implicit-euler, fixed-points, contraction, residual, solver-consistency]
timestamp: 2026-09-16T00:00:00Z
---

The [implicit-Euler formulation](./implicit-euler.md) supplies the equation to solve, while
[contractive fixed-point iteration](./contractive-fixed-point-iteration.md) supplies convergence
facts for an arbitrary self-map. This specification identifies the additional solver-consistency
property that connects those independent layers. It applies to any solver map; the concrete VBD
proof is a Phase-7 obligation.

# Three layers of a solver guarantee

Let `X` be a real normed space, let `ie` be an implicit-Euler step, and write

$$
F(x)=F_{\mathrm{IE}}(x)=\nabla G_{\mathrm{IE}}(x)
=\operatorname{energyGradient}_{ie}(x).
$$

The Phase-1 gradient identity gives the displayed equality. An implicit-Euler solution is a point
`p` with `F(p) = 0`; it is a stationary point of `G_IE`. No minimization or uniqueness of such
points is implicit in this terminology.

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
\operatorname{UnbiasedOn}(F,T,S)
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
needed to identify the Banach fixed point as a solution. Exact regular VBD satisfies both
directions; the generic Phase-5 theorem requires only unbiasedness.

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

This is an upper bound on residual from state error. It supplies neither a reverse state-error
bound nor per-sweep residual decrease. Those stronger results need a residual lower bound or a
separate model-specific argument.

# Canonical VBD consistency check

Consider free blocks indexed by `i`. On a regular branch of the canonical local VBD update, let
the local residual be the corresponding block of the same global residual, `F_i(x)`, and let
`B_i(x)` be invertible. The paper's force convention is `f_i = -F_i`; its Newton update is
equivalently

$$
U_i(x)_i=x_i-B_i(x)^{-1}F_i(x),
\qquad
U_i(x)_j=x_j\quad(j\ne i).
$$

The matrix `B_i` need not be the exact block Hessian for this fixed-point argument; invertibility
and the displayed residual identity suffice. In particular, a root is preserved because every
correction is zero.

For a serial sweep that visits each free block exactly once, the converse follows by induction in
the visit order. If the completed sweep fixes `x`, the first block is never written again, so its
local correction is zero. Invertibility gives `F_i(x)=0`, and the first update has left the state
unchanged. Repeating this argument shows that every update is zero at the original `x`, hence
`F(x)=0`. Therefore the regular serial sweep is unbiased, and in fact

$$
T_{\mathrm{serial}}(x)=x
\quad\Longleftrightarrow\quad F(x)=0.
$$

For a buffered color batch, every vertex writes only its own output block computed from the common
pre-batch snapshot. If a completed colored sweep fixes `x`, no later color rewrites a block from
an earlier color. The same induction over colors shows every block correction is zero and hence
`F(x)=0`. This argument does not require same-color commutation: proper coloring is needed to
identify the buffered batch with a serial ordering and to obtain the selected contraction bound,
not for fixed-point-to-residual consistency. Thus a regular buffered sweep is also unbiased. A
proper static coloring gives the stronger equality with its serial counterpart.

These conclusions apply to a fixed smooth energy and a fixed execution plan. They match the
paper's per-vertex Newton equation and its buffered color-pass semantics [1]. The Phase-7
formalization packages the once-per-free-block and regularity assumptions into the concrete
execution theorem.

## Production boundaries

The literal production algorithm described in the VBD paper is not unconditionally unbiased for
the Phase-1 residual.

- The implementation bypasses a vertex update when its local Hessian is nearly singular. A skipped
  block can have `F_i(x) ≠ 0` while making a zero correction; the paper explicitly notes that all
  vertices can then freeze. The fixed-point-to-residual implication fails without a regular-region
  premise excluding this branch.
- Fixed positional constraints require the residual projected to the free or constrained subspace.
  A prescribed coordinate may legitimately have a nonzero full-space gradient because it carries a
  reaction force.
- Collision detection schedules, frozen contact geometry, and friction approximations must define
  one fixed residual and one fixed map before this property can be stated. Their relationship to
  the exact gradient of a fully coupled implicit-Euler energy is an additional model-specific
  proof obligation. Acceleration similarly requires an augmented state because it depends on
  earlier iterates.

The accepted first theorem avoids these boundaries: it uses the skip-free nonlinear axial chain,
a static proper coloring, and the stated fixed potential. The general VBD theorem records exactly
which branch and residual it analyzes rather than assigning the property to every implementation
feature at once.

# Formalization target

`Vbd.Integrator.FixedPoint` imports only `Vbd.Integrator.ImplicitEulerEnergy` and
`Vbd.Dynamics.Contraction`. It defines the generic `UnbiasedOn` predicate and proves:

| Backlog item | Premises added at the bridge | Conclusion |
|---|---|---|
| IF-01 | Complete nonempty invariant contraction region and `UnbiasedOn (energyGradient ie) T S` | The unique solver fixed point in `S` exists and is an IE stationary solution. |
| IF-02 | IF-01 and `x₀ ∈ S` | The iterates converge to that solution with the geometric distance bound. |
| IF-03 | IF-02 and `LipschitzOnWith L (energyGradient ie) S` | The IE residual has the displayed geometric upper bound. |

The generic module does not prove unbiasedness for a particular update formula. `Integrator/VBD`
proves it for the regular concrete sweep; its result discharges the IF-01 premise. Metric distance
stays at the contraction boundary, with `dist_eq_norm` used only for the normed residual statement.
No block decomposition, coloring, Hessian inverse, chain coefficient, or concrete execution order
belongs in the generic bridge.

# Citation

[1] [Vertex Block Descent reference note](/references/vbd-paper.md), especially the local Newton
equation and color-buffer execution described in the [source transcript](/references/vbd-paper-full.md#31-global-optimization)
and [parallelization section](/references/vbd-paper-full.md#39-parallelization).
