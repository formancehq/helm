{{/** 
    This now can be included in every chart folowing:
    It need to be either integrate as one instance or as multiple seperated instances
    
    global:
      aws:
        iam: true

      postgres:
        enabled: true
    
    <service>:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn:

    We could integrate with a postgres chart like bitnami and follow their construction
**/}}

{{- define "core.postgres.uri" -}}
{{- include "aws.iam.postgres" . }}
{{- if and .Values.global.postgresql.auth.existingSecret (not .Values.config.postgresqlUrl) }}
- name: POSTGRES_USERNAME
  value: {{ include "postgresql.v1.username" . }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.v1.secretName" . }}
      key: {{ include "postgresql.v1.adminPasswordKey" . }}
{{- else }}
- name: POSTGRES_USERNAME
  value: {{ .Values.global.postgresql.auth.username }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.global.postgresql.auth.password }}
{{- end }}
- name: POSTGRES_URI
{{- if .Values.config.postgresqlUrl }}
  value: "{{ .Values.config.postgresqlUrl }}"
{{- else }}
  value: "postgresql://$(POSTGRES_USERNAME):$(POSTGRES_PASSWORD)@{{.Values.global.postgresql.host | default (printf "%s.%s.svc" (include "postgresql.v1.primary.fullname" .Subcharts.postgresql) .Release.Namespace ) }}:{{.Values.global.postgresql.service.ports.postgresql}}/{{.Values.global.postgresql.auth.database}}{{- if .Values.global.postgresql.additionalArgs}}?{{.Values.global.postgresql.additionalArgs}}{{- end -}}"
{{- end }}
{{- end }}