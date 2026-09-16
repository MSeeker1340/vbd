# Verified convergence certificates for Vertex Block Descent

This repository is a Lean 4 formalization of one practical route to
**quantified local convergence guarantees for Vertex Block Descent (VBD)**. It
does not introduce a new simulator or an improved VBD algorithm. It provides a
reusable proof framework for establishing that a stated mechanical model,
timestep, execution order, and warm-start region make a prescribed VBD sweep
converge to the intended implicit-Euler solve at a stated geometric rate.

## Intended audience

The intended audience consists of simulation engineers and researchers seeking
explicit stability and accuracy guarantees for systems solved by VBD, together
with formalization researchers studying modular Lean developments of
numerical-analysis arguments.

## Background

VBD was introduced by Chen, Liu, Yang, and Yuksel as a vertex-block
Gauss–Seidel method for the variational form of implicit Euler [1]. At every
vertex it forms a small local Newton solve while holding the other vertices
fixed. This makes each update cheap, exposes vertex-level parallelism through
coloring, and avoids a global linear solve. The paper reports large-scale
simulation results, stability in bounded-iteration use, and numerical
convergence; its production evaluation generally uses the full local Newton
step without the optional line search [1].

The VBD literature also contains algorithmic extensions and alternative
formulations. Augmented VBD introduces multiplier, penalty, and regularization
updates for difficult constraints and stiffness contrast [3]; higher-order VBD
extends the discretization to isoparametric elements and uses sub-stepping to
improve observed convergence behavior [4]. Solver-level differentiation work
also represents a finite VBD solve as an ordered composition of updates and
proves an exact discrete-adjoint result for that executed solve [5]. These
results broaden the range of VBD formulations and applications without making
their convergence questions interchangeable: their state, local update, and
execution semantics differ.

The literature review recorded in
[VBD formalization and convergence literature](knowledge/references/vbd-convergence-landscape.md)
has not identified a proof-assistant formalization of VBD or a quantitative
convergence theorem for an actual VBD forward sweep. This is a bounded review
finding, not a claim that no such result exists. The identified VBD sources
provide algorithmic formulations, empirical convergence comparisons, or an
exact adjoint theorem, but not a model-specific finite-sweep
convergence-check framework for the unsafeguarded sweep. In particular,
local/global energy bookkeeping does not alone establish a unique solution,
convergence of the iterates, a rate, or an error after a fixed number of
sweeps. A full Newton step can also fail to decrease its local energy away
from the solution; the original paper explicitly presents line search as the
mechanism that would make that descent conclusion available [1]. Classical
block-coordinate convergence theory likewise has assumptions and conclusions
that need not match a nonlinear, ordered, block-Newton VBD sweep with its
chosen execution semantics [2].

## Our approach

This repository closes a precise part of that gap by treating the actual VBD
sweep as a map T. Rather than infer a global optimization conclusion from the
method's mechanics, the formalization proves contraction directly on a
complete, forward-invariant region. Banach's fixed-point theorem then provides
a unique fixed point and geometric convergence. A separate consistency proof
identifies that fixed point with the root of the implicit-Euler residual. This
separation is important: contraction can permit intermediate increases in
objective value or physical residual while still forcing convergence to the
correct state.

The central tool is contractive fixed-point iteration. In a certified instance,
the framework proves

$$
\|T^s(x_0)-x^*\| \le q^s\|x_0-x^*\|,\qquad 0\le q<1,
$$

where T is the *actual* serial or properly colored VBD sweep and x* is an
implicit-Euler stationary state. The norm, invariant neighborhood, and
physical parameter range are explicit. This yields a finite sweep budget for
a chosen state-error or residual tolerance, rather than an empirical judgment
that several simulated trajectories settle or a fixed iteration count selected
only to meet a runtime budget.

For a smooth, block-structured implicit-Euler model with an exact serial or
static proper-color VBD execution, the framework states a theorem with the
following shape.

> Given explicit local block-inverse bounds, cross-block coupling and Hessian
> variation bounds, a proved invariant region, a valid execution plan, and a
> covered warm start, the VBD sweep is a contraction in a stated block norm.
> Its unique regional fixed point is an implicit-Euler stationary solution;
> after s sweeps the theorem bounds state error and, where residual regularity
> is supplied, physical residual error.

The inputs are mass and timestep scales, local stiffness or inverse-Hessian
bounds, incident coupling, constitutive-law variation over a state region, a
coloring/order, and a warm-start bound. The output is a certificate of the
form “this execution is covered in this region, with this factor and this
sweep budget.” The proof does not replace physical modelling or numerical
testing; it makes the assumptions behind a quantitative claim visible and
machine-checked.

The initial guarantee is a one-timestep theorem. Extending it to a full simulation
requires an additional argument that the next timestep's input remains in a
certified region and that accumulated solver and discretization errors are
controlled.

