# identity

Formance Identity service

Identity requires an existing PostgreSQL database and three independent
credentials: the runtime URI, the migration URI, and the Identity application
secret. The migration and bootstrap Jobs run as pre-install/pre-upgrade hooks
by default. They use the exact same immutable image as the runtime, while only
the migration Job receives the privileged migration URI.

For production deployments, reference existing Kubernetes Secrets rather than
putting credentials in values. The chart intentionally does not create a
database, ExternalSecrets, or a provider-specific CA ConfigMap.

## Values

### Global Identity configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform.identity.connector.authenticationPolicy | string | `"identity"` | Membership authentication policy applied to the connector. |
| global.platform.identity.connector.id | string | `"identity"` | Identity connector ID exposed by Membership. |
| global.platform.identity.connector.name | string | `"Identity"` | Identity connector display name. |
| global.platform.identity.enabled | bool | `true` | Enable Identity when this chart is consumed by CloudPrem. |
| global.platform.identity.host | string | `"identity.{{ .Values.global.serviceHost }}"` | Public Identity host. |
| global.platform.identity.issuerPath | string | `"/api/auth"` | OIDC issuer path exposed by Identity. |
| global.platform.identity.membership.callbackURL | string | `""` | Exact Membership OAuth callback URL. Defaults to the public Membership callback. |
| global.platform.identity.membership.client.existingSecret | string | `""` | Existing Secret containing the Membership client secret. |
| global.platform.identity.membership.client.id | string | `"membership"` | Membership confidential client ID registered in Identity. |
| global.platform.identity.membership.client.secret | string | `""` | Membership confidential client secret. Prefer existingSecret in production. |
| global.platform.identity.membership.client.secretKeys.secret | string | `""` | Key containing the Membership client secret. |
| global.platform.identity.scheme | string | `"https"` | Public Identity URL scheme. |

