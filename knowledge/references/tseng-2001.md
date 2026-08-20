---
type: Research Reference
title: Tseng 2001 Block-Coordinate Convergence
description: Summarizes the exact-minimization BCD model, regularity bridge, and convergence assumptions relevant to later phases.
resource: https://doi.org/10.1023/A:1017501703105
tags: [block-coordinate-descent, convergence, stationary-point, nonsmooth]
timestamp: 2026-08-20T00:00:00Z
---

# Bibliography

Paul Tseng. “Convergence of a Block Coordinate Descent Method for Nondifferentiable Minimization.” *Journal of Optimization Theory and Applications* 109(3), 475–494, June 2001. DOI: 10.1023/A:1017501703105.

# Problem model

Tseng studies an extended-real objective

$$
f(x_1,\ldots,x_N)=f_0(x_1,\ldots,x_N)+\sum_{k=1}^N f_k(x_k),
$$

where the nonsmooth part is block-separable. At each iteration, one coordinate block is exactly minimized while all other blocks remain fixed. An essentially cyclic rule requires every block to be selected within a bounded window; the cyclic rule is a special case.

# Stationarity bridge

The paper distinguishes coordinatewise minimum from stationarity. A coordinatewise minimum becomes stationary under a regularity condition relating nonnegative block directional derivatives to nonnegative full directional derivatives. Gâteaux differentiability of the coupled part `f₀`, with domain conditions, supplies this regularity in the paper's model.

This distinction directly supports the project's policy not to identify blockwise optimality with full stationarity without a theorem.

# Main convergence shape

Under continuity on a compact initial level set, the generated sequence is defined and bounded and objective values decrease. Theorem 4.1 gives stationary cluster-point conclusions under alternative assumptions including pairwise block pseudoconvexity plus regularity, or uniqueness of certain block minima plus cyclic selection and a regularity conclusion. The paper explicitly notes that non-pseudoconvex coordinate descent can cycle and that nondifferentiable coordinate descent can stop at a nonstationary point without separable structure/regularity.

# Applicability limits

Tseng's local model is smooth-coupled plus block-separable nonsmooth terms, while this project's generic objective is a sum of overlapping local factors. The results are valuable for convergence architecture and hypotheses, but cannot be instantiated until the objectives, update rule, compactness/continuity assumptions, and stationarity notions are aligned.

# Local full text

Read the [agent-readable paper transcript](./tseng-2001-full.md) for repeated searches and detailed theorem work. Use the canonical PDF below for citation and verification against conversion errors.

# Citations

[1] [Author-hosted paper PDF](https://www.mit.edu/~dimitrib/PTseng/papers/archive/bcr_jota.pdf)
[2] [Author publication list](https://www.mit.edu/~dimitrib/PTseng/papers.html)
