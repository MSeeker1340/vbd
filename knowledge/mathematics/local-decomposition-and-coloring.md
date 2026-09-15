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
block updates. It records no positive-curvature, invertibility, differentiability, or contraction
premise. Those analytic properties remain separate from the support data.

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

with no occurrence of $x_k$ for $k\notin\{i,j\}$. Equivalently,

$$
x_i=z_i\quad(i\in S)
\quad\Longrightarrow\quad
E_S(x)=E_S(z).
$$

The implicit-Euler potential is directly assumed to be

$$
E(x)=\sum_{S\in A}E_S(x).
$$

Thus a component is one summand indexed by the set of blocks on which it may depend. Multiple
summands with the same support are combined into one component, so no separate component-label type
or support function is needed. Smoothness assumptions needed for the gradient or Hessian of $E$ are
additional properties of the $E_S$; support locality alone is sufficient for the results here.

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

# Coloring block updates

Let $K$ be a finite set indexing a partition $(C_c)_{c\in K}$ of $I$: every $C_c$ is nonempty, the
sets are pairwise disjoint, and their union is $I$. A label $c\in K$ is called a **color**, and
$C_c$ is its **color class**. This is the standard terminology from parallel algorithms: a color
has no structure beyond identifying one part of the partition.

An execution plan is an ordering $(c_1,\ldots,c_m)$ of the colors in $K$. It executes the color
classes $C_{c_1},\ldots,C_{c_m}$ one after another and attempts to execute the single-block updates
within each class simultaneously. Coloring therefore exposes parallel work without changing the
required order between dependent blocks.

A block update at $i$ can use every component $E_S$ for which $i\in S$. If two blocks $i$ and $j$
with the same color $c$ occur in one support $S$, their updates can both use $E_S$ and can therefore
depend on each other. The structural condition needed for a color class to represent independent
updates is consequently: every support $S\in A$ contains at most one block of $C_c$. The
commutation theorem for concrete VBD updates proves the remaining update-map fact later.

# Induced coloring graph

The induced graph converts the support condition above into the standard proper graph-coloring
test: it draws an edge for every pair of distinct blocks in a common support.

For distinct blocks, define

$$
i\sim_A j
\quad\Longleftrightarrow\quad
i\ne j\ \land\ \exists S\in A,\;i\in S\land j\in S.
$$

The graph with vertex set $I$ and edges $\sim_A$ is symmetric and irreflexive. A two-block support
$\{i,j\}$ contributes the one edge $i\text{—}j$. A three-block support $\{i,j,k\}$ contributes all
three pairwise edges, so it forms a triangle. In general, every support induces a clique. The graph
is used only to test colors; the original support family $A$ remains the data used for locality and
energy bookkeeping.

# Proper colorings

A coloring $(C_c)_{c\in K}$ is **proper for $A$** when no color class contains an edge:

$$
\forall c\in K,\;\forall i,j\in C_c,\quad i\sim_A j\quad\Longrightarrow\quad i=j.
$$

Equivalently,

$$
\forall S\in A,\;\forall c\in K,\qquad |S\cap C_c|\le 1.
$$

Thus a proper color class contains at most one block from each support.

For $M\subseteq A$, every coloring proper for $A$ is proper for $M$. Conversely, a coloring proper
for $M$ is proper for $A$ exactly when $|S\cap C_c|\le 1$ for every $S\in A\setminus M$ and
$c\in K$. This is the exact condition for extending properness from a smaller support family.

# Color batches and serial equivalence

Let $U_i:X\to X$ be a single-block update map with write support contained in $\{i\}$. The snapshot
batch $P_c$ for color $c$ evaluates all $U_i$ for $i\in C_c$ at the common input $x$ and writes
their selected block outputs simultaneously. For the externally ordered colors $(c_1,\ldots,c_m)$,
the colored sweep is

$$
T_{(c_1,\ldots,c_m)}=P_{c_m}\circ\cdots\circ P_{c_1}.
$$

This definition is valid whether or not the updates commute. It specifies the buffered semantics
of a parallel color class.

Properness is a property of the potential decomposition, whereas commutation is a property of
update maps. The production VBD theorem connects them by proving that the new value produced by
$U_i$ is unchanged whenever two inputs agree on $\bigcup\{S\in A\mid i\in S\}$. For distinct
$i,j$ in a proper color class, no support in $A$ contains both blocks; this fact and the
single-block write property give

$$
U_i\circ U_j=U_j\circ U_i.
$$

The simultaneous/sequential theorem from
[block states and operators](./block-states-and-operators.md#theorem-simultaneous-and-sequential-equivalence)
then identifies $P_c$ with every serial ordering of the $U_i$ in a proper color class. Neither
disjoint write supports nor a proper coloring alone proves this equality; the concrete
component-locality result for the update maps is required.

If a support added to a proper subfamily contains two blocks of the same color, its snapshot batch
remains well-defined but need not equal a serial composition. It requires a theorem for its actual
simultaneous-batch derivative or an explicitly accepted perturbation analysis; the current
exact-execution route does not supply that result.

# Phase-4 theorem statements and examples

The Phase-4 results are:

1. Components outside $A[J]$ cancel from the energy change caused by a modification supported in
   $J$.
2. The relation $\sim_A$ is symmetric and irreflexive.
3. A coloring is proper for the induced graph if and only if $|S\cap C_c|\le 1$ for every
   $S\in A$ and $c\in K$.
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
