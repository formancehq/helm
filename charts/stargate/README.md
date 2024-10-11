# stargate

![Version: 0.3.0](https://img.shields.io/badge/Version-0.3.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Formance Stargate gRPC Gateway

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | v1.0.0-beta.1 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 15.5.X |

## Values

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.elb | bool | `false` | Enable AWS ELB across all services, appropriate <service>.aws.targertGroup must be set |
| global.aws.iam | bool | `false` | Enable AWS IAM across all services, appropriate <service>.serviceAccount.annotations must be set |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
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
| global.serviceHost | string | `""` | is the base domain for portal and console |
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Target memory utilization percentage |
| aws | object | `{"targetGroups":{"grpc":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"stargate.fullname\" $ }}","port":"{{ .Values.service.ports.grpc | default 3068 }}"},"targetGroupARN":"","targetType":"ip"}}}` | Target group name |
| config | object | `{"auth_issuer_url":"","monitoring":{"serviceName":"stargate"},"nats":{"clientID":"stargate","topicMapping":"stargate"}}` | Service name for monitoring |
| fullnameOverride | string | `""` | String to fully override stargate.fullname template with a string |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/formancehq/stargate","tag":""}` | Image tag |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"stargate.{{ .Values.global.serviceHost }}","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[]}` | Ingress TLS |
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
| service | object | `{"ports":{"grpc":{"port":3068},"http":{"port":8080}},"type":"ClusterIP"}` | gRPC port |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | The name of the service account to use. |
| tolerations | list | `[]` | Tolerations for pod assignment |
| topologySpreadConstraints | list | `[]` | Topology spread constraints |

