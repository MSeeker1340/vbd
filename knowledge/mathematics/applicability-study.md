---
type: Mathematical Specification
title: VBD Contraction for Coupled Axial Springs
description: Develops a coupled mechanical example from its implicit-Euler objective to a finite-sweep contraction bound and extensions to richer models.
tags: [applicability, vbd, contraction, residual, springs]
timestamp: 2026-09-14T00:00:00Z
---

# Context

An end-to-end example connects the [implicit-Euler identities](./implicit-euler.md),
[block-update algebra](./block-states-and-operators.md), and
[contractive fixed-point theory](./contractive-fixed-point-iteration.md).
The example must have genuine coupling between vertices and a nonlinear update, while permitting
explicit bounds on an invariant neighborhood. A chain of masses and hardening springs provides
such a system. Its VBD sweep is a nonlinear map whose fixed points are implicit-Euler solutions.
The analysis below derives a contraction factor and a finite-sweep physical-residual bound.

The derivations are real-arithmetic mathematics awaiting Lean formalization. Numerical
experiments illustrate the estimates. The [project decision](/project/applicability-decision.md)
records the model-selection rationale, evaluation policy, and scope of the formalization milestone.

# Mechanical model

Consider beads sliding along a straight frictionless rail, connected by elastic segments.
This can represent a discretized elastic band constrained to longitudinal motion, or a row of
sliding masses joined by springs. The hardening law below is an idealized constitutive model;
a real band's tension-only behavior or material calibration would require additional assumptions.
Both chain endpoints are free. Each vertex has one positional degree of freedom.

Let the rest spacing be $\ell>0$, and write the physical position of mass $i$ as
$x_i=x_i^{\mathrm{rest}}+\ell u_i$. The signed extension of an adjacent spring is
$\ell(u_i-u_j)$, up to orientation. For stiffness $k_e>0$, use the physical spring energy

$$
E_e(s)=\frac{k_e}{2}s^2+\frac{k_e\eta}{4\ell^2}s^4,
\qquad \eta\ge0.
$$

The case $\eta=0$ is quadratic; $\eta>0$ gives nonlinear hardening. Interaction support
is the path graph. Positive curvature follows from this particular spring law, independently
of that support structure.

For timestep $h>0$, define the dimensionless inertia predictor and coefficients

$$
y_i=\frac{x_i^{\mathrm{old}}+h v_i^{\mathrm{old}}+h^2a_i^{\mathrm{ext}}
                 -x_i^{\mathrm{rest}}}{\ell},
\qquad a_i=\frac{m_i}{m_{\min}}\ge1,
\qquad b_e=\frac{h^2k_e}{m_{\min}}.
$$

Dividing the implicit-Euler incremental energy by $m_{\min}\ell^2/h^2$ gives

$$
G(u)=\frac12\sum_i a_i(u_i-y_i)^2
 +\sum_{e=\{i,j\}}b_e\left(\frac{d_e^2}{2}+\frac{\eta d_e^4}{4}\right),
\qquad d_e=u_i-u_j.
$$

Thus inertia and elasticity contribute to the same objective. The initial iterate is the
predictor itself, $u^0=y$. This construction uses the old state and external acceleration,
without access to the new implicit-Euler solution.

# Forces, local solves, and sweeps

Write $f=\nabla G$, $H=Df$, and $D_i=H_{ii}$. For neighbors $j\sim i$,

$$
f_i(u)=a_i(u_i-y_i)+\sum_{j\sim i}b_{ij}(d_{ij}+\eta d_{ij}^3),
\qquad
D_i(u)=a_i+\sum_{j\sim i}b_{ij}(1+3\eta d_{ij}^2).
$$

The full Newton vertex update is

$$
(U_i(u))_j=
\begin{cases}
u_i-f_i(u)/D_i(u),&j=i\text{ and }|D_i(u)|>\varepsilon,\\
u_j,&\text{otherwise}.
\end{cases}
$$

