---
type: Module Plan
title: Lean Module Map
description: Maps the goal-first roadmap to small Lean modules and explicit dependency boundaries.
tags: [lean4, modules, architecture, implementation-plan]
timestamp: 2026-10-20T20:38:44Z
---

# Foundation modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P1 | `Integrator/ImplicitEulerEnergy.lean` | Implemented incremental objective, gradient/residual, and Hessian identities | none |
| P2 | `Block/Basic.lean` | `BlockSum B`, native coordinate access, injections, and replacements | none |
| P2 | `Block/Update.lean` | Write support under composition and simultaneous merging | `Block/Basic` |
| P2 | `Block/Operator.lean` | Continuous block entries, finite assembly and reconstruction, and block-matrix arithmetic | `Block/Basic` |
| P3 | `Dynamics/Contraction.lean` | Implemented local fixed-point and finite-iterate interfaces; derivative bridge is implemented | none |

# Bridge and synthesis modules

| Phase | Module | Responsibility | Direct project dependencies |
|---|---|---|---|
| P4 | `Integrator/LocalPotential.lean` | Implemented finite-support potential components, exact cancellation, and support-to-Mathlib-graph/coloring bridge lemmas | `ImplicitEulerEnergy`, `Block/Basic` |
| P5 | `Integrator/FixedPoint.lean` | Implemented solver-independent [unbiased fixed-point convergence](/mathematics/implicit-euler-fixed-points.md) from a contractive map to an implicit-Euler stationary solution | `ImplicitEulerEnergy`, `Dynamics/Contraction` |
| P6 | `Block/Contraction.lean` | Implemented derivative-factor comparisons, ordered composition, commuting batches, and covered maximum-norm contraction certificates | `Block/Update`, `Block/Operator`, `Dynamics/Contraction` |
| P7 | `Integrator/VBD.lean` | Implemented VB-01–VB-02 exact executions and regular-sweep consistency | `Block/Operator`, `Block/Update`, `Integrator/FixedPoint` |
| P7 | `Integrator/VBDDerivative.lean` | Implemented regular-state derivatives including inverse variation, root block entries, and ordered Gauss–Seidel identification | `Integrator/VBD`, `Block/Contraction` |
| P7 | `Integrator/VBDCurvature.lean` | Implemented VB-04 inertia-based block coercivity, inverse bounds, and scalar regularity certificates | `Integrator/VBD` |
| P7 | `Integrator/VBDCoupling.lean` | Implemented VB-05 normalized coupling, covered root-sweep bounds, and quantitative norm conversions | `Integrator/VBDDerivative`, `Integrator/VBDCurvature` |
| P7 | `Examples/AxialSpring.lean` | Implemented spring residual, Jacobian, exact Newton blocks, and AP-03 serial root derivative factor | `Integrator/VBDCoupling` |
| P7 | `Integrator/VBDNonlinear.lean` | Implemented generic changed-row variation estimates and uniform serial Lipschitz certificates | `Integrator/VBDCoupling` |
| P7 | `Examples/AxialSpringNeighborhood.lean` | Implemented invariant nonlinear box, uniform serial factor, and selected warm-start membership | `Examples/AxialSpring`, `Integrator/VBDNonlinear` |
| P7 | `Integrator/VBDColoring.lean` | Implemented component-energy-to-Newton locality, same-color commutation including skips, buffered/serial equivalence, and numbered color execution | `Integrator/LocalPotential`, `Integrator/VBDNonlinear` |
| P7 | `Examples/AxialSpringColoring.lean` | Implemented spring Newton read locality, finite-chain even/odd coloring, and proper-color nonlinear contraction and invariance | `Examples/AxialSpringNeighborhood`, `Integrator/VBDColoring` |
| P7 | `Examples/AxialSpringEnergy.lean` | Implemented symmetric spring energy gradient, normalized IE problem, and exact production Newton-data identification | `Examples/AxialSpring` |
| P7 | `Examples/AxialSpringResidual.lean` | Implemented mass-scaled residual derivative and Lipschitz bound, and scalar maximum-principle root location | `Examples/AxialSpringEnergy`, `Examples/AxialSpringNeighborhood` |
| P7 | `Examples/AxialSpringConvergence.lean` | Implemented unique-root convergence and finite-sweep state/residual certificates for serial and proper-color production plans | `Examples/AxialSpringResidual`, `Examples/AxialSpringColoring` |
| P7 | `Examples/AxialSpringChain.lean` | Implemented physical-input normalization, finite-chain degree bounds, common stationary point, and physical 20-sweep residual guarantees | `Examples/AxialSpringConvergence` |

These paths are the current module boundaries recorded in the central
[roadmap](/project/roadmap.md) and [backlog](/project/backlog.md).

# Initial build order

Phases 1 and 2 are complete. `Block/Update.lean` and `Block/Operator.lean` each depend only on
`Block/Basic.lean` within the project.
Phase 3 has an implemented, block-independent core covering CT-01–CT-03 and reusing the pinned
Mathlib contraction API. The [axial-spring contraction analysis](/mathematics/axial-spring-contraction.md) and
[AP-03 decision](/project/applicability-decision.md) authorize CT-04 and the exact-execution
Phase 4–7 route. Same-color coupling estimates in exact arithmetic are deferred. Exploratory
derivations and diagnostic scripts introduce no cross-foundation Lean imports; the module dependency boundaries stay in force.

The three foundations may be implemented independently:

```text
Integrator/ImplicitEulerEnergy
Block/Basic -> Block/Update
           -> Block/Operator
Dynamics/Contraction
```

Bridge modules introduce cross-foundation imports. `Block/*` contains block-state and
block-operator declarations; `Dynamics/Contraction` contains generic metric and normed-space
fixed-point declarations.

# Representation and norm boundary

Phase 1 retains `X` as an abstract real Hilbert-space parameter. Phase 2 uses `B : ι → Type*` and
`BlockSum B := PiLp 2 B`. Coordinate algebra states its typeclass requirements declaration by
declaration. P6 uses a theorem-local maximum norm or equivalent metric for the accepted chain certificate,
with explicit transport to the existing finite `ℓ²` block representation. Generic derivative
lemmas remain norm-polymorphic; weighted and energy norms are options for later assessments.

