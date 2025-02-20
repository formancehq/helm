
{{/**

  # Stargate
  # API URL is either Stargate gRPC Gateway or the stack gateway to stacks
  # It can be external or internal
  #
  # Console:
  # NODE_ENV is the environment of the app
  # REDIRECT_URI is the url to redirect after login
  #
  # Platform_ Cookie:
  # ENCRYPTION_KEY is the key to encrypt the auth cookies
  # COOKIE_DOMAIN is the domain to set the auth cookies
  # UNSECURE_COOKIES is a flag to set the cookies as secure or not
  #
  # Portal:
  # PLATFORM_URL is the url to redirect after logout
  #
  # Membership:
  # MEMBERSHIP_CLIENT_ID is the client id of the membership api
  # MEMBERSHIP_CLIENT_SECRET is the client secret of the membership api
  # MEMBERSHIP_URL_API is the url to the membership api
  #
  # Monitoring:
  # OTEL_TRACES is a flag to enable tracing
  # OTEL_TRACES_ENDPOINT is the url to the tracing endpoint
  # OTEL_TRACES_EXPORTER is the exporter to use
  # OTEL_TRACES_EXPORTER_OTLP_ENDPOINT is the url to the tracing endpoint
  # OTEL_TRACES_EXPORTER_OTLP_INSECURE is a flag to set the exporter as insecure
  # OTEL_TRACES_EXPORTER_OTLP_MODE is the mode to use
  # OTEL_TRACES_PORT is the port to use
  # OTEL_RESOURCE_ATTRIBUTES is the attributes to set

**/}}

## This need to match portal oauth client if enabled !
{{- define "console.oauth.client" }}
- name: REDIRECT_URI
  value: {{ tpl (default (printf "%s://%s" .Values.global.platform.console.scheme .Values.global.platform.console.host) .Values.config.redirect_url) $ }}
- name: MEMBERSHIP_CLIENT_ID
  value: "{{ .Values.global.platform.portal.oauth.client.id }}"
- name: MEMBERSHIP_CLIENT_SECRET
  {{- if gt (len .Values.global.platform.portal.oauth.client.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.portal.oauth.client.existingSecret }}
      key: {{ .Values.global.platform.portal.oauth.client.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.global.platform.portal.oauth.client.secret | quote }}
  {{- end }}
- name: MEMBERSHIP_URL_API
  value: {{ tpl (printf "%s://%s/api" .Values.global.platform.membership.scheme .Values.global.platform.membership.host) $}}
{{- end }}

{{- define "console.env" }}
- name: NODE_ENV
  value: {{ .Values.config.environment }}
- name: ENCRYPTION_KEY
  {{- if .Values.global.platform.console.cookie.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.console.cookie.existingSecret }}
      key: {{ .Values.global.platform.console.cookie.secretKeys.encryptionKey }}
  {{- else }}
  value: {{ .Values.global.platform.console.cookie.encryptionKey | default .Values.config.encryption_key | quote }}
  {{- end }}
- name: PLATFORM_URL
  value: {{ tpl (default (printf "%s://%s" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) .Values.config.platform_url) $ }}
- name: UNSECURE_COOKIES
  value: "false"
- name: COOKIE_DOMAIN
  value: {{ .Values.global.serviceHost }}
- name: API_URL
  value: {{ (default "http://gateway.#{organizationId}-#{stackId}.svc:8080/api" .Values.config.stargate_url) }}
{{ include "console.oauth.client" . }}
{{ include "core.sentry" . }}
{{ include "core.monitoring" . }}
{{ include "console.additionalEnv" . }}
{{- end }}

{{- define "console.additionalEnv" }}
{{ with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end }}