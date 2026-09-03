---
type: Software Reference
title: optsuite/optlib (Lean 4)
description: Lean 4 optimization library whose two-block PALM descent theory is outside the current fixed-point route.
resource: https://github.com/optsuite/optlib
tags: [optlib, lean4, block-coordinate-descent, kl-property]
timestamp: 2026-09-03T00:00:00Z
---

# Discovery

Initial research found an active Lean 4 repository at `optsuite/optlib`. Its README describes formalizations spanning gradients, strong convexity, optimality conditions, first-order algorithms, block coordinate descent, and ADMM. Some earlier components have been merged into Mathlib.

`Optlib/Algorithm/BCD/Convergence.lean` states that it formalizes a sufficient-descent lemma, an upper bound on the subdifferential, properties of limit points, and convergence under the Kurdyka–Łojasiewicz property. The associated 2025 paper describes Lean 4 formalizations of BCD and ADMM convergence in nonsmooth/nonconvex settings.

# Assessed interface

The focused assessment used commit `5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3` dated 2026-08-05.
The repository is Apache-2.0 licensed, has no release tags, and remains pinned to Lean and Mathlib
4.13.0 rather than this project's 4.34.0-rc1.

`Optlib/Algorithm/BCD/Scheme.lean` formalizes two-block PALM. It fixes a product of Hilbert spaces
`E × F`, a composite objective `f(x) + g(y) + H(x,y)`, and alternating proximal-gradient updates.
The main convergence file proves a quantitative descent inequality, square-summability and
vanishing of steps, a subdifferential relative-error bound, cluster-set facts, finite length under a
KL hypothesis, and convergence to a limiting-subdifferential critical point.

# Relevance and decision

The proof architecture remains relevant only to a possible secondary descent route: sufficient
decrease plus a lower objective bound yields asymptotic regularity, while relative-error and KL
hypotheses strengthen the conclusion.

The Lean interface is not part of the current roadmap. It fixes two blocks, has no abstract
sequential/simultaneous coloring algebra or cross-block sensitivity model, and requires descending
proximal-gradient updates rather than the production full block-Newton map. Its convergence
theorems are coupled to Optlib's proximal, subdifferential, and KL definitions.

The project therefore uses pinned Mathlib for the independent block and contraction foundations.
Direct Optlib reuse is reconsidered only if the roadmap activates a named descent or KL theorem and
a compatible release exposes the required abstract interface. The full decision is recorded in the
[dependency assessment](/formalization/dependency-assessment.md).

# Local full text

The [agent-readable formalization paper](./block-optimization-formalization-paper.md) preserves the source prose, Lean snippets, and TeX mathematics for repeated analysis.

# Citations

[1] [optsuite/optlib repository](https://github.com/optsuite/optlib)
[2] [BCD convergence module](https://github.com/optsuite/optlib/blob/main/Optlib/Algorithm/BCD/Convergence.lean)
[3] [Formalization of Algorithms for Optimization with Block Structures](https://arxiv.org/abs/2503.18806)
[4] [Assessed BCD scheme](https://github.com/optsuite/optlib/blob/5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3/Optlib/Algorithm/BCD/Scheme.lean)
[5] [Assessed toolchain](https://github.com/optsuite/optlib/blob/5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3/lean-toolchain)
