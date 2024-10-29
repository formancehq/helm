{{/** 
    This now can be included in every chart folowing:
    
    global:
      aws:
        elb:
          enabled: true

    aws:
      targetGroups:
        http:
          ipAddressType: ipv4
          targetType: ip
          serviceRefName: "{{ include "core.fullname" . }}-http"
          serviceRefPort: "{{ .Values.service.port }}"
          targetGroup: ""
        grpc:
          ipAddressType: ipv4
          targetType: ip
  
**/}}


{{- define "aws.tgb.generics" -}}
{{ $ := index . 0 }}
{{ $data := index . 1 }}
{{- range $k,$v := $data }}
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: {{ include "core.fullname" $ }}-{{ $k }}
  namespace: {{ $.Release.Namespace }}
  labels:
    {{- include "core.labels" $ | nindent 4 }}
spec:
  ipAddressType: {{ $v.ipAddressType }}
  serviceRef:
    name: {{ tpl $v.serviceRef.name $ }}
    port: {{ tpl $v.serviceRef.port $ }}
  targetGroupARN: {{ $v.targetGroupARN }}
  targetType: {{ $v.targetType }}
---
{{- end -}}
{{- end -}}