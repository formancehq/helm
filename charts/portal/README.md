# portal

![Version: 3.0.0-beta.5](https://img.shields.io/badge/Version-3.0.0--beta.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.17.5](https://img.shields.io/badge/AppVersion-v1.17.5-informational?style=flat-square)

Formance Portal

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/platform-ui>

## Requirements

Kubernetes: `>=1.14.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | 1.X |

## Values

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.elb | bool | `false` | Enable AWS ELB |
| aws | object | `{"targetGroups":{"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Portal target groups |

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
| global.platform.consoleV3.enabled | bool | `true` | Enable console-v3  |
| global.platform.consoleV3.host | string | `"console.v3.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.consoleV3.scheme | string | `"https"` | is the scheme for the console |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | is the host for the portal |
| global.platform.portal.oauth.client.existingSecret | string | `""` | is the name of the secret |
| global.platform.portal.oauth.client.id | string | `"portal"` | is the id of the client |
| global.platform.portal.oauth.client.secret | string | `"changeMe1"` | is the secret of the client |
| global.platform.portal.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.portal.scheme | string | `"https"` | is the scheme for the portal |
| global.serviceHost | string | `""` | is the base domain for portal and console |

### Stargate configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform.stargate.enabled | bool | `false` | if enabled, the stackApiUrl is not required It will be templated with `{{ printf "http://%s-%s:8080/#{organizationId}/#{stackId}/api" .Release.Name "stargate" -}}` |
| global.platform.stargate.stackApiUrl | string | `""` | if stargate is disabled, the stackApiUrl is defaulted to the `http://gateway.#{organizationId}-#{stackId}.svc:8080/api` To allow external access sets the stackApiUrl to an external url |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform.portal.oauth.client.postLogoutRedirectUris | string | `"- {{ tpl (printf \"%s://%s\" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) $ }}/auth/logout\n"` |  |
| global.platform.portal.oauth.client.redirectUris | string | `"- {{ tpl (printf \"%s://%s\" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) $ }}/auth/login\n- {{ tpl (printf \"%s://%s\" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) $ }}/auth/login-by-org\n"` |  |
| global.platform.portal.oauth.client.scopes[0] | string | `"accesses"` |  |
| global.platform.portal.oauth.client.scopes[1] | string | `"remember_me"` |  |
| global.platform.portal.oauth.client.scopes[2] | string | `"keep_refresh_token"` |  |
| global.platform.portal.oauth.client.scopes[3] | string | `"on_behalf"` |  |
| affinity | object | `{}` | Portal affinity |
| annotations | object | `{}` | Portal annotations  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| config.additionalEnv | list | `[]` | Additional environment variables |
| config.cookie.existingSecret | string | `""` | Cookie existing secret |
| config.cookie.secret | string | `"changeMe2"` | Cookie secret |
| config.cookie.secretKeys | object | `{"secret":""}` | Cookie secret key |
| config.environment | string | `"production"` | Portal environment |
| config.featuresDisabled | list | `[]` |  |
| config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| config.sentry.dsn | string | `""` | Sentry DSN |
| config.sentry.enabled | bool | `false` | Sentry enabled |
| config.sentry.environment | string | `""` | Sentry environment |
| config.sentry.release | string | `""` | Sentry release |
| image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| image.repository | string | `"ghcr.io/formancehq/portal"` | image repository |
| image.tag | string | `""` | image tag |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` | ingress annotations |
| ingress.className | string | `""` | ingress class name |
| ingress.enabled | bool | `true` | ingress enabled |
| ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.portal.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | ingress host |
| ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| ingress.labels | object | `{}` | ingress labels |
| ingress.tls | list | `[]` | ingress tls |
| livenessProbe | object | `{}` | Portal liveness probe |
| nodeSelector | object | `{}` | Portal node selector |
| podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| podSecurityContext | object | `{}` | Pod Security Context |
| readinessProbe | object | `{}` | Portal readiness probe |
| replicas | int | `1` | Number of replicas |
| resources | object | `{}` | Portal resources |
| securityContext | object | `{}` | Container Security Context |
| service.annotations | object | `{}` | service annotations |
| service.clusterIP | string | `""` | service cluster IP |
| service.ports.http | object | `{"port":3000}` | service http port |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Service account creation |
| serviceAccount.name | string | `""` | Service account name |
| tolerations | list | `[]` | Portal tolerations |
| volumeMounts | list | `[]` |  |
| volumes | list | `[]` | Portal volumes |
