{{/**
    Hook annotations for a migration Job — works under plain `helm
    install/upgrade` AND ArgoCD's `helm template` rollout.

    Why both Helm and Argo annotations:

    - Helm hooks (`pre-install,pre-upgrade`) are honored by
      `helm install` / `helm upgrade`. Setting BOTH directions (rather
      than the previous `pre-upgrade`-only-on-`feature.migrationHooks`)
      keeps the Job's identity stable: the resource is always a hook,
      never a "release resource" that flips into a hook on the first
      upgrade. Identity flips were the source of the cross-project
      "Job already exists" / orphan-on-uninstall bug operators have hit.

    - ArgoCD strips Helm hook semantics when rendering with
      `helm template`. Without `argocd.argoproj.io/hook` the same
      manifest would re-apply on every sync as a plain resource and
      fail Job-spec immutability. `PreSync` mirrors Helm's intent.

    - `before-hook-creation` / `BeforeHookCreation` deletes the
      previous Job before recreating, covering image bumps and other
      spec changes that would otherwise hit immutability errors.

    - `hook-succeeded` is intentionally NOT in the delete policy:
      operators need `kubectl logs` for forensics post-success;
      cleanup is bounded by `ttlSecondsAfterFinished` on the Job spec
      (Helm honors it on hooks in modern versions).

    - `feature.migrationHooks` is no longer consulted. The previous
      gate produced two broken modes (off → no hooks, race; on with
      `not .Release.IsInstall` → identity flip), neither of which is
      what operators want. Hooks-always is the only safe default.
  **/}}
{{- define "core.job.annotations" -}}
helm.sh/hook: pre-install,pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation
helm.sh/hook-weight: "10"
argocd.argoproj.io/hook: PreSync
argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
argocd.argoproj.io/sync-wave: "10"
{{- end }}
