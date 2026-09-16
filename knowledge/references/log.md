# Curated References Update Log

## 2026-09-16

* **Fixed-point consistency assessment**: Checked the paper's local Newton update, singular-Hessian bypass, and buffered color-pass semantics against the new unbiasedness interface. Exact regular serial and buffered sweeps have fixed-point-to-residual consistency; the production skip branch and changing/approximated execution data require explicit boundaries.

## 2026-09-15

* **Research**: Broadened the VBD review to identified formulation, convergence, and proof-assistant formalization work, independent of the project theorem route. Added higher-order-element/sub-stepping VBD alongside the original VBD, Augmented VBD, solver-level differentiation, and external nonlinear block-Gauss–Seidel sources; no identified VBD source supplies a proof-assistant formalization or theorem-level convergence analysis.
* **Research**: Reframed the contraction literature as a generic numerical-method survey. It now separates contraction of executed block iterations, contraction in discretized Picard methods for integral equations, and validated contraction of an auxiliary map; VBD’s exact-sweep route is recorded only as one application of the first category.

## 2026-09-11

* **Research**: Added [Adaptive VBD iterations and stopping criteria](./adaptive-vbd-iterations.md), comparing original VBD initialization/acceleration, AVBD penalties, related adaptive rigid-body substepping, WarpVBD early stopping, and Newton's iteration-budget API. Verified WarpVBD's coordinate-sum stop test against its source. The bounded search did not identify a Banach-certified adaptive VBD iteration paper or establish why production implementations choose fixed budgets; distinguished these limits from the positive implementation evidence.

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
