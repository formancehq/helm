{{/*
   * 
    This now can be included in every chart folowing:
    
    global:
      debug: true
  
**/}}



{{- define "core.env.common" -}}
- name: DEBUG
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "debug" "Default" "false") | quote }}
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
{{- end -}}
