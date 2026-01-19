{{/**
    AWS Services templates for S3, SNS, and SQS configuration.

    Global configuration (shared across services):
    global:
      aws:
        region: "eu-west-1"  # Optional - provided by IRSA when using serviceAccount with roleARN
        s3:
          enabled: true
          endpointOverride: ""  # For LocalStack or MinIO
        sns:
          enabled: true
          endpointOverride: ""  # For LocalStack
        sqs:
          enabled: true
          endpointOverride: ""  # For LocalStack

    Service-specific configuration (topics, queues, buckets):
    config:
      aws:
        sns:
          topicMapping: "event1:topic1,event2:topic2"
        sqs:
          queueMapping: "event1:queue1,event2:queue2"
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
{{- $topicMapping := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.sns.topicMapping" "Default" "") -}}
{{- if $topicMapping }}
- name: PUBLISHER_SNS_TOPIC_MAPPING
  value: {{ $topicMapping | quote }}
{{- end }}
{{- end }}
{{- end }}

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
{{- $queueMapping := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "aws.sqs.queueMapping" "Default" "") -}}
{{- if $queueMapping }}
- name: SUBSCRIBER_SQS_QUEUE_MAPPING
  value: {{ $queueMapping | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Combined AWS services environment variables (region + S3 + SNS + SQS)
*/}}
{{- define "core.aws.env" -}}
{{- include "core.aws.region" . }}
{{- include "core.aws.s3.env" . }}
{{- include "core.aws.sns.env" . }}
{{- include "core.aws.sqs.env" . }}
{{- end }}