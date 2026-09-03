---
type: Mathematical Specification
title: Block Update Operators and Contraction
description: Specifies objective-independent block composition and the cross-block bounds used to prove sweep contraction.
tags: [block-operators, gauss-seidel, fixed-point, contraction]
timestamp: 2026-09-03T00:00:00Z
---

# Block update algebra

For heterogeneous blocks `B : ι → Type*`, the total state is `BlockSum B`. A one-block map `Uᵢ`
may change coordinate `i` and must leave every other coordinate unchanged. An ordered schedule
defines a serial sweep by composition. A finite set of distinct blocks also has a simultaneous
update semantics used for a parallel color class.

These definitions are independent of objectives, residuals, gradients, and descent. See the
[roadmap](/project/roadmap.md) for the Phase 2 boundary.

# Cross-block sensitivity

A one-block map is the identity on untouched coordinates, so it is not generally a strict
contraction of the total space. The useful local data instead bounds the changed output block in
terms of every input block:

$$
\|\pi_i(U_i(x)-U_i(y))\|
\le \sum_j C_{ij}\|\pi_j(x-y)\|.
$$

The nonnegative coefficients `Cᵢⱼ` form a comparison or coupling operator. Schedule composition
must propagate these bounds in the same order as the actual updates. A global contraction theorem
requires a stated product norm and an induced bound `q < 1`; it does not follow merely from a
collection of isolated per-block facts.

# Serial and colored sweeps

For serial execution, the composed comparison bound has Gauss-Seidel structure: later blocks see
the already updated values of earlier blocks. For colored execution, blocks within a color read the
same pre-color state and are Jacobi-like, while colors remain sequential.

When blocks in a color are independent, their cross-dependencies vanish, their updates commute,
and the simultaneous color map equals any sequential ordering of that class. When live interactions
couple same-color blocks, the actual color map remains valid but needs its own comparison bound or a
perturbation theorem.

# Fixed-point iteration

The main convergence interface is local contraction of the complete sweep `S` on a
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
