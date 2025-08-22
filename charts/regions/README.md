# Formance regions Helm chart

![Version: 2.22.0](https://img.shields.io/badge/Version-2.22.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)
Formance Private Regions Helm Chart

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../agent | agent | 2.X |
| oci://ghcr.io/formancehq/helm | operator | 2.X |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/operator>
* <https://github.com/formancehq/agent>

## Migration

#### EE Licence

Membership now need a EE licence. You can get a licence from the Formance team. The licence is valid for 1 cluster.
Then configure it through the `global.licence.token` and `global.licence.clusterID` values. See [Licence configuration](#licence-configuration) for more information.

**Homepage:** <https://formance.com>

## Values

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable global debug |
| global.monitoring.batch | bool | `false` | Enable otel batching |
| global.monitoring.logs.enabled | bool | `true` | Enable logging |
| global.monitoring.logs.format | string | `"json"` | Format |
| global.monitoring.logs.level | string | `"info"` | Level: Info, Debug, Error |
| global.monitoring.traces.enabled | bool | `false` | Enable otel tracing |
| global.monitoring.traces.endpoint | string | `""` | Endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter |
| global.monitoring.traces.insecure | bool | `true` | Insecure |
| global.monitoring.traces.mode | string | `"grpc"` | Mode |
| global.monitoring.traces.port | int | `4317` | Port |

### Licence configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.licence.clusterID | string | `""` | Obtain your licence cluster id with `kubectl get ns kube-system -o jsonpath='{.metadata.uid}'` |
| global.licence.createSecret | bool | `true` | Licence Secret with label `formance.com/stack: any` |
| global.licence.existingSecret | string | `""` | Licence Client Token as a secret |
| global.licence.issuer | string | `"https://license.formance.cloud/keys"` | Licence Environment  |
| global.licence.secretKeys.token | string | `"token"` | Hardcoded in the operator |
| global.licence.token | string | `""` | Licence Client Token delivered by contacting [Formance](https://formance.com) |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.serviceName | string | `"agent"` | TORework |
| agent.agent.authentication.clientID | string | `"REGION_ID"` |  |
| agent.agent.authentication.clientSecret | string | `""` |  |
| agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| agent.agent.authentication.mode | string | `"bearer"` |  |
| agent.agent.baseUrl | string | `"https://sandbox.formance.cloud"` |  |
| agent.agent.id | string | `"aws-eu-west-1-sandbox"` |  |
| agent.enabled | bool | `false` |  |
| agent.image.tag | string | `""` |  |
| agent.server.address | string | `"app.formance.cloud:443"` |  |
| agent.server.tls.enabled | bool | `true` |  |
| agent.server.tls.insecureSkipVerify | bool | `true` |  |
| operator.enabled | bool | `true` |  |
| operator.fullnameOverride | string | `"operator"` |  |
| operator.image.repository | string | `"ghcr.io/formancehq/operator"` |  |
| operator.image.tag | string | `""` |  |
| operator.nameOverride | string | `"operator"` |  |
| operator.operator-crds.create | bool | `true` |  |
| operator.operator.disableWebhooks | bool | `false` |  |
| operator.operator.enableLeaderElection | bool | `true` |  |
| operator.operator.env | string | `"private"` |  |
| operator.operator.metricsAddr | string | `":8080"` |  |
| operator.operator.probeAddr | string | `":8081"` |  |
| operator.operator.region | string | `"private"` |  |
| versions.create | bool | `true` |  |
| versions.files."v1.0".auth | string | `"v0.4.4"` |  |
| versions.files."v1.0".gateway | string | `"v2.0.18"` |  |
| versions.files."v1.0".ledger | string | `"v1.10.14"` |  |
| versions.files."v1.0".orchestration | string | `"v0.2.1"` |  |
| versions.files."v1.0".payments | string | `"v1.0.0-rc.5"` |  |
| versions.files."v1.0".reconciliation | string | `"v0.1.0"` |  |
| versions.files."v1.0".search | string | `"v0.10.0"` |  |
| versions.files."v1.0".stargate | string | `"v0.1.10"` |  |
| versions.files."v1.0".wallets | string | `"v0.4.6"` |  |
| versions.files."v1.0".webhooks | string | `"v2.0.18"` |  |
| versions.files."v2.0".auth | string | `"v2.3.0"` |  |
| versions.files."v2.0".gateway | string | `"v2.0.24"` |  |
| versions.files."v2.0".ledger | string | `"v2.0.24"` |  |
| versions.files."v2.0".orchestration | string | `"v2.0.24"` |  |
| versions.files."v2.0".payments | string | `"v2.0.31"` |  |
| versions.files."v2.0".reconciliation | string | `"v2.0.24"` |  |
| versions.files."v2.0".search | string | `"v2.0.24"` |  |
| versions.files."v2.0".stargate | string | `"v2.0.24"` |  |
| versions.files."v2.0".wallets | string | `"v2.0.24"` |  |
| versions.files."v2.0".webhooks | string | `"v2.0.24"` |  |
| versions.files."v2.1".auth | string | `"v2.3.0"` |  |
| versions.files."v2.1".gateway | string | `"v2.0.24"` |  |
| versions.files."v2.1".ledger | string | `"v2.1.7"` |  |
| versions.files."v2.1".orchestration | string | `"v2.0.24"` |  |
| versions.files."v2.1".payments | string | `"v2.0.31"` |  |
| versions.files."v2.1".reconciliation | string | `"v2.0.24"` |  |
| versions.files."v2.1".search | string | `"v2.0.24"` |  |
| versions.files."v2.1".stargate | string | `"v2.0.24"` |  |
| versions.files."v2.1".wallets | string | `"v2.1.5"` |  |
| versions.files."v2.1".webhooks | string | `"v2.1.0"` |  |
| versions.files."v2.2".auth | string | `"v2.3.0"` |  |
| versions.files."v2.2".gateway | string | `"v2.0.24"` |  |
| versions.files."v2.2".ledger | string | `"v2.2.47"` |  |
| versions.files."v2.2".orchestration | string | `"v2.0.24"` |  |
| versions.files."v2.2".payments | string | `"v2.0.31"` |  |
| versions.files."v2.2".reconciliation | string | `"v2.0.24"` |  |
| versions.files."v2.2".search | string | `"v2.0.24"` |  |
| versions.files."v2.2".stargate | string | `"v2.0.24"` |  |
| versions.files."v2.2".wallets | string | `"v2.1.5"` |  |
| versions.files."v2.2".webhooks | string | `"v2.1.0"` |  |
| versions.files."v3.0".auth | string | `"v2.3.0"` |  |
| versions.files."v3.0".gateway | string | `"v2.1.0"` |  |
| versions.files."v3.0".ledger | string | `"v2.2.47"` |  |
| versions.files."v3.0".orchestration | string | `"v2.1.1"` |  |
| versions.files."v3.0".payments | string | `"v3.0.18"` |  |
| versions.files."v3.0".reconciliation | string | `"v2.1.0"` |  |
| versions.files."v3.0".search | string | `"v2.1.0"` |  |
| versions.files."v3.0".stargate | string | `"v2.1.0"` |  |
| versions.files."v3.0".wallets | string | `"v2.1.5"` |  |
| versions.files."v3.0".webhooks | string | `"v2.1.0"` |  |
| versions.files.default.auth | string | `"v0.4.4"` |  |
| versions.files.default.gateway | string | `"v2.0.18"` |  |
| versions.files.default.ledger | string | `"v1.10.14"` |  |
| versions.files.default.orchestration | string | `"v0.2.1"` |  |
| versions.files.default.payments | string | `"v1.0.0-rc.5"` |  |
| versions.files.default.reconciliation | string | `"v0.1.0"` |  |
| versions.files.default.search | string | `"v0.10.0"` |  |
| versions.files.default.stargate | string | `"v0.1.10"` |  |
| versions.files.default.wallets | string | `"v0.4.6"` |  |
| versions.files.default.webhooks | string | `"v2.0.18"` |  |
| agent.affinity | object | `{}` |  |
| agent.agent.authentication.clientID | string | `""` | Mode: Bearer |
| agent.agent.authentication.clientSecret | string | `""` | Mode: Beare |
| agent.agent.authentication.existingSecret | string | `""` | Existing Secret |
| agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| agent.agent.authentication.mode | string | `"bearer"` | mode: token|bearer |
| agent.agent.authentication.secretKeys.secret | string | `""` |  |
| agent.agent.authentication.token | string | `""` | Mode: Token |
| agent.agent.baseUrl | string | `""` |  |
| agent.agent.id | string | `"b7549a16-f74a-4815-ab1e-bb8ef1c3833b"` |  |
| agent.agent.outdated | bool | `false` | Any region: - this flag is sync by the server - it will mark the associated region as outdated and will block any new Creation/Enable/Restore |
| agent.agent.production | bool | `false` | Only for public region This flag is not sync by the server |
| agent.config.monitoring.serviceName | string | `"agent"` |  |
| agent.debug | bool | `false` |  |
| agent.fullnameOverride | string | `""` |  |
| agent.image.pullPolicy | string | `"IfNotPresent"` |  |
| agent.image.repository | string | `"ghcr.io/formancehq/agent"` |  |
| agent.image.tag | string | `""` |  |
| agent.imagePullSecrets | list | `[]` |  |
| agent.nameOverride | string | `""` |  |
| agent.nodeSelector | object | `{}` |  |
| agent.podAnnotations | object | `{}` |  |
| agent.podSecurityContext | object | `{}` |  |
| agent.resources.limits.cpu | string | `"100m"` |  |
| agent.resources.limits.memory | string | `"128Mi"` |  |
| agent.resources.requests.cpu | string | `"100m"` |  |
| agent.resources.requests.memory | string | `"128Mi"` |  |
| agent.securityContext | object | `{}` |  |
| agent.server.address | string | `"app.formance.cloud:443"` |  |
| agent.server.tls.enabled | bool | `true` |  |
| agent.server.tls.insecureSkipVerify | bool | `true` |  |
| agent.serviceAccount.annotations | object | `{}` |  |
| agent.tolerations | list | `[]` |  |
