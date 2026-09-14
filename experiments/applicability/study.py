"""Deterministic AP-01--AP-03 diagnostics; float64 evidence, not interval proofs."""
import csv
import json
from pathlib import Path
import numpy as np

OUT = Path(__file__).resolve().parent
B, Y, TOL, BUDGET = 0.1, 0.05, 1e-6, 20


def certificate(alpha, eta):
    s = 2 * alpha * (1 + 12 * eta * B**2)
    p = B + Y + 4 * alpha * B * (1 + 4 * eta * B**2)
    q = s / (1 + s) + 24 * alpha * eta * B * p
    lip = 1 + 4 * alpha * (1 + 12 * eta * B**2)
    return q, lip


def model(n, alpha, ratio, contrast, eta):
    a = np.where(np.arange(n) % 2, ratio, 1.0)
    k = alpha * np.where(np.arange(n-1) % 2, 1 / contrast, 1.0)
    y = Y * np.cos(np.arange(n) * 1.7)
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


def main():
    rows, trajectories = [], []
    max_fd = 0.0
    for n in (4,16,64):
      for alpha in (0.01,0.1,0.2,0.25,1.0,10.0,100.0):
       for ratio in (1.0,1000.0):
        for contrast in (1.0,10000.0):
         for eta in (0.0,1.0):
          a,y,ev,sw = model(n,alpha,ratio,contrast,eta)
          root = y.copy()
          for _ in range(100):
              f,h,_ = ev(root)
              step = np.linalg.solve(h,f)
              root -= step
              if np.max(abs(step)) < 1e-14:
                  break
          assert np.max(abs(ev(root)[0]/a)) < 1e-10
          for mode in ('serial','color'):
            _,j,c,_ = sw(root,mode)
            rho = float(max(abs(np.linalg.eigvals(j))))
            q,lip = certificate(alpha,eta)
            x = y.copy()
            max_ratio = max_increase = 0.0
            hit = None
            for t in range(BUDGET+1):
                f,h,e = ev(x)
                r = float(max(abs(f/a)))
                z,jx,cx,inc = sw(x,mode)
                err = float(max(abs(x-root)))
                defect = float(max(abs(z-x)))
                if r <= TOL and hit is None:
                    hit = t
                if r > 1e-12:
                    max_ratio = max(max_ratio,float(max(abs(ev(z)[0]/a)))/r)
                max_increase = max(max_increase,inc)
                if n == 16 and ratio == contrast == 1:
                    trajectories.append(dict(n=n,alpha=alpha,eta=eta,mode=mode,sweep=t,state=err,residual=r,defect=defect,energy=e))
                if t < BUDGET:
                    x = z
            # Residual-map linearization in the scaled physical residual coordinates.
            hr = ev(root)[1]
            rr = (hr/a[:,None]) @ j @ np.linalg.inv(hr/a[:,None])
            rows.append(dict(n=n,alpha=alpha,mass_ratio=ratio,stiffness_ratio=contrast,eta=eta,mode=mode,rho=rho,norm_inf=float(np.linalg.norm(j,np.inf)),norm_2=float(np.linalg.norm(j,2)),comparison_inf=float(np.linalg.norm(c,np.inf)),comparison_2=float(np.linalg.norm(c,2)),residual_derivative_inf=float(np.linalg.norm(rr,np.inf)),q_bound=q,theta_bound=lip*q,bound20=lip*2*Y*q**BUDGET if q<1 else None,residual20=r,state20=err,first_tolerance=hit,max_residual_ratio=max_ratio,max_energy_increase=max_increase))
            if n == 4 and ratio == contrast == 1 and alpha in (0.1,10.0):
                eps=1e-6
                fd=np.column_stack([(sw(y+eps*np.eye(n)[i],mode)[0]-sw(y-eps*np.eye(n)[i],mode)[0])/(2*eps) for i in range(n)])
                max_fd=max(max_fd,float(np.max(abs(fd-sw(y,mode)[1]))))
    for name,data in [('results.csv',rows),('trajectories.csv',trajectories)]:
        with (OUT/name).open('w',newline='') as f:
            w=csv.DictWriter(f,fieldnames=data[0].keys()); w.writeheader(); w.writerows(data)
    supported=[r for r in rows if r['alpha']<=.25]
    summary=dict(cases=len(rows),numpy=np.__version__,max_derivative_fd_error=max_fd,supported_cases=len(supported),supported_worst_residual20=max(r['residual20'] for r in supported),supported_max_sweeps=max(r['first_tolerance'] for r in supported),residual_increase_cases=sum(r['max_residual_ratio']>1+1e-8 for r in rows),q_endpoint=certificate(.25,1)[0],theta_endpoint=np.prod(certificate(.25,1)),theta_at_point2=np.prod(certificate(.2,1)))
    assert max_fd < 1e-6
    assert all(r['residual20']<=TOL for r in supported)
    assert all(r['max_energy_increase'] < 1e-10 for r in supported)
    # Exact rational non-descent example: n=2, a=k=1, eta=100,
    # y=(1,-1), x=(0,0), U_0(x)=(1/2,0): E changes 1 -> 37/16.
    from fractions import Fraction as Q
    e_after=Q(1,2)*(Q(1,4)+1)+Q(1,2)*Q(1,4)+25*Q(1,16)
    assert e_after == Q(37,16)
    # Exact safe rounded endpoint and physical-residual counterexample.
    alpha, eta, bb, yy = Q(1,4), Q(1), Q(1,10), Q(1,20)
    ss = 2*alpha*(1+12*eta*bb**2)
    pp = bb+yy+4*alpha*bb*(1+4*eta*bb**2)
    qq = ss/(1+ss)+24*alpha*eta*bb*pp
    assert qq < Q(512,1000)
    assert Q(212,1000)*Q(512,1000)**20 < Q(1,10**6)
    assert 24*alpha*eta*bb**3 <= bb-yy
    assert 11*Q(10,11)-10*Q(100,121) == Q(210,121) > 1
    summary['non_descent_energy_before']=1
    summary['non_descent_energy_after']=str(e_after)
    (OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary,indent=2))

if __name__ == '__main__':
    main()
