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
{{- $enableIam := (eq (include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.iam" "Default" "false")) "true") }}
{{- if .Values.postgresql.enabled }}
- name: POSTGRES_USERNAME
  value: {{ include "postgresql.v1.username" . }}
{{- else }}
- name: POSTGRES_USERNAME
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.auth.username" "Default" "") }}
{{- end }}
{{- $existingSecret := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.auth.existingSecret" "Default" "") }}
{{- if and (not (empty $existingSecret)) (empty .Values.config.postgresqlUrl) }}
  {{- if .Values.postgresql.enabled }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "postgresql.v1.secretName" . }}
      key: {{ include "postgresql.v1.adminPasswordKey" . }}
  {{- else if (not $enableIam) }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ $existingSecret | quote }}
      key: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.auth.secretKeys.adminPasswordKey" "Default" "") | quote }}
  {{- end }}
{{- else if (not $enableIam) }}
- name: POSTGRES_PASSWORD
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.auth.password" "Default" "") }}
{{- end }}
- name: POSTGRES_URI
{{- if .Values.config.postgresqlUrl }}
  value: "{{ .Values.config.postgresqlUrl }}"
{{- else }}
  {{- $host := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.host" "Default" "") }}
  {{- $database := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.auth.database" "Default" "") }}
  {{- $port := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.service.ports.postgresql" "Default" "5432") }}
  {{- $additionalArgs := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "postgresql.additionalArgs" "Default" "") }}
  {{- if $enableIam }}
  value: "postgresql://$(POSTGRES_USERNAME)@{{ $host }}:{{ $port }}/{{ $database }}{{- if $additionalArgs}}?{{ $additionalArgs }}{{- end -}}"
  {{- else if .Values.postgresql.enabled }}
  value: "postgresql://$(POSTGRES_USERNAME):$(POSTGRES_PASSWORD)@{{ printf "%s.%s.svc" (include "postgresql.v1.primary.fullname" .Subcharts.postgresql) .Release.Namespace }}:{{ $port }}/{{ $database }}{{- if $additionalArgs}}?{{ $additionalArgs }}{{- end -}}"
  {{- else }}
  value: "postgresql://$(POSTGRES_USERNAME):$(POSTGRES_PASSWORD)@{{ $host }}:{{ $port }}/{{ $database }}{{- if $additionalArgs}}?{{ $additionalArgs }}{{- end -}}"
  {{- end }}
{{- end }}
{{- end }}
