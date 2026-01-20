{{/*
  .Context: Context of the chart
  .Key: Key to find in the <service>.config.<key> then in <global>.<key>
  .Default: default an object where each key is a string
*/}}
{{- define "resolveGlobalOrServiceValue" -}}
  {{- $values := .Context -}}
  {{- $values := $values.Values -}}
  {{- $key := .Key -}}
  {{- $default := tpl .Default .Context -}}
  {{- $from := .From | default "config" -}}

  {{- $keys := splitList "." $key -}}
  

  {{- $configkeys := splitList "." (print $from "." $key) -}}
  {{- $subchartValue := $values -}}
  {{- $found := true -}}
  {{- range $configkeys -}}
    {{- if hasKey $subchartValue . -}}
      {{- $subchartValue = index $subchartValue . -}}
    {{- else -}}
      {{- $found = false -}}
      {{- break -}}
    {{- end -}}
  {{- end -}}

  {{- if not $found -}}
    {{- $subchartValue = $values.global -}}
    {{- $found = true -}}
    {{- range $keys -}}
      {{- if hasKey $subchartValue . -}}
        {{- $subchartValue = index $subchartValue . -}}
      {{- else -}}
        {{- $subchartValue = $default -}}
        {{- $found = false -}}
        {{- break -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if not $found -}}
    {{- $subchartValue = $default -}}
  {{- end -}}

  {{- $subchartValue -}}
{{- end -}}
