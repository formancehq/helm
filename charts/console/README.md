# console

![Version: v1.0.0-beta.1](https://img.shields.io/badge/Version-v1.0.0--beta.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 9431e5f4b4b1a03cb8f02ef1676507b9c023f2bb](https://img.shields.io/badge/AppVersion-9431e5f4b4b1a03cb8f02ef1676507b9c023f2bb-informational?style=flat-square)

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
| file://../core | core | v1.0.0-beta.1 |

## Values

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable debug mode |
| global.platform.console.host | string | `"console.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.console.scheme | string | `"https"` | is the scheme for the console |
| global.platform.cookie.encryptionKey | string | `"changeMe00"` | is used to encrypt a cookie that share authentication between platform services (console, portal, ...),is used to store the current state organizationId-stackId |
| global.platform.cookie.existingSecret | string | `""` | is the name of the secret |
| global.platform.cookie.secretKeys | object | `{"encryptionKey":""}` | is the key contained within the secret |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.oauthClient.existingSecret | string | `""` | is the name of the secret |
| global.platform.membership.oauthClient.id | string | `"platform"` | is the id of the client |
| global.platform.membership.oauthClient.secret | string | `"changeMe1"` | is the secret of the client |
| global.platform.membership.oauthClient.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.membership.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | is the host for the portal |
| global.platform.portal.scheme | string | `"https"` | is the scheme for the portal |
| global.serviceHost | string | `""` | is the base domain for portal and console |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Console affinity |
| config.additionalEnv | object | `{}` | Console additional environment variables |
| config.environment | string | `"production"` | Console environment |
| config.monitoring | object | `{"traces":{"attributes":"","enabled":false,"port":4317,"url":""}}` | Otel collector configuration |
| config.monitoring.traces.attributes | string | `""` | Console monitoring traces attributes |
| config.monitoring.traces.enabled | bool | `false` | Console monitoring traces enabled |
| config.monitoring.traces.port | int | `4317` | Console monitoring traces port |
| config.monitoring.traces.url | string | `""` | Console monitoring traces url |
| image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| image.repository | string | `"ghcr.io/formancehq/console"` | image repository |
| image.tag | string | `"9431e5f4b4b1a03cb8f02ef1676507b9c023f2bb"` | image tag |
| ingress.annotations | object | `{}` | ingress annotations |
| ingress.className | string | `""` | ingress class name |
| ingress.enabled | bool | `true` | ingress enabled |
| ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.console.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | ingress host |
| ingress.hosts[0].paths[0].path | string | `"/"` | ingress path |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| ingress.tls | list | `[]` | ingress tls |
| livenessProbe | object | `{}` | Console liveness probe |
| nodeSelector | object | `{}` | Console node selector |
| readinessProbe | object | `{}` | Console readiness probe |
| replicas | int | `1` | Number of replicas |
| resources | object | `{}` | Console resources |
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

