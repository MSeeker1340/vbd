---
type: Mathematical Specification
title: VBD Contraction for Coupled Axial Springs
description: Develops a coupled mechanical example from its implicit-Euler objective to a finite-sweep contraction bound and extensions to richer models.
tags: [applicability, vbd, contraction, residual, springs]
timestamp: 2026-09-15T00:00:00Z
---

In [implicit Euler as optimization](./implicit-euler.md), we turn one timestep into a force-balance
problem: the old position and velocity determine a prediction, and we seek a new configuration
where the incremental objective is stationary. In [block states and operators](./block-states-and-operators.md),
we organize the search into updates that move one part of the candidate configuration at a time.
We can now bring these two descriptions together and ask how much progress a complete VBD sweep makes.

Imagine holding the timestep fixed and watching the candidate positions change during the solve.
Moving one vertex changes the forces on its neighbors. Their subsequent updates respond to that
change, and the effect propagates through the sweep. To use
[fixed-point contraction](./contractive-fixed-point-iteration.md), we need to show that this
propagation reduces differences between candidate configurations. We also need to connect the
configuration where the iteration settles to the force balance we originally wanted to solve.

We will follow that argument for a chain of masses joined by elastic springs. The quadratic
spring law makes the mechanism visible: a vertex update averages its neighbors with the inertia
prediction. Nonlinear hardening then shows what additional control is needed when the local
stiffness changes during the solve. The result will be an explicit neighborhood, timestep range,
and number of sweeps sufficient for a physical-residual tolerance.

The estimates here are mathematical derivations awaiting Lean formalization. The accompanying
experiment checks the behavior of the actual nonlinear sweep. The
[project decision](/project/applicability-decision.md) records why this family is the first
formalization target and which broader applications remain open.

# Mechanical model

Picture a row of beads sliding along a straight frictionless rail, with a spring between each
neighboring pair. We can also view the beads as sample points of an elastic band constrained to
longitudinal motion. The rail leaves each bead one positional degree of freedom, and both ends
of the chain are free. Stretching or compressing a segment changes the forces on its two endpoints;
sliding the whole chain by the same amount leaves every spring extension unchanged.

We model those segments with a quadratic energy plus a hardening term. This is an idealized
elastic band: a real band's tension-only behavior and material calibration would need further
assumptions.

Let the rest spacing be $\ell>0$, and write the physical position of mass $i$ as
$x_i=x_i^{\mathrm{rest}}+\ell u_i$. The signed extension of an adjacent spring is
$\ell(u_i-u_j)$, up to orientation. For stiffness $k_e>0$, use the physical spring energy

$$
E_e(s)=\frac{k_e}{2}s^2+\frac{k_e\eta}{4\ell^2}s^4,
\qquad \eta\ge0.
$$

Setting $\eta=0$ gives a linear spring force. With $\eta>0$, the force grows more rapidly
as the segment stretches or compresses, and so does its stiffness. The two models share the same
neighbor relationships; their different derivatives will matter when we estimate the update.
This keeps the distinction between locality and curvature concrete.

To compare stiffness with inertia, it helps to express displacement in units of the rest spacing
and energy in units set by the timestep. For $h>0$, write

$$
y_i=\frac{x_i^{\mathrm{old}}+h v_i^{\mathrm{old}}+h^2a_i^{\mathrm{ext}}
                 -x_i^{\mathrm{rest}}}{\ell},
\qquad a_i=\frac{m_i}{m_{\min}}\ge1,
\qquad b_e=\frac{h^2k_e}{m_{\min}}.
$$

Here $y$ is the inertia prediction from the old state. The coefficient $a_i$ compares each mass
to the lightest one, while $b_e$ compares spring stiffness to the inertial scale $m_{\min}/h^2$.
In particular, reducing the timestep reduces every $b_e$. Dividing the implicit-Euler incremental
energy by $m_{\min}\ell^2/h^2$ gives

$$
G(u)=\frac12\sum_i a_i(u_i-y_i)^2
 +\sum_{e=\{i,j\}}b_e\left(\frac{d_e^2}{2}+\frac{\eta d_e^4}{4}\right),
