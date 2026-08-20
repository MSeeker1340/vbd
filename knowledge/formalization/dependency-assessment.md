---
type: Dependency Decision Record
title: Optimization Library Dependency Assessment
description: Distinguishes the pinned foundation from reference-only and candidate Lean optimization libraries.
tags: [dependencies, mathlib, optlib, cvxlean]
timestamp: 2026-08-20T00:00:00Z
---

# Current decision

Mathlib remains the only direct mathematical dependency. No optimization library is added during initial research.

# Assessment

| Source | Language/status | Use now | Reason |
|---|---|---|---|
| Mathlib | Lean 4, pinned dependency | import and prove against | Required foundation; APIs confirmed locally |
| `verified-optimization/CvxLean` | Lean 4 framework | consult selectively | Focuses on modeling, verified reductions, DCP canonization, and solver integration rather than VBD's generic convergence layer |
| `optsuite/optlib` | Active Lean 4 library | evaluate before convergence work | Newly discovered BCD/KL formalization may be reusable, but compatibility, assumptions, API quality, and overlap with pinned Mathlib must be checked |

# Gate for adding `optsuite/optlib`

Do not add it merely because a BCD module exists. Before a dependency proposal:

1. compare its Lean/Mathlib revisions with this project;
2. identify exact imported declarations needed by a roadmap theorem;
3. compare its BCD model (nonsmooth composite objective, subdifferentials, sufficient descent, KL property) with the project's factor-local exact-change model;
4. determine whether importing, porting a small result, or reproving a specialized lemma has the lowest maintenance cost;
5. record licensing and transitive-dependency impact.

# Citations

[1] [CvxLean](https://github.com/verified-optimization/CvxLean)
[2] [Lean 4 optsuite/optlib](https://github.com/optsuite/optlib)
[3] [Lean 4 BCD convergence source](https://github.com/optsuite/optlib/blob/main/Optlib/Algorithm/BCD/Convergence.lean)
