"""One-timestep scalar VBD experiment; run with ``uv run python -m study``."""
import argparse
import csv
import itertools
import json
import math
import sys
from pathlib import Path

import numpy as np

PRESETS = {
    "quick": dict(n=[16], alpha=[0.1, 0.25, 10.0], mass_ratio=[1.0],
                  stiffness_ratio=[1.0], eta=[0.0, 1.0], mode=["serial", "color"]),
    "study": dict(n=[4, 16, 64], alpha=[0.01, 0.1, 0.2, 0.25, 1.0, 10.0, 100.0],
                  mass_ratio=[1.0, 1000.0], stiffness_ratio=[1.0, 10000.0],
                  eta=[0.0, 1.0], mode=["serial", "color"]),
}


def certificate(alpha, eta, radius=0.1, amplitude=0.05):
    """Uniform scalar bound; invariance and skip conditions are checked by run_case."""
    s = 2 * alpha * (1 + 12 * eta * radius**2)
    p = radius + amplitude + 4 * alpha * radius * (1 + 4 * eta * radius**2)
    q = s / (1 + s) + 48 * alpha * eta * radius * p / (1 + 2*alpha)**2
    lip = 1 + 4 * alpha * (1 + 12 * eta * radius**2)
    return q, lip


def model(n, alpha, ratio, contrast, eta, amplitude=0.05):
    a = np.where(np.arange(n) % 2, ratio, 1.0)
    k = alpha * np.where(np.arange(n-1) % 2, 1 / contrast, 1.0)
    y = amplitude * np.cos(np.arange(n) * 1.7)
    def evaluate(x):
        d = x[:-1] - x[1:]
        f = a * (x-y)
        force = k * (d + eta*d**3)
        f[:-1] += force
        f[1:] -= force
        w = k * (1 + 3*eta*d*d)
        h = np.diag(a.copy())
        for i, wi in enumerate(w):
            h[i,i] += wi
            h[i+1,i+1] += wi
            h[i,i+1] = h[i+1,i] = -wi
        energy = np.dot(a, (x-y)**2)/2 + np.sum(k*(d*d/2+eta*d**4/4))
        return f, h, float(energy)
    def sweep(x, mode, threshold=1e-12):
        z = x.copy()
        jac = np.eye(n)
        comp = np.eye(n)
        batches = [[i] for i in range(n)] if mode == 'serial' else [list(range(c,n,2)) for c in range(2)]
        max_increase = 0.0
        for batch in batches:
            f,h,e = evaluate(z)
            rows = np.eye(n)
            zz = z.copy()
            for i in batch:
                if abs(h[i,i]) <= threshold:
                    continue
                zz[i] -= f[i]/h[i,i]
                dh = np.zeros(n)
                for j in (i-1,i+1):
                    if 0 <= j < n:
                        v = 6*k[min(i,j)]*eta*(z[i]-z[j])
                        dh[i] += v
                        dh[j] -= v
                rows[i] -= h[i]/h[i,i]
                rows[i] += f[i]*dh/h[i,i]**2
            jac = rows @ jac
            comp = abs(rows) @ comp
            max_increase = max(max_increase, evaluate(zz)[2]-e)
            z = zz
        return z, jac, comp, max_increase
    return a, y, evaluate, sweep


def reference_root(y, evaluate):
    """Independent full Newton reference solve; never advances a VBD trajectory."""
    root = y.copy()
    for _ in range(100):
        f, h, _ = evaluate(root)
        step = np.linalg.solve(h, f)
        root -= step
        if np.max(abs(step)) < 1e-14:
            break
    return root


