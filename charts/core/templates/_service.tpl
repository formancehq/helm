{{/*
   * 
    This now can be included in every chart folowing:
    
    global:
      debug: true
  
**/}}



{{- define "core.env.common" -}}
- name: DEBUG
  value: {{ include "resolveGlobalOrServiceValue" (dict "Values" .Values "Key" "debug" "Default" "false") | quote }}
{{- end -}}
