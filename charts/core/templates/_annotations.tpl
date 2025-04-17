{{/*
  Annotations template for the core chart.
*/}}
{{- define "core.podAnnotations" -}}
{{ with .Values.podAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}
