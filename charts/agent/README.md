# agent

![Version: 2.12.0](https://img.shields.io/badge/Version-2.12.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.7.0](https://img.shields.io/badge/AppVersion-v2.7.0-informational?style=flat-square)

Formance Membership Agent Helm Chart

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/agent>
* <https://github.com/formancehq/helm/charts/agent>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | 1.X |

## Values

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable global debug |
| global.monitoring.logs.enabled | bool | `true` | Enable logging |
| global.monitoring.logs.format | string | `"json"` | Format |
| global.monitoring.logs.level | string | `"info"` | Level: Info, Debug, Error |
| global.monitoring.traces.batch | bool | `false` | Enable otel batching |
| global.monitoring.traces.enabled | bool | `false` | Enable otel tracing |
| global.monitoring.traces.endpoint | string | `""` | Endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter |
| global.monitoring.traces.insecure | bool | `true` | Insecure |
| global.monitoring.traces.mode | string | `"grpc"` | Mode |
| global.monitoring.traces.port | int | `4317` | Port |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.serviceName | string | `"agent"` | TORework |
| affinity | object | `{}` |  |
| agent.authentication.clientID | string | `""` | Mode: Bearer |
| agent.authentication.clientSecret | string | `""` | Mode: Beare |
| agent.authentication.existingSecret | string | `""` | Existing Secret |
| agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| agent.authentication.mode | string | `"bearer"` | mode: token|bearer |
| agent.authentication.secretKeys.secret | string | `""` |  |
| agent.authentication.token | string | `""` | Mode: Token |
| agent.baseUrl | string | `""` |  |
| agent.id | string | `"b7549a16-f74a-4815-ab1e-bb8ef1c3833b"` |  |
| agent.outdated | bool | `false` | Any region: - this flag is sync by the server - it will mark the associated region as outdated and will block any new Creation/Enable/Restore |
| agent.production | bool | `false` | Only for public region This flag is not sync by the server |
| config.monitoring.serviceName | string | `"agent"` |  |
| debug | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/formancehq/agent"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| resources.limits.cpu | string | `"100m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| securityContext | object | `{}` |  |
| server.address | string | `"app.formance.cloud:443"` |  |
| server.tls.enabled | bool | `true` |  |
| server.tls.insecureSkipVerify | bool | `true` |  |
| serviceAccount.annotations | object | `{}` |  |
| tolerations | list | `[]` |  |
