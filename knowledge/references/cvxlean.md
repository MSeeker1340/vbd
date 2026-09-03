---
type: Software Reference
title: CvxLean
description: Lean 4 framework for formal convex optimization models, verified reductions, and DCP canonization.
resource: https://github.com/verified-optimization/CvxLean
tags: [cvxlean, lean4, convex-optimization, dcp]
timestamp: 2026-08-20T00:00:00Z
---

# Scope

CvxLean is a Lean 4 convex-optimization modeling framework based on Mathlib. It represents optimization problems as formal objects and supports verified equivalences, reductions, relaxations, and proof-producing disciplined-convex-programming canonization. Its solver workflow calls MOSEK after verified transformation to conic form.

# Relevance to VBD

CvxLean is useful for studying modern Lean 4 representations of optimization problems and verified
transformations. It is not an obvious foundation for the current VBD route, which needs
objective-independent block composition, contractive fixed-point estimates, and concrete
cross-block coupling rather than solver-backed DCP modeling.

Consult its definitions when choosing an optimization-problem vocabulary, but avoid importing its solver and modeling stack unless a specific theorem benefits.

# Citations

[1] [CvxLean repository and documentation](https://github.com/verified-optimization/CvxLean)
