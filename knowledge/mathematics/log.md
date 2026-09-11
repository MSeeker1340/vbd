# Mathematical Specifications Update Log

## 2026-09-11

* **Stopping criteria**: Added the previous-update a posteriori bound and adaptive stopping interpretation to the contraction specification. Distinguished qualitative termination from a numerical state-error guarantee using an affine counterexample, and linked the adaptive VBD reference assessment.

* **Motivation**: Introduced the VBD solver context in [Contractive fixed-point iteration](./contractive-fixed-point-iteration.md), distinguishing Newton descent from root finding and explaining invariant-neighborhood contraction, finite-sweep guarantees, and the later block-coupling and stationarity bridges. Clarified that objective descent and contraction are distinct properties.

* **Creation**: Added [Contractive fixed-point iteration](./contractive-fixed-point-iteration.md) with invariant-set hypotheses, Banach existence and uniqueness, finite-iteration and defect bounds, derivative and invariant-ball certificates, and separate persistent, vanishing, and summable perturbation conclusions. Indexed the article and linked the curvature specification to it, making the convexity and completeness premises explicit.

## 2026-09-08

* **Naming**: Renamed the block-state and operator specification to [Block states and operators](./block-states-and-operators.md), aligned its title and index entry, and updated incoming references.

* **Presentation**: Illustrated write support and simultaneous merging with a shared four-block example, showing preserved blocks as zeros in change vectors and merging as their sum. Added the corresponding linear batch matrix with selected operator block rows and an identity block row, keeping nonlinear component maps distinct from linear matrix entries.
* **Exposition**: Replaced the theorem's closing explanation of colored execution with a brief sidenote linking to the later treatment of VBD's colored updates.
* **Theorem**: Refined simultaneous batches with explicit operator and block index sets, support bounds, snapshot semantics, and exact support. Stated simultaneous–sequential equivalence for every enumeration of a pairwise-commuting family with disjoint write-support bounds, and supplied a detailed blockwise proof including unassigned blocks and the empty batch.
* **Organization**: Grouped the specification into block states and operators on block states, retaining the mechanical background as an introduction. Presented sequential composition and commutation before the block-dependent concepts, with sequential and parallel algorithm motivation. Recast external execution as sequential composition and made the relationship between write support and block rows of the operator minus identity explicit. Updated the mathematics index.
* **Definition**: Replaced the predicate-first write-support presentation with the set of block indices changed for some input, and characterized support bounds by containment. Updated execution and batch statements to distinguish exact support from bounds. Standardized block and block-index terminology, reserving scalar coordinates for the interior of a block.
* **Exposition**: Reordered the block-states section into a sequence of definitions with formulas: decomposition, state vector, norm, projection, inclusion, and replacement. Kept the distinction between general coordinate algebra and the normed linear representation.

## 2026-09-07

* **Background**: Connected block states to candidate configurations in the implicit-Euler solve, with particle, multibody, and nodal finite-element examples explaining block structure and local interactions. Distinguished solver updates from timestep advancement and linked the interaction model before introducing the abstract block space.
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
