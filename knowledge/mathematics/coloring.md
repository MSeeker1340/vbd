---
type: Mathematical Specification
title: Coloring, Independence, and Parallel Updates
description: Defines when state-dependent block updates commute and distinguishes proper parallel colors from hybrid same-color coupling.
tags: [graph-coloring, parallelism, commutation, locality]
timestamp: 2026-08-20T00:00:00Z
---

# Abstract independence relation

Phase 2 treats the read-dependencies of block maps abstractly. Two distinct blocks are independent
when neither update changes data read by the other. This relation induces a symmetric conflict
graph.

Physical finite-support interactions later discharge this abstraction. In that specialization,
two blocks `i` and `j` are independent when no live interaction contains both:

$$
\forall e,\quad \neg(i\in N(e)\land j\in N(e)).
$$

# Theorem targets

For replacement updates with values chosen independently of mutation order, updates to distinct blocks commute definitionally or by `Function.update_comm`. For state-dependent local update rules, factor-independence must also show that updating `i` does not change the local data used to compute the update at `j`, and conversely. Only then can one prove equality of the two sequential orders.

A proper coloring assigns different colors to conflicting blocks. Within one color class, pairwise
independence supports an order-independent fold and equality with a simultaneous parallel update.
Different colors remain sequential.

# Hybrid colored updates

Dynamically introduced interactions can invalidate a precomputed coloring. The simultaneous map is
then Jacobi-like within the affected color and Gauss-Seidel-like between colors. It is not equated
with a sequential ordering. Its contraction must be proved from its actual cross-block sensitivity
or from a perturbation bound relative to a proper coloring.

Coloring and commutation require no objective, monotonicity, or curvature assumptions.

# VBD connection

The VBD paper colors vertices so that no elastic force element contains two vertices of the same
color. Its collision implementation may use partially Jacobi-style buffered updates when dynamic
collision interactions violate the precomputed material coloring. The roadmap first proves exact
static equivalence, then analyzes the production hybrid map under explicit coupling assumptions.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