def run_case(case, args):
    n, alpha, ratio, contrast, eta, mode = case
    a, y, evaluate, sweep = model(n, alpha, ratio, contrast, eta, args.amplitude)
    root = reference_root(y, evaluate)
    if not np.all(np.isfinite(root)) or np.max(abs(evaluate(root)[0]/a)) >= 1e-10:
        raise ValueError(f"reference Newton solve failed for {case}")
    # Use the requested skip semantics for both trajectory and derivative diagnostics.
    def advance(x):
        return sweep(x, mode, args.threshold)
    _, jac, comparison, _ = advance(root)
    q, lip = certificate(alpha, eta, args.radius, args.amplitude)
    lower_diagonal = np.diag(evaluate(np.zeros(n))[1])
    valid = bool(q < 1 and args.threshold < min(lower_diagonal)
                 and 24*alpha*eta*args.radius**3 <= args.radius-args.amplitude)
    if not all(map(math.isfinite, [q, lip])):
        raise ValueError(f"non-finite certificate estimate for {case}")
    initial = dict(n=n, alpha=alpha, mass_ratio=ratio, stiffness_ratio=contrast, eta=eta, mode=mode)
    x = y.copy()
    trajectory = []
    hit = None
    max_ratio = max_increase = 0.0
    for t in range(args.sweeps+1):
        f, _, energy = evaluate(x)
        residual = float(max(abs(f/a)))
        z, _, _, increase = advance(x)
        error = float(max(abs(x-root)))
        defect = float(max(abs(z-x)))
        if not all(map(math.isfinite, [energy, residual, error, defect])):
            raise ValueError(f"non-finite trajectory for {case} at sweep {t}")
        if residual <= args.tolerance and hit is None:
            hit = t
        bound = lip*2*args.amplitude*q**t if valid else None
        trajectory.append(dict(**initial, sweep=t, state=error, residual=residual,
                               defect=defect, energy=energy, residual_bound=bound))
        # The terminal lookahead computes the defect but is outside the requested budget.
        if t < args.sweeps:
            if residual > 1e-12:
                max_ratio = max(max_ratio, float(max(abs(evaluate(z)[0]/a)))/residual)
            max_increase = max(max_increase, increase)
            x = z
    hr = evaluate(root)[1] / a[:, None]
    residual_jac = hr @ jac @ np.linalg.inv(hr)
    row = dict(**initial, rho=float(max(abs(np.linalg.eigvals(jac)))),
               norm_inf=float(np.linalg.norm(jac, np.inf)), norm_2=float(np.linalg.norm(jac, 2)),
               comparison_inf=float(np.linalg.norm(comparison, np.inf)),
               comparison_2=float(np.linalg.norm(comparison, 2)),
               residual_derivative_inf=float(np.linalg.norm(residual_jac, np.inf)),
               q_bound=q, theta_bound=lip*q, certificate_valid=valid,
               bound_final=trajectory[-1]['residual_bound'], residual_final=residual,
               state_final=error, first_tolerance=hit,
               max_residual_ratio=max_ratio, max_energy_increase=max_increase)
    return row, trajectory


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                    formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--preset', choices=PRESETS, default='quick', help='parameter grid')
    parser.add_argument('--n', type=int, nargs='+', help='numbers of vertices (at least 2)')
    for name in ('alpha', 'mass-ratio', 'stiffness-ratio', 'eta'):
        parser.add_argument('--'+name, type=float, nargs='+', help='override this grid axis')
    parser.add_argument('--mode', choices=['serial', 'color'], nargs='+', help='execution orders')
    parser.add_argument('--sweeps', type=int, default=20, help='number of complete VBD sweeps')
    parser.add_argument('--tolerance', type=float, default=1e-6, help='scaled physical residual target')
    parser.add_argument('--amplitude', type=float, default=0.05, help='inertia predictor amplitude Y')
    parser.add_argument('--radius', type=float, default=0.1, help='certificate box radius B')
    parser.add_argument('--threshold', type=float, default=1e-12, help='normalized scalar skip threshold')
    parser.add_argument('--output', type=Path, default=Path('runs/latest'), help='output directory; files replaced on rerun')
    parser.add_argument('--table-limit', type=int, default=24, help='terminal rows (0 prints all); report contains all cases')
    parser.add_argument('--plot-cases', type=int, default=6, help='plot stress cases and up to two cases meeting the analytic budget (1–12)')
    parser.add_argument('--no-plots', action='store_true', help='write only tables and numeric data')
    args = parser.parse_args(argv)
    for key, default in PRESETS[args.preset].items():
        values = getattr(args, key)
        setattr(args, key, list(dict.fromkeys(default if values is None else values)))
    if any(n < 2 for n in args.n):
        parser.error('--n values must be at least 2')
    for key in ('alpha', 'mass_ratio', 'stiffness_ratio', 'eta'):
        values = getattr(args, key)
        lower = 1 if key in ('mass_ratio', 'stiffness_ratio') else 0
        if any(not math.isfinite(v) or v < lower or (key == 'alpha' and v == 0) for v in values):
            parser.error(f'invalid --{key.replace("_", "-")} values')
    for key in ('tolerance', 'radius', 'amplitude', 'threshold'):
        v = getattr(args, key)
        if not math.isfinite(v) or v < 0 or (key in ('tolerance', 'radius') and v == 0):
            parser.error(f'invalid --{key}')
    if args.amplitude > args.radius:
        parser.error('--amplitude must not exceed --radius')
    if args.sweeps < 0 or args.table_limit < 0 or not 1 <= args.plot_cases <= 12:
        parser.error('sweeps/table-limit must be nonnegative and plot-cases between 1 and 12')
    return args


