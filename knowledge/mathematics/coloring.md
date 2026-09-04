---
type: Mathematical Specification
title: Coloring and Parallel Sweep Structure
description: Specifies physical conflict colorings and their role in serial, buffered, and hybrid VBD sweeps.
tags: [graph-coloring, parallelism, locality, vbd]
timestamp: 2026-09-04T00:00:00Z
---

# Physical conflict relation

Finite-support interactions induce a symmetric conflict relation. Distinct blocks `i` and `j` do
not conflict when no live interaction contains both:

$$
\forall e,\quad \neg(i\in N(e)\land j\in N(e)).
$$

# Coloring validity

A proper coloring assigns different colors to conflicting blocks. The interaction layer proves
this combinatorial property for concrete finite-support systems. The production VBD layer then
uses the actual block computation and buffering semantics to prove the corresponding relationship
between serial and colored sweeps.

# Hybrid colored updates

Dynamically introduced interactions can invalidate a precomputed coloring. The buffered map is then
Jacobi-like within the affected color and Gauss-Seidel-like between colors. It is not equated with
the serial sweep. Its contraction must be proved from its actual derivative block entries or from a
perturbation bound relative to the proper static case.

# VBD connection

The VBD paper colors vertices so that no elastic force element contains two vertices of the same
color. Its collision implementation may use partially Jacobi-style buffered updates when dynamic
collision interactions violate the precomputed material coloring. The roadmap proves the static
relationship for the concrete sweep definitions, then analyzes the hybrid map under explicit
coupling assumptions.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