The normalized study threshold is $\varepsilon=10^{-12}$, corresponding to a physical
scalar Hessian threshold $10^{-12}m_{\min}/h^2$ in force/length units.
Since $D_i\ge a_i\ge1$, every visit follows the nonsingular branch in this family.
There is no line search or iteration acceleration.

A serial sweep visits vertices $0,\ldots,n-1$, exposing each write to subsequent visits:

$$
T_{\mathrm{serial}}=U_{n-1}\circ\cdots\circ U_0.
$$

A proper-color sweep updates even vertices from one snapshot, then odd vertices from the next
snapshot. Same-color vertices share no spring, so their updates commute. A color batch equals
any serial order of its members. Every vertex is visited exactly once per complete sweep;
this coverage condition matters both for consistency and the contraction estimate.

# Stationary solutions and observables

The Hessian is a positive diagonal inertia matrix plus a weighted path Laplacian:

$$
H(u)=\operatorname{diag}(a)+L_{w(u)},
\qquad w_e(u)=b_e(1+3\eta d_e^2)>0.
$$

Therefore $G$ is coercive and strongly convex, with a unique stationary point $u^*$.
If $\|y\|_\infty\le Y$, the largest root coordinate has nonnegative outgoing elastic
forces, and the smallest has nonpositive ones. Their equations imply

$$
\min_i y_i\le u_j^*\le\max_i y_i,
\qquad \|u^*\|_\infty\le Y.
$$

A root is preserved by every update. Conversely, if a skip-free once-per-vertex sweep fixes its
input, each coordinate's sole write must be zero. Induction through the visits shows that all
intermediate states equal the input and all components of $f$ vanish. Hence

$$
T(u)=u\quad\Longleftrightarrow\quad f(u)=0.
$$

This argument applies to both execution orders and is independent of contraction. With skips,
the implication can fail: for two masses with $a_i=b=1$, $\eta=0$,
$y=(1,-1)$, $u=(0,0)$, and $\varepsilon=2$, both updates skip despite nonzero force.

Four observables describe different properties of an iteration:

$$
\begin{aligned}
e(u)&=\|u-u^*\|_\infty &&\text{(state error)},\\
r_{\mathrm{IE}}(u)&=\max_i\frac{|f_i(u)|}{a_i}
 =\max_i\frac{h^2|F_{\mathrm{IE},i}(x)|}{m_i\ell}
 &&\text{(scaled physical residual)},\\
r_T(u)&=\|T(u)-u\|_\infty &&\text{(sweep defect)},\\
G(u)&&&\text{(incremental objective)}.
\end{aligned}
$$

The physical residual uses a fixed weighted maximum norm on force for each system. A residual
tolerance $\tau$ means $|F_{\mathrm{IE},i}|\le m_i\ell\tau/h^2$ for every mass.
It does not assert stepwise energy decrease or identify the defect with the physical residual.

# A neighborhood preserved by every update

Assume $0\le Y\le B$, $\|y\|_\infty\le Y$, and
$b_e\le\alpha=h^2k_{\max}/m_{\min}$. Set

$$
\mathcal C=\{u:\|u\|_\infty\le B\}.
$$

On this box, $|d_{ij}|\le2B$. Expanding the Newton numerator yields

$$
(U_i(u))_i=
\frac{a_i y_i+\sum_{j\sim i}b_{ij}
 [u_j+\eta d_{ij}^2(2u_i+u_j)]}
 {a_i+\sum_{j\sim i}b_{ij}(1+3\eta d_{ij}^2)}.
$$

Its absolute value is bounded by

$$
\frac{a_iY+\sum_{j\sim i}b_{ij}(B+12\eta B^3)}
     {a_i+\sum_{j\sim i}b_{ij}}.
$$

Since each vertex has at most two neighbors, the sufficient condition

$$
24\alpha\eta B^3\le B-Y
$$

makes every individual update preserve $\mathcal C$. Proper-color snapshots preserve it
coordinatewise as well. This supplies the intermediate-state control needed to compose local
derivative bounds, rather than only invariance of the complete sweep.

# From the derivative to contraction

The changed derivative row is

