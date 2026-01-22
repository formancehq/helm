{{/**
    SNS Publisher environment variables configuration.

    global:
      aws:
        sns:
          enabled: true
          endpointOverride: ""  # For LocalStack
**/}}

{{/*
SNS Publisher environment variables
*/}}
{{- define "core.aws.sns.env" -}}
{{- $enabled := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.sns.enabled" "Default" "false") -}}
{{- if eq $enabled "true" }}
- name: PUBLISHER_SNS_ENABLED
  value: "true"
{{- $endpointOverride := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.sns.endpointOverride" "Default" "") -}}
{{- if $endpointOverride }}
- name: PUBLISHER_SNS_ENDPOINT_OVERRIDE
  value: {{ $endpointOverride | quote }}
{{- end }}
{{- end }}
{{- end }}