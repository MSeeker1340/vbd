# Mathematical Specifications Update Log

## 2026-09-07

* **Simplification**: Focused the block-coordinate specification on write support as an upper bound on changed coordinates, support propagation through external execution, commutation, and simultaneous batches. Condensed routine coordinate and matrix arithmetic, retained the basis-free block representation, and made the later analytic boundary explicit. Updated the mathematics index to match.
* **Correction**: Removed the rejected block-value-rule formulation and the generic ordered/colored matrix splittings. Update operators are supplied state transformations, execution order is external, and color equivalence is expressed through commutation and simultaneous merging.
* **Block specification**: Recast the block space as a finite mathematical `ℓ²`-direct sum and made operator-valued block matrices the primary engineering-facing notation, including matrix forms for projection, inclusion, replacement, and linearization; kept Lean representation details in the formalization layer and source documentation.

## 2026-09-04

* **Block theory**: Specified continuous-linear block entries, finite reconstruction, operator arithmetic, and ordered or colored splittings as the reusable algebra supporting later complete-sweep derivative bounds.
* **Coloring**: Located conflict graphs in finite-support physical interactions and reserved serial/buffered execution equivalence for the concrete VBD sweep definitions.

## 2026-09-03

* **Analysis route**: Replaced per-block energy descent as the main convergence premise with local contraction of the actual serial or colored sweep around an implicit-Euler root.
* **Block theory**: Recast one-block results as objective-independent update algebra and cross-block sensitivity composition; isolated energy cancellation and coordinate stationarity as helper facts rather than milestones.
* **Parallelism**: Distinguished exact sequential equivalence for proper colors from Jacobi-within-color contraction or perturbation bounds when live collisions introduce same-color coupling.
* **Curvature**: Redirected inertia and Hessian bounds toward block invertibility, normalized coupling, a nonlinear contraction neighborhood, and finite-sweep error instead of qualitative conditioning alone.
* **Notation**: Distinguished the heterogeneous block family `B : ι → Type*` from the total space `X` and adopted `BlockSum B` for the Phase 2 product construction.

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