\qquad d_e=u_i-u_j.
$$

The first term pulls each candidate position toward its prediction; the second couples it to
its neighbors. At $u=y$ the inertia contribution to the gradient is zero, but spring forces
generally remain. We therefore start at $u^0=y$ and let the VBD updates correct that imbalance.
This is a warm start we can construct before solving the new timestep.

# Forces, local solves, and sweeps

Hold every bead except bead $i$ fixed. VBD takes one Newton step for this single remaining
variable, using the current force imbalance and local stiffness. Write $f=\nabla G$,
$H=Df$, and $D_i=H_{ii}$. Differentiating the energy gives, for neighbors $j\sim i$,

$$
f_i(u)=a_i(u_i-y_i)+\sum_{j\sim i}b_{ij}(d_{ij}+\eta d_{ij}^3),
\qquad
D_i(u)=a_i+\sum_{j\sim i}b_{ij}(1+3\eta d_{ij}^2).
$$

The ratio $-f_i/D_i$ is the displacement that balances the local quadratic approximation.
Applying it to bead $i$, while preserving every other position, gives

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

For quadratic springs, we can see exactly what this step does. Substituting $\eta=0$ and
cancelling the old value of $u_i$ gives

$$
(U_i(u))_i=\frac{a_i y_i+\sum_{j\sim i}b_{ij}u_j}
                  {a_i+\sum_{j\sim i}b_{ij}}.
$$

The new position is a weighted average of the prediction and the neighboring candidates.
Compare two candidate configurations with the same prediction: only the neighbors contribute
to the difference between their updated positions. Some of the averaging weight belongs to the
fixed prediction, so the total sensitivity to neighbors is less than one. Stronger inertia
makes that sensitivity smaller. This is the contraction mechanism we will extend to the
nonlinear spring law.

A visit to the next bead must use the position we just computed. A serial sweep therefore
visits vertices $0,\ldots,n-1$ through the composition

$$
T_{\mathrm{serial}}=U_{n-1}\circ\cdots\circ U_0.
$$

