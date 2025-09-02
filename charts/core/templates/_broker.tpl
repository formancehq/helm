{{/** 
    This now can be included in every chart folowing:
    
    # Global configuration
    global:
      nats:
        enabled: true
        url: "nats://nats:4222"

    # Service specific
    nats:
      clientID: "publisher"
      topicMapping: "topic1:subject1,topic2:subject2"

    # We could integrate with a nats chart like bitami and follow their construction
  
**/}}


{{- define "core.nats.env" }}
- name: PUBLISHER_NATS_ENABLED
  value: '{{ .Values.global.nats.enabled }}'
{{- if .Values.global.nats.enabled }}
  {{- if .Values.global.nats.requestTimeout }}
- name: PUBLISHER_NATS_REQUEST_TIMEOUT
  value: {{ .Values.global.nats.requestTimeout | quote }}
  {{- else }}
  {{- end }}
  {{- if .Values.global.nats.auth.existingSecret }}
- name: PUBLISHER_NATS_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.nats.auth.existingSecret }}
      key: {{ .Values.global.nats.auth.secretKeys.username }}
- name: PUBLISHER_NATS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.nats.auth.existingSecret }}
      key: {{ .Values.global.nats.auth.secretKeys.password }}
  {{- else }}
- name: PUBLISHER_NATS_USERNAME
  value: {{ .Values.global.nats.auth.username | quote }}
- name: PUBLISHER_NATS_PASSWORD
  value: {{ .Values.global.nats.auth.password | quote }}
  {{- end }}
- name: PUBLISHER_NATS_URL
  value: "{{ tpl .Values.global.nats.url $ }}"
- name: PUBLISHER_NATS_CLIENT_ID
  value: "{{ .Values.config.publisher.clientID}}"
- name: PUBLISHER_TOPIC_MAPPING
  value: "{{ .Values.config.publisher.topicMapping }}"
{{- end }}
{{- end }}