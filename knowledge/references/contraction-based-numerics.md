---
type: Research Reference
title: Contraction-Based Analysis of Numerical Iterative Methods
description: Surveys numerical methods whose convergence or error analysis uses explicit contraction certificates.
tags: [contraction, fixed-point-iteration, numerical-analysis, comparison-matrix, validated-numerics]
timestamp: 2026-09-15T00:00:00Z
---

# Scope and result

Contraction mapping is a general numerical-analysis mechanism for establishing
existence, uniqueness, convergence rates, and a priori or a posteriori error
bounds. The literature below separates three roles: contraction of the
executed iteration, contraction of a discretized successive-approximation
method, and validated contraction of an auxiliary map near a numerical
approximation. These roles have different conclusions even when each invokes
Banach’s theorem.

# Block-contraction convergence of executed iterations

## Distributed iterative waterfilling

Scutari, Palomar, and Barbarossa analyze simultaneous and sequential iterative
waterfilling algorithms for coupled communication links. They bound blockwise
differences by a nonnegative interference matrix, use a weighted block maximum
norm, and prove that a block-contraction condition gives a unique fixed point
and linear convergence of the sequential Gauss–Seidel scheme. The same paper
also treats simultaneous and smoothed variants and interprets the sufficient
condition in physical channel parameters.

The analysis exemplifies a general pattern: block-local maps, a nonnegative
comparison matrix, a weighted block maximum norm, explicit
serial/simultaneous execution semantics, and a parameter-level sufficient
condition. It establishes linear convergence of the iteration that is
executed, rather than only existence of a solution.

## Nonlinear power-flow iterations

The block-diagonal-dominance study of Ilić-Spong, Katz, Dai, and Zaborszky
derives sufficient convergence conditions for nonlinear underrelaxed block
Jacobi and block Gauss–Seidel maps and tests them on three-bus and thirty-bus
load-flow instances. It supplies a second application in which a coupling
certificate is evaluated against a concrete system, rather than treated as a
purely asymptotic statement. Its conditions are recorded in the
[VBD convergence landscape](./vbd-convergence-landscape.md#block-diagonal-dominance).

# Contraction in discretized successive approximation

## Integral and integrodifferential equations

Phillips analyzes iterative numerical solution of integral and
integrodifferential equations by contraction mapping, including the error
introduced when polynomial approximations replace exact iterates. Rocha,
Azevedo, Oliveira, and Correa give a later example in which a collocation discretization
of a nonlinear functional integral equation is solved by Picard iteration.
Their analysis separates discretization error from fixed-point iteration error,
uses Banach’s theorem for the latter, derives convergence and an a priori error
estimate, and compares the conclusions with numerical examples.

This class of studies illustrates that an iteration certificate and a
discretization certificate are distinct. A contraction factor controls the
iterations of the stated discrete map; transferring the conclusion to the
continuous problem additionally requires an approximation-error analysis.

# Validated contraction near a numerical approximation

## Radii-polynomial method

Hungria, Lessard, and Mireles James develop radii polynomials for validated
numerics. Starting from a numerical approximate zero, the method constructs a
Newton-like operator, bounds its defect and derivative on a closed ball, and
uses the contraction mapping theorem to certify a unique nearby solution and
an explicit error radius. Their survey develops the method for nonlinear
operator equations and reports applications to ordinary, partial, and delay
differential equations; the certificate itself is a Banach-space fixed-point
construction rather than an ODE-specific argument.

The structure supports computer-assisted numerical certification: evaluated
parameters, a candidate state, validated defect and derivative bounds, an
invariant ball, and a computable contraction factor yield a local certificate.
The auxiliary map is generally different from the iteration used to obtain the
candidate. Its contraction therefore certifies a nearby root and uniqueness in
the stated ball, not necessarily the rate of a separate production iteration.

# Relevance to VBD

The VBD theorem route belongs to the first category: contraction of the actual
executed sweep. The waterfilling analysis is consequently the closest generic
block-iteration pattern. Radii-polynomial validation remains complementary for
local solution certification, while integral-equation studies emphasize the
separation between iteration and discretization errors.

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

[3] G. M. Phillips, “Analysis of Numerical Iterative Methods for Solving
Integral and Integrodifferential Equations,” *The Computer Journal* 13(3),
297–300, 1970. [DOI](https://doi.org/10.1093/comjnl/13.3.297).

[4] A. M. Rocha, J. S. Azevedo, S. P. Oliveira, and M. R. Correa,
“Numerical Analysis of a Collocation Method for Functional Integral Equations,”
*Applied Numerical Mathematics* 134, 31–45, 2018.
[DOI](https://doi.org/10.1016/j.apnum.2018.07.002).

[5] A. Hungria, J.-P. Lessard, and J. D. Mireles James, “Rigorous Numerics for
Analytic Solutions of Differential Equations: the Radii Polynomial Approach,”
*Mathematics of Computation* 85(299), 1427–1459, 2016.
[DOI](https://doi.org/10.1090/mcom/3046).
