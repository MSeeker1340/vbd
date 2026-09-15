---
type: Mathematical Specification
title: Local Decomposition and Coloring
description: Defines support-indexed components of the implicit-Euler potential, exact local energy bookkeeping, proper coloring, and color-batch execution.
tags: [locality, sparsity, potential-decomposition, graph-coloring, parallelism, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Purpose and scope

This Phase-4 specification assumes that the potential $E$ in the
[implicit-Euler problem](./implicit-euler.md) is a finite sum of block-local components. It derives
both the exact energy bookkeeping for a block change and the coloring structure used to organize
VBD block updates. The corresponding curvature, differentiability, and contraction assumptions
belong to the later analytic bridge and VBD-synthesis results.

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

and its value is determined by $x_i$ and $x_j$. Equivalently,

$$
x_i=z_i\quad(i\in S)
\quad\Longrightarrow\quad
E_S(x)=E_S(z).
$$

The implicit-Euler potential is directly assumed to be

$$
E(x)=\sum_{S\in A}E_S(x).
$$

Thus a component is one summand indexed by the set of blocks on which it may depend. The
support-indexed family combines summands with the same support. Smoothness assumptions needed for
the gradient or Hessian of $E$ are additional properties of the $E_S$; support locality supplies
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

Components can occur in the energy changes of several blocks. The equality identifies exactly which
summands are reevaluated for a proposed block replacement.

# Coloring blocks

VBD obtains one update for each block and combines those updates into a sweep. A serial sweep
visits the block updates one at a time. A colored sweep groups them into batches: it evaluates the
updates in each batch together, then proceeds to the next batch. The support family $A$ determines
which groupings provide the structural premise for the concrete VBD commutation theorem.

Choose a number $m$ and nonempty block sets

$$
C_0,\ldots,C_{m-1}
$$

that are pairwise disjoint and whose union is $I$. The number $r$ is called **color $r$**, and
$C_r$ is its **color class**. The classes $C_0,\ldots,C_{m-1}$ are the consecutive batches of the
colored sweep.

# Induced coloring graph

The induced graph records which block pairs occur in a common support. It lets the support condition
for a proper coloring be checked by an ordinary graph condition.

For distinct blocks, define

$$
i\sim_A j
\quad\Longleftrightarrow\quad
i\ne j\ \land\ \exists S\in A,\;i\in S\land j\in S.
$$

The graph with vertex set $I$ and edges $\sim_A$ is symmetric and irreflexive. A two-block support
$\{i,j\}$ contributes the one edge $i\text{—}j$. A three-block support $\{i,j,k\}$ contributes all
three pairwise edges, so it forms a triangle. In general, every support induces a clique. The graph
tests color classes, while the support family $A$ supplies locality and energy bookkeeping.

# Proper colorings

A coloring $C_0,\ldots,C_{m-1}$ is **proper for $A$** when every support intersects every color
class in at most one block:

$$
\forall S\in A,\;\forall r\in\{0,\ldots,m-1\},\qquad |S\cap C_r|\le 1.
$$

Equivalently, two blocks of one color class that occur together in a support are the same block:

$$
\forall r\in\{0,\ldots,m-1\},\;\forall i,j\in C_r,\quad i\sim_A j\quad\Longrightarrow\quad i=j.
$$

Thus a proper color class contains at most one block from each support.

For $M\subseteq A$, the same coloring is proper for $M$. The condition
$|S\cap C_r|\le 1$ for $S\in A\setminus M$ and $r\in\{0,\ldots,m-1\}$ extends properness from
$M$ to $A$.

# Color batches and serial equivalence

Let every block $i$ have a single-block update $U_i:X\to X$ with write support contained in
$\{i\}$. An update at $i$ uses the components $E_S$ with $i\in S$. Properness assigns the blocks
of every support to distinct color classes. The concrete VBD locality theorem turns this support
separation into commutation of the updates within each color class.

The snapshot batch $P_r$ for color $r$ evaluates all $U_i$ for $i\in C_r$ at the common input $x$
and writes their selected block outputs simultaneously. The colored sweep executes the batches in
color-number order:

$$
T_{C_0,\ldots,C_{m-1}}=P_{m-1}\circ\cdots\circ P_0.
$$

This definition supplies the buffered semantics of a parallel color class. The VBD locality and
properness results identify it with every serial ordering within that class.

The production VBD locality theorem states that the new value produced by $U_i$ is determined by
the blocks in $\bigcup\{S\in A\mid i\in S\}$. For $i,j\in C_r$, properness and the single-block
write property give

$$
U_i\circ U_j=U_j\circ U_i.
$$

The simultaneous/sequential theorem from
[block states and operators](./block-states-and-operators.md#theorem-simultaneous-and-sequential-equivalence)
identifies $P_r$ with every serial ordering of the $U_i$ in a proper color class. Extending a
support family uses the properness condition above to determine its color batches.

# Phase-4 theorem statements and examples

The Phase-4 results are:

1. Components outside $A[J]$ cancel from the energy change caused by a modification supported in
   $J$.
2. The relation $\sim_A$ is symmetric and irreflexive.
3. The support condition $|S\cap C_r|\le 1$ for every $S\in A$ and
   $r\in\{0,\ldots,m-1\}$ is equivalent to the graph condition
   $i\sim_A j\Longrightarrow i=j$ for $i,j\in C_r$.
4. Properness is preserved under restriction to $M\subseteq A$, and the condition above
   characterizes when it extends from $M$ to $A$.
5. The two-coloring $C_0=\{0,2\}$, $C_1=\{1,3\}$ of the four-block chain is proper.
6. The three-coloring $C_0=\{a\}$, $C_1=\{b\}$, $C_2=\{c\}$ is proper for the one-support family
   $\{\{a,b,c\}\}$.

For the chain example, take

$$
A=\bigl\{\{0,1\},\{1,2\},\{2,3\}\bigr\}.
$$

The induced graph is the path $0\text{—}1\text{—}2\text{—}3$, and the two colors have classes
$C_0=\{0,2\}$ and $C_1=\{1,3\}$. For $A=\{\{a,b,c\}\}$, every two distinct vertices are adjacent,
so the three colors have singleton classes $C_0=\{a\}$, $C_1=\{b\}$, and $C_2=\{c\}$.
