# Project Management Update Log

## 2026-08-20

* **Tooling**: Added a complete incremental `lake build` to the repository pre-commit hook, configured Mathlib's Batteries lint driver for `Vbd`, and documented pinned-toolchain, Mathlib-cache, narrow-build, single-file, and scratch commands.
* **Correction**: Replaced standalone dated worklogs with this reserved, scope-local update log and changed commit-body references from `Worklog:` to `Log:`.
* **Refactor**: Consolidated architecture, roadmap, and backlog under `knowledge/project/`; moved concise current repository state into `AGENTS.md` and removed overlapping snapshot, scope, and policy concepts.
* **Tooling**: Installed `okflint` 0.3.1 with `uv`, added `knowledge/okf-base.yaml`, activated the version-controlled `.githooks/pre-commit` hook, and documented clone setup in the README.
* **Governance**: Made `knowledge/index.md` the required progressive-disclosure entry point and retained only durable always-on instructions in `AGENTS.md`, following [OpenAI's AGENTS.md guidance](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
* **Planning**: Established the phased roadmap, ordered theorem backlog, explicit dependencies, acceptance criteria, open representation decisions, and deferred work.

Git remains the authoritative commit history; this file summarizes meaningful changes to project-management knowledge.
