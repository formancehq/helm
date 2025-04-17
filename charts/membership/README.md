# Formance membership Helm chart

![Version: 2.5.0](https://img.shields.io/badge/Version-2.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.3.2](https://img.shields.io/badge/AppVersion-v1.3.2-informational?style=flat-square)
Formance EE Membership API. Manage stacks, organizations, regions, invitations, users, roles, and permissions.

## Requirements

Kubernetes: `>=1.14.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | 1.X |
| https://charts.dexidp.io | dex | 0.17.X |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 15.5.X |

> [!IMPORTANT]
> You need to obtain a licence from the Formance team. (See [EE Licence](#ee-licence))

- SSL Certificate (Let's Encrypt or another)
- Public domain according to the certificate authority

## Source Code

* <https://github.com/formancehq/membership-api>
* <https://github.com/formancehq/helm/charts/membership>

## Migration

### From v0.38 To v1.0.0

#### EE Licence

Membership now need a EE licence. You can get a licence from the Formance team. The licence is valid for 1 cluster.
Then configure it through the `global.licence.token` and `global.licence.clusterID` values. See [Licence configuration](#licence-configuration) for more information.

#### RBAC

Membership service contains a behavior-breaking change within the RBAC module.

Before, permissions were managed dynamically on the organization and stack with a *fallback* on the organization resource. (default organization accesses and default stack accesses). Which led to a lot of confusion and inconsistency regarding the user's permissions

The fallback has been removed from the RBAC module and is only used when a new user joins the organization.

#### Breaking changes

Membership chart now use `.global.platform.<service>.oauth.client` to generate a client and allow the ability to integrate with another chart. specific configuration can added through `.config.auth.additionalOAuthClients` value.

## Values

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.elb | bool | `false` | Enable AWS ELB |
| global.aws.iam | bool | `false` | Enable AWS IAM Authentification |
| aws | object | `{"targetGroups":{"grpc":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.grpc.port }}"},"targetGroupARN":"","targetType":"ip"},"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Membership target groups |
| dex.aws | object | `{"targetGroups":{"dex-http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"dex.fullname\" .Subcharts.dex }}","port":"{{ .Values.dex.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Target Groups |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable debug mode |
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
| global.nats.url | string | `""` | NATS URL: nats://nats:4222 nats://$PUBLISHER_NATS_USERNAME:$PUBLISHER_NATS_PASSWORD@nats:4222 |
| global.platform.console.host | string | `"console.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.console.scheme | string | `"https"` | is the scheme for the console |
| global.platform.consoleV3.host | string | `"console.v3.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.consoleV3.oauth.client.id | string | `"console-v3"` | is the id of the client |
| global.platform.consoleV3.oauth.client.scopes | list | `["supertoken","accesses","remember_me","keep_refresh_token"]` | is the name of the secret |
| global.platform.consoleV3.oauth.client.secret | string | `"changeMe2"` | is the secret of the client |
| global.platform.consoleV3.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.consoleV3.scheme | string | `"https"` | is the scheme for the console |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.relyingParty.host | string | `"dex.{{ .Values.global.serviceHost }}"` | is the host for the relying party issuer |
| global.platform.membership.relyingParty.path | string | `""` | is the path for the relying party issuer |
| global.platform.membership.relyingParty.scheme | string | `"https"` | is the scheme the relying party |
| global.platform.membership.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | is the host for the portal |
| global.platform.portal.oauth.client.id | string | `"portal"` | is the id of the client |
| global.platform.portal.oauth.client.scopes | list | `["supertoken","accesses","remember_me","keep_refresh_token"]` | is the name of the secret |
| global.platform.portal.oauth.client.secret | string | `"changeMe1"` | is the secret of the client |
| global.platform.portal.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.portal.scheme | string | `"https"` | is the scheme for the portal |
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
| global.serviceHost | string | `""` | is the base domain for portal and console |
| config.migration.enabled | bool | `true` | Enable migration job |
| config.migration.postgresql.auth.existingSecret | string | `""` | Name of existing secret to use for PostgreSQL credentials (overrides `auth.existingSecret`). |
| config.migration.postgresql.auth.password | string | `""` | Password for the "postgres" admin user (overrides `auth.postgresPassword`) |
| config.migration.postgresql.auth.secretKeys.adminPasswordKey | string | `""` | Name of key in existing secret to use for PostgreSQL credentials (overrides `auth.secretKeys.adminPasswordKey`). Only used when `global.postgresql.auth.existingSecret` is set. |
| config.migration.postgresql.auth.username | string | `""` | Name for a custom user to create (overrides `auth.username`) |

### Licence configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.licence.clusterID | string | `""` | Obtain your licence cluster id with `kubectl get ns kube-system -o jsonpath='{.metadata.uid}'` |
| global.licence.existingSecret | string | `""` | Licence Client Token as a secret |
| global.licence.issuer | string | `"https://license.formance.cloud/keys"` | Licence Environment  |
| global.licence.secretKeys.token | string | `""` | Key in existing secret to use for Licence Client Token |
| global.licence.token | string | `""` | Licence Client Token delivered by contacting [Formance](https://formance.com) |

### Dex configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dex.configOverrides | object | `{"enablePasswordDB":true,"oauth2":{"responseTypes":["code","token","id_token"],"skipApprovalScreen":true},"staticPasswords":[{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}],"storage":{"type":"postgres"}}` | Config override allow template function. Database is setup on the chart global, make sure that user/password when using kubernetes secret |
| dex.configOverrides.enablePasswordDB | bool | `true` | enable password db |
| dex.configOverrides.oauth2.responseTypes | list | `["code","token","id_token"]` | oauth2 response types |
| dex.configOverrides.oauth2.skipApprovalScreen | bool | `true` | oauth2 skip approval screen |
| dex.configOverrides.staticPasswords[0] | object | `{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}` | static passwords email |
| dex.configOverrides.staticPasswords[0].hash | string | `"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"` | static passwords hash |
| dex.configOverrides.staticPasswords[0].userID | string | `"08a8684b-db88-4b73-90a9-3cd1661f5466"` | static passwords user id |
| dex.configOverrides.staticPasswords[0].username | string | `"admin"` | static passwords username |
| dex.configSecret.create | bool | `false` | Dex config secret create Default secret provided by the dex chart |
| dex.configSecret.createConfigSecretOverrides | bool | `true` | Dex config secret create config secret overrides Enable secret config overrides provided by the cloudprem chart |
| dex.configSecret.name | string | `"membership-dex-config"` | Dex config secret name |
| dex.enabled | bool | `true` | Enable dex |
| dex.envVars | list | `[]` | Dex additional environment variables |
| dex.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| dex.image.repository | string | `"ghcr.io/formancehq/dex"` | image repository |
| dex.image.tag | string | `"v1.0.4"` | image tag |
| dex.ingress.annotations | object | `{}` | Dex ingress annotations |
| dex.ingress.className | string | `""` | Dex ingress class name |
| dex.ingress.enabled | bool | `true` | Dex ingress enabled |
| dex.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.relyingParty.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | Dex ingress host |
| dex.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | Dex ingress path refer to .Values.global.platform.membership.relyingParty.host.path |
| dex.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Dex ingress path type |
| dex.ingress.tls | list | `[]` | Dex ingress tls |
| dex.resources | object | `{}` | Dex resources |

### Membership Feature

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| feature.disableEvents | bool | `true` | Membership feature disable events |
| feature.managedStacks | bool | `true` | Membership feature managed stacks |
| feature.migrationHooks | bool | `false` | Run migration in a hook |

### Postgresql configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.architecture | string | `"standalone"` | Postgresql architecture |
| postgresql.enabled | bool | `true` | Enable postgresql |
| postgresql.fullnameOverride | string | `"postgresql"` | Postgresql fullname override |
| postgresql.primary | object | `{"persistence":{"enabled":false}}` | Postgresql primary persistence enabled |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.nats.auth.existingSecret | string | `""` |  |
| global.nats.auth.password | string | `""` |  |
| global.nats.auth.secretKeys.password | string | `"password"` |  |
| global.nats.auth.secretKeys.username | string | `"username"` |  |
| global.nats.auth.user | string | `""` |  |
| global.nats.enabled | bool | `false` |  |
| global.platform.console.enabled | bool | `true` |  |
| global.platform.consoleV3.enabled | bool | `false` |  |
| global.platform.consoleV3.oauth.client.existingSecret | string | `""` |  |
| global.platform.portal.enabled | bool | `true` |  |
| global.platform.portal.oauth.client.existingSecret | string | `""` |  |
| affinity | object | `{}` | Membership affinity |
| annotations | object | `{}` | Membership annotations  |
| autoscaling | object | `{}` | Membership autoscaling |
| commonLabels | object | `{}` | DEPRECATED Membership service |
| config.additionalEnv | list | `[]` | Additional Environment variables on the main deployment |
| config.auth.additionalOAuthClients | list | `[]` | Membership additional oauth clients |
| config.auth.tokenValidity | object | `{"accessToken":"5m","refreshToken":"72h"}` | According to "nsuµmh" And https://github.com/spf13/cast/blob/e9ba3ce83919192b29c67da5bec158ce024fdcdb/caste.go#L61C3-L61C3 |
| config.fctl | bool | `true` | Enable Fctl |
| config.grpc.existingSecret | string | `""` |  |
| config.grpc.secretKeys.secret | string | `"TOKENS"` |  |
| config.grpc.tokens | list | `[]` | Membership agent grpc token |
| config.job | object | `{"garbageCollector":{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"0 0 * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]},"invitationGC":{"concurrencyPolicy":"Forbid","resources":{},"restartPolicy":"Never","schedule":"0/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]},"stackLifeCycle":{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"*/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}}` | CronJob to manage the stack life cycle and the garbage collector |
| config.job.garbageCollector | object | `{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"0 0 * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}` | Clean expired tokens and refresh tokens after X time |
| config.job.stackLifeCycle | object | `{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"*/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}` | Job create 2 jobs to eaither warn or prune a stacks This does not change the state of the stack WARN: Mark stack Disposable -> trigger a mail PRUNE: Mark stack Warned -> trigger a mail It blocks stack cycles if supendend It is highly recommended to enable it as it is the only way we control |
| config.migration.annotations | object | `{}` | Membership job migration annotations Argo CD translate `pre-install,pre-upgrade` to: argocd.argoproj.io/hook: PreSync |
| config.migration.serviceAccount.annotations | object | `{}` |  |
| config.migration.serviceAccount.create | bool | `true` |  |
| config.migration.serviceAccount.name | string | `""` |  |
| config.migration.ttlSecondsAfterFinished | string | `""` |  |
| config.migration.volumeMounts | list | `[]` |  |
| config.migration.volumes | list | `[]` |  |
| config.oidc | object | `{"clientId":"membership","clientSecret":"changeMe","existingSecret":"","scopes":["openid","email","federated:id"],"secretKeys":{"secret":""}}` | Membership relying party connection url |
| config.oidc.clientId | string | `"membership"` | Membership oidc client id |
| config.oidc.clientSecret | string | `"changeMe"` | Membership oidc client secret |
| config.oidc.existingSecret | string | `""` | Membership oidc existing secret |
| config.oidc.scopes | list | `["openid","email","federated:id"]` | Membership oidc redirect uri |
| config.oidc.scopes[2] | string | `"federated:id"` | Membership Dex federated id scope |
| config.oidc.secretKeys | object | `{"secret":""}` | Membership oidc secret key |
| config.publisher.clientID | string | `"membership"` |  |
| config.publisher.jetstream.replicas | int | `1` |  |
| config.publisher.topicMapping | string | `"membership"` |  |
| config.stack.cycle.delay.disable | string | `"72h"` |  |
| config.stack.cycle.delay.disablePollingDelay | string | `"1m"` |  |
| config.stack.cycle.delay.disposable | string | `"360h"` |  |
| config.stack.cycle.delay.prune | string | `"720h"` |  |
| config.stack.cycle.delay.prunePollingDelay | string | `"1m"` |  |
| config.stack.cycle.delay.warn | string | `"72h"` |  |
| config.stack.cycle.dryRun | bool | `true` |  |
| config.stack.minimalStackModules[0] | string | `"Auth"` |  |
| config.stack.minimalStackModules[1] | string | `"Ledger"` |  |
| config.stack.minimalStackModules[2] | string | `"Payments"` |  |
| config.stack.minimalStackModules[3] | string | `"Gateway"` |  |
| debug | bool | `false` | Membership debug |
| dev | bool | `false` | Membership dev, disable ssl verification |
| fullnameOverride | string | `""` | Membership fullname override |
| image.pullPolicy | string | `"IfNotPresent"` | Membership image pull policy |
| image.repository | string | `"ghcr.io/formancehq/membership"` | Membership image repository |
| image.tag | string | `""` | Membership image tag |
| imagePullSecrets | list | `[]` | Membership image pull secrets |
| ingress.annotations | object | `{}` | Membership ingress annotations |
| ingress.className | string | `""` | Membership ingress class name |
| ingress.enabled | bool | `true` | Membership ingress enabled |
| ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.host $ }}","paths":[{"path":"/api","pathType":"Prefix"}]}` | Membership ingress host |
| ingress.hosts[0].paths[0] | object | `{"path":"/api","pathType":"Prefix"}` | Membership ingress path |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Membership ingress path type |
| ingress.tls | list | `[]` | Membership ingress tls |
| initContainers | list | `[]` | Membership init containers |
| nameOverride | string | `""` | Membership name override |
| nodeSelector | object | `{}` | Membership node selector |
| podAnnotations | object | `{}` | pod annotations |
| podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| podSecurityContext | object | `{}` | Membership pod security context |
| replicaCount | int | `1` | Count of replicas |
| resources | object | `{}` | Membership resources |
| securityContext.capabilities | object | `{"drop":["ALL"]}` | Membership security context capabilities drop |
| securityContext.readOnlyRootFilesystem | bool | `true` | Membership security context read only root filesystem |
| securityContext.runAsNonRoot | bool | `true` | Membership security context run as non root |
| securityContext.runAsUser | int | `1000` | Membership security context run as user |
| service.annotations | object | `{}` | service annotations |
| service.clusterIP | string | `""` | service cluster IP |
| service.ports.grpc.port | int | `8082` | service grpc port |
| service.ports.http | object | `{"port":8080}` | service http port |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Service account creation |
| serviceAccount.name | string | `""` | Service account name |
| tolerations | list | `[]` | Membership tolerations |
| volumeMounts | list | `[]` | Membership volume mounts |
| volumes | list | `[]` | Membership volumes |
