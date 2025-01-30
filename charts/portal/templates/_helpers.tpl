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
  {{- if or .Values.config.cookie.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.cookie.existingSecret }}
      key: {{ .Values.config.cookie.secretKeys.secret  }}
  {{- else }}
  value: {{ .Values.config.cookie.secret  }}
  {{- end }}
- name: COOKIE_NAME
  value: __session_platform
{{- if .Values.global.platform.console.enabled }}
- name: COOKIE_DOMAIN
  value: {{ .Values.global.serviceHost }}
- name: CONSOLE_COOKIE_SECRET
  {{- if gt (len .Values.global.platform.portal.oauth.cookie.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.portal.oauth.cookie.existingSecret }}
      key: {{ .Values.global.platform.portal.oauth.cookie.secretKeys.encryptionKey }}
  {{- else }}
  value: {{ .Values.global.platform.portal.oauth.cookie.encryptionKey | quote }}
  {{- end }}
{{- else }}
- name: COOKIE_DOMAIN
  value: {{ tpl .Values.global.platform.portal.host $ }}
{{- end -}}
{{- end -}}

{{- define "portal.oauth.client" }}
- name: MEMBERSHIP_URL_API
  value: {{ (printf "%s/api" (include "service.url" (dict "service" .Values.global.platform.membership "Context" .))) }}
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
- name: REDIRECT_URI
  value: {{ include "service.url" (dict "service" .Values.global.platform.portal "Context" .) }}
{{- end }}

{{- define "portal.env" -}}
- name: NODE_ENV
  value: {{ .Values.config.environment }}
- name: FEATURES_DISABLED
  value: "{{ join "," .Values.config.featuresDisabled}}"
- name: APPS_CONSOLE
  value: {{ include "service.url" (dict "service" .Values.global.platform.console "Context" .) }}
- name: DEBUG
  value: {{ .Values.global.debug | quote }}
{{- include "portal.cookie" . }}
{{- include "portal.oauth.client" . }}
{{- include "core.sentry" . }}
{{- include "core.monitoring" . }}
{{ include "portal.additionalEnv" . }}
{{- end }}

{{ define "portal.additionalEnv" }}
{{- with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end }}


