---
type: Architecture Decision
title: Mathematical and Module Architecture
description: Separates implicit-Euler physics, block-update and operator algebra, contraction theory, and their explicit bridge layers.
tags: [architecture, dependencies, locality, contraction]
timestamp: 2026-10-20T00:00:00Z
---

# Arithmetic and error scope

The project studies VBD in exact arithmetic, including finite-iteration state and residual errors. Floating-point rounding, errors from approximate local solves, and GPU implementation verification are outside its scope.

# Independent foundations

The project has three self-contained foundations:

1. **Implicit-Euler mathematics** defines the incremental objective, its gradient as the nonlinear
   residual, and its Hessian.
2. **Block-update algebra** defines heterogeneous block sums, write-local state transformations,
   composition, commutation, simultaneous batches, and block-matrix
   representations of continuous linear operators.
3. **Contractive fixed-point iteration** provides local fixed-point, finite-iterate, and derivative
   results for arbitrary self-maps.

Pairwise bridge layers combine implicit Euler with finite-support potential components, implicit Euler with generic
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
spaces, potential-component support and bound data as parameters. Model-specific inverse,
coupling, invariant-region and predictor lemmas supply those parameters at the synthesis boundary.
The [adaptation analysis](/mathematics/axial-spring-contraction.md#reuse-beyond-the-chain) describes
how this interface extends to vector blocks and richer mechanics, including the boundaries
where contact or friction requires additional theory. Quantitative applicability is assessed
per model; the chain milestone leaves broad production applicability open.

# Locality and curvature

Keep these structures distinct:

- **Locality/sparsity** records which blocks a potential component contains. It supports the
  component-overlap graph, valid colors, and sparse block entries.
- **Curvature and coupling** control block invertibility and derivatives of the supplied update
  operators. Their bounds compose according to the actual external execution semantics.

These structures are independent. A contraction factor for serial or colored execution is derived
from positive diagonal control, off-diagonal coupling, and the externally supplied composition or
simultaneous-batch semantics in the chosen block norm.

# Potential-component boundary

The potential is represented by arbitrary finite-support components, including pairwise and
higher-arity terms. Theorems involving graph coloring derive a component-overlap graph from shared
supports.

The production VBD layer proves how a proper coloring relates its concrete buffered sweep to serial
execution. Adding a component that contains two same-colored blocks creates same-color coupling;
the corresponding complete sweep requires a bound for its exact simultaneous update map.

# Representation boundary

Reserve `X` for a total space. Let `B : ι → Type*` denote heterogeneous block spaces and define

```lean
abbrev BlockSum {ι : Type*} (B : ι → Type*) := PiLp 2 B
```

Use `BlockSum B` throughout the block layers. The type exists for an arbitrary block family.
Coordinate algebra states its required instances locally. Contraction modules may require finite
`ι`, complete normed block spaces, and a selected product norm.

For the mathematical block decomposition, $X$ has the Hilbert inner product of the
implicit-Euler formulation and its induced physical $\ell^2$ norm. The modeler specifies a
calibrated norm on each block and hence induced product norms $\lVert\cdot\rVert_p$ on the same
block vectors. The [AP-03 decision](./applicability-decision.md) selects the maximum member of
that family for the first chain contraction certificate. The relation from a state-error
certificate to the physical residual norm is an explicitly stated regularity bound. Scalar-matrix
and compactness results introduce finite-dimensional block assumptions at their declaration sites.

# Notation boundary

Mathematical specifications present finite indexed families of block operators as operator-valued
block matrices. This notation leaves the interior of each block basis-free. Each implementing Lean
module selects its concrete source representation locally.

# Python tooling boundary

Python experiments and development scripts share the repository-root `pyproject.toml`,
`uv.lock`, and `.venv`. Modules run from the repository root, such as
`uv run --locked python -m experiments.applicability.study`. Experiment-specific sources and
outputs stay under `experiments/`; Python dependencies remain separate from the Lean foundation.
The [experiment README](../../experiments/applicability/README.md) documents its commands.

# Documentation boundary

Keep the current phase ordering and accepted theorem targets in the [roadmap](/project/roadmap.md).
Keep item status and acceptance criteria in the [backlog](/project/backlog.md). Place source-local
API, representation, and proof details beside the Lean declarations.
