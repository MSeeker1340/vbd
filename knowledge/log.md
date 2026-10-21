# Knowledge Bundle Update Log

## 2026-10-21

* **Shared preview syntax**: Adopted `$$` display delimiters across the KB for both GitHub and VS Code's built-in preview, with the [rendering convention](./references/pdf-conversion.md#github-mathematical-rendering) covering both renderers. Retained the prior macro and superscript normalization.

* **GitHub mathematical rendering**: Standardized KB math notation across all scopes and the paper corpus, using the [conversion guide's rendering convention](./references/pdf-conversion.md#github-mathematical-rendering). Recorded scope-specific notation and transcript repairs in their local logs.

## 2026-09-04

* **Governance**: Made affirmative, standalone current-state prose the default for every non-log concept and reserved conversational rationale, corrections, rejected alternatives, and chronology for scoped logs.

## 2026-08-20

* **Correction**: Adopted hierarchy-scoped [`log.md`](https://okf.md/spec/#7-log-files-optional) histories and removed the custom standalone worklog concept scheme.
* **Refactor**: Consolidated project-management concepts under [project](./project/) and removed redundant snapshot, scope, and policy concepts.
* **Tooling**: Added a strict `okflint` manifest and repository-managed pre-commit hook.
* **Governance**: Reduced `AGENTS.md` to always-on project context, bundle-maintenance rules, core formalization invariants, and current repository state.
* **Initialization**: Converted the original project charter and initial research into an OKF bundle covering mathematics, Lean formalization, references, and project management.

This curated scope history complements Git history; it does not replace commit-level attribution or diffs.
