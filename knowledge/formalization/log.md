# Lean Formalization Update Log

## 2026-09-04

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
