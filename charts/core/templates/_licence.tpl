{{/**
  global:
    licence:
      createSecret: true
      clusterID: ""
      issuer: "https://license.formance.cloud/keys"
      token: ""
      existingSecret: ""
      secretKeys:
        token: "token"

  config:
    licence:
      createSecret: true
      clusterID: ""
      issuer: ""
      token: ""
      existingSecret: ""
      secretKeys:
        token: ""
**/}}
{{- define "core.licence.env" }}
{{- $enabled := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.enabled" "Default" "true") -}}
{{- if eq $enabled "true" }}
{{- $existingSecret := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.existingSecret" "Default" "") -}}
{{- $createSecret := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.createSecret" "Default" "false") -}}
{{- $secretName := "" -}}
{{- if $existingSecret -}}
  {{- $secretName = $existingSecret -}}
{{- else if eq $createSecret "true" -}}
  {{- $secretName = printf "%s-licence" .Release.Name -}}
{{- end }}
- name: LICENCE_TOKEN
  {{- if $secretName }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName | quote }}
      key: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.secretKeys.token" "Default" "token") | quote }}
  {{- else }}
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.token" "Default" "") | quote }}
  {{- end }}
- name: LICENCE_CLUSTER_ID
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.clusterID" "Default" "") | quote }}
- name: LICENCE_ISSUER
  {{- if $secretName }}
  valueFrom:
    secretKeyRef:
      name: {{ $secretName | quote }}
      key: "issuer"
  {{- else }}
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.issuer" "Default" "") | quote }}
  {{- end }}
{{- end }}
{{- end }}
