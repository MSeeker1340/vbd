---
type: Mathematical Specification
title: Finite-Support Potential Components
description: Defines finite-support components of the implicit-Euler potential, their induced coloring graph, and exact local energy bookkeeping.
tags: [locality, sparsity, potential-decomposition, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Purpose and scope

This specification is the locality half of Phase 4. It decomposes the potential $E$ in the
[implicit-Euler problem](./implicit-euler.md) into finitely supported components and derives the
combinatorial information used by [proper colorings](./coloring.md). It records no
positive-curvature, invertibility, differentiability, or contraction premise. Those analytic
properties remain separate from the support data.

# Potential components

A **potential component** is one labeled summand in a decomposition of $E$. The label distinguishes
summands; it carries no additional physical interpretation. The total potential is the sum of the
components selected for the problem under consideration.

Let $I$ be a finite set of block indices, let $X_i$ be the configuration space of block $i$, and
write

$$
X=\bigoplus_{i\in I}^{\ell^2}X_i
$$

for the candidate-configuration space, as in
[block states and operators](./block-states-and-operators.md#block-states). Let $A$ be a finite
component index set. Each $e\in A$ has a finite support

$$
N(e)\subseteq I
$$

and a component potential $E_e:X\to\mathbb R$. For states $x$ and $z$, write

$$
x =_S z \quad\Longleftrightarrow\quad
\forall i\in S,\;x_i=z_i.
$$

The component $E_e$ is **local on its support** when

$$
x =_{N(e)} z \quad\Longrightarrow\quad E_e(x)=E_e(z).
$$

The potential assembled from the components indexed by $A$ is

$$
E_A(x)=\sum_{e\in A}E_e(x).
$$

The potential in an implicit-Euler problem has this form when $E=E_A$. Smoothness assumptions
needed for its gradient or Hessian are additional properties of the $E_e$; support locality alone
is sufficient for the results here.

# Exact local energy bookkeeping

For a block set $S\subseteq I$, define the components indexed by $A$ that meet $S$ by

$$
A_S=\{e\in A\mid N(e)\cap S\ne\varnothing\}.
$$

If two states agree outside $S$, every component outside $A_S$ has the same value at both
states. Therefore

$$
E_A(z)-E_A(x)
=\sum_{e\in A_S}\bigl(E_e(z)-E_e(x)\bigr)
\quad\text{whenever}\quad
\forall i\notin S,\;z_i=x_i.
$$

In particular, replacing only block $i$ by $b$ gives

$$
E_A(R_i(x,b))-E_A(x)
=\sum_{e\in A_{\{i\}}}
  \bigl(E_e(R_i(x,b))-E_e(x)\bigr).
$$

This is an equality of energy changes, not a decomposition into disjoint per-block objectives:
one component can occur in the formula for several block changes. It identifies exactly which
summands must be reevaluated for a proposed block replacement.

# Induced coloring graph

For distinct blocks, define

$$
i\sim_A j
\quad\Longleftrightarrow\quad
i\ne j\ \land\ \exists e\in A,\;i\in N(e)\land j\in N(e).
$$

The graph with vertex set $I$ and edges $\sim_A$ is symmetric and irreflexive. Its neighbor set at
$i$ is contained in the union of the supports of components in $A_{\{i\}}$, with $i$ removed. Thus
an edge records exactly that the two blocks co-occur in the supplied support of a component.
For a two-block component decomposition this is the usual graph of block coupling. In general,
each component support induces a clique in the graph.

# Phase-4 theorem statements

The finite-support component model has the following Phase-4 results.

1. Locality is closed under the finite sum, and components outside $A_S$ cancel from the
   energy change caused by a modification supported in $S$.
2. The relation $\sim_A$ is symmetric and irreflexive.
3. The graph edge condition is equivalent to two distinct blocks occurring in a common component
   support.
4. Enlarging $A$ can only add graph edges; restricting $A$ can only remove them.

These statements concern a potential decomposition. They do not define a VBD Newton update or
infer an update's read dependence merely from its write support. The production VBD theorem later
proves that its block-$i$ update depends only on the supports of components containing $i$, then
uses the absence of a common component to establish same-color commutation.

# Concrete support examples

For a four-block chain with supports

$$
\{0,1\},\quad\{1,2\},\quad\{2,3\},
$$

the induced graph is the path $0\text{—}1\text{—}2\text{—}3$. The parity map
$\chi(i)= i \bmod 2$ is a valid two-coloring.

For one three-block component with support $\{a,b,c\}$, every two distinct vertices are adjacent.
The map $\chi(a)=0$, $\chi(b)=1$, and $\chi(c)=2$ is a valid three-coloring. This example makes
the support condition explicit: a valid coloring assigns distinct colors to all blocks in one
component support.
