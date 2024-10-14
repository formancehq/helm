# agent

![Version: v2.1.0](https://img.shields.io/badge/Version-v2.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.1.0](https://img.shields.io/badge/AppVersion-v2.1.0-informational?style=flat-square)

Formance Membership Agent Helm Chart

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/agent>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| agent.authentication.clientID | string | `""` |  |
| agent.authentication.clientSecret | string | `""` |  |
| agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| agent.authentication.mode | string | `"bearer"` |  |
| agent.baseUrl | string | `""` |  |
| agent.id | string | `"b7549a16-f74a-4815-ab1e-bb8ef1c3833b"` |  |
| agent.production | bool | `false` |  |
| config.monitoring.serviceName | string | `"agent"` |  |
| debug | bool | `false` |  |
| fullnameOverride | string | `""` |  |
| global.monitoring.logs.format | string | `"json"` |  |
| global.serviceName | string | `"agent"` |  |
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

