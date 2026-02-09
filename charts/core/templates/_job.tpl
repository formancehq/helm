{{/**
  
    This way is only reliable when using helm install and helm upgrade.
    ArgoCD use helm template
  
  **/}}
{{- define "core.job.annotations" -}}
{{- if and (not .Release.IsInstall) .Values.feature.migrationHooks }}
helm.sh/hook: pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded,hook-failed
helm.sh/hook-weight: "10"
{{- end }}
{{- end }}
