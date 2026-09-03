# Curated References Update Log

## 2026-09-03

* **Correction**: Recorded that evaluated VBD runs use the unsafeguarded full block-Newton step; local line search is optional and was disabled in the reported experiments.
* **Relevance**: Moved Optlib's descent/KL development outside the main fixed-point contraction route while retaining the completed dependency assessment.
* **Foundation**: Added Mathlib's contractive-map and Banach fixed-point support to its current project role; CvxLean remains outside the block-composition route.
* **Research**: Completed the Optlib BCD assessment at commit `5da27c5`, documenting its toolchain, two-block PALM model, convergence theorem stack, licensing, and reference-only role in Phase 2.

## 2026-08-20

* **Resources**: Added agent-readable full-text Markdown for VBD, Tseng 2001, and the Lean 4 block-optimization formalization paper, with source checksums and conversion limitations.
* **Tooling**: Selected a source-first Pandoc pipeline for arXiv papers and pinned Docling for PDF-only papers; documented alternatives, reproducible commands, and admission checks.
* **Correction**: Removed the wrongly attributed Lean 3 Optlib reference and all conclusions derived from it.
* **Research**: Added the Lean 4 [`optsuite/optlib`](./optlib-lean4.md) reference and its block-coordinate convergence evaluation questions.
* **Research**: Added [CvxLean](./cvxlean.md) as relevant Lean 4 optimization-modeling context but not an initial foundation for local-update theory.
* **Research**: Added the [Vertex Block Descent](./vbd-paper.md) paper notes, emphasizing local/global objective-change equality and static coloring semantics.
* **Research**: Added [Tseng 2001](./tseng-2001.md), including its regularity bridge from coordinatewise minima to stationarity and the limits of direct reuse.
