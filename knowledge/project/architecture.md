---
type: Architecture Decision
title: Mathematical and Module Architecture
description: Separates implicit-Euler physics, block-operator algebra, contraction theory, and their explicit bridge layers.
tags: [architecture, dependencies, locality, contraction]
timestamp: 2026-09-04T00:00:00Z
---

# Independent foundations

The project has three self-contained foundations:

1. **Implicit-Euler mathematics** defines the incremental objective, its gradient as the nonlinear
   residual, and its Hessian. It knows nothing about block schedules or convergence.
2. **Block-operator algebra** defines heterogeneous block sums, coordinate replacement, block
   entries of continuous linear operators, reconstruction, arithmetic, and ordered or colored
   operator splittings. It knows nothing about objectives, mechanics, solver execution, or
   convergence.
3. **Contractive fixed-point iteration** provides local fixed-point, finite-iterate, derivative,
   and perturbation results for arbitrary self-maps. It knows nothing about mechanics or blocks.

Pairwise bridge layers combine implicit Euler with local interactions, implicit Euler with generic
fixed-point results, and block operators with contraction bounds. Production VBD is the first
layer that may depend on all three foundations. The central [roadmap](/project/roadmap.md) gives the
complete dependency graph and current status.

# Production-facing solution concept

The generic target remains a stationary point of the implicit-Euler incremental objective,
equivalently a root of its gradient. The main solver property is local contraction of the actual
unsafeguarded serial or colored sweep around such a root. Energy descent, minimization, convexity,
and line search are secondary routes and are not prerequisites for the production theorem.

Do not claim convergence from a fixed-point characterization alone. Do not treat scalar energy
monotonicity as sufficient for convergence. Quantitative results must state a contraction or other
stability hypothesis strong enough for their conclusion.

# Locality and curvature

Keep these structures distinct:

- **Locality/sparsity** records which blocks a physical interaction contains. It supports conflict
  graphs, valid colors, and sparse block entries.
- **Curvature and coupling** control block invertibility and the derivative of a complete sweep.
  Together with its ordered or colored block splitting, they can establish contraction.

Neither implies the other. In particular, positive definiteness or a favorable condition number
does not by itself determine the contraction factor of a Gauss-Seidel or colored splitting; the
off-diagonal coupling and the chosen block norm must appear.

# Interaction boundary

Physical interactions are represented by arbitrary finite block supports. These supports form a
hypergraph, covering pairwise forces as well as triangle, tetrahedron, bending, and other
multi-vertex elements. A conflict graph is derived from shared hyperedges only when graph coloring
is needed.

The production VBD layer proves how a static proper coloring relates its concrete buffered sweep to
serial execution. Dynamic collision interactions may create same-color coupling; the corresponding
complete sweep requires a separate hybrid or perturbation bound.

# Representation boundary

Reserve `X` for a total space. Let `B : ι → Type*` denote heterogeneous block spaces and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Use `BlockSum B` throughout the block layers. Merely forming the type does not impose normed or
inner-product structure. Coordinate algebra adds only the instances it uses. Contraction modules
may require finite `ι`, complete normed block spaces, and a selected product norm.

The existing finite `ℓ²` norm is the first representation candidate, not a commitment that every
useful contraction estimate must use it. A weighted maximum or system-dependent energy norm may be
introduced locally if it is required to turn a coupling or spectral condition into a contraction.
Finite dimensionality of every block is added only by matrix-native or compactness results that
need it.

# Documentation boundary

Keep the current phase ordering and accepted theorem targets in the [roadmap](/project/roadmap.md).
Keep item status and acceptance criteria in the [backlog](/project/backlog.md). Source-local API,
representation, and proof details belong beside the Lean declarations rather than in additional
project-management concepts.
