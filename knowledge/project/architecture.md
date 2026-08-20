---
type: Architecture Decision
title: Mathematical and Module Architecture
description: Preserves the separation between generic optimization, implicit Euler, and VBD specialization.
tags: [architecture, dependencies, locality, curvature]
timestamp: 2026-08-20T00:00:00Z
---

# Dependency direction

```text
generic optimization theory
        ↓
implicit-Euler specialization
        ↓
VBD-specific theory
```

Generic modules may know about finite blocks, local factors, updates, descent, derivatives, curvature, and independence. They must not know about particles, timesteps, mass matrices, force elements, or spatial dimension.

The implicit-Euler layer instantiates a scalar objective with inertia plus potential energy. The VBD layer then chooses vertex blocks and connects the generic block theory to the mechanics-specific local energy described in the [VBD reference](/references/vbd-paper.md).

# Two independent structures

The project must keep these concepts distinct:

- **Locality/sparsity**: a factor depends only on selected blocks. This supports local objective evaluation, local derivatives, commuting updates, and parallel color classes.
- **Positive curvature**: a quadratic or Hessian lower bound. This supports descent directions, strong convexity, uniqueness, conditioning, and stronger convergence claims.

Neither implies the other. The generic [local decomposition](/mathematics/local-decomposition.md) must work without curvature assumptions, while [curvature strengthening](/mathematics/curvature.md) must not assume diagonal or local operators unless a specialization requires it.

# Representation boundary

The first representation decision should support finite, possibly heterogeneous blocks. Two viable Lean designs remain open:

1. A dependent product `∀ i, X i`, with block replacement by `Function.update`.
2. An abstract global Hilbert space with block injections and projections.

The dependent-product design is the leading candidate for the initial locality and descent lemmas because it makes “other blocks unchanged” definitional. Before fixing it, test whether the pinned Mathlib gives the required normed and inner-product instances without excessive transport overhead. See the [module map](/formalization/module-map.md).
