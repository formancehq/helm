{{/**
    AWS Region environment variable configuration.

    global:
      aws:
        region: "eu-west-1"  # Optional - provided by IRSA when using serviceAccount with roleARN
**/}}

{{/*
AWS Region environment variable
*/}}
{{- define "core.aws.region" -}}
{{- $region := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.region" "Default" "") -}}
{{- if $region }}
- name: AWS_REGION
  value: {{ $region | quote }}
{{- end }}
{{- end }}
