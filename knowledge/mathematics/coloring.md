---
type: Mathematical Specification
title: Coloring and Parallel Sweep Structure
description: Defines proper coloring of live interaction hypergraphs and distinguishes exact static batches from buffered hybrid execution.
tags: [graph-coloring, parallelism, locality, vbd, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Coloring the live interaction structure

Use the live interaction hypergraph and conflict relation $\mathsf{\#}_A$ from
[finite-support physical interactions](./local-decomposition.md). A coloring is a map

$$
\chi : \iota\to\kappa,
$$

where $\kappa$ is any color type. It is **proper for the live set** $A$ when

$$
i\mathrel{\mathsf{\#}_A}j\quad\Longrightarrow\quad\chi(i)\ne\chi(j).
$$

Equivalently, every live interaction has at most one vertex of each color:

$$
\forall e\in A,\;\forall i,j\in N(e),\quad
i\ne j\quad\Longrightarrow\quad\chi(i)\ne\chi(j).
$$

This hypergraph form is the direct physical condition. It says that the restriction of $\chi$ to
$N(e)$ is injective for every live interaction; its equivalence with proper coloring of the
induced graph is a Phase-4 theorem. It applies unchanged to interactions of every finite arity.

For a color $c$, write $C_c = \{i \mid \chi(i)=c\}$. A proper color class contains no two vertices of any
one live interaction. An executable sweep supplies a finite ordered collection of finite color
classes covering the blocks it updates. The order of those classes is external algorithm data; a
coloring does not choose an execution order.

# From physical independence to a concrete batch

The Phase 2 batch operator is defined for arbitrary single-block update maps $U_i : X \to X$ with
disjoint write supports $\{i\}$. For a color class $C$, its snapshot batch is

$$
P_C(x)=\operatorname{merge}\bigl((U_i(x))_{i\in C};x\bigr),
$$

meaning that every $U_i$ is evaluated at the common input $x$ and only its block $i$ output is
written. For an externally ordered list of classes $(C_1,\ldots,C_m)$, the colored sweep is

$$
T_\chi=P_{C_m}\circ\cdots\circ P_{C_1}.
$$

This definition is valid whether or not the updates commute. It fixes the buffered semantics
needed when same-color computations run in parallel.

Physical properness alone is a statement about interaction supports, whereas commutation is a
statement about update maps. The production VBD layer connects them by proving two local facts
for its block update $U_i$:

1. $U_i$ writes only block $i$.
2. Its new value at $i$ is unchanged when blocks outside the supports of interactions incident to
   $i$ are changed.

For distinct $i,j$ in a proper color class, no live interaction is incident to both. These two
facts then give

$$
U_i\circ U_j=U_j\circ U_i.
$$

The simultaneous/sequential theorem from
[block states and operators](./block-states-and-operators.md#theorem-simultaneous-and-sequential-equivalence)
therefore identifies $P_C$ with every serial ordering of the $U_i$ in a proper static color class.
This is the exact-execution bridge used by the selected serial/proper-color route. Neither
disjoint write supports nor a proper coloring by itself proves this equality; the concrete
incident-read locality theorem is required.

# Static material colors and changing live sets

Let $M$ be the material interactions used to precompute a static coloring, and let $A$ be the
actual live set in a color pass. A material coloring is exact for that pass precisely when it is
proper for $A$, not merely for $M$.

Two monotonicity facts give the validity boundary:

- If $A \subseteq M$, then every coloring proper for $M$ remains proper for $A$. Deleting interactions,
  including after tearing or deactivation, cannot invalidate a static proper coloring.
- If $A = M \cup D$, then a coloring proper for $M$ remains proper for $A$ exactly when every added
  interaction $e \in D$ contains at most one vertex of each static color. Equivalently, no added
  interaction witnesses two distinct equal-colored vertices.

If an added collision or other dynamic interaction contains distinct $i$ and $j$ with
$\chi(i)=\chi(j)$, the static coloring is not proper for the live set. The same-color batch $P_C$ is
still a well-defined snapshot map, but it need not equal a serial Gauss–Seidel composition:
the two updates can read each other's old values. The resulting sweep is Jacobi-like inside the
affected color class and Gauss–Seidel-like between color classes. It requires a theorem for its
actual simultaneous-batch derivative or an explicitly accepted perturbation/hybrid analysis;
the current exact-execution route does not supply that result.

# Phase-4 theorem targets and examples

`Vbd/Integrator/LocalInteractions.lean` proves the following combinatorial results over the live
finite-support model.

1. A coloring is proper for the conflict graph if and only if it is injective on every live
   interaction support.
2. The parity coloring of the four-block pairwise chain is proper.
3. The three-color assignment of a triangular interaction is proper.
4. Properness is preserved when the live set is restricted, and the exact added-interaction
   condition above characterizes preservation when a material live set is extended.

The module does not implement collision detection, recoloring, GPU scheduling, or hybrid
contraction estimates. It supplies the exact hypothesis that later concrete update proofs and
execution theorems consume.

# VBD context

VBD colors vertices so that no force element contains multiple vertices of a color. For known
material elements this coloring can be precomputed. The VBD paper describes an auxiliary position
buffer for collision interactions that were absent from the material coloring; this realizes the
snapshot semantics above rather than restoring sequential equivalence. The mathematical result
here separates that executable meaning from the stronger proper-live-color premise required by the
current contraction theorem route.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
