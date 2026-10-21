---
type: Paper Transcript
title: Tseng 2001 Block-Coordinate Convergence — Agent-readable Full Text
description: Formula-enriched Markdown rendering of Tseng's block-coordinate descent convergence paper for repeated local use.
resource: https://www.mit.edu/~dimitrib/PTseng/papers/archive/bcr_jota.pdf
tags:
  - block-coordinate-descent
  - convergence
  - optimization
  - paper-transcript
  - tseng
timestamp: 2026-10-21T02:02:26Z
---

# Conversion provenance

- Mathematics uses protected GitHub inline delimiters and fenced `math` displays; equation labels use Markdown anchors.
- Canonical source: [author-hosted PDF](https://www.mit.edu/~dimitrib/PTseng/papers/archive/bcr_jota.pdf)
- Source SHA-256: `b6b060395bc083d5b687916c6782c0cdc2b7b8bbf9fe7bd9392a0b5ce1d34649`
- Rendering: Docling 2.120.3, standard layout pipeline with OCR and table recognition disabled and formula enrichment enabled, running locally on CPU.
- Quality note: equations were reconstructed from page images and may contain transcription errors. Use the canonical PDF to verify quotations, theorem statements, and notation.

# Converted paper

## Convergence of a Block Coordinate Descent Method for Nondifferentiable Minimization 1

P. TSENG 2

Communicated by O. L. Mangasarian

Abstract. We study the convergence properties of a (block) coordinate descent method applied to minimize a nondifferentiable (nonconvex) function f ( x 1 , . . . , xN ) with certain separability and regularity properties. Assuming that f is continuous on a compact level set, the subsequence convergence of the iterates to a stationary point is shown when either f is pseudoconvex in every pair of coordinate blocks from among N A 1 coordinate blocks or f has at most one minimum in each of N A 2 coordinate blocks. If f is quasiconvex and hemivariate in every coordinate block, then the assumptions of continuity of f and compactness of the level set may be relaxed further. These results are applied to derive new (and old) convergence results for the proximal minimization algorithm, an algorithm of Arimoto and Blahut, and an algorithm of Han. They are applied also to a problem of blind source separation.

Key Words. Block coordinate descent, nondifferentiable minimization, stationary point, Gauss-Seidel method, convergence, quasiconvex functions, pseudoconvex functions.

## 1. Introduction

A popular method for minimizing a real-valued continuously differentiable function f of n real variables, subject to bound constraints, is the (block) coordinate descent method. In this method, the coordinates are partitioned into N blocks and, at each iteration, f is minimized with respect to one of the coordinate blocks while the other coordinates are held fixed. This method, which is related closely to the Gauss-Seidel and SOR methods for equation solving (Ref. 1), was studied early by Hildreth (Ref. 2) and Warga (Ref. 3), and is described in various books on optimization (Refs. 1 and 4-

1 This work was partially supported by the National Science Foundation Grant CCR-9731273.

2 Professor, Department of Mathematics, University of Washington, Seattle, Washington.

10). Its applications include channel capacity computation (Refs. 11-12), image reconstruction (Ref. 7), dynamic programming (Refs. 13-15), and flow routing (Ref. 16). It may be applied also to the dual of a linearly constrained, strictly convex program to obtain various decomposition methods (see Refs. 6-7, 17-22, and references therein) and parallel SOR methods (Ref. 23).

Convergence of the (block) coordinate descent method requires typically that f be strictly convex (or quasiconvex or hemivariate) differentiable and, taking into account the bound constraints, has bounded level sets (e.g., Refs. 3-4 and 24-25). Zadeh (Ref. 26; also see Ref. 27) relaxed the strict convexity assumption to pseudoconvexity, which allows f to have a nonunique minimum along coordinate directions. For certain classes of convex functions, the level sets need not be bounded (see Refs. 2, 6-7, 17, 19-22, and references therein). If f is not (pseudo)convex, then an example of Powell (Ref. 28) shows that the method may cycle without approaching any stationary point of f . Nonetheless, convergence can be shown for special cases of non(pseudo)convex f , as when f is quadratic (Ref. 29), or f is strictly pseudoconvex in each of N A 2 coordinate blocks (Ref. 27), or f has unique minimum in each coordinate block (Ref. 8, p. 159). If f is not differentiable, the coordinate descent method may get stuck at a nonstationary point even when f is convex (e.g., Ref. 4, p. 94). For this reason, it is perceived generally that the method is unsuitable when f is nondifferentiable. However, an exception occurs when the nondifferentiable part of f is separable. Such a structure for f was considered first by Auslender (Ref. 4, p. 94) in the case where f is strongly convex. This structure is implicit in a decomposition method and projection method of Han (Refs. 18, 30), for which f is the convex dual functional associated with a certain linearly constrained convex program (see Ref. 22 for detailed discussions). This structure arises also in least-square problems where an l 1 -penalty is placed on a subset of the parameters in order to minimize the support (see Refs. 31-33 and references therein).

Motivated by the preceding works, we consider in this paper the nondifferentiable (nonconvex) case where the nondifferentiable part of f is separable. Specifically, we assume that f has the following special form:

```math
f ( x _ { 1 } , \dots , x _ { N } ) = f _ { 0 } ( x _ { 1 } , \dots , x _ { N } ) + \sum _ { k = 1 } ^ { N } f _ { k } ( x _ { k } ) ,
```

for some f 0 : ℜ n 1 C ··· C nN &gt; ℜ∪ { S } and some f k : ℜ nk &gt; ℜ∪ { S }, k G 1, . . . , N . Here, N , n 1 , . . . , nN are positive integers. We assume that f is proper, i.e., f ∕ ≡ S . We will refer to each xk , k G 1, . . . , N , as a coordinate block of x G ( x 1 , . . . , xN ). We will show that each cluster point of the iterates generated by the (block) coordinate descent method is a stationary point of f , provided that f 0 has a certain smoothness property (see Lemma 3.1), f is continuous on a compact level set, and either f is pseudoconvex in every pair of coordinate blocks from among N A 1 coordinate blocks, or f has at most one minimum in each of N A 2 coordinate blocks (see Theorem 4.1). If f is quasiconvex and hemivariate in every coordinate block, then the assumptions of continuity of f and compactness of the level set may be relaxed further (see Proposition 5.1). These results unify and extend some previous results in Refs. 4, 6, 8, 26-27. For example, previous results assumed that f is pseudoconvex and that f 1 , . . . , fN are indicator functions for closed convex sets, whereas we assume only that f is pseudoconvex in every pair of coordinate blocks from among N A 1 coordinate blocks, with no additional assumption made on f 1 , . . . , fN . Previous results also did not consider the case where f is not continuous on its effective domain. Lastly, we apply our results to derive new (and old) convergence results for the proximal minimization algorithm, an algorithm of Arimoto and Blahut (Refs. 11-12), and an algorithm of Han (Ref. 30); see Examples 6.1-6.3. We also apply them to a problem of blind source separation described in Refs. 31, 33; see Example 6.4.

In our notation, ℜ m denotes the space of m -dimensional real column vector. For any x , y ∈ℜ m , we denote by 〈 x , y 〉 the Euclidean inner product of x , y and by ∣∣ x ∣∣ the Euclidean norm of x , i.e.,

```math
\| x \| = \sqrt { \langle x , x \rangle } .
```

For any set S ⊆ℜ m , we denote by int( S ) the interior of S and denote

```math
b d r y ( S ) = S \setminus\mathrm{int} ( S ) .
```

For any h : ℜ m &gt; ℜ∪ { S }, we denote by dom h the effective domain of h , i.e.,

```math
d o m \, h = \{ x \in \Re ^ { m } | h ( x ) < \infty \} .
```

For any x ∈ dom h and any d ∈ℜ m , we denote the (lower) directional derivative of h at x in the direction d by

```math
h ^ { \prime } ( x ; d ) = \liminf _ { \lambda \downarrow 0 } [ h ( x + \lambda d ) - h ( x ) ] / \lambda .
```

We say that h is quasiconvex if

```math
h ( x + \lambda d ) \leq \max \{ h ( x ) , h ( x + d ) \} , \quad \text {for all } x , d \, \text {and} \, \lambda \in [ 0 , 1 ] ;
```

h is pseudoconvex if

```math
h ( x + d ) \geq h ( x ) , \quad \text {whenever } x \in \text {dom } h \text { and } h ^ { \prime } ( x ; d ) \geq 0 ;
```

see Ref. 34, p. 146; and h is hemivariate if h is not constant on any line segment belonging to dom h (Ref. 1). For any nonempty I ⊆ {1, . . . , m }, we say that h ( x 1 , . . . , xm ) is pseudoconvex [respectively, has at most one minimum point].

## 2. Block Coordinate Descent Method

We describe formally the block coordinate descent (BCD) method below.

## BCD Method.

Initialization. Choose any x 0 G ( x 0 1 , . . . , x 0 N ) ∈ dom f .

Iteration r C 1, r ¤ 0. Given x r G ( x r 1 , . . . , x r N ) ∈ dom f , choose an index s ∈ {1, . . . , N } and compute a new iterate

```math
x ^ { r + 1 } = ( x _ { 1 } ^ { r + 1 } , \dots , x _ { N } ^ { r + 1 } ) \in \text {dom} f
```

satisfying

```math
x _ { s } ^ { r + 1 } \in \arg \min _ { x _ { s } } f ( x _ { 1 } ^ { r } , \dots , x _ { s - 1 } ^ { r } , x _ { s } , x _ { s + 1 } ^ { r } , \dots , x _ { N } ^ { r } ) , \quad ( 2 )
```

```math
\begin{aligned}
x _ { j } ^ { r + 1 } = x _ { j } ^ { r } , \quad \forall j \neq s . \quad & & ( 3 )
\end{aligned}
```

We note that the minimization in (2) is attained if

```math
X ^ { 0 } = \{ x \colon f ( x ) \leq f ( x ^ { 0 } ) \}
```

is bounded and f is lower semicontinuous (lsc) on X 0 , so X 0 is compact (Ref. 35). Alternatively, this minimization is attained if f is convex, has a minimum point, and is hemivariate in each coordinate block (but the level sets of f need not be bounded). To ensure convergence, we need further that each coordinate block is chosen sufficiently often in the method. In particular, we will choose the coordinate blocks according to the following rule (see, e.g., Refs. 7-8, 21, 25).

Essentially Cyclic Rule. There exists a constant T ¤ N such that every index s ∈ {1, . . . , N } is chosen at least once between the r th iteration and the ( r C T A 1)th iteration, for all r .

A well-known special case of this rule, for which T G N , is given below.

Cyclic Rule. Choose s G k at iterations k , k C N , k C 2 N , . . . , for k G 1, . . . , N .

## 3. Stationary Points of f

We say that z is a stationary point of f if z ∈ dom f and

```math
f ^ { \prime } ( z ; d ) \geq 0 , \quad \forall d .
```

We say that z is a coordinatewise minimum point of f if z ∈ dom f and

```math
\begin{aligned}
f ( z + ( 0 , \dots , d _ { k } , \dots , 0 ) ) \geq & f ( z ) , \quad \forall d _ { k } \in \Re ^ { n _ { k } } ,
\end{aligned}
```

for all k G 1, . . . , N . Here and throughout, we denote by (0, . . . , dk , . . . , 0) the vector in ℜ n 1 C ··· C nN whose k th coordinate block is dk and whose other coordinates are zero. We say that f is regular at z ∈ dom f if

```math
\begin{aligned}
f ^ { \prime } ( z ; d ) & \geq 0 , \quad \forall d = ( d _ { 1 } , \dots , d _ { N } ) , \\ \text {such that} f ^ { \prime } ( z ; ( 0 , \dots , d _ { k } , \dots , 0 ) ) & \geq 0 , \quad k = 1 , \dots , N .
\end{aligned}
```

This notion of regularity is weaker than that used by Auslender (Ref. 4, p. 93), which entails

```math
f ^ { \prime } ( z ; d ) = \sum _ { k = 1 } ^ { N } f ^ { \prime } ( z ; ( 0 , \dots , d _ { k } , \dots , 0 ) ) , \quad \text {for all $d=(d_{1},\dots,d_{N})$} .
```

For example, the function

```math
f ( x _ { 1 } , x _ { 2 } ) = \phi ( x _ { 1 } , x _ { 2 } ) + \phi ( - x _ { 1 } , x _ { 2 } ) + \phi ( x _ { 1 } , - x _ { 2 } ) + \phi ( - x _ { 1 } , - x _ { 2 } ) ,
```

where

```math
\phi ( a , b ) = \max \{ 0 , a + b - \sqrt { a ^ { 2 } + b ^ { 2 } } \} ,
```

is regular at z G (0, 0) in the sense of (5), but is not regular in the sense of Ref. 4, p. 93.

Since (4) implies

```math
f ^ { \prime } ( z ; ( 0 , \dots , d _ { k } , \dots , 0 ) ) \geq 0 , \quad \text {for all } d _ { k } ,
```

it follows that a coordinatewise minimum point z of f is a stationary point of f whenever f is regular at z . To ensure regularity of f at z , we consider one of the following smoothness assumptions on f 0 :

- (A1) dom f 0 is open and f 0 is Ga ˆteaux-differentiable on dom f 0 .
- (A2) f 0 is Ga ˆteaux-differentiable on int(dom f 0 ) and, for every z ∈ dom f ∩ bdry(dom f 0 ), there exist k ∈ {1, . . . , N } and dk ∈ℜ nk such that f ( z C (0, . . . , dk , . . . , 0)) F f ( z ).

Assumption A1 was considered essentially by Auslender (Ref. 4, Example 2 on p. 94). In contrast to Assumption A1, Assumption A2 allows dom f 0 to include boundary points. We will see an application (Example 6.2) where A2 holds but not A1.

Lemma 3.1. Under A1, f is regular at each z ∈ dom f . Under A2, f is regular at each coordinatewise minimum point z of f .

Proof. Under A1, if z G ( z 1 , . . . , zN ) ∈ dom f , then z ∈ dom f 0 . Under A2, if z G ( z 1 , . . . , zN ) is a coordinatewise minimum point of f , then z ∉ bdry(dom f 0 ), so z ∈ int(dom f 0 ). Thus, under either A1 or A2, f 0 is Ga ˆteaux-differentiable at z . Fix any d G ( d 1 , . . . , dN ) such that

```math
f ^ { \prime } ( z ; ( 0 , \dots , d _ { k } , \dots , 0 ) ) \geq 0 , \quad k = 1 , \dots , N .
```

```math
0 .
```

Then,

```math
\begin{aligned}
T h e n , & & f ^ { \prime } ( z ; d ) = \langle \nabla f _ { 0 } ( z ) , d \rangle + \liminf _ { \lambda \downarrow 0 } \sum _ { k = 1 } ^ { N } \left [ f _ { k } ( x _ { k } + \lambda d _ { k } ) - f _ { k } ( x _ { k } ) \right ] / \lambda \\ & & \geq \langle \nabla f _ { 0 } ( z ) , d \rangle + \sum _ { k = 1 } ^ { N } \liminf _ { \lambda \downarrow 0 } \left [ f _ { k } ( x _ { k } + \lambda d _ { k } ) - f _ { k } ( x _ { k } ) \right ] / \lambda \\ & & = \langle \nabla f _ { 0 } ( z ) , d \rangle + \sum _ { k = 1 } ^ { N } f _ { k } ^ { \prime } ( z _ { k } ; d _ { k } ) \\ & & = \sum _ { k = 1 } ^ { N } f ^ { \prime } ( z ; ( 0 , \dots , d _ { k } , \dots , 0 ) ) \\ & & \geq 0 .
\end{aligned}
```

## 4. Convergence Analysis: I

Our first convergence result unifies and extends a result of Auslender (Ref. 4, p. 95) for the nondifferentiable convex case and some results of Grippo and Sciandrone (Ref. 27), Luenberger (Ref. 8, p. 159), and Zadeh (Ref. 26) for the differentiable case. In what follows, r ≡ ( N A 1) mod N G A A A

means r N 1, 2 N 1, 3 N 1, . . . .

Theorem 4.1. Assume that the level set X 0 G { x : f ( x ) / f ( x 0 )} is compact and that f is continuous on X 0 . Then, the sequence { x r G ( x r 1 , . . . , x r N )} r G 0, 1,... generated by the BCD method using the essentially cyclic rule is defined and bounded. Moreover, the following statements

```math
-
```

▭

hold:

- (a) If f ( x 1 , . . . , xN ) is pseudoconvex in ( xk , xi ) for every i , k ∈ {1, . . . , N }, and if f is regular at every x ∈ X 0 , then every cluster point of { x r } is a stationary point of f .
- (b) If f ( x 1 , . . . , xN ) is pseudoconvex in ( xk , xi ) for every i , k ∈ {1, . . . , N A 1}, if f is regular at every x ∈ X 0 , and if the cyclic rule is used, then every cluster point of { x r } r ≡ ( N A 1) mod N is a stationary point of f .
- (c) If f ( x 1 , . . . , xN ) has at most one minimum in xk for k G 2, . . . , N A 1, and if the cyclic rule is used, then every cluster point z of { x r } r ≡ ( N A 1) mod N is a coordinatewise minimum point of f . In addition, if f is regular at z , then z is a stationary point of f .

Proof. Since X 0 is compact, an induction argument on r shows that x r C 1 is defined, f ( x r C 1 ) / f ( x r ), and x r C 1 ∈ X 0 for all r G 0, 1, . . . . Thus, { x r } is bounded. Consider any subsequence { x r } r ∈ R , with R ⊆ {0, 1, . . .}, converging to some z . For each j ∈ {1, . . . , T }, { x r A T C 1 C j } r ∈ R is bounded, so by passing to a subsequence, if necessary, we can assume that

```math
\{ x ^ { r - T + 1 + j } \} _ { r \in \mathcal { N } } \text { converges to some } z ^ { j } = ( z _ { 1 } ^ { j } , \dots , z _ { N } ^ { j } ) , \quad j = 1 , \dots , T .
```

Thus,

```math
z ^ { T - 1 } = z .
```

Since { f ( x r )} converges monotonically and f is continuous on X 0 , we obtain that

```math
f ( x ^ { 0 } ) \geq \lim _ { r \to \infty } f ( x ^ { r } ) = f ( z ^ { 1 } ) = \dots = f ( z ^ { T } ) .
```

By further passing to a subsequence, if necessary, we can assume that the index s chosen at iteration r A T C 1 C j , j ∈ {1, . . . , T }, is the same for all r ∈ R , which we denote by s j .

For each j ∈ {1, . . . , T }, since s j is chosen at iteration r A T C 1 C j for r ∈ R , then (2) and (3) yield

```math
\begin{aligned}
f ( x ^ { r - T + 1 + j } ) \leq & f ( x ^ { r - T + 1 + j } + ( 0 , \dots , d _ { s ^ { \prime } } , \dots , 0 ) ) , \quad \forall d _ { s ^ { \prime } } , j = 1 , \dots , T , \\ x _ { k } ^ { r - T + 1 + j } = & x _ { k } ^ { r - T + j } , & \forall k \neq s ^ { j } , j = 2 , \dots , T .
\end{aligned}
```

Then, the continuity of f on X 0 yields in the limit that

```math
\begin{aligned}
f ( z ^ { j } ) \leq & f ( z ^ { j } + ( 0 , \dots , d _ { s ^ { \prime } } , \dots , 0 ) ) , \quad \forall d _ { s ^ { \prime } } , j = 1 , \dots , T , \\ z _ { k } ^ { j } = & \, z _ { k } ^ { j - 1 } , \quad \forall k \neq s ^ { j } , \quad j = 2 , \dots , T .
\end{aligned}
```

Then, (6) and (7) yield

```math
\begin{aligned}
f ( z ^ { j - 1 } ) \leq & f ( z ^ { j - 1 } + ( 0 , \dots , d _ { s ^ { \prime } } ) , \dots , 0 ) ) , \quad \forall d _ { s ^ { \prime } } , j = 2 , \dots , T . \quad ( 8 )
\end{aligned}
```

(a), (b) Suppose that f is regular at every x ∈ X 0 and that f ( x 1 , . . . , xN ) is pseudoconvex in ( xk , xi ) for every i , k ∈ { s 1 } ∪ · · · ∪ { s T A 1 }. This holds under the assumption (a) or under the assumption (b), with { x r } r ∈ R being any convergent subsequence of { x r } r ≡ ( N A 1) mod N . We claim that, for j G 1, . . . , T A 1,

```math
\begin{aligned}
f ( z ^ { j } ) \leq & f ( z ^ { j } + ( 0 , \dots , d _ { k } , \dots , 0 ) ) , \quad \forall d _ { k } , \forall k = s ^ { 1 } , \dots , s ^ { j } . \quad ( 9 )
\end{aligned}
```

By (7), (9) holds for j G 1. Suppose that (9) holds for j G 1, . . . , l A 1 for some l ∈ {2, . . . , T A 1}. We show that (9) holds for j G l . From (8), we have that

```math
\begin{aligned}
f ( z ^ { l - 1 } ) \leq & f ( z ^ { l - 1 } + ( 0 , \dots , d _ { s } , \dots , 0 ) ) , \quad \forall d _ { s } ,
\end{aligned}
```

```math
f ^ { \prime } ( z ^ { l - 1 } ; ( 0 , \dots , z _ { s ^ { l } } ^ { l } - z _ { s ^ { l } } ^ { l - 1 } , \dots , 0 ) ) \geq 0 .
```

Also, since (9) holds for j G l A 1, we have that, for each k G s 1 , . . . , s l A 1 ,

```math
f ^ { \prime } ( z ^ { l - 1 } ; ( 0 , \dots , d _ { k } , \dots , 0 ) ) \geq 0 , \quad \forall d _ { k } .
```

Since by (6) z l A 1 ∈ X 0 , so f is regular at z l A 1 , the above two relations imply

```math
f ^ { \prime } ( z ^ { l - 1 } ; ( 0 , \dots , d _ { k } , \dots , 0 ) + ( 0 , \dots , z _ { s } ^ { l } - z _ { s } ^ { l - 1 } , \dots , 0 ) ) \geq 0 , \quad \forall d _ { k } .
```

Since f is pseudoconvex in ( xk , xs l ), this yields [also using z l G z l A 1 C (0, . . . , z l s l A z l A 1 s l , . . . , 0)] for k G s 1 , . . . , s l A 1 that

```math
\begin{aligned}
f ( z ^ { l } + ( 0 , \dots , d _ { k } , \dots , 0 ) ) \geq & f ( z ^ { l - 1 } ) = f ( z ^ { l } ) , \quad \forall d _ { k } .
\end{aligned}
```

Since we have also that (7) holds with j G l , we see that (9) holds for j G l . By induction, (9) holds for all j G 1, . . . , T A 1.

Since z T A 1 G z and (9) holds for j G T A 1, then (4) holds for k G s 1 , . . . , s T A 1 . Since z T A 1 G z and (8) holds (in particular, for j G T ), then (4) holds for k G s T also. Since

```math
\{ 1 , \dots , N \} = \{ s ^ { 1 } \} \cup \cdots \cup \{ s ^ { T } \} ,
```

this implies that z is a coordinatewise minimum point of f . Since f is regular at z , then z is in fact a stationary point of f .

- (c) Suppose that f ( x 1 , . . . , xN ) has at most one minimum in xk for k G s 2 , . . . , s T A 1 . This holds under the assumption (c), with { x r } r ∈ R being any convergent subsequence of { x r } r ≡ ( N A 1) mod N . For each j G 2, . . . , T A 1, since

implying

(7) and (8) hold, then the function

```math
d _ { s ^ { j } } \mapsto f ( z ^ { j } + ( 0 , \dots , d _ { s ^ { j } } , \dots , 0 ) )
```

attains its minimum at both ds j G 0 and ds j G z j A 1 s j A z j s j . By assumption, the minimum point is unique, implying 0 G z j A 1 s j A z j s j , or equivalently, z j A 1 G z j . Thus, z 1 G z 2 G · · · G z T A 1 G z and (7) yields that (4) holds for k G s 1 , . . . , s T A 1 . Since z T A 1 G z and (8) holds (in particular, for j G T ), then (4) holds for k G s T also. Since

```math
\{ 1 , \dots , N \} = \{ s ^ { 1 } \} \cup \cdots \cup \{ s ^ { T } \} ,
```

this implies that z is a coordinatewise minimum point of f . If f is regular at z , then z is also a stationary point of f . ▭

Notice that, if f is pseudoconvex, then f is pseudoconvex in ( xk , xi ) for every i , k ∈ {1, . . . , N }; if f is quasiconvex and hemivariate in xk , then f has at most one minimum in xk . The converses do not hold. For example, the 2-variable Rosenbrock function has a unique minimum point but is not quasiconvex. The following 3-variable quadratic function

```math
f ( x _ { 1 } , x _ { 2 } , x _ { 3 } ) = ( 1 / 2 ) x _ { 1 } ^ { 2 } + ( 1 / 2 ) x _ { 2 } ^ { 2 } + ( 1 / 2 ) x _ { 3 } ^ { 2 } + x _ { 1 } x _ { 3 } + x _ { 2 } x _ { 3 } - x _ { 1 } x _ { 2 }
```

is convex in every pair of variables, but is not pseudoconvex. In particular, for x G (0, 0, 1 ∕ 2) and d G (1, 1, -1), we have f ′ ( x ; d ) G 1 ∕ 2 ¤ 0, while f ( x C d ) G -7 ∕ 8 F f ( x ) G 1 ∕ 8. This example generalizes to any quadratic function

```math
f ( x ) = \langle x , Q x \rangle .
```

where Q ∈ R N B N is symmetric, not positive semidefinite, but whose 2 B 2 principal submatrices are positie semidefinite. Then, for any d satisfying 〈 d , Qd 〉 F 0 and any x satisfying

```math
0 \leq \langle x , Q d \rangle < - ( 1 / 2 ) \langle d , Q d \rangle ,
```

we have that

```math
f ^ { \prime } ( x ; d ) \geq 0 , \quad \text {while} \, f ( x + d ) < f ( x ) .
```

Thus, parts (a) and (c) of Theorem 4.1 may be viewed as extensions of two results of Grippo and Sciandrone (Ref. 27, Propositions 5.2, 5.3) for the case of f 0 being continuously differentiable and each f k being the indicator function of some closed convex set. In turn, the first of these results extended a result of Zadeh (Ref. 26) for which f k ≡ 0 for all k . Part (b) makes a less restrictive assumption on f than part (a), though its assumption on the BCD method is more restrictive. Part (b) is sharp in the sense that it is false if instead we assume that f is convex in every coordinate block. This is because the Powell 3-variable example (Ref. 28) is convex in each variable; see Ref. 27, Section 6 for further discussions of the example. We will see an application (Example 6.4) in which part (b) applies but not part (a) nor (c).

## 5. Convergence Analysis: II

The convergence analysis of the previous section assumes f to be continuous on a bounded level set and makes no use of the special structure (1) of f . In this section, we show that this assumption can be relaxed by exploiting the special structure (1), provided that f is quasiconvex and hemivariate in each coordinate block. More precisely, we will make the following assumptions on f , f 0 , f 1 , . . . , fN :

- (B1) f 0 is continuous on dom f 0 .
- (B2) For each k ∈ {1, . . . , N } and ( xj ) j ≠ k , the function xk &gt; f ( x 1 , . . . , xN ) is quasiconvex and hemivariate.
- (B3) f 0 , f 1 , . . . , fN are lsc.

We will see some applications (Ref. 6, Section 3.4.3 and Examples 6.16.3) for which f satisfies this weaker assumption although it is not strictly convex. In addition, we will make one of the following technical assumptions on f 0 :

- (C1) dom f 0 is open and f 0 tends to S at every boundary point of dom f 0 .
- (C2) dom f 0 G Y 1 B · · · B YN , for some Yk ⊆ R nk , k G 1, . . . , N .

In contrast to Assumption C1, Assumption C2 allows f 0 to have a finite value on bdry(dom f ). We will see in Example 6.2 a nonseparable function f 0 that satisfies Assumptions B1-B3 and C2, but not C1. We show below that Assumptions B1-B3, together with either Assumption C1 or C2, ensure that every cluster point of the iterates generated by the BCD method is a coordinate minimum point of f . The proof of this result is patterned after an argument given by Bertsekas and Tsitsiklis (Ref. 6, pp. 220-221; also see Ref. 27), but is complicated by the fact that f is not necessarily differentiable (or even continuous) on its effective domain.

Proposition 5.1. Suppose that f , f 0 , f 1 , . . . , fN satisfy Assumptions B1B3 and that f 0 satisfies either Assumption C1 or C2. Also, assume that the sequence { x r G ( x r 1 , . . . , x r N )} r G 0, 1,... generated by the BCD method using the essentially cyclic rule is defined. Then, either { f ( x r )} ↓ -S , or else every cluster point z G ( z 1 , . . . , zN ) is a coordinatewise minimum point of f .

Proof. Since f ( x 0 ) FS and f ( x r C 1 ) / f ( x r ) for all r , then either { f ( x r )} ↓ -S , or else { f ( x r )} converges to some limit and { f ( x r C 1 ) A f ( x r )} → 0. Consider the latter case and let z be any cluster point of { x r }. Since f is lsc by Assumption B3, we have

```math
f ( z ) \leq \lim _ { r \to \infty } f ( x ^ { r } ) < \infty ,
```

so z ∈ dom f . We show below that z satisfies (4) for k G 1, . . . , N . First, we claim that, for any infinite subsequence

```math
\{ x ^ { r } \} _ { r \in \mathcal { N } } \rightarrow z ,
```

with R ⊆ {0, 1, . . .}, there holds that

```math
( x ^ { r + 1 } \} _ { r \in \mathcal { N } } \to z .
```

We prove this by contradiction. Suppose that this were not true. Then, there exists an infinite subsequence R ′ of R and a scalar (H 0 such that

```math
\| x ^ { r + 1 } - x ^ { r } \| \geq \epsilon , \quad \text {for all } r \in \mathcal { R } ^ { \prime } .
```

By further passing to a subsequence, if necessary, we can assume that there is some nonzero vector d for which

```math
\begin{aligned}
\{ ( x ^ { r + 1 } - x ^ { r } ) / \| x ^ { r + 1 } - x ^ { r } \| \} _ { r \in \mathcal { W } ^ { \prime } } \to & d ,
\end{aligned}
```

and that the same coordinate block, say xs , is chosen t the ( r C 1)st iteration for all r ∈ R ′ . Moreover, (10) implies that { f 0 ( x r )} r ∈ R and { f k ( x r k )} r ∈ R , k G 1, . . . , N , are bounded from below, which together with the convergence of { f ( x r )} G { f 0 ( x r ) C ∑ N k G 1 f k ( x r k )} implies that { f 0 ( x r )} r ∈ R and { f k ( x r k )} r ∈ R , k G 1, . . . , N , are bounded. Hence, by further passing to a subsequence, if necessary, we can assume that there is some scalar θ for which

```math
\{ \, f _ { 0 } ( x ^ { r } ) + f _ { s } ( x _ { s } ^ { r } ) \} _ { r \in \mathcal { N } ^ { r } } \rightarrow \theta .
```

Fix any λ∈ [0, ( ]. Let

```math
\hat { z } = z + \lambda d ,
```

and for each r ∈ R ′ , let

```math
\hat { x } ^ { r } = x ^ { r } + \lambda ( x ^ { r + 1 } - x ^ { r } ) / \| x ^ { r + 1 } - x ^ { r } \| .
```

Then, by (10), (12), and (14),

```math
\{ \hat { x } ^ { r } \} _ { r \in \mathcal { N } ^ { \prime } } \rightarrow \hat { z } .
```

For each r ∈ R ′ , we see from (2) that x r C 1 is obtained from x r by minimizing f with respect to xs , while the other coordinates are held fixed. Since

x

∕∣∣

λ

r

C

1

A

x

r

∣∣

/

∕

λ

(/

1, so x ˆ r lies on the line segment joining x r with x r C 1 , this together with f ( x r C 1 ) / f ( x r ) and the quasiconvexity of xs &gt; f ( x r 1 , . . . , x r s A 1 , xs , x r s C 1 , . . . , x r N ) implies

```math
\begin{aligned}
f ( \hat { x } ^ { r } ) \leq & f ( x ^ { r } ) , \quad \forall r \in \mathcal { W } ^ { \prime } .
\end{aligned}
```

Since f is lsc, this and (16) imply z ˆ ∈ dom f . Also, this and (1) and the observation that x r and x ˆ r differ only in their s th coordinate block imply

```math
\begin{aligned}
f _ { 0 } ( \hat { x } ^ { r } ) + f _ { s } ( \hat { x } _ { s } ^ { r } ) \leq & f _ { 0 } ( x ^ { r } ) + f _ { s } ( x _ { s } ^ { r } ) , \quad \forall r \in \mathcal { W } ^ { \prime } .
\end{aligned}
```

This combined with (13) yields

```math
\lim _ { r \to \infty , r \in \mathcal { I } ^ { \prime } } \sup \{ f _ { 0 } ( \hat { x } ^ { r } ) + f _ { s } ( \hat { x } _ { s } ^ { r } ) \} \leq \theta .
```

Also, since

```math
\{ \, f ( x ^ { r + 1 } ) - f ( x ^ { r } ) \} _ { r \in \mathcal { W } ^ { \prime } } \to 0 ,
```

we have equivalently that

```math
\{ \, f _ { 0 } ( x ^ { r + 1 } ) + f _ { s } ( x _ { s } ^ { r + 1 } ) - f _ { 0 } ( x ^ { r } ) - f _ { s } ( x _ { s } ^ { r } ) \} _ { r \in \mathcal { N } ^ { \prime } } \to 0 ,
```

so (13) implies

```math
\{ \, f _ { 0 } ( x ^ { r + 1 } ) + f _ { s } ( x _ { s } ^ { r + 1 } ) \} _ { r \in \mathcal { N } ^ { \prime } } \to \theta .
```

Let

```math
\delta = f _ { 0 } ( \hat { z } ) + f _ { s } ( \hat { z } _ { s } ) - \theta .
```

Since f 0 and f s are lsc, we have from (16), (17) that δ / 0. We claim that in fact δ G 0. Suppose that this were not true, so that δ H 0. By (16) and the observation that, for all r ∈ R ′ , x ˆ r and x r differ in only their s th coordinate block, we have

```math
\{ ( x _ { 1 } ^ { r } , \dots , x _ { s - 1 } ^ { r } , \hat { z } _ { s } , x _ { s + 1 } ^ { r } , \dots , x _ { N } ^ { r } ) \} _ { r \in \mathcal { N } ^ { \prime } } \to \hat { z } .
```

Moreover, the vector on the left-hand side of (19) is in dom f 0 for all r ∈ R ′ sufficiently large. Since z ˆ ∈ dom f 0 , this is certainly true under Assumption C1; under Assumption C2, this is also true because x r ∈ dom f 0 for all r and dom f 0 has a product structure corresponding to the coordinate blocks. Then, (18) together with (19) and the continuity of f 0 on dom f 0 implies that, for all r ∈ R ′ sufficiently large, there holds that

```math
f ( x ^ { r } + y ^ { r } ) \neq x ^ { r } + y ^ { r }
```

```math
\begin{aligned}
f _ { 0 } ( x _ { 1 } ^ { r } , \dots , x _ { s - 1 } ^ { r } , \hat { z } _ { s } , x _ { s + 1 } ^ { r } , \dots , x _ { N } ^ { r } ) + f _ { s } ( \hat { z } _ { s } ) \\ \leq & f _ { 0 } ( x ^ { r + 1 } ) + f _ { s } ( x _ { s } ^ { r + 1 } ) + \delta / 2 ,
\end{aligned}
```

or equivalently [via (1) and the observation that x r and x r C 1 differ in only their s th coordinate block],

```math
\begin{aligned}
f ( x _ { 1 } ^ { r } , \dots , x _ { s - 1 } ^ { r } , \hat { z } _ { s } , x _ { s + 1 } ^ { r } , \dots , x _ { N } ^ { r } ) \leq & f ( x ^ { r + 1 } ) + \delta / 2 ,
\end{aligned}
```

a contradiction to the fact that x r C 1 is obtained from x r by minimizing f with respect to the s th coordinate block, while the other coordinates are held fixed. Hence, δ G 0 and therefore

```math
f _ { 0 } ( \hat { z } ) + f _ { s } ( \hat { z } _ { s } ) = \theta .
```

Since the choice of λ was arbitrary, we obtain [also using (14)]

```math
f _ { 0 } ( z + \lambda d ) + f _ { s } ( z _ { s } + \lambda d _ { s } ) = \theta , \quad \forall \lambda \in [ 0 , \epsilon ] ,
```

where ds denotes the s th coordinate block of d . Since x r and x r C 1 differ in only their s th coordinate block for all r ∈ R ′ , then all coordinate blocks of d , except ds , are zero [see (12)], and the above relation, together with (1), shows that f ( z C λ d ) is constant (and finite) for all λ∈ [0, ( ], a contradiction to Assumption B2, namely, that f is hemivariate in the s th coordinate block. Hence, (11) holds.

Since (11) holds for any subsequence { x r } r ∈ R of { x r } converging to z , we can apply (11) to the subsequence { x r C 1 } r ∈ R to conclude that { x r C 2 } r ∈ R → z and so on, yielding

```math
\{ x ^ { r + j } \} _ { r \in \mathcal { I } } \to z , \quad \forall j = 0 , 1 , \dots , T ,
```

where T is the bound specified in the essentially cyclic rule.

We claim that (20), together with Assumption C1 or C2, implies

```math
\begin{aligned}
f _ { 0 } ( z ) + f _ { k } ( z _ { k } ) \leq & f _ { 0 } ( z _ { 1 } , \dots , z _ { k - 1 } , x _ { k } , z _ { k + 1 } , \dots , z _ { N } ) + f _ { k } ( x _ { k } ) ,
\end{aligned}
```

for all xk and all k ∈ {1, . . . , N }. To see this, fix any k ∈ {1, . . . , N }. Since the coordinate blocks are chosen according to the essentially cyclic rule, there exists some j ∈ {1, . . . , T } and an infinite subsequence R ′ ⊆ R such that the coordinate block xk is chosen at the ( r C j )th iteration for all r ∈ R ′ . Then, for each r ∈ R ′ , x r C j k minimizes f 0 ( x r C j 1 , . . . , x r C j k A 1 , xk , x r C j k C 1 , . . . , x r C j N ) C f k ( xk ) over all xk [see (1), (2), (3)], so that

```math
\begin{aligned}
f _ { 0 } ( x ^ { r + j } ) + & f _ { k } ( x ^ { r + j } ) \\ \leq & f _ { 0 } ( x ^ { r + j } , \dots , x ^ { r + j } , x _ { k } , x ^ { r + j } , x _ { k + 1 } , \dots , x ^ { r + j } ) + & f _ { k } ( x _ { k } ) , \quad \forall x _ { k } .
\end{aligned}
```

Fix any xk ∈ dom f k such that ( z 1 , . . . , zk A 1 , xk , zk C 1 , . . . , zN ) ∈ dom f 0 . Suppose that Assumption C1 holds, so dom f 0 is open. Since z ∈ dom f 0 , then (20) implies that

```math
( x ^ { r + j } , \dots , x ^ { r + j } _ { k - 1 } , x _ { k } , x ^ { r + j } _ { k + 1 } , \dots , x ^ { r + j } _ { N } ) \in \text {dom} \, f _ { 0 } , \\ \text {for all} \, r \in \mathcal { P } ^ { \prime } \text { sufficiently large} .
```

Passing to the limit as r → S , r ∈ R ′ , and using the lsc property of f k and the continuity of f 0 on the open set dom f 0 , we obtain from (20) and (22) that (21) holds. Suppose instead that Assumption C2 holds, so

```math
\text {dom} f _ { 0 } = Y _ { 1 } \times \cdots \times Y _ { N } , \quad \text {for some} \, Y _ { 1 } \subseteq \Re ^ { n _ { 1 } } , \dots , Y _ { N } \subseteq \Re ^ { n _ { N } } .
```

Then, the first quantity on the right-hand side of (22) is finite for all r ∈ ℜ′ . Passing to the limit as r → S , r ∈ℜ′ , and using the lsc property of f k and the continuity of f 0 on dom f 0 , we obtain from (20) and (22) that (21) holds. If xk ∉ dom f k or ( z 1 , . . . , zk A 1 , xk , zk C 1 , . . . , zN ) ∉ dom f 0 , then the right-hand side of (21) has the extended value S , so (21) holds trivially. Since the above choice of k was arbitrary, this shows that (21) holds for all xk and all k ∈ {1, . . . , N }. Then, it follows from (1) that (4) holds for all k G 1, . . . , N . ▭

Proposition 5.1 extends a result of Grippo and Sciandrone (Ref. 27, Proposition 5.1) for the special case where each f k is the indicator function for some closed convex set and f 0 is continuously differentiable and (block) coordinatewise strictly pseudoconvex. In turn, the latter result is an extension of a result of Bertsekas and Tsitsiklis (Ref. 6, Proposition 3.9 in Section 3.3.5), which assumes further f 0 to be convex. As a corollary of Proposition 5.1, we obtain the following convergence result for the BCD method.

Theorem 5.1. Suppose that f , f 0 , f 1 , . . . , fN satisfy Assumptions B1B3 and that f 0 satisfies either Assumption C1 or C2. Also, assume that { x : f ( x ) / f ( x 0 )} is bounded. Then, the sequence { x r } generated by the BCD method using the essentially cyclic rule is defined, bounded, and every cluster point is a coordinatewise minimum point of f .

Theorem 5.1 extends a result of Auslender [see Theorem 1.2(a) in Ref. 4, p. 95] for the special case where f k is convex for all k , dom f 0 G Y 1 B · · · B YN for some closed convex sets Yk ⊆ ℜ nk , k G 1, . . . , N , and f 0 is strongly convex and continuous on dom f 0 .

## 6. Applications

We describe four interesting applications of the BCD method below. In all applications, the objective function f is not necessarily strictly convex nor differentiable everywhere on its effective domain.

Example 6.1. Proximal Minimization Algorithm. Let ψ : ℜ n &gt; ℜ∪ { S } be a proper (i.e., ψ ∕ ≡ S ) lsc function. Fix any scalar c H 0, and consider the proper lsc function f defined by

```math
f ( x , y ) = c \| x - y \| ^ { 2 } + \psi ( x ) .
```

Clearly, this function has the form (1) with

```math
f _ { 0 } ( x , y ) = c \| x - y \| ^ { 2 } , \quad f _ { 1 } = \psi , \quad f _ { 2 } \equiv 0 .
```

Applying the BCD method to f yields a method whereby f ( x , y ) is alternately minimized with respect to x and y . This method has the form

```math
x ^ { r + 1 } = \arg \min _ { x } c \| x - x ^ { r } \| ^ { 2 } + \psi ( x ) , \quad r = 0 , 1 , \dots ,
```

which is the proximal minimization algorithm with fixed parameter c for minimizing ψ ; see Ref. 6, Section 3.4.3 and Refs. 36-37 and references therein.

It is easily seen that f , f 0 , f 1 , f 2 satisfy Assumptions B1-B3 and that f 0 satisfies Assumptions A1 and C1. Moreover, f is regular everywhere on dom f . Then, by Proposition 5.1, if ψ is bounded below (so, f is bounded below), then every cluster point z of the iterates generated by the above proximal minimization algorithm is a stationary point of ψ , i.e.,

```math
\psi ^ { \prime } ( z ; d ) \geq 0 , \quad \text {for all $d$.}
```

Notice that Theorem 4.1 is not applicable here, since f need not be continuous on its level sets.

Example 6.2. Arimoto-Blahut Algorithm. Let Pij , i G 1, . . . , n , j G 1, . . . , m , be given nonnegative scalars satisfying

```math
\sum _ { j } P _ { i j } = 1 , \quad \text {for all $i$.}
```

The Pij may be viewed as probabilities. Consider the proper lsc function f defined by

```math
f ( x , y ) = f _ { 0 } ( x , y ) + f _ { 1 } ( x ) + f _ { 2 } ( y ) ,
```

where

```math
\text {where} \\ f _ { 0 } ( x , y ) = \begin{cases} \sum _ { j = 1 } ^ { m } \sum _ { i = 1 } ^ { n } P _ { i j } x _ { i } \phi ( y _ { i j } / x _ { i } ) , & \text {if } x \geq 0 , y > 0 , \\ \infty , & \text {otherwise} , \end{cases} \\ f _ { 1 } ( x ) = \begin{cases} 0 , & \text {if } \sum _ { i = 1 } ^ { n } x _ { i } = 1 , \\ \infty , & \text {otherwise} , \end{cases} \\ f _ { 2 } ( y ) = \begin{cases} 0 , & \text {if } \sum _ { i = 1 } ^ { n } y _ { i j } = 1 , \quad \forall j = 1 , \dots , m . \\ \infty , & \text {otherwise} , \end{cases} \\ \text {with } \phi ( t ) = - \log ( t ) . \text { In our notation, } x \text { is a vector in } \Re ^ { n } \text { whose } \text {th} \text { cc}
```

with φ ( t ) G -log( t ). In our notation, x is a vector in ℜ n whose i th coordinate is xi , and y is a vector in ℜ nm whose (( i A 1) m C j )th coordinate is yij . Applying the BCD method to f yields a method whereby f ( x , y ) is alternately minimized with respect to x and y . This in turn can be seen to be the Arimoto-Blahut algorithm for computing the capacity of a discrete memoryless communication channel (Refs. 11-12).

It can be verified that f , f 0 , f 1 , f 2 are convex and satisfy Assumptions B1-B3. Convexity of f 0 follows from observing that ( a , b ) &gt; a φ ( b ∕ a ) is convex. Moreover, f has compact level sets and is continuous on each level set, and f 0 satisfies Assumptions A2 and C2. Notice that f is not strictly convex and f 0 does not satisfy Assumption A1 or C1. Thus, by Lemma 3.1 and Theorem 5.1 or Theorem 4.1(c), the sequence of iterates generated by the Arimoto-Blahut algorithm is bounded and each cluster point is a stationary point of f . By the convexity of f , this is in fact a minimum point of f . This result matches those obtained in Refs. 11-12. Analogous convergence results are obtained for variants of the Arimoto-Blahut algorithm, whereby we use, for example,

```math
\phi ( t ) = t \log ( t ) \quad \text {or} \quad \phi ( t ) = 1 / t .
```

Example 6.3. Han Algorithm. Let f be the proper lsc convex function studied by Han [Ref. 30, (D ′ )],

```math
f ( x _ { 1 } , \dots , x _ { N } ) = ( 1 / 2 ) \| x _ { 1 } + \cdots + x _ { N } - d \| ^ { 2 } + \sum _ { k = 1 } ^ { N } f _ { k } ( x _ { k } ) ,
```

where d is a given vector in ℜ m and each f k : ℜ m &gt; ℜ∪ { S } is a proper lsc convex function. Also see Ref. 18 for a special case where f k is the support function of a closed convex set. Clearly, f is of the form (1) with

```math
f _ { 0 } ( x _ { 1 } , \dots , x _ { N } ) = ( 1 / 2 ) \| x _ { 1 } + \cdots + x _ { N } - d \| ^ { 2 } .
```

Han proposed in Ref. 30 an algorithm for minimizing f , which may be viewed as an instance of the BCD method using the cyclic rule, as was shown in Ref. 22.

It is seen easily that f , f 0 , f 1 , . . . , fN satisfy Assumptions B1-B3 and that f 0 satisfies Assumptions A1 and C1. Thus, by Lemma 3.1 and Proposition 5.1 [also see the remark following (3)], if f has a minimum point, then the iterates generated by the Han algorithm are defined and every cluster point is a minimum point of f . This result matches Proposition 4.3 in Ref. 30. On the other hand, by using the convexity of the functions, stronger convergence results can be obtained; see Refs. 22, 38.

Example 6.4. Blind Source Separation. In Ref. 33, Zibulevsky and Pearlmutter studied an optimization formulation of the blind source separation, whereby an error term of the form

```math
( 1 / 2 \sigma ^ { 2 } ) \| A S - X \| _ { F } ^ { 2 } + \sum _ { j , t } f _ { j } ^ { t } ( s _ { j } ^ { t } ) ,
```

is minimized with respect to

```math
A \in \Re ^ { m \times n } \quad \text {and} \quad S = [ s _ { j } ^ { t } ] _ { j = 1 , \dots , n , t = 1 , \dots , T } \in \Re ^ { n \times T } .
```

Here, X ∈ℜ m B T are the given data; ∣∣ · ∣∣ F denotes the Frobenious norm; σ H 0; and each f t j : ℜ &gt; [0, S ] is a proper convex function that is continuous on its effective domain and has bounded level sets. In Ref. 31, the particular choice of f t j ( · ) G ∣ · ∣ is used. To ensure the existence of an optimal solution, it was suggested in Ref. 33 that constraints such as

```math
\| A _ { l } \| \leq 1 , \quad i = 1 , \dots , m ,
```

be imposed, where Ai denotes the i th row of A . The objective function of this problem has the form (1) with N G 1 C nT ,

```math
\begin{aligned}
f _ { 0 } ( A , s _ { 1 } ^ { 1 } , \dots , s _ { n } ^ { T } ) & = ( 1 / 2 \sigma ^ { 2 } ) \| A S - X \| _ { F } ^ { 2 } , \\ f _ { 1 } ( A ) & = \begin{cases} 0 , & \text {if} \| A _ { i } \| \leq 1 , \quad i = 1 , \dots , m , \\ \infty , & \text {else} , \end{cases}
\end{aligned}
```

and f t j , j G 1, . . . , n , t G 1, . . . , T , as given. Notice that minimizing f with respect to A entails minimizing a convex quadratic function over the Cartesian product of m Euclidean balls, while minimizing f with respect to each s t j entails minimizing the sum of a convex quadratic function of one variable with a convex function of one variable. Thus, the BCD method applied to this f can be implemented fairly inexpensively. If we replace (23) by the single ball constraint

```math
\| A \| _ { F } \leq \rho ,
```

for some fixed ρ H 0, then minimizing f with respect to A can be solved efficiently using e.g. the More ´-Sorenson method.

It is not difficult to see that f is continuous on its effective domain and has compact level sets. Moreover, f is convex in ( s 1 1 , . . . , s T n ), f 1 is convex, and f 0 satisfies Assumption A1. Thus, by Lemma 3.1 and Theorem 4.1(b), the iterates generated by the BCD method using the cyclic rule are defined and every cluster point is a stationary point of f . Notice that f is not pseudoconvex in every pair of coordinate blocks and that f need not have at most one minimum in each s t j , so neither Theorem 5.1, nor part (a) of Theorem 4.1, nor part (c) of Theorem 4.1 is applicable here.

Instead of treating each s t j as a coordinate block, we can treat alternatively S G [ s t j ] j , t as a coordinate block. However, minimizing f with respect to S is more difficult. In the case of f t j ( · ) G ∣ · ∣ , this would require solving a large convex quadratic programming problem. A comparison of a primaldual interior-point method and the BCD method for solving such a problem is given in Ref. 32.

## References

1. ORTEGA, J. M., and RHEINBOLDT, W. C., Iterati û e Solution of Nonlinear Equations in Se û eral Variables , Academic Press, New York, NY, 1970.
2. HILDRETH, C., A Quadratic Programming Procedure , Naval Research Logistics Quarterly, Vol. 4, pp. 79-85, 1957; see also Erratum, Naval Research Logistics Quarterly, Vol. 4, p. 361, 1957.
3. WARGA, J., Minimizing Certain Con û ex Functions , SIAM Journal on Applied Mathematics, Vol. 11, pp. 588-593, 1963.
4. AUSLENDER, A., Optimisation Me ´thodes Nume ´riques , Masson, Paris, France, 1976.
5. BERTSEKAS, D. P., Nonlinear Programming , 2nd Edition, Athena Scientific, Belmont, Massachusetts, 1999.
6. BERTSEKAS, D. P., and TSITSIKLIS, J. N., Parallel and Distributed Computation: Numerical Methods , Prentice-Hall, Englewood Cliffs, New Jersey, 1989.
7. CENSOR, Y., and ZENIOS, S. A., Parallel Optimization: Theory, Algorithms, and Applications, Oxford University Press, Oxford, United Kingdom, 1997.
8. LUENBERGER, D. G., Linear and Nonlinear Programming , Addison-Wesley, Reading, Massachusetts, 1973.

9. POLAK, E., Computational Methods in Optimization: A Unified Approach , Academic Press, New York, NY, 1971.
10. ZANGWILL, W. I., Nonlinear Programming , Prentice-Hall, Englewood Cliffs, New Jersey, 1969.
11. ARIMOTO, S., An Algorithm for Computing the Capacity of Arbitrary DMCs , IEEE Transactions on Information Theory, Vol. 18, pp. 14-20, 1972.
12. BLAHUT, R., Computation of Channel Capacity and Rate Distortion Functions , IEEE Transactions on Information Theory, Vol. 18, pp. 460-473, 1972.
13. HOWSON, H. R., and SANCHO, N. G. F., A New Algorithm for the Solution of Multistate Dynamic Programming Problems , Mathematical Programming, Vol. 8, pp. 104-116, 1975.
14. KORSAK, A. J., and LARSON, R. E., A Dynamic Programming Successi û e Approximations Technique with Con û ergence Proofs , Automatica, Vol. 6, pp. 253-260, 1970.
15. ZUO, Z. Q., and WU, C. P., Successi û e Approximation Technique for a Class of Large -Scale NLP Problems and Its Application to Dynamic Programming , Journal of Optimization Theory and Applications, Vol. 62, pp. 515-527, 1989.
16. STERN, T. E., A Class of Decentralized Routing Algorithms Using Relaxation , IEEE Transactions on Communications, Vol. 25, pp. 1092-1102, 1977.
17. BREGMAN, L. M., The Relaxation Method of Finding the Common Point of Conû ex Sets and Its Application to the Solution of Problems in Con û ex Programming , USSR Computational Mathematics and Mathematical Physics, Vol. 7, pp. 200217, 1967.
18. HAN, S. P., A Successi û e Projection Method , Mathematical Programming, Vol. 40, pp. 1-14, 1988.
19. KIWIEL, K. C., Free -Steering Relaxation Methods for Problems with Strictly Con û ex Costs and Linear Constraints , Mathematics of Operations Research, Vol. 22, pp. 326-349, 1997.
20. LUO, Z. Q., and TSENG, P., On the Con û ergence Rate of Dual Ascent Methods for Strictly Con û ex Minimization , Mathematics of Operations Research, Vol. 18, pp. 846-867, 1993.
21. TSENG, P., Dual Ascent Methods for Problems with Strictly Con û ex Costs and Linear Constraints: A Unified Approach , SIAM Journal on Control and Optimization, Vol. 28, pp. 214-242, 1990.
22. TSENG, P., Dual Coordinate Ascent Methods for Nonstrictly Con û ex Minimization , Mathematical Programming, Vol. 59, pp. 231-247, 1993.
23. MANGASARIAN, O. L., and DE LEONE, R., Parallel Successi û e O û errelaxation Methods for Symmetric Linear Complementarity Problems and Linear Programs , Journal of Optimization Theory and Applications, Vol. 54, pp. 437-446, 1987.
24. CEA, J., and GLOWINSKI, R., Sur des Methodes d ' Optimisation par Relaxation , Revue Franc ¸aise d'Automatique, Informatique et Recherche Ope ´rationnelle, Vol. R3, pp. 5-32, 1973.
25. SARGENT, R. W. H., and SEBASTIAN, D. J., On the Con û ergence of Sequential Minimization Algorithms , Journal of Optimization Theory and Applications, Vol. 12, pp. 567-575, 1973.

26. ZADEH, N., A Note on the Cyclic Coordinate Ascent Method , Management Science, Vol. 16, pp. 642-644, 1970.
27. GRIPPO, L., and SCIANDRONE, M., On the Con û ergence of the Block Nonlinear Gauss -Seidel Method under Con û ex Constraints , Operations Research Letters, Vol. 26, pp. 127-136, 2000.
28. POWELL, M. J. D., On Search Directions for Minimization Algorithms , Mathematical Programming, Vol. 4, pp. 193-201, 1973.
29. LUO, Z. Q., and TSENG, P., Error Bounds and Con û ergence Analysis of Feasible Descent Methods: A General Approach , Annals of Operations Research, Vol. 46, pp. 157-178, 1993.
30. HAN, S. P., A Decomposition Method and Its Application to Con û ex Programming , Mathematics of Operations Research, Vol. 14, pp. 237-248, 1989.
31. BOFILL, P., and ZIBULEVSKY, M., Sparse Undetermined ICA: Estimating the Mixing Matrix and the Sources Separately , Technical Report UPC-DAC-20007, Universitat Polite `cnica de Catalunya, Barcelona, Spain, 1999.
32. SARDY, S., BRUCE, A., and TSENG, P., Block Coordinate Relaxation Methods for Nonparametric Wa û elet Denoising , Journal of Computational and Graphical Statistics, Vol. 9, pp. 361-379, 2000.
33. ZIBULEVSKY, M., and PEARLMUTTER, B., Blind Source Separation by Sparse Decomposition , Technical Report CS99-1, Computer Science Department, University of New Mexico, Albuquerque, New Mexico, 1999.
34. MANGASARIAN, O. L., Nonlinear Programming , McGraw-Hill, New York, NY, 1969.
35. ROCKAFELLAR, R. T., Con û ex Analysis , Princeton University Press, Princeton, New Jersey, 1970.
36. MARTINET, B., Determination Approche ´e d'un Point Fixe d'une Application Pseudo-Contractante: Cas de l'Application Prox , Comptes Rendus des Se ´ances de l'Acade ´mie des Sciences, Vol. 274A, pp. 163-165, 1972.
37. ROCKAFELLAR, R. T., Augmented Lagrangians and Applications of the Proximal Point Algorithm in Con û ex Programming , Mathematics of Operations Research, Vol. 1, pp. 97-116, 1976.
38. BAUSCHKE, H. H., and LEWIS, A. S., Dykstra's Algorithm with Bregman Projections: A Con û ergence Proof , Optimization (to appear).
