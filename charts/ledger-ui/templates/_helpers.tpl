
{{/**

  # Stargate
  # API_STACK_URL is either Stargate gRPC Gateway or the stack gateway to stacks.
  # It can be external or internal, and carries the #{organizationId}/#{stackId}
  # placeholders (see .Values.config.stargate_url or global.platform.stargate).
  #
  # Ledger UI:
  # NODE_ENV is the environment of the app
  # AUTHENTICATION_ENABLED toggles OAuth/DB sessions (1 = stack mode, 0 =
  #   micro-stack / auth-less mode reading LEDGER_API_URL directly).
  # POSTGRES_URI (+ POSTGRES_AWS_ENABLE_IAM / AWS_REGION when IAM auth is on)
  # COOKIE_SECRET is the secret to encrypt the auth cookies
  # COOKIE_DOMAIN is the domain to set the auth cookies
  # MEMBERSHIP_CLIENT_ID / MEMBERSHIP_CLIENT_SECRET / MEMBERSHIP_URL_API for OAuth
  # REDIRECT_URI is the OAuth redirect URI back to this app
  # PORTAL_UI is the url of the portal app (app switcher)
  # LEDGER_UI is the public url of this app (self-reference for outbound links)
  # Other cross-app URLs (CONSOLE_V3_UI, STUDIO_UI, BANKING_BRIDGE_UI,
  #   LEDGER_API_URL for auth-less mode) are optional and provided via
  #   .Values.config.additionalEnv.
  #
  # Monitoring:
  # OTEL_TRACES* + OTEL_SERVICE_NAME + OTEL_RESOURCE_ATTRIBUTES via core.monitoring
  # SENTRY_* via core.sentry when enabled

**/}}

{{- define "ledger-ui.cookie" }}
- name: COOKIE_SECRET
  {{- if or .Values.config.cookie.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.cookie.existingSecret }}
      key: {{ .Values.config.cookie.secretKeys.encryptionKey }}
  {{- else }}
  value: {{ .Values.config.cookie.encryptionKey }}
  {{- end }}
- name: COOKIE_DOMAIN
  value: {{ tpl .Values.global.platform.ledgerUi.host $ }}
{{- end -}}


{{- define "ledger-ui.oauth.client" }}
- name: REDIRECT_URI
  value: {{ tpl (default (printf "%s://%s" .Values.global.platform.ledgerUi.scheme .Values.global.platform.ledgerUi.host) .Values.config.redirect_url) $ }}
- name: MEMBERSHIP_CLIENT_ID
  value: "{{ .Values.global.platform.ledgerUi.oauth.client.id }}"
- name: MEMBERSHIP_CLIENT_SECRET
  {{- if gt (len .Values.global.platform.ledgerUi.oauth.client.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.ledgerUi.oauth.client.existingSecret }}
      key: {{ .Values.global.platform.ledgerUi.oauth.client.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.global.platform.ledgerUi.oauth.client.secret | quote }}
  {{- end }}
- name: MEMBERSHIP_URL_API
  value: {{ tpl (printf "%s://%s/api" .Values.global.platform.membership.scheme .Values.global.platform.membership.host) $}}
{{- end }}


{{- define "ledger-ui.env" -}}
- name: NODE_ENV
  value: {{ .Values.config.environment }}
- name: AUTHENTICATION_ENABLED
  value: {{ .Values.config.authenticationEnabled | quote }}
- name: API_STACK_URL
{{- if .Values.global.platform.stargate.enabled  }}
  value: {{ printf "http://%s-%s:8080/#{organizationId}/#{stackId}/api" .Release.Name "stargate" -}}
{{- else }}
  value: {{ default "http://gateway.#{organizationId}-#{stackId}.svc:8080/api" (default .Values.global.platform.stargate.stackApiUrl .Values.config.stargate_url) }}
{{- end }}
- name: PORTAL_UI
  value: {{ tpl (default (printf "%s://%s" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) .Values.config.platform_url) $ }}
- name: LEDGER_UI
  value: {{ tpl (printf "%s://%s" .Values.global.platform.ledgerUi.scheme .Values.global.platform.ledgerUi.host) $ }}
{{ include "core.env.common" . }}
{{- include "ledger-ui.cookie" . }}
{{- include "ledger-ui.oauth.client" . }}
{{- include "core.postgres.uri" . }}
{{- include "core.sentry" . }}
{{- include "core.monitoring" . }}
{{ with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end -}}