For parallel execution, notice that updating an even bead cannot change the data needed by
another even bead: its neighbors are odd. We may update all even beads from one snapshot, then
all odd beads from the resulting snapshot. This is the chain's proper-color sweep.
The same-color updates commute, so the simultaneous/sequential equivalence from
[block states and operators](./block-states-and-operators.md#theorem-simultaneous-and-sequential-equivalence)
lets us treat each batch as any serial ordering of its members.
Both executions visit every vertex exactly once; we will use that fact twice below.

# Where the iteration should settle

Before estimating the speed of the iteration, we should identify its destination. The energy
in this example has enough curvature to give a unique force-balanced configuration. Its Hessian
is a positive diagonal inertia matrix plus a weighted path Laplacian:

$$
H(u)=\operatorname{diag}(a)+L_{w(u)},
\qquad w_e(u)=b_e(1+3\eta d_e^2)>0.
$$

The spring Laplacian is positive semidefinite, and the inertia diagonal is bounded below by
the identity. Consequently $G$ is coercive and strongly convex, with a unique stationary point
$u^*$. These are properties of this spring model; the generic implicit-Euler solution concept
still requires only stationarity.

We can locate $u^*$ without computing it. Take a bead whose displacement at the root is largest.
Every spring contribution to its gradient is nonnegative. Its inertia contribution must balance
that sum, so this displacement cannot exceed its own prediction. Applying the same argument to
the smallest displacement gives

$$
\min_i y_i\le u_j^*\le\max_i y_i,
\qquad \|u^*\|_\infty\le Y.
$$

This root is certainly fixed by VBD: every local force imbalance is zero. We also need the
converse, since convergence to a different fixed point would not solve the timestep.
Suppose a complete sweep returns its input unchanged. The first bead is written only once, so
its update must have been zero. The second visit therefore sees the original state and must
also make a zero update. Continuing through the order shows that every component of $f$ is zero.
The same reasoning applies to the proper-color order. Thus, on the skip-free branch,

$$
T(u)=u\quad\Longleftrightarrow\quad f(u)=0.
$$

The once-per-vertex condition rules out a later write undoing an earlier one. The skip-free
condition rules out a bead staying still merely because its solve was bypassed. For example,
with two masses, $a_i=b=1$, $\eta=0$, $y=(1,-1)$, $u=(0,0)$, and
$\varepsilon=2$, both updates skip despite nonzero force. Our bound $D_i\ge1$ and the
much smaller study threshold exclude that behavior. None of this identification of fixed
points has used contraction.

## Reading progress during a solve

If we know the reference solution, the most direct measure of progress is the state error
$e(u)=\|u-u^*\|_\infty$. A practical solve usually does not know that solution. It can,
however, evaluate the remaining force imbalance. We measure it with

$$
r_{\mathrm{IE}}(u)=\max_i\frac{|f_i(u)|}{a_i}
 =\max_i\frac{h^2|F_{\mathrm{IE},i}(x)|}{m_i\ell}.
$$

This scaling puts the residual in displacement units relative to $\ell$: a tolerance $\tau$
means $|F_{\mathrm{IE},i}|\le m_i\ell\tau/h^2$ for every mass. It gives us a physical
quantity to control after a prescribed number of sweeps.

We can also measure how far a sweep moves the candidate,

$$
r_T(u)=\|T(u)-u\|_\infty,
$$

and track the objective $G(u)$. These measurements answer different questions. A small movement
can reflect a weak update as well as a small force imbalance; the skipped example above makes
that distinction exact. Decreasing energy alone does not quantify the remaining distance
to the stationary point. We will first bound state error by contraction, then derive the
physical-residual bound from it. The experiment records all four quantities so that these
relationships can be inspected rather than assumed.

# A neighborhood preserved by every update

The quadratic average gives us a useful starting point: if the prediction and all neighbors
lie in an interval, the updated bead stays in that interval. With hardening, the Newton step
need not be an average, so we must establish a replacement for this property.

Leave some room around the predictor by taking $0\le Y\le B$ and
$\|y\|_\infty\le Y$. With $b_e\le\alpha=h^2k_{\max}/m_{\min}$, consider the box

$$
\mathcal C=\{u:\|u\|_\infty\le B\}.
$$

The margin $B-Y$ is the room available for the spring correction. We want every individual
visit to remain in this box: each visit's output is where the next derivative will be evaluated.
On the box, spring extensions satisfy $|d_{ij}|\le2B$. Expanding the Newton numerator makes
the departure from the quadratic average explicit:

$$
(U_i(u))_i=
\frac{a_i y_i+\sum_{j\sim i}b_{ij}
 [u_j+\eta d_{ij}^2(2u_i+u_j)]}
 {a_i+\sum_{j\sim i}b_{ij}(1+3\eta d_{ij}^2)}.
$$

The extra term contains three displacement factors. Bounding them by the box radius gives

$$
|(U_i(u))_i|\le\frac{a_iY+\sum_{j\sim i}b_{ij}(B+12\eta B^3)}
     {a_i+\sum_{j\sim i}b_{ij}}.
$$

Each bead has at most two neighbors, so their total contribution fits into the available
margin whenever

$$
24\alpha\eta B^3\le B-Y.
$$

Under this condition every visit preserves $\mathcal C$, and the same is true coordinatewise
for a proper-color batch. Smaller timesteps or weaker hardening reduce the required margin.
Shrinking $B$ and $Y$ proportionally helps too: the nonlinear correction scales cubically while
the margin scales linearly. We now have one common region in which to estimate every stage of
the sweep.

# From the derivative to contraction

Return to two nearby candidate configurations. For the quadratic average, their difference
passes to the updated bead only through its neighbors. In the nonlinear case, changing the
candidate also changes the stiffness used to divide the force imbalance. Differentiating the
actual Newton step captures both effects:

$$
(DU_i(u))_{ij}=\delta_{ij}-\frac{H_{ij}(u)}{D_i(u)}
              +\frac{f_i(u)\,\partial_jD_i(u)}{D_i(u)^2}.
$$

The first two terms give the familiar Newton cancellation on the diagonal and normalized
coupling off the diagonal. The final term measures the change in the local inverse stiffness,
multiplied by the force imbalance still present. It vanishes at the root, which explains why
the root linearization is especially simple. Decomposing $H(u^*)=D+L+R$ into diagonal,
strictly lower, and strictly upper parts in visit order gives

$$
DT(u^*)=-(D+L)^{-1}R,
$$

the Gauss–Seidel error matrix. This matrix helps explain the observed asymptotic rate, but our
warm start is not generally the root. To guarantee its progress, we must bound the additional
term throughout the box.

The resulting estimate has two parts: sensitivity to neighbors and sensitivity to changing
stiffness. For compactness, write

$$
\begin{aligned}
\nu&=2\alpha,& S&=\nu(1+12\eta B^2),\\
P&=B+Y+2B\nu(1+4\eta B^2),&
q&=\frac{S}{1+S}+\frac{24\eta B\nu P}{(1+\nu)^2}.
\end{aligned}
$$

Here $\nu$ bounds incident spring stiffness relative to inertia; $S$ also allows for the
largest hardening in the box. The first term of $q$, $S/(1+S)$, bounds the neighboring
sensitivities and plays the role of the averaging weight in the quadratic case. The second
term is the allowance for nonlinear variation. It is zero when $\eta=0$.

To see where that allowance comes from, use the actual local ratio
$\nu_i=\sum_j b_{ij}/a_i\le\nu$. The three quantities in the variation term satisfy

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

Keeping the denominator here matters: increasing spring stiffness increases the numerator,
but also the local stiffness by which we divide. To replace $\nu_i$ by its uniform bound,
observe that the derivative of $s(p+rs)/(1+s)^2$ has numerator
$p+(2r-p)s$, with $p=B+Y$ and $r=2B(1+4\eta B^2)$.
It is nonnegative because $Y\le B$.

There is still a small obstacle: a single vertex update leaves all other positions untouched,
so it cannot contract the entire state in the maximum norm. The improvement appears after a
complete sweep. Start with an upper bound on every component of a perturbation. The first
visit reduces its chosen component to at most $q$ times that bound. If $q<1$, none of the
components now exceeds the original bound, so the same argument applies to the second visit.
Continuing through the sweep reduces every component, and no vertex is written again.

This is the ordered comparison-matrix argument expressed in terms of the perturbation it
tracks. It applies to the proper-color ordering too. Integrating the derivative estimate
between any two points of the convex box gives

$$
\|T(u)-T(v)\|_\infty\le q\|u-v\|_\infty,
\qquad u,v\in\mathcal C.
$$

We can now apply the generic contraction theorem on the complete closed box. Its iterates
approach a unique fixed point there, and our earlier consistency argument identifies that point
with the implicit-Euler solution. The physical model has supplied the hypotheses; the remaining
iteration estimate is the one already furnished by fixed-point theory.

# Finite-sweep bounds and physical scales

We can put numbers into the estimate without first running the solver. Take a predictor range
$Y=0.05$, leave twice that range for intermediate states by setting $B=0.1$, and allow
$0\le\eta\le1$ with $\alpha\le1/4$. The box-preservation condition holds, and we obtain

$$
q\le0.494442<0.512,
\qquad
L_F=1+4\alpha(1+12\eta B^2)\le2.12.
$$

The constant $L_F$ translates state error into force imbalance: integrating the Hessian from
the root to the candidate gives $r_{\mathrm{IE}}(u)\le L_F\|u-u^*\|_\infty$.
Both the predictor and the root lie within $Y$ of the rest configuration, so their initial
separation is at most $2Y=0.1$. Using the convenient common factor $0.512$, we get

$$
\|T^s(y)-u^*\|_\infty\le0.1(0.512)^s,
\qquad
r_{\mathrm{IE}}(T^s(y))\le0.212(0.512)^s.
$$

After 20 sweeps the physical-residual bound is below $3.25\times10^{-7}$, meeting the
$10^{-6}$ target. We do not need to know $u^*$ to check that the warm start is covered:
the predictor condition is stated using the old timestep data. The box also contains a
radius-$0.05$ maximum-norm ball around the root. A different start anywhere in the box remains
covered by contraction, with the larger initial error allowance $B+Y=0.15$.

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

The finite-sweep estimate ensures a small residual at the chosen budget. A stronger demand is
that the residual improve after every sweep. For this chain, we can relate residual back to
state error as well: at a coordinate of largest absolute error, the signed Laplacian contribution
to $f(u)-f(u^*)$ is nonnegative. Thus $\|u-u^*\|_\infty\le r_{\mathrm{IE}}(u)$.
Combining the two directions of comparison with contraction gives

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

We can compare the guarantee with what the iteration actually does. The
[experiment module](../../experiments/applicability/study.py) recomputes the nonlinear forces
and local stiffnesses at every visit, then applies the full VBD step. An independent full
Newton solve supplies a reference root for measuring state error; it does not drive the VBD
trajectory. Its [README](../../experiments/applicability/README.md) gives runnable commands and
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

Read the table across both timestep regimes. At $\alpha=0.25$, the observed counts fit
comfortably inside the 20-sweep guarantee. At $\alpha=1$, these particular trajectories still
meet the budget beyond the range of our nonlinear 20-sweep guarantee. By $\alpha=10$, both orders
miss the target: the derivative's spectral radius is below one, but the decay is too slow for
the requested budget. A local convergence indication and a useful finite-budget guarantee
are different pieces of information.

The table also helps locate conservatism. At the root, changed derivative rows are nonnegative,
so taking absolute values of the factors loses no cancellation in this model. Off-root variation terms can have either sign; triangle inequalities
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

# Connection to the formalization

The argument follows the same separation as the earlier articles. The spring objective
instantiates `Integrator/ImplicitEulerEnergy`, and the vertex visits use the algebra in
`Block/Basic`, `Block/Update`, and `Block/Operator`. Those foundations do not need to know the
numerical range used in this example.

The new work lies at their boundaries. `Integrator/LocalInteractions` supplies the reason
same-color visits commute. `Block/Contraction` turns local derivative bounds into a bound for
the ordered sweep, and the CT-04 extension of `Dynamics/Contraction` connects that derivative
bound to metric contraction. `Integrator/FixedPoint` then transports the state estimate to the
physical residual. Finally, `Integrator/VBD` supplies the actual Newton update, its consistency
argument, and the spring-specific inverse and neighborhood estimates.

This places the reusable reasoning where another material model can use it. The chain provides
the coefficients and proves that they satisfy the hypotheses; it does not specialize the block
algebra or fixed-point theorem to one-dimensional springs. The
[module map](/formalization/module-map.md) records the implementation boundaries.

# Reuse beyond the chain

## General block estimate

To move beyond the rail, first separate the parts of the argument that used scalar signs from
those that only used norms and composition. The local derivative belongs to the latter group.
Replace the scalar force by a block residual $R_i(x)$ and the scalar stiffness by an invertible
operator $K_i(x)$. The update still subtracts a local solve,
$x_i-K_i(x)^{-1}R_i(x)$, and differentiation gives

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

We can test this reuse with a concrete extension before tackling general materials. Allow each
vertex displacement to be a vector $u_i\in\mathbb R^d$, and connect vertices by any finite
simple graph. Using the length of the displacement difference in the same spring energy gives

$$
G(u)=\frac12\sum_i a_i\|u_i-y_i\|^2
 +\sum_{e=\{i,j\}}b_e\left(\frac{\|u_i-u_j\|^2}{2}
                           +\frac{\eta\|u_i-u_j\|^4}{4}\right).
$$

The quartic term now couples the components within a vertex as well as neighboring vertices.
It therefore exercises an actual block solve. This energy measures differences of displacements;
it remains distinct from a geometric spring law based on the current distance between vertices
and a nonzero rest length.

The path's degree-two bound has to change. A vertex with more incident springs receives more
coupling during its update. The corresponding parameter is

$$
z=\max_i\frac{\sum_{e\ni i}b_e}{a_i}
 =\max_i\frac{h^2\sum_{e\ni i}k_e}{m_i}
 \le\Delta\frac{h^2k_{\max}}{m_{\min}},
$$

where $\Delta$ is maximum graph degree. This shows how the same estimate can cover a larger
graph: control total incident stiffness relative to each mass, rather than counting the total
number of vertices. For an edge displacement $d_e$, the derivatives we need are

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

We therefore recover the same 20-sweep physical-residual bound, now with
$r_{\mathrm{IE}}(u)=\max_i\|R_i(u)\|/a_i$. Nothing in these constants depends on whether
the vectors have two or three components. The price of extra connectivity is already visible
in $z$. This is a concrete analytic extension of the argument; the numerical experiment still
executes the scalar chain.

## Geometric elasticity and higher-arity elements

For an elastic triangle or tetrahedron, the algebraic part still looks familiar: an element
couples its incident vertices, and a visit solves for one vertex while holding the others fixed.
What changes is the dependence of the force on deformation. We can reuse support, coloring,
block differentiation, and ordered comparison, but must obtain new inverse, mixed-derivative
and variation estimates from the element's constitutive law.

Inertia can still help even when some potential curvature is negative. For example, a lower
bound $-\kappa_i I$ on the local potential curvature gives

$$
H_{ii}(x)\succeq\left(\frac{m_i}{h^2}-\kappa_i\right)I,
\qquad \frac{m_i}{h^2}>\kappa_i.
$$

This controls the inverse local solve, but says nothing yet about the influence of neighboring
vertices. That influence needs mixed-block bounds. Likewise, a neighborhood that includes a
collapsed element may have no useful variation bound. The scalar maximum principle that located
the chain's root is another step to revisit: general matrix-valued elasticity does not have its
sign structure. These are the physical estimates a new material must supply before the generic
sweep theorem yields a useful guarantee. Its singularity test must also be interpreted in the
new block dimension and physical units.

## Damping, contact, and friction

Adding a smooth force means revisiting the same local estimates. Linear viscous damping is
a simple illustration: substituting
$v^{\mathrm{new}}=(x^{\mathrm{new}}-x^{\mathrm{old}})/h$ gives a contribution $C/h$
to the position-residual derivative for a symmetric positive-semidefinite damping matrix $C$.
This may strengthen the local diagonal, but off-diagonal damping also couples updates. We
must account for both effects before concluding that the solver becomes more contractive.

Contact introduces a second difficulty: the force law and the read dependencies can change
as vertices move. On one fixed smooth contact branch we can perform the same differentiation.
Across activation boundaries we need a direct Lipschitz or suitable piecewise argument.
A new contact may also join two vertices that share a material color, removing the independence
that justified their simultaneous updates. We then need the actual buffered-map estimate in
BC-04. If contact data is lagged, two identical position vectors can produce different updates
depending on that data; a fixed-map analysis must include it in the state or be replaced by a
varying-map theorem.

The [VBD paper, §§3.5–3.6](https://graphics.cs.utah.edu/research/projects/vbd/vbd-siggraph2024.pdf)
uses regularized friction and approximate local derivatives, including frozen-normal treatment.
This brings us back to the distinction between the residual and the matrix used to solve it:
we must differentiate the actual update, specifying which quantities are frozen and retaining
the $K_i$ mismatch terms above. A fixed-data friction potential can give a conditional result,
but we still have to identify its root with the intended fully coupled physical equation.
Ideal sticking/sliding laws can instead need a nonsmooth inclusion or complementarity solution
concept. Block algebra and metric contraction remain reusable, while the smooth derivative bridge
and energy-gradient interpretation may need new results. A CT-05 perturbation theorem requires
an actual error bound and region preservation; friction is not automatically a small perturbation.
