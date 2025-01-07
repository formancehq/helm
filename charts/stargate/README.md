# stargate

![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Formance Stargate gRPC Gateway

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | 1.X |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 15.5.X |

## Values

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.elb | bool | `false` | Enable AWS ELB across all services, appropriate <service>.aws.targertGroup must be set |
| global.aws.iam | bool | `false` | Enable AWS IAM across all services, appropriate <service>.serviceAccount.annotations must be set |
| aws | object | `{"targetGroups":{"grpc":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.grpc.port | default 3068 }}"},"targetGroupARN":"","targetType":"ip"}}}` | Aws Stargate target groups |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.monitoring.batch | bool | `false` | Enable otel batching |
| global.monitoring.logs.enabled | bool | `true` | Enable logging |
| global.monitoring.logs.format | string | `"json"` | Format |
| global.monitoring.logs.level | string | `"info"` | Level: Info, Debug, Error |
| global.monitoring.metrics.enabled | bool | `false` | Enable |
| global.monitoring.metrics.endpoint | string | `""` | Endpoint |
| global.monitoring.metrics.exporter | string | `"otlp"` | Exporter |
| global.monitoring.metrics.insecure | bool | `true` | Insecure |
| global.monitoring.metrics.mode | string | `"grpc"` | Mode |
| global.monitoring.metrics.port | int | `4317` | Port |
| global.monitoring.traces.enabled | bool | `false` | Enable otel tracing |
| global.monitoring.traces.endpoint | string | `"localhost"` | Endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter |
| global.monitoring.traces.insecure | bool | `true` | Insecure |
| global.monitoring.traces.mode | string | `"grpc"` | Mode |
| global.monitoring.traces.port | int | `4317` | Port |
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

### Global Nats configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.nats.enabled | bool | `false` | Enable NATS |
| global.nats.url | string | `""` | URL for NATS |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable debug mode |
| global.nats.auth.existingSecret | string | `""` |  |
| global.nats.auth.password | string | `nil` |  |
| global.nats.auth.secretKeys.password | string | `"password"` |  |
| global.nats.auth.secretKeys.username | string | `"username"` |  |
| global.nats.auth.user | string | `nil` |  |
| global.serviceHost | string | `""` | is the base domain for portal and console |
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| config.auth_issuer_url | string | `""` |  |
| config.publisher.clientID | string | `"stargate"` |  |
| config.publisher.topicMapping | string | `"stargate"` |  |
| fullnameOverride | string | `""` | String to fully override stargate.fullname template with a string |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/formancehq/stargate"` |  |
| image.tag | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"stargate.{{ .Values.global.serviceHost }}"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` |  |
| nameOverride | string | `""` | String to partially override stargate.fullname template with a string (will append the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment |
| podAnnotations | object | `{}` | Annotations to add to the pod |
| podDisruptionBudget.enabled | bool | `false` | Enable a [pod distruption budget](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) to help dealing with [disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/). It is **highly recommended** for webhooks as disruptions can prevent launching new pods. |
| podDisruptionBudget.maxUnavailable | int | `0` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podSecurityContext | object | `{}` | Security context for the pod |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | Resource limits and requests |
| securityContext | object | `{}` | Security context for the container |
| service.ports.grpc.port | int | `3068` |  |
| service.ports.http.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` | Tolerations for pod assignment |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |
