---
type: Software Reference
title: Mathlib
description: Primary Lean 4 foundation for analysis, derivatives, linear algebra, convexity, matrices, and finite sums.
resource: https://github.com/leanprover-community/mathlib4
tags: [mathlib, lean4, foundation]
timestamp: 2026-08-20T00:00:00Z
---

# Role

Mathlib is the primary and currently sole mathematical dependency. The repository pins Mathlib tag `v4.34.0-rc1` at revision `de5ce8a9a66a4aa68a9bdbb35b63a06d34d9ca11`.

Relevant areas include Fréchet derivatives, gradients on inner-product spaces, continuous linear and bilinear maps, finite products and sums, matrices and positive definiteness, convexity, strong convexity, extrema, and graph theory.

# Usage policy

Search the pinned source before reproving standard results. Online docs are useful for navigation but may describe a different revision. Record confirmed APIs in the [local inventory](/formalization/mathlib-inventory.md), and prove small bridge lemmas in project modules when Mathlib's abstraction differs from the one selected here.

# Citations

[1] [Mathlib repository](https://github.com/leanprover-community/mathlib4)
[2] [Mathlib documentation](https://leanprover-community.github.io/mathlib4_docs/)
