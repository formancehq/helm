# formance

![Version: 2.7.0](https://img.shields.io/badge/Version-2.7.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Formance Platform - Unified Helm Chart

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/helm/tree/main/charts/formance>

## Requirements

Kubernetes: `>=1.14.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../cloudprem | cloudprem | 5.X |
| file://../regions | regions | 3.X |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 18.X |

## Values

### AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws | object | `{"elb":false,"iam":false}` | AWS integration |
| global.aws.elb | bool | `false` | Enable AWS ELB TargetGroupBinding |
| global.aws.iam | bool | `false` | Enable AWS IAM authentication (IRSA) |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable debug mode |
| global.platform.consoleV3 | object | `{"host":"console.v3.{{ .Values.global.serviceHost }}","oauth":{"client":{"existingSecret":"","id":"console-v3","postLogoutRedirectUris":"- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/logout\n","redirectUris":"- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/login\n- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/login-by-org\n","scopes":["accesses","remember_me","keep_refresh_token","on_behalf"],"secret":"changeMe2","secretKeys":{"secret":""}}},"scheme":"https"}` | Console V3: EXPERIMENTAL |
| global.platform.consoleV3.oauth.client.existingSecret | string | `""` | is the name of the secret |
| global.platform.consoleV3.oauth.client.id | string | `"console-v3"` | is the id of the client |
| global.platform.consoleV3.oauth.client.scopes | list | `["accesses","remember_me","keep_refresh_token","on_behalf"]` | is the name of the secret |
| global.platform.consoleV3.oauth.client.secret | string | `"changeMe2"` | is the secret of the client |
| global.platform.consoleV3.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.membership.relyingParty.path | string | `""` | is the path for the relying party issuer |
| global.platform.portal.oauth.client.id | string | `"portal"` | is the id of the client |
| global.platform.portal.oauth.client.scopes | list | `["accesses","remember_me","keep_refresh_token","on_behalf"]` | is the name of the secret |
| global.platform.portal.oauth.client.secret | string | `"changeMe1"` | is the secret of the client |
| global.platform.portal.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.serviceHost | string | `""` | Base domain for all services (e.g., formance.example.com) |
| cloudprem.membership.config.migration.enabled | bool | `true` | Enable migration job |

### Licence configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.licence | object | `{"clusterID":"","createSecret":true,"existingSecret":"","issuer":"https://license.formance.cloud/keys","secretKeys":{"token":"token"},"token":""}` | Licence configuration (REQUIRED when ee.enabled=true) |
| global.licence.clusterID | string | `""` | Cluster ID: kubectl get ns kube-system -o jsonpath='{.metadata.uid}' |
| global.licence.createSecret | bool | `true` | Create licence secret |
| global.licence.existingSecret | string | `""` | Use existing secret for licence token |
| global.licence.issuer | string | `"https://license.formance.cloud/keys"` | Licence issuer URL |
| global.licence.secretKeys.token | string | `"token"` | Key in existing secret for licence token |
| global.licence.token | string | `""` | Licence token from Formance |

### Monitoring configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.monitoring | object | `{"logs":{"enabled":true,"format":"json","level":"info"},"metrics":{"enabled":false,"endpoint":"","exporter":"otlp","insecure":true,"mode":"grpc","port":4317},"support":{"authSecret":"","authSecretKey":"","enabled":false,"endpoint":"https://otel-support.internal.frmnc.net","resourceAttributes":{},"stackSelector":{"matchExpressions":[{"key":"formance.com/stack","operator":"Exists"}]}},"traces":{"batch":false,"enabled":false,"endpoint":"localhost","exporter":"otlp","insecure":true,"mode":"grpc","port":4317}}` | Monitoring configuration |
| global.monitoring.logs.enabled | bool | `true` | Enable logging |
| global.monitoring.logs.format | string | `"json"` | Log format (json, text) |
| global.monitoring.logs.level | string | `"info"` | Log level (info, debug, error) |
| global.monitoring.metrics.enabled | bool | `false` | Enable OpenTelemetry metrics |
| global.monitoring.metrics.endpoint | string | `""` | OTLP endpoint |
| global.monitoring.metrics.exporter | string | `"otlp"` | Exporter type |
| global.monitoring.metrics.insecure | bool | `true` | Disable TLS verification |
| global.monitoring.metrics.mode | string | `"grpc"` | Transport mode (grpc/http) |
| global.monitoring.metrics.port | int | `4317` | OTLP port |
| global.monitoring.support.authSecret | string | `""` | Secret name containing the bearer token for auth. Defaults to the licence secret if empty. |
| global.monitoring.support.authSecretKey | string | `""` | Key within the auth secret that contains the token |
| global.monitoring.support.enabled | bool | `false` | Enable Formance support telemetry forwarding (opt-in). Requires operator chart >= 3.12.0. |
| global.monitoring.support.endpoint | string | `"https://otel-support.internal.frmnc.net"` | Formance support collector endpoint |
| global.monitoring.support.resourceAttributes | object | `{}` | Resource attributes added to all signals sent to this endpoint |
| global.monitoring.support.stackSelector | object | `{"matchExpressions":[{"key":"formance.com/stack","operator":"Exists"}]}` | Stack selector for the support OtelExporterEndpoint |
| global.monitoring.traces.batch | bool | `false` | Enable trace batching |
| global.monitoring.traces.enabled | bool | `false` | Enable OpenTelemetry tracing |
| global.monitoring.traces.endpoint | string | `"localhost"` | OTLP endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter type |
| global.monitoring.traces.insecure | bool | `true` | Disable TLS verification |
| global.monitoring.traces.mode | string | `"grpc"` | Transport mode (grpc/http) |
| global.monitoring.traces.port | int | `4317` | OTLP port |

### NATS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.nats | object | `{"auth":{"existingSecret":"","password":"","secretKeys":{"password":"password"},"user":""},"enabled":false,"url":""}` | NATS configuration |
| global.nats.auth.existingSecret | string | `""` | Use existing secret |
| global.nats.auth.password | string | `""` | NATS password |
| global.nats.auth.secretKeys.password | string | `"password"` | Key for password in secret |
| global.nats.auth.user | string | `""` | NATS username |
| global.nats.enabled | bool | `false` | Enable NATS for event streaming |
| global.nats.url | string | `""` | NATS URL |

### Platform configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform | object | `{"consoleV3":{"enabled":true,"host":"console.{{ .Values.global.serviceHost }}","scheme":"https"},"identity":{"connector":{"authenticationPolicy":"identity","id":"identity","name":"Identity"},"enabled":false,"host":"identity.{{ .Values.global.serviceHost }}","issuerPath":"/api/auth","membership":{"callbackURL":"","client":{"existingSecret":"","id":"membership","secret":"","secretKeys":{"secret":""}}},"scheme":"https"},"membership":{"host":"membership.{{ .Values.global.serviceHost }}","oidc":{"host":"dex.{{ .Values.global.serviceHost }}","scheme":"https"},"relyingParty":{"host":"dex.{{ .Values.global.serviceHost }}","scheme":"https"},"scheme":"https"},"portal":{"enabled":true,"host":"portal.{{ .Values.global.serviceHost }}","scheme":"https"},"stargate":{"enabled":false,"stackApiUrl":""}}` | Platform services configuration (EE only) |
| global.platform.consoleV3.enabled | bool | `true` | Enable console v3 |
| global.platform.consoleV3.host | string | `"console.{{ .Values.global.serviceHost }}"` | Console host |
| global.platform.consoleV3.scheme | string | `"https"` | Console URL scheme |
| global.platform.identity.connector.authenticationPolicy | string | `"identity"` | Membership authentication policy applied to the connector. |
| global.platform.identity.connector.id | string | `"identity"` | Identity connector ID. |
| global.platform.identity.connector.name | string | `"Identity"` | Identity connector display name. |
| global.platform.identity.enabled | bool | `false` | Enable the Identity service and its Membership connector. |
| global.platform.identity.host | string | `"identity.{{ .Values.global.serviceHost }}"` | Public Identity host. |
| global.platform.identity.issuerPath | string | `"/api/auth"` | OIDC issuer path exposed by Identity. |
| global.platform.identity.membership.callbackURL | string | `""` | Exact Membership callback URL registered in Identity. |
| global.platform.identity.membership.client.existingSecret | string | `""` | Existing Secret containing the Membership client secret. |
| global.platform.identity.membership.client.id | string | `"membership"` | Membership client ID registered in Identity. |
| global.platform.identity.membership.client.secret | string | `""` | Membership client secret. Prefer existingSecret in production. |
| global.platform.identity.membership.client.secretKeys.secret | string | `""` | Key containing the Membership client secret. |
| global.platform.identity.scheme | string | `"https"` | Public Identity URL scheme. |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | Membership host |
| global.platform.membership.oidc.host | string | `"dex.{{ .Values.global.serviceHost }}"` | OIDC issuer host |
| global.platform.membership.oidc.scheme | string | `"https"` | OIDC issuer scheme |
| global.platform.membership.relyingParty.host | string | `"dex.{{ .Values.global.serviceHost }}"` | Relying party host (Dex) |
| global.platform.membership.relyingParty.scheme | string | `"https"` | Relying party scheme (Dex) |
| global.platform.membership.scheme | string | `"https"` | Membership URL scheme |
| global.platform.portal.enabled | bool | `true` | Enable portal |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | Portal host |
| global.platform.portal.scheme | string | `"https"` | Portal URL scheme |
| global.platform.stargate.enabled | bool | `false` | Enable Stargate for stack API routing |
| global.platform.stargate.stackApiUrl | string | `""` | Stack API URL (if stargate disabled) |

### PostgreSQL configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.postgresql | object | `{"additionalArgs":"sslmode=disable","auth":{"database":"formance","existingSecret":"","password":"formance","postgresPassword":"formance","secretKeys":{"adminPasswordKey":"","userPasswordKey":""},"username":"formance"},"host":"postgresql","service":{"ports":{"postgresql":5432}}}` | PostgreSQL configuration |
| global.postgresql.additionalArgs | string | `"sslmode=disable"` | Additional connection arguments |
| global.postgresql.auth.database | string | `"formance"` | Database name |
| global.postgresql.auth.existingSecret | string | `""` | Use existing secret for credentials |
| global.postgresql.auth.password | string | `"formance"` | Database password |
| global.postgresql.auth.postgresPassword | string | `"formance"` | Postgres admin password |
| global.postgresql.auth.secretKeys.adminPasswordKey | string | `""` | Key for admin password in secret |
| global.postgresql.auth.secretKeys.userPasswordKey | string | `""` | Key for user password in secret |
| global.postgresql.auth.username | string | `"formance"` | Database username |
| global.postgresql.host | string | `"postgresql"` | PostgreSQL host (used by membership/dex in EE mode) |
| global.postgresql.service.ports.postgresql | int | `5432` | PostgreSQL port |

### PostgreSQL

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.enabled | bool | `true` | Enable standalone PostgreSQL |

### PostgreSQL (Demo)

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql.fullnameOverride | string | `"postgresql"` | PostgreSQL image configuration |

### Regions configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| regions.agent | object | `{"agent":{"authentication":{"clientID":"","clientSecret":"","issuer":"https://app.formance.cloud/api","mode":"bearer"},"baseUrl":"","id":""},"enabled":false,"image":{"tag":""},"server":{"address":"app.formance.cloud:443","tls":{"enabled":true,"insecureSkipVerify":true}}}` | Agent configuration (connects to Formance Cloud) |
| regions.agent.agent.authentication.clientID | string | `""` | OAuth client ID |
| regions.agent.agent.authentication.clientSecret | string | `""` | OAuth client secret |
| regions.agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` | OAuth issuer |
| regions.agent.agent.authentication.mode | string | `"bearer"` | Authentication mode (bearer, token) |
| regions.agent.agent.baseUrl | string | `""` | Base URL for the region |
| regions.agent.agent.id | string | `""` | Agent ID (region identifier) |
| regions.agent.enabled | bool | `false` | Enable agent (must be explicitly enabled) |
| regions.agent.image.tag | string | `""` | Agent image tag |
| regions.agent.server.address | string | `"app.formance.cloud:443"` | Formance Cloud server address |
| regions.agent.server.tls.enabled | bool | `true` | Enable TLS |
| regions.agent.server.tls.insecureSkipVerify | bool | `true` | Skip TLS verification |
| regions.operator | object | `{"enabled":true,"ledger":{"enabled":false},"operator-crds":{"create":false}}` | Operator configuration |
| regions.operator.enabled | bool | `true` | Enable the Formance Operator |
| regions.operator.ledger.enabled | bool | `false` | Enable the Ledger v3 Operator (requires operator.enabled) |
| regions.versions | object | `{"allowDefaultVersion":false,"create":true}` | Stack versions configuration |
| regions.versions.allowDefaultVersion | bool | `false` | Allow default version |
| regions.versions.create | bool | `true` | Create version CRDs |

### Tags

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| tags | object | `{"CommunityEdition":true,"Demo":false,"EnterpriseEdition":false,"EntrepriseEdition":false}` | Tags |

### Edition

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| tags.Demo | bool | `false` | Enable demo mode, which adds sample configuration hints to the install notes |
| tags.EnterpriseEdition | bool | `false` | Choose deployment edition - EE: Enterprise (requires a Licence) - CE: Community |
| tags.EntrepriseEdition | bool | `false` | Deprecated misspelling of `tags.EnterpriseEdition`, still honoured. Will be removed in the next major. Prefer `tags.EnterpriseEdition`. |

### Migration configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.console-v3.config.migration.enabled | bool | `true` | Enable migration job with a separated user |
| cloudprem.portal.config.migration.enabled | bool | `true` | Enable migration job with a separated user |

### Console configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.console-v3.config.postgresqlUrl | string | `""` | PostgreSQL connection URL override (if not set, will be generated from global.postgresql) |

### Publisher configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.console-v3.config.publisher.clientID | string | `"console-v3"` | NATS client ID |
| cloudprem.console-v3.config.publisher.topicMapping | string | `"console-v3"` | NATS topic mapping |
| cloudprem.portal.config.publisher.clientID | string | `"portal"` | NATS client ID |
| cloudprem.portal.config.publisher.topicMapping | string | `"portal"` | NATS topic mapping |

### Membership Feature

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.console-v3.feature.migrationHooks | bool | `false` | Run migration in a hook |
| cloudprem.membership.feature.disableEvents | bool | `true` | Membership feature disable events |
| cloudprem.membership.feature.managedStacks | bool | `true` | Membership feature managed stacks |
| cloudprem.membership.feature.migrationHooks | bool | `false` | Run migration in a hook |
| cloudprem.portal.feature.migrationHooks | bool | `false` | Run migration in a hook |

### Postgresql configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.console-v3.postgresql.enabled | bool | `false` | Enable postgresql |
| cloudprem.membership.postgresql.enabled | bool | `true` | Enable postgresql |
| cloudprem.portal.postgresql.enabled | bool | `false` | Enable postgresql |

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.membership.aws | object | `{"targetGroups":{"grpc":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.grpc.port }}"},"targetGroupARN":"","targetType":"ip"},"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Membership target groups |
| cloudprem.membership.dex.aws | object | `{"targetGroups":{"dex-http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"dex.fullname\" .Subcharts.dex }}","port":"{{ .Values.dex.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Target Groups |
| cloudprem.portal.aws | object | `{"targetGroups":{"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Portal target groups |

### Dex configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.membership.dex.configOverrides | object | `{"enablePasswordDB":true,"oauth2":{"responseTypes":["code","token","id_token"],"skipApprovalScreen":true},"staticPasswords":[{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","role":"USER","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}],"storage":{"type":"postgres"}}` | Config override allow template function. Database is setup on the chart global, make sure that user/password when using kubernetes secret |
| cloudprem.membership.dex.configOverrides.enablePasswordDB | bool | `true` | enable password db |
| cloudprem.membership.dex.configOverrides.oauth2.responseTypes | list | `["code","token","id_token"]` | oauth2 response types |
| cloudprem.membership.dex.configOverrides.oauth2.skipApprovalScreen | bool | `true` | oauth2 skip approval screen |
| cloudprem.membership.dex.configOverrides.staticPasswords[0] | object | `{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","role":"USER","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}` | static passwords email |
| cloudprem.membership.dex.configOverrides.staticPasswords[0].hash | string | `"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"` | static passwords hash |
| cloudprem.membership.dex.configOverrides.staticPasswords[0].userID | string | `"08a8684b-db88-4b73-90a9-3cd1661f5466"` | static passwords user id |
| cloudprem.membership.dex.configOverrides.staticPasswords[0].username | string | `"admin"` | static passwords username |
| cloudprem.membership.dex.configSecret.create | bool | `false` | Dex config secret create Default secret provided by the dex chart |
| cloudprem.membership.dex.configSecret.createConfigSecretOverrides | bool | `true` | Dex config secret create config secret overrides Enable secret config overrides provided by the cloudprem chart |
| cloudprem.membership.dex.configSecret.name | string | `"membership-dex-config"` | Dex config secret name |
| cloudprem.membership.dex.enabled | bool | `true` | Enable dex |
| cloudprem.membership.dex.envVars | list | `[]` | Dex additional environment variables |
| cloudprem.membership.dex.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| cloudprem.membership.dex.image.repository | string | `"ghcr.io/formancehq/dex"` | image repository |
| cloudprem.membership.dex.image.tag | string | `"v2.0.0"` | image tag |
| cloudprem.membership.dex.ingress.annotations | object | `{}` | Dex ingress annotations |
| cloudprem.membership.dex.ingress.className | string | `""` | Dex ingress class name |
| cloudprem.membership.dex.ingress.enabled | bool | `true` | Dex ingress enabled |
| cloudprem.membership.dex.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.relyingParty.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | Dex ingress host |
| cloudprem.membership.dex.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | Dex ingress path refer to .Values.global.platform.membership.relyingParty.host.path |
| cloudprem.membership.dex.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Dex ingress path type |
| cloudprem.membership.dex.ingress.tls | list | `[]` | Dex ingress tls |
| cloudprem.membership.dex.resources | object | `{}` | Dex resources |

### Portal configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cloudprem.portal.config.postgresqlUrl | string | `""` | PostgreSQL connection URL override (if not set, will be generated from global.postgresql) |

### Ledger Operator configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| regions.operator.enabled | bool | `true` | Enable the Formance Operator |
| regions.operator.ledger.enabled | bool | `false` | Enable the Ledger v3 Operator (requires operator.enabled) |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.nats.auth.secretKeys.username | string | `"username"` |  |
| global.nats.requestTimeout | string | `"60s"` |  |
| global.platform.consoleV3.oauth.client.postLogoutRedirectUris | string | `"- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/logout\n"` |  |
| global.platform.consoleV3.oauth.client.redirectUris | string | `"- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/login\n- {{ tpl (printf \"%s://%s\" .Values.global.platform.consoleV3.scheme .Values.global.platform.consoleV3.host) $ }}/auth/login-by-org\n"` |  |
| global.platform.portal.oauth.client.existingSecret | string | `""` |  |
| global.platform.portal.oauth.client.postLogoutRedirectUris | string | `"- {{ tpl (printf \"%s://%s\" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) $ }}/auth/logout\n"` |  |
| global.platform.portal.oauth.client.redirectUris | string | `"- {{ tpl (printf \"%s://%s\" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) $ }}/auth/login\n- {{ tpl (printf \"%s://%s\" .Values.global.platform.portal.scheme .Values.global.platform.portal.host) $ }}/auth/login-by-org\n"` |  |
| global.platform.portal.oauth.client.scopes[0] | string | `"accesses"` |  |
| global.platform.portal.oauth.client.scopes[1] | string | `"remember_me"` |  |
| global.platform.portal.oauth.client.scopes[2] | string | `"keep_refresh_token"` |  |
| global.platform.portal.oauth.client.scopes[3] | string | `"on_behalf"` |  |
| global.platform.stargate.serverURL | string | `""` |  |
| global.platform.stargate.tls.disable | bool | `false` |  |
| global.serviceName | string | `"agent"` | TORework |
| cloudprem.console-v3.config.postgresql.auth.database | string | `"console"` |  |
| cloudprem.membership.postgresql.enabled | bool | `false` |  |
| cloudprem.portal.config.postgresql.auth.database | string | `"portal"` |  |
| postgresql.name | string | `""` |  |
| postgresql.nameOverride | string | `""` |  |
| regions.settings | object | `{}` |  |
| regions.stacks | object | `{}` |  |
| cloudprem.console-v3.affinity | object | `{}` | Console affinity |
| cloudprem.console-v3.annotations | object | `{}` | Console annotations  |
| cloudprem.console-v3.autoscaling.enabled | bool | `false` |  |
| cloudprem.console-v3.autoscaling.maxReplicas | int | `100` |  |
| cloudprem.console-v3.autoscaling.minReplicas | int | `1` |  |
| cloudprem.console-v3.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| cloudprem.console-v3.aws.targetGroups.http.ipAddressType | string | `"ipv4"` | Target group IP address type |
| cloudprem.console-v3.aws.targetGroups.http.serviceRef.name | string | `"{{ include \"core.fullname\" $ }}"` | Target group service reference name |
| cloudprem.console-v3.aws.targetGroups.http.serviceRef.port | string | `"{{ .Values.service.ports.http.port }}"` | Target group service reference port |
| cloudprem.console-v3.aws.targetGroups.http.targetGroupARN | string | `""` | Target group ARN |
| cloudprem.console-v3.aws.targetGroups.http.targetType | string | `"ip"` | Target group target type |
| cloudprem.console-v3.config.additionalEnv | list | `[{"name":"FEATURES_DISABLED","value":"sessions"}]` | Console additional environment variables |
| cloudprem.console-v3.config.cookie.encryptionKey | string | `"changeMe00"` | is used to encrypt a cookie value |
| cloudprem.console-v3.config.cookie.existingSecret | string | `""` | is the name of the secret |
| cloudprem.console-v3.config.cookie.secretKeys | object | `{"encryptionKey":""}` | is the key contained within the secret |
| cloudprem.console-v3.config.environment | string | `"production"` | Console environment |
| cloudprem.console-v3.config.managedStack | string | `"1"` | Enable managed stack mode (1 = enabled, 0 = disabled) |
| cloudprem.console-v3.config.migration.annotations | object | `{}` | Membership job migration annotations Argo CD translate `pre-install,pre-upgrade` to: argocd.argoproj.io/hook: PreSync |
| cloudprem.console-v3.config.migration.serviceAccount.annotations | object | `{}` |  |
| cloudprem.console-v3.config.migration.serviceAccount.create | bool | `true` |  |
| cloudprem.console-v3.config.migration.serviceAccount.name | string | `""` |  |
| cloudprem.console-v3.config.migration.ttlSecondsAfterFinished | string | `""` |  |
| cloudprem.console-v3.config.migration.volumeMounts | list | `[]` |  |
| cloudprem.console-v3.config.migration.volumes | list | `[]` |  |
| cloudprem.console-v3.config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| cloudprem.console-v3.config.sentry.dsn | string | `""` | Sentry DSN |
| cloudprem.console-v3.config.sentry.enabled | bool | `false` | Sentry enabled |
| cloudprem.console-v3.config.sentry.environment | string | `""` | Sentry environment |
| cloudprem.console-v3.config.sentry.release | string | `""` | Sentry release |
| cloudprem.console-v3.config.stargate_url | string | `""` | Deprecated |
| cloudprem.console-v3.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| cloudprem.console-v3.image.repository | string | `"ghcr.io/formancehq/console-v3"` | image repository |
| cloudprem.console-v3.image.tag | string | `""` | image tag |
| cloudprem.console-v3.imagePullSecrets | list | `[]` | image pull secrets |
| cloudprem.console-v3.ingress.annotations | object | `{}` | ingress annotations |
| cloudprem.console-v3.ingress.className | string | `""` | ingress class name |
| cloudprem.console-v3.ingress.enabled | bool | `true` | ingress enabled |
| cloudprem.console-v3.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.consoleV3.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | ingress host |
| cloudprem.console-v3.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| cloudprem.console-v3.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| cloudprem.console-v3.ingress.labels | object | `{}` | ingress labels |
| cloudprem.console-v3.ingress.tls | list | `[]` | ingress tls |
| cloudprem.console-v3.livenessProbe | object | `{}` | Console liveness probe |
| cloudprem.console-v3.nodeSelector | object | `{}` | Console node selector |
| cloudprem.console-v3.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| cloudprem.console-v3.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| cloudprem.console-v3.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| cloudprem.console-v3.podSecurityContext | object | `{}` | Pod Security Context |
| cloudprem.console-v3.readinessProbe | object | `{}` | Console readiness probe |
| cloudprem.console-v3.replicas | int | `1` | Number of replicas |
| cloudprem.console-v3.resources | object | `{}` | Console resources |
| cloudprem.console-v3.securityContext | object | `{}` | Container Security Context |
| cloudprem.console-v3.service.annotations | object | `{}` | service annotations |
| cloudprem.console-v3.service.clusterIP | string | `""` | service cluster IP |
| cloudprem.console-v3.service.ports.http | object | `{"port":3000}` | service http port |
| cloudprem.console-v3.service.type | string | `"ClusterIP"` | service type |
| cloudprem.console-v3.serviceAccount.annotations | object | `{}` | Service account annotations |
| cloudprem.console-v3.serviceAccount.create | bool | `true` | Service account creation |
| cloudprem.console-v3.serviceAccount.name | string | `""` | Service account name |
| cloudprem.console-v3.tolerations | list | `[]` | Console tolerations |
| cloudprem.console-v3.volumeMounts | list | `[]` | Console volume mounts |
| cloudprem.console-v3.volumes | list | `[]` | Console volumes |
| cloudprem.identity.affinity | object | `{}` | Affinity rules. |
| cloudprem.identity.annotations | object | `{}` | Annotations added to the Deployment. |
| cloudprem.identity.bootstrapVolumeMounts | list | `[]` | Additional bootstrap volume mounts. |
| cloudprem.identity.commonLabels | object | `{}` | Extra labels added to resources and pods, outside immutable selectors. |
| cloudprem.identity.config.additional | object | `{}` | Additional literal ConfigMap entries. |
| cloudprem.identity.config.additionalEnv | list | `[]` | Additional runtime environment variables. |
| cloudprem.identity.config.additionalEnvFrom | list | `[]` | Additional runtime envFrom sources. |
| cloudprem.identity.config.hostname | string | `"0.0.0.0"` | Listen address. |
| cloudprem.identity.config.identitySecret.existingSecret | string | `""` | Existing Secret containing the Better Auth secret. |
| cloudprem.identity.config.identitySecret.secretKeys.secret | string | `""` | Key containing the Better Auth secret. |
| cloudprem.identity.config.identitySecret.value | string | `""` | Better Auth secret. Prefer existingSecret in production. |
| cloudprem.identity.config.mail.from | string | `"noreply@example.com"` | Sender address. |
| cloudprem.identity.config.mail.mailgun.apiKey | string | `""` | Mailgun API key. Prefer existingSecret in production. |
| cloudprem.identity.config.mail.mailgun.domain | string | `""` | Mailgun domain. |
| cloudprem.identity.config.mail.mailgun.existingSecret | string | `""` | Existing Secret containing the Mailgun API key. |
| cloudprem.identity.config.mail.mailgun.region | string | `"us"` | Mailgun region: us or eu. |
| cloudprem.identity.config.mail.mailgun.secretKeys.apiKey | string | `""` | Key containing the Mailgun API key. |
| cloudprem.identity.config.mail.smtp.existingSecret | string | `""` | Existing Secret containing the SMTP password. |
| cloudprem.identity.config.mail.smtp.host | string | `""` | SMTP host. |
| cloudprem.identity.config.mail.smtp.password | string | `""` | SMTP password. Prefer existingSecret in production. |
| cloudprem.identity.config.mail.smtp.port | int | `587` | SMTP port. |
| cloudprem.identity.config.mail.smtp.secretKeys.password | string | `""` | Key containing the SMTP password. |
| cloudprem.identity.config.mail.smtp.secure | bool | `false` | Use implicit SMTP TLS. |
| cloudprem.identity.config.mail.smtp.username | string | `""` | SMTP username. |
| cloudprem.identity.config.mail.transport | string | `"file"` | Mail transport: file, smtp, or mailgun. |
| cloudprem.identity.config.nodeEnv | string | `"production"` | Node environment. |
| cloudprem.identity.config.port | int | `3000` | Listen port. |
| cloudprem.identity.config.publicURL | string | `""` | Public Identity URL. Defaults to global.platform.identity scheme and host. |
| cloudprem.identity.config.relyingPartyID | string | `""` | WebAuthn relying-party ID. Defaults to global.platform.identity.host. |
| cloudprem.identity.database.migration.existingSecret | string | `""` | Existing Secret containing the migration PostgreSQL URI. |
| cloudprem.identity.database.migration.secretKeys.uri | string | `"postgres.uri"` | Key containing the migration PostgreSQL URI. |
| cloudprem.identity.database.migration.uri | string | `""` | Migration PostgreSQL URI. Prefer existingSecret in production. |
| cloudprem.identity.database.runtime.existingSecret | string | `""` | Existing Secret containing the runtime PostgreSQL URI. |
| cloudprem.identity.database.runtime.secretKeys.uri | string | `"postgres.uri"` | Key containing the runtime PostgreSQL URI. |
| cloudprem.identity.database.runtime.uri | string | `""` | Runtime PostgreSQL URI. Prefer existingSecret in production. |
| cloudprem.identity.deployment.progressDeadlineSeconds | int | `300` | Deployment progress deadline. |
| cloudprem.identity.deployment.revisionHistoryLimit | int | `3` | Deployment revision history limit. |
| cloudprem.identity.deployment.strategy.rollingUpdate.maxSurge | int | `1` |  |
| cloudprem.identity.deployment.strategy.rollingUpdate.maxUnavailable | int | `0` |  |
| cloudprem.identity.fullnameOverride | string | `""` | Override the fully qualified application name. |
| cloudprem.identity.hooks.bootstrap.activeDeadlineSeconds | int | `180` | Maximum bootstrap runtime. |
| cloudprem.identity.hooks.bootstrap.annotations | object | `{}` | Hook annotations merged with the Helm defaults. |
| cloudprem.identity.hooks.bootstrap.backoffLimit | int | `0` | Bootstrap retry count. |
| cloudprem.identity.hooks.bootstrap.enabled | bool | `true` | Register or update Membership's confidential OAuth client after migrations. |
| cloudprem.identity.hooks.bootstrap.resources | object | `{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Bootstrap Job resources. |
| cloudprem.identity.hooks.bootstrap.ttlSecondsAfterFinished | int | `86400` | Successful/failed Job retention. |
| cloudprem.identity.hooks.migration.activeDeadlineSeconds | int | `300` | Maximum migration runtime. |
| cloudprem.identity.hooks.migration.annotations | object | `{}` | Hook annotations merged with the Helm defaults. |
| cloudprem.identity.hooks.migration.backoffLimit | int | `0` | Migration retry count. |
| cloudprem.identity.hooks.migration.enabled | bool | `true` | Run database migrations before installs and upgrades. |
| cloudprem.identity.hooks.migration.resources | object | `{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Migration Job resources. |
| cloudprem.identity.hooks.migration.ttlSecondsAfterFinished | int | `86400` | Successful/failed Job retention. |
| cloudprem.identity.hooks.serviceAccount.annotations | object | `{}` | Hook ServiceAccount annotations. |
| cloudprem.identity.hooks.serviceAccount.create | bool | `true` | Create a hook ServiceAccount before migration and bootstrap Jobs. |
| cloudprem.identity.hooks.serviceAccount.name | string | `""` | Hook ServiceAccount name. |
| cloudprem.identity.image.digest | string | `""` | Optional image digest, for example sha256:abcdef. |
| cloudprem.identity.image.pullPolicy | string | `"IfNotPresent"` | Identity image pull policy. |
| cloudprem.identity.image.repository | string | `"ghcr.io/formancehq/identity"` | Identity image repository. |
| cloudprem.identity.image.tag | string | `""` | Identity image tag. Defaults to the chart appVersion. |
| cloudprem.identity.imagePullSecrets | list | `[]` | Image pull secrets. |
| cloudprem.identity.ingress.annotations | object | `{}` | Ingress annotations. |
| cloudprem.identity.ingress.className | string | `""` | Ingress class name. |
| cloudprem.identity.ingress.enabled | bool | `false` | Enable the Identity Ingress. |
| cloudprem.identity.ingress.hosts[0].host | string | `"{{ .Values.global.platform.identity.host }}"` |  |
| cloudprem.identity.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| cloudprem.identity.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| cloudprem.identity.ingress.labels | object | `{"app.kubernetes.io/component":"runtime"}` | Extra Ingress labels. |
| cloudprem.identity.ingress.tls | list | `[]` | Ingress TLS configuration. |
| cloudprem.identity.initContainers | list | `[]` | Additional init containers. |
| cloudprem.identity.migrationVolumeMounts | list | `[]` | Additional migration volume mounts. |
| cloudprem.identity.nameOverride | string | `""` | Override the chart name. |
| cloudprem.identity.networkPolicy.enabled | bool | `false` | Enable an ingress NetworkPolicy for Identity pods. |
| cloudprem.identity.networkPolicy.ingress | list | `[]` | NetworkPolicy ingress rules. |
| cloudprem.identity.networkPolicy.policyTypes | list | `["Ingress"]` | NetworkPolicy policy types. |
| cloudprem.identity.nodeSelector | object | `{}` | Node selector. |
| cloudprem.identity.podAnnotations | object | `{}` | Annotations added to Identity pods. |
| cloudprem.identity.podLabels | object | `{}` | Extra labels added to Identity pods. |
| cloudprem.identity.podSecurityContext | object | `{"fsGroup":1000,"runAsGroup":1000,"runAsNonRoot":true,"runAsUser":1000,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context. |
| cloudprem.identity.probes.liveness.enabled | bool | `true` |  |
| cloudprem.identity.probes.liveness.failureThreshold | int | `3` |  |
| cloudprem.identity.probes.liveness.periodSeconds | int | `30` |  |
| cloudprem.identity.probes.liveness.tcpSocket.port | string | `"http"` |  |
| cloudprem.identity.probes.liveness.timeoutSeconds | int | `2` |  |
| cloudprem.identity.probes.readiness.enabled | bool | `true` |  |
| cloudprem.identity.probes.readiness.failureThreshold | int | `3` |  |
| cloudprem.identity.probes.readiness.httpGet.path | string | `"/_info"` |  |
| cloudprem.identity.probes.readiness.httpGet.port | string | `"http"` |  |
| cloudprem.identity.probes.readiness.periodSeconds | int | `10` |  |
| cloudprem.identity.probes.readiness.timeoutSeconds | int | `3` |  |
| cloudprem.identity.probes.startup.enabled | bool | `true` |  |
| cloudprem.identity.probes.startup.failureThreshold | int | `36` |  |
| cloudprem.identity.probes.startup.periodSeconds | int | `5` |  |
| cloudprem.identity.probes.startup.tcpSocket.port | string | `"http"` |  |
| cloudprem.identity.replicaCount | int | `1` | Number of Identity replicas. |
| cloudprem.identity.resources | object | `{"limits":{"cpu":"1","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | Identity container resources. |
| cloudprem.identity.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context. |
| cloudprem.identity.selectorLabels.extra | object | `{"app.kubernetes.io/component":"runtime"}` | Additional immutable selector labels. |
| cloudprem.identity.selectorLabels.includeInstance | bool | `true` | Include app.kubernetes.io/instance in immutable workload selectors. Disable only when adopting a legacy Deployment whose selector omitted it. |
| cloudprem.identity.service.annotations | object | `{}` | Service annotations. |
| cloudprem.identity.service.clusterIP | string | `""` | Service ClusterIP. |
| cloudprem.identity.service.ports.http.nodePort | string | `""` | Optional HTTP NodePort. |
| cloudprem.identity.service.ports.http.port | int | `3000` | Service HTTP port. |
| cloudprem.identity.service.type | string | `"ClusterIP"` | Service type. |
| cloudprem.identity.serviceAccount.annotations | object | `{}` | Runtime ServiceAccount annotations. |
| cloudprem.identity.serviceAccount.automountServiceAccountToken | bool | `false` | Mount the Kubernetes API token in runtime pods. |
| cloudprem.identity.serviceAccount.create | bool | `true` | Create the runtime ServiceAccount. |
| cloudprem.identity.serviceAccount.name | string | `""` | Runtime ServiceAccount name. |
| cloudprem.identity.tolerations | list | `[]` | Tolerations. |
| cloudprem.identity.volumeMounts | list | `[{"mountPath":"/tmp","name":"temporary"},{"mountPath":"/app/apps/identity/.next/cache","name":"next-cache"}]` | Additional runtime volume mounts. |
| cloudprem.identity.volumes | list | `[{"emptyDir":{"sizeLimit":"64Mi"},"name":"temporary"},{"emptyDir":{"sizeLimit":"128Mi"},"name":"next-cache"}]` | Additional volumes mounted by the runtime and hook Jobs. |
| cloudprem.membership.affinity | object | `{}` | Membership affinity |
| cloudprem.membership.annotations | object | `{}` | Membership annotations |
| cloudprem.membership.autoscaling | object | `{}` | Membership autoscaling |
| cloudprem.membership.commonLabels | object | `{}` | DEPRECATED Membership service |
| cloudprem.membership.config.additionalEnv | list | `[]` |  |
| cloudprem.membership.config.auth.additionalOAuthClients | list | `[]` | Membership additional oauth clients |
| cloudprem.membership.config.auth.loginWithSSO | bool | `false` | Enable login with sso (email selector on login page) |
| cloudprem.membership.config.auth.tokenValidity | object | `{"accessToken":"5m","refreshToken":"72h"}` | According to "nsuµmh" And https://github.com/spf13/cast/blob/e9ba3ce83919192b29c67da5bec158ce024fdcdb/caste.go#L61C3-L61C3 |
| cloudprem.membership.config.fctl | bool | `true` | Enable Fctl |
| cloudprem.membership.config.grpc.existingSecret | string | `""` |  |
| cloudprem.membership.config.grpc.secretKeys.secret | string | `"TOKENS"` |  |
| cloudprem.membership.config.grpc.tokens | list | `[]` | Membership agent grpc token |
| cloudprem.membership.config.job | object | `{"garbageCollector":{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"0 0 * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]},"invitationGC":{"concurrencyPolicy":"Forbid","resources":{},"restartPolicy":"Never","schedule":"0/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]},"stackLifeCycle":{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"*/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}}` | CronJob to manage the stack life cycle and the garbage collector |
| cloudprem.membership.config.job.garbageCollector | object | `{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"0 0 * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}` | Clean expired tokens and refresh tokens after X time |
| cloudprem.membership.config.job.stackLifeCycle | object | `{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"*/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}` | Job create 2 jobs to eaither warn or prune a stacks This does not change the state of the stack WARN: Mark stack Disposable -> trigger a mail PRUNE: Mark stack Warned -> trigger a mail It blocks stack cycles if supendend It is highly recommended to enable it as it is the only way we control |
| cloudprem.membership.config.migration.annotations | object | `{}` | Membership job migration annotations Argo CD translate `pre-install,pre-upgrade` to: argocd.argoproj.io/hook: PreSync |
| cloudprem.membership.config.migration.serviceAccount.annotations | object | `{}` |  |
| cloudprem.membership.config.migration.serviceAccount.create | bool | `true` |  |
| cloudprem.membership.config.migration.serviceAccount.name | string | `""` |  |
| cloudprem.membership.config.migration.ttlSecondsAfterFinished | string | `""` |  |
| cloudprem.membership.config.migration.volumeMounts | list | `[]` |  |
| cloudprem.membership.config.migration.volumes | list | `[]` |  |
| cloudprem.membership.config.oidc | object | `{"clientId":"membership","clientSecret":"changeMe","connectors":[],"existingSecret":"","scopes":["openid","email","federated:id"],"secretKeys":{"secret":""}}` | Membership relying party connection url (used with Dex only) |
| cloudprem.membership.config.oidc.clientId | string | `"membership"` | Membership oidc client id |
| cloudprem.membership.config.oidc.clientSecret | string | `"changeMe"` | Membership oidc client secret |
| cloudprem.membership.config.oidc.connectors | list | `[]` | Add external connectors |
| cloudprem.membership.config.oidc.existingSecret | string | `""` | Membership oidc existing secret |
| cloudprem.membership.config.oidc.scopes | list | `["openid","email","federated:id"]` | Membership oidc redirect uri |
| cloudprem.membership.config.oidc.scopes[2] | string | `"federated:id"` | Membership Dex federated id scope |
| cloudprem.membership.config.oidc.secretKeys | object | `{"secret":""}` | Membership oidc secret key |
| cloudprem.membership.config.publisher.clientID | string | `"membership"` |  |
| cloudprem.membership.config.publisher.jetstream.replicas | int | `1` |  |
| cloudprem.membership.config.publisher.topicMapping | string | `"membership"` |  |
| cloudprem.membership.config.stack.additionalModules[0] | string | `"Payments"` |  |
| cloudprem.membership.config.stack.additionalModules[1] | string | `"Stargate"` |  |
| cloudprem.membership.config.stack.cycle.delay.disable | string | `"72h"` |  |
| cloudprem.membership.config.stack.cycle.delay.disablePollingDelay | string | `"1m"` |  |
| cloudprem.membership.config.stack.cycle.delay.disposable | string | `"360h"` |  |
| cloudprem.membership.config.stack.cycle.delay.prune | string | `"720h"` |  |
| cloudprem.membership.config.stack.cycle.delay.prunePollingDelay | string | `"1m"` |  |
| cloudprem.membership.config.stack.cycle.delay.warn | string | `"72h"` |  |
| cloudprem.membership.config.stack.cycle.dryRun | bool | `true` |  |
| cloudprem.membership.config.stack.minimalStackModules[0] | string | `"Auth"` |  |
| cloudprem.membership.config.stack.minimalStackModules[1] | string | `"Ledger"` |  |
| cloudprem.membership.config.stack.minimalStackModules[2] | string | `"Gateway"` |  |
| cloudprem.membership.config.wizard.job.annotations | object | `{}` |  |
| cloudprem.membership.config.wizard.job.labels | object | `{}` |  |
| cloudprem.membership.config.wizard.job.ttlSecondsAfterFinished | int | `300` | Seconds after which the wizard Job is eligible for cleanup (e.g. 300) |
| cloudprem.membership.config.wizard.setup | string | `"users: []\norganizations: []\nregions: []\nstacks: []"` | Wizard bootstrap config (users, organizations, regions, stacks). Rendered under "wizard:" in /config/config.yaml. |
| cloudprem.membership.debug | bool | `false` | Membership debug |
| cloudprem.membership.dev | bool | `false` | Membership dev, disable ssl verification |
| cloudprem.membership.fullnameOverride | string | `""` | Membership fullname override |
| cloudprem.membership.image.pullPolicy | string | `"IfNotPresent"` | Membership image pull policy |
| cloudprem.membership.image.repository | string | `"ghcr.io/formancehq/membership"` | Membership image repository |
| cloudprem.membership.image.tag | string | `""` | Membership image tag |
| cloudprem.membership.imagePullSecrets | list | `[]` | Membership image pull secrets |
| cloudprem.membership.ingress.annotations | object | `{}` | Membership ingress annotations |
| cloudprem.membership.ingress.className | string | `""` | Membership ingress class name |
| cloudprem.membership.ingress.enabled | bool | `true` | Membership ingress enabled |
| cloudprem.membership.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.host $ }}","paths":[{"path":"/api","pathType":"Prefix"}]}` | Membership ingress host |
| cloudprem.membership.ingress.hosts[0].paths[0] | object | `{"path":"/api","pathType":"Prefix"}` | Membership ingress path |
| cloudprem.membership.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Membership ingress path type |
| cloudprem.membership.ingress.labels | object | `{}` | Membership ingress labels |
| cloudprem.membership.ingress.tls | list | `[]` | Membership ingress tls |
| cloudprem.membership.initContainers | list | `[]` | Membership init containers |
| cloudprem.membership.nameOverride | string | `""` | Membership name override |
| cloudprem.membership.nodeSelector | object | `{}` | Membership node selector |
| cloudprem.membership.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| cloudprem.membership.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| cloudprem.membership.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| cloudprem.membership.podSecurityContext | object | `{}` | Membership pod security context |
| cloudprem.membership.replicaCount | int | `1` | Count of replicas |
| cloudprem.membership.resources | object | `{}` | Membership resources |
| cloudprem.membership.securityContext.capabilities | object | `{"drop":["ALL"]}` | Membership security context capabilities drop |
| cloudprem.membership.securityContext.readOnlyRootFilesystem | bool | `true` | Membership security context read only root filesystem |
| cloudprem.membership.securityContext.runAsNonRoot | bool | `true` | Membership security context run as non root |
| cloudprem.membership.securityContext.runAsUser | int | `1000` | Membership security context run as user |
| cloudprem.membership.service.annotations | object | `{}` | service annotations |
| cloudprem.membership.service.clusterIP | string | `""` | service cluster IP |
| cloudprem.membership.service.ports.grpc.port | int | `8082` | service grpc port |
| cloudprem.membership.service.ports.http | object | `{"port":8080}` | service http port |
| cloudprem.membership.service.type | string | `"ClusterIP"` | service type |
| cloudprem.membership.serviceAccount.annotations | object | `{}` | Service account annotations |
| cloudprem.membership.serviceAccount.create | bool | `true` | Service account creation |
| cloudprem.membership.serviceAccount.name | string | `""` | Service account name |
| cloudprem.membership.tolerations | list | `[]` | Membership tolerations |
| cloudprem.membership.volumeMounts | list | `[]` | Membership volume mounts |
| cloudprem.membership.volumes | list | `[]` | Membership volumes |
| cloudprem.portal.affinity | object | `{}` | Portal affinity |
| cloudprem.portal.annotations | object | `{}` | Portal annotations  |
| cloudprem.portal.autoscaling.enabled | bool | `false` |  |
| cloudprem.portal.autoscaling.maxReplicas | int | `100` |  |
| cloudprem.portal.autoscaling.minReplicas | int | `1` |  |
| cloudprem.portal.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| cloudprem.portal.config.additionalEnv | list | `[]` | Additional environment variables |
| cloudprem.portal.config.cookie.existingSecret | string | `""` | Cookie existing secret |
| cloudprem.portal.config.cookie.secret | string | `"changeMe2"` | Cookie secret |
| cloudprem.portal.config.cookie.secretKeys | object | `{"secret":""}` | Cookie secret key |
| cloudprem.portal.config.environment | string | `"production"` | Portal environment |
| cloudprem.portal.config.featuresDisabled[0] | string | `"notifications"` |  |
| cloudprem.portal.config.featuresDisabled[1] | string | `"sessions"` |  |
| cloudprem.portal.config.managedStack | string | `"1"` | Enable managed stack mode (1 = enabled, 0 = disabled) |
| cloudprem.portal.config.migration.annotations | object | `{}` | Membership job migration annotations Argo CD translate `pre-install,pre-upgrade` to: argocd.argoproj.io/hook: PreSync |
| cloudprem.portal.config.migration.serviceAccount.annotations | object | `{}` |  |
| cloudprem.portal.config.migration.serviceAccount.create | bool | `true` |  |
| cloudprem.portal.config.migration.serviceAccount.name | string | `""` |  |
| cloudprem.portal.config.migration.ttlSecondsAfterFinished | string | `""` |  |
| cloudprem.portal.config.migration.volumeMounts | list | `[]` |  |
| cloudprem.portal.config.migration.volumes | list | `[]` |  |
| cloudprem.portal.config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| cloudprem.portal.config.sentry.dsn | string | `""` | Sentry DSN |
| cloudprem.portal.config.sentry.enabled | bool | `false` | Sentry enabled |
| cloudprem.portal.config.sentry.environment | string | `""` | Sentry environment |
| cloudprem.portal.config.sentry.release | string | `""` | Sentry release |
| cloudprem.portal.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| cloudprem.portal.image.repository | string | `"ghcr.io/formancehq/portal"` | image repository |
| cloudprem.portal.image.tag | string | `""` | image tag |
| cloudprem.portal.imagePullSecrets | list | `[]` |  |
| cloudprem.portal.ingress.annotations | object | `{}` | ingress annotations |
| cloudprem.portal.ingress.className | string | `""` | ingress class name |
| cloudprem.portal.ingress.enabled | bool | `true` | ingress enabled |
| cloudprem.portal.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.portal.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | ingress host |
| cloudprem.portal.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| cloudprem.portal.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| cloudprem.portal.ingress.labels | object | `{}` | ingress labels |
| cloudprem.portal.ingress.tls | list | `[]` | ingress tls |
| cloudprem.portal.livenessProbe | object | `{}` | Portal liveness probe |
| cloudprem.portal.nodeSelector | object | `{}` | Portal node selector |
| cloudprem.portal.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| cloudprem.portal.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| cloudprem.portal.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| cloudprem.portal.podSecurityContext | object | `{}` | Pod Security Context |
| cloudprem.portal.readinessProbe | object | `{}` | Portal readiness probe |
| cloudprem.portal.replicas | int | `1` | Number of replicas |
| cloudprem.portal.resources | object | `{}` | Portal resources |
| cloudprem.portal.securityContext | object | `{}` | Container Security Context |
| cloudprem.portal.service.annotations | object | `{}` | service annotations |
| cloudprem.portal.service.clusterIP | string | `""` | service cluster IP |
| cloudprem.portal.service.ports.http | object | `{"port":3000}` | service http port |
| cloudprem.portal.service.type | string | `"ClusterIP"` | service type |
| cloudprem.portal.serviceAccount.annotations | object | `{}` | Service account annotations |
| cloudprem.portal.serviceAccount.create | bool | `true` | Service account creation |
| cloudprem.portal.serviceAccount.name | string | `""` | Service account name |
| cloudprem.portal.tolerations | list | `[]` | Portal tolerations |
| cloudprem.portal.volumeMounts | list | `[]` |  |
| cloudprem.portal.volumes | list | `[]` | Portal volumes |
| regions.agent.agent.authentication.clientID | string | `"REGION_ID"` |  |
| regions.agent.agent.authentication.clientSecret | string | `""` |  |
| regions.agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| regions.agent.agent.authentication.mode | string | `"bearer"` |  |
| regions.agent.agent.baseUrl | string | `"https://sandbox.formance.cloud"` |  |
| regions.agent.agent.id | string | `"aws-eu-west-1-sandbox"` |  |
| regions.agent.enabled | bool | `false` |  |
| regions.agent.image.tag | string | `""` |  |
| regions.agent.server.address | string | `"app.formance.cloud:443"` |  |
| regions.agent.server.tls.enabled | bool | `true` |  |
| regions.agent.server.tls.insecureSkipVerify | bool | `true` |  |
| regions.fullnameOverride | string | `""` |  |
| regions.ledger-operator.image.tag | string | `"v3.0.0-beta.1"` |  |
| regions.ledger-operator.ledgerImage.tag | string | `"v3.0.0-beta.1"` |  |
| regions.nameOverride | string | `""` |  |
| regions.operator.fullnameOverride | string | `"operator"` |  |
| regions.operator.image.repository | string | `"ghcr.io/formancehq/operator"` |  |
| regions.operator.image.tag | string | `""` |  |
| regions.operator.nameOverride | string | `"operator"` |  |
| regions.operator.operator-crds.create | bool | `false` |  |
| regions.operator.operator.disableWebhooks | bool | `false` |  |
| regions.operator.operator.enableLeaderElection | bool | `true` |  |
| regions.operator.operator.env | string | `"private"` |  |
| regions.operator.operator.metricsAddr | string | `":8080"` |  |
| regions.operator.operator.probeAddr | string | `":8081"` |  |
| regions.operator.operator.region | string | `"private"` |  |
| regions.settings | object | `{}` |  |
| regions.stacks | object | `{}` |  |
| regions.versions.allowDefaultVersion | bool | `false` |  |
| regions.versions.create | bool | `true` |  |
| regions.versions.files."v2.0".auth | string | `"v2.4.3"` |  |
| regions.versions.files."v2.0".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v2.0".ledger | string | `"v2.0.33"` |  |
| regions.versions.files."v2.0".orchestration | string | `"v2.0.33"` |  |
| regions.versions.files."v2.0".payments | string | `"v2.0.33"` |  |
| regions.versions.files."v2.0".reconciliation | string | `"v2.0.33"` |  |
| regions.versions.files."v2.0".search | string | `"v2.0.33"` |  |
| regions.versions.files."v2.0".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v2.0".wallets | string | `"v2.0.33"` |  |
| regions.versions.files."v2.0".webhooks | string | `"v2.0.33"` |  |
| regions.versions.files."v2.1".auth | string | `"v2.4.3"` |  |
| regions.versions.files."v2.1".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v2.1".ledger | string | `"v2.1.7"` |  |
| regions.versions.files."v2.1".orchestration | string | `"v2.0.33"` |  |
| regions.versions.files."v2.1".payments | string | `"v2.0.33"` |  |
| regions.versions.files."v2.1".reconciliation | string | `"v2.0.33"` |  |
| regions.versions.files."v2.1".search | string | `"v2.0.33"` |  |
| regions.versions.files."v2.1".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v2.1".wallets | string | `"v2.1.5"` |  |
| regions.versions.files."v2.1".webhooks | string | `"v2.4.1"` |  |
| regions.versions.files."v2.2".auth | string | `"v2.4.3"` |  |
| regions.versions.files."v2.2".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v2.2".ledger | string | `"v2.2.59"` |  |
| regions.versions.files."v2.2".orchestration | string | `"v2.0.33"` |  |
| regions.versions.files."v2.2".payments | string | `"v2.0.33"` |  |
| regions.versions.files."v2.2".reconciliation | string | `"v2.0.33"` |  |
| regions.versions.files."v2.2".search | string | `"v2.0.33"` |  |
| regions.versions.files."v2.2".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v2.2".wallets | string | `"v2.1.5"` |  |
| regions.versions.files."v2.2".webhooks | string | `"v2.4.1"` |  |
| regions.versions.files."v3.0".auth | string | `"v2.4.3"` |  |
| regions.versions.files."v3.0".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v3.0".ledger | string | `"v2.2.59"` |  |
| regions.versions.files."v3.0".orchestration | string | `"v2.1.1"` |  |
| regions.versions.files."v3.0".payments | string | `"v3.0.19"` |  |
| regions.versions.files."v3.0".reconciliation | string | `"v2.3.1"` |  |
| regions.versions.files."v3.0".search | string | `"v2.1.0"` |  |
| regions.versions.files."v3.0".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v3.0".wallets | string | `"v2.1.5"` |  |
| regions.versions.files."v3.0".webhooks | string | `"v2.4.1"` |  |
| regions.versions.files."v3.1".auth | string | `"v2.4.3"` |  |
| regions.versions.files."v3.1".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v3.1".ledger | string | `"v2.3.22"` |  |
| regions.versions.files."v3.1".orchestration | string | `"v2.4.1"` |  |
| regions.versions.files."v3.1".payments | string | `"v3.0.19"` |  |
| regions.versions.files."v3.1".reconciliation | string | `"v2.3.1"` |  |
| regions.versions.files."v3.1".search | string | `"v2.1.0"` |  |
| regions.versions.files."v3.1".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v3.1".wallets | string | `"v2.1.5"` |  |
| regions.versions.files."v3.1".webhooks | string | `"v2.4.1"` |  |
| regions.versions.files."v3.2".auth | string | `"v2.5.0"` |  |
| regions.versions.files."v3.2".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v3.2".ledger | string | `"v2.4.12"` |  |
| regions.versions.files."v3.2".mcp | string | `"v0.3.0"` |  |
| regions.versions.files."v3.2".orchestration | string | `"v2.6.2"` |  |
| regions.versions.files."v3.2".payments | string | `"v3.4.1"` |  |
| regions.versions.files."v3.2".reconciliation | string | `"v2.4.1"` |  |
| regions.versions.files."v3.2".search | string | `"v2.1.0"` |  |
| regions.versions.files."v3.2".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v3.2".transactionplane | string | `"v0.11.1"` |  |
| regions.versions.files."v3.2".wallets | string | `"v2.2.0"` |  |
| regions.versions.files."v3.2".webhooks | string | `"v2.5.3"` |  |
| regions.versions.files."v4.0-beta".auth | string | `"v2.5.0"` |  |
| regions.versions.files."v4.0-beta".gateway | string | `"v2.3.1"` |  |
| regions.versions.files."v4.0-beta".ledger | string | `"v3.0.0-beta.1"` |  |
| regions.versions.files."v4.0-beta".mcp | string | `"v0.3.0"` |  |
| regions.versions.files."v4.0-beta".orchestration | string | `"v2.6.2"` |  |
| regions.versions.files."v4.0-beta".payments | string | `"v3.4.1"` |  |
| regions.versions.files."v4.0-beta".reconciliation | string | `"v2.4.1"` |  |
| regions.versions.files."v4.0-beta".search | string | `"v2.1.0"` |  |
| regions.versions.files."v4.0-beta".stargate | string | `"v2.2.2"` |  |
| regions.versions.files."v4.0-beta".transactionplane | string | `"v0.11.1"` |  |
| regions.versions.files."v4.0-beta".wallets | string | `"v2.2.0"` |  |
| regions.versions.files."v4.0-beta".webhooks | string | `"v2.5.3"` |  |
| regions.versions.files.default.auth | string | `"v0.4.4"` |  |
| regions.versions.files.default.gateway | string | `"v2.0.18"` |  |
| regions.versions.files.default.ledger | string | `"v1.10.14"` |  |
| regions.versions.files.default.orchestration | string | `"v0.2.1"` |  |
| regions.versions.files.default.payments | string | `"v1.0.0-rc.5"` |  |
| regions.versions.files.default.reconciliation | string | `"v0.1.0"` |  |
| regions.versions.files.default.search | string | `"v0.10.0"` |  |
| regions.versions.files.default.stargate | string | `"v0.1.10"` |  |
| regions.versions.files.default.wallets | string | `"v0.4.6"` |  |
| regions.versions.files.default.webhooks | string | `"v2.0.18"` |  |
| regions.agent.affinity | object | `{}` |  |
| regions.agent.agent.additionalBaseUrls | list | `[]` |  |
| regions.agent.agent.authentication.clientID | string | `""` | Mode: Bearer |
| regions.agent.agent.authentication.clientSecret | string | `""` | Mode: Beare |
| regions.agent.agent.authentication.existingSecret | string | `""` | Existing Secret |
| regions.agent.agent.authentication.issuer | string | `"https://app.formance.cloud/api"` |  |
| regions.agent.agent.authentication.mode | string | `"bearer"` | mode: token|bearer |
| regions.agent.agent.authentication.secretKeys.secret | string | `""` |  |
| regions.agent.agent.authentication.token | string | `""` | Mode: Token |
| regions.agent.agent.baseUrl | string | `""` |  |
| regions.agent.agent.id | string | `"b7549a16-f74a-4815-ab1e-bb8ef1c3833b"` |  |
| regions.agent.agent.outdated | bool | `false` | Any region: - this flag is sync by the server - it will mark the associated region as outdated and will block any new Creation/Enable/Restore |
| regions.agent.agent.production | bool | `false` | Only for public region This flag is not sync by the server |
| regions.agent.config.monitoring.serviceName | string | `"agent"` |  |
| regions.agent.debug | bool | `false` |  |
| regions.agent.fullnameOverride | string | `""` |  |
| regions.agent.image.pullPolicy | string | `"IfNotPresent"` |  |
| regions.agent.image.repository | string | `"ghcr.io/formancehq/agent"` |  |
| regions.agent.image.tag | string | `""` |  |
| regions.agent.imagePullSecrets | list | `[]` |  |
| regions.agent.nameOverride | string | `""` |  |
| regions.agent.nodeSelector | object | `{}` |  |
| regions.agent.podAnnotations | object | `{}` |  |
| regions.agent.podSecurityContext | object | `{}` |  |
| regions.agent.resources.limits.cpu | string | `"100m"` |  |
| regions.agent.resources.limits.memory | string | `"128Mi"` |  |
| regions.agent.resources.requests.cpu | string | `"100m"` |  |
| regions.agent.resources.requests.memory | string | `"128Mi"` |  |
| regions.agent.securityContext | object | `{}` |  |
| regions.agent.server.address | string | `"app.formance.cloud:443"` |  |
| regions.agent.server.tls.enabled | bool | `true` |  |
| regions.agent.server.tls.insecureSkipVerify | bool | `true` |  |
| regions.agent.serviceAccount.annotations | object | `{}` |  |
| regions.agent.tolerations | list | `[]` |  |
