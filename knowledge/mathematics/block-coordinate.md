---
type: Mathematical Specification
title: Block Decompositions and Update Operators
description: Describes block states, operator composition and reordering, write support, simultaneous batches, and continuous-linear block representation.
tags: [write-support, block-updates, block-operators, block-matrices, coloring]
timestamp: 2026-09-08T00:00:00Z
---

In [implicit Euler as optimization](/mathematics/implicit-euler.md), the unknown `x ∈ X` is the
configuration sought at the end of one timestep. The previous configuration and velocity determine
the prediction `y`, and the solver seeks a stationary point of the incremental objective
`G_IE(x)`. A **state** here is a candidate configuration during that solve: it contains the
configuration degrees of freedom being updated. Velocity has been eliminated in forming the
implicit-Euler objective. An update operator changes this candidate within the timestep's solve.

Mechanical models often give these degrees of freedom a natural block structure. Particle and
multibody models group degrees of freedom by particle or body, with springs, joints, or contacts coupling
the participating blocks. In a nodal finite-element discretization of an elastic body, a block
can hold one node's position or displacement. Each element contributes an energy depending on
its incident nodes; assembling the elements produces a global energy with local interactions.
For example, a linear tetrahedral element couples four nodal blocks.

These models motivate viewing a configuration as a collection of blocks and organizing solver
updates around subsets of them. Local interactions couple blocks, so a change to one block can
affect the computation of updates to neighboring blocks. The
[finite-support interaction model](/mathematics/local-decomposition.md) describes that physical
dependency structure. The algebra here provides block states and operations on them, with write
support identifying the blocks an operation can change. It applies to state maps
independently of their physical origin or the objective being solved.

# Block states

Let `I` be a finite set of block indices and `Xᵢ` a real normed vector space for each block. The total
state space has the decomposition

$$
X=\bigoplus_{i\in I}^{\ell^2}X_i.
$$

The block spaces may differ and may be infinite-dimensional. A state is a block vector,
displayed using any fixed enumeration of `I`:

$$
x=(x_i)_{i\in I}=\begin{bmatrix}x_1\\ \vdots\\ x_n\end{bmatrix}\in X,
\qquad x_i\in X_i.
$$

Each `xᵢ` contains the entire configuration block at block index `i`. In a particle or body
model, `i` identifies a particle or body; its internal scalar coordinates belong to `Xᵢ`.
The `ℓ²` norm combines the block norms:

$$
\|x\|_X^2=\sum_{i\in I}\|x_i\|_{X_i}^2.
$$

Projection reads one block:

$$
\pi_i:X\to X_i,\qquad \pi_i x=x_i.
$$

Inclusion places a block value in an otherwise zero state:

$$
\iota_i:X_i\to X,\qquad
\iota_i b=\begin{bmatrix}0\\ \vdots\\ b\\ \vdots\\ 0\end{bmatrix},
\quad\text{with }b\text{ in block }i.
$$

Both maps are continuous linear. Replacing block `i` by `b` uses them to express the change
to a state:

$$
R_i(x,b)=x+\iota_i(b-\pi_i x).
$$

The other blocks retain their values. Block access, replacement, and the write-support
algebra below also apply to arbitrary block types; the normed vector-space structure supplies
the linear representation above.

# Operators on block states

An update operator transforms one candidate state into another:

$$
U:X\to X.
$$

A sequential algorithm applies such operators in a chosen order. Parallel algorithms group
updates into batches whose results must be combined. Composition and commutation describe the
ordering algebra for self-maps of any space; write support and block representation then relate
these maps to the decomposition of `X`.

## Sequential composition

Applying `U` and then `V` is represented by

$$
x\longmapsto U(x)\longmapsto V(U(x))=(V\circ U)(x).
$$

Composition is associative and has the identity map as its unit:

$$
T\circ(V\circ U)=(T\circ V)\circ U,
\qquad
\operatorname{id}_X\circ U=U\circ\operatorname{id}_X=U.
$$

For a finite sequence `𝓔 = (U₁, …, Uₘ)`, the composite and its intermediate states are

$$
S_{\mathcal E}=U_m\circ\cdots\circ U_1,
\qquad x_0=x,
\qquad x_r=U_r(x_{r-1}).
$$

The empty sequence represents the identity. Concatenating sequences composes their maps in
execution order:

$$
S_{\mathcal E\mathbin{+\!+}\mathcal F}
=S_{\mathcal F}\circ S_{\mathcal E}.
$$

This models a sequential VBD sweep once its updates and order have been chosen. A batch is itself
a state map, so the same algebra also describes a sequence of batches.

## Commutation and reordering

Two operators commute when their composite is independent of which is applied first:

$$
U\circ V=V\circ U.
$$

Adjacent commuting operators may be exchanged in a sequence. Consequently, a finite
pairwise-commuting family has the same composite in every enumeration. These identities justify
reordering algorithmic steps. For parallel execution, the simultaneous-batch construction below
specifies how to combine outputs and when that combination equals sequential composition.

