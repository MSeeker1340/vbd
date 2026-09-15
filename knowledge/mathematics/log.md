# Mathematical Specifications Update Log

## 2026-09-15

* **Coloring motivation**: Explained that the induced graph converts the requirement of at most one block of each color per support into ordinary proper vertex coloring. Added the pair-support edge and three-block-support triangle examples, while retaining $A$ as the source of energy-locality information.

* **Locality interpretation**: Defined a component local on $S$ as a formula containing only the block values indexed by $S$, illustrated by a binary term $\varphi(x_i,x_j)$, before giving the extensional equality formulation.

* **Indexing simplification**: Indexed each potential component directly by its finite support $S\subseteq I$, so the finite component family is $A\subseteq\mathcal P(I)$. Combined equal-support summands and removed the separate component-label type and support function.

* **Assumption simplification**: Made the Phase-1 potential $E$ directly a finite sum of component potentials. Removed the auxiliary $E_A$ notation and the conditional bridge between a generic potential and its decomposition.

* **Terminology simplification**: Replaced the active-set terminology with the finite component index set $A$. The decomposition now introduces only the labels required to write $E=\sum_{e\in A}E_e$ and its support-based consequences.

* **Scope simplification**: Recast Phase 4 as a finite-support decomposition of the Phase-1 potential. Replaced interaction, physical-origin, live-set, and physical-conflict terminology with potential components, an active set, and the induced component-overlap graph; retained only the support and update-locality facts needed by later coloring theorems.

* **Definition**: Introduced an interaction as a labeled elemental potential-energy contribution before using its support and live-set notation.

* **Rendering correction**: Replaced inline code spans containing mathematical expressions in the Phase-4 interaction and coloring specifications with inline TeX delimiters.

* **Notation correction**: Recast the finite-support interaction specification entirely in mathematical block-space, finite-set, and direct-sum notation. Removed implementation vocabulary from its definitions and theorem statements.

* **Phase-4 review specification**: Defined live finite-support interaction hypergraphs, extensional locality, incident interaction sets, exact energy-change cancellation, and the induced symmetric irreflexive conflict relation. Specified proper coloring equivalently as injectivity on every live support, with checked pairwise-chain and triangular examples.

* **Static-color boundary**: Distinguished a static material coloring from properness for the actual live set. Recorded deletion preservation, the exact added-interaction preservation criterion, and the buffered Jacobi-within-color semantics that apply after a violation. Kept concrete VBD update locality, commutation, and hybrid contraction as later production/deferred obligations.

## 2026-09-15

* **Worked-example scope**: Marked the spring-chain article explicitly as an application of the existing convergence framework. Reframed its introduction around checking concrete hypotheses and budgets, distinguished implemented foundations from pending bridges with TODOs, and moved the general block-Newton estimate to the supporting curvature article. Further physical extensions are identified as additional examples to work out.

* **Article identity**: Renamed the mathematical article to `axial-spring-contraction.md`, titled “VBD Contraction for Coupled Axial Springs.” Updated its index entry and incoming links throughout the repository; the applicability decision remains a separate project record.

* **Reader-guided applicability exposition**: Studied the block-state and implicit-Euler articles and revised the applicability article around the physical meaning of each proof step. Added the quadratic averaging mechanism, explained nonlinear sensitivity and complete-sweep contraction, interpreted the numerical comparison, and replaced the module catalogue with a connected account of the formalization. Retained the quantitative bounds and extension scope.

## 2026-09-14

* **Exposition and experiment tooling**: Rewrote the spring study as a mathematical development with physical rail/band examples, rendered equations, results, module connections, and extensions. Moved model-selection rationale and the evaluation contract to the project decision. Added a locked uv experiment, configurable module CLI, full trajectory data, tables and plots, with focused mathematical/CLI checks; the full 336-case regression preserves the measured state/residual results and matrix diagnostics.

* **Generalization and certificate audit**: Added the dimension-independent block derivative interface, a quantified vector spring-graph extension, and adaptation obligations for elasticity, contact and friction. Corrected a missing factor of two in the scalar Hessian-variation estimate by retaining both local inverse denominators; the supported 20-sweep bound remains valid, with regenerated certificate numbers and a residual-reduction factor bounded by 0.804 on the smaller range.

* **Applicability study**: Derived a uniform nonlinear axial-chain certificate, predictor and intermediate-state bounds, independent skip-free consistency, and quantitative residual reduction on a smaller subrange. Added 336 reproducible numerical cases, exact residual-progress and objective-increase counterexamples, norm-conservatism analysis, and explicit production-coverage limits; linked the curvature specification.

* **Scope and motivation**: Labeled perturbed iteration as an optional extension and explained its role in transferring reference-map accuracy to approximate execution. Distinguished this strategy from direct analysis of exact serial or buffered VBD maps, linked its selection to the applicability study, and clarified that floating-point verification remains deferred.

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