$$
(DU_i(u))_{ij}=\delta_{ij}-\frac{H_{ij}(u)}{D_i(u)}
              +\frac{f_i(u)\,\partial_jD_i(u)}{D_i(u)^2}.
$$

The final term vanishes at a root. In the visit order, decompose the root Hessian into its
diagonal, strictly lower, and strictly upper parts, $H(u^*)=D+L+R$. Then

$$
DT(u^*)=-(D+L)^{-1}R,
$$

the Gauss–Seidel error matrix. Away from the root, the force-dependent variation term remains.
A root-local spectral radius alone therefore does not certify the nonlinear neighborhood.

For a uniform estimate, define

$$
\begin{aligned}
\nu&=2\alpha,& S&=\nu(1+12\eta B^2),\\
P&=B+Y+2B\nu(1+4\eta B^2),&
q&=\frac{S}{1+S}+\frac{24\eta B\nu P}{(1+\nu)^2}.
\end{aligned}
$$

The off-diagonal Newton row sums to at most $S/(1+S)$, and its diagonal contribution
cancels. To bound the variation term, put $\nu_i=\sum_j b_{ij}/a_i\le\nu$. Then

$$
\begin{aligned}
D_i&\ge a_i(1+\nu_i),\\
|f_i|&\le a_i[B+Y+2B\nu_i(1+4\eta B^2)],\\
\sum_j|\partial_jD_i|&\le24\eta B a_i\nu_i.
\end{aligned}
$$

Consequently the variation row sum is at most

$$
\frac{24\eta B\nu_i[B+Y+2B\nu_i(1+4\eta B^2)]}{(1+\nu_i)^2}
\le \frac{24\eta B\nu P}{(1+\nu)^2}.
$$

For the final inequality, the derivative of $s(p+rs)/(1+s)^2$ has numerator
$p+(2r-p)s$, with $p=B+Y$ and $r=2B(1+4\eta B^2)$.
It is nonnegative because $Y\le B$. Both local inverse factors are retained.

All unchanged derivative rows are identity rows; each changed row has absolute sum at most
$q$. If $q<1$, the ordered comparison product also has row sums at most $q$:
before a visit all current components are bounded by the initial maximum, and the visited
component becomes bounded by $q$ times that maximum. Its value then stays fixed.
This works for serial and proper-color orders. Convexity of $\mathcal C$ gives

$$
\|T(u)-T(v)\|_\infty\le q\|u-v\|_\infty,
\qquad u,v\in\mathcal C.
$$

Completeness of the closed box, invariance, and fixed-point consistency now connect the local
estimates to the generic contraction theorem.

# Finite-sweep bounds and physical scales

At $B=0.1$, $Y=0.05$, $0\le\eta\le1$, and $\alpha\le1/4$, the
invariance condition holds and

$$
q\le0.494442<0.512,
\qquad
L_F=1+4\alpha(1+12\eta B^2)\le2.12.
$$

Integrating the Hessian along a segment gives
$r_{\mathrm{IE}}(u)\le L_F\|u-u^*\|_\infty$.
The predictor and root bounds give $\|y-u^*\|_\infty\le2Y=0.1$, so

$$
\|T^s(y)-u^*\|_\infty\le0.1(0.512)^s,
\qquad
r_{\mathrm{IE}}(T^s(y))\le0.212(0.512)^s.
$$

After 20 sweeps the latter is below $3.25\times10^{-7}$, meeting a tolerance of
$10^{-6}$. The box contains a radius-$0.05$ maximum-norm ball around the root;
initialization requires only the explicit predictor bound. A general start in the box has
initial state error at most $B+Y=0.15$.

For $\ell=0.1\,\mathrm m$, the predictor permits 5 mm displacement and intermediate
states permit 10 mm. A dimensionless state error of $10^{-6}$ is 0.1 micrometers;
the force-residual tolerance retains its mass and timestep scaling above.
The timestep condition is

$$
h\le\frac12\sqrt{\frac{m_{\min}}{k_{\max}}}.
$$

