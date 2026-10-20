# Lean Formalization Update Log

## 2026-10-20

* **VB-06 implementation**: Extended `VBDDerivative` through Mathlib explicit inversion calculus and added/exported `VBDNonlinear` plus `AxialSpringNeighborhood`. Kept generic finite-dimensional vector-block parameters, bounded changed rows per column, and fed static comparison rows and per-update invariance into the prepared Phase-6 composition theorem. Instantiated the actual polynomial spring derivative, retained incident stiffness in the inverse denominator, and proved box preservation and warm-start membership. Added a nonzero off-root diagonal derivative regression, endpoint chain contraction with repeated visits, invariant warm-start iterates, and a vector-block derivative check. Synchronized module boundaries and Mathlib APIs.

## 2026-10-20

* **VB-05 implementation**: Added and exported `Integrator/VBDCoupling.lean` and `Examples/AxialSpring.lean`. Composed VB-04 inverse estimates with off-diagonal norms and Phase-6 covered comparison products. Proved the spring residual derivative, exact diagonal/off-diagonal entries, regularity and diagonal-map smoothness, then instantiated VB-03 for the actual serial sweep and bounded its maximum-norm root derivative by `14/39` over the AP-03 degree-two range. Added explicit norm conversion constants and compiled nonlinear/vector integration checks. Kept energy-gradient identification and uniform nonlinear-region certificates as later physical instantiations.

## 2026-10-20

* **VB-04 implementation**: Added and exported `Integrator/VBDCurvature.lean`, composing the Phase-1 diagonal Hessian identity with explicit mass and potential lower bounds and Mathlib finite-dimensional invertibility and operator-norm APIs. The inverse bound supports arbitrary finite-dimensional real Hilbert blocks; scalar determinant comparison supplies skip-free regularity. Checked timestep scaling with negative potential curvature, a two-dimensional anisotropic solve, and physical curvature discharge of VB-02 consistency at the selected positive threshold. Synchronized module boundaries and Mathlib inventory.

## 2026-10-20

* **VB-03 implementation**: Added and exported `Integrator/VBDDerivative.lean`. Derived production single-block root derivatives through Mathlib inversion and operator/vector calculus, then used the Phase-6 ordered chain rule on the invariant root singleton. Proved normalized changed-row entries, zero diagonal under exact inversion, untouched identity rows, the Gauss–Seidel forward-substitution equation, and the chronological sweep identification. The IE specialization derives the residual derivative from stored Phase-1 assumptions and exposes diagonal-Hessian differentiability separately. Added concrete order-sensitive coupled linear checks and a changing-Hessian cubic-residual check; recorded reused Mathlib APIs and the synthesis module split.

## 2026-10-20

* **VB-02 implementation**: Proved regular block fixed-point equivalence, root preservation for arbitrary serial/buffered plans, and complete regular sweep fixed-point/root equivalence for once-per-block serial orders and pairwise-disjoint buffered passes. The proof uses write preservation and exact local inverse action, independently of contraction and within-pass commutation. Added production `UnbiasedOn` certificates and a cross-norm integration check feeding the concrete IE serial consistency proof into Phase-5 Banach existence. Advanced the module map to VB-03.

## 2026-10-20

* **VB-01 implementation**: Added and exported `Integrator/VBD.lean`: finite-dimensional heterogeneous block-Newton data, exact determinant-test branches, invertibility and local solve certificates, singleton write support, chronological serial products, snapshot-merge batches, conditional commuting serial equivalence, and the IE diagonal Hessian identity. Concrete scalar checks distinguish opposite serial orders, buffered coupled writes, and threshold equality. The prepared Phase-1/Phase-2 interfaces support this step without a new mathematical prerequisite.

## 2026-10-20

* **Phase-5 cross-norm implementation**: Checked that the planned result combines metric Banach existence with a Lipschitz residual into a separate normed codomain, without additional mathematics. Added generic `UnbiasedOn.exists_fixedPoint`, `norm_iterate_le`, and algebraic `comp_equiv`; retained the IE same-space APIs as wrappers. Added integration checks using the actual Phase-6 maximum-norm map and a heterogeneous Hilbert IE residual. Replaced the module-map integration-gap claim with the implemented interface. The previous inner-product-instance probe tested an unnecessary requirement; the issue was incomplete implementation of the existing Phase-5 specification. Phase 7 remains at VB-01.

## 2026-10-20

* **Phase-7 stopping point**: At the user's request to stop at the first preparation problem, stopped the VB-01 entry assessment before adding production definitions. Phase 6's maximum-norm `maxMap` does not directly instantiate the Hilbert-space IE existence and residual specializations in Phase 5. A scratch Lean probe importing `Vbd`, inspecting those declarations, and running `#synth InnerProductSpace ℝ (Fin 2 → ℝ)` reports the missing instance. The chain's mass-scaled maximum residual also differs from the implemented IF-03 Hilbert residual conclusion. Recorded these integration prerequisites in the module map; no transport repair, theorem-route change, or Phase-7 completion is claimed.

