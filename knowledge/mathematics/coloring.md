---
type: Mathematical Specification
title: Coloring, Independence, and Commuting Updates
description: Defines when block updates commute and how graph coloring supports parallel color classes.
tags: [graph-coloring, parallelism, commutation, locality]
timestamp: 2026-08-20T00:00:00Z
---

# Independence relation

Two distinct blocks `i` and `j` are factor-independent when no objective factor depends on both:

$$
\forall e,\quad \neg(i\in N(e)\land j\in N(e)).
$$

This relation is symmetric. It induces a conflict graph whose vertices are blocks and whose edges join non-independent blocks.

# Theorem targets

For replacement updates with values chosen independently of mutation order, updates to distinct blocks commute definitionally or by `Function.update_comm`. For state-dependent local update rules, factor-independence must also show that updating `i` does not change the local data used to compute the update at `j`, and conversely. Only then can one prove equality of the two sequential orders.

A proper coloring assigns different colors to conflicting blocks. Within one color class, pairwise independence supports an order-independent fold and therefore a parallel interpretation. Different colors remain sequential, preserving a colored Gauss–Seidel sweep.

# Analytical boundary

Commutation is a locality theorem, not a curvature theorem. Monotone descent for a color-class update additionally requires that the simultaneous or order-independent combined update preserve the per-block descent facts. Dynamically introduced factors can invalidate a precomputed coloring; this implementation issue should not weaken the static generic theorem.

# VBD connection

The VBD paper colors vertices so that no force element contains two vertices of the same color. It reports fewer colors than element/constraint coloring in its examples. Its collision implementation may use partially Jacobi-style buffered updates when dynamic collision factors violate the precomputed material coloring. The initial formal target is the clean static theorem; dynamic recoloring and buffering are postponed.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
