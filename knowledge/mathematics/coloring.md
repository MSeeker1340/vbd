---
type: Mathematical Specification
title: Coloring and Parallel Sweep Structure
description: Defines proper coloring of finite-support potential components and distinguishes exact color batches from buffered execution.
tags: [graph-coloring, parallelism, locality, potential-decomposition, phase-4]
timestamp: 2026-09-15T00:00:00Z
---

# Coloring a potential decomposition

Use the component index set $A$, supports $N(e)$, and graph relation $\sim_A$ from
[finite-support potential components](./local-decomposition.md). A coloring is a map

$$
\chi:I\to\kappa,
$$

where $\kappa$ is any color type. It is **proper for $A$** when

$$
i\sim_A j\quad\Longrightarrow\quad\chi(i)\ne\chi(j).
$$

Equivalently, the restriction of $\chi$ to each component support is injective:

$$
\forall e\in A,\;\forall i,j\in N(e),\quad
i\ne j\quad\Longrightarrow\quad\chi(i)\ne\chi(j).
$$

The support form is the direct condition. A proper color class contains at most one block from
each component support. An executable sweep supplies a finite ordered collection of finite
color classes covering the blocks it updates; the coloring itself does not choose that order.

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
$U_i$ is unchanged when blocks outside the supports of components containing $i$ are changed. For
distinct $i,j$ in a proper color class, no component contains both blocks;
this fact and the single-block write property give

$$
U_i\circ U_j=U_j\circ U_i.
$$

The simultaneous/sequential theorem from
[block states and operators](./block-states-and-operators.md#theorem-simultaneous-and-sequential-equivalence)
then identifies $P_C$ with every serial ordering of the $U_i$ in a proper color class. Neither
disjoint write supports nor a proper coloring alone proves this equality; the concrete
component-locality result for the update maps is required.

# Changing the component index set

Let $M$ be the component index set for which a coloring was established, and let $A$ be the
component index set of a particular color pass. The coloring is proper for that pass precisely when it is
proper for $A$, not merely for $M$.

- If $A\subseteq M$, then every coloring proper for $M$ remains proper for $A$.
- If $A=M\cup D$, then a coloring proper for $M$ remains proper for $A$ exactly when every
  $e\in D$ contains at most one block of each color.

If an added component contains distinct $i$ and $j$ with $\chi(i)=\chi(j)$, the coloring is not
proper for the new component index set. The same-color snapshot batch $P_C$ remains a well-defined map, but
need not equal a serial composition: two updates can use each other's old values. The resulting
sweep is Jacobi-like within the affected color class and Gauss–Seidel-like between color classes.
It requires a theorem for its actual simultaneous-batch derivative or an explicitly accepted
perturbation analysis; the current exact-execution route does not supply that result.

# Phase-4 theorem statements and examples

The Phase-4 component-and-coloring results are:

1. A coloring is proper for the induced graph if and only if it is injective on every
   component support.
2. The parity coloring of the four-block chain is proper.
3. The three-color assignment of a three-block component is proper.
4. Properness is preserved when the component index set is restricted, and the added-component
   condition above characterizes preservation when it is extended.

The specification supplies the hypotheses used by later concrete update and execution theorems.
It contains no collision-detection, recoloring, scheduling, or hybrid-contraction theory.
