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
Is Enterprise Edition selected?

`tags.EnterpriseEdition` is the supported key. `tags.EntrepriseEdition` is the
original misspelling, still honoured so existing values files keep working; it
is deprecated and warned about in NOTES.txt.

Returns a non-empty string when EE is on, so callers can use it directly in an
`if`. Keep this as the only place that reads either tag.
*/}}
{{- define "formance.enterpriseEnabled" -}}
{{- if or .Values.tags.EnterpriseEdition .Values.tags.EntrepriseEdition -}}true{{- end -}}
{{- end -}}

{{/*
Reject unknown keys under `tags`.

Helm resolves tags natively and silently ignores ones it does not know, so a
typo -- including the near-miss `EnterprizeEdition` -- would otherwise leave an
Enterprise install quietly running as Community.
*/}}
{{- define "formance.validateTags" -}}
{{- $known := list "EnterpriseEdition" "EntrepriseEdition" "CommunityEdition" "Demo" -}}
{{- range $key, $_ := .Values.tags -}}
  {{- if not (has $key $known) -}}
    {{- fail (printf "\n\n==================== CONFIGURATION ERROR ====================\nUnknown tag: tags.%s\n\nHelm ignores tags it does not recognise, so this would have been\nsilently dropped -- leaving an Enterprise install running as Community.\n\nValid tags are:\n  tags.EnterpriseEdition  (Enterprise Edition, requires a licence)\n  tags.CommunityEdition   (Community Edition, the default)\n  tags.Demo               (demo mode hints in the install notes)\n  tags.EntrepriseEdition  (deprecated spelling of tags.EnterpriseEdition)\n==============================================================\n" $key) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validate Enterprise Edition configuration.
This template will fail if EE is enabled but licence is not properly configured.
*/}}
{{- define "formance.validateEE" -}}
{{- if include "formance.enterpriseEnabled" . -}}
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
{{- if include "formance.enterpriseEnabled" . -}}
Enterprise Edition
{{- else -}}
Community Edition
{{- end -}}
{{- end -}}
