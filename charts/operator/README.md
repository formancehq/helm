# operator

![Version: v2.0.19](https://img.shields.io/badge/Version-v2.0.19-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v2.0.19](https://img.shields.io/badge/AppVersion-v2.0.19-informational?style=flat-square)

Formance Operator Helm Chart

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/operator>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../operator-crds | operator-crds | v2.0.19 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/formancehq/operator"` |  |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.15.0"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| operator-crds.create | bool | `true` |  |
| operator.dev | bool | `false` |  |
| operator.enableLeaderElection | bool | `true` |  |
| operator.env | string | `"staging"` |  |
| operator.licence.create | bool | `true` |  |
| operator.licence.issuer | string | `""` |  |
| operator.licence.secretName | string | `""` |  |
| operator.licence.token | string | `""` |  |
| operator.metricsAddr | string | `":8080"` |  |
| operator.probeAddr | string | `":8081"` |  |
| operator.region | string | `"eu-west-1"` |  |
| operator.utils.tag | string | `"v2.0.14"` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| webhooks.enabled | bool | `false` |  |

