# Mathematical Specifications Update Log

## 2026-09-02

* **API**: Made twice differentiability of the potential an `ImplicitEulerStep` invariant and exported the canonical potential Hessian and Hessian-sum identity; curvature bounds remain deferred.
* **API**: Made global differentiability of the potential an `ImplicitEulerStep` invariant; the incremental potential is globally differentiable and its canonical gradient equals the residual.
* **API**: Renamed the one-timestep problem record from `ImplicitEuler` to `ImplicitEulerStep`.
* **Interface**: Recorded the `ImplicitEuler` problem record with self-adjoint mass and positive timestep, and replaced supplied potential-gradient witnesses with the canonical gradient under differentiability assumptions.

## 2026-08-21

* **Context**: Derived the implicit-Euler incremental potential from conservative Lagrangian mechanics and a backward-Euler step, and recorded the scheme's first-order convergence, A/L-stability, and qualified numerical dissipation.

## 2026-08-20

* **Formalization**: Completed the implicit-Euler gradient, Hessian, residual, and stationarity identities with explicit self-adjointness, nonzero-timestep, and potential-derivative assumptions.
* **Creation**: Specified implicit Euler as stationarity of an inertia-plus-potential objective, keeping minimization and uniqueness conditional on curvature.
* **Creation**: Specified factor-local objectives through exact equality of local and global changes under a one-block update.
* **Creation**: Separated generic block updates, Gauss–Seidel descent, Newton assumptions, and convergence strata.
* **Creation**: Separated locality and sparsity from positive-curvature assumptions and recorded the quadratic curvature-strengthening target.
* **Creation**: Specified independent updates and graph coloring without importing collision-handling or GPU implementation assumptions.
* **Research**: Recorded that incident vertex energies overlap, so VBD locality is a change identity rather than a vertex-wise sum decomposition.