## Write support

For a state-update operator `U : X → X`, its **write support** is the set of block indices
at which it changes some input state:

$$
\operatorname{supp}_{\mathrm w}(U)
=\{i\in I\mid \exists x\in X,\ (U(x))_i\ne x_i\}.
$$

Membership means that the block changes for at least one input; for another input, the same
block may remain unchanged. Every block outside the support is preserved for all inputs.
The support describes written blocks only: the computed value of a block may depend on the
entire input state.

A supplied set `W ⊆ I` is a **write-support bound** when it contains the support. Equivalently,

$$
\operatorname{supp}_{\mathrm w}(U)\subseteq W
\quad\Longleftrightarrow\quad
\forall x\in X,\ \forall i\notin W,\ (U(x))_i=x_i.
$$

Such bounds may include additional block indices and can be enlarged freely. They let operators,
multi-block batches, and complete executions share the same support calculus. Identity and
composition satisfy

$$
\operatorname{supp}_{\mathrm w}(\operatorname{id}_X)=\varnothing,
\qquad
\operatorname{supp}_{\mathrm w}(V\circ U)
\subseteq\operatorname{supp}_{\mathrm w}(U)\cup\operatorname{supp}_{\mathrm w}(V).
$$

The inclusion allows changes to cancel during composition. In particular, write-support bounds
`W` and `Z` for `U` and `V` give the bound `W ∪ Z` for `V ∘ U`, including when they overlap.

For a sequence `𝓔 = (U₁, …, Uₘ)`, this gives the bound

$$
\operatorname{supp}_{\mathrm w}(S_{\mathcal E})
\subseteq\bigcup_{r=1}^{m}\operatorname{supp}_{\mathrm w}(U_r).
$$

Any supplied bounds `Wᵣ` therefore give the execution a bound `⋃ᵣ Wᵣ`.

Disjoint write supports alone do not imply commutation: an operator may read a block changed
by another. The [interaction layer](/mathematics/local-decomposition.md) supplies physical locality
information; the production layer uses it to establish commutation for concrete operators under
a valid [coloring](/mathematics/coloring.md).

## Simultaneous batches

Let a finite family `(Uᵣ)ᵣ∈K` have pairwise-disjoint write-support bounds `(Wᵣ)ᵣ∈K`. The simultaneous
map `P_K` evaluates all operators on the same input and merges their selected blocks:

$$
(P_K(x))_j=
\begin{cases}
(U_r(x))_j,&j\in W_r,\\
x_j,&j\notin\displaystyle\bigcup_{r\in K}W_r.
\end{cases}
$$

Disjointness makes the writer for each selected block unique. The resulting map has write support
`⋃ᵣ supp_w(Uᵣ)`, bounded by `⋃ᵣ Wᵣ`. This construction applies to noncommuting operators, giving
the snapshot semantics needed for buffered batches with coupled reads.

For pairwise-commuting operators, the simultaneous map equals their sequential composition in
every enumeration. For a block index in `Wᵣ`, place `Uᵣ` first using commutation; all remaining
operators preserve that block. This identifies the sequential output with the merge formula.

A colored algorithm processes its color classes in a chosen order, with each class interpreted
as a simultaneous batch. Within a commuting class, the batch may also be interpreted as any
sequential ordering.

## Continuous-linear block representation

For finite `I` and normed vector-space blocks, projection and inclusion are continuous linear
maps. A continuous linear operator `A : X → X` is represented by the operator-valued block matrix

$$
[A]_{ij}=\pi_i\circ A\circ\iota_j : X_j\to X_i.
$$

Every finite family of continuous-linear entries assembles into such an operator, and extraction
and assembly are inverse. The representation preserves operator arithmetic and keeps each block
basis-free. A displayed matrix uses any enumeration of `I`; the represented map is independent
of that choice.

The write support of `A` consists of the block rows in which it differs from the identity:

$$
\operatorname{supp}_{\mathrm w}(A)
=\{i\in I\mid \exists j\in I,\ [A-\operatorname{id}_X]_{ij}\ne 0\}.
$$

Thus block rows outside the write support are identity block rows. For a simultaneous batch of
linear operators, each selected block row is taken from its designated operator, and every
unselected block row is an identity block row.

## Connection to linearization

The [roadmap](/project/roadmap.md) uses this algebra to supply actual execution maps and their
linear representations to later bridge layers. For differentiable updates, those layers
apply the chain rule at the intermediate states:

$$
[DS_{\mathcal E}(x)]
=[DU_m(x_{m-1})]\cdots[DU_1(x_0)].
$$

Preserved output blocks give identity block rows in the derivative. Simultaneous batches supply
block rows evaluated at a common input. These two execution semantics determine the linear operators
whose bounds are studied in the [contraction analysis](/mathematics/curvature.md). Differentiability,
norm estimates, and concrete VBD formulas enter in those later phases.
