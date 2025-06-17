{{- define "membership.auth.tokenValidities" }}
- name: TOKENS_VALIDITY_ACCESS
  value: "{{ .Values.config.auth.tokenValidity.accessToken }}"
- name: TOKENS_VALIDITY_REFRESH
  value: "{{ .Values.config.auth.tokenValidity.refreshToken }}"
{{- end }}

{{- define "membership.stack.cycle" }}
- name: STACK_PRUNING_DELAY
  value: "{{.Values.config.stack.cycle.delay.prune}}"
- name: STACK_PRUNING_POLLING_DELAY
  value: "{{.Values.config.stack.cycle.delay.prunePollingDelay}}"
- name: STACK_DISABLE_DELAY
  value: "{{.Values.config.stack.cycle.delay.disable}}"
- name: STACK_DISABLE_POLLING_DELAY
  value: "{{.Values.config.stack.cycle.delay.disablePollingDelay}}"
- name: STACK_DISPOSABLE_DELAY
  value: "{{.Values.config.stack.cycle.delay.disposable}}"
{{- end }}

{{- define "membership.stack.env" }}
{{- include "membership.stack.cycle" . }}
- name: STACK_MINIMAL_MODULES
  value: "{{ join " " .Values.config.stack.minimalStackModules}}"
{{- end }}

{{- define "membership.grpc.env" }}
{{- if and (not .Values.feature.managedStacks) (.Values.global.nats.enabled) }}
- name: GRPC_TLS_INSECURE
  value: "true"
- name: GRPC_H2C_ENABLED
  value: "true"
- name: GRPC_TOKEN
{{- if .Values.config.grpc.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.grpc.existingSecret }}
      key: {{ .Values.config.grpc.secretKeys.secret }}
{{- else }}
  value: '{{ join " " .Values.config.grpc.tokens }}'
{{- end }}
{{- end }}
{{- end }}

{{- define "membership.env" -}}
- name: DEV
  value: "{{.Values.dev}}"
- name: CONFIG
  value: "/config/config.yaml"
- name: LOGIN_WITH_SSO
  value: "{{.Values.config.auth.loginWithSSO}}"
{{- if .Values.dex.enabled }}
- name: RP_ISSUER
  value: "{{ tpl (printf "%s://%s%s" .Values.global.platform.membership.relyingParty.scheme .Values.global.platform.membership.relyingParty.host .Values.global.platform.membership.relyingParty.path) $ }}"
- name: RP_CLIENT_ID
  value: "{{ tpl .Values.config.oidc.clientId .}}"
