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

The crucial identity is about **change**, not decomposition: the global energy is not the sum of all vertex-local energies because multi-vertex force elements appear more than once, but changing only vertex `i` changes the global objective by exactly the change in the local energy for `i`. This directly motivates the generic [local objective theorem](/mathematics/local-decomposition.md).

Each vertex update is a low-dimensional local solve. The paper uses a Newton direction based on the local gradient and Hessian and performs line search for descent. It reports skipping an update when a suitable local Hessian/inverse is unavailable. These choices should instantiate, not define, the generic [block-coordinate layer](/mathematics/block-coordinate.md).

For parallelism, vertices are colored so no force element contains two vertices of one color. Color classes are processed sequentially and vertices within a class in parallel. Dynamic collision factors complicate this clean model, and the implementation uses buffering that can yield partially Jacobi-style behavior. The initial theorem target is the static independence result in [coloring](/mathematics/coloring.md).

# Claim discipline

The paper describes numerical convergence, stability, performance, and behavior under bounded iteration counts in its simulation setting. These statements must not be imported as formal theorems without matching definitions and assumptions. In particular, local/global descent alone does not prove convergence to a unique global minimizer or quantify finite-timestep error.

# Use in this project

- Source the VBD-specific local energy and algorithm structure.
- Validate the generic abstraction by recovering the paper's local/global change argument.
- Keep collision handling, acceleration, material models, 3D blocks, and GPU techniques outside the initial generic formalization.

# Local full text

Read the [agent-readable paper transcript](./vbd-paper-full.md) for repeated searches and detailed section-level work. Use the canonical PDF below for citation and visual verification.

# Citations

[1] [arXiv abstract and preprint](https://arxiv.org/abs/2403.06321)
[2] [Author-hosted paper PDF](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
