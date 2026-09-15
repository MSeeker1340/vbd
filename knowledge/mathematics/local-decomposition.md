---
type: Mathematical Specification
title: Finite-Support Physical Interactions
description: Defines live finite-support interaction hypergraphs, their induced conflict relation, and exact local energy bookkeeping.
tags: [locality, sparsity, interactions, hypergraph, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Purpose and scope

This specification is the locality half of Phase 4. It decomposes the potential in the
[implicit-Euler problem](./implicit-euler.md) into finitely supported physical interactions and
derives the combinatorial information used by [proper colorings](./coloring.md). It records no
positive-curvature, invertibility, differentiability, or contraction premise. Those analytic
properties remain separate from interaction support.

Let `ι` index the blocks, let `B : ι → Type*` be their family, and write `X = BlockSum B` for a
candidate configuration. Let `ε` index a fixed universe of possible interactions. A particular
solve has a finite **live set** `A : Finset ε`; this permits material, constraint, and collision
interactions to be distinguished by which elements of the universe are live, without changing the
basic definitions.

# Local interactions and the live hypergraph

Each interaction `e : ε` has a finite block support

$$
N(e) : \operatorname{Finset}\,\iota
$$

and an energy contribution `P_e : X → ℝ`. For states `x` and `z`, write

$$
x =_S z \quad\Longleftrightarrow\quad
\forall i\in S,\;x_i=z_i.
$$

The contribution is **extensionally local** on its support when

$$
x =_{N(e)} z \quad\Longrightarrow\quad P_e(x)=P_e(z).
$$

The assembled live potential is

$$
P_A(x)=\sum_{e\in A}P_e(x).
$$

Together, `(ι, (N(e))_{e ∈ A})` is the live interaction hypergraph. It covers pairwise springs
and edges as two-element hyperedges, and triangle, tetrahedron, bending, contact, and other
multi-block elements as arbitrary finite hyperedges. Empty and singleton supports are permitted:
they contribute a constant or one-block term and create no conflict between distinct blocks.

When the assembled potential supplies the potential field in an implicit-Euler step, the Phase 1
incremental objective uses `E = P_A`. Smoothness assumptions needed for its gradient or Hessian
are additional properties of the `P_e`; support locality alone is sufficient for the results here.

# Incident interactions and exact energy bookkeeping

For a block set `S : Finset ι`, define its live incident interactions by

$$
\operatorname{Inc}_A(S)
=\{e\in A\mid N(e)\cap S\ne\varnothing\}.
$$

For a single block, use `Inc_A(i) = Inc_A({i})`. If two states agree outside `S`, every live
interaction outside `Inc_A(S)` has the same value at both states. Therefore

$$
P_A(z)-P_A(x)
=\sum_{e\in\operatorname{Inc}_A(S)}\bigl(P_e(z)-P_e(x)\bigr)
\quad\text{whenever}\quad
\forall i\notin S,\;z_i=x_i.
$$

In particular, replacing only block `i` by `b` gives

$$
P_A(R_i(x,b))-P_A(x)
=\sum_{e\in\operatorname{Inc}_A(i)}
  \bigl(P_e(R_i(x,b))-P_e(x)\bigr).
$$

This is an equality of energy changes, not a decomposition of the energy into disjoint
per-vertex objectives: interactions incident to different vertices can overlap. It identifies
exactly which terms must be reevaluated for a proposed block replacement.

# Induced physical conflict relation

For distinct blocks, define the live conflict relation by

$$
i\mathrel{\mathsf{\#}_A}j
\quad\Longleftrightarrow\quad
i\ne j\ \land\ \exists e\in A,\;i\in N(e)\land j\in N(e).
$$

The **physical conflict graph** has vertex set `ι` and these edges. The relation is symmetric and
irreflexive. Its neighbor set is contained in the union of supports of `Inc_A(i)`, with `i`
removed. Thus an edge records exactly that the two blocks co-occur in a supplied live support;
the support itself may be a conservative locality bound. No dense global graph is assumed.

For a pairwise interaction system this graph is the usual primal graph. For a general hypergraph,
each hyperedge induces a clique on its distinct support vertices. The hypergraph remains the
primary physical data because it retains which blocks occur together in one interaction; the graph
is its coloring projection.

# Phase-4 theorem targets

The Lean module `Vbd/Integrator/LocalInteractions.lean` packages finite supports, local
interaction values, a finite live set, and the following results.

1. Extensional locality is closed under the finite live sum, and interactions not incident to a
   changed block set cancel from its energy difference.
2. The induced conflict relation is symmetric and irreflexive.
3. The conflict edge definition is equivalent to two distinct vertices occurring in a common live
   hyperedge.
4. Enlarging the live set can only add conflict edges; restricting it can only remove them.

The module exports combinatorial locality. It does not define a VBD Newton update or infer an
update's read dependence merely from its write support. The production VBD layer later proves that
its concrete update for block `i` reads only the interactions incident to `i`, then uses the
conflict-free condition to establish same-color commutation.

# Concrete support examples

For a four-block chain with live pairwise supports

$$
\{0,1\},\quad\{1,2\},\quad\{2,3\},
$$

the induced graph is the path `0—1—2—3`. The parity map `χ(i)=i mod 2` is a valid two-coloring.

For one triangular interaction with support `{a,b,c}`, every two distinct vertices conflict. The
map `χ(a)=0`, `χ(b)=1`, and `χ(c)=2` is a valid three-coloring. This multi-vertex example makes
the hypergraph condition explicit: a valid color assigns distinct colors to all vertices in one
live interaction, rather than merely recording a pairwise element type.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
