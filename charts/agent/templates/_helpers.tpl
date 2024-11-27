{{/*
Selector labels
*/}}
{{- define "agent.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "agent.env" -}}
- name: DEBUG
  value: "{{.Values.debug}}"
- name: SERVER_ADDRESS
  value: "{{.Values.server.address}}"
- name: TLS_ENABLED
  value: "{{.Values.server.tls.enabled}}"
- name: TLS_INSECURE_SKIP_VERIFY
  value: "{{.Values.server.tls.insecureSkipVerify}}"
- name: TLS_CA_CERT
  value: "{{.Values.server.tls.ca}}"
- name: ID
  value: "{{.Values.agent.id}}"
- name: TAG
  value: "{{range $key, $value := .Values.agent.tags}}{{$key}}={{$value}} {{end}}"
- name: AUTHENTICATION_MODE
  value: "{{ .Values.agent.authentication.mode }}"
{{- if eq .Values.agent.authentication.mode "token" }}
- name: AUTHENTICATION_TOKEN
  value: "{{ .Values.agent.authentication.token }}"
{{- end }}
{{- if eq .Values.agent.authentication.mode "bearer" }}
- name: AUTHENTICATION_ISSUER
  value: "{{ .Values.agent.authentication.issuer }}"
- name: AUTHENTICATION_CLIENT_ID
  value: "{{ .Values.agent.authentication.clientID }}"
- name: AUTHENTICATION_CLIENT_SECRET
  value: "{{ .Values.agent.authentication.clientSecret }}"
{{- end }}
- name: BASE_URL
  value: "{{ .Values.agent.baseUrl }}"
- name: PRODUCTION
  value: "{{ .Values.agent.production }}"
- name: OUTDATED
  value: "{{ .Values.agent.outdated }}"
{{- include "core.monitoring" . }}
{{- end }}