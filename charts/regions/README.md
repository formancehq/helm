# regions

![Version: v2.1.0-beta.1](https://img.shields.io/badge/Version-v2.1.0--beta.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Formance Private Regions Helm Chart

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/operator>
* <https://github.com/formancehq/agent>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../agent | agent | v2.1.0-beta.1 |
| file://../operator | operator | v2.1.0-beta.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.monitoring.logs.format | string | `"json"` |  |
| global.serviceName | string | `"agent"` |  |
| agent.agent.authentication.clientID | string | `"REGION_ID"` |  |
| agent.agent.authentication.clientSecret | string | `""` |  |
| agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| agent.agent.authentication.mode | string | `"bearer"` |  |
| agent.agent.baseUrl | string | `"https://sandbox.formance.cloud"` |  |
| agent.agent.id | string | `"aws-eu-west-1-sandbox"` |  |
| agent.enabled | bool | `false` |  |
| agent.image.tag | string | `"v2.1.0-beta.1"` |  |
| agent.server.address | string | `"app.formance.cloud:443"` |  |
| agent.server.tls.enabled | bool | `true` |  |
| agent.server.tls.insecureSkipVerify | bool | `true` |  |
| operator.enabled | bool | `true` |  |
| operator.fullnameOverride | string | `"operator"` |  |
| operator.image.repository | string | `"ghcr.io/formancehq/operator"` |  |
| operator.image.tag | string | `"v2.1.0-beta.1"` |  |
| operator.nameOverride | string | `"operator"` |  |
| operator.operator-crds.create | bool | `true` |  |
| operator.operator.disableWebhooks | bool | `false` |  |
| operator.operator.enableLeaderElection | bool | `true` |  |
| operator.operator.env | string | `"private"` |  |
| operator.operator.licence.create | bool | `true` |  |
| operator.operator.licence.issuer | string | `""` |  |
| operator.operator.licence.secretName | string | `""` |  |
| operator.operator.licence.token | string | `""` |  |
| operator.operator.metricsAddr | string | `":8080"` |  |
| operator.operator.probeAddr | string | `":8081"` |  |
| operator.operator.region | string | `"private"` |  |
| versions.create | bool | `true` |  |
| versions.files."v1.0".auth | string | `"v0.4.4"` |  |
| versions.files."v1.0".gateway | string | `"v2.0.17"` |  |
| versions.files."v1.0".ledger | string | `"v1.10.14"` |  |
| versions.files."v1.0".operator-utils | string | `"v2.0.17"` |  |
| versions.files."v1.0".orchestration | string | `"v0.2.1"` |  |
| versions.files."v1.0".payments | string | `"v1.0.0-rc.5"` |  |
| versions.files."v1.0".reconciliation | string | `"v0.1.0"` |  |
| versions.files."v1.0".search | string | `"v0.10.0"` |  |
| versions.files."v1.0".stargate | string | `"v0.1.10"` |  |
| versions.files."v1.0".wallets | string | `"v0.4.6"` |  |
| versions.files."v1.0".webhooks | string | `"v2.0.17"` |  |
| versions.files."v2.0".auth | string | `"v2.0.17"` |  |
| versions.files."v2.0".gateway | string | `"v2.0.17"` |  |
| versions.files."v2.0".ledger | string | `"v2.0.17"` |  |
| versions.files."v2.0".operator-utils | string | `"v2.0.17"` |  |
| versions.files."v2.0".orchestration | string | `"v2.0.17"` |  |
| versions.files."v2.0".payments | string | `"v2.0.17"` |  |
| versions.files."v2.0".reconciliation | string | `"v2.0.17"` |  |
| versions.files."v2.0".search | string | `"v2.0.17"` |  |
| versions.files."v2.0".stargate | string | `"v2.0.17"` |  |
| versions.files."v2.0".wallets | string | `"v2.0.17"` |  |
| versions.files."v2.0".webhooks | string | `"v2.0.17"` |  |
| versions.files."v2.1".auth | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".gateway | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".ledger | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".operator-utils | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".orchestration | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".payments | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".reconciliation | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".search | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".stargate | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".wallets | string | `"v2.1.0-beta.1"` |  |
| versions.files."v2.1".webhooks | string | `"v2.1.0-beta.1"` |  |
| versions.files.default.auth | string | `"v0.4.4"` |  |
| versions.files.default.gateway | string | `"v2.0.17"` |  |
| versions.files.default.ledger | string | `"v1.10.14"` |  |
| versions.files.default.operator-utils | string | `"v2.0.17"` |  |
| versions.files.default.orchestration | string | `"v0.2.1"` |  |
| versions.files.default.payments | string | `"v1.0.0-rc.5"` |  |
| versions.files.default.reconciliation | string | `"v0.1.0"` |  |
| versions.files.default.search | string | `"v0.10.0"` |  |
| versions.files.default.stargate | string | `"v0.1.10"` |  |
| versions.files.default.wallets | string | `"v0.4.6"` |  |
| versions.files.default.webhooks | string | `"v2.0.17"` |  |
| agent.affinity | object | `{}` |  |
| agent.agent.authentication.clientID | string | `""` |  |
| agent.agent.authentication.clientSecret | string | `""` |  |
| agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| agent.agent.authentication.mode | string | `"bearer"` |  |
| agent.agent.baseUrl | string | `""` |  |
| agent.agent.id | string | `"b7549a16-f74a-4815-ab1e-bb8ef1c3833b"` |  |
| agent.agent.production | bool | `false` |  |
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
| operator.affinity | object | `{}` |  |
| operator.fullnameOverride | string | `""` |  |
| operator.image.pullPolicy | string | `"IfNotPresent"` |  |
| operator.image.repository | string | `"ghcr.io/formancehq/operator"` |  |
| operator.image.tag | string | `""` |  |
| operator.imagePullSecrets | list | `[]` |  |
| operator.kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| operator.kubeRbacProxy.image.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` |  |
| operator.kubeRbacProxy.image.tag | string | `"v0.15.0"` |  |
| operator.nameOverride | string | `""` |  |
| operator.nodeSelector | object | `{}` |  |
| operator.operator-crds.create | bool | `true` |  |
| operator.operator.dev | bool | `false` |  |
| operator.operator.enableLeaderElection | bool | `true` |  |
| operator.operator.env | string | `"staging"` |  |
| operator.operator.licence.create | bool | `true` |  |
| operator.operator.licence.issuer | string | `""` |  |
| operator.operator.licence.secretName | string | `""` |  |
| operator.operator.licence.token | string | `""` |  |
| operator.operator.metricsAddr | string | `":8080"` |  |
| operator.operator.probeAddr | string | `":8081"` |  |
| operator.operator.region | string | `"eu-west-1"` |  |
| operator.operator.utils.tag | string | `"v2.0.14"` |  |
| operator.podAnnotations | object | `{}` |  |
| operator.podSecurityContext | object | `{}` |  |
| operator.replicaCount | int | `1` |  |
| operator.resources | object | `{}` |  |
| operator.securityContext | object | `{}` |  |
| operator.tolerations | list | `[]` |  |
| operator.webhooks.enabled | bool | `false` |  |

