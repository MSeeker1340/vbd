---
type: Mathematical Specification
title: Contractive Fixed-Point Iteration
description: Contraction on invariant complete sets, geometric iterate bounds, derivative criteria, and stability under perturbations.
tags: [fixed-points, contraction, iteration, perturbations]
timestamp: 2026-09-14T00:00:00Z
---

In [implicit Euler as optimization](/mathematics/implicit-euler.md), a timestep is determined
by a stationary point of the incremental objective `G_IE`. VBD seeks this configuration through
repeated block-Newton updates, organized into serial or buffered colored sweeps using the
[block-operator algebra](/mathematics/block-states-and-operators.md). Each complete sweep is a
map on candidate configurations. The convergence question is whether repeatedly applying that
map approaches a stationary solution, and how much error remains after a fixed sweep budget.

Newton updates admit both an optimization interpretation and a root-finding interpretation.
A positive-definite local Hessian makes the Newton direction a descent direction away from
stationarity; decreasing the objective with the full step additionally requires control of the
quadratic model's error. Root finding targets the stationarity equation itself. Convergence to
a root can hold even when a step increases the objective or its direction fails to be a descent
direction. Minimization requires additional hypotheses about the stationary point.

The contraction approach certifies the actual sweep map on an invariant neighborhood of a
stationary solution. A uniform factor below one gives geometric convergence and finite-sweep
error bounds while permitting intermediate objective increases. Contraction and objective
descent provide different kinds of control over iteration: monotone objective
decrease alone implies neither contraction nor convergence of the iterates. A contraction
does decrease distance to its fixed point in the certified metric.

