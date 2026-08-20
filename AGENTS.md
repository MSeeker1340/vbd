# VBD Formalization Project

This repository formalizes the mathematical core of Vertex Block Descent (VBD) in Lean 4. It is a proof/formalization project, not primarily a verified simulation implementation.

## Project knowledge is in `knowledge/`

The project-local `knowledge/` directory is the detailed source of project context. It is an Open Knowledge Format (OKF) bundle designed for progressive disclosure.

- Before substantial research, planning, proof, review, or implementation, start at `knowledge/index.md` and read the indexes and concepts relevant to the task.
- Consult `knowledge/project/backlog.md` before selecting or extending roadmap work. Explicit user direction may reprioritize it.
- Treat this file as durable, always-on operating guidance; keep detailed mathematics, roadmap material, reference notes, module documentation, design decisions, and historical context in `knowledge/`.
- When this file and the bundle disagree, explicit user direction takes precedence, then this file, then the bundle. Correct stale bundle content as part of the work when appropriate.

## Maintain the knowledge bundle

Use the official `okf-open-knowledge-format` skill whenever creating, restructuring, validating, or materially updating the bundle.

- Keep project management material together under `knowledge/project/`: durable plans, the backlog, and decisions.
- Record meaningful knowledge changes as concise, newest-first entries in the `log.md` nearest to their scope; use `knowledge/log.md` only for bundle-wide changes. These curated update notes complement rather than replace Git history.
- Update relevant project, mathematics, formalization, or reference concepts when work changes the corresponding durable knowledge.
- Keep indexes useful for progressive disclosure, preserve cross-links, and validate OKF conformance after bundle edits.
- Do not pad the bundle with empty or speculative concepts. Create module documentation when the corresponding source module or concrete design exists.

## Core formalization invariants

- Use Mathlib as the primary Lean 4 foundation. Search Mathlib and relevant optimization formalizations before reproving standard results.
- Evaluate any new Lean 4 dependency explicitly before adding it.
- Preserve the dependency direction: generic optimization theory → implicit-Euler specialization → VBD specialization. Do not let mechanics- or implementation-specific assumptions leak upward.
- Keep locality/sparsity separate from positive-curvature assumptions.
- Use stationary points as the generic solution concept. Do not claim minimization, uniqueness, convergence, or rates without the additional hypotheses that justify them.
- Keep nonconvex, convex, and strongly convex results separate; state assumptions explicitly and as weakly as practical.
- Prefer small reusable definitions and lemmas over monolithic theorems.
- Separate mathematics from choices such as 3D particles, diagonal masses, coloring heuristics, collision handling, or GPU kernels unless a target theorem specifically requires them.

Detailed mathematical specifications and roadmap ordering live in `knowledge/mathematics/`, `knowledge/project/roadmap.md`, and `knowledge/formalization/module-map.md`.

## Current repository state

The repository is an initialized Lean library pinned to Lean and Mathlib `v4.34.0-rc1`; no VBD definitions or proofs have been added yet. The next planned implementation is the state-space and mass-operator skeleton in `Integrator/ImplicitEulerEnergy.lean`. The `knowledge/` bundle is validated by the repository-managed pre-commit hook.

## Development workflow

- Keep edits scoped and preserve unrelated user changes.
- Compile affected Lean modules and run the narrowest relevant checks before handing off work.
- When dependencies, toolchains, module layout, or public theorem interfaces change, update the corresponding knowledge concepts and tracking state.
- Do not build generic numerical-ODE or simulation infrastructure unless an accepted target theorem requires it.
- Use a concise one-line commit subject. If a commit has a body, it may contain only `Log: knowledge/<scope>/log.md` references and, for work substantially produced by an agent, an `Assisted-by: <agent name>` trailer.
