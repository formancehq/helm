{{/**
    S3 environment variables configuration.

    global:
      aws:
        s3:
          enabled: true
          endpointOverride: ""  # For LocalStack or MinIO
**/}}

{{/*
S3 environment variables
*/}}
{{- define "core.aws.s3.env" -}}
{{- $enabled := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.s3.enabled" "Default" "false") -}}
{{- if eq $enabled "true" }}
- name: S3_BUCKET_AWS_ENABLED
  value: "true"
{{- $endpointOverride := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.s3.endpointOverride" "Default" "") -}}
{{- if $endpointOverride }}
- name: S3_BUCKET_ENDPOINT_OVERRIDE
  value: {{ $endpointOverride | quote }}
{{- end }}
{{- end }}
{{- end }}