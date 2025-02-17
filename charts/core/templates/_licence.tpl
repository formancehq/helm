{{/** 
    global:
      licence:
        token: ""
        clusterID: ""
        issuer: ""
    
    config:
      licence:
        token: ""
        clusterID: ""
        issuer: ""
**/}}
{{- define "core.licence.env" }}
- name: LICENCE_TOKEN
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.token" "Default" "") | quote}}
- name: LICENCE_CLUSTER_ID
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.clusterID" "Default" "") | quote}}
- name: LICENCE_ISSUER
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.issuer" "Default" "") | quote}}
{{- end }}