Phase 5 accepts a metric solver state and an independently normed residual codomain. An equivalent
state representation pulls back the IE residual and conjugates the solver map; unbiasedness is
preserved algebraically. Thus Phase 6's maximum-norm state can feed Phase 5 while the gradient
retains its Hilbert-space codomain. A scaled residual can use its own codomain and cross-norm
regularity bound. The [chain certificate](/mathematics/axial-spring-contraction.md#finite-sweep-bounds-and-physical-scales)
uses a mass-scaled maximum residual; its stated regularity constant applies to those chosen norms.

# Reuse acceptance condition

CT-04, IF-01–IF-03 and BC-01–BC-03/BC-05 expose generic norm, residual-regularity and
block-comparison hypotheses. They must support vector-valued blocks and finite component-support
systems without embedding the chain's degree, constitutive coefficients or scalar sign lemmas.
P7 separates the general block-Newton map, skip-free consistency and derivative identities
from the chain's concrete inverse, box-invariance and accuracy instantiations. The chain is the
first application; these generic results are required deliverables in the same theorem route.
The [adaptation analysis](/mathematics/axial-spring-contraction.md#reuse-beyond-the-chain) specifies
which hypotheses richer models must discharge and which friction/contact extensions need new
interfaces. Source file splitting within P7 follows this boundary when implementation warrants it.

# Documentation boundary

Document module APIs, assumptions, representation choices, and proof details in the corresponding
Lean source. Keep this bundle focused on cross-module architecture, current roadmap state,
mathematical specifications, dependency assessments, and external references.

# Implementation status

`Integrator/ImplicitEulerEnergy.lean` implements Phase 1. The three Phase 2 modules implement
heterogeneous block operations, exact write support under ordinary composition, disjoint
snapshot merging with commuting sequential equivalence, and continuous-linear block-matrix
assembly, reconstruction, and arithmetic. Preserved linear output blocks are characterized by
identity block rows. All implemented foundation modules are exported by `Vbd.lean`.

`Dynamics/Contraction.lean` implements CT-01–CT-03 using Mathlib contraction and Lipschitz
iteration results. It supplies local fixed-point existence and uniqueness, convergence to a
supplied fixed point, finite-iterate distance bounds, and a defect-based error estimate, with
no project imports. Its norm-polymorphic CT-04 derivative bridge implements the convex-set
mean-value step. AP-01–AP-03 are complete research deliverables; exact hybrid coupling analysis is deferred.

`Integrator/LocalPotential.lean` implements Phase 4. It sums support-indexed local components,
proves cancellation outside the affected supports of a block change, constructs the component
interaction graph, and uses Mathlib's numbered proper colorings for the support-local coloring
bridges. It is exported by `Vbd.lean`.

`Integrator/FixedPoint.lean` implements Phase 5. It defines solver unbiasedness relative to a
residual, derives existence and stationarity of the unique fixed point on a complete invariant
contractive set, and transports finite iterate state error to an independently normed residual.
It imports only `ImplicitEulerEnergy` and `Dynamics/Contraction` and is exported by `Vbd.lean`.

`Block/Contraction.lean` implements BC-01–BC-03 and BC-05. It combines only the block and
dynamics foundations and is exported by `Vbd.lean`. Comparisons compose in execution order,
with derivatives evaluated at intermediate states in an explicitly invariant region.
The finite dependent function space supplies the theorem-local maximum norm via an explicit
continuous-linear equivalence with `BlockSum`. Complete coverage of changed rows with a common
bound below one gives the sweep certificate. Commuting disjoint-write merges inherit bounds
and derivatives from their enumerations. Phase 7 supplies the concrete VBD and physical premises.

`Integrator/VBD.lean` implements VB-01–VB-02 and is exported by `Vbd.lean`. It supplies exact local
Newton updates with determinant-threshold skipping and chronological serial or buffered plans.
The IE specialization uses the energy gradient and exact diagonal Hessian blocks, with the
inertia-plus-potential identity inherited from Phase 1. Buffered passes retain snapshot semantics
for coupled updates; conditional equivalence with serial execution uses the Phase-2 commuting
merge theorem. Complete once-per-block serial and disjoint buffered plans fix exactly the residual
roots at regular states, independently of contraction or within-pass commutation. All plans
preserve residual roots. The consistency theorems discharge the Phase-5 unbiasedness premise.

`Integrator/VBDDerivative.lean` implements VB-03 and is exported by `Vbd.lean`. Strict acceptance
of a differentiable local Hessian map makes the regular branch valid near the root. The local
root derivative has the normalized Hessian row, and Phase-6 composition gives the sweep derivative
in the externally supplied order. Exact diagonal blocks identify it with the block Gauss–Seidel
error operator, represented by chronological linear row updates with a proved forward-substitution
equation. The concrete IE specialization derives its residual derivative from Phase 1.

`Integrator/VBDCurvature.lean` implements VB-04 and is exported by `Vbd.lean`. Mass and potential
curvature bounds give explicit coercivity and inverse-norm control of the actual IE Newton blocks
throughout a supplied region. The inverse result supports heterogeneous finite-dimensional real
Hilbert blocks. Scalar coercivity above the production threshold supplies regularity for the
consistency and derivative interfaces.

`Integrator/VBDCoupling.lean` implements the generic VB-05 coupling-to-root-sweep bound and
explicit maximum/ℓ² state norm conversions. It preserves heterogeneous vector-block parameters
and reuses Phase-6 comparison multiplication and covered row certificates.
`Examples/AxialSpring.lean` supplies the scalar physical instantiation: the polynomial residual
has its Jacobian, exact Newton diagonal entries, smoothness and skip-free regularity proved.
The degree-two AP-03 parameter range bounds the actual covered serial sweep derivative at a
supplied root in the accepted box by `14/39`. Both modules are exported by `Vbd.lean`.

`Integrator/VBDDerivative.lean` also supplies the full regular-state derivative through
Mathlib inversion calculus. `Integrator/VBDNonlinear.lean` bounds the inverse-variation term
per column and feeds uniform changed-row bounds and per-visit invariance into Phase 6.
Both interfaces retain arbitrary finite-dimensional normed blocks.
`Examples/AxialSpringNeighborhood.lean` implements VB-06 for the AP-03 degree-two range:
every visit preserves the radius-`0.1` maximum-norm box, covered serial sweeps have factor
`318/625 < 0.512`, and the selected cosine predictor and rest-state warm starts belong to the
box. These modules are exported by `Vbd.lean`.

`Integrator/VBDColoring.lean` implements VB-07's generic locality and execution bridge.
Phase-4 component energy increments determine local block gradients and diagonal Hessians;
block-diagonal inertia gives locality of the actual IE Newton data. Support-wise proper colors
then supply update commutation on both skip branches, snapshot/serial equality for arbitrary
within-color enumerations, and complete once-per-color fixed-point consistency.
`Examples/AxialSpringColoring.lean` proves the polynomial Newton inputs' component locality and
the nearest-neighbor chain's even/odd Mathlib coloring for arbitrary length. Exact execution
equality transports the VB-06 factor and invariant box to proper-color sweeps. The generic
bridge supports vector blocks and higher-arity supports. Both modules are exported by `Vbd.lean`.

`Examples/AxialSpringEnergy.lean` identifies symmetric quadratic-plus-quartic spring forces
with the energy gradient, places the normalized model in Phase 1, and identifies the production
Newton data with its IE constructor. `Examples/AxialSpringResidual.lean` supplies the scalar
maximum principle and the mass-scaled maximum-residual Lipschitz constant `53/25`.
`Examples/AxialSpringConvergence.lean` uses Phase-5 Banach existence and finite-iterate transport
to produce the root, convergence, and state/residual bounds for the actual serial and proper-color
iterates. `Examples/AxialSpringChain.lean` derives every hypothesis from physical chain data,
proves the length/timestep force normalization, and certifies both plans at the same unique
physical stationary point with 20-sweep scaled residual below `3.25 × 10⁻⁷ < 10⁻⁶`.
These four exported modules implement VB-08. Vector-block reuse remains in the generic
foundation and synthesis interfaces; the root-location sign argument specializes the scalar chain.