## 2026-10-20

* **Scope cleanup**: Removed inexact-iteration and execution-error extension references from the module plan and Mathlib inventory. The dynamics foundation covers CT-01–CT-04; same-color coupling remains a separate exact-arithmetic analysis.

## 2026-10-20

* **Phase 6 implementation**: Added and exported `Block/Contraction.lean` with block-action and operator-norm comparisons, intermediate-state derivatives, ordered matrix bounds, maximum-norm transport, commuting merges, and covered changed-row contraction. Implemented CT-04 through Mathlib convex-set mean-value theory and synchronized the module map and API inventory.

## 2026-09-16

* **Phase-5 implementation**: Added and exported `Integrator/FixedPoint.lean`. It compiles the generic `UnbiasedOn` predicate, IE-stationary fixed-point existence, finite iterate distance and convergence interfaces, and a Lipschitz residual-error bound using only the Phase-1 and Phase-3 modules.

## 2026-09-16

* **Phase-5 consistency refinement**: The planned `Integrator/FixedPoint.lean` interface now takes `UnbiasedOn (energyGradient ie) T S` rather than a designated point assumed both stationary and fixed. Banach existence yields the point; the residual premise identifies it as an IE solution. Concrete VBD unbiasedness remains an `Integrator/VBD` proof.

## 2026-09-16

* **Phase-4 implementation**: Added and exported `Integrator/LocalPotential.lean`. It compiles finite-support local potentials, exact energy-change cancellation, support-induced graph adjacency and monotonicity, Mathlib-coloring bridges, support-family restriction and extension criteria, and pair/triple examples.

* **Phase-4 reuse decision**: Confirmed pinned Mathlib's `SimpleGraph.fromRel`, proper vertex coloring, color-class, and graph-partition APIs. Phase 4 will use `G.Coloring (Fin m)` directly and add only the support-induced graph and support-local bridge lemmas.

## 2026-09-15

* **Module plan**: Renamed the planned Phase-4 module to `Integrator/LocalPotential.lean` and aligned its responsibility with finite-support potential components and their component-overlap graph.

## 2026-09-14

* **Reuse contract**: Required generic bridge and block-Newton declarations alongside chain instantiations, preserving block-dimension and interaction-support parameters. Recorded the boundary for future contact/friction interfaces.

* **Applicability route**: Synchronized module work order with the completed AP-03 decision. The derivative bridge is next, maximum-norm transport serves the exact-execution chain theorem, and perturbation/hybrid extensions are deferred without changing foundation imports.

* **Phase 3 core**: Reviewed and recorded the pinned Mathlib contraction, invariant-subset, fixed-point and iterate APIs. Implemented and exported six small ambient-space interfaces in `Dynamics/Contraction.lean`, reusing Mathlib existence, uniqueness, Lipschitz iteration and defect bounds. Kept completeness local to existence and strict contraction local to convergence/uniqueness/error certification. Synchronized the module map.

## 2026-09-11

* **Work order**: Synchronized the module plan with the early applicability gate: the thin Phase 3 core precedes AP-01–AP-03, and further dynamics and bridge/synthesis formalization requires a supported proceed decision. Kept the three foundation import boundaries intact during exploratory work.

* **Simplification**: Deleted `execute`, `intermediate`, and their wrapper lemmas. Retained block-specific preservation and write-support lemmas for Mathlib’s `List.prod` on `Function.End`; reformulated simultaneous–sequential equivalence as `merge_eq_prod`, using Mathlib’s product reordering theorem directly. Updated the module map.

## 2026-09-08

* **Terminology review**: Reviewed all three `Block` modules. Clarified whole blocks and block indices in `Basic`, operator indices and list positions in `Update`, and finite index families and `Fintype` instances in `Operator`. Made write-support and simultaneous-merge descriptions precise; retained declaration names and theorem statements. Updated the specification link in `Basic`.

* **Implementation**: Completed the independent `Block/Update` and `Block/Operator` modules and exported them through `Vbd.lean`. Added exact write-support calculus, ordered execution and permutation laws, disjoint snapshot merging with exact support and commuting sequential equivalence, additive change identities, and heterogeneous continuous-linear assembly, reconstruction, arithmetic, and preserved-row characterization. Kept algebraic block identities in `Block/Basic` and analytic assumptions local to the operator layer.

## 2026-09-07

