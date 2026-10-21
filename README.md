# Verified convergence certificates for Vertex Block Descent

This repo contains a **formal mathematical analysis of Vertex Block Descent (VBD)** in Lean 4 /
Mathlib, connecting implicit-Euler mechanics, block-Newton execution, and
contractive fixed-point theory. Definitions, assumptions, and proofs are
expressed in Lean and checked by its kernel. The library studies when VBD
converges, what it converges to, and how much state and residual error remains
after a finite number of sweeps, in exact arithmetic.

The core is a reusable framework of parameterized theorems for block updates,
execution semantics, and convergence under explicit mathematical hypotheses.
Concrete mechanical models supply the bounds needed to apply those theorems.

- [Vertex Block Descent](#vertex-block-descent)
- [Convergence approach](#convergence-through-fixed-points)
- [Mathematical architecture](#mathematical-architecture)
- [Module guide](#lean-library-guide)
- [Spring-chain example and theorem](#example-nonlinear-spring-chain)
- [Build and inspect the proofs](#build-and-inspect-the-proofs)
- [Numerical experiments](#numerical-experiments)
- [Scope and extensions](#scope-and-extensions)

## Vertex Block Descent

[VBD, introduced by Chen, Liu, Yang, and Yuksel](https://arxiv.org/abs/2403.06321),
is a method for solving the variational form of implicit Euler through
vertex-level Gauss–Seidel iterations. Each visit holds the other vertices fixed
and takes a local Newton step for one vertex block. The small local systems
avoid a global linear solve, and a proper coloring groups independent vertex
updates into parallel batches.

A sweep is therefore an ordered composition of updates. Later serial visits
read earlier writes; vertices in a buffered color batch read a shared snapshot.
The local Hessians depend on the state, and the update includes a determinant
threshold that can skip a nearly singular block. These details determine the
map whose convergence needs to be analyzed.

A quantitative guarantee must connect that executed map to the implicit-Euler
equation and control how errors propagate through repeated sweeps. Local
curvature, coupling between vertices, execution order, and the initial state
all enter the argument. Numerical experiments show how selected instances
behave; formal analysis establishes statements for every system and initial
state satisfying the theorem's hypotheses, with the reasoning checked by a
proof assistant.

Among the sources covered by the project's
[literature review](knowledge/references/vbd-convergence-landscape.md), no prior
formalization was identified that establishes convergence of
actual VBD sweeps under explicit assumptions for specified problem families.
The reviewed work includes algorithmic formulations, empirical convergence
studies, and related mathematical analyses.

This repository presents **one such formal treatment**, organized as a reusable
framework for analyzing exact serial and properly colored VBD. Its
[general theory](knowledge/project/architecture.md#generic-theory-and-worked-instances)
is parameterized by block spaces, potential components, execution plans, and
quantitative bounds. It supports heterogeneous vector blocks and arbitrary
finite component supports; each application supplies its own curvature,
coupling, and neighborhood estimates.

The [nonlinear axial spring chain](knowledge/mathematics/axial-spring-contraction.md)
is a worked application demonstrating the full route from physical inputs to a
finite-sweep certificate. The framework develops one contraction-based account
of VBD convergence, with a broader picture still open. The
[extension discussion](knowledge/project/whats-next.md) describes further
models, parameter regimes, and execution strategies. The accompanying
experiments explore the worked application's bounds and their limits.

## Convergence through fixed points

The analysis treats a complete VBD sweep as a map T. On a nonempty complete
region S, a proof that T preserves S and contracts distances by a factor
0 ≤ q < 1 gives a unique fixed point x* and geometric convergence for x₀ ∈ S:

$$
\|T^s(x_0)-x^*\|\le q^s\|x_0-x^*\|.
$$

A separate consistency proof identifies a complete regular sweep's fixed points
with roots of the implicit-Euler residual. A Lipschitz bound for that residual
then converts state error into a physical-residual bound. Together, these
results give an explicit sweep budget for a specified accuracy and
initial-state region.

To obtain such a certificate for a mechanical model, the library combines
local inverse and coupling bounds, Hessian variation over a neighborhood,
region preservation, execution semantics, and warm-start membership. The
norms and parameter ranges are explicit. These are inputs to
[generic theorem interfaces](knowledge/formalization/module-map.md#reuse-acceptance-condition):
a smooth mechanical model can reuse the argument by establishing its own
hypotheses for the selected norm, region, and execution plan.

## Mathematical architecture

The argument draws on three independent parts of the library:

1. **Implicit-Euler mathematics.** For predictor y, self-adjoint mass operator
   M, timestep h > 0, and potential P, define

   $$
   G_{IE}(x)=\frac{1}{2h^2}\langle x-y,M(x-y)\rangle+P(x).
   $$

   The library proves its gradient/residual and Hessian identities on an
   abstract real Hilbert space. The generic solution concept is stationarity,
   ∇G_IE(x) = 0; stronger conclusions carry their own assumptions.

2. **Block states, updates, and operators.** Heterogeneous block spaces support
   access, replacement, write support, composition, simultaneous snapshot
   merging, and continuous-linear block matrices. Disjoint writes and read
   independence are separate properties; commutation supplies the link between
   simultaneous and sequential execution.

3. **Contractive fixed-point iteration.** Mathlib's fixed-point theory yields
   existence, uniqueness, geometric convergence, finite-iterate bounds, and
   defect-based estimates on complete invariant sets. A derivative bound on a
   convex region supplies the required Lipschitz estimate.

The VBD analysis connects these foundations as follows:

- Finite-support potential components give exact local energy cancellation,
  an interaction graph, and proper support colorings.
- Block derivative bounds form nonnegative comparison matrices. Their products
  follow the actual execution order, evaluating derivatives at intermediate
  states; covered changed-row bounds yield a maximum-norm sweep certificate.
- Exact Newton updates include the determinant skip branch. Complete regular
  sweeps fix exactly residual roots, independently of contraction.
- At a root, the sweep derivative is the ordered block Gauss–Seidel error
  operator. Away from the root, the derivative includes variation of the
  inverse local Hessian.
- Inertia and potential curvature give coercivity and inverse bounds; coupling
  and Hessian variation give uniform nonlinear contraction on an invariant
  neighborhood, with explicit norm conversions.
- Component-local Newton data commute within proper colors, including skips.
  Buffered color execution equals serial enumeration within each color and
  inherits its certificate.
- The solver-independent implicit-Euler fixed-point bridge turns these facts
  into a stationary solution and finite state-error bounds. Cross-norm residual
  regularity converts state error into the stated physical-residual budget.

This route does not require each visit or sweep to decrease energy or physical
residual. The finite-budget guarantee follows from the certified state
contraction and residual transport.

## Lean library guide

[`Vbd.lean`](Vbd.lean) exports the full mathematical library. The project
is pinned to **Lean and Mathlib v4.34.0-rc1**, with Mathlib as its sole direct
Lean dependency.

### Independent foundations

| Module | Proved content |
|---|---|
| [Integrator/ImplicitEulerEnergy](Vbd/Integrator/ImplicitEulerEnergy.lean) | Basis-free incremental energy, gradient/residual, and Hessian identities |
| [Block/Basic](Vbd/Block/Basic.lean) | Heterogeneous block states, access, injection, and replacement |
| [Block/Update](Vbd/Block/Update.lean) | Write support, finite composition, disjoint snapshot merging, and commuting sequential equivalence |
| [Block/Operator](Vbd/Block/Operator.lean) | Continuous-linear block entries, assembly, reconstruction, and matrix arithmetic |
| [Dynamics/Contraction](Vbd/Dynamics/Contraction.lean) | Invariant-set fixed points, convergence, finite-iterate and defect estimates, and the derivative-to-Lipschitz bridge |

### Bridges and general VBD results

| Module | Proved content |
|---|---|
| [Integrator/LocalPotential](Vbd/Integrator/LocalPotential.lean) | Finite-support energies, exact local cancellation, support graphs, and Mathlib proper-coloring bridges |
| [Integrator/FixedPoint](Vbd/Integrator/FixedPoint.lean) | Solver unbiasedness, contractive implicit-Euler solutions, finite state error, and residual transport with independent norms |
| [Block/Contraction](Vbd/Block/Contraction.lean) | Block-entry comparisons, intermediate-state chain rules, ordered matrix products, commuting-batch derivatives, and covered maximum-norm contraction |
| [Integrator/VBD](Vbd/Integrator/VBD.lean) | Exact block-Newton updates, determinant skipping, external serial/buffered plans, and regular fixed-point/root consistency |
| [Integrator/VBDDerivative](Vbd/Integrator/VBDDerivative.lean) | Regular-state inverse-variation derivatives, root block entries, and ordered Gauss–Seidel identification |
| [Integrator/VBDCurvature](Vbd/Integrator/VBDCurvature.lean) | Inertia-based block coercivity, uniform inverse bounds, and scalar skip-threshold certificates |
| [Integrator/VBDCoupling](Vbd/Integrator/VBDCoupling.lean) | Root coupling and covered sweep bounds, with explicit maximum/ℓ² norm conversions |
| [Integrator/VBDNonlinear](Vbd/Integrator/VBDNonlinear.lean) | Nonlinear changed-row variation bounds and uniform serial Lipschitz certificates |
| [Integrator/VBDColoring](Vbd/Integrator/VBDColoring.lean) | Energy-to-Newton read locality, same-color commutation, buffered/serial equivalence, and complete color-plan consistency |

### The nonlinear spring-chain instance

| Module | Proved content |
|---|---|
| [Examples/AxialSpring](Vbd/Examples/AxialSpring.lean) | Polynomial residual, Jacobian, exact Newton blocks, and serial root derivative bound 14/39 under degree-two coupling and timestep bounds |
| [Examples/AxialSpringNeighborhood](Vbd/Examples/AxialSpringNeighborhood.lean) | Invariant radius-0.1 box, uniform factor 318/625, and predictor/rest-state warm-start membership |
| [Examples/AxialSpringColoring](Vbd/Examples/AxialSpringColoring.lean) | Arbitrary-length even/odd chain coloring and proper-color inheritance of contraction and invariance |
| [Examples/AxialSpringEnergy](Vbd/Examples/AxialSpringEnergy.lean) | Exact spring energy gradient, normalized implicit-Euler problem, and production Newton-data identification |
| [Examples/AxialSpringResidual](Vbd/Examples/AxialSpringResidual.lean) | Maximum-principle root location and mass-scaled maximum-residual Lipschitz constant 53/25 = 2.12 |
| [Examples/AxialSpringConvergence](Vbd/Examples/AxialSpringConvergence.lean) | Unique-root convergence, finite state/residual envelopes, and exact 20-sweep arithmetic for serial and proper-color plans |
| [Examples/AxialSpringChain](Vbd/Examples/AxialSpringChain.lean) | Physical-input normalization, common unique stationary state, force-unit scaling, and end-to-end certificates |

The [module map](knowledge/formalization/module-map.md) gives dependencies and
reuse boundaries. To follow the general argument, start with the three
foundations above, then read the block-contraction and VBD bridge modules.
For the concrete theorem, `AxialSpringChain.Certificate` records the conclusions
and `AxialSpringConvergence` connects them to the generic interfaces.
The [finite-sweep integration examples](tests/VBDFinite.lean) show
endpoint parameters, high mass/stiffness contrast, quadratic and nonlinear
instances, and explicit physical energy/force checks.

## Example: nonlinear spring chain

This application instantiates the general framework with explicit physical
parameters and numerical error bounds. The scalar chain geometry and spring
constants enter through the model-specific lemmas in `Vbd/Examples/`.

Consider a finite chain of masses moving along a line, with free ends and
nearest-neighbor quadratic-plus-quartic hardening springs. This simple model
couples neighboring vertices through a state-dependent Hessian while allowing
explicit estimates for the Newton updates. Let ℓ be the rest spacing, u the
displacement in units of ℓ, and y the inertia predictor.
With relative masses aᵢ = mᵢ/m_min and edge coefficients bₑ = h²kₑ/m_min, its
normalized implicit-Euler objective is

$$
G(u)=\frac12\sum_i a_i(u_i-y_i)^2+
\sum_{e=\{i,j\}}b_e\left(\frac{(u_i-u_j)^2}{2}
+\frac{\eta(u_i-u_j)^4}{4}\right).
$$

Each VBD visit takes a full local Newton step using the current residual and
local Hessian. The formal execution includes determinant-threshold skipping;
the conditions below ensure that no visit skips inside the certified
box.

The theorem applies under the following conditions:

| Quantity | Condition |
|---|---|
| Chain | Arbitrary finite length; symmetric, nonnegative nearest-neighbor stiffnesses |
| Masses and scales | mᵢ ≥ m_min > 0, timestep h > 0, rest spacing ℓ > 0 |
| Stiffness and timestep | kₑ ≤ k_max and h²k_max/m_min ≤ 1/4 |
| Hardening | 0 ≤ η ≤ 1, including the quadratic case η = 0 |
| Predictor and initial state | yᵢ = 0.05 cos(1.7i), starting at u⁰ = y |
| Skip threshold | 10⁻¹² in normalized scalar Hessian units |
| Execution | Increasing-index serial visits, or buffered even vertices followed by odd vertices |

Under these conditions, there is a unique stationary state u*, and both
execution orders converge to it. Every intermediate visit stays in the maximum-norm box
‖u‖∞ ≤ 0.1; the root satisfies ‖u*‖∞ ≤ 0.05. Each sweep contracts on the box
with the chain-length-independent factor

$$
q=\frac{318}{625}=0.5088<0.512.
$$

For either execution T, starting at the predictor, the finite-sweep bounds are

$$
\|T^s(y)-u^*\|_\infty\le 0.1q^s,
\qquad
r_{IE}(T^s(y))\le 0.212q^s,
$$

where the residual has an explicit physical meaning:

$$
r_{IE}(u)=\max_i\frac{h^2}{m_i\ell}
\left|\nabla G_{IE}(\ell u)_i\right|.
$$

Here G_IE is the physical incremental energy on displacements from rest.
A residual tolerance τ therefore bounds the force imbalance at vertex i by
mᵢℓτ/h². Using the slightly looser factor 0.512 gives the envelopes
0.1(0.512)ˢ and 0.212(0.512)ˢ. In particular,

$$
r_{IE}(T^{20}(y))<3.25\times10^{-7}<10^{-6}.
$$

In Lean, this result is
[`Vbd.AxialSpring.ChainSystem.end_to_end`](Vbd/Examples/AxialSpringChain.lean).
`ChainSystem` packages the physical inputs; `Certificate` contains the common
physical stationary point, its uniqueness, both convergence certificates, and
both 20-sweep residual guarantees. The theorem constructs the solution and
derives the contraction premises from the system data.

More generally, the library supports any predictor satisfying |yᵢ| ≤ 0.05, arbitrary
complete serial orders and proper support-color plans under their stated
hypotheses. The neighborhood results also cover the rest-state warm start.
The theorem above specializes these results to the cosine predictor and the
two listed plans. The [worked mathematical analysis](knowledge/mathematics/axial-spring-contraction.md)
explains the estimates and physical scaling in detail.

## Build and inspect the proofs

Install Lean's toolchain manager through the [Lean setup instructions](https://lean-lang.org/install/).
From the repository root, fetch the pinned Mathlib cache and build:

```sh
lake exe cache get
lake build
```

The checkout's `lean-toolchain` selects Lean v4.34.0-rc1. `lake build` checks the
entire exported library. Import it in Lean with `import Vbd`, or import a single
module for a focused development. For example:

```lean
import Vbd.Examples.AxialSpringChain

example {n : ℕ} (s : Vbd.AxialSpring.ChainSystem n) :
    ∃ p, s.Certificate p :=
  s.end_to_end
```

The integration checks live in [`tests/`](tests/) and compile separately:

```sh
lake lean tests/FixedPoint.lean
lake lean tests/VBD.lean
lake lean tests/VBDDerivative.lean
lake lean tests/VBDCurvature.lean
lake lean tests/VBDCoupling.lean
lake lean tests/VBDNonlinear.lean
lake lean tests/VBDColoring.lean
lake lean tests/VBDFinite.lean
```

While editing, use `lake build Vbd.Examples.AxialSpringChain` or
`lake lean path/to/file.lean` for focused checks, and `lake lint` for the
configured package linter.

The versioned [pre-commit hook](.githooks/pre-commit) validates the knowledge
bundle, builds the full library, and compiles all eight integration files.
To enable it in a fresh checkout, install `okflint` with `uv tool install okflint`
and run `git config core.hooksPath .githooks`. Run the same checks manually with
`bash .githooks/pre-commit`.

## Numerical experiments

The Python study evaluates serial and even/odd Newton
sweeps, their derivatives, and the conservatism of the analytic bounds. It
records state error, physical residual, sweep defect, and objective separately,
including stress cases beyond the theorem's parameter range.

With Python 3.11 or newer and `uv`, run from the repository root:

```sh
# Quick diagnostic grid; outputs go to an ignored runs directory.
uv run --locked python -m experiments.applicability.study

# Reproduce the full 336-case study in a separate directory.
uv run --locked python -m experiments.applicability.study \
  --preset study --output experiments/applicability/runs/study

# Check the experiment implementation.
uv run --locked python -m unittest discover -s experiments/applicability/tests -v
```

The checked-in [report](experiments/applicability/report.md),
[plot](experiments/applicability/convergence.png),
[summary](experiments/applicability/summary.json), and CSV data document the
baseline. All 192 cases within the theorem's parameter range reached the residual
target within six measured sweeps. That observation is separate from the
uniform Lean-proved 20-sweep guarantee. The experiment uses floating-point
arithmetic and supplies diagnostic evidence rather than proof premises.
Its [README](experiments/applicability/README.md) documents parameters, output
columns, and custom runs; the [mathematical analysis](knowledge/mathematics/axial-spring-contraction.md#numerical-behavior-and-limits-of-the-bounds)
also gives exact examples separating state contraction, residual progress,
and energy descent.

## Scope and extensions

The formal guarantees concern a finite solve of **one implicit-Euler timestep
in exact arithmetic**. Finite-iteration state and residual errors are included.
Floating-point rounding, approximate local solves, and GPU implementation
verification are outside the proved scope.

The generic library keeps locality separate from curvature, accepts
heterogeneous vector blocks and finite-support potential components, and states
convergence assumptions explicitly. Its concrete physical certificate covers
the scalar chain and parameter range above. Contraction on a certified region
does not establish global convergence for arbitrary VBD systems or initial
states; generic stationarity results do not imply minimization. The chain's
stationary-point uniqueness has an additional model-specific root-location
proof.

Richer vector and geometric materials, contact and friction, dynamic or coupled
batches, accelerated solvers, and error across timesteps require additional
mathematics. [What’s next](knowledge/project/whats-next.md) discusses possible
extensions and the results needed to support them.

## Project documentation and references

The [`knowledge/` index](knowledge/index.md) is the entry point to the project's
Open Knowledge Format bundle:

- [Mathematics](knowledge/mathematics/index.md): reusable theory and the worked chain derivation.
- [Formalization](knowledge/formalization/index.md): module boundaries, pinned Mathlib APIs, and dependency assessment.
- [Project](knowledge/project/index.md): architecture, research decisions, development history, and possible extensions.
- [References](knowledge/references/index.md): VBD papers, related formalizations, and contraction literature.

The original algorithm is described in A. H. Chen, Z. Liu, Y. Yang, and
C. Yuksel, “Vertex Block Descent,” *ACM Transactions on Graphics* 43(4),
Article 116, 2024 ([DOI](https://doi.org/10.1145/3658179),
[open preprint](https://arxiv.org/abs/2403.06321)). The
[curated literature review](knowledge/references/vbd-convergence-landscape.md)
places the project alongside classical block-coordinate theory, Augmented VBD,
higher-order VBD, and solver-level differentiation. Fixed-point existence and
iteration infrastructure build on
[Mathlib's contraction library](https://github.com/leanprover-community/mathlib4/blob/de5ce8a9a66a4aa68a9bdbb35b63a06d34d9ca11/Mathlib/Topology/MetricSpace/Contracting.lean).

## License

Original project code and documentation are licensed under the
[Apache License 2.0](LICENSE). Third-party dependencies and reference material,
including reproduced papers in `knowledge/references/`, retain their original
licenses and attribution.