For VBD, the substantive certificate comes from controlling block inverses, cross-block
coupling, and their propagation through the actual execution order or simultaneous-batch
semantics. The [curvature and coupling analysis](/mathematics/curvature.md) supplies these
bounds, and the [implicit-Euler bridge](/project/roadmap.md#phase-5--implicit-euler-fixed-point-goals)
connects a designated fixed point to stationarity. The theory here provides the independent,
objective-free iteration estimates used by those layers. Its guarantees apply within the
certified region; practical convergence alone does not establish a contraction certificate.

# Setting and contraction

Fixed-point iteration applies a self-map repeatedly to solve its fixed-point equation. Let
`(X, d)` be a metric space, let `S ⊆ X`, and let `T : X → X`. For an initial point `x₀ ∈ S`, set

$$
x_{k+1}=T(x_k),\qquad x_k=T^k(x_0),\qquad T^0=\mathrm{id}.
$$

The set is **forward invariant** when `T(S) ⊆ S`. The map is a **contraction on S** with
factor `q` when `0 ≤ q < 1` and

$$
d(T(x),T(y))\le q\,d(x,y)\qquad(x,y\in S).
$$

The factor and the metric are part of the certificate. In a normed space the metric is
`d(x,y) = ‖x-y‖`, using the norm stated by the theorem. These assumptions concern an arbitrary
map; block structure, an objective, and mechanics enter through the bridge layers of the
[project architecture](/project/architecture.md).

# Banach fixed-point theorem on an invariant set

Suppose `S` is nonempty and complete in its induced metric, forward invariant under `T`, and
`T` is a contraction on `S`. Then there is a unique `x* ∈ S` with `T(x*) = x*`, and every
iteration starting in `S` converges to `x*`.

Completeness is required only of `S`. A nonempty closed subset of a complete metric space
supplies it, in particular a closed ball of nonnegative radius. An open neighborhood alone
need not be complete. The fixed point is unique within `S`; behavior outside `S` requires
separate hypotheses.

To see existence, contraction bounds consecutive steps by

$$
d(x_k,x_{k+1})\le q^k d(x_0,x_1).
$$

For `m > n`, the triangle inequality and a geometric sum give

$$
d(x_n,x_m)\le\sum_{j=n}^{m-1}q^j d(x_0,x_1)
\le\frac{q^n}{1-q}d(x_0,x_1).
$$

Thus the iterates are Cauchy and have a limit in `S`. Lipschitz continuity makes that limit a
fixed point. Two fixed points in `S` satisfy `d(x*,y*) ≤ q d(x*,y*)`, so their distance is zero.

If a fixed point `x* ∈ S` is already supplied, the geometric estimate below proves convergence
without completeness: completeness provides existence when the fixed point is unknown.

# Quantitative error and stopping bounds

For a fixed point `x* ∈ S` and any `x₀ ∈ S`, induction gives the finite-iteration bound

$$
d(x_k,x^*)\le q^k d(x_0,x^*)\qquad(k\ge0).
$$

With an available initial error bound `d(x₀,x*) ≤ R`, a budget of `k` iterations therefore
certifies error at most `q^k R`. For `0 < q < 1` and `0 < ε < R`, it suffices to take

$$
k\ge\left\lceil\frac{\log(R/\varepsilon)}{\log(1/q)}\right\rceil.
$$

If `R ≤ ε`, zero iterations suffice. If `q = 0`, one application reaches the fixed point.

The fixed-point defect also certifies distance: for every `x ∈ S`,

$$
d(x,x^*)\le\frac{d(x,T(x))}{1-q}.
$$

Indeed, the triangle inequality bounds the left side by `d(x,T(x)) + q d(x,x*)`.
Consequently the iterates satisfy both an a priori and an a posteriori estimate:

$$
d(x_k,x^*)\le\frac{q^k}{1-q}d(x_0,x_1),
\qquad
d(x_k,x^*)\le\frac{d(x_k,x_{k+1})}{1-q}.
$$

A fixed-point defect is a property of the solver map. Identifying it with, or comparing it to,
a physical equation residual requires an additional bridge. For example, if a residual map `F`
is `L`-Lipschitz on `S` and `F(x*) = 0`, then `‖F(x_k)‖ ≤ L d(x_k,x*)`.
The [implicit-Euler bridge](/project/roadmap.md#phase-5--implicit-euler-fixed-point-goals)
supplies this connection to [stationarity](/mathematics/implicit-euler.md).

# Adaptive stopping from the last update

After `k ≥ 1` exact iterations, let `Δ_k = d(x_k,x_{k-1})`. Applying the defect bound at
`x_k` and contraction to the pair `x_{k-1}, x_k` gives

$$
d(x_k,x^*)\le\frac{q}{1-q}\Delta_k.
$$

Thus `q Δ_k/(1-q) ≤ ε` certifies the current state's error without computing another sweep.
The formula also covers `q = 0`, when the first sweep reaches the fixed point.

A simpler rule stops when `Δ_k ≤ τ` for a chosen update tolerance `τ > 0`. This rule needs no
value of `q` to execute. Under the Banach hypotheses, existence of some `q < 1` ensures eventual
termination, but a state-error interpretation of `τ` requires quantitative information.
For example, `T(x) = (1-δ)x + δ` on `[0,1]`, with `0 < δ < 1`, contracts with factor `1-δ`.
Starting at zero gives a first displacement `δ` and remaining error `1-δ`. Arbitrarily small
updates can therefore coexist with substantial state error across this family.

Practical update-based stopping and [related adaptive VBD mechanisms](/references/adaptive-vbd-iterations.md)
are distinct from certified solution accuracy. Checks on observed history can detect failures;
they do not by themselves prove a uniform contraction bound or fixed-point/root consistency.

# Derivative and invariant-ball certificates

Let `X` be a real normed space and `S` a convex subset. Suppose `T : X → X` is Fréchet
differentiable at every point of `S` and its continuous-linear derivative satisfies

$$
\|DT(x)\|_{\mathrm{op}}\le q\qquad(x\in S),\qquad 0\le q<1.
$$

The mean-value inequality along segments in `S` gives `‖T(x)-T(y)‖ ≤ q ‖x-y‖` there.
This statement uses ambient differentiability at boundary points; within-set derivative
variants can use the corresponding mean-value hypotheses. Invariance and completeness are
separate premises of the fixed-point theorem.

A useful invariance certificate takes `S = closedBall(c,r)`, `r ≥ 0`, and assumes the
contraction bound on `S` together with

$$
\|T(c)-c\|\le(1-q)r.
$$

For `x ∈ S`, the triangle inequality yields

$$
\|T(x)-c\|\le q\|x-c\|+\|T(c)-c\|\le r.
$$

In a Banach space this certifies an invariant complete set. Centering at a known fixed point
makes the center defect zero.

For a local derivative certificate, suppose `T(x*) = x*`, `T` is differentiable on an open
neighborhood of `x*`, `DT` is continuous at `x*`, and `‖DT(x*)‖op < 1`. Choose
`‖DT(x*)‖op < q < 1`. Continuity supplies a sufficiently small positive closed-ball radius
on which `‖DT(x)‖op ≤ q`. The ball is invariant by the centered certificate, yielding local
geometric convergence. Quantitative derivative variation gives an explicit radius.

A spectral-radius estimate is distinct from an operator-norm estimate in the chosen norm.
Using spectral information requires a justified norm change or a contraction theorem for an
iterate. The [curvature and coupling layer](/mathematics/curvature.md) supplies derivative
bounds for concrete VBD execution maps.

# Optional extension: perturbed iteration

Perturbation theory transfers an accuracy guarantee from a contractive reference map to an
execution that approximates it. Each approximate update introduces fresh error, while subsequent
contraction damps earlier error. The estimates below quantify the resulting distance to the
reference fixed point and distinguish an eventual error neighborhood from exact convergence.

This extension is useful when the chosen analysis compares the actual sweep with a simpler
reference sweep, or when local solves are deliberately approximate. Such a comparison must
supply a bound on the discrepancy per sweep. Serial and buffered colored VBD can each be
analyzed directly as their own exact map; their convergence proofs do not inherently require
perturbation estimates. The [applicability study](/project/roadmap.md#applicability-gate-and-work-order)
determines whether a reference-map comparison is useful for a concrete target. Floating-point
error is another possible application, with its error bounds and verification deferred by the
[backlog](/project/backlog.md#deferred-by-the-current-route).

Let `T` contract on `S` with fixed point `x* ∈ S`. Suppose a sequence `y_k ∈ S` has nonnegative
step errors `ε_k` satisfying

$$
d(y_{k+1},T(y_k))\le\varepsilon_k.
$$

Writing `e_k = d(y_k,x*)`, the triangle inequality gives `e_{k+1} ≤ q e_k + ε_k`.
Unrolling this recurrence yields

$$
e_k\le q^k e_0+\sum_{j=0}^{k-1}q^{k-1-j}\varepsilon_j.
$$

The empty sum for `k = 0` is zero. This convolution bound separates three useful conclusions:

- **Persistent bounded errors:** if `ε_k ≤ ε̄`, then
  `e_k ≤ q^k e₀ + ε̄(1-q^k)/(1-q)` and `limsup e_k ≤ ε̄/(1-q)`.
  This guarantees an error neighborhood, not convergence to a point.
- **Vanishing errors:** if `ε_k → 0`, then `e_k → 0`. Split the convolution into a finite
  prefix, whose geometric weights vanish, and a tail bounded by an arbitrarily small
  constant times `1/(1-q)`. A geometric rate requires quantitative decay information.
- **Summable errors:** if `Σ ε_k < ∞`, then `e_k → 0` and additionally
  `Σ e_k ≤ (e₀ + Σ ε_k)/(1-q)`. Summing the nonnegative convolution proves the latter bound.

Membership `y_k ∈ S` must be established for the perturbed sequence as well. Invariance under
`T` alone controls exact iterates. For example, on `closedBall(c,r)`, the stronger margin

$$
\|T(c)-c\|+\bar\varepsilon\le(1-q)r
$$

ensures perturbed invariance by induction whenever `y₀` lies in the ball and every step error
is at most `ε̄`.

A related fixed-point stability bound compares maps. If `T` contracts on `S`, `T(x*) = x*`,
`U(y*) = y*`, both points lie in `S`, and `d(T(y*),U(y*)) ≤ δ`, then

$$
d(x^*,y^*)\le\frac{\delta}{1-q}.
$$

This estimate assumes the fixed point of `U` is supplied; existence and uniqueness for `U`
require their own hypotheses.

# Formalization foundation

Phase 3 is the generic dynamics foundation in the [roadmap](/project/roadmap.md).
[Mathlib](/references/mathlib.md) supplies the contraction predicate, Banach theorem,
invariant-subset restriction, iterate convergence, and geometric and defect bounds. Its
mean-value theory supplies the derivative-to-Lipschitz step. The project layer exposes the
local-set results used by later bridges and optional perturbation results when the selected
analysis requires a reference-map comparison. Exact declaration assessment and
implementation progress are tracked by [CT-01–CT-05](/project/backlog.md#phase-3--contractive-fixed-point-iteration).

# Citations

[1] [Pinned Mathlib contraction and fixed-point source](https://github.com/leanprover-community/mathlib4/blob/de5ce8a9a66a4aa68a9bdbb35b63a06d34d9ca11/Mathlib/Topology/MetricSpace/Contracting.lean) — Banach theorem, invariant subsets, distance estimates, and fixed-point stability.

[2] [Pinned Mathlib mean-value source](https://github.com/leanprover-community/mathlib4/blob/de5ce8a9a66a4aa68a9bdbb35b63a06d34d9ca11/Mathlib/Analysis/Calculus/MeanValue.lean) — derivative bounds on convex sets imply Lipschitz bounds.
