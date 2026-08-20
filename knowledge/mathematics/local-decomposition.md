---
type: Mathematical Specification
title: Local Objective Decomposition
description: Defines factor locality and the exact local/global change identity for one block update.
tags: [locality, sparsity, finite-sums, block-update]
timestamp: 2026-08-20T00:00:00Z
---

# Generic objective

Let `ι` index blocks and `ε` index objective factors. A state is `x = (xᵢ)ᵢ`. Each factor `Gₑ` has a support `N(e)`, the finite set of blocks on which it depends, and

$$
G(x)=\sum_{e\in\mathcal E}G_e(x).
$$

Locality should be expressed extensionally: if two states agree on `N(e)`, then `Gₑ` has the same value on both. This avoids committing each factor to a particular restricted-domain representation.

# Block update

For block `i` and replacement value `z`, write `x[i := z]` for the state equal to `x` except at `i`. Define the affected-factor set

$$
\mathcal E_i=\{e\in\mathcal E\mid i\in N(e)\}
$$

and the local objective

$$
L_i(x)=\sum_{e\in\mathcal E_i}G_e(x).
$$

The central algebraic theorem is

$$
G(x[i:=z])-G(x)
=L_i(x[i:=z])-L_i(x).
$$

Every unaffected factor cancels because the two states agree on its support. This statement requires only finite sums, decidable membership/equality as needed by the representation, and the locality witnesses. It requires no differentiability or curvature.

# Immediate consequences

- `L_i(x[i:=z]) ≤ L_i(x)` implies `G(x[i:=z]) ≤ G(x)`.
- Strict local decrease implies the same strict global decrease.
- Any block update preserving the local objective preserves the global objective.
- Derivative locality can later be proved by applying derivative congruence to the decomposition, with differentiability assumptions added only there.

# VBD connection

The VBD paper's per-vertex local energy includes the vertex inertia and each force element incident to that vertex. The sum of all per-vertex local energies is generally not the global energy because a multi-vertex force element is counted multiple times. The theorem needed by VBD is the change identity above, not equality between the global objective and the sum of all block-local objectives.

# Lean proof shape

Partition the finite factor set by whether `i ∈ N(e)`. Rewrite the global sum as affected plus unaffected sums, prove each unaffected summand unchanged under `Function.update`, then cancel. Establish the non-strict, strict, and equality corollaries from the single exact identity.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
