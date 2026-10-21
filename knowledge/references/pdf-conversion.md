---
type: Tooling Guide
title: Research Paper Conversion
description: Selects reproducible tools and quality checks for converting cited mathematical PDFs into agent-readable Markdown.
tags: [pdf, markdown, research, docling, pandoc, arxiv]
timestamp: 2026-10-21T02:29:26Z
---

# Decision

Use a source-first pipeline when an arXiv source representation exists:

1. obtain arXiv source-derived HTML or LaTeX;
2. convert it with pinned Pandoc;
3. strip presentation-only markup with the local [Pandoc cleanup filter](./pandoc-cleanup.lua).

This preserves TeX mathematics more reliably than reconstructing equations from PDF pixels.

For PDF-only papers, use pinned Docling locally. Its standard pipeline reconstructs reading order and document structure; enable formula enrichment when equation fidelity justifies the additional CPU cost. Keep image export in `placeholder` mode unless figures are essential to the intended reading task.

# Tool assessment

| Tool | Strengths | Tradeoffs | Project use |
|---|---|---|---|
| Docling | Local CPU execution, structured PDF parsing, formula and table models, direct Markdown export, MIT license | Formula enrichment is slow on CPU; optional table inference requires native graphics libraries in this container | Primary PDF-only converter |
| Pandoc with arXiv source or ar5iv | Exact source mathematics, mature Markdown writer, deterministic local transformation | Only applicable when source-derived input exists; complex publisher LaTeX may need ar5iv or cleanup filters | Preferred for arXiv papers |
| Marker | Strong layout, equations, tables, and scientific-paper benchmarks | Current local pipeline requires a heavier inference backend; model weights use an OpenRAIL-derived license | High-accuracy fallback on suitable hardware |
| MinerU | Scientific-document focus, LaTeX formula recognition, CPU pipeline, Markdown and JSON | Heavier deployment and a custom Apache-derived license | Alternative scientific-PDF fallback |
| PyMuPDF4LLM | Lightweight, local, layout-aware Markdown suitable for RAG | AGPL licensing and less explicit emphasis on mathematical equation reconstruction | Fast text-first fallback |

# Reproducible commands

Download and fingerprint every input before conversion:

```bash
curl -L --fail --silent --show-error SOURCE_PDF -o paper.pdf
sha256sum paper.pdf
```

Convert a born-digital PDF with the exact Docling version used for this bundle:

```bash
uvx --from docling==2.120.3 docling convert paper.pdf \
  --from pdf --to md --image-export-mode placeholder \
  --pipeline standard --no-ocr --device cpu --output converted
```

For a source-less mathematical PDF, add `--enrich-formula`. On this CPU-only checkout it is substantially slower but replaces detected equation regions with LaTeX. The container lacks `libGL.so.1`; add `--no-tables` here if Docling's optional table model fails to initialize.

For ar5iv HTML, use pinned Pandoc and the committed cleanup filter:

```bash
pandoc paper.html \
  --from html --to markdown+tex_math_dollars+pipe_tables \
  --wrap none --strip-comments \
  --lua-filter knowledge/references/pandoc-cleanup.lua \
  --output paper.md
```

For a self-contained arXiv LaTeX root, change `--from html` to `--from latex` and run Pandoc from the source directory so relative `input` files resolve.

# Admission checks

Before adding a generated transcript:

- verify the title, authors, abstract, section order, conclusion, and references;
- search for replacement characters and unresolved markers such as `formula-not-decoded`;
- inspect the definitions and theorem statements most relevant to the project;
- record the canonical source, PDF checksum, converter versions, route, and limitations at the top of the transcript;
- omit large figures by default and retain the canonical PDF link for visual verification;
- add OKF frontmatter and link the transcript from both its curated reference and this directory's index.

# GitHub mathematical rendering

Knowledge concepts and paper transcripts use protected inline math syntax
(`$` followed by a backtick, the expression, a backtick, and `$`) and `$$` on
separate lines for displayed equations. These forms support GitHub and VS Code's
built-in math preview. Display blocks have blank lines before and after them;
list continuations retain the indentation of their enclosing item.

Use `\lVert` and `\rVert` for norms in Markdown tables, and separate inline math
from adjacent words with spaces. Use upright identifiers such as `\mathrm{supp}`
and braced star superscripts such as `x^{\ast}`. Use `aligned` or `cases`
environments for alignment markers and row breaks.
Equation labels are Markdown anchors outside the math block, with ordinary Markdown
links for cross-references. Numbered source equations appear as labeled display blocks.
Lean and shell examples retain their source code.

Validate extracted expressions with MathJax and render the Markdown with VS Code's
Markdown-it/KaTeX plugin, checking that every display is recognized as math rather than
code. PDF-derived formulas retain their documented transcription limits; verify
mathematical corrections against the canonical paper.

# Current corpus

| Paper | Conversion route |
|---|---|
| [Vertex Block Descent](./vbd-paper-full.md) | ar5iv source-derived HTML → Pandoc 3.10.2 → cleanup filter |
| [Formalization of Algorithms for Optimization with Block Structures](./block-optimization-formalization-paper.md) | arXiv LaTeX source → Pandoc 3.10.2 → cleanup filter |
| [Tseng 2001](./tseng-2001-full.md) | PDF → Docling 2.120.3 standard pipeline with formula enrichment |

# Citations

[1] [Docling official repository](https://github.com/docling-project/docling)
[2] [Pandoc official repository](https://github.com/jgm/pandoc)
[3] [ar5iv](https://ar5iv.labs.arxiv.org/)
[4] [Marker official repository](https://github.com/datalab-to/marker)
[5] [MinerU official repository](https://github.com/opendatalab/MinerU)
[6] [PyMuPDF4LLM official repository](https://github.com/pymupdf/pymupdf4llm)
[7] [GitHub mathematical expression syntax](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/writing-mathematical-expressions)
[8] [VS Code math preview syntax](https://code.visualstudio.com/docs/languages/markdown#_math-formula-rendering)
