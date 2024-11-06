{{/** 
    # -- Enable tracing
    # -- Endpoint for tracing
    # -- Exporter for tracing
    # -- Insecure for tracing
    # -- Mode
    # -- Port
    # -- Enable logging
    # -- Level for logging
    # -- Format for logging
    # -- Enable metrics
    # -- Endpoint for metrics
    # -- Exporter for metrics
    # -- Insecure for metrics
    # -- Mode for metrics
    # -- Port for metrics
    global:
      monitoring:
        traces:
          enabled: true
          endpoint: "localhost"
          exporter: "otlp"
          insecure: "true"
          mode: "grpc"
          port: 4317
        logs:
          enabled: true
          level: "info"
          format: "json"
        metrics:
          enabled: true
          exporter: "otlp"
          insecure: "true"
          mode: "grpc"
          port: 4317
    
    # -- Service name for monitoring
    config:
      monitoring:
        serviceName: ""

    Each component who want to use monitoring should include this snippet in their deployment.yaml

**/}}


{{- define "core.monitoring.traces" }}
- name: OTEL_TRACES
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.enabled" "Default" "") | quote}}
- name: OTEL_TRACES_ENDPOINT
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.endpoint" "Default" "")| quote }}
- name: OTEL_TRACES_EXPORTER
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.exporter" "Default" "") | quote }}
- name: OTEL_TRACES_EXPORTER_OTLP_INSECURE
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.insecure" "Default" "") | quote}}
- name: OTEL_TRACES_EXPORTER_OTLP_MODE
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.mode" "Default" "") | quote}}
- name: OTEL_TRACES_PORT
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.port" "Default" "") | quote }}
- name: OTEL_TRACES_EXPORTER_OTLP_ENDPOINT
  value: "$(OTEL_TRACES_ENDPOINT):$(OTEL_TRACES_PORT)"
{{- end }}

{{- define "core.monitoring.metrics" }}
- name: OTEL_METRICS
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.enabled" "Default" "") | quote }}
- name: OTEL_METRICS_ENDPOINT
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.endpoint" "Default" "") | quote}}
- name: OTEL_METRICS_EXPORTER
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.exporter" "Default" "") | quote}}
- name: OTEL_METRICS_EXPORTER_OTLP_INSECURE
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.insecure" "Default" "") | quote }}
- name: OTEL_METRICS_EXPORTER_OTLP_MODE
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.mode" "Default" "") | quote }}
- name: OTEL_METRICS_PORT
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.port" "Default" "") | quote }}
- name: OTEL_METRICS_EXPORTER_OTLP_ENDPOINT
  value: "$(OTEL_TRACES_ENDPOINT):$(OTEL_METRICS_PORT)"
{{- end -}}

{{- define "core.monitoring.logs" }}
- name: LOGS_ENABLED
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.logs.enabled" "Default" "") | quote }}
- name: LOGS_LEVEL
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.logs.level" "Default" "")| quote }}
{{- if eq (include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.logs.format" "Default" "")) "json" }}
- name: JSON_FORMATTING_LOGGER
  value: "true"
{{- end -}}
{{- end -}}


{{- define "core.monitoring.common" }}
- name: OTEL_SERVICE_NAME
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.serviceName" "Default" "{{ .Chart.Name }}") | quote}}
- name: OTEL_BATCH
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.batch" "Default" "false") | quote}}
- name: OTEL_RESOURCE_ATTRIBUTES
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.attributes" "Default" "") | quote}}
{{- end -}}

{{- define "core.monitoring" -}}
{{- include "core.monitoring.common" . }}
{{- $traces := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.traces.enabled" "Default" "") }}
{{- $logs := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.logs.enabled" "Default" "") }}
{{- $metrics := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "monitoring.metrics.enabled" "Default" "") }}
{{- if eq $traces "true" }}
{{- include "core.monitoring.traces" . }}
{{- end }}
{{- if eq $logs "true" }}
{{- include "core.monitoring.logs" . }}
{{- end }}
{{- if eq $metrics "true" }}
{{- include "core.monitoring.metrics" . }}
{{- end }}
{{- end -}}

