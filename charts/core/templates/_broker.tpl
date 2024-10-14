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


{{- define "core.nats.env" -}}
{{- if .Values.global.nats.enabled }}
- name: PUBLISHER_NATS_ENABLED
  value: '{{ .Values.global.nats.enabled }}'
- name: PUBLISHER_NATS_URL
  value: "{{ tpl .Values.global.nats.url $ }}"
- name: PUBLISHER_NATS_CLIENT_ID
  value: "{{ .Values.config.publisher.clientID}}"
- name: PUBLISHER_TOPIC_MAPPING
  value: "{{ .Values.config.publisher.topicMapping }}"
{{- end -}}
{{- end -}}