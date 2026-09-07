---
type: Mathematical Specification
title: Block Decompositions and Update Operators
description: Specifies write supports across external executions, commutation, simultaneous batches, and their continuous-linear block representation.
tags: [write-support, block-updates, block-operators, block-matrices, coloring]
timestamp: 2026-09-07T00:00:00Z
---

# Background

In [implicit Euler as optimization](/mathematics/implicit-euler.md), the unknown `x ∈ X` is the
configuration sought at the end of one timestep. The previous configuration and velocity determine
the prediction `y`, and the solver seeks a stationary point of the incremental objective
`G_IE(x)`. A **state** here is a candidate configuration during that solve: it contains the
configuration degrees of freedom being updated. Velocity has been eliminated in forming the
implicit-Euler objective. An update operator changes this candidate within the timestep's solve.

Mechanical models often give these degrees of freedom a natural block structure. Particle and
multibody models group coordinates by particle or body, with springs, joints, or contacts coupling
the participating blocks. In a nodal finite-element discretization of an elastic body, a block
can hold one node's position or displacement. Each element contributes an energy depending on
its incident nodes; assembling the elements produces a global energy with local interactions.
For example, a linear tetrahedral element couples four nodal blocks.

These models motivate viewing a configuration as a collection of blocks and organizing solver
updates around subsets of them. Local interactions couple blocks, so a change to one block can
affect the computation of updates to neighboring blocks. The
[finite-support interaction model](/mathematics/local-decomposition.md) describes that physical
dependency structure. The algebra here provides block states and operations on them, with write
support recording which coordinates an operation preserves. It applies to supplied state maps
independently of their physical origin or the objective being solved.

# Block states

Represent a state as `x = (xᵢ)ᵢ∈I`, where `I` indexes the blocks and `xᵢ ∈ Xᵢ` is the entire
configuration block at index `i`. Blocks may have different types or dimensions. Coordinate
access reads a block, and replacement substitutes a new value for that block while preserving
the others. Write-support and execution statements apply to arbitrary block types; linear
representation uses a finite index set and real normed
vector spaces, with total space

$$
X=\bigoplus_{i\in I}^{\ell^2}X_i,
\qquad
\|x\|^2=\sum_{i\in I}\|x_i\|^2.
$$

The blocks may be infinite-dimensional. Write `πᵢ : X → Xᵢ` for projection and `ιᵢ : Xᵢ → X`
for inclusion.

# Write support

For a state-update operator `U : X → X` and a supplied set of coordinates `W ⊆ I`, define

$$
\operatorname{WritesWithin}(U,W)
\quad\Longleftrightarrow\quad
\forall x\in X,\ \forall j\notin W,\ (U(x))_j=x_j.
$$

The set `W` is an upper bound on the coordinates that may change. An operator may preserve some or
all coordinates inside `W`, and any larger set is also a valid write support. Its output on a
written coordinate may depend on the entire input state.

This property records preserved coordinates uniformly for operators, multi-block batches, and
complete executions. If `WritesWithin(U,W)` and `WritesWithin(V,Z)`, then

$$
\operatorname{WritesWithin}(V\circ U,\ W\cup Z).
$$

The identity has empty write support. Applying these laws through a finite execution gives a
support bound for the whole execution, including when individual write supports overlap.

# External execution

An external controller supplies a finite sequence `𝓔 = (U₁, …, Uₘ)`. Its execution and
intermediate states are

$$
S_{\mathcal E}=U_m\circ\cdots\circ U_1,
\qquad x_0=x,
\qquad x_r=U_r(x_{r-1}).
$$

If `Uᵣ` has write support `Wᵣ`, the execution preserves every coordinate outside `⋃ᵣ Wᵣ`.
Concatenating executions composes their maps in execution order. A batch is itself a state map,
so the same composition applies to externally ordered batches.

# Commutation and reordering

Operators `U` and `V` commute when `U ∘ V = V ∘ U`. Adjacent commuting operators may be exchanged
in an execution, and a finite pairwise-commuting family has the same composite in every enumeration.

Disjoint write supports alone do not imply commutation: an operator may read a coordinate changed
by another. Commutation expresses that their effects are compatible with either execution order.
The [interaction layer](/mathematics/local-decomposition.md) supplies physical locality information;
the production layer uses it to establish commutation for concrete operators under a valid
[coloring](/mathematics/coloring.md).

# Simultaneous batches

Let a finite family `(Uᵣ)ᵣ∈K` have pairwise-disjoint write supports `(Wᵣ)ᵣ∈K`. The simultaneous
map `P_K` evaluates all operators on the same input and merges their written coordinates:

$$
(P_K(x))_j=
\begin{cases}
(U_r(x))_j,&j\in W_r,\\
x_j,&j\notin\displaystyle\bigcup_{r\in K}W_r.
\end{cases}
$$

Disjointness makes the writer for each selected coordinate unique. The resulting map has write
support `⋃ᵣ Wᵣ`. This construction applies to noncommuting operators, giving the snapshot semantics
needed for buffered batches with coupled reads.

For pairwise-commuting operators, the simultaneous map equals their sequential composition in
every enumeration. For a coordinate in `Wᵣ`, place `Uᵣ` first using commutation; all remaining
operators preserve that coordinate. This identifies the sequential output with the merge formula.

Color classes are executed in an external order, with each class interpreted as a simultaneous
batch. Within a commuting class, the batch may also be interpreted as any sequential ordering.

# Continuous-linear block representation

For finite `I` and normed vector-space blocks, projection and inclusion are continuous linear
maps. A continuous linear operator `A : X → X` is represented by the operator-valued block matrix

$$
[A]_{ij}=\pi_i\circ A\circ\iota_j : X_j\to X_i.
$$

Every finite family of continuous-linear entries assembles into such an operator, and extraction
and assembly are inverse. The representation preserves operator arithmetic and keeps each block
basis-free. A displayed matrix uses any enumeration of `I`; the represented map is independent
of that choice.

Write support has a direct interpretation here: rows outside the write support are the
corresponding identity rows. For a simultaneous batch of linear operators, each written row is
taken from its designated operator, and every unwritten row is an identity row.

# Use by later phases

The [roadmap](/project/roadmap.md) uses this algebra to supply actual execution maps and their
linear representations to later bridge layers. For differentiable supplied updates, those layers
apply the chain rule at the intermediate states:

$$
[DS_{\mathcal E}(x)]
=[DU_m(x_{m-1})]\cdots[DU_1(x_0)].
$$

Preserved output coordinates give identity rows in the derivative. Simultaneous batches supply
rows evaluated at a common input. These two execution semantics determine the linear operators
whose bounds are studied in the [contraction analysis](/mathematics/curvature.md). Differentiability,
norm estimates, and concrete VBD formulas enter in those later phases.