* **Module plan**: Restored `Block/Update.lean` for write-local operators and externally controlled execution algebra; retained `Block/Operator.lean` as an independent block-matrix linearization layer rather than making matrix splittings the execution model.
* **Correction**: Removed `DMatrix` from the planned public implementation boundary. Phase 2 remains representation-neutral at roadmap level, and its Lean code may operate directly on indexed continuous-linear entries. `DMatrix` and categorical biproducts were evaluated without being adopted as project-wide commitments.

## 2026-09-04

* **Module plan**: Made `Block/Operator.lean` the next Phase 2 module for block entries and finite reconstruction; physical coloring moves through `Integrator/LocalInteractions`, while concrete sweep definitions remain in `Integrator/VBD`.
* **Implementation**: Added `Vbd.Block.Basic` with `BlockSum B := PiLp 2 B`, native coordinate application, zero-supported injection, and same-coordinate, untouched-coordinate, identity, overwrite, and commutation laws for replacement.
* **Interface**: Kept block operations as a pure functional API and deferred an optional `StateM (BlockSum B)` presentation unless later algorithm derivations demonstrate a need for imperative notation.

## 2026-09-03

* **Module plan**: Replaced the planned `Optimization/*` descent stack with independent `Block/*` and `Dynamics/Contraction` foundations, pairwise `Integrator` bridges, and a final production `Integrator/VBD` synthesis module.
* **Library reuse**: Confirmed that pinned Mathlib already provides `ContractingWith`, restricted contractions, Banach fixed points, iterate convergence, and a priori estimates; the project will add only local-neighborhood, derivative, and perturbation bridges.
* **Notation**: Standardized Phase 2 on `B : ι → Type*`, `B i`, and `BlockSum B := PiLp 2 B`, keeping `X` reserved for total spaces and eliminating a representation change at the analytic boundary.
* **Decision**: Rejected a direct Optlib dependency for Phase 2 after assessing its 4.13.0 toolchain and two-block PALM-specific interface; retained its convergence proof decomposition as a later reference.
* **Architecture**: Selected a raw dependent product for exact locality and Mathlib's `PiLp 2` type synonym for derivative, Newton, and convergence results.
* **Planning**: Added `BlockDerivative` to the module map and separated algebraic, analytic, Newton, coloring, and convergence dependencies.

## 2026-09-02

* **API**: Removed the tautological energy-gradient/stationarity equivalence; a generic stationary-point predicate belongs in the optimization layer.
* **API**: Standardized the incremental objective as `energy` and its analytic gradient as `energyGradient`; removed the unused `residual` alias.
* **API**: Replaced the public Hessian derivative certificate with the canonical `hessian_energy` equality, parallel to `gradient_energy`.
* **API**: Made global differentiability of the potential gradient an `ImplicitEulerStep` invariant and exported the canonical potential Hessian and unconditional Hessian-sum identity.
* **API**: Made global differentiability of the potential an `ImplicitEulerStep` invariant and exported global differentiability and residual-as-gradient identities without pointwise caller hypotheses.
* **API**: Expressed the potential-gradient and potential-gradient-certificate identities through the named `residual` function.
* **API**: Made Phase 1's derivative certificates module-private; the incremental definitions, gradient identity, residual/stationarity equivalence, and Hessian identity form its VBD-facing interface.
* **API**: Renamed the one-timestep problem record from `ImplicitEuler` to `ImplicitEulerStep`.
* **API**: Bundled mass, potential, timestep, predicted state, self-adjointness, and timestep positivity into the `ImplicitEuler` problem record; replaced caller-supplied potential gradients with Mathlib's canonical `gradient` and pointwise differentiability assumptions.
* **API**: Grouped the fixed mass operator and potential energy as system-level Lean parameters, ahead of per-solve timestep and state arguments.
* **Documentation**: Adopted Mathlib-style declaration-local source documentation for Phase 1; the module docstring now contains only module-wide scope and links.

## 2026-08-21

* **Documentation**: Moved Phase 1 API, assumptions, dependency boundaries, and Hessian-representation rationale into the Lean module docstring; removed the source-mirroring `formalization/modules/` concepts and policy.

## 2026-08-20

* **Implementation**: Added the compiling, basis-free `Vbd.Integrator.ImplicitEulerEnergy` Phase 1 module, exposed it from `Vbd.lean`, and documented its public interface and assumptions.
* **Correction**: Removed the incorrectly attributed legacy Optlib dependency assessment; only the relevant Lean 4 `optsuite/optlib` candidate remains.
* **Research**: Audited the pinned Mathlib source for gradients, Fréchet derivatives, second derivatives, strong convexity, positive matrices and operators, extrema, finite products, and graph APIs.
* **Research**: Assessed Mathlib as the sole current dependency and CvxLean and Lean 4 Optlib as reference or evaluation candidates rather than automatic imports.
* **Planning**: Mapped the theorem roadmap to small Lean modules with explicit dependency boundaries and a compiling implicit-Euler implementation spike first.
