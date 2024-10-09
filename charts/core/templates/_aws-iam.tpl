{{/** 
    This now can be included in every chart folowing:
    
    global:
      aws:
        iam:
          enabled: true

    Each component who want to use IAM should include this snippet in their deployment.yaml
    We could decline it in the future to be more specific to a service
  
  
  **/}}

{{- define "aws.iam.postgres" }}
{{- if .Values.global.aws.iam }}
- name: POSTGRES_AWS_ENABLE_IAM
  value: "true"
{{- end }}
{{- end }}
