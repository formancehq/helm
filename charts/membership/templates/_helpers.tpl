{{- define "membership.auth.tokenValidities" -}}
- name: TOKENS_VALIDITY_ACCESS
  value: "{{ .Values.config.auth.tokenValidity.accessToken }}"
- name: TOKENS_VALIDITY_REFRESH
  value: "{{ .Values.config.auth.tokenValidity.refreshToken }}"
{{- end -}}

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

{{- define "membership.grpc.env" -}}
{{- if not .Values.feature.managedStacks }}
- name: GRPC_TLS_INSECURE
  value: "{{ .Values.config.agent.grpc.tls.insecure }}"
- name: GRPC_H2C_ENABLED
  value: "{{ .Values.config.agent.grpc.h2c }}"
- name: GRPC_TOKEN
{{- if .Values.config.agent.grpc.existingSecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.config.agent.grpc.existingSecret }}
      key: {{ .Values.config.agent.grpc.secretKeys.secret }}
{{- else }}
  value: '{{ join " " .Values.config.agent.grpc.tokens }}'
{{- end }}
{{- end }}
{{- end -}}

{{- define "membership.env" -}}
- name: DEBUG
  value: "{{.Values.debug}}"
- name: DEV
  value: "{{.Values.dev}}"
- name: CONFIG
  value: "/config/config.yaml"
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
- name: PLATFORM_OAUTH_CLIENT_SECRET
  {{- if gt (len .Values.global.platform.membership.oauthClient.existingSecret) 0 }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.global.platform.membership.oauthClient.existingSecret }}
      key: {{ .Values.global.platform.membership.oauthClient.secretKeys.secret }}
  {{- else }}
  value: {{ .Values.global.platform.membership.oauthClient.secret | quote }}
  {{- end }}
{{- include "core.postgres.uri" . }}
{{- include "core.monitoring" . }}
{{- include "membership.grpc.env" . }}
{{ include "membership.auth.tokenValidities" . }}
{{- with .Values.additionalEnv }}
{{- tpl (toYaml .) $ }}
{{- end }}
{{- end }}

{{ define "render-value" }}
  {{- if kindIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}     
  {{- end }}
{{- end }}

{{ define "dex-values" }}
issuer: "{{ tpl (printf "%s://%s" .Values.global.platform.membership.relyingParty.scheme .Values.global.platform.membership.relyingParty.host) $ }}"
logger:
  # -- logger format
  # @section -- Dex configuration
  format: "json"
storage:
  # -- storage type
  # @section -- Dex configuration
  type: postgres
  config:
    # -- storage config host
    # @section -- Dex configuration
    host: '{{.Values.global.postgresql.host | default (printf "%s.%s.svc" (include "postgresql.v1.primary.fullname" .Subcharts.postgresql) .Release.Namespace ) }}'
    # -- (number) storage config port, cannot be templated from other values
    # @section -- Dex configuration
    port: {{ .Values.global.postgresql.service.ports.postgresql }} # @schema type:number
    # -- storage config database
    # @section -- Dex configuration
    database: "{{.Values.global.postgresql.auth.database }}"
    # -- storage config user
    # @section -- Dex configuration
    user: formance
    # -- storage config password
    # @section -- Dex configuration
    password: formance
    ssl:
      # -- storage config ssl mode
      # @section -- Dex configuration
      mode: disable

staticClients:
  - # -- static clients name
    # @section -- Dex configuration
    name: "membership"
    # -- static clients id
    # @section -- Dex configuration
    id: "{{ .Values.config.oidc.clientId }}"
    {{ if .Values.config.oidc.existingSecret }}
    # -- static clients secret env var, do not use secret and secretEnv at the same time
    # -- According to dex.envVars
    # @section -- Dex configuration
    secretEnv: MEMBERSHIP_CLIENT_SECRET
    {{ else }}
    # -- static clients secret
    # @section -- Dex configuration
    secret: "{{ tpl .Values.config.oidc.clientSecret $ }}"
    {{ end }}
    # -- static clients redirect uris
    # @section -- Dex configuration
    redirectURIs:
      - "{{ .Values.global.platform.membership.scheme }}://{{ tpl .Values.global.platform.membership.host $ }}/api/authorize/callback"
{{- end }}