For $m_{\min}=0.001\,\mathrm{kg}$, stiffnesses of $1$, $100$, and
$10^4\,\mathrm{N/m}$ permit approximately 15.81, 1.581, and 0.1581 ms, respectively.
At the nonlinear endpoint an interior vertex's elastic diagonal can reach 0.56 against minimum
inertia 1. These are synthetic physical examples, not measured band material properties.

## Stepwise residual progress

At a coordinate of largest absolute error, the signed Laplacian contribution to
$f(u)-f(u^*)$ is nonnegative. Thus $\|u-u^*\|_\infty\le r_{\mathrm{IE}}(u)$, and

$$
r_{\mathrm{IE}}(T(u))\le\theta r_{\mathrm{IE}}(u),
\qquad \theta=L_Fq.
$$

For $\alpha\le0.2$, $\eta\le1$, this gives $\theta\le0.804<1$.
At $\alpha=0.25$, the sufficient bound is approximately 1.0482 and does not establish
stepwise progress, although the finite-sweep bound still holds. A failing sufficient estimate
is not a counterexample to progress. Likewise, contraction of the sweep defect is a separate
consequence of state contraction, not a replacement for the force-residual argument.

# Numerical behavior and limits of the bounds

The [experiment module](../../experiments/applicability/study.py) executes nonlinear VBD
sweeps and measures all four observables; an independent full Newton solve supplies a reference
root. Its [README](../../experiments/applicability/README.md) gives runnable commands and
parameter definitions. The fixed study grid has 336 cases. All 192 cases in the stated
$\alpha\le0.25$, $\eta\le1$ range reach tolerance within six sweeps.
These floating-point observations complement the uniform analytic estimate.

[Tables](../../experiments/applicability/report.md),
[raw results](../../experiments/applicability/results.csv),
[trajectories](../../experiments/applicability/trajectories.csv), and
[run configuration](../../experiments/applicability/summary.json) make the results inspectable.
For 16 vertices, equal masses and stiffnesses, and $\eta=1$:

| $\alpha$ | Order | $\rho(DT(u^*))$ | $\|DT(u^*)\|_\infty$ | $\|DT(u^*)\|_2$ | Sweeps to tolerance |
|---|---|---|---|---|---|
| 0.25 | serial | 0.10825 | 0.20094 | 0.21061 | 6 |
| 0.25 | proper color | 0.10825 | 0.33420 | 0.34660 | 4 |
| 1 | serial | 0.43450 | 0.50043 | 0.55950 | 11 |
| 1 | proper color | 0.43450 | 0.66695 | 0.79445 | 11 |
| 10 | serial | 0.90192 | 0.90910 | 1.09641 | >20 |
| 10 | proper color | 0.90192 | 0.95238 | 1.36117 | >20 |
| 100 | serial | 0.98943 | 0.99010 | 1.21062 | >20 |
| 100 | proper color | 0.98943 | 0.99502 | 1.47277 | >20 |

At the root, changed derivative rows are nonnegative, so absolute-factor comparison introduces
no cancellation loss. Off-root variation terms can have either sign; triangle inequalities
and independent maxima then introduce conservatism. The maximum-norm bound is independent
of chain length, but depends on incident coupling. Euclidean transport obeys

$$
\|v\|_\infty\le\|v\|_2\le\sqrt n\,\|v\|_\infty.
$$

A one-step norm conversion can therefore destroy contraction (already at $n=16$ for the
endpoint bound), whereas conversion of the final state-error estimate costs only $\sqrt n$.
A weighted comparison vector or energy norm can sharpen some estimates. Several-sweep
contraction can also handle a one-step norm above one. None of these changes makes a fixed
20-sweep tolerance hold on a trajectory that actually misses it.
For the quadratic family the global bound $q_0=2\alpha/(1+2\alpha)$ is available, but
it also becomes slow at large $\alpha$.

Two exact examples distinguish convergence properties. For two quadratic vertices with
$a_i=1$, $b=10$, $y=0$, and $u=(r,r)$, a serial sweep gives

