# Helm repo — Claude instructions

This repo holds Formance's Helm charts. Below is the standard workflow when a new
upstream service tag is released and the chart needs to be bumped. Treat this as
the canonical "as we usually do" procedure — match it unless the user says otherwise.

## Repository layout

`charts/` contains one chart per service. The dependency tree is:

```text
formance      ──► regions   ──► agent, operator (OCI), core
              └─► cloudprem ──► membership, portal, console-v3
                                membership ──► postgresql, dex, core
                                portal/console-v3 ──► postgresql, core
```

- `core` is a library chart shared by everything.
- `formance` and `regions` use floating major-version ranges (`3.X`, `4.X`) in
  `Chart.yaml`, so their `Chart.lock` is what actually pins each release.
- `cloudprem` has no `templates/` of its own — it is an umbrella chart, so
  `helm lint --strict charts/cloudprem` fails with
  `[WARNING] templates/: directory does not exist`. This is **pre-existing** and
  not introduced by version bumps; ignore it.

## Upstream → chart mapping

| Upstream repo                | Chart(s) to bump                                                          |
| ---------------------------- | ------------------------------------------------------------------------- |
| `formancehq/membership-api`  | `membership` → `cloudprem` → `formance`                                   |
| `formancehq/agent`           | `agent` → `regions` → `formance`                                          |
| `formancehq/portal`          | `portal` → `cloudprem` → `formance`                                       |
| `formancehq/console-v3`      | `console-v3` → `cloudprem` → `formance`                                   |
| `formancehq/operator`        | `regions` (Chart.lock refresh picks it up) → `formance`                   |

## The cascade rule (read this twice)

**Any change to a `Chart.lock` means the chart that owns it must have its
`version` bumped, and every chart that depends on it must also be bumped — all
the way up to `formance`.** No exceptions.

A `Chart.lock` change happens whenever:

1. You edited a dependency's `Chart.yaml` `version`.
2. `helm dependency update` pulled a new transitive version (e.g. `regions`
   picking up a fresh `operator` from `oci://ghcr.io/formancehq/helm`).
3. A floating range (`3.X`, `4.X`) resolved to a higher version.

For each case, the procedure is the same: walk **up** the dependency tree from
the chart whose lock changed and bump every parent's `version` until you reach
the umbrella (`formance`). Forgetting a parent means consumers of the umbrella
never see the change — the lock digest is what actually pins the release.

Concrete examples:

- `membership` bump → bump `membership` → bump `cloudprem` → bump `formance`.
- `agent` bump → bump `agent` → bump `regions` → bump `formance`.
- `operator` resolves to a new patch (lock-only refresh in `regions`) → bump
  `regions` → bump `formance`. The `operator` chart itself lives upstream, so
  you do not edit anything inside `charts/`, but the cascade still applies.
- `portal` and `console-v3` both bumped at once → still a single `cloudprem`
  bump and a single `formance` bump (cascade dedupes).

If `just pre-commit` produces a `Chart.lock` diff on a chart whose `version`
you did **not** touch, that chart needs a bump too. Add it to the same commit.

## Version bump scheme

Mirror the upstream service's semver step on the **chart** version:

- Upstream **patch** (`v2.4.0 → v2.4.1`) → chart patch (`3.4.0 → 3.4.1`).
- Upstream **minor** (`v2.4.0 → v2.5.0`) → chart minor (`3.4.0 → 3.5.0`).
- Upstream **major** (`v2 → v3`) → chart **major**, and this requires
  Maxence/Clem approval (see `formance-skills:formance-git`).

Wrapper chart bumps (`cloudprem`, `formance`, `regions`) match the largest step
of any dep they pull in. Don't be clever — keep them aligned with the leaf.

Only the leaf chart has an `appVersion`. Set it to the exact upstream tag
including the `v` prefix (e.g. `"v2.5.0"`). Umbrella charts keep
`appVersion: "latest"`.

## Standard procedure

1. Confirm the upstream tag exists:

   ```sh
   gh release view <tag> --repo formancehq/<service>
   ```

   Glance at the release notes for breaking changes — if anything looks
   breaking, surface it to the user before proceeding.

2. Branch from `main`:

   ```sh
   git checkout main && git pull
   git checkout -b chore/upgrade-<service>-<tag>
   ```

3. Edit `Chart.yaml` for each affected chart. Touch **only** `version` (and
   `appVersion` on the leaf). Do not edit `Chart.lock` or `README.md` by hand —
   they are generated.

4. Run the precommit pipeline. It is mandatory before every commit (see the
   global `~/.claude/CLAUDE.md`):

   ```sh
   just pre-commit
   ```

   This refreshes every chart's deps, regenerates `values.schema.json`, lints
   and dry-renders all charts, runs `helm-docs`, and rewrites the root
   `README.md` from `tools/readme/readme.tpl`.

   Expect side-effects on top of your edits:

   - `Chart.lock` digests and timestamps refresh on every chart you touched
     and on charts that transitively depend on them.
   - `regions/Chart.lock` may pick up a new `operator` OCI version (resolved
     fresh from `oci://ghcr.io/formancehq/helm`). **Apply the cascade rule:**
     bump `regions` and `formance` even if you weren't planning to touch them.
   - `README.md` (root and per-chart) is regenerated from the template.

   The cloudprem strict-lint failure is pre-existing (see above); the
   precommit run still completes its README generation step.

5. Re-run the cascade audit. After `just pre-commit`, look at the diff:

   ```sh
   git status
   git diff --stat charts/*/Chart.lock
   ```

   For every modified `Chart.lock`, the owning chart's `Chart.yaml` `version`
   should also be in the diff. If it isn't, you forgot a parent — bump it,
   re-run `just pre-commit`, and re-audit. Repeat until clean.

6. Sanity-check the final diff. Only the following should change for a clean
   leaf-chart bump:

   ```text
   charts/<leaf>/Chart.yaml
   charts/<leaf>/README.md
   charts/<parent>/Chart.yaml
   charts/<parent>/Chart.lock
   charts/<parent>/README.md
   ...up the dependency chain...
   README.md
   ```

   If any `values.yaml`, `values.schema.json`, or template file shows up in
   the diff, stop — something else is going on and the user needs to see it.

7. Commit and open a draft PR. Use conventional-commit style and match the
   tone of recent merges (`git log --oneline -10`):

   ```text
   chore: update <service> to <tag>
   ```

   For PRs that cascade through multiple charts, list every chart bumped in
   the body. Open as draft and let CI validate before marking ready.

8. Watch CI with `formance-skills:formance-ci-watch` if asked.

## What NOT to do

- Don't bump a chart "just in case" without an upstream trigger or a real
  template change — chart versions are consumer-facing.
- Don't hand-edit `Chart.lock` files. Run `just pre-commit` (or
  `helm dependency update <chart>`) and commit the result.
- Don't skip the cascade. Forgetting to bump `formance` after bumping
  `cloudprem` means consumers of the umbrella chart never pick up the change.
  Same for `regions` when `operator` refreshes.
- Don't merge `--no-verify` or skip `just pre-commit` — the README and
  lockfile drift will get caught by CI anyway and force a follow-up commit.
- Don't touch `agent`/`regions` when the user only mentions
  membership/cloudprem/formance. Stay in scope.

## Reference: prior bump PR

PR #374 (`chore: update membership and agent versions`) is the canonical
example of a multi-chart cascade. When in doubt about file scope or commit
shape, mirror that PR's diff structure.
