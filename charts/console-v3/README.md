# console-v3

![Version: 3.0.0-beta.15](https://img.shields.io/badge/Version-3.0.0--beta.15-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.0.0-beta.10](https://img.shields.io/badge/AppVersion-v2.0.0--beta.10-informational?style=flat-square)

Formance Console

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/console>

## Requirements

Kubernetes: `>=1.14.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | 1.X |

## Values

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.elb | bool | `false` | Enable AWS ELB across all services, appropriate <service>.aws.targertGroup must be set |
| global.aws.iam | bool | `false` | Enable AWS IAM Authentification |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable debug mode |
| global.monitoring.traces.batch | bool | `false` | Enable otel batching |
| global.monitoring.traces.enabled | bool | `false` | Enable otel tracing |
| global.monitoring.traces.endpoint | string | `""` | Endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter |
| global.monitoring.traces.insecure | bool | `true` | Insecure |
| global.monitoring.traces.mode | string | `"grpc"` | Mode |
| global.monitoring.traces.port | int | `4317` | Port |
| global.platform.consoleV3 | object | `{"host":"console.v3.{{ .Values.global.serviceHost }}","oauth":{"client":{"existingSecret":"","id":"console-v3","postLogoutRedirectUris":"- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/logout\n","redirectUris":"- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/login\n- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/login-by-org\n","scopes":["accesses","remember_me","keep_refresh_token","on_behalf"],"secret":"changeMe2","secretKeys":{"secret":""}}},"scheme":"https"}` | Console V3: EXPERIMENTAL |
| global.platform.consoleV3.host | string | `"console.v3.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.consoleV3.oauth.client.existingSecret | string | `""` | is the name of the secret |
| global.platform.consoleV3.oauth.client.id | string | `"console-v3"` | is the id of the client |
| global.platform.consoleV3.oauth.client.secret | string | `"changeMe2"` | is the secret of the client |
| global.platform.consoleV3.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.consoleV3.scheme | string | `"https"` | is the scheme for the console |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | is the host for the portal |
| global.platform.portal.scheme | string | `"https"` | is the scheme for the portal |
| global.postgresql.additionalArgs | string | `"sslmode=disable"` | Additional arguments for PostgreSQL Connection URI |
| global.postgresql.auth.database | string | `"formance"` | Name for a custom database to create (overrides `auth.database`) |
| global.postgresql.auth.existingSecret | string | `""` | Name of existing secret to use for PostgreSQL credentials (overrides `auth.existingSecret`). |
| global.postgresql.auth.password | string | `"formance"` | Password for the "postgres" admin user (overrides `auth.postgresPassword`) |
| global.postgresql.auth.postgresPassword | string | `"formance"` | Password for the custom user to create (overrides `auth.password`) |
| global.postgresql.auth.secretKeys.adminPasswordKey | string | `""` | Name of key in existing secret to use for PostgreSQL credentials (overrides `auth.secretKeys.adminPasswordKey`). Only used when `global.postgresql.auth.existingSecret` is set. |
| global.postgresql.auth.secretKeys.userPasswordKey | string | `""` | Name of key in existing secret to use for PostgreSQL credentials (overrides `auth.secretKeys.userPasswordKey`). Only used when `global.postgresql.auth.existingSecret` is set. |
| global.postgresql.auth.username | string | `"formance"` | Name for a custom user to create (overrides `auth.username`) |
| global.postgresql.host | string | `""` | Host for PostgreSQL (overrides included postgreql `host`) |
| global.postgresql.service.ports.postgresql | int | `5432` | PostgreSQL service port (overrides `service.ports.postgresql`) |
| global.serviceHost | string | `""` | is the base domain for portal and console |

### Stargate configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform.stargate.enabled | bool | `false` | if enabled, the stackApiUrl is not required It will be templated with `{{ printf "http://%s-%s:8080/#{organizationId}/#{stackId}/api" .Release.Name "stargate" -}}` |
| global.platform.stargate.stackApiUrl | string | `""` | if stargate is disabled, the stackApiUrl is defaulted to the `http://gateway.#{organizationId}-#{stackId}.svc:8080/api` To allow external access sets the stackApiUrl to an external url |

### Migration configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.migration.enabled | bool | `true` | Enable migration job with a separated user |

### Console configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config.postgresqlUrl | string | `""` | PostgreSQL connection URL override (if not set, will be generated from global.postgresql) |

### Membership Feature

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| feature.migrationHooks | bool | `false` | Run migration in a hook |

### Postgresql configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.enabled | bool | `false` | Enable postgresql |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Console affinity |
| annotations | object | `{}` | Console annotations  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| aws.targetGroups.http.ipAddressType | string | `"ipv4"` | Target group IP address type |
| aws.targetGroups.http.serviceRef.name | string | `"{{ include \"core.fullname\" $ }}"` | Target group service reference name |
| aws.targetGroups.http.serviceRef.port | string | `"{{ .Values.service.ports.http.port }}"` | Target group service reference port |
| aws.targetGroups.http.targetGroupARN | string | `""` | Target group ARN |
| aws.targetGroups.http.targetType | string | `"ip"` | Target group target type |
| config.additionalEnv | list | `[]` | Console additional environment variables |
| config.cookie.encryptionKey | string | `"changeMe00"` | is used to encrypt a cookie value |
| config.cookie.existingSecret | string | `""` | is the name of the secret |
| config.cookie.secretKeys | object | `{"encryptionKey":""}` | is the key contained within the secret |
| config.environment | string | `"production"` | Console environment |
| config.managedStack | string | `"1"` | Enable managed stack mode (1 = enabled, 0 = disabled) |
| config.migration.annotations | object | `{}` | Membership job migration annotations Argo CD translate `pre-install,pre-upgrade` to: argocd.argoproj.io/hook: PreSync |
| config.migration.serviceAccount.annotations | object | `{}` |  |
| config.migration.serviceAccount.create | bool | `true` |  |
| config.migration.serviceAccount.name | string | `""` |  |
| config.migration.ttlSecondsAfterFinished | string | `""` |  |
| config.migration.volumeMounts | list | `[]` |  |
| config.migration.volumes | list | `[]` |  |
| config.sentry | object | `{"authToken":{"existingSecret":"","secretKeys":{"value":""},"value":""},"dsn":"","enabled":false,"environment":"","release":""}` | Console additional environment variables FEATURE_DISABLED - name: FEATURE_DISABLED   value: "true" |
| config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| config.sentry.dsn | string | `""` | Sentry DSN |
| config.sentry.enabled | bool | `false` | Sentry enabled |
| config.sentry.environment | string | `""` | Sentry environment |
| config.sentry.release | string | `""` | Sentry release |
| config.stargate_url | string | `""` | Deprecated |
| image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| image.repository | string | `"ghcr.io/formancehq/console-v3"` | image repository |
| image.tag | string | `""` | image tag |
| imagePullSecrets | list | `[]` | image pull secrets |
| ingress.annotations | object | `{}` | ingress annotations |
| ingress.className | string | `""` | ingress class name |
| ingress.enabled | bool | `true` | ingress enabled |
| ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.consoleV3.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | ingress host |
| ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| ingress.labels | object | `{}` | ingress labels |
| ingress.tls | list | `[]` | ingress tls |
| livenessProbe | object | `{}` | Console liveness probe |
| nodeSelector | object | `{}` | Console node selector |
| podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| podSecurityContext | object | `{}` | Pod Security Context |
| readinessProbe | object | `{}` | Console readiness probe |
| replicas | int | `1` | Number of replicas |
| resources | object | `{}` | Console resources |
| securityContext | object | `{}` | Container Security Context |
| service.annotations | object | `{}` | service annotations |
| service.clusterIP | string | `""` | service cluster IP |
| service.ports.http | object | `{"port":3000}` | service http port |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Service account creation |
| serviceAccount.name | string | `""` | Service account name |
| tolerations | list | `[]` | Console tolerations |
| volumeMounts | list | `[]` | Console volume mounts |
| volumes | list | `[]` | Console volumes |
