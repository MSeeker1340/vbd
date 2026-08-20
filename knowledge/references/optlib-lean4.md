---
type: Software Reference
title: optsuite/optlib (Lean 4)
description: Active Lean 4 optimization library with formalized BCD convergence discovered during initial research.
resource: https://github.com/optsuite/optlib
tags: [optlib, lean4, block-coordinate-descent, kl-property]
timestamp: 2026-08-20T00:00:00Z
---

# Discovery

Initial research found an active Lean 4 repository at `optsuite/optlib`. Its README describes formalizations spanning gradients, strong convexity, optimality conditions, first-order algorithms, block coordinate descent, and ADMM. Some earlier components have been merged into Mathlib.

`Optlib/Algorithm/BCD/Convergence.lean` states that it formalizes a sufficient-descent lemma, an upper bound on the subdifferential, properties of limit points, and convergence under the Kurdyka–Łojasiewicz property. The associated 2025 paper describes Lean 4 formalizations of BCD and ADMM convergence in nonsmooth/nonconvex settings.

# Relevance

This may reduce later work in `Optimization/Convergence.lean`, but its objective structure and convergence assumptions are not yet known to match VBD's overlapping local-factor model. It is therefore a candidate for focused evaluation, not a current project dependency.

# Evaluation questions

- Does its current toolchain align with Mathlib `v4.34.0-rc1`?
- Can its sufficient-descent abstraction accept the project's update sequence?
- Does its subdifferential/KL layer introduce more generality than the roadmap presently needs?
- Which results have already moved into Mathlib?
- Would importing the library be more stable than adapting a small theorem?

# Local full text

The [agent-readable formalization paper](./block-optimization-formalization-paper.md) preserves the source prose, Lean snippets, and TeX mathematics for repeated analysis.

# Citations

[1] [optsuite/optlib repository](https://github.com/optsuite/optlib)
[2] [BCD convergence module](https://github.com/optsuite/optlib/blob/main/Optlib/Algorithm/BCD/Convergence.lean)
[3] [Formalization of Algorithms for Optimization with Block Structures](https://arxiv.org/abs/2503.18806)
