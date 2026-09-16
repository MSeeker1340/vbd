---
type: Mathematical Specification
title: Implicit-Euler Fixed-Point Bridge
description: Connects a certified solver fixed point to implicit-Euler stationarity and transports contraction error to an implicit-Euler residual bound.
tags: [implicit-euler, fixed-points, contraction, residual, iteration]
timestamp: 2026-09-16T00:00:00Z
---

The [implicit-Euler formulation](./implicit-euler.md) defines one timestep by stationarity of
its incremental energy. The [contractive fixed-point foundation](./contractive-fixed-point-iteration.md)
certifies convergence of an arbitrary solver map once a fixed point and an invariant contraction
region are supplied. This bridge states exactly how those facts combine without assuming a
particular block-update formula. The production VBD map enters only in Phase 7.

# Setting

Let `X` be a real normed space, let `ie` be an implicit-Euler step, and write

$$
F_{\mathrm{IE}}(x)=\nabla G_{\mathrm{IE}}(x)
=\operatorname{energyGradient}_{ie}(x).
$$

The equality is the Phase-1 gradient identity. A point `p : X` is an implicit-Euler solution
when

$$
F_{\mathrm{IE}}(p)=0.
$$

It is therefore a stationary point of `G_IE`. This is the solution concept used by this bridge;
neither minimization nor uniqueness of stationary points is assumed.

Let `S ⊆ X` be a certified region and `T : X → X` a solver map. The bridge takes the following
data as independent premises:

$$
p\in S,\qquad F_{\mathrm{IE}}(p)=0,\qquad T(p)=p,
$$

$$
T(S)\subseteq S,\qquad
\lVert T(x)-T(y)\rVert\le q\lVert x-y\rVert
\quad(x,y\in S),\qquad 0\le q<1.
$$

The stationary and solver-fixed-point statements are deliberately separate. They are the
root-preservation and root-identification obligation for the concrete solver. For a VBD sweep,
Phase 7 proves them from the actual local-update semantics, including the selected skip behavior.

# Solver-independent stationary convergence

Under the setting above, `p` is the unique fixed point of `T` in `S`. Every `x₀ ∈ S` has
iterates `x_k = T^k(x₀)` remaining in `S` and satisfying

$$
\lVert x_k-p\rVert\le q^k\lVert x_0-p\rVert.
$$

Consequently `x_k → p`, and the solver converges geometrically to the designated
implicit-Euler stationary point. Completeness of `S` is unnecessary for this conclusion because
`p` is supplied. If the solver fixed point is not known beforehand, nonemptiness and completeness
of the invariant region give existence through the Banach theorem; showing that the resulting
point solves the implicit-Euler equation still requires solver consistency.

The conclusion is uniqueness of a **solver fixed point** in `S`. It does not assert that `p` is
the only stationary point of `G_IE` in `S`: that stronger claim needs a converse such as
`F_IE(x) = 0 → T(x) = x`, together with the displayed fixed-point uniqueness, or independent
curvature hypotheses. Likewise, a contraction certificate alone does not identify an arbitrary
fixed point with a physical solution.

This result is IF-01. Its finite-iteration form is IF-02; both reuse the generic local
contraction interface rather than reproving Banach theory for implicit Euler.

# Residual transport

State convergence becomes a quantitative implicit-Euler residual guarantee when the residual is
Lipschitz on the same region. Suppose a constant `L ≥ 0` satisfies

$$
\lVert F_{\mathrm{IE}}(x)-F_{\mathrm{IE}}(y)\rVert
\le L\lVert x-y\rVert\qquad(x,y\in S).
$$

Since `F_IE(p) = 0`, the iterate bound gives

$$
\lVert F_{\mathrm{IE}}(x_k)\rVert
\le L\lVert x_k-p\rVert
\le Lq^k\lVert x_0-p\rVert.
$$

Thus an initial state-error allowance `R` and a residual tolerance `ε` are certified by

$$
\lVert x_0-p\rVert\le R,
\qquad Lq^kR\le\varepsilon.
$$

The same statement applies to a physically scaled residual `R_phys = A ∘ F_IE` after supplying
its own Lipschitz constant on `S`. The scaling and the bound belong to the concrete model; Phase
5 only transports any such established regularity. A derivative bound
`‖DF_IE(x)‖op ≤ L` on a convex region is one sufficient route to this premise, but is not part of
the solver-independent theorem.

This transport is one-way. The upper residual estimate does not give a state-error estimate or
stepwise residual decrease. Either conclusion needs an additional residual lower bound,
monotonicity argument, or problem-specific result. In particular, state contraction can permit an
intermediate increase of the physical residual while still forcing it to zero at the geometric
rate above.

# Formalization target

`Vbd.Integrator.FixedPoint` imports only `Vbd.Integrator.ImplicitEulerEnergy` and
`Vbd.Dynamics.Contraction`. Its public declarations take the solver map, certified set,
designated point, contraction premises, and residual-regularity constant as parameters. The
Phase-1 API supplies `ie.energyGradient` and its equality with the canonical gradient of
`ie.energy`; the Phase-3 API supplies set invariance, fixed-point uniqueness, convergence, and
the finite distance bound.

The intended theorem family is:

| Backlog item | Premises added at the bridge | Conclusion |
|---|---|---|
| IF-01 | `energyGradient ie p = 0` and `IsFixedPt T p`, plus local contraction | `p` is the unique solver fixed point in `S` and is an IE stationary solution |
| IF-02 | IF-01 premises and `x₀ ∈ S` | `dist (T^[k] x₀) p ≤ q^k * dist x₀ p` and convergence to `p` |
| IF-03 | IF-02 premises and `LipschitzOnWith L (energyGradient ie) S` | `‖energyGradient ie (T^[k] x₀)‖ ≤ L q^k ‖x₀-p‖` |

The formal theorem should state metric distance at the generic contraction boundary and use
`dist_eq_norm` only where the residual norm is required. Completeness remains local to an
existence theorem for an unknown solver fixed point. No block decomposition, component support,
coloring, Hessian inverse, or chain-specific coefficient occurs in this module.

# Role in the theorem chain

Phase 5 consumes the stationary-point identity from Phase 1 and the iteration facts from Phase 3.
Phase 6 establishes contraction certificates for supplied block-update executions. Phase 7 supplies
the concrete VBD sweep, proves the solver consistency premises, and instantiates the residual
regularity bound for the accepted axial-chain certificate. The resulting finite-sweep conclusion
concerns the stated local region and one implicit-Euler timestep.

The [axial-spring analysis](./axial-spring-contraction.md) supplies a worked `L` and a scaled
residual for its predictor box. Its 20-sweep target is an application obligation, not a restriction
on this generic bridge.
