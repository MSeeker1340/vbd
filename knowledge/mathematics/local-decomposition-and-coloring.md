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

# Partitioning block updates

The relevant mathematical datum is a finite partition $\mathcal C$ of $I$: its members are
nonempty pairwise-disjoint subsets whose union is $I$. In parallel-algorithm terminology, the
members $C\in\mathcal C$ are called **colors**. The color names themselves carry no information;
only the partition matters. An execution plan is an ordering
$\mathbf C=(C_1,\ldots,C_m)$ of its parts. It executes these parts one after another and attempts
to execute the single-block updates within each part simultaneously. This exposes parallel work
without changing the required order between dependent blocks.

A block update at $i$ can use every component $E_S$ for which $i\in S$. If two blocks $i$ and $j$
in the same part occur in one support $S$, their updates can both use $E_S$ and can therefore
depend on each other. The structural condition needed for a part to represent independent updates
is consequently: every support $S\in A$ contains at most one block of that part. The commutation
theorem for concrete VBD updates proves the remaining update-map fact later.

# Induced overlap graph

The induced graph converts the support condition above into the standard graph-partition test: it
draws an edge for every pair of distinct blocks in a common support.

For distinct blocks, define

$$
i\sim_A j
\quad\Longleftrightarrow\quad
i\ne j\ \land\ \exists S\in A,\;i\in S\land j\in S.
$$

The graph with vertex set $I$ and edges $\sim_A$ is symmetric and irreflexive. A two-block support
$\{i,j\}$ contributes the one edge $i\text{—}j$. A three-block support $\{i,j,k\}$ contributes all
three pairwise edges, so it forms a triangle. In general, every support induces a clique. The graph
is used only to test the partition; the original support family $A$ remains the data used for locality and
energy bookkeeping.

# Proper partitions

A partition $\mathcal C$ is **proper for $A$** when no part contains an edge:

$$
\forall C\in\mathcal C,\;\forall i,j\in C,\quad i\sim_A j\quad\Longrightarrow\quad i=j.
$$

Equivalently,

$$
\forall S\in A,\;\forall C\in\mathcal C,\qquad |S\cap C|\le 1.
$$

Thus a proper part contains at most one block from each support. This is precisely a proper graph
coloring when the parts are conventionally called colors.

For $M\subseteq A$, every partition proper for $A$ is proper for $M$. Conversely, a partition
proper for $M$ is proper for $A$ exactly when $|S\cap C|\le 1$ for every $S\in A\setminus M$ and
$C\in\mathcal C$. This is the exact condition for extending properness from a smaller support
family.

# Partition batches and serial equivalence

Let $U_i:X\to X$ be a single-block update map with write support contained in $\{i\}$. For a part
$C$, its snapshot batch $P_C$ evaluates all $U_i$ for $i\in C$ at the common input $x$ and
writes their selected block outputs simultaneously. For an externally ordered list of classes
$\mathbf C=(C_1,\ldots,C_m)$, the partitioned sweep is

$$
T_{\mathbf C}=P_{C_m}\circ\cdots\circ P_{C_1}.
$$

This definition is valid whether or not the updates commute. It specifies the buffered semantics
of a parallel part.

Properness is a property of the potential decomposition, whereas commutation is a property of
update maps. The production VBD theorem connects them by proving that the new value produced by
$U_i$ is unchanged whenever two inputs agree on $\bigcup\{S\in A\mid i\in S\}$. For distinct
$i,j$ in a proper part, no support in $A$ contains both blocks; this fact and the
single-block write property give

$$
U_i\circ U_j=U_j\circ U_i.
$$

The simultaneous/sequential theorem from
[block states and operators](./block-states-and-operators.md#theorem-simultaneous-and-sequential-equivalence)
then identifies $P_C$ with every serial ordering of the $U_i$ in a proper part. Neither disjoint
write supports nor a proper partition alone proves this equality; the concrete
component-locality result for the update maps is required.

If a support added to a proper subfamily contains two blocks of the same part, its snapshot batch
remains well-defined but need not equal a serial composition. It requires a theorem for its actual
simultaneous-batch derivative or an explicitly accepted perturbation analysis; the current
exact-execution route does not supply that result.

# Phase-4 theorem statements and examples

The Phase-4 results are:

1. Components outside $A[J]$ cancel from the energy change caused by a modification supported in
   $J$.
2. The relation $\sim_A$ is symmetric and irreflexive.
3. A partition is proper for the induced graph if and only if $|S\cap C|\le 1$ for every
   $S\in A$ and $C\in\mathcal C$.
4. Properness is preserved under restriction to $M\subseteq A$, and the condition above
   characterizes when it extends from $M$ to $A$.
5. The partition $\{\{0,2\},\{1,3\}\}$ of the four-block chain is proper.
6. The singleton partition $\{\{a\},\{b\},\{c\}\}$ is proper for the one-support family
   $\{\{a,b,c\}\}$.

For the chain example, take

$$
A=\bigl\{\{0,1\},\{1,2\},\{2,3\}\bigr\}.
$$

The induced graph is the path $0\text{—}1\text{—}2\text{—}3$, and its two-part partition is
$\{\{0,2\},\{1,3\}\}$. For $A=\{\{a,b,c\}\}$, every two distinct vertices are adjacent, so the
singleton partition $\{\{a\},\{b\},\{c\}\}$ is proper.
