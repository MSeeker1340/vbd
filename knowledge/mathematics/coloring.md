---
type: Mathematical Specification
title: Coloring and Parallel Sweep Structure
description: Defines proper coloring of support-indexed potential components and distinguishes exact color batches from buffered execution.
tags: [graph-coloring, parallelism, locality, potential-decomposition, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Coloring a potential decomposition

Use the support-indexed component family $A\subseteq\mathcal P(I)$ and graph relation $\sim_A$
from [finite-support potential components](./local-decomposition.md). A coloring is a map

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

A proper color class contains at most one block from each support in $A$. An executable sweep
supplies a finite ordered collection of finite color classes covering the blocks it updates; the
coloring itself does not choose that order.

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

# Restricting the support family

Let $M\subseteq A$. Every coloring proper for $A$ is proper for $M$. Conversely, a coloring proper
for $M$ is proper for $A$ exactly when every $S\in A\setminus M$ contains at most one block of each
color.

If some $S\in A\setminus M$ contains distinct $i$ and $j$ with $\chi(i)=\chi(j)$, a coloring proper
for $M$ is not proper for $A$. The same-color snapshot batch $P_C$ remains a well-defined map, but
need not equal a serial composition: two updates can use each other's old values. The resulting
sweep is Jacobi-like within the affected color class and Gauss–Seidel-like between color classes.
It requires a theorem for its actual simultaneous-batch derivative or an explicitly accepted
perturbation analysis; the current exact-execution route does not supply that result.

# Phase-4 theorem statements and examples

The Phase-4 component-and-coloring results are:

1. A coloring is proper for the induced graph if and only if it is injective on every $S\in A$.
2. The parity coloring of the four-block chain is proper.
3. The three-color assignment of the one-support family $\{\{a,b,c\}\}$ is proper.
4. Properness is preserved under restriction to $M\subseteq A$, and the condition above
   characterizes when it extends from $M$ to $A$.

The specification supplies the hypotheses used by later concrete update and execution theorems.
It contains no collision-detection, recoloring, scheduling, or hybrid-contraction theory.