$$
T(u)=\left(\frac{10r}{11},\frac{100r}{121}\right),
\qquad r_{\mathrm{IE}}(u)=r,
\qquad r_{\mathrm{IE}}(T(u))=\frac{210r}{121}>r\quad(r>0).
$$

Thus global state contraction can coexist with physical-residual increases. For an
objective-increasing example, take $a_i=b=1$, $\eta=100$, $y=(1,-1)$, and
$u=(0,0)$. The first update gives $U_0(u)=(1/2,0)$, with

$$
G(u)=1,\qquad G(U_0(u))=\frac{37}{16}>1.
$$

This second example is outside the certified box and nonlinear parameter range. The local
convergence result makes no claim about convergent objective-increasing trajectories.

# Planned formalization modules

The argument factors through the existing foundations and planned bridges in the
[module map](/formalization/module-map.md):

| Mathematical step | Module | Generic result and instance data |
|---|---|---|
| IE objective and derivatives | `Integrator/ImplicitEulerEnergy` | Existing basis-free identities; spring potential supplies the instance |
| Writes, composition, block derivatives | `Block/Basic`, `Block/Update`, `Block/Operator` | Existing heterogeneous block algebra |
| Invariant-set convergence and finite iterates | `Dynamics/Contraction` | Existing contraction core; CT-04 adds the derivative bridge |
| Local interactions and proper colors | `Integrator/LocalInteractions` | Finite-support theory; the path supplies a concrete coloring |
| Distance-to-physical-residual transport | `Integrator/FixedPoint` | Solver-independent result with supplied residual regularity |
| Ordered comparison estimates | `Block/Contraction` | Generic block maximum-norm bound |
| Concrete update and parameter bounds | `Integrator/VBD` | General Newton update and consistency, then chain inverse/box/budget lemmas |

The scalar law and degree-two constants enter through instance lemmas. The derivative,
composition and convergence statements retain block spaces and physical bound data as parameters.

# Reuse beyond the chain

## General block estimate

For a residual $R_i(x)$ and invertible local solve operator $K_i(x)$, the update
changes block $i$ to $x_i-K_i(x)^{-1}R_i(x)$. Its derivative in block direction $v_j$ is

$$
(DU_i)_{ij}[v_j]=\delta_{ij}v_j-K_i^{-1}D_jR_i[v_j]
 +K_i^{-1}\bigl(D_jK_i[v_j]\bigr)K_i^{-1}R_i.
$$

For exact Newton blocks, $K_i=D_iR_i$, the diagonal cancellation gives the sufficient bound

$$
\sum_{j\ne i}\|K_i^{-1}D_jR_i\|
 +\|K_i^{-1}\|\,\|K_i^{-1}R_i\|\sum_j\|D_jK_i\|\le q<1.
$$

These are operator and block-vector norms, with state norm $\max_i\|x_i\|$.
Uniform estimates and intermediate-state invariance let the same ordered-composition proof
apply in any block dimension. An approximate solve matrix contributes the additional term
$\|I-K_i^{-1}D_iR_i\|$; it can persist even at a root. Root consistency still follows
from invertibility and once-per-block execution, but the exact Gauss–Seidel identification
requires exact derivative blocks.

## Vector springs and general graphs

An explicit vector extension takes $u_i\in\mathbb R^d$ on a finite simple graph and uses

$$
G(u)=\frac12\sum_i a_i\|u_i-y_i\|^2
 +\sum_{e=\{i,j\}}b_e\left(\frac{\|u_i-u_j\|^2}{2}
                           +\frac{\eta\|u_i-u_j\|^4}{4}\right).
$$

The quartic term couples vector components. This displacement-difference model is distinct
from geometric springs with nonzero rest length based on actual vertex separation.
Put

$$
z=\max_i\frac{\sum_{e\ni i}b_e}{a_i}
 =\max_i\frac{h^2\sum_{e\ni i}k_e}{m_i}
 \le\Delta\frac{h^2k_{\max}}{m_{\min}},
$$

where $\Delta$ is maximum graph degree. Connectivity enters through incident stiffness.
For an edge displacement $d_e$, its Hessian and variation obey

