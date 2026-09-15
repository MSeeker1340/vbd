---
type: Dependency Decision Record
title: Optimization Library Dependency Assessment
description: Records the pinned foundation and the roles of candidate Lean optimization libraries.
tags: [dependencies, mathlib, optlib, cvxlean]
timestamp: 2026-09-15T00:00:00Z
---

# Current decision

Mathlib is the sole direct mathematical dependency. The current roadmap analyzes VBD as a
contractive fixed-point iteration. Phase 2's block algebra and Phase 3's thin fixed-point layer are
implemented directly on Mathlib. `optsuite/optlib` serves as a reference for a future secondary
energy-descent or KL route.

# Assessment

| Source | Language/status | Use now | Reason |
|---|---|---|---|
| Mathlib | Lean 4, pinned dependency | import and prove against | Required foundation; APIs confirmed locally |
| `verified-optimization/CvxLean` | Lean 4 framework | consult selectively | Supplies modeling, verified reductions, DCP canonization, and solver integration |
| `optsuite/optlib` | Lean 4 library, Apache-2.0 | reference | Supplies a two-block PALM development through a descent/KL route on Lean 4.13.0 |

# Optlib assessment

The assessed Optlib commit is `5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3` from 2026-08-05.
Its `lean-toolchain` and `lakefile.lean` pin Lean and Mathlib 4.13.0; this project pins 4.34.0-rc1.
Optlib distributes development from an untagged `main` branch.

Its BCD scheme has exactly two Hilbert-space blocks `E` and `F`. The objective is
`ψ(x,y) = f(x) + g(y) + H(x,y)`, and each alternating update is required to be a proximal-gradient
step with a fixed Lipschitz-derived stepsize. `ProblemData` also assumes lower semicontinuity and
lower bounds for the separable terms, continuous differentiability and global Lipschitz continuity
of the coupling gradient, completeness, and eventually properness/boundedness assumptions.

The main relevant declarations are `PALM_Descent`, `Sufficient_Descent1`–`4`, `Ψ_subdiff_bound`,
`Limited_length`, and `Convergence_to_critpt`. Their statements use Optlib's `BCD`, proximal
operator, Fréchet and limiting subdifferential, and KL stack.

The two libraries address different theorem interfaces:

- This project uses arbitrary finite, possibly heterogeneous blocks; Optlib specializes to two.
- This project uses heterogeneous block-operator entries, component-overlap colorings, and
  quantitative sweep-derivative bounds; Optlib supplies proximal-gradient BCD abstractions.
- Production VBD uses unsafeguarded full block-Newton updates; Optlib's scheme uses descending
  proximal-gradient steps.
- This project's main target is local contraction with a finite-sweep error bound; Optlib proves
  convergence through a nonsmooth subdifferential/KL hierarchy.
- Direct reuse would include a port across twenty-one Lean/Mathlib minor versions plus a
  project-local locality layer.

Optlib itself adds Mathlib as its sole unconditional project dependency; `doc-gen4` is conditional
on its documentation build. Its Apache-2.0 license is compatible with this project.

# Reassessment gate

Direct reuse becomes eligible when a named secondary descent or KL theorem is activated and a
proposal establishes all of the following:

1. Optlib supports this project's pinned Lean/Mathlib revision or has a maintained compatible tag;
2. the exact needed theorem exposes the sequence, sufficient-decrease, and relative-error
   interfaces required by the target;
3. the theorem's stationarity notion has a proved bridge to this project's smooth block derivative;
4. reuse has a smaller maintenance and dependency footprint than a project-local theorem.

The current project uses Optlib as a mathematical proof-pattern reference.

# Citations

[1] [CvxLean](https://github.com/verified-optimization/CvxLean)
[2] [Lean 4 optsuite/optlib](https://github.com/optsuite/optlib)
[3] [Lean 4 BCD convergence source](https://github.com/optsuite/optlib/blob/main/Optlib/Algorithm/BCD/Convergence.lean)
[4] [Optlib BCD scheme at the assessed commit](https://github.com/optsuite/optlib/blob/5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3/Optlib/Algorithm/BCD/Scheme.lean)
[5] [Optlib toolchain at the assessed commit](https://github.com/optsuite/optlib/blob/5da27c5f95aa6a8a45b8c14b968ade4c13ff18c3/lean-toolchain)
