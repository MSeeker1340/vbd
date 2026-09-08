---
type: Research Reference
title: Vertex Block Descent
description: Curated notes on Chen, Liu, Yang, and Yuksel's VBD method and its formalization-relevant claims.
resource: https://doi.org/10.1145/3658179
tags: [vbd, implicit-euler, gauss-seidel, graphics]
timestamp: 2026-08-20T00:00:00Z
---

# Bibliography

Anka He Chen, Ziheng Liu, Yin Yang, and Cem Yuksel. “Vertex Block Descent.” *ACM Transactions on Graphics* 43(4), Article 116, July 2024. DOI: 10.1145/3658179. The arXiv preprint is 2403.06321.

# Formalization-relevant content

The paper presents VBD as block-coordinate descent on the variational implicit-Euler objective using vertex-level Gauss–Seidel iterations. For vertex `i`, it defines a local variational energy consisting of the vertex inertia term and the potential energies of force elements incident to that vertex.

Changing only vertex `i` changes only its incident force elements. This finite-support structure
defines the physical read-dependencies and conflict graph used by the generic block and coloring
layers. The corresponding local/global energy-change identity is valid bookkeeping but is not the
main convergence route.

Each vertex update is a low-dimensional full Newton step based on the local gradient and Hessian.
The paper describes local line search as an option but reports that its evaluated production runs
do not use it. The implementation also skips an update when the Hessian is nearly singular. The
current roadmap therefore analyzes the actual unsafeguarded sweep as a fixed-point iteration rather
than assuming descent; see the generic [block-operator analysis](/mathematics/block-states-and-operators.md).

For parallelism, vertices are colored so no elastic force element contains two vertices of one
color. Color classes are processed sequentially and vertices within a class in parallel. Dynamic
collision interactions complicate this clean model, and buffering can yield partially Jacobi-style
behavior. The roadmap separates exact proper-color equivalence from contraction bounds for this
hybrid map; see [coloring](/mathematics/coloring.md).

# Claim discipline

The paper describes numerical convergence, stability, performance, and behavior under bounded iteration counts in its simulation setting. These statements must not be imported as formal theorems without matching definitions and assumptions. In particular, local/global descent alone does not prove convergence to a unique global minimizer or quantify finite-timestep error.

# Use in this project

- Source the VBD-specific local energy and algorithm structure.
- Derive the serial and colored production sweep maps and their cross-block coupling.
- Keep collision handling, acceleration, material models, 3D blocks, and GPU techniques outside the initial generic formalization.

# Local full text

Read the [agent-readable paper transcript](./vbd-paper-full.md) for repeated searches and detailed section-level work. Use the canonical PDF below for citation and visual verification.

# Citations

[1] [arXiv abstract and preprint](https://arxiv.org/abs/2403.06321)
[2] [Author-hosted paper PDF](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
