---
type: Architecture Decision
title: Mathematical and Module Architecture
description: Separates implicit-Euler physics, block-update and operator algebra, contraction theory, and their explicit bridge layers.
tags: [architecture, dependencies, locality, contraction]
timestamp: 2026-09-14T00:00:00Z
---

# Independent foundations

The project has three self-contained foundations:

1. **Implicit-Euler mathematics** defines the incremental objective, its gradient as the nonlinear
   residual, and its Hessian.
2. **Block-update algebra** defines heterogeneous block sums, write-local state transformations,
   composition, commutation, simultaneous batches, and block-matrix
   representations of continuous linear operators.
3. **Contractive fixed-point iteration** provides local fixed-point, finite-iterate, derivative,
   and perturbation results for arbitrary self-maps.

Pairwise bridge layers combine implicit Euler with local interactions, implicit Euler with generic
fixed-point results, and block operators with contraction bounds. Production VBD is the first
layer that may depend on all three foundations. The central [roadmap](/project/roadmap.md) gives the
complete dependency graph and current status.

# Production-facing solution concept

The generic target is a stationary point of the implicit-Euler incremental objective, equivalently
a root of its gradient. The main solver property is local contraction of the actual unsafeguarded
serial or colored sweep around such a root. Energy descent, minimization, convexity, and line search
form secondary routes for compatible theorem targets.

Convergence results state a contraction or another stability hypothesis that entails their
conclusion. Fixed-point characterization and scalar energy monotonicity serve as separate
properties.

# Generic theory and worked instances

The first axial-chain certificate is an application of the formal library. Generic block
composition, derivative comparison, fixed-point consistency and iteration results retain block
spaces, interaction support and physical bound data as parameters. Model-specific inverse,
coupling, invariant-region and predictor lemmas supply those parameters at the synthesis boundary.
The [adaptation analysis](/mathematics/applicability-study.md#reuse-beyond-the-chain) describes
how this interface extends to vector blocks and richer mechanics, including the boundaries
where contact or friction requires additional theory. Quantitative applicability is assessed
per model; the chain milestone leaves broad production applicability open.

# Locality and curvature

Keep these structures distinct:

- **Locality/sparsity** records which blocks a physical interaction contains. It supports conflict
  graphs, valid colors, and sparse block entries.
- **Curvature and coupling** control block invertibility and derivatives of the supplied update
  operators. Their bounds compose according to the actual external execution semantics.

These structures are independent. A contraction factor for serial or colored execution is derived
from positive diagonal control, off-diagonal coupling, and the externally supplied composition or
simultaneous-batch semantics in the chosen block norm.

# Interaction boundary

Physical interactions are represented by arbitrary finite block supports. These supports form a
hypergraph, covering pairwise forces as well as triangle, tetrahedron, bending, and other
multi-vertex elements. Theorems involving graph coloring derive a conflict graph from shared
hyperedges.

The production VBD layer proves how a static proper coloring relates its concrete buffered sweep to
serial execution. Dynamic collision interactions may create same-color coupling; the corresponding
complete sweep requires a separate hybrid or perturbation bound.

# Representation boundary

Reserve `X` for a total space. Let `B : ι → Type*` denote heterogeneous block spaces and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Use `BlockSum B` throughout the block layers. The type exists for an arbitrary block family.
Coordinate algebra states its required instances locally. Contraction modules may require finite
`ι`, complete normed block spaces, and a selected product norm.

The [AP-03 decision](./applicability-decision.md) selects a theorem-local unweighted maximum
norm for the first chain contraction certificate, with explicit transport to the existing finite
`ℓ²` representation. Weighted maximum and energy norms remain options for later assessments. Scalar-matrix and compactness results introduce finite-dimensional
block assumptions at their declaration sites.

# Notation boundary

Mathematical specifications present finite indexed families of block operators as operator-valued
block matrices. This notation leaves the interior of each block basis-free. Each implementing Lean
module selects its concrete source representation locally.

# Documentation boundary

Keep the current phase ordering and accepted theorem targets in the [roadmap](/project/roadmap.md).
Keep item status and acceptance criteria in the [backlog](/project/backlog.md). Place source-local
API, representation, and proof details beside the Lean declarations.
