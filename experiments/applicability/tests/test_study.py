"""Mathematical and CLI regression checks for the experimental module."""
import contextlib
import csv
from fractions import Fraction as Q
import io
import json
from pathlib import Path
import tempfile
import unittest

import numpy as np
from experiments.applicability import study


class StudyTests(unittest.TestCase):
    def test_quadratic_sweep_is_gauss_seidel(self):
        n = 6
        a, y, evaluate, sweep = study.model(n, 0.7, 3, 2, 0)
        h = evaluate(y)[1]
        root = np.linalg.solve(h, a*y)
        x = np.linspace(-0.04, 0.03, n)
        for mode in ['serial', 'color']:
            order = list(range(n)) if mode == 'serial' else list(range(0, n, 2))+list(range(1, n, 2))
            hp = h[np.ix_(order, order)]
            gp = -np.linalg.solve(np.tril(hp), np.triu(hp, 1))
            g = np.zeros((n, n))
            g[np.ix_(order, order)] = gp
            z, jac, comp, _ = sweep(x, mode)
            np.testing.assert_allclose(z, root+g@(x-root), atol=1e-14)
            np.testing.assert_allclose(jac, g, atol=1e-14)
            np.testing.assert_allclose(comp, g, atol=1e-14)

    def test_nonlinear_derivative_away_from_root(self):
        _, y, _, sweep = study.model(4, 0.25, 1, 2, 1)
        x = y + np.array([0.02, -0.01, 0.01, -0.02])
        eps = 1e-6
        for mode in ['serial', 'color']:
            fd = np.column_stack([(sweep(x+eps*e, mode)[0]-sweep(x-eps*e, mode)[0])/(2*eps)
                                  for e in np.eye(4)])
            np.testing.assert_allclose(sweep(x, mode)[1], fd, atol=1e-9)

    def test_exact_certificate_and_counterexamples(self):
        alpha, b, y, z = Q(1, 4), Q(1, 10), Q(1, 20), Q(1, 2)
        q, lip = study.certificate(alpha, Q(1), b, y)
        self.assertLess(q, Q(512, 1000))
        self.assertLess(lip*2*y*Q(512, 1000)**20, Q(1, 10**6))
        self.assertLessEqual(24*alpha*b**3, b-y)
        p = b+y+2*b*z*(1+4*b*b)
        q_vec = z*(1+12*b*b)/(1+z)+24*b*z*p/(1+z)**2
        self.assertEqual(q_vec, Q(318, 625))
        self.assertEqual(11*Q(10, 11)-10*Q(100, 121), Q(210, 121))
        self.assertEqual(Q(1, 2)*(Q(1, 4)+1)+Q(1, 8)+25*Q(1, 16), Q(37, 16))

    def test_invalid_cli_values(self):
        for argv in [['--n', '1'], ['--alpha', 'nan'], ['--eta', '-1'],
                     ['--sweeps', '-1'], ['--amplitude', '.2'], ['--mass-ratio', '.5']]:
            with self.subTest(argv=argv), contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    study.parse_args(argv)
                self.assertEqual(error.exception.code, 2)

    def test_custom_run_outputs_and_budget(self):
        with tempfile.TemporaryDirectory() as directory, contextlib.redirect_stdout(io.StringIO()):
            study.main(['--n', '4', '--alpha', '.25', '--eta', '1', '--mode', 'color',
                        '--sweeps', '3', '--tolerance', '1e-12', '--no-plots', '--output', directory])
            out = Path(directory)
            summary = json.loads((out/'summary.json').read_text())
            self.assertEqual(summary['cases'], 1)
            self.assertEqual(summary['config']['sweeps'], 3)
            with (out/'trajectories.csv').open() as f:
                data = list(csv.DictReader(f))
            self.assertEqual([int(r['sweep']) for r in data], [0, 1, 2, 3])
            self.assertTrue(all(float(r['residual']) <= float(r['residual_bound'])+1e-14 for r in data))
            self.assertTrue((out/'report.md').exists())
            self.assertFalse((out/'convergence.png').exists())

    def test_skip_is_not_reported_as_certificate(self):
        args = study.parse_args(['--threshold', '2', '--sweeps', '2'])
        row, data = study.run_case((2, 1.0, 1.0, 1.0, 0.0, 'serial'), args)
        self.assertFalse(row['certificate_valid'])
        self.assertIsNone(row['bound_final'])
        self.assertGreater(row['residual_final'], 0)
        self.assertTrue(all(r['defect'] == 0 for r in data))
        self.assertTrue(all(r['state'] == data[0]['state'] for r in data))


if __name__ == '__main__':
    unittest.main()
