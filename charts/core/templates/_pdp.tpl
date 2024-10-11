{{- define "core.podDisruptionBudget" -}}
{{- if .Values.podDisruptionBudget.enabled }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "core.fullname" . }}
  labels:
{{ include "core.labels" . | indent 4 }}
spec:
  {{- with .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ . }}
  {{- end }}
  {{- with .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ . }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "core.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end -}}