- name: RP_CLIENT_SECRET
  {{- if gt (len .Values.config.oidc.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.oidc.existingSecret }}
      key: {{ .Values.config.oidc.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.config.oidc.clientSecret | quote }}
  {{- end }}
- name: RP_SCOPES
  value: "{{ join " " .Values.config.oidc.scopes }}"
{{- end }}
- name: SERVICE_URL
  value: "{{ tpl (printf "%s://%s/api" .Values.global.platform.membership.scheme .Values.global.platform.membership.host) $ }}"
- name: MANAGED_STACKS
  value: "{{.Values.feature.managedStacks}}"
- name: DISABLE_EVENTS
  value: "{{.Values.feature.disableEvents}}"
{{- if and .Values.global.platform.console.host .Values.global.platform.console.scheme }}
- name: CONSOLE_PUBLIC_BASEURL
  value: {{ tpl (default (printf "%s://%s" .Values.global.platform.console.scheme .Values.global.platform.console.host) .Values.config.redirect_url) $ }}
{{- end }}
{{- range $serviceName, $service := .Values.global.platform }}
{{- if and (and (hasKey $service "oauth") (hasKey $service.oauth "client")) $service.enabled }}
- name: {{ printf "%s_OAUTH_CLIENT_SECRET" (upper $serviceName) }}
  {{- if gt (len $service.oauth.client.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ $service.oauth.client.existingSecret }}
      key: {{ $service.oauth.client.secretKeys.secret }}
  {{- else }}
  value: {{ $service.oauth.client.secret | quote }}
  {{- end }}
{{- end -}}
{{- end }}
{{ include "core.env.common" . }}
{{- include "core.licence.env" . }}
{{- include "core.postgres.uri" . }}
{{- include "core.monitoring" . }}
{{- include "membership.grpc.env" . }}
{{- include "membership.stack.env" . }}
{{- if not .Values.feature.managedStacks }}
{{- include "core.nats.env" .  }}
{{- end }}
{{- include "membership.auth.tokenValidities" . }}
{{ with .Values.config.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end -}}

{{- define "dex-values" }}
issuer: "{{ tpl (printf "%s://%s%s" .Values.global.platform.membership.relyingParty.scheme .Values.global.platform.membership.relyingParty.host .Values.global.platform.membership.relyingParty.path) $ }}"
logger:
  format: "json"
storage:
    {{- if ((index .Values.dex.configOverrides "storage")) }}
    {{- if ((index .Values.dex.configOverrides.storage "type")) }}
    {{- if eq .Values.dex.configOverrides.storage.type "postgres" }}
  type: postgres
  config:
    {{- if .Values.postgresql.enabled }}
    host: {{ printf "%s.%s.svc" (include "postgresql.v1.primary.fullname" .Subcharts.postgresql) .Release.Namespace }}
    {{- else }}
    host: {{ .Values.global.postgresql.host }}
    {{- end }}
    port: {{ .Values.global.postgresql.service.ports.postgresql }}
    database: {{ .Values.global.postgresql.auth.database }}
    user: {{ .Values.global.postgresql.auth.username }}
    {{- if not .Values.global.postgresql.auth.existingSecret }}
    password: {{ .Values.global.postgresql.auth.password }}
    {{- else }}
    password: $POSTGRES_PASSWORD
    {{- end }}
    {{- if contains .Values.global.postgresql.additionalArgs "sslmode=disable" }}
    ssl:
      mode: disable
      {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

staticClients:
  - name: "membership"
    id: "{{ .Values.config.oidc.clientId }}"
    {{ if .Values.config.oidc.existingSecret }}
    secretEnv: MEMBERSHIP_CLIENT_SECRET
    {{ else }}
    secret: "{{ tpl .Values.config.oidc.clientSecret $ }}"
    {{ end }}
    redirectURIs:
      - "{{ .Values.global.platform.membership.scheme }}://{{ tpl .Values.global.platform.membership.host $ }}/api/authorize/callback"
{{- end }}


{{- define "membership.job.serviceAccountName" -}}
{{- if .Values.config.migration.serviceAccount.create }}
{{- default (printf "%s-%s" (include "core.fullname" .) "migrate") .Values.config.migration.serviceAccount.name }}
{{- else }}
{{- default "default-migrate" .Values.config.migration.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "job.postgres.uri" -}}
{{- include "aws.iam.postgres" . }}
- name: POSTGRES_USERNAME
  value: {{ default .Values.global.postgresql.auth.username .Values.config.migration.postgresql.auth.username }}
{{- if and (or .Values.global.postgresql.auth.existingSecret .Values.config.migration.postgresql.auth.existingSecret) (not .Values.config.postgresqlUrl) }}
  {{- if (not .Values.global.aws.iam) }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ default .Values.global.postgresql.auth.existingSecret .Values.config.migration.postgresql.auth.existingSecret }}
      key: {{ default .Values.global.postgresql.auth.secretKeys.adminPasswordKey .Values.config.migration.postgresql.auth.secretKeys.adminPasswordKey }}
  {{- end }}
{{- else if (not .Values.global.aws.iam) }}
- name: POSTGRES_PASSWORD
  value: {{ default .Values.global.postgresql.auth.password .Values.config.migration.postgresql.auth.password }}
{{- end }}
- name: POSTGRES_URI
{{- if .Values.config.postgresqlUrl }}
  value: "{{ .Values.config.postgresqlUrl }}"
{{- else }}
  {{- $host := .Values.global.postgresql.host }}
  {{- if .Values.global.aws.iam }}
  value: "postgresql://$(POSTGRES_USERNAME)@{{ $host }}:{{.Values.global.postgresql.service.ports.postgresql}}/{{.Values.global.postgresql.auth.database}}{{- if .Values.global.postgresql.additionalArgs}}?{{.Values.global.postgresql.additionalArgs}}{{- end -}}"
  {{- else if .Values.postgresql.enabled }}
  value: "postgresql://$(POSTGRES_USERNAME):$(POSTGRES_PASSWORD)@{{ printf "%s.%s.svc" (include "postgresql.v1.primary.fullname" .Subcharts.postgresql) .Release.Namespace }}:{{.Values.global.postgresql.service.ports.postgresql}}/{{.Values.global.postgresql.auth.database}}{{- if .Values.global.postgresql.additionalArgs}}?{{.Values.global.postgresql.additionalArgs}}{{- end -}}"
  {{- else }}
  value: "postgresql://$(POSTGRES_USERNAME):$(POSTGRES_PASSWORD)@{{ $host }}:{{.Values.global.postgresql.service.ports.postgresql}}/{{.Values.global.postgresql.auth.database}}{{- if .Values.global.postgresql.additionalArgs}}?{{.Values.global.postgresql.additionalArgs}}{{- end -}}"
  {{- end }}
{{- end }}
{{- end }}

{{/**
  
    This way is only reliable when using helm install and helm upgrade.
    ArgoCD use helm template
  
  **/}}
{{- define "migrations.job.annotations" -}}
{{- if and (not .Release.IsInstall) .Values.feature.migrationHooks }}
helm.sh/hook: pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded,hook-failed
helm.sh/hook-weight: "10"
{{- end }}
{{- end }}

{{- define "migrations.job.sa.annotations" -}}
{{- if and (not .Release.IsInstall) .Values.feature.migrationHooks }}
helm.sh/hook: pre-upgrade
helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded,hook-failed
helm.sh/hook-weight: "-10"
{{- end }}
{{- end }}