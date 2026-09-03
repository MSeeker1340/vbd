# VBD Formalization Project

This repository formalizes the mathematical core of Vertex Block Descent (VBD) in Lean 4. It is a proof/formalization project, not primarily a verified simulation implementation.

## Project knowledge is in `knowledge/`

The project-local `knowledge/` directory is the detailed source of project context. It is an Open Knowledge Format (OKF) bundle designed for progressive disclosure.

- Before substantial research, planning, proof, review, or implementation, start at `knowledge/index.md` and read the indexes and concepts relevant to the task.
- Consult `knowledge/project/backlog.md` before selecting or extending roadmap work. Explicit user direction may reprioritize it.
- Treat this file as durable, always-on operating guidance; keep detailed mathematics, cross-module architecture, roadmap material, reference notes, project decisions, and historical context in `knowledge/`.
- When this file and the bundle disagree, explicit user direction takes precedence, then this file, then the bundle. Correct stale bundle content as part of the work when appropriate.

## Maintain the knowledge bundle

Use the official `okf-open-knowledge-format` skill whenever creating, restructuring, validating, or materially updating the bundle.

- Keep project management material together under `knowledge/project/`: durable plans, the backlog, and decisions.
- Record meaningful knowledge changes as concise, newest-first entries in the `log.md` nearest to their scope; use `knowledge/log.md` only for bundle-wide changes. These curated update notes complement rather than replace Git history.
- Update relevant project, mathematics, formalization, or reference concepts when work changes the corresponding durable knowledge.
- Keep indexes useful for progressive disclosure, preserve cross-links, and validate OKF conformance after bundle edits.
- Do not pad the bundle with empty, speculative, or source-mirroring concepts. Keep source-local APIs, assumptions, representation choices, and proof notes in Lean source documentation, placing them on the closest declaration and reserving module docstrings for module-wide context; reserve the bundle for reusable mathematics and cross-cutting project knowledge.

## Core formalization invariants

- Use Mathlib as the primary Lean 4 foundation. Search Mathlib and relevant optimization formalizations before reproving standard results.
- Evaluate any new Lean 4 dependency explicitly before adding it.
- Preserve three independent foundations—implicit-Euler mathematics, block-operator algebra, and contractive fixed-point iteration—and combine them only in the explicit bridge layers defined by the roadmap. Do not let mechanics- or implementation-specific assumptions leak into either generic foundation.
- Keep locality/sparsity separate from positive-curvature assumptions.
- Use stationary points as the generic solution concept. Do not claim minimization, uniqueness, convergence, or rates without the additional hypotheses that justify them.
- Keep nonconvex, convex, and strongly convex results separate; state assumptions explicitly and as weakly as practical.
- Prefer small reusable definitions and lemmas over monolithic theorems.
- Separate mathematics from choices such as 3D particles, diagonal masses, coloring heuristics, collision handling, or GPU kernels unless a target theorem specifically requires them.

Detailed mathematical specifications and roadmap ordering live in `knowledge/mathematics/`, `knowledge/project/roadmap.md`, and `knowledge/formalization/module-map.md`.

## Current repository state

The repository is a Lean library pinned to Lean and Mathlib `v4.34.0-rc1`. Phase 1 is implemented in `Integrator/ImplicitEulerEnergy.lean`: the basis-free energy, gradient, and Hessian identities compile without VBD-specific types. Phase 2 is active and now contains only objective-independent block sums and update algebra; its next implementation is `Block/Basic.lean` with heterogeneous `BlockSum B := PiLp 2 B` coordinate operations. Phase 3 will be a thin, block-independent layer over Mathlib's contractive fixed-point results. Later bridge phases combine these foundations before the production VBD synthesis derives serial and colored contraction bounds. The repository-managed pre-commit hook validates the `knowledge/` bundle and builds the complete Lean project.

## Development workflow

- Keep edits scoped and preserve unrelated user changes.
- Compile affected Lean modules and run the narrowest relevant checks before handing off work.
- Use `lake build` for the full project, `lake build <Module>` or `lake lean <file>` while iterating, and `lake lint` for the configured package linter.
- When dependencies, toolchains, module layout, or public theorem interfaces change, update the corresponding knowledge concepts and tracking state.
- Do not build generic numerical-ODE or simulation infrastructure unless an accepted target theorem requires it.
- Use a concise one-line commit subject. If a commit has a body, it may contain only `Log: knowledge/<scope>/log.md` references and, for work substantially produced by an agent, an `Assisted-by: <agent name>` trailer.
