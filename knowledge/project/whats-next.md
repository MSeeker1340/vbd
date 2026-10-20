---
type: Project Roadmap
title: "What’s Next: Extensions of the VBD Formalization"
description: Describes optional extensions of the completed library and the additional mathematics each requires.
tags: [future-work, reuse, applicability, vbd]
timestamp: 2026-10-20T21:12:52Z
---

# A completed foundation

The accepted Phase 1–7 program is complete. The [backlog](./backlog.md) records its
delivered results. The library connects implicit-Euler stationarity, exact block-Newton
execution, and contractive iteration through reusable interfaces. Its finite nonlinear
spring-chain instance proves convergence of serial and proper-color plans to the same
physical stationary point, meeting the selected residual tolerance in 20 sweeps under
explicit system and warm-start assumptions.

The directions below are independent follow-on projects. Each extends the theorem's
model, execution, or accuracy scope and requires its own applicability assessment.
The [module map](/formalization/module-map.md) identifies the reusable interfaces;
the [extension analysis](/mathematics/axial-spring-contraction.md#reuse-beyond-the-chain)
develops the model-specific mathematics in greater detail.

# Richer mechanical models

Vector-valued springs on finite graphs are a close extension of the checked scalar chain.
The mathematical article supplies analytic bounds in terms of total incident stiffness
relative to mass, including a dimension-independent vector estimate. Formalizing this
instance would exercise actual matrix block solves while retaining smooth convex forces
and static support coloring. The vector estimate itself is not yet a Lean theorem.

Geometric springs and triangle or tetrahedral elasticity require constitutive-law bounds
for local inverses, mixed-block coupling, and Hessian variation, together with an invariant
region and covered warm starts. Negative potential curvature can be offset by sufficient
inertia, but local invertibility alone supplies no sweep contraction factor. The chain's
scalar root-location argument also needs an appropriate replacement.

The implicit-Euler foundation already accepts a continuous-linear mass operator.
A concrete non-diagonal mass specialization must account for its off-diagonal blocks in
the update's read dependencies, support graph, and coupling estimates. This is a model
extension using the existing representation.

# Broader convergence certificates

The current maximum-norm comparison gives a sufficient certificate on the accepted
parameter range. Weighted norms, energy norms, sharper ordered comparison products, or
contraction over several sweeps could admit stiffer systems or larger warm-start regions.
A useful extension must demonstrate a quantitative gain for a stated family and retain
the actual execution map, region preservation, and physical-residual transport.

Convergence from arbitrary initial states requires additional global hypotheses. For a
specific model, a descent argument or a safeguarded solver could provide a route into a
certified region. Any changed update needs its own consistency and convergence theorem;
the existing local certificate does not establish such a global result.

# Coupled batches and evolving contacts

The block algebra defines simultaneous snapshot updates even when they do not commute.
The accepted colored contraction theorem uses proper support colors, so each batch is
equivalent to a sequential enumeration. With same-color coupling, a new certificate must
bound the actual simultaneous map and prove intermediate-state and batch invariance.

Dynamic contacts add changing dependencies and possibly nonsmooth activation boundaries.
An extension must track coloring validity and establish bounds across the relevant contact
branches. Lagged contact data belongs in the solver state, or in an explicit varying-map
analysis. Friction may require a nonsmooth solution concept and a replacement for the
smooth energy-gradient bridge. These are separate physical and execution obligations.

# Error across timesteps

The current theorem bounds a finite solve of one implicit-Euler step. A simulation-wide
result needs stability of the step-to-step map, renewed warm-start coverage, and a recurrence
propagating the finite-solve error. Comparing the resulting trajectory to a continuous
mechanical solution additionally requires an independently stated and bounded implicit-Euler
discretization error. Solver error and discretization error then enter a common trajectory
bound through explicit stability estimates.

# Certificate-guided solver tooling

An offline analyzer could turn system parameters and region bounds into a validated
contraction factor and iteration budget. The library supplies a mathematical interface
for checking such certificates; an analyzer still needs sound symbolic or validated
numerical bounds. Sampling supplies diagnostic evidence rather than uniform certification.

A runtime stopping rule could use the certified factor and defect estimates, provided the
execution remains in the certified regime. Evolving states and contacts require either
coverage by the offline certificate or validity checks with a defined fallback. The
[adaptive VBD reference note](/references/adaptive-vbd-iterations.md) explains the distinction
between heuristic stopping and certified accuracy. Floating-point rounding, approximate
local solves, and GPU implementation verification each add error or implementation
obligations beyond the exact-arithmetic library.
