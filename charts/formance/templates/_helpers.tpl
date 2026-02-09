{{/*
Formance Unified Chart - Helpers
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "formance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "formance.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "formance.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "formance.labels" -}}
helm.sh/chart: {{ include "formance.chart" . }}
{{ include "formance.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "formance.selectorLabels" -}}
app.kubernetes.io/name: {{ include "formance.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Validate Enterprise Edition configuration.
This template will fail if EE is enabled but licence is not properly configured.
*/}}
{{- define "formance.validateEE" -}}
{{- if .Values.tags.EntrepriseEdition -}}
  {{- if and (not .Values.global.licence.token) (not .Values.global.licence.existingSecret) -}}
    {{- fail "\n\n==================== CONFIGURATION ERROR ====================\nEnterprise Edition enabled but no licence provided.\n\nPlease set one of:\n  --set global.licence.token=<your-token>\n  --set global.licence.existingSecret=<secret-name>\n\nContact Formance to obtain a licence: https://formance.com\n==============================================================\n" -}}
  {{- end -}}
  {{- if not .Values.global.licence.clusterID -}}
    {{- fail "\n\n==================== CONFIGURATION ERROR ====================\nEnterprise Edition enabled but clusterID is missing.\n\nGet your cluster ID with:\n  kubectl get ns kube-system -o jsonpath='{.metadata.uid}'\n\nThen set:\n  --set global.licence.clusterID=<cluster-id>\n==============================================================\n" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Get edition name
*/}}
{{- define "formance.edition" -}}
{{- if .Values.tags.EntrepriseEdition -}}
Enterprise Edition
{{- else -}}
Community Edition
{{- end -}}
{{- end -}}