$$
H_e=b_e[(1+\eta\|d_e\|^2)I+2\eta d_ed_e^\mathsf T],
\qquad
\|DH_e[\delta d_e]\|\le6b_e\eta\|d_e\|\,\|\delta d_e\|.
$$

On the product of radius-$B$ balls, local inverse and variation bounds give

$$
\begin{aligned}
P(z)&=B+Y+2Bz(1+4\eta B^2),\\
q_{\mathrm{vec}}&\le\frac{z(1+12\eta B^2)}{1+z}
             +\frac{24\eta BzP(z)}{(1+z)^2}.
\end{aligned}
$$

For intermediate-state invariance, expand

$$
K_iu_i-R_i=a_iy_i+\sum_{j\sim i}b_{ij}
 [(1+\eta\|d_{ij}\|^2)u_j+2\eta d_{ij}\langle d_{ij},u_i\rangle].
$$

The numerator norm is at most $a_iY+\sum_jb_{ij}(B+12\eta B^3)$, while
$K_i\succeq(a_i+\sum_jb_{ij})I$. Hence $12\eta B^3z\le B-Y$ suffices.
Strong convexity gives a unique root; taking the inner product of its equation with a
largest-norm coordinate gives $\max_i\|u_i^*\|\le Y$.
At $B=0.1$, $Y=0.05$, $\eta\le1$, and $z\le0.5$,

$$
q_{\mathrm{vec}}\le0.5088<0.512,
\qquad L_F\le1+2z(1+12\eta B^2)\le2.12.
$$

The same 20-sweep bound follows for the vector residual
$r_{\mathrm{IE}}(u)=\max_i\|R_i(u)\|/a_i$, in 2D, 3D, or any finite dimension.
This is an analytic extension; the experiment module executes the scalar chain.

## Geometric elasticity and higher-arity elements

Triangle, tetrahedron, or geometric spring energies reuse interaction support, coloring,
block differentiation, and comparison composition. Each constitutive law must provide local
inverse, mixed-derivative and variation bounds on a specified deformation region. A template is

$$
H_{ii}(x)\succeq\left(\frac{m_i}{h^2}-\kappa_i\right)I,
\qquad \frac{m_i}{h^2}>\kappa_i,
$$

when potential curvature has lower bound $-\kappa_i I$. Contraction additionally needs
mixed-block bounds. Near collapsed elements, derivative variation may become unbounded.
Scalar maximum principles and sign arguments do not automatically extend to these materials;
root existence, predictor membership and quantitative residual transport need appropriate replacements.
The singularity test also becomes dimension-dependent and must retain its physical units.

## Damping, contact, and friction

Smooth added forces can enter the same residual/update interface through their contributions
to inverse, coupling and variation bounds. Linear viscous damping with a symmetric
positive-semidefinite matrix $C$ contributes $C/h$ to the position-residual derivative
because $v^{\mathrm{new}}=(x^{\mathrm{new}}-x^{\mathrm{old}})/h$.
Off-diagonal damping can increase coupling as well as diagonal control.

A fixed smooth contact branch admits the same derivative analysis. Activation boundaries need
a direct Lipschitz or suitable piecewise argument. Live contacts can invalidate material
coloring, requiring the actual buffered-map estimate in BC-04. Lagged contact data or changing
schedules require an augmented state or a varying-map theorem.

The [VBD paper, §§3.5–3.6](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
uses regularized friction and approximate local derivatives, including frozen-normal treatment.
Its analysis must differentiate the actual update, specifying frozen quantities and retaining
the $K_i$ mismatch terms above. A fixed-data friction potential can support a conditional
result; identifying its root with the fully coupled physical equation is another obligation.
Ideal sticking/sliding laws can instead need a nonsmooth inclusion or complementarity solution
concept. Block algebra and metric contraction remain reusable, while the smooth derivative bridge
and energy-gradient interpretation may need new results. A CT-05 perturbation theorem requires
an actual error bound and region preservation; friction is not automatically a small perturbation.