### Global Membership configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | Public Membership host. |
| global.platform.membership.scheme | string | `"https"` | Public Membership URL scheme. |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.serviceHost | string | `""` | Base domain used by Formance services. |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules. |
| annotations | object | `{}` | Annotations added to the Deployment. |
| bootstrapVolumeMounts | list | `[]` | Additional bootstrap volume mounts. |
| commonLabels | object | `{}` | Extra labels added to resources and pods, outside immutable selectors. |
| config.additional | object | `{}` | Additional literal ConfigMap entries. |
| config.additionalEnv | list | `[]` | Additional runtime environment variables. |
| config.additionalEnvFrom | list | `[]` | Additional runtime envFrom sources. |
| config.hostname | string | `"0.0.0.0"` | Listen address. |
| config.identitySecret.existingSecret | string | `""` | Existing Secret containing the Better Auth secret. |
| config.identitySecret.secretKeys.secret | string | `""` | Key containing the Better Auth secret. |
| config.identitySecret.value | string | `""` | Better Auth secret. Prefer existingSecret in production. |
| config.mail.from | string | `"noreply@example.com"` | Sender address. |
| config.mail.mailgun.apiKey | string | `""` | Mailgun API key. Prefer existingSecret in production. |
| config.mail.mailgun.domain | string | `""` | Mailgun domain. |
| config.mail.mailgun.existingSecret | string | `""` | Existing Secret containing the Mailgun API key. |
| config.mail.mailgun.region | string | `"us"` | Mailgun region: us or eu. |
| config.mail.mailgun.secretKeys.apiKey | string | `""` | Key containing the Mailgun API key. |
| config.mail.smtp.existingSecret | string | `""` | Existing Secret containing the SMTP password. |
| config.mail.smtp.host | string | `""` | SMTP host. |
| config.mail.smtp.password | string | `""` | SMTP password. Prefer existingSecret in production. |
| config.mail.smtp.port | int | `587` | SMTP port. |
| config.mail.smtp.secretKeys.password | string | `""` | Key containing the SMTP password. |
| config.mail.smtp.secure | bool | `false` | Use implicit SMTP TLS. |
| config.mail.smtp.username | string | `""` | SMTP username. |
| config.mail.transport | string | `"file"` | Mail transport: file, smtp, or mailgun. |
| config.nodeEnv | string | `"production"` | Node environment. |
| config.port | int | `3000` | Listen port. |
| config.publicURL | string | `""` | Public Identity URL. Defaults to global.platform.identity scheme and host. |
| config.relyingPartyID | string | `""` | WebAuthn relying-party ID. Defaults to global.platform.identity.host. |
| database.migration.existingSecret | string | `""` | Existing Secret containing the migration PostgreSQL URI. |
| database.migration.secretKeys.uri | string | `"postgres.uri"` | Key containing the migration PostgreSQL URI. |
| database.migration.uri | string | `""` | Migration PostgreSQL URI. Prefer existingSecret in production. |
| database.runtime.existingSecret | string | `""` | Existing Secret containing the runtime PostgreSQL URI. |
| database.runtime.secretKeys.uri | string | `"postgres.uri"` | Key containing the runtime PostgreSQL URI. |
| database.runtime.uri | string | `""` | Runtime PostgreSQL URI. Prefer existingSecret in production. |
| deployment.progressDeadlineSeconds | int | `300` | Deployment progress deadline. |
| deployment.revisionHistoryLimit | int | `3` | Deployment revision history limit. |
| deployment.strategy.rollingUpdate.maxSurge | int | `1` |  |
| deployment.strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| fullnameOverride | string | `""` | Override the fully qualified application name. |
| hooks.bootstrap.activeDeadlineSeconds | int | `180` | Maximum bootstrap runtime. |
| hooks.bootstrap.annotations | object | `{}` | Hook annotations merged with the Helm defaults. |
| hooks.bootstrap.backoffLimit | int | `0` | Bootstrap retry count. |
| hooks.bootstrap.enabled | bool | `true` | Register or update Membership's confidential OAuth client after migrations. |
| hooks.bootstrap.resources | object | `{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Bootstrap Job resources. |
| hooks.bootstrap.ttlSecondsAfterFinished | int | `86400` | Successful/failed Job retention. |
| hooks.migration.activeDeadlineSeconds | int | `300` | Maximum migration runtime. |
| hooks.migration.annotations | object | `{}` | Hook annotations merged with the Helm defaults. |
| hooks.migration.backoffLimit | int | `0` | Migration retry count. |
| hooks.migration.enabled | bool | `true` | Run database migrations before installs and upgrades. |
| hooks.migration.resources | object | `{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Migration Job resources. |
| hooks.migration.ttlSecondsAfterFinished | int | `86400` | Successful/failed Job retention. |
| hooks.serviceAccount.annotations | object | `{}` | Hook ServiceAccount annotations. |
| hooks.serviceAccount.create | bool | `true` | Create a hook ServiceAccount before migration and bootstrap Jobs. |
| hooks.serviceAccount.name | string | `""` | Hook ServiceAccount name. |
| image.digest | string | `""` | Optional image digest, for example sha256:abcdef. |
| image.pullPolicy | string | `"IfNotPresent"` | Identity image pull policy. |
| image.repository | string | `"ghcr.io/formancehq/identity"` | Identity image repository. |
| image.tag | string | `""` | Identity image tag. Defaults to the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets. |
| ingress.annotations | object | `{}` | Ingress annotations. |
| ingress.className | string | `""` | Ingress class name. |
| ingress.enabled | bool | `false` | Enable the Identity Ingress. |
| ingress.hosts[0].host | string | `"{{ .Values.global.platform.identity.host }}"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.labels | object | `{"app.kubernetes.io/component":"runtime"}` | Extra Ingress labels. |
| ingress.tls | list | `[]` | Ingress TLS configuration. |
| initContainers | list | `[]` | Additional init containers. |
| migrationVolumeMounts | list | `[]` | Additional migration volume mounts. |
| nameOverride | string | `""` | Override the chart name. |
| networkPolicy.enabled | bool | `false` | Enable an ingress NetworkPolicy for Identity pods. |
| networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules. |
| networkPolicy.policyTypes | list | `["Ingress"]` | NetworkPolicy policy types. |
| nodeSelector | object | `{}` | Node selector. |
| podAnnotations | object | `{}` | Annotations added to Identity pods. |
| podLabels | object | `{}` | Extra labels added to Identity pods. |
| podSecurityContext | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context. |
| probes.liveness.enabled | bool | `true` |  |
| probes.liveness.failureThreshold | int | `3` |  |
| probes.liveness.periodSeconds | int | `30` |  |
| probes.liveness.tcpSocket.port | string | `"http"` |  |
| probes.liveness.timeoutSeconds | int | `2` |  |
| probes.readiness.enabled | bool | `true` |  |
| probes.readiness.failureThreshold | int | `3` |  |
| probes.readiness.httpGet.path | string | `"/_info"` |  |
| probes.readiness.httpGet.port | string | `"http"` |  |
| probes.readiness.periodSeconds | int | `10` |  |
| probes.readiness.timeoutSeconds | int | `3` |  |
| probes.startup.enabled | bool | `true` |  |
| probes.startup.failureThreshold | int | `36` |  |
| probes.startup.periodSeconds | int | `5` |  |
| probes.startup.tcpSocket.port | string | `"http"` |  |
| replicaCount | int | `1` | Number of Identity replicas. |
| resources | object | `{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Identity container resources. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context. |
| selectorLabels.extra | object | `{"app.kubernetes.io/component":"runtime"}` | Additional immutable selector labels. |
| selectorLabels.includeInstance | bool | `true` | Include app.kubernetes.io/instance in immutable workload selectors. Disable only when adopting a legacy Deployment whose selector omitted it. |
| service.annotations | object | `{}` | Service annotations. |
| service.clusterIP | string | `""` | Service ClusterIP. |
| service.ports.http.nodePort | string | `""` | Optional HTTP NodePort. |
| service.ports.http.port | int | `3000` | Service HTTP port. |
| service.type | string | `"ClusterIP"` | Service type. |
| serviceAccount.annotations | object | `{}` | Runtime ServiceAccount annotations. |
| serviceAccount.automountServiceAccountToken | bool | `false` | Mount the Kubernetes API token in runtime pods. |
| serviceAccount.create | bool | `true` | Create the runtime ServiceAccount. |
| serviceAccount.name | string | `""` | Runtime ServiceAccount name. |
| tolerations | list | `[]` | Tolerations. |
| volumeMounts | list | `[{"mountPath":"/tmp","name":"temporary"},{"mountPath":"/app/apps/identity/.next/cache","name":"next-cache"}]` | Additional runtime volume mounts. |
| volumes | list | `[{"emptyDir":{"sizeLimit":"64Mi"},"name":"temporary"},{"emptyDir":{"sizeLimit":"128Mi"},"name":"next-cache"}]` | Additional volumes mounted by the runtime and hook Jobs. |
