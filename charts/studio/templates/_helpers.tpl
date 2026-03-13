
{{/**

  # Studio:
  # NODE_ENV is the environment of the app
  # COOKIE_SECRET is the secret to encrypt the auth cookies
  # COOKIE_DOMAIN is the domain to set the auth cookies
  # MEMBERSHIP_CLIENT_ID is the client id of the membership app
  # MEMBERSHIP_CLIENT_SECRET is the client secret of the membership app
  # MEMBERSHIP_URL_API is the url of the membership app
  # REDIRECT_URI is the OAuth callback url
  # OPENAI_API_KEY is the API key for OpenAI
  # CHAT_ENABLED is the feature flag for chat
  # APPS_BUILDER is the feature flag for apps builder

**/}}

{{- define "studio.cookie" }}
- name: COOKIE_SECRET
  {{- if .Values.config.cookie.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.cookie.existingSecret }}
      key: {{ .Values.config.cookie.secretKeys.encryptionKey }}
  {{- else }}
  value: {{ .Values.config.cookie.encryptionKey }}
  {{- end }}
- name: COOKIE_DOMAIN
  value: {{ tpl .Values.global.platform.studio.host $ }}
{{- end -}}

{{- define "studio.oauth.client" }}
- name: REDIRECT_URI
  value: {{ tpl (printf "%s://%s" .Values.global.platform.studio.scheme .Values.global.platform.studio.host) $ }}
- name: MEMBERSHIP_CLIENT_ID
  value: "{{ .Values.global.platform.studio.oauth.client.id }}"
- name: MEMBERSHIP_CLIENT_SECRET
  {{- if gt (len .Values.global.platform.studio.oauth.client.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.studio.oauth.client.existingSecret }}
      key: {{ .Values.global.platform.studio.oauth.client.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.global.platform.studio.oauth.client.secret | quote }}
  {{- end }}
- name: MEMBERSHIP_URL_API
  value: {{ tpl (printf "%s://%s/api" .Values.global.platform.membership.scheme .Values.global.platform.membership.host) $ }}
{{- end }}

{{- define "studio.openai" }}
{{- if .Values.config.openai.existingSecret }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.openai.existingSecret }}
      key: {{ .Values.config.openai.secretKeys.apiKey }}
{{- else if .Values.config.openai.apiKey }}
- name: OPENAI_API_KEY
  value: {{ .Values.config.openai.apiKey | quote }}
{{- end }}
{{- end }}

{{- define "studio.features" }}
- name: CHAT_ENABLED
  value: {{ .Values.config.features.chatEnabled | quote }}
- name: APPS_BUILDER
  value: {{ .Values.config.features.appsBuilder | quote }}
{{- end }}

{{- define "studio.env" -}}
- name: NODE_ENV
  value: {{ .Values.config.environment }}
{{ include "core.env.common" . }}
{{- include "studio.cookie" . }}
{{- include "studio.oauth.client" . }}
{{- include "studio.openai" . }}
{{- include "studio.features" . }}
{{- include "core.postgres.uri" . }}
{{- include "core.sentry" . }}
{{- include "core.monitoring" . }}
{{ with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end -}}
