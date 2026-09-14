---
type: Architecture Decision
title: First Quantitative VBD Applicability Route
description: Selects maximum-norm state contraction for bounded nonlinear axial chains and proper-color execution, with explicit accuracy and coverage limits.
tags: [applicability, theorem-route, maximum-norm, execution]
timestamp: 2026-09-14T00:00:00Z
---

# Decision (AP-03)

**Proceed with a scoped quantitative state-contraction theorem and independent root consistency.**
The [applicability study](/mathematics/applicability-study.md) supplies analytic estimates for
scalar axial chains with quadratic or hardening quartic springs, `0 ≤ η ≤ 1`, and
`h² k_max/m_min ≤ 1/4`. The scope includes arbitrary finite chain length, positive heterogeneous
masses and springs under these bounds, serial once-per-vertex sweeps, and even/odd proper-color
snapshot batches. The study's fixed predictor and intermediate-state bounds give a uniform
contraction factor `q < 0.512`, and a physical IE residual below `10⁻⁶` in at most 20 sweeps.
These are mathematical derivations awaiting Lean formalization, not completed Lean theorems.
AP-01–AP-03 are complete research deliverables; the quantitative end-to-end acceptance gate VB-08
remains open until the instantiated theorem is proved.

# Norm and execution boundary

Use the unweighted block maximum norm for the first contraction certificate. Retain `BlockSum`
and its existing `PiLp 2` representation in the independent algebra foundation; introduce the
maximum metric through a theorem-local normed representation or explicit equivalent metric
at the bridge, with distance-transport lemmas. The generic CT-04 derivative result must be
norm-polymorphic. No new Lean dependency is required by this decision.

The first production theorem covers static proper colors. Same-color live collision coupling,
approximate solves, floating-point execution, and perturbations are follow-on scope.
BC-04, CT-05 and the perturbation component of BC-05 are deferred until such an execution
variant has its own applicability certificate. They are not prerequisites of the initial
exact-execution theorem. Generic interaction support still includes higher-arity elements;
LI-03's multi-vertex coloring example remains required but carries no quartic-chain contraction claim.

# Guarantee comparison

State contraction plus skip-free fixed-point consistency supplies the selected full-range
finite-sweep guarantee. Quantitative physical-residual reduction with `θ ≤ 0.799` is available
on the smaller range `h² k_max/m_min ≤ 0.2`; it also gives qualitative progress there.
Strict residual progress alone is a weaker milestone and is not the selected end-to-end route.
The stress regime admits residual increases, including an exact quadratic example in the study.
The maximum norm resolves the avoidable Euclidean conversion loss; stronger weights, energy
norms and several-sweep estimates are optional work for a revised stiff-regime target.

The result applies to one timestep's solve with an inertia predictor within 5 mm of the rest
configuration at the selected `L=0.1 m` scale. It certifies neither accumulation over timesteps
nor general VBD production workloads. Non-descent convergence, nonconvex elasticity, contact,
and large-deformation warm starts remain outside the initial theorem. The separate rational
objective-increase example belongs to the same constitutive family but lies outside the
certified region and parameter range.

# Formal proof obligations and work order

1. **CT-04:** connect uniform derivative bounds on a convex neighborhood to the generic
   contraction interface, retaining freedom of norm and explicit domain hypotheses.
2. **LI-01–LI-04:** provide finite-support interactions and proper-color commutation, including
   the generic multi-vertex example and static-color validity boundary.
3. **IF-01–IF-03:** transport known-root state bounds to the explicitly scaled physical residual;
   IF-03 is required for the selected residual accuracy target.
4. **BC-01–BC-03 and exact BC-05:** compose changed-row comparison matrices in the supplied
   order, certify maximum-norm contraction, and transport distances from the block representation.
5. **VB-01–VB-04:** define the full-step scalar specialization and threshold, prove skip-free
   consistency independently, derive the full `f_i ∂D_i` derivative term, and prove inverse bounds.
6. **VB-05–VB-07:** instantiate degree-two coupling bounds, prove every intermediate update
   preserves the box, derive uniform contraction, and discharge proper-color execution equivalence.
7. **VB-08:** instantiate `B`, `Y`, `α`, `η`, predictor membership, root existence/bound, norm
   constants and the safe rounded 20-sweep residual estimate. Include the quadratic baseline and
   genuinely nonlinear quartic case, with the study's physical calibration and exclusions.

The [backlog](./backlog.md), [roadmap](./roadmap.md), and
[module map](/formalization/module-map.md) carry these dependencies. Extending the physical
scope or claiming convergent objective-increasing trajectories requires another applicability
assessment before broadening the theorem statement.
