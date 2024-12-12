{{/**
  config:
    <...>
    sentry:
      enabled: false
      # -- Sentry DSN
      dsn: ""
      # -- Sentry environment
      environment: ""
      # -- Sentry release
      release: ""
      # -- Sentry Auth Token
      authToken:
        value: ""
        existingSecret: ""
        secretKeys:
          value: ""
    <...>
**/}}

{{- define "core.sentry" }}
- name: SENTRY
  value: {{ .Values.config.sentry.enabled | quote }}
{{- if .Values.config.sentry.enabled }}
- name: SENTRY_DSN
  value: {{ .Values.config.sentry.dsn }}
- name: SENTRY_ENVIRONMENT
  value: {{ .Values.config.sentry.environment }}
- name: SENTRY_RELEASE
  value: {{ .Values.config.sentry.release }}
- name: SENTRY_AUTH_TOKEN
  {{- if gt (len .Values.config.sentry.authToken.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.sentry.authToken.existingSecret }}
      key: {{ .Values.config.sentry.authToken.secretKeys.value }}
  {{- else }}
  value: {{ .Values.config.sentry.authToken.value }}
  {{- end }}
{{- end -}}
{{- end -}}