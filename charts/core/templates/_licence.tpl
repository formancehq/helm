{{/** 
  global:
    # Add your license information 
    licence:
      # -- Obtain your licence cluster id with `kubectl get ns kube-system -o jsonpath='{.metadata.uid}'`
      # @section -- Licence configuration
      clusterID: ""
      # -- Licence Environment 
      # @section -- Licence configuration
      issuer: "https://license.formance.cloud/keys"
      # -- Licence Client Token delivered by contacting [Formance](https://formance.com)
      # @section -- Licence configuration
      token: ""
      # -- Licence Client Token as a secret
      # @section -- Licence configuration
      existingSecret: ""
      secretKeys:
        # -- Key in existing secret to use for Licence Client Token
        # @section -- Licence configuration
        token: ""
    
  config:
    licence:
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
- name: LICENCE_TOKEN
  {{- $value := include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.existingSecret" "Default" "") -}}
  {{- if $value }}
  valueFrom:
    secretKeyRef:
      name: {{ $value | quote }}
      key: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.secretKeys.token" "Default" "") | quote }}
  {{- else }}
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.token" "Default" "") | quote }}
  {{- end }}
- name: LICENCE_CLUSTER_ID
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.clusterID" "Default" "") | quote}}
- name: LICENCE_ISSUER
  value: {{ include "resolveGlobalOrServiceValue" (dict "Context" . "Key" "licence.issuer" "Default" "") | quote}}
{{- end }}
{{- end }}