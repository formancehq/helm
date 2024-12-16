{{/*

    #
    # Membership:
    # MEMBERSHIP_URL_API is the url to the membership api
    # MEMBERSHIP_CLIENT_ID is the client id of the membership api
    # MEMBERSHIP_CLIENT_SECRET is the client secret of the membership api
    #
    # Portal:
    #
    # NODE_ENV is the environment of the app
    # REDIRECT_URI is the url to redirect after login
    #
    #
    # Console V3 & Portal :
    # COOKIE_SECRET is the secret to encrypt the session cookies
    # COOKIE_NAME is the name of the cookie
    # COOKIE_DOMAIN is the domain of the cookie to set (it could be inferred from the service host) as only available to the portal
    # 
    # Apps:
    # APPS_CONSOLE is the url to the console app
    #
    # Console:
    #
    # CONSOLE_COOKIE_SECRET is the secret to encrypt the console v2 cookies
    # - As console cookie also need to be available to the portal, a common domain must be used
    # - Adding a CONSOLE_COOKIE_DOMAIN for cookie distinction

*/}}

{{- define "portal.cookie" }}
- name: COOKIE_SECRET
  {{- if or .Values.config.cookie.existingSecret .Values.global.platform.portal.cookie.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.cookie.existingSecret | default .Values.global.platform.portal.cookie.existingSecret }}
      key: {{ .Values.config.cookie.secretKeys.secret | default .Values.global.platform.portal.cookie.secretKeys.encryptionKey }}
  {{- else }}
  value: {{ .Values.config.cookie.secret | default .Values.global.platform.portal.cookie.encryptionKey }}
  {{- end }}
- name: COOKIE_NAME
  value: __session_platform
- name: COOKIE_DOMAIN
  value: {{ .Values.global.serviceHost }}
- name: CONSOLE_COOKIE_SECRET
  {{- if gt (len .Values.global.platform.cookie.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.cookie.existingSecret }}
      key: {{ .Values.global.platform.cookie.secretKeys.encryptionKey }}
  {{- else }}
  value: {{ .Values.global.platform.cookie.encryptionKey | quote }}
  {{- end }}
{{- end -}}

{{- define "portal.env" -}}
- name: NODE_ENV
  value: {{ .Values.config.environment }}
- name: MEMBERSHIP_URL_API
  value: {{ (printf "%s/api" (include "service.url" (dict "service" .Values.global.platform.membership "Context" .))) }}
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
- name: FEATURES_DISABLED
  value: "{{ join "," .Values.config.featuresDisabled}}"
- name: REDIRECT_URI
  value: {{ include "service.url" (dict "service" .Values.global.platform.portal "Context" .) }}
- name: APPS_CONSOLE
  value: {{ include "service.url" (dict "service" .Values.global.platform.console "Context" .) }}
- name: DEBUG
  value: {{ .Values.global.debug | quote }}
{{- include "portal.cookie" . }}
{{- include "core.sentry" . }}
{{- include "core.monitoring" . }}
{{ include "portal.additionalEnv" . }}
{{- end }}

{{ define "portal.additionalEnv" }}
{{- with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end }}


