{{/*
Common labels
*/}}
{{- define "core.labels" -}}
helm.sh/chart: {{ include "core.chart" . }}
{{ include "core.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "core.selectorLabels" -}}
app.kubernetes.io/name: {{ include "core.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
