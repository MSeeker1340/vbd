---
type: Research Reference
title: Adaptive VBD Iterations and Stopping Criteria
description: Distinguishes update-based early stopping, adaptive solver mechanisms, and certified solution-error bounds in VBD-related work.
tags: [vbd, adaptive-iterations, stopping-criteria, contraction, residuals]
timestamp: 2026-09-11T00:00:00Z
---

# Scope and evidence

Adaptive iteration counts terminate a timestep's nonlinear solve according to observed progress.
Adaptive initialization, acceleration, penalty updates, and substepping change other parts of
the algorithm. The sources below establish examples of these mechanisms; they do not establish
a VBD stopping rule certified by a uniform Banach contraction factor. This is a bounded source
assessment, not a claim that such research is absent from the literature. Mutable implementation
and documentation links identify the versions inspected on 2026-09-11.

# Related research and implementations

| Source | Adaptive mechanism or iteration policy | Relationship to certified stopping |
|---|---|---|
| Chen, Liu, Yang, and Yuksel, *Vertex Block Descent* (2024), §§3.7–3.8 and Algorithm 1 [1] | Adaptive initial guesses use previous-step acceleration; Chebyshev acceleration uses an estimated spectral radius, set manually or tuned; the algorithm has an iteration budget | The spectral estimate controls acceleration, not a proved upper bound on remaining solution error |
| Giles, Diaz, and Yuksel, *Augmented Vertex Block Descent* (2025), §3 and Algorithm 1 [2] | Augmented-Lagrangian multiplier and penalty-stiffness updates address hard constraints and stiffness contrast; the simulation loop uses a prescribed iteration count | Adaptive penalties change the solver state; they are distinct from an adaptive stopping decision |
| Giles and Andrews, *Adaptive Sub-stepping for Constrained Rigid Body Simulations* (MIG 2024) [3] | A diagonalized geometric-stiffness heuristic selects smaller timesteps and the number of substeps | Related rigid-body work, rather than a VBD contraction-based stopping theorem |
| `mmichelis/WarpVBD`, README and `src/vbd_solver.py` [4, 5] | A configurable update threshold can terminate the solve before its maximum iteration count | Direct evidence of practical early stopping without a certified contraction factor |
| Newton Physics, `SolverVBD` API [6] | Exposes `iterations` as the number of VBD iterations per step | Evidence of a configured iteration budget; the API description does not attribute this choice to difficulty estimating contraction |

The WarpVBD README describes an update-norm tolerance. In the inspected source, the actual test
is `abs(dxs.numpy().sum(1)).max() < dx_tol`: it takes the maximum absolute signed coordinate sum
per vertex. Coordinate cancellation makes this different from a norm on displacement vectors.
The stopping condition supplies no contraction certificate or physical-residual error bound.
This implementation illustrates early stopping, not a validated solution-distance estimator. [4, 5]

# Meaning of an adaptive threshold

For exact iterates of a fixed map, a stopping rule based on the last displacement needs no
numerical contraction factor to execute. If the Banach hypotheses hold for some factor below
one, those displacements tend to zero, so every positive displacement threshold is eventually
met. A chosen threshold measures update size; it does not by itself measure distance to the root.

The [contractive iteration specification](/mathematics/contractive-fixed-point-iteration.md)
gives the stronger certificate: for `k ≥ 1`, a known valid upper bound `q < 1` implies
`d(x_k,x*) ≤ q d(x_k,x_{k-1})/(1-q)`. Other quantitative error estimates can serve the same
engineering purpose. A physical-residual tolerance can be checked directly without `q`, while
converting that tolerance into state error requires its own bound. Fixed-point consistency
connects the solver's limiting state to the implicit-Euler equation.

Existence of a contraction factor, an empirical rate estimate, and a certified computable upper
bound are separate deliverables. The last can come from analytic inequalities with evaluated
parameters or validated numerical bounds; a closed-form optimal factor is unnecessary.
Observed displacement ratios alone do not bound all future iterates or every state in a region.

# Engineering interpretation for the project

The original VBD paper explicitly motivates iteration budgets by bounded computation time [1].
The cited sources support that motivation and examples of heuristic adaptivity. They provide no
basis for concluding that production solvers use fixed counts specifically because a contraction
factor is difficult to obtain.

For this project, a certified stop test is a small mathematical consequence of an applicable
quantitative certificate. Its practical value depends on certificate cost, conservatism, norm
conversion, and monitoring overhead relative to the sweeps saved. These are evaluation questions,
not established performance gains. A runtime cap can coexist with an accuracy test, with separate
outcomes for tolerance reached and budget exhausted.

The [applicability study](/project/roadmap.md#applicability-gate-and-work-order) can compare
update thresholds, direct physical-residual thresholds, and certified state-error stopping on
the same family. Exact-arithmetic guarantees apply to the specified execution map. Acceleration
with memory, adaptive penalties, and changing contacts require a matching state/map analysis;
floating-point certification requires numerical-error bounds beyond the initial scope.

# Citations

[1] [Vertex Block Descent, arXiv v4](https://arxiv.org/html/2403.06321v4), with [project reference notes](./vbd-paper.md).

[2] [Augmented Vertex Block Descent, author-hosted paper](https://graphics.cs.utah.edu/research/projects/avbd/Augmented_VBD-SIGGRAPH25.pdf), [author project page](https://graphics.cs.utah.edu/research/projects/avbd/).

[3] [Adaptive Sub-stepping for Constrained Rigid Body Simulations, author publication page](https://profs.etsmtl.ca/sandrews/publication/adaptsubstep_mig2024/).

[4] [WarpVBD README and tolerance benchmark](https://github.com/mmichelis/WarpVBD#tolerance).

[5] [WarpVBD solver source](https://github.com/mmichelis/WarpVBD/blob/main/src/vbd_solver.py).

[6] [Newton Physics SolverVBD API](https://newton-physics.github.io/newton/latest/api/_generated/newton.solvers.SolverVBD.html).
