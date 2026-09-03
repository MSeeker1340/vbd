---
type: Mathematical Specification
title: Implicit Euler as Optimization
description: Derives the implicit-Euler incremental potential and specifies its derivatives, stationarity equation, and numerical character.
tags: [implicit-euler, classical-mechanics, gradient, hessian, stationary-point, numerical-analysis]
timestamp: 2026-09-02T00:00:00Z
---

# Data

Let `X` be a real Hilbert space, `h > 0` a timestep, `y : X` a predicted position, `M : X → X` a self-adjoint mass operator, and `E : X → ℝ` a potential energy. Define the weighted quadratic form by

$$
\lVert z\rVert_M^2 = \langle z, Mz\rangle
$$

and the incremental objective

$$
G_{\mathrm{IE}}(x)
=\frac{1}{2h^2}\langle x-y,M(x-y)\rangle+E(x).
$$

The derivative identity requires self-adjointness of `M` to simplify the derivative of the quadratic term to `M(x-y)/h²`. Positive definiteness is not needed for this identity; quantitative lower bounds belong to the later [curvature and coupling analysis](/mathematics/curvature.md).

# Classical-mechanics origin

The incremental potential is the optimization form of a standard route through classical
mechanics. For a conservative mechanical system with configuration `q`, velocity `v`, constant
mass operator `M`, and potential energy `E`, Hamilton's principle makes the action of the
Lagrangian

$$
L(q,v)=\frac12\langle v,Mv\rangle-E(q)
$$

stationary. Its differential form is the Euler–Lagrange equation, which here reduces to Newton's
equation

$$
M\ddot q=-\nabla E(q).
$$

Write this second-order equation as the first-order system

$$
\dot q=v,
\qquad
M\dot v=-\nabla E(q).
$$

One backward-Euler step evaluates both right-hand sides at the new state:

$$
q_{n+1}=q_n+h v_{n+1},
\qquad
M(v_{n+1}-v_n)=-h\nabla E(q_{n+1}).
$$

Eliminating `v_{n+1}` and defining the inertial prediction `y=q_n+h v_n` gives

$$
\frac1{h^2}M(q_{n+1}-y)+\nabla E(q_{n+1})=0.
$$

This is exactly the stationarity equation `∇G_IE(q_{n+1})=0`. Thus `G_IE` is not an
independent physical energy: it is an *incremental potential* whose critical points encode a
backward-Euler step. If external acceleration is treated explicitly, it can be absorbed into the
prediction, for example `y=q_n+h v_n+h²a_ext`, as in the VBD formulation [1]. This variational
form of backward Euler is standard in optimization-based simulation [2, 3].

# Numerical character of backward Euler

- **Convergence order.** Under the usual smoothness and well-posedness assumptions for the ODE,
  backward Euler has local truncation error `O(h²)` and global error `O(h)` on a fixed time
  interval: it is a first-order method [4]. This concerns the time discretization with each
  nonlinear step solved exactly; error from terminating the VBD solve early is a separate issue.
- **Stiff stability.** On the linear test equation `u' = λu`, its amplification factor is
  `R(z)=1/(1-z)`, where `z=hλ`. Hence `|R(z)|≤1` throughout the closed left half-plane and
  `R(z)→0` as `|z|→∞` there: backward Euler is A-stable and L-stable. Strongly decaying modes
  therefore do not impose the explicit Euler stability restriction, though large steps can still
  have poor accuracy.
- **Numerical dissipation.** For conservative oscillatory mechanics, backward Euler is not
  symplectic and introduces artificial damping. For the normalized harmonic oscillator, the
  one-step phase-space map scales the quadratic energy by `1/(1+h²)`, so energy and phase-space
  area contract at every step [5]. Smaller timesteps reduce this damping [1]. This is numerical,
  not physical, dissipation and is distinct from adding a Rayleigh or other damping force.

These properties explain the method's popularity for stiff deformable-body simulation: it trades
high-order and long-time conservation for robust suppression of unresolved high-frequency modes.
They do **not** imply that mechanical energy decreases for every nonlinear potential and every
step, nor that an arbitrary stationary point of a nonconvex `G_IE` is a minimizer.

# Phase-1 theorem targets

Under differentiability of `E` at `x`, prove

$$
\nabla G_{\mathrm{IE}}(x)
=\frac{1}{h^2}M(x-y)+\nabla E(x).
$$

Define the implicit-Euler residual by

$$
R_{\mathrm{IE}}(x)=\frac{1}{h^2}M(x-y)+\nabla E(x),
$$

then prove the pointwise equivalence

$$
R_{\mathrm{IE}}(x)=0
\iff
\nabla G_{\mathrm{IE}}(x)=0.
$$

This is an equivalence with stationarity, not with global minimization.

Under twice differentiability, represent and prove

$$
\nabla^2G_{\mathrm{IE}}(x)=\frac{1}{h^2}M+\nabla^2E(x).
$$

# Assumption ledger

| Claim | Needed assumptions |
|---|---|
| Phase-1 Lean interface | `ImplicitEulerStep` record containing a complete real inner-product state, self-adjoint continuous linear `M`, positive `h`, predicted `y`, and a potential `E` whose gradient is globally differentiable |
| Simplified gradient formula | Phase-1 interface invariant |
| Residual iff stationarity | gradient formula only |
| Hessian sum formula | Phase-1 interface invariant |
| Strict/strong convexity | a positive curvature lower bound |
| Unique minimizer | existence plus strict convexity, or a suitable strong-convexity theorem |

# Formalization notes

The Lean interface records one timestep problem and its constraints in an `ImplicitEulerStep` value: mass operator, twice-differentiable potential energy, timestep, predicted state, self-adjointness proof, and timestep-positivity proof. The module calls the objective `energy`, proves that it is globally differentiable, and identifies Mathlib's canonical `∇ ie.energy` with `ie.energyGradient`. Its Hessian is the inertia Hessian plus the canonical potential Hessian. The later implicit-Euler fixed-point bridge uses this gradient as its nonlinear residual. The API does not accept separate gradient or Hessian functions. The local particle-mass formula belongs in VBD synthesis, not here.

The implemented Phase 1 module, `Vbd/Integrator/ImplicitEulerEnergy.lean`, selects the Fréchet derivative of the gradient as its Hessian representation. It establishes Hessian existence without curvature bounds. Quantitative lower bounds from the inertia term, including their dependence on `h`, belong to the final VBD synthesis. API details and the representation rationale live in the source documentation.

# Citations

[1] [Vertex Block Descent](https://arxiv.org/html/2403.06321)
[2] [Physical Simulations, Chapter 6: Incremental Potential](https://cseweb.ucsd.edu/~alchern/teaching/Simulation.pdf)
[3] [Fast Simulation of Mass-Spring Systems](https://graphics.berkeley.edu/papers/Liu-FSM-2013-11/)
[4] [Energy-diminishing integration of gradient systems](https://www.unige.ch/~hairer/preprints/gradientflow.pdf)
[5] [A review of some geometric integrators](https://doi.org/10.1186/s40323-018-0110-y)
[6] [Mathlib gradient API](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Analysis/Calculus/Gradient/Basic.html)
