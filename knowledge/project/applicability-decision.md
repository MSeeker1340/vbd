---
type: Architecture Decision
title: First Quantitative VBD Applicability Route
description: Records the rationale, evaluation contract, and implementation scope for the first VBD convergence example.
tags: [applicability, theorem-route, maximum-norm, execution]
timestamp: 2026-09-14T00:00:00Z
---

# Decision

**Proceed with maximum-norm state contraction and independent fixed-point/root consistency.**
The first end-to-end Lean instance is a coupled axial chain with quadratic and hardening
quartic springs, using exact serial or static proper-color VBD sweeps.
The [mathematical article](/mathematics/axial-spring-contraction.md) develops the model, derives
its bounds, and explains their extension to richer mechanics.

AP-01–AP-03 is complete for this first family. The analytic result supports a scaled physical
residual below $10^{-6}$ within 20 sweeps when $h^2k_{\max}/m_{\min}\le1/4$,
$0\le\eta\le1$, and the stated predictor condition holds. VB-08 remains open until its
Lean instantiation is proved. Applicability to general production materials, contact, and
friction remains a separate physical assessment.

# Why this model

The first example must exercise the entire proof chain while allowing explicit physical
hypotheses to be checked. An axial chain satisfies this requirement with little constitutive
or geometric machinery:

* Adjacent springs give genuine cross-block coupling, so the sweep is not a collection of
  independent solves. The path also supplies nontrivial proper-color execution.
* The quadratic case isolates the Gauss–Seidel mechanism. The quartic case adds a changing
  Hessian and the force-dependent derivative term needed for a nonlinear neighborhood proof.
* The rail constraint makes inverse and invariant-region estimates tractable. These scalar
  estimates can instantiate dimension-independent derivative and composition theorems.
* Positive inertia and bounded hardening permit explicit timestep, predictor and iteration
  bounds, instead of an unspecified sufficiently small neighborhood.

The model's simplicity also bounds its evidence: its convex spring law does not test indefinite
elasticity, contact activation, or friction. The vector extension in the mathematical article
shows that the proof method supports larger blocks; it does not calibrate real 3D materials.
The [VBD reference](/references/vbd-paper.md) motivates spring examples, inertia initialization,
and contrast stress tests. It supplies no measured calibration for this particular quartic law.

# Why this guarantee and norm

State contraction provides a finite-sweep budget across the supported range and permits
physical-residual transport using a quantitative regularity bound. Strict residual progress
alone supplies no arbitrary-accuracy budget. Direct quantitative residual reduction is useful
on the smaller range $h^2k_{\max}/m_{\min}\le0.2$, but the available sufficient estimate
is ineffective at the full-range endpoint. Exact examples also demonstrate that physical
residuals can increase under a state-contractive sweep.

The block maximum norm follows the componentwise update structure and avoids a
$\sqrt n$ conversion penalty in the contraction factor. It preserves a per-vertex error
interpretation as chain length grows. Weighted or energy norms and several-sweep contraction
remain options for a broader stiff-regime assessment.

Exact serial and proper-color execution exercise ordering and snapshot semantics while keeping
physical independence explicit. Dynamic same-color coupling and approximate solves require
additional derivative or perturbation estimates, so they are follow-on execution scopes.

# Evaluation contract and provenance

The fixed study preset uses the following design parameters, independently of the measured
iteration counts. They are synthetic engineering examples and stress ranges, not material data
or a perceptual accuracy standard.

| Quantity | Study value or range | Purpose |
|---|---|---|
| Rest spacing $\ell$ | $0.1\,\mathrm m$ | Gives displacements a physical scale |
| Minimum mass | $0.001\,\mathrm{kg}$ | Sets the inertial scale |
| Maximum stiffness | $1$–$10^4\,\mathrm{N/m}$ | Exposes timestep restrictions |
| Timestep calibration | $10^{-4}$–$0.04\,\mathrm s$ | Covers admitted and stress cases |
| Vertex count | $4,16,64$ | Tests size effects |
| Normalized stiffness $\alpha$ | $0.01,0.1,0.2,0.25,1,10,100$ | Spans inertia-dominated and stiff solves |
| Mass ratio | $1,1000$ | Alternating heavy/light vertices |
| Stiffness ratio | $1,10000$ | Alternating stiff/soft edges |
| Nonlinearity $\eta$ | $0,1$ | Quadratic baseline and nonlinear case |
| Predictor | $y_i=0.05\cos(1.7i)$ | Deterministic, nonuniform inertia warm start |
| Certificate box | $\|u\|_\infty\le0.1$ | Explicit intermediate-state region |
| Residual tolerance and budget | $10^{-6}$, 20 sweeps | Quantitative evaluation target |

Every normalized grid value has a realization within the calibration ranges: for example,
$k_{\max}=100\,\mathrm{N/m}$ and $h=\sqrt{\alpha m_{\min}/k_{\max}}$.
A separate exact large-amplitude example tests objective increase outside the certified range.
The experiment's [`study` preset](../../experiments/applicability/README.md) reproduces this grid;
CLI overrides support further inspection without changing the accepted theorem scope.

# Project scope and reuse contract

The chain is the first application of a reusable formal library. Foundation and bridge
statements retain block spaces, residuals, supports, execution orders and bound data as
parameters. Chain geometry, scalar signs and constitutive constants enter through instance
lemmas. A chain-only proof without the generic interfaces does not satisfy the implementation
acceptance condition in the [module map](/formalization/module-map.md).

The accepted metric is theorem-local: retain `BlockSum` and its existing `PiLp 2` representation,
with explicit distance transport where needed. CT-04 remains norm-polymorphic. The experiment's
Python environment is separate from the Lean dependency graph.

CT-04 is next. The [backlog](./backlog.md) carries the proof dependencies, including IF-03 for
physical-residual transport. CT-05, BC-04 and perturbation extensions remain deferred until an
approximate or hybrid execution variant has an applicability certificate. The generic
higher-arity coloring example in LI-03 remains required, independently of the chain certificate.

The initial guarantee concerns one timestep with the specified predictor region. It excludes
multi-timestep error accumulation, nonconvex material guarantees, contact/friction, and
convergent objective-increasing trajectories. Extending the application requires the new
model's actual update, residual, intermediate-state bounds, initial-state coverage and accuracy
budget to discharge the reusable hypotheses described in the
[extension analysis](/mathematics/axial-spring-contraction.md#reuse-beyond-the-chain).
