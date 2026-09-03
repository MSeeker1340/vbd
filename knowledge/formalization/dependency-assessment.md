---
type: Dependency Decision Record
title: Optimization Library Dependency Assessment
description: Distinguishes the pinned foundation from reference-only and candidate Lean optimization libraries.
tags: [dependencies, mathlib, optlib, cvxlean]
timestamp: 2026-09-03T00:00:00Z
---

# Current decision

Mathlib remains the only direct mathematical dependency. The current roadmap analyzes VBD as a
contractive fixed-point iteration rather than building its main result on descent. Phase 2's block
algebra and Phase 3's thin fixed-point layer are implemented directly on Mathlib.
`optsuite/optlib` is not imported or copied; it remains a reference only if a future secondary
energy-descent or KL route is activated.

# Assessment

| Source | Language/status | Use now | Reason |
|---|---|---|---|
| Mathlib | Lean 4, pinned dependency | import and prove against | Required foundation; APIs confirmed locally |
| `verified-optimization/CvxLean` | Lean 4 framework | consult selectively | Focuses on modeling, verified reductions, DCP canonization, and solver integration rather than VBD's generic convergence layer |
| `optsuite/optlib` | Lean 4 library, Apache-2.0 | reference only | Its BCD layer is pinned to 4.13.0, specializes to two-block PALM, and follows a descent/KL route outside the current architecture |

# Optlib assessment

The assessment used Optlib commit `5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3` from 2026-08-05.
Its `lean-toolchain` and `lakefile.lean` pin Lean and Mathlib 4.13.0; this project pins 4.34.0-rc1.
Optlib has no release tags, so depending on `main` would not provide a stable version boundary.

Its BCD scheme has exactly two Hilbert-space blocks `E` and `F`. The objective is
`ψ(x,y) = f(x) + g(y) + H(x,y)`, and each alternating update is required to be a proximal-gradient
step with a fixed Lipschitz-derived stepsize. `ProblemData` also assumes lower semicontinuity and
lower bounds for the separable terms, continuous differentiability and global Lipschitz continuity
of the coupling gradient, completeness, and eventually properness/boundedness assumptions.

The main reusable-looking declarations are `PALM_Descent`, `Sufficient_Descent1`–`4`,
`Ψ_subdiff_bound`, `Limited_length`, and `Convergence_to_critpt`. They are not abstract lemmas over
an arbitrary iterate sequence: their statements depend on Optlib's `BCD`, proximal operator,
Fréchet and limiting subdifferential, and KL stack. Importing the convergence theorem would
therefore import a modeling choice outside the current block-operator and fixed-point foundations.

The mismatch is structural, not merely syntactic:

- VBD needs arbitrary finite, possibly heterogeneous blocks; Optlib fixes two blocks.
- VBD needs objective-independent block schedules, simultaneous color maps, read-dependencies, and
  cross-block sensitivity composition; Optlib has no corresponding abstraction.
- Production VBD uses unsafeguarded full block-Newton updates, while Optlib requires descending
  proximal-gradient steps.
- The current convergence target is local contraction and a finite-sweep error bound; Optlib's
  convergence result commits to a custom nonsmooth subdifferential/KL hierarchy.
- Porting across twenty-one Lean/Mathlib minor versions would be project-owned maintenance, while
  still leaving the missing locality layer to implement.

Optlib itself adds Mathlib as its sole unconditional project dependency; `doc-gen4` is conditional
on its documentation build. The Apache-2.0 license is compatible, but compatibility does not offset
the API and maintenance costs.

# Reassessment gate

Reconsider direct reuse only if a named secondary descent or KL theorem is activated. A proposal
must show all of the following:

1. Optlib supports this project's pinned Lean/Mathlib revision or has a maintained compatible tag;
2. the exact needed theorem is abstract over a sequence, sufficient decrease, and relative error,
   rather than its two-block PALM structure;
3. the theorem's stationarity notion has a proved bridge to this project's smooth block derivative;
4. reuse is smaller than a project-local theorem and does not pull an unused nonsmooth hierarchy
   into upstream locality modules.

Until then, borrow the mathematical decomposition of the convergence argument, not its source.

# Citations

[1] [CvxLean](https://github.com/verified-optimization/CvxLean)
[2] [Lean 4 optsuite/optlib](https://github.com/optsuite/optlib)
[3] [Lean 4 BCD convergence source](https://github.com/optsuite/optlib/blob/main/Optlib/Algorithm/BCD/Convergence.lean)
[4] [Optlib BCD scheme at the assessed commit](https://github.com/optsuite/optlib/blob/5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3/Optlib/Algorithm/BCD/Scheme.lean)
[5] [Optlib toolchain at the assessed commit](https://github.com/optsuite/optlib/blob/5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3/lean-toolchain)
