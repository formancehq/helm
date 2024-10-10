{{- define "service.url" -}}
{{- $service := .service -}}
{{- $ := .Context -}}
{{- if kindIs "string" $service -}}
#### Wrong values
{{- else -}}
{{- tpl (printf "%s://%s" ($service.scheme) ($service.host)) $ -}}
{{- end -}}
{{- end -}}