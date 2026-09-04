---
type: Mathematical Specification
title: Finite-Support Physical Interactions
description: Describes interaction hypergraphs and the locality data used to derive block dependencies and coloring.
tags: [locality, sparsity, interactions, hypergraph]
timestamp: 2026-09-04T00:00:00Z
---

# Interaction model

Let `B : ι → Type*` be a heterogeneous block family and let `ε` index physical interactions. Each
interaction `Pₑ` has a finite support `N(e) : Finset ι` and is extensionally local: two states that
agree on `N(e)` give the same interaction value. A finite active set defines

$$
P(x)=\sum_{e\in\mathcal E}P_e(x).
$$

Supports form a hypergraph. Pairwise forces have two-element supports; triangle, tetrahedron,
bending, and other multi-vertex elements use larger supports within the same abstraction.

# Conflict and coloring role

Two blocks conflict when some live interaction contains both. This derived conflict graph supplies
the proper-color condition and predicts sparsity of derivative block entries.

For static interactions, a proper coloring excludes a shared interaction within a color.
Dynamically introduced collision interactions can add hyperedges and invalidate that fact. Such
coupling must appear in the concrete buffered sweep or be removed by recoloring.

# Energy bookkeeping

For a replacement of block `i`, unaffected interactions cancel from the energy difference. The
resulting equality between global and incident-interaction energy changes is an elementary helper
lemma used for local energy bookkeeping.

# VBD connection

VBD's elastic force elements instantiate finite-support interactions. Their supports justify the
static vertex conflict graph. The production collision path may augment that graph; the final
colored-sweep analysis includes the complete live interaction set.

# Citations

[1] [Vertex Block Descent paper](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
