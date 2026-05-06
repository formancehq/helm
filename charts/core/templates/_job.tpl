{{/**
    Hook annotations for a migration Job — works under plain `helm
    install/upgrade` AND ArgoCD (which auto-translates Helm hook
    annotations to its native PreSync/BeforeHookCreation/sync-wave).

    Gated by `.Values.feature.migrationHooks` so consumers can opt
    out (e.g. when running migrations via a separate orchestrator).

    - `pre-install,pre-upgrade` keeps the Job's identity stable as a
      hook in BOTH install and upgrade. The previous
      `pre-upgrade`-only-on-upgrade gate meant the resource was a plain
      release object on install and flipped to a hook on the next
      upgrade, which produced "Job already exists" errors and orphans
      on uninstall.

    - `before-hook-creation` deletes the previous Job before recreating
      so image bumps and other spec changes don't hit Job-spec
      immutability. `hook-succeeded` is intentionally NOT here so
      operators can `kubectl logs` post-success; cleanup is bounded by
      `ttlSecondsAfterFinished` on the Job spec.
  **/}}
{{- define "core.job.annotations" -}}
{{- if .Values.feature.migrationHooks }}
helm.sh/hook: pre-install,pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation
helm.sh/hook-weight: "10"
{{- end }}
{{- end }}
