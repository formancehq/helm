
{{/**

  # Stargate
  # API URL is either Stargate gRPC Gateway or the stack gateway to stacks
  # It can be external or internal
  #
  # Console:
  # NODE_ENV is the environment of the app
  # COOKIE_SECRET is the secret to encrypt the auth cookies
  # COOKIE_DOMAIN is the domain to set the auth cookies
  # COOKIE_NAME is the name of the auth cookie
  # MEMBERSHIP_CLIENT_ID is the client id of the membership app
  # MEMBERSHIP_CLIENT_SECRET is the client secret of the membership app
  # MEMBERSHIP_URL_API is the url of the membership app
  # API_URL is the url of the stack gateway
  # PORTAL_UI is the url of the portal app
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
  # SENTRY is a flag to enable sentry
  # SENTRY_DSN is the url to the sentry endpoint
  # SENTRY_ENVIRONMENT is the environment to use
  # SENTRY_RELEASE is the release to use
  # SENTRY_AUTH_TOKEN is the auth token to use

**/}}
{{- define "console.env" }}
- name: NODE_ENV
  value: {{ .Values.config.environment }}
- name: COOKIE_SECRET
  {{- if gt (len .Values.global.platform.cookie.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.cookie.existingSecret }}
      key: {{ .Values.global.platform.cookie.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.global.platform.cookie.secret }}
  {{- end }}
- name: COOKIE_DOMAIN
  value: {{ .Values.global.serviceHost }}
- name: COOKIE_NAME
  value: __session_platform
- name: MEMBERSHIP_CLIENT_ID
  value: "{{ .Values.global.platform.membership.oauthClient.id }}"
- name: MEMBERSHIP_CLIENT_SECRET
  {{- if gt (len .Values.global.platform.membership.oauthClient.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.membership.oauthClient.existingSecret }}
      key: {{ .Values.global.platform.membership.oauthClient.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.global.platform.membership.oauthClient.secret | quote }}
  {{- end }}
- name: MEMBERSHIP_URL_API
  value: {{ tpl (printf "%s://%s/api" .Values.global.platform.membership.scheme .Values.global.platform.membership.host) $}}
- name: API_URL
  value: {{ (default "http://gateway.#{organizationId}-#{stackId}.svc:8080/api" .Values.config.stargate_url) }}  {{- end }}
- name: PORTAL_UI
  value: {{ tpl (default (printf "%s://%s" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) .Values.config.platform_url) $ }}
- name: SENTRY
  value: {{ .Values.config.sentry.enabled | quote }}
- name: SENTRY_DSN
  value: {{ .Values.config.sentry.dsn }}
- name: SENTRY_ENVIRONMENT
  value: {{ .Values.config.sentry.environment }}
- name: SENTRY_RELEASE
  value: {{ .Values.config.sentry.release }}
- name: SENTRY_AUTH_TOKEN
  value: {{ .Values.config.sentry.authToken }}
{{- define "console.additionalEnv" }}
{{ with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end}}