The guarantees are deliberately conditional and local. They do not claim that
all VBD systems contract, that every stationary point minimizes an energy, or
that a one-timestep guarantee proves long-horizon simulation stability.
Collision activation, friction, floating-point/GPU error, approximate local
solves, accelerated iterations, and dynamic buffered execution each require
their own analysis. The library does not attempt a catch-all formalization of
numerical mechanics; it presents one coherent, reusable route whose
hypotheses can be tested on a concrete system.

## Mathematical architecture

The formalization preserves three foundations that are useful independently,
then joins them only in explicit bridge layers.

1. **[Implicit Euler as stationarity](knowledge/mathematics/implicit-euler.md).**
   With predictor y, mass operator M, timestep h, and potential P, the
   incremental objective is

   $$
   G_{IE}(x)=\frac{1}{2h^2}\langle x-y,M(x-y)\rangle+P(x),
   \qquad F_{IE}(x)=\nabla G_{IE}(x).
   $$

   A timestep solution is, in the general theory, a stationary point
   F_IE(x)=0. This avoids accidentally assuming convexity, minimization,
   uniqueness, or a rate where the model has not supplied them.

2. **[Block updates and execution semantics](knowledge/mathematics/block-states-and-operators.md).**
   A state is a heterogeneous family of vertex blocks. The library represents
   single-block writes, supports under composition, simultaneous disjoint
   updates, and continuous linear block operators. This provides a precise
   language for what a serial order changes and when a same-color batch is
   equivalent to any sequential ordering. Read dependencies remain a separate
   physical fact; write support alone does not prove that updates commute.

3. **[Contractive dynamics](knowledge/mathematics/contractive-fixed-point-iteration.md).**
   On a nonempty complete invariant set S, if T(S) ⊆ S and T has factor q < 1,
   then T has a unique fixed point in S and its iterates converge
   geometrically. The framework also supplies a priori and defect-based error
   estimates. A derivative/operator bound on a convex region is the usual way
   to establish the required Lipschitz factor.

The synthesis is specified in
[curvature, coupling, and VBD contraction](knowledge/mathematics/curvature.md),
[local decomposition and coloring](knowledge/mathematics/local-decomposition-and-coloring.md).
It differentiates the actual local Newton updates, bounds their block effects
by a nonnegative comparison matrix, propagates those bounds through the real
execution order, and proves q < 1 in an appropriate block norm. It then
connects the sweep's fixed point back to implicit-Euler stationarity and
transports state error to a physical residual when the model supplies the
needed regularity.

## Lean library status and result chain

The package is pinned to Lean and Mathlib v4.34.0-rc1. The implemented
foundation modules are exported through [Vbd.lean](Vbd.lean):

| Module | Present result |
|---|---|
| [Vbd/Integrator/ImplicitEulerEnergy.lean](Vbd/Integrator/ImplicitEulerEnergy.lean) | Basis-free incremental energy, gradient/residual, and Hessian identities. |
| [Vbd/Block/Basic.lean](Vbd/Block/Basic.lean) | Heterogeneous block states, access, injection, and replacement. |
| [Vbd/Block/Update.lean](Vbd/Block/Update.lean) | Write support under composition and simultaneous merging of disjoint writes. |
| [Vbd/Block/Operator.lean](Vbd/Block/Operator.lean) | Continuous-linear block entries, finite assembly, reconstruction, and arithmetic. |
| [Vbd/Dynamics/Contraction.lean](Vbd/Dynamics/Contraction.lean) | Invariant-set fixed-point interface, convergence to a supplied fixed point, finite-iterate bounds, and a defect estimate. |
| [Vbd/Integrator/LocalPotential.lean](Vbd/Integrator/LocalPotential.lean) | Finite-support component potentials, exact local energy cancellation, and bridges from support graphs to Mathlib proper colorings. |

The following TODOs identify the unfinished pieces required for an end-to-end
VBD certificate.

- **TODO — derivative-to-contraction bridge:** Turn uniform derivative bounds
  on convex neighborhoods into the normed-space contraction interface.

- **TODO — implicit-Euler fixed-point bridge:** Prove, for an arbitrary solver
  map with a designated stationary fixed point, the state and residual
  convergence conclusions used by VBD.

- **TODO — composed-update contraction theorem:** Assemble block derivative
  estimates through serial and proper-color execution using ordered comparison
  matrices in a stated norm.

- **TODO — production VBD synthesis:** Define the actual block-Newton update,
  including its regular/skip behavior and external execution plan; prove
  fixed-point consistency, derivative bounds, contraction, and finite-sweep
  error bounds.

- **TODO — end-to-end Lean worked instance:** Instantiate that chain for the
  axial-spring model below, including its explicit 20-sweep residual budget.

The [module map](knowledge/formalization/module-map.md) records module
boundaries and dependencies. The internal [roadmap](knowledge/project/roadmap.md)
records implementation sequencing; this README explains the result, whereas
the roadmap explains its build order.

## Worked applicability example: nonlinear axial spring chains

The first application is deliberately modest but nontrivial: masses move on a
line and adjacent masses are coupled by quadratic-plus-hardening springs. It
contains genuine cross-block coupling, nonlinear local Hessians, serial
Gauss–Seidel execution, and an even/odd proper-color execution. It is not a
calibration of a general 3D elastic material.

For normalized displacement u, predictor y, relative mass a_i, and edge
coefficient b_e=h²k_e/m_min, the model uses

$$
G(u)=\frac12\sum_i a_i(u_i-y_i)^2+
\sum_{e=\{i,j\}}b_e\left(\frac{(u_i-u_j)^2}{2}
+\frac{\eta(u_i-u_j)^4}{4}\right),\qquad \eta\ge0.
$$

The accompanying [axial-spring analysis](knowledge/mathematics/axial-spring-contraction.md)
derives explicit, model-specific hypotheses. In particular, for the stated
predictor box, 0 ≤ η ≤ 1, and

$$
\frac{h^2 k_{max}}{m_{min}}\le\frac14,
$$

it derives an invariant maximum-norm box and a conservative sweep factor
q ≤ 0.512. With the specified warm start, this implies a scaled
implicit-Euler residual below 10⁻⁶ in 20 sweeps (the calculation gives
3.25 × 10⁻⁷). This remains an analytic worked derivation, supported by a
reproducible numerical study, until the end-to-end Lean instance is completed.
The experiments show that the assumptions are meaningful rather than purely
diagonal or asymptotic, while remaining separate from a uniform proof.

The example also shows what transfer to another smooth system entails. A new
model can reuse the generic state, update, coloring, and contraction results,
but must establish local inverse bounds, mixed-block coupling, Hessian
variation, an invariant region, execution semantics, fixed-point/root
consistency, and warm-start coverage. Vector-valued spring blocks and general
finite graphs fit the same pattern. Geometric elasticity, contact, and friction
need additional material- and execution-specific hypotheses; dynamic contacts
can invalidate a static coloring, and nonsmooth laws can require a different
solution interface.

## Using the repository

The checked foundations and spring-chain diagnostics can be built and run with:

```bash
lake exe cache get
lake build

uv run --locked python -m experiments.applicability.study
uv run --locked python -m unittest discover -s experiments/applicability/tests -v
```

The Python experiment is evidence and a diagnostic aid; it is not part of the
Lean proof chain. Its [README](experiments/applicability/README.md) documents
parameters and outputs. The [development architecture](knowledge/project/architecture.md)
and [backlog](knowledge/project/backlog.md) govern further formalization work.

## References

1. A. H. Chen, Z. Liu, Y. Yang, and C. Yuksel, “Vertex Block Descent,” *ACM
   Transactions on Graphics* 43(4), Article 116, 2024.
   [DOI](https://doi.org/10.1145/3658179),
   [open preprint](https://arxiv.org/abs/2403.06321).

2. P. Tseng, “Convergence of a Block Coordinate Descent Method for
   Nondifferentiable Minimization,” *SIAM Journal on Optimization* 11(2),
   2001. [DOI](https://doi.org/10.1137/S1052623498336933).

3. C. Giles, E. Diaz, and C. Yuksel, “Augmented Vertex Block Descent,” *ACM
   Transactions on Graphics* 44(4), Article 90, 2025.
   [DOI](https://doi.org/10.1145/3731195).

4. B. Saillant, F. Zara, F. Jaillet, and G. Damiand, “Going Further With
   Vertex Block Descent,” *Computer Animation and Virtual Worlds* 36(3),
   e70039, 2025. [DOI](https://doi.org/10.1002/cav.70039).

5. L. Shu, Y. Jiang, K. Wu, Y. Yang, L. Guibas, and C. Jiang, “Differentiate
   the Solver, Not the Equation: Reverse-Sweep Adjoints for Block Implicit
   Simulation,” arXiv:2608.08559, 2026.
   [Preprint](https://arxiv.org/abs/2608.08559).

6. S. Banach, “Sur les opérations dans les ensembles abstraits et leur
   application aux équations intégrales,” *Fundamenta Mathematicae* 3, 1922.
   The formal fixed-point infrastructure is provided by
   [Mathlib’s contraction library](https://github.com/leanprover-community/mathlib4/blob/de5ce8a9a66a4aa68a9bdbb35b63a06d34d9ca11/Mathlib/Topology/MetricSpace/Contracting.lean).
