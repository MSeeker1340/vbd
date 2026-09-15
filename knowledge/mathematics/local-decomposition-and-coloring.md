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

# Induced coloring graph

The support family $A$ says which blocks occur together in each component. To perform same-color
updates in parallel, a color class must contain at most one block from each $S\in A$. The induced
graph converts this condition on supports into ordinary vertex coloring: it draws an edge for every
pair of distinct blocks in a common support.

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

A coloring is a map

$$
\chi:I\to\kappa,
$$

where $\kappa$ is any color type. It is **proper for $A$** when

$$
i\sim_A j\quad\Longrightarrow\quad\chi(i)\ne\chi(j).
$$

Equivalently, the restriction of $\chi$ to every $S\in A$ is injective:

$$
\forall S\in A,\;\forall i,j\in S,\quad
i\ne j\quad\Longrightarrow\quad\chi(i)\ne\chi(j).
$$

Thus a proper color class contains at most one block from each support. An executable sweep
supplies a finite ordered collection of finite color classes covering the blocks it updates; the
coloring itself does not choose that order.

For $M\subseteq A$, every coloring proper for $A$ is proper for $M$. Conversely, a coloring proper
for $M$ is proper for $A$ exactly when every $S\in A\setminus M$ contains at most one block of each
color. This is the exact condition for extending a coloring from a smaller support family.

# Color batches and serial equivalence

Let $U_i:X\to X$ be a single-block update map with write support contained in $\{i\}$. For a color
class $C$, its snapshot batch $P_C$ evaluates all $U_i$ for $i\in C$ at the common input $x$ and
writes their selected block outputs simultaneously. For an externally ordered list of classes
$(C_1,\ldots,C_m)$, the colored sweep is

$$
T_\chi=P_{C_m}\circ\cdots\circ P_{C_1}.
$$

This definition is valid whether or not the updates commute. It specifies the buffered semantics
of a parallel color pass.

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
then identifies $P_C$ with every serial ordering of the $U_i$ in a proper color class. Neither
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
3. A coloring is proper for the induced graph if and only if it is injective on every $S\in A$.
4. Properness is preserved under restriction to $M\subseteq A$, and the condition above
   characterizes when it extends from $M$ to $A$.
5. The parity coloring of the four-block chain is proper.
6. The three-color assignment of the one-support family $\{\{a,b,c\}\}$ is proper.

For the chain example, take

$$
A=\bigl\{\{0,1\},\{1,2\},\{2,3\}\bigr\}.
$$

The induced graph is the path $0\text{—}1\text{—}2\text{—}3$, and
$\chi(i)=i\bmod 2$ is a valid two-coloring. For $A=\{\{a,b,c\}\}$, every two distinct vertices
are adjacent and $\chi(a)=0$, $\chi(b)=1$, $\chi(c)=2$ is a valid three-coloring.