def table(rows):
    headings = ['case', 'n', 'alpha', 'eta', 'mass', 'stiffness', 'order', 'rho', 'norm_inf', 'q', 'cert', 'hit', 'residual']
    cells = [[str(i+1), str(r['n']), f"{r['alpha']:g}", f"{r['eta']:g}",
              f"{r['mass_ratio']:g}", f"{r['stiffness_ratio']:g}", r['mode'],
              f"{r['rho']:.4f}", f"{r['norm_inf']:.4f}", f"{r['q_bound']:.4f}",
              'yes' if r['certificate_valid'] else 'no',
              '—' if r['first_tolerance'] is None else str(r['first_tolerance']),
              f"{r['residual_final']:.3e}"] for i, r in enumerate(rows)]
    widths = [max(len(h), *(len(row[j]) for row in cells)) for j, h in enumerate(headings)]
    def line(row):
        return '| ' + ' | '.join(v.ljust(w) for v, w in zip(row, widths)) + ' |'
    return '\n'.join([line(headings), line(['-'*w for w in widths]), *(line(row) for row in cells)])


def plot(rows, trajectories, args):
    # Agg works on headless hosts. Cache lives with ignored/generated outputs.
    import os
    os.environ.setdefault('MPLCONFIGDIR', str(args.output.resolve()/'.matplotlib'))
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.ticker import MaxNLocator
    hardest = sorted(range(len(rows)), key=lambda i: rows[i]['residual_final'], reverse=True)
    guaranteed = [i for i in hardest if rows[i]['bound_final'] is not None
                  and rows[i]['bound_final'] <= args.tolerance]
    guaranteed.sort(key=lambda i: rows[i]['first_tolerance'] or 0, reverse=True)
    # Keep the supported regime visible even when the stress grid dominates the ranking.
    chosen = guaranteed[:min(2, args.plot_cases//2)]
    chosen += [i for i in hardest if i not in chosen][:args.plot_cases-len(chosen)]
    fig, axes = plt.subplots(2, 2, figsize=(12, 9))
    for i in chosen:
        r = rows[i]
        data = trajectories[i]
        label = f"#{i+1}: n={r['n']}, α={r['alpha']:g}, η={r['eta']:g}, m={r['mass_ratio']:g}, k={r['stiffness_ratio']:g}, {r['mode']}"
        for ax, key, title in zip(axes.flat, ['residual', 'state', 'defect', 'energy'],
                                 ['Physical residual', 'State error', 'Sweep defect', 'Objective']):
            values = [d[key] for d in data]
            line, = ax.plot([d['sweep'] for d in data], values if key == 'energy' else np.maximum(values, 1e-18), label=label)
            if key == 'residual' and r['bound_final'] is not None and r['bound_final'] <= args.tolerance:
                ax.plot([d['sweep'] for d in data], np.maximum([d['residual_bound'] for d in data], 1e-18),
                        color=line.get_color(), linestyle=':', linewidth=1)
            ax.set(xlabel='Complete sweeps', ylabel=title)
            if key != 'energy':
                ax.set_yscale('log')
            ax.xaxis.set_major_locator(MaxNLocator(integer=True))
            ax.grid(alpha=0.25)
    axes[0, 0].axhline(args.tolerance, color='black', linestyle='--', linewidth=1)
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc='lower center', fontsize=8)
    fig.suptitle('VBD trajectories — supported and stress cases\nDotted: residual bounds; dashed: target; logarithmic plotting floor: 1e−18')
    fig.tight_layout(rect=(0, min(0.32, 0.04+0.025*len(chosen)), 1, 0.94))
    fig.savefig(args.output/'convergence.png', dpi=140)
    plt.close(fig)
    return [i+1 for i in chosen]


def main(argv=None):
    args = parse_args(argv)
    grid = itertools.product(args.n, args.alpha, args.mass_ratio, args.stiffness_ratio, args.eta, args.mode)
    rows, trajectories = [], []
    try:
        for case in grid:
            row, trajectory = run_case(case, args)
            rows.append(row)
            trajectories.append(trajectory)
    except (ValueError, np.linalg.LinAlgError, OverflowError) as error:
        raise SystemExit(f'experiment failed: {error}') from error
    args.output.mkdir(parents=True, exist_ok=True)
    for name, data in [('results.csv', rows), ('trajectories.csv', list(itertools.chain.from_iterable(trajectories)))]:
        with (args.output/name).open('w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=data[0].keys(), lineterminator='\n')
            writer.writeheader()
            writer.writerows(data)
    certified = [r for r in rows if r['certificate_valid']]
    summary = dict(config={k: str(v) if isinstance(v, Path) else v for k, v in vars(args).items()},
                   python=sys.version.split()[0], numpy=np.__version__, cases=len(rows),
                   certificate_valid_cases=len(certified),
                   bound_meets_tolerance=sum(r['bound_final'] is not None and r['bound_final'] <= args.tolerance for r in rows),
                   observed_meets_tolerance=sum(r['first_tolerance'] is not None for r in rows),
                   worst_residual_final=max(r['residual_final'] for r in rows),
                   residual_increase_cases=sum(r['max_residual_ratio'] > 1+1e-8 for r in rows))
    if not args.no_plots:
        summary['plotted_cases'] = plot(rows, trajectories, args)
        import matplotlib
        summary['matplotlib'] = matplotlib.__version__
    else:
        (args.output/'convergence.png').unlink(missing_ok=True)
    (args.output/'summary.json').write_text(json.dumps(summary, indent=2, allow_nan=False)+'\n')
    intro = (f"{len(rows)} cases; {args.sweeps} sweeps; residual target {args.tolerance:g}.\n"
             f"Uniform certificates: {len(certified)}; bounds meeting target: {summary['bound_meets_tolerance']}; "
             f"observed target hits: {summary['observed_meets_tolerance']}.\n")
    report = '# VBD applicability experiment\n\n'+intro+'\n'+table(rows)+'\n\n'
    report += ('`rho` and `norm_inf` are root-local derivative diagnostics. `q` is a box estimate; '
               '`cert` additionally checks invariance and the skip branch. `hit` is the first '
               'observed tolerance sweep (— means not reached). Floating-point results are not proofs.\n')
    if not args.no_plots:
        report += '\n![Convergence diagnostics](convergence.png)\n'
    (args.output/'report.md').write_text(report)
    print(intro)
    print(table(rows if args.table_limit == 0 else rows[:args.table_limit]))
    if args.table_limit and len(rows) > args.table_limit:
        print(f'\nShowing {args.table_limit}/{len(rows)} cases; complete table in report.md.')
    print(f'\nOutputs: {args.output.resolve()}')
    print('rho/norm_inf: at root; q: uniform candidate; cert: all region/skip checks; hit: observed sweep.')


if __name__ == '__main__':
    main()
