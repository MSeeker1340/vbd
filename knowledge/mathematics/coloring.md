---
type: Mathematical Specification
title: Coloring and Parallel Sweep Structure
description: Specifies physical conflict colorings and their role in serial, buffered, and hybrid VBD sweeps.
tags: [graph-coloring, parallelism, locality, vbd]
timestamp: 2026-09-07T00:00:00Z
---

# Physical conflict relation

Finite-support interactions induce a symmetric conflict relation. Distinct blocks `i` and `j`
conflict exactly when some live interaction contains both. Equivalently, independence means

$$
\forall e,\quad \neg(i\in N(e)\land j\in N(e)).
$$

# Coloring validity

A proper coloring assigns different colors to conflicting blocks. The interaction layer proves
this combinatorial property for concrete finite-support systems. For the corresponding concrete
VBD update operators, physical independence establishes pairwise commutation within each color.
The generic block-update algebra then identifies the simultaneous color batch with every serial
ordering of those operators. The order between color batches is supplied externally.

# Hybrid colored updates

Dynamically introduced interactions can invalidate a precomputed coloring and the corresponding
commutation property. The buffered map is then Jacobi-like within the affected color and
Gauss-Seidel-like between colors. Its analysis uses its actual simultaneous-batch derivative or a
perturbation bound relative to the commuting static case.

# VBD connection

The VBD paper colors vertices so that each elastic force element intersects a color class in at
most one vertex. Its collision implementation may use partially Jacobi-style buffered updates when
dynamic collision interactions violate the precomputed material coloring. The roadmap proves the
static relationship for the concrete sweep definitions, then analyzes the hybrid map under
explicit coupling assumptions.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
