# vbd

## Development setup

Install [elan](https://lean-lang.org/lean4/doc/setup.html), then enter the repository. Elan automatically selects the pinned toolchain from `lean-toolchain`. On a fresh checkout, obtain Mathlib's precompiled cache before building:

```bash
lake exe cache get
lake build
```

Install the OKF linter and enable the repository-managed Git hook once per checkout:

```bash
uv tool install okflint
git config core.hooksPath .githooks
```

The pre-commit hook runs both strict OKF validation and a complete incremental `lake build`. Run the same checks manually with:

```bash
.githooks/pre-commit
```

Useful Lean development commands:

```bash
lake build                         # build every default project target
lake build Vbd.Basic               # build one module and its dependencies
lake lean Vbd/Basic.lean           # elaborate one source file directly
lake lint                          # run the configured package linters
lake env lean --stdin              # elaborate a temporary snippet from stdin
```

Run only the knowledge-base check with:

`okflint validate --manifest knowledge/okf-base.yaml knowledge/`

## GitHub configuration

To set up your new GitHub repository, follow these steps:

* Under your repository name, click **Settings**.
* In the **Actions** section of the sidebar, click "General".
* Check the box **Allow GitHub Actions to create and approve pull requests**.
* Click the **Pages** section of the settings sidebar.
* In the **Source** dropdown menu, select "GitHub Actions".

After following the steps above, you can remove this section from the README file.
