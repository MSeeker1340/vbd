---
type: Research Reference
title: VBD Formalization and Convergence Literature
description: Surveys VBD-family formulations together with identified formalization and convergence analyses.
tags: [vbd, formalization, convergence, block-newton, gauss-seidel, literature-review]
timestamp: 2026-09-15T00:00:00Z
---

# Scope and result

This survey covers VBD-family papers that introduce, extend, or instantiate
the solver, together with identified theorem-level convergence and
machine-checked formalization work. The publications identified here provide
algorithmic formulations, empirical convergence comparisons, and an exact
discrete-adjoint theorem for a VBD-family solver. No identified source
formalizes VBD in a proof assistant or proves a quantitative convergence theorem
for an actual VBD sweep. This is a bounded search result, not a claim that no
such work exists.

The [original VBD paper](./vbd-paper.md) supplies the local variational
formulation, full block-Newton update, coloring semantics, and empirical
convergence evidence. [Augmented VBD](#augmented-vbd),
[solver-level VBD differentiation](#solver-level-vbd-formulation), and
[higher-order VBD](#higher-order-elements-and-sub-stepping) modify or reuse
the basic update for distinct algorithmic goals.

# VBD-family formulations

## Vertex Block Descent

Chen, Liu, Yang, and Yuksel formulate VBD as vertex-level Gauss–Seidel solves
of the variational implicit-Euler objective. Each visit applies one local
Newton step; line search is optional and excluded from the reported runs. The
paper reports numerical convergence, stability, and performance, but does not
state a uniform contraction factor, invariant neighborhood, or finite-sweep
solution-error certificate for the unsafeguarded production sweep.

The paper is the primary source for the VBD map analyzed by this project. Its
local/global energy-change identity remains useful bookkeeping, while a
contraction result requires separate control of the complete sweep and
fixed-point/root consistency.

## Higher-order elements and sub-stepping

Saillant, Zara, Jaillet, and Damiand extend VBD from linear tetrahedra to
general isoparametric elements and higher-order shape functions. Their method
uses sub-stepping to improve convergence behavior and reports visual and
computational experiments. It changes the discretization and execution
configuration but does not state a formal convergence theorem or a
proof-assistant formalization.

## Solver-level VBD formulation

Shu, Jiang, Wu, Yang, Guibas, and Jiang formulate a finite VBD solve as an
ordered composition of block-update maps and differentiate that executed map
through a reverse colored sweep. This formulation makes the sweep Jacobian an
ordered product of local update Jacobians, matching the project’s distinction
between the executed solver map and the converged implicit-Euler equation. The
paper establishes an exact discrete-adjoint result for its solver family and
reports finite-budget experiments; it does not supply a contraction or
finite-sweep convergence certificate for the VBD forward sweep.

The source reinforces the project’s exact-execution boundary. Its saturated
steps and contact-coupled implementation are outside the first theorem scope,
but its composition viewpoint is compatible with the planned block-operator
and derivative-factor formalization.

## Augmented VBD

Giles, Diaz, and Yuksel extend VBD with augmented-Lagrangian constraint terms,
dual-variable updates, penalty adaptation, approximate Hessians, and
regularization for hard constraints and stiffness contrast. The paper presents
empirical convergence and low-iteration simulation results. Its iteration is
not the fixed VBD sweep map selected by this project: the multiplier and
penalty updates introduce additional evolving state, and its approximate local
matrices differ from the exact local Hessian route.

Augmented VBD is therefore evidence that stiffness contrast and constraints
matter in production, not a direct convergence theorem for the initial
exact-execution VBD formalization. An AVBD analysis requires an extended state
and an invariant/contraction or varying-map result for its actual update rules.

# Relevant external convergence theory

## Exact-minimization and M-function routes

Grippo and Sciandrone analyze nonlinear block Gauss–Seidel for constrained
optimization with exact block minimization. Under their stated convexity or
generalized-convexity assumptions, they obtain critical-point conclusions for
limit points; those hypotheses and conclusions differ from the single-Newton
VBD update. Hageman and Porsching study nonlinear block Gauss–Seidel and
successive overrelaxation for nonlinear systems `F(x)=0`. Under an M-function
condition they compare rates for block groupings, use Newton iterations for
block subproblems, and report numerical results.

These results establish useful precedent for separating the block update,
cross-block structure, and convergence assumptions. They do not provide the
neighborhood-specific derivative/comparison bounds needed for the project’s
nonlinear VBD sweep.

## Block diagonal dominance

Ilić-Spong, Katz, Dai, and Zaborszky prove sufficient convergence conditions
for underrelaxed block Jacobi and block Gauss–Seidel iterations for nonlinear
equations from a strict block-diagonal-dominance condition. Their load-flow
application includes three-bus and thirty-bus numerical examples and compares
block Gauss–Seidel with Newton–Raphson. This is a close antecedent for
expressing local inverse strength relative to cross-block coupling, although
its nonlinear function class, underrelaxation, and power-flow model differ
from VBD.

# Relationship to the project

The first project theorem concerns the exact, skip-free serial or static
proper-color VBD map on the selected axial-spring region. The external
nonlinear block-Gauss–Seidel results inform the selection of hypotheses but do
not replace proofs of local block regularity, ordered-composition bounds,
execution semantics, and fixed-point/implicit-Euler consistency. The
[contraction-based numerical studies](./contraction-based-numerics.md) record
generic contraction patterns separately from this VBD survey.

# Citations

[1] A. H. Chen, Z. Liu, Y. Yang, and C. Yuksel, “Vertex Block Descent,” *ACM
Transactions on Graphics* 43(4), Article 116, 2024.
[DOI](https://doi.org/10.1145/3658179),
[preprint](https://arxiv.org/abs/2403.06321).

[2] C. Giles, E. Diaz, and C. Yuksel, “Augmented Vertex Block Descent,” *ACM
Transactions on Graphics* 44(4), Article 90, 2025.
[DOI](https://doi.org/10.1145/3731195),
[author-hosted PDF](https://graphics.cs.utah.edu/research/projects/avbd/Augmented_VBD-SIGGRAPH25.pdf).

[3] L. Shu, Y. Jiang, K. Wu, Y. Yang, L. Guibas, and C. Jiang,
“Differentiate the Solver, Not the Equation: Reverse-Sweep Adjoints for Block
Implicit Simulation,” arXiv:2608.08559, 2026.
[Preprint](https://arxiv.org/abs/2608.08559).

[4] B. Saillant, F. Zara, F. Jaillet, and G. Damiand, “Going Further With
Vertex Block Descent,” *Computer Animation and Virtual Worlds* 36(3), e70039,
2025. [DOI](https://doi.org/10.1002/cav.70039).

[5] L. Grippo and M. Sciandrone, “On the Convergence of the Block Nonlinear
Gauss–Seidel Method under Convex Constraints,” *Operations Research Letters*
26(3), 127–136, 2000.
[DOI](https://doi.org/10.1016/S0167-6377(99)00074-7).

[6] L. A. Hageman and T. A. Porsching, “Aspects of Nonlinear Block Successive
Overrelaxation,” *SIAM Journal on Numerical Analysis* 12(3), 316–335, 1975.
[DOI](https://doi.org/10.1137/0712026).

[7] M. Ilić-Spong, I. N. Katz, H. Dai, and J. Zaborszky, “Block Diagonal
Dominance for Systems of Nonlinear Equations with Application to Load Flow
Calculations in Power Systems,” *Mathematical Modelling* 5(5), 275–297, 1984.
[DOI](https://doi.org/10.1016/0270-0255(84)90006-X).
