---
type: Mathematical Specification
title: Block Linear Operators and Sweep Bounds
description: Specifies heterogeneous block entries, operator reconstruction, splittings, and their role in sweep contraction.
tags: [block-operators, block-matrices, gauss-seidel, contraction]
timestamp: 2026-09-03T00:00:00Z
---

# Block-state algebra

For heterogeneous blocks `B : ι → Type*`, the total state is `BlockSum B`. Reading coordinate `i`
is ordinary dependent-function application `x i`. `BlockSum.inject i b` embeds a value into a
state that is zero away from `i`, while `BlockSum.replace x i b` writes `b` at `i` and preserves
every other coordinate.

Replacement is the state-modification primitive. The block value supplied to it is computed by the
concrete algorithm; the generic block foundation does not impose a universal update-rule type.

# Block entries

Let `A : BlockSum B →L[ℝ] BlockSum B` be a continuous linear operator. Its `(i,j)` block entry is
the continuous linear map

$$
A_{ij}=\pi_i\circ A\circ\iota_j : B_j\to B_i,
$$

where `πᵢ` is Mathlib's continuous coordinate projection and `ιⱼ` is the continuous version of
single-coordinate injection. For finite `ι`, the entries reconstruct the action of `A`:

$$
(Ax)_i=\sum_j A_{ij}x_j.
$$

Consequently, two operators are equal when all their block entries are equal. Addition, scalar
multiplication, identity, and composition reduce to the corresponding finite block-matrix formulas.

# Ordered and colored splittings

A finite order on blocks partitions entries into diagonal, earlier-block, and later-block parts.
Their sum reconstructs the original operator. This is the algebraic splitting needed to state a
Gauss-Seidel derivative, independently of how a nonlinear sweep computes its intermediate values.

A finite coloring similarly partitions entries into same-color and cross-color parts. This is only
an operator decomposition. Equality between concrete serial and buffered colored execution is a
property of the actual VBD maps and is proved in the production layer.

# Cross-block bounds

For a differentiable complete sweep `S`, bounds

$$
\|(DS(x))_{ij}v_j\|\le C_{ij}\|v_j\|
$$

define a nonnegative comparison operator. An induced bound `q < 1` in a stated block norm yields a
local contraction criterion. Ordered and colored splittings expose the coupling terms relevant to
serial and buffered parallel execution; sparsity or favorable diagonal blocks alone do not imply
contraction.

# Fixed-point iteration

The convergence interface is local contraction of the complete sweep `S` on a
forward-invariant neighborhood of a known fixed point `x*`:

$$
\|S(x)-S(y)\|\le q\|x-y\|,
\qquad q<1.
$$

Generic fixed-point theory then gives geometric finite-sweep bounds. Identifying `x*` with an
implicit-Euler solution and proving the concrete VBD sensitivity bounds belong to later bridge and
synthesis layers.

# Secondary energy route

Energy monotonicity, line search, convex minimization, and KL arguments are not foundations of the
production analysis. They may be added later for a named solver variant or theorem, but the
production full block-Newton step is not assumed to descend.
