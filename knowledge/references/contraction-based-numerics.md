---
type: Research Reference
title: Contraction-Based Numerical Convergence Studies
description: Identifies numerical-analysis studies that use explicit contraction certificates for iterative maps and assesses their reuse for VBD.
tags: [contraction, fixed-point-iteration, numerical-analysis, comparison-matrix, validated-numerics]
timestamp: 2026-09-15T00:00:00Z
---

# Scope and result

Contraction mapping is used in numerical studies both to prove convergence of
the executed iteration and to validate the existence of a nearby solution for
a modified Newton-like map. The distinction is essential for VBD. The first
route directly matches the project target; the second provides a pattern for an
offline configuration certificate but does not prove convergence of the
production VBD sweep without an additional comparison theorem.

# Block-contraction convergence of executed iterations

## Distributed iterative waterfilling

Scutari, Palomar, and Barbarossa analyze simultaneous and sequential iterative
waterfilling algorithms for coupled communication links. They bound blockwise
differences by a nonnegative interference matrix, use a weighted block maximum
norm, and prove that a block-contraction condition gives a unique fixed point
and linear convergence of the sequential Gauss–Seidel scheme. The same paper
also treats simultaneous and smoothed variants and interprets the sufficient
condition in physical channel parameters.

This is the closest assessed proof architecture to the VBD route:
block-local updates, a nonnegative comparison matrix, a weighted or maximum
block norm, explicit serial/simultaneous execution semantics, and a
parameter-level sufficient condition. Its waterfilling map and equilibrium
problem are unrelated to implicit Euler, so it supplies a proof pattern rather
than a theorem that can be imported. In particular, VBD still requires bounds
for the derivative of the *actual* local Newton update, including variation of
the local inverse.

## Nonlinear power-flow iterations

The block-diagonal-dominance study of Ilić-Spong, Katz, Dai, and Zaborszky
derives sufficient convergence conditions for nonlinear underrelaxed block
Jacobi and block Gauss–Seidel maps and tests them on three-bus and thirty-bus
load-flow instances. It supplies a second application in which a coupling
certificate is evaluated against a concrete system, rather than treated as a
purely asymptotic statement. Its conditions are recorded in the
[VBD convergence landscape](./vbd-convergence-landscape.md#block-diagonal-dominance).

# A posteriori contraction validation

## Radii-polynomial method

Hungria, Lessard, and Mireles James develop radii polynomials for validated
numerics. Starting from a numerical approximate zero, the method constructs a
Newton-like operator, bounds its defect and derivative on a closed ball, and
uses the contraction mapping theorem to certify a unique nearby solution and
an explicit error radius. Their survey develops the method for nonlinear
operator equations and reports applications to ordinary, partial, and delay
differential equations; the certificate itself is a Banach-space fixed-point
construction rather than an ODE-specific argument.

The structure is relevant to an offline VBD analyzer: evaluated physical
parameters, a candidate state, interval or validated bounds, an invariant
ball, and a computable contraction factor can yield a machine-checkable local
certificate. The Newton-like validation map is generally different from the
VBD sweep. Its contraction therefore certifies a root near the candidate, not
the finite-sweep behavior of VBD, unless a separate bound connects the two
maps. This distinction preserves the roadmap’s priority on exact-execution
contraction.

# Project consequence

The direct model for the first VBD theorem is block contraction of the actual
sweep, following the comparison-matrix architecture exemplified by Scutari,
Palomar, and Barbarossa. Radii-polynomial validation is a complementary future
tool for establishing local solution existence or emitting offline
configuration certificates. Neither source removes the need to prove
fixed-point/root consistency, intermediate-state invariance, and VBD-specific
derivative bounds.

# Citations

[1] G. Scutari, D. P. Palomar, and S. Barbarossa, “Optimal Linear Precoding
Strategies for Wideband Non-Cooperative Systems Based on Game Theory—Part II:
Algorithms,” *IEEE Transactions on Signal Processing* 56(3), 1250–1267, 2008.
[DOI](https://doi.org/10.1109/TSP.2007.907808),
[preprint](https://arxiv.org/abs/0707.0871).

[2] M. Ilić-Spong, I. N. Katz, H. Dai, and J. Zaborszky, “Block Diagonal
Dominance for Systems of Nonlinear Equations with Application to Load Flow
Calculations in Power Systems,” *Mathematical Modelling* 5(5), 275–297, 1984.
[DOI](https://doi.org/10.1016/0270-0255(84)90006-X).

[3] A. Hungria, J.-P. Lessard, and J. D. Mireles James, “Rigorous Numerics for
Analytic Solutions of Differential Equations: the Radii Polynomial Approach,”
*Mathematics of Computation* 85(299), 1427–1459, 2016.
[DOI](https://doi.org/10.1090/mcom/3046).
