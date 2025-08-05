{{/*
Selector labels
*/}}
{{- define "agent.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "agent.env" -}}
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
  {{- if gt (len .Values.agent.authentication.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.agent.authentication.existingSecret }}
      key: {{ .Values.agent.authentication.secretKeys.secret | default "token"  }}
  {{- else }}
  value: {{ .Values.agent.authentication.token }}
  {{- end }}
{{- end }}
{{- if eq .Values.agent.authentication.mode "bearer" }}
- name: AUTHENTICATION_ISSUER
  value: "{{ .Values.agent.authentication.issuer }}"
- name: AUTHENTICATION_CLIENT_ID
  value: "{{ .Values.agent.authentication.clientID }}"
- name: AUTHENTICATION_CLIENT_SECRET
  {{- if gt (len .Values.agent.authentication.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.agent.authentication.existingSecret }}
      key: {{ .Values.agent.authentication.secretKeys.secret | default "client-secret"  }}
  {{- else }}
  value: {{ .Values.agent.authentication.clientSecret }}
  {{- end }}
{{- end }}
- name: BASE_URL
  value: "{{ .Values.agent.baseUrl }}"
- name: PRODUCTION
  value: "{{ .Values.agent.production }}"
- name: OUTDATED
  value: "{{ .Values.agent.outdated }}"
{{ include "core.env.common" . }}
{{- include "core.monitoring" . }}
{{- end }}