---
type: Mathematical Specification
title: Finite-Support Potential Components
description: Defines support-indexed components of the implicit-Euler potential, their induced coloring graph, and exact local energy bookkeeping.
tags: [locality, sparsity, potential-decomposition, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Purpose and scope

This specification is the locality half of Phase 4. It assumes that the potential $E$ in the
[implicit-Euler problem](./implicit-euler.md) is a finite sum of block-local components and derives
the combinatorial information used by [proper colorings](./coloring.md). It records no
positive-curvature, invertibility, differentiability, or contraction premise. Those analytic
properties remain separate from the support data.

# Potential components

Let $I$ be a finite set of block indices, let $X_i$ be the configuration space of block $i$, and
write

$$
X=\bigoplus_{i\in I}^{\ell^2}X_i
$$

for the candidate-configuration space, as in
[block states and operators](./block-states-and-operators.md#block-states). Assume that

$$
A\subseteq\mathcal P(I)
$$

is a finite family of supports. For every $S\in A$, let $E_S:X\to\mathbb R$ be a component
potential. To say that $E_S$ is **local on $S$** means that its formula uses only the block values
$x_i$ with $i\in S$. For example, a binary component on $\{i,j\}$ has the form

$$
E_{\{i,j\}}(x)=\varphi(x_i,x_j),
$$

with no occurrence of any $x_k$ for $k\notin\{i,j\}$. Mathematically, this is expressed by

$$
x_i=z_i\quad(i\in S)
\quad\Longrightarrow\quad
E_S(x)=E_S(z).
$$

The implicit-Euler potential is directly assumed to be

$$
E(x)=\sum_{S\in A}E_S(x).
$$

Thus a potential component is simply one summand indexed by the set of blocks on which it may
depend. Multiple summands with the same support are combined into one component, so no separate
component-label type or support function is needed. Smoothness assumptions needed for the gradient
or Hessian of $E$ are additional properties of the $E_S$; support locality alone is sufficient for
the results here.

# Exact local energy bookkeeping

For a block set $J\subseteq I$, define

$$
A[J]=\{S\in A\mid S\cap J\ne\varnothing\}.
$$

If two states agree outside $J$, every component outside $A[J]$ has the same value at both states.
Therefore

$$
E(z)-E(x)
=\sum_{S\in A[J]}\bigl(E_S(z)-E_S(x)\bigr)
\quad\text{whenever}\quad
z_i=x_i\quad(i\notin J).
$$

In particular, replacing only block $i$ by $b$ gives

$$
E(R_i(x,b))-E(x)
=\sum_{S\in A[\{i\}]}
  \bigl(E_S(R_i(x,b))-E_S(x)\bigr).
$$

This is an equality of energy changes, not a decomposition into disjoint per-block objectives:
one component can occur in the formula for several block changes. It identifies exactly which
summands must be reevaluated for a proposed block replacement.

# Induced coloring graph

The support family $A$ says which blocks occur together in each component. A coloring needs to
assign different colors to any two blocks that occur together: equivalently, each support
$S\in A$ must contain at most one block of each color. The induced graph converts this condition
on sets into the usual vertex-coloring condition. It draws an edge for every pair of distinct
blocks belonging to one common support; a proper coloring of the graph is therefore exactly a
coloring satisfying the condition above.

For distinct blocks, define

$$
i\sim_A j
\quad\Longleftrightarrow\quad
i\ne j\ \land\ \exists S\in A,\;i\in S\land j\in S.
$$

The graph with vertex set $I$ and edges $\sim_A$ is symmetric and irreflexive. Its neighbor set at
$i$ is contained in the union of the supports in $A[\{i\}]$, with $i$ removed. A two-block support
$\{i,j\}$ contributes the one edge $i\text{—}j$. A three-block support $\{i,j,k\}$ contributes all
three pairwise edges, so it forms a triangle and forces three distinct colors on these blocks. In
general, every higher-arity support induces a clique in the graph. The graph is used only for
coloring; the original support family $A$ remains available for energy bookkeeping and locality.

# Phase-4 theorem statements

The finite-support component model has the following Phase-4 results.

1. Components outside $A[J]$ cancel from the energy change caused by a modification supported in
   $J$.
2. The relation $\sim_A$ is symmetric and irreflexive.
3. The graph edge condition is equivalent to two distinct blocks occurring in a common support in
   $A$.
4. Enlarging $A$ can only add graph edges; restricting $A$ can only remove them.

These statements concern the assumed decomposition of $E$. They do not define a VBD Newton update
or infer an update's read dependence merely from its write support. The production VBD theorem
later proves that its block-$i$ update depends only on the $E_S$ with $i\in S$, then uses the
absence of a common support to establish same-color commutation.

# Concrete support examples

For a four-block chain, take

$$
A=\bigl\{\{0,1\},\{1,2\},\{2,3\}\bigr\}.
$$

The induced graph is the path $0\text{—}1\text{—}2\text{—}3$, and
$\chi(i)=i\bmod 2$ is a valid two-coloring.

For $A=\{\{a,b,c\}\}$, every two distinct vertices are adjacent. The assignment
$\chi(a)=0$, $\chi(b)=1$, and $\chi(c)=2$ is a valid three-coloring.
