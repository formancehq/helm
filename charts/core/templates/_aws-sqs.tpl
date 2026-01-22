{{/**
    SQS Subscriber environment variables configuration.

    global:
      aws:
        sqs:
          enabled: true
          endpointOverride: ""  # For LocalStack
**/}}

{{/*
SQS Subscriber environment variables
*/}}
{{- define "core.aws.sqs.env" -}}
{{- $enabled := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.sqs.enabled" "Default" "false") -}}
{{- if eq $enabled "true" }}
- name: SUBSCRIBER_SQS_ENABLED
  value: "true"
{{- $endpointOverride := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.sqs.endpointOverride" "Default" "") -}}
{{- if $endpointOverride }}
- name: SUBSCRIBER_SQS_ENDPOINT_OVERRIDE
  value: {{ $endpointOverride | quote }}
{{- end }}
{{- end }}
{{- end }}