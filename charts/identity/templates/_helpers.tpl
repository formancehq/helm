{{- define "identity.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "identity.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "identity.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "identity.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "identity.selectorLabels" -}}
app.kubernetes.io/name: {{ include "identity.name" . }}
{{- if .Values.selectorLabels.includeInstance }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- with .Values.selectorLabels.extra }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "identity.labels" -}}
helm.sh/chart: {{ include "identity.chart" . }}
app.kubernetes.io/name: {{ include "identity.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "identity.podLabels" -}}
{{ include "identity.labels" . }}
{{- with .Values.selectorLabels.extra }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{- define "identity.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "identity.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "identity.hookServiceAccountName" -}}
{{- if .Values.hooks.serviceAccount.create -}}
{{- default (printf "%s-hooks" (include "identity.fullname" .)) .Values.hooks.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.hooks.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "identity.configName" -}}
{{- printf "%s-config" (include "identity.fullname" .) -}}
{{- end }}

{{- define "identity.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- if .Values.image.digest -}}
{{- printf "%s:%s@%s" .Values.image.repository $tag .Values.image.digest -}}
{{- else -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}
{{- end }}

{{- define "identity.publicURL" -}}
{{- if .Values.config.publicURL -}}
{{- tpl .Values.config.publicURL . -}}
{{- else -}}
{{- tpl (printf "%s://%s" .Values.global.platform.identity.scheme .Values.global.platform.identity.host) . -}}
{{- end -}}
{{- end }}

{{- define "identity.relyingPartyID" -}}
{{- tpl (.Values.config.relyingPartyID | default .Values.global.platform.identity.host) . -}}
{{- end }}

{{- define "identity.membershipCallbackURL" -}}
{{- if .Values.global.platform.identity.membership.callbackURL -}}
{{- tpl .Values.global.platform.identity.membership.callbackURL . -}}
{{- else -}}
{{- tpl (printf "%s://%s/api/authorize/callback" .Values.global.platform.membership.scheme .Values.global.platform.membership.host) . -}}
{{- end -}}
{{- end }}

{{- define "identity.configData" -}}
NODE_ENV: {{ .Values.config.nodeEnv | quote }}
HOSTNAME: {{ .Values.config.hostname | quote }}
PORT: {{ .Values.config.port | quote }}
IDENTITY_URL: {{ include "identity.publicURL" . | quote }}
IDENTITY_RP_ID: {{ include "identity.relyingPartyID" . | quote }}
MEMBERSHIP_CLIENT_ID: {{ tpl .Values.global.platform.identity.membership.client.id . | quote }}
MEMBERSHIP_CALLBACK_URL: {{ include "identity.membershipCallbackURL" . | quote }}
IDENTITY_MAIL_TRANSPORT: {{ .Values.config.mail.transport | quote }}
IDENTITY_MAIL_FROM: {{ .Values.config.mail.from | quote }}
{{- if eq .Values.config.mail.transport "smtp" }}
IDENTITY_SMTP_HOST: {{ .Values.config.mail.smtp.host | quote }}
IDENTITY_SMTP_PORT: {{ .Values.config.mail.smtp.port | quote }}
IDENTITY_SMTP_SECURE: {{ .Values.config.mail.smtp.secure | quote }}
{{- with .Values.config.mail.smtp.username }}
IDENTITY_SMTP_USER: {{ . | quote }}
{{- end }}
{{- else if eq .Values.config.mail.transport "mailgun" }}
IDENTITY_MAILGUN_DOMAIN: {{ .Values.config.mail.mailgun.domain | quote }}
IDENTITY_MAILGUN_REGION: {{ .Values.config.mail.mailgun.region | quote }}
{{- end }}
{{- with .Values.config.additional }}
{{ tpl (toYaml .) $ }}
{{- end }}
{{- end }}

{{- define "identity.configEnv" -}}
{{- $config := include "identity.configData" . | fromYaml -}}
{{- range $name, $value := $config }}
- name: {{ $name }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{- define "identity.secretValue" -}}
{{- if .existingSecret }}
valueFrom:
  secretKeyRef:
    name: {{ tpl .existingSecret $.Root | quote }}
    key: {{ .key | quote }}
{{- else }}
value: {{ .value | quote }}
{{- end }}
{{- end }}

{{- define "identity.runtimeSecretEnv" -}}
- name: POSTGRES_URI
  {{- include "identity.secretValue" (dict "Root" . "existingSecret" .Values.database.runtime.existingSecret "key" .Values.database.runtime.secretKeys.uri "value" .Values.database.runtime.uri) | nindent 2 }}
- name: IDENTITY_SECRET
  {{- include "identity.secretValue" (dict "Root" . "existingSecret" .Values.config.identitySecret.existingSecret "key" .Values.config.identitySecret.secretKeys.secret "value" .Values.config.identitySecret.value) | nindent 2 }}
- name: MEMBERSHIP_CLIENT_SECRET
  {{- include "identity.secretValue" (dict "Root" . "existingSecret" .Values.global.platform.identity.membership.client.existingSecret "key" .Values.global.platform.identity.membership.client.secretKeys.secret "value" .Values.global.platform.identity.membership.client.secret) | nindent 2 }}
{{- if eq .Values.config.mail.transport "smtp" }}
{{- if or .Values.config.mail.smtp.existingSecret .Values.config.mail.smtp.password }}
- name: IDENTITY_SMTP_PASSWORD
  {{- include "identity.secretValue" (dict "Root" . "existingSecret" .Values.config.mail.smtp.existingSecret "key" .Values.config.mail.smtp.secretKeys.password "value" .Values.config.mail.smtp.password) | nindent 2 }}
{{- end }}
{{- else if eq .Values.config.mail.transport "mailgun" }}
- name: IDENTITY_MAILGUN_API_KEY
  {{- include "identity.secretValue" (dict "Root" . "existingSecret" .Values.config.mail.mailgun.existingSecret "key" .Values.config.mail.mailgun.secretKeys.apiKey "value" .Values.config.mail.mailgun.apiKey) | nindent 2 }}
{{- end }}
{{- end }}

{{- define "identity.migrationSecretEnv" -}}
- name: NODE_ENV
  value: {{ .Values.config.nodeEnv | quote }}
- name: POSTGRES_URI
  {{- include "identity.secretValue" (dict "Root" . "existingSecret" .Values.database.migration.existingSecret "key" .Values.database.migration.secretKeys.uri "value" .Values.database.migration.uri) | nindent 2 }}
{{- with .Values.config.additional.NODE_EXTRA_CA_CERTS }}
- name: NODE_EXTRA_CA_CERTS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- define "identity.hookAnnotations" -}}
helm.sh/hook: pre-install,pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation
{{- end }}
