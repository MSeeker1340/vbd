---
type: Mathematical Specification
title: Block Decompositions and Update Operators
description: Specifies externally composed block updates, commutation, simultaneous batches, and operator-valued block-matrix representations.
tags: [block-updates, block-operators, block-matrices, coloring, contraction]
timestamp: 2026-09-07T00:00:00Z
---

# Data

Let `I` be a finite index set and let `(Xᵢ)ᵢ∈I` be a family of real normed vector spaces. The
blocks may be infinite-dimensional. The total space is the finite `ℓ²`-direct sum

$$
X=\bigoplus_{i\in I}^{\ell^2}X_i,
$$

equivalently the finite product `∏ᵢ Xᵢ` equipped with pointwise real vector-space operations and
the norm

$$
\lVert x\rVert_X^2=\sum_{i\in I}\lVert x_i\rVert_{X_i}^2.
$$

For each `i ∈ I`, let

$$
\pi_i:X\to X_i,
\qquad
\iota_i:X_i\to X
$$

be the canonical block projection and block inclusion. They are bounded linear maps. In block-matrix
notation they are the operator row and column

$$
\pi_i=
\begin{bmatrix}
0 & \cdots & \operatorname{id}_{X_i} & \cdots & 0
\end{bmatrix},
\qquad
\iota_i=
\begin{bmatrix}
0\\ \vdots\\ \operatorname{id}_{X_i}\\ \vdots\\ 0
\end{bmatrix}.
$$

Here and below, a displayed block matrix uses any fixed enumeration of the finite set `I`; the
maps and identities are independent of that enumeration. In particular,

$$
\pi_i\iota_i=\operatorname{id}_{X_i},
\qquad
\pi_i\iota_j=0\quad(i\ne j),
\qquad
\sum_{i\in I}\iota_i\pi_i=\operatorname{id}_X.
$$

A state and its finite block decomposition may therefore be written as

$$
x=
\begin{bmatrix}x_1\\ \vdots\\ x_n\end{bmatrix}
=\sum_{i\in I}\iota_i x_i,
\qquad x_i=\pi_i x.
$$

# Block replacement

For fixed `b ∈ Xᵢ`, replacing block `i` of `x` by `b` is the affine operation

$$
R_i(x,b)=
\begin{bmatrix}
x_1\\ \vdots\\ b\\ \vdots\\ x_n
\end{bmatrix}
=x+\iota_i(b-\pi_i x).
$$

As a map of the pair `(x,b)`, replacement is the operator row matrix

$$
R_i(x,b)=
\begin{bmatrix}
\operatorname{id}_X-\iota_i\pi_i & \iota_i
\end{bmatrix}
\begin{bmatrix}x\\b\end{bmatrix},
\qquad
R_i:X\oplus X_i\longrightarrow X.
$$

It has the block-component laws

$$
\pi_iR_i(x,b)=b,
\qquad
\pi_jR_i(x,b)=\pi_jx \quad (j\ne i).
$$

Replacing a block by its existing component changes nothing, a second replacement of the same
block overwrites the first, and replacements of distinct blocks commute.

# Update operators and write locality

An update operator is a state transformation

$$
U:X\to X.
$$

For a set of blocks `W ⊆ I`, the operator `U` is supported for writes on `W` when

$$
\pi_jU(x)=\pi_jx
\qquad (j\notin W).
$$

A block update is an update operator supported for writes on a singleton `{i}`. A general update
may write any finite set of blocks. This support condition constrains outputs only: an operator may
read blocks outside its write support.

The identity has empty write support. If `U` has write support `W` and `V` has write support `Z`,
then `V \circ U` has write support contained in `W ∪ Z`.

# Externally ordered composition

An external controller supplies an ordered finite sequence of update operators

$$
\mathcal E=(U_1,U_2,\ldots,U_m).
$$

Its execution operator and intermediate states are

$$
S_{\mathcal E}=U_m\circ\cdots\circ U_2\circ U_1,
\qquad
x_0=x,
\qquad
x_r=U_r(x_{r-1}).
$$

The position of each operator in the sequence determines its execution order. Concatenating two
execution sequences corresponds to composing their execution operators in the same order.

# Commutation and simultaneous updates

Two update operators commute when

$$
U\circ V=V\circ U.
$$

Commuting adjacent operators does not change an execution operator. Consequently, the composition
of a finite pairwise-commuting family is independent of its enumeration.

Let `(U_r)_{r\in K}` have pairwise-disjoint write supports `(W_r)_{r\in K}`. Their simultaneous
update operator `P_K` reads a single input state and merges the written blocks:

$$
\pi_jP_K(x)=
\begin{cases}
\pi_jU_r(x),&j\in W_r,\\
\pi_jx,&j\notin\displaystyle\bigcup_{r\in K}W_r.
\end{cases}
$$

If these update operators commute pairwise, `P_K` equals their composition in every enumeration.
Distinct write supports alone do not imply commutation because one operator may read a block written
by another.

A coloring groups block updates into color classes. Within a color class, pairwise commutation makes
the simultaneous color update equal to any serial ordering of the same operators. Color classes
themselves are executed in an externally supplied order. The
[coloring specification](/mathematics/coloring.md) describes how physical interaction structure
establishes or invalidates the required commutation property.

# Operator block matrices

An operator block matrix on `(Xᵢ)ᵢ∈I` has the form

$$
\mathbf A=
\begin{bmatrix}
A_{11} & \cdots & A_{1n}\\
\vdots & \ddots & \vdots\\
A_{n1} & \cdots & A_{nn}
\end{bmatrix},
\qquad A_{ij}:X_j\to X_i,
$$

where the entries are bounded linear maps. Its action is ordinary matrix–vector multiplication
with operator application in place of scalar multiplication:

$$
\mathbf A
\begin{bmatrix}x_1\\ \vdots\\ x_n\end{bmatrix}
=
\begin{bmatrix}
\sum_j A_{1j}x_j\\
\vdots\\
\sum_j A_{nj}x_j
\end{bmatrix}.
$$

Finiteness of `I` makes this a bounded linear operator on `X` without additional summability or
uniform-boundedness assumptions. Conversely, every bounded linear operator `A : X → X` has the
block-matrix representation

$$
[A]_{ij}=\pi_i\circ A\circ\iota_j.
$$

Realization and block-matrix representation are inverse: operator block matrices and bounded
linear operators on `X` carry the same information. The block-matrix view retains the decomposition
of `X` while remaining basis-free inside every `Xᵢ`.

# Block-matrix arithmetic

The zero and identity operators have the block matrices

$$
\mathbf 0=
\begin{bmatrix}0&\cdots&0\\ \vdots&\ddots&\vdots\\0&\cdots&0\end{bmatrix},
\qquad
\mathbf I=
\begin{bmatrix}
\operatorname{id}_{X_1}& &0\\
&\ddots&\\
0&&\operatorname{id}_{X_n}
\end{bmatrix}.
$$

Addition and scalar multiplication are entrywise:

$$
[A_{ij}]+[B_{ij}]=[A_{ij}+B_{ij}],
\qquad
a[A_{ij}]=[aA_{ij}].
$$

Multiplication uses composition of operator entries:

$$
[A_{ij}][B_{ij}]
=\left[\sum_{k\in I}A_{ik}\circ B_{kj}\right]_{ij}.
$$

Realization preserves zero, identity, addition, scalar multiplication, and multiplication. Thus
operator calculations may be performed directly in block-matrix notation and then interpreted as
calculations on the global space.

# Linearization of composed updates

For a differentiable externally ordered execution sequence, the chain rule gives

$$
DS_{\mathcal E}(x)
=DU_m(x_{m-1})\circ\cdots\circ DU_1(x_0).
$$

Its block-matrix representation is therefore

$$
[DS_{\mathcal E}(x)]
=[DU_m(x_{m-1})]\cdots[DU_1(x_0)].
$$

If `U` has write support `W`, every output row outside `W` in `[DU(x)]` is the corresponding row of
the identity matrix. The block matrices and execution order of concrete update operators determine
the associated Gauss–Seidel formula.

# Role in contraction analysis

Nonnegative block bounds for the derivative factors,

$$
\lVert(DU_r(x_{r-1}))_{ij}v_j\rVert_{X_i}
\le C^{(r)}_{ij}\lVert v_j\rVert_{X_j},
$$

compose in the same external order as the update operators. Bounds on the resulting comparison
matrix yield a bound for the complete execution operator in the selected block norm. Serial,
commuting-color, and buffered noncommuting batches use their actual composition or simultaneous
semantics. The quantitative hypotheses are specified in the
[curvature and coupling analysis](/mathematics/curvature.md) and proved in later phases.

# Assumption ledger

| Claim | Needed assumptions |
|---|---|
| Replacement component, overwrite, and commutation identities | decidable block equality |
| Affine replacement formula | real vector spaces |
| Write-support identity and composition laws | block projections |
| Finite execution and commutation laws | self-maps of the state space |
| Simultaneous merge | finite pairwise-disjoint write supports and decidable block membership |
| Equality of simultaneous and sequential updates | simultaneous-merge assumptions and pairwise commutation |
| Bounded block projections and inclusions | finite index set and real normed block spaces |
| Block-matrix realization and arithmetic | finite index set and real normed block spaces |
| Derivative block matrices | differentiability at the relevant intermediate states |
| Completeness for fixed-point results | each block is complete, stated in the contraction layer |
