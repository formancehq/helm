# membership

![Version: v1.0.0-beta.1](https://img.shields.io/badge/Version-v1.0.0--beta.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.35.3](https://img.shields.io/badge/AppVersion-v0.35.3-informational?style=flat-square)

Formance Membership Helm Chart

## Source Code

* <https://github.com/formancehq/membership-api>

## Requirements

Kubernetes: `>=1.14.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../core | core | v1.0.0-beta.1 |
| https://charts.dexidp.io | dex | 0.17.X |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 15.5.X |

## Values

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.iam | bool | `false` | Enable AWS IAM Authentification |
| global.debug | bool | `false` | Enable debug mode |
| global.monitoring.logs.enabled | bool | `true` | Enable logging |
| global.monitoring.logs.format | string | `"json"` | Format |
| global.monitoring.logs.level | string | `"info"` | Level: Info, Debug, Error |
| global.monitoring.traces.enabled | bool | `false` | Enable otel tracing |
| global.monitoring.traces.endpoint | string | `"localhost"` | Endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter |
| global.monitoring.traces.insecure | bool | `true` | Insecure |
| global.monitoring.traces.mode | string | `"grpc"` | Mode |
| global.monitoring.traces.port | int | `4317` | Port |
| global.platform.console.host | string | `"console.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.console.scheme | string | `"https"` | is the scheme for the console |
| global.platform.enabled | bool | `true` | Enable Platform OAuth Client |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.oauthClient.existingSecret | string | `""` | is the name of the secret |
| global.platform.membership.oauthClient.id | string | `"platform"` | is the id of the client |
| global.platform.membership.oauthClient.secret | string | `"changeMe1"` | is the secret of the client |
| global.platform.membership.oauthClient.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.membership.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | is the host for the portal |
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

### Dex configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| dex.configOverrides | object | `{"enablePasswordDB":true,"oauth2":{"responseTypes":["code","token","id_token"],"skipApprovalScreen":true},"staticPasswords":[{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}]}` | Config override allow template function. Database is setup on the chart global, make sure that user/password when using kubernetes secret |
| dex.configOverrides.enablePasswordDB | bool | `true` | enable password db |
| dex.configOverrides.oauth2.responseTypes | list | `["code","token","id_token"]` | oauth2 response types |
| dex.configOverrides.oauth2.skipApprovalScreen | bool | `true` | oauth2 skip approval screen |
| dex.configOverrides.staticPasswords[0].email | string | `"admin@formance.com"` | static passwords email |
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
| dex.image.tag | string | `"v0.33.10"` | image tag |
| dex.ingress.annotations | object | `{}` | Dex ingress annotations |
| dex.ingress.className | string | `""` | Dex ingress class name |
| dex.ingress.enabled | bool | `true` | Dex ingress enabled |
| dex.ingress.hosts[0].host | string | `"dex.{{ .Values.global.serviceHost }}"` | Dex ingress host |
| dex.ingress.hosts[0].paths[0].path | string | `"/"` | Dex ingress path |
| dex.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Dex ingress path type |
| dex.ingress.tls | list | `[]` | Dex ingress tls |
| dex.resources | object | `{}` | Dex resources |

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
| affinity | object | `{}` | Membership affinity |
| autoscaling | object | `{}` | Membership autoscaling |
| commonLabels | object | `{}` | DEPRECATED Membership service |
| config.additionalOAuthClients | list | `[]` |  |
| config.fctl | bool | `true` | Enable Fctl |
| config.migration.annotations | object | `{"helm.sh/hook":"pre-upgrade","helm.sh/hook-delete-policy":"before-hook-creation,hook-succeeded,hook-failed"}` | Membership migration annotations |
| config.migration.annotations."helm.sh/hook" | string | `"pre-upgrade"` | Membership migration helm hook |
| config.migration.annotations."helm.sh/hook-delete-policy" | string | `"before-hook-creation,hook-succeeded,hook-failed"` | Membership migration hook delete policy |
| config.oidc | object | `{"clientId":"membership","clientSecret":"changeMe","existingSecret":"","issuer":"https://dex.{{ .Values.global.serviceHost }}","secretKeys":{"secret":""}}` | DEPRECATED Membership postgresql connection url postgresqlUrl: "postgresql://formance:formance@postgresql.formance-control.svc:5432/formance?sslmode=disable" |
| config.oidc.clientId | string | `"membership"` | Membership oidc client id |
| config.oidc.clientSecret | string | `"changeMe"` | Membership oidc client secret |
| config.oidc.existingSecret | string | `""` | Membership oidc existing secret |
| config.oidc.issuer | string | `"https://dex.{{ .Values.global.serviceHost }}"` | Membership oidc issuer |
| config.oidc.secretKeys | object | `{"secret":""}` | Membership oidc secret key |
| debug | bool | `false` | Membership debug |
| dev | bool | `false` | Membership dev |
| feature.disableEvents | bool | `true` | Membership feature disable events |
| feature.managedStacks | bool | `true` | Membership feature managed stacks |
| fullnameOverride | string | `""` | Membership fullname override |
| image.pullPolicy | string | `"IfNotPresent"` | Membership image pull policy |
| image.repository | string | `"ghcr.io/formancehq/membership"` | Membership image repository |
| image.tag | string | `""` | Membership image tag |
| imagePullSecrets | list | `[]` | Membership image pull secrets |
| ingress.annotations | object | `{}` | Membership ingress annotations |
| ingress.className | string | `""` | Membership ingress class name |
| ingress.enabled | bool | `true` | Membership ingress enabled |
| ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.host $ }}","paths":[{"path":"/api","pathType":"Prefix"}]}` | Membership ingress host |
| ingress.hosts[0].paths[0].path | string | `"/api"` | Membership ingress path |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Membership ingress path type |
| ingress.tls | list | `[]` | Membership ingress tls |
| initContainers | list | `[]` | Membership init containers |
| nameOverride | string | `""` | Membership name override |
| nodeSelector | object | `{}` | Membership node selector |
| podSecurityContext | object | `{}` | Membership pod security context |
| replicaCount | int | `1` | Count of replicas |
| resources | object | `{}` | Membership resources |
| securityContext.capabilities | object | `{"drop":["ALL"]}` | Membership security context capabilities drop |
| securityContext.readOnlyRootFilesystem | bool | `true` | Membership security context read only root filesystem |
| securityContext.runAsNonRoot | bool | `true` | Membership security context run as non root |
| securityContext.runAsUser | int | `1000` | Membership security context run as user |
| service.annotations | object | `{}` | service annotations |
| service.clusterIP | string | `""` | service cluster IP |
| service.ports.grpc | object | `{"port":8082}` | service grpc port |
| service.ports.http | object | `{"port":8080}` | service http port |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Service account creation |
| serviceAccount.name | string | `""` | Service account name |
| tolerations | list | `[]` | Membership tolerations |
| volumeMounts | list | `[]` | Membership volume mounts |
| volumes | list | `[]` | Membership volumes |

