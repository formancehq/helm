# Formance cloudprem Helm chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/cloudprem)](https://artifacthub.io/packages/search?repo=cloudprem)
![Version: 3.0.3](https://img.shields.io/badge/Version-3.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.1.0](https://img.shields.io/badge/AppVersion-v1.1.0-informational?style=flat-square)

Formance control-plane

[Formance Cloudprem](https://docs.formance.com/deployment/cloudprem2/intro) is a platform that allows you to manage your users, organizations and your data plane.

## Requirements

Kubernetes: `>=1.14.0-0`

| Repository | Name | Version |
|------------|------|---------|
| file://../console-v3 | console-v3 | 2.X |
| file://../console | console | 2.X |
| file://../membership | membership | 2.X |
| file://../portal | portal | 2.X |

> [!IMPORTANT]
> You need to obtain a licence from the Formance team. (See [EE Licence](#ee-licence))

- SSL Certificate (Let's Encrypt or another)
- Public domain according to the certificate authority

## TL;DR

```bash

export YOUR_LICENCE=$YOUR_LICENCE_KEY
export YOUR_CLUSTER_ID=$YOUR_CLUSTER_ID
export BASE_DOMAIN=example.com
export BASE_DOMAIN_WILDCARD_CERTIFICATE=example-com-wildcard-certificate-tls

helm install cloudprem oci://ghcr.io/formancehq/helm/cloudprem \
  --set global.licence.token=$YOUR_LICENCE_KEY
  --set global.licence.clusterID=$YOUR_CLUSTER_ID
  --set global.serviceHost=$BASE_DOMAIN \
  --set membership.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE \
  --set portal.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE \
  --set console.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE \
  --set dex.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE
```

## Introduction

This chart bootstraps 5 different components that form the Formance Control Plane, additionally you will need to install the Formance Data Plane composed of a Kubernetes Operator.

In order to deploy the 5 different components, you must have a Kubernetes cluster with an Ingress Controller and valid SSL certificates for the different domains.

Following components need his own database:

- [Dex](https://dexidp.io/) (Authentication)
- Membership (User and Organization Management)

Addtionnaly all components need a public URL that can be accessible through a VPN or a public domain.

The deployment is done via Helm. Make sure you have Helm installed and configured.

You will first have to create a `values.yaml` file to define your values.

> [!TIP]
>By default, a PostgreSQL database is included in this configuration without any data persistence.

In order to do your first deployment you will need to complete the following steps:
- [Complete de minimal profile](#minimal-valuesyaml-profile)
- [Deploy Operator](https://docs.formance.com/operator/Installation)
- [Deploy Stack](#deploy-stack)
- [Init Cloudprem](#init-cloudprem)

## Minimal `values.yaml` profile

> [!IMPORTANT]
> Each certificate must be in the form of `.global.serviceHost` following the example below:
>- Console: `console.{{ .Values.global.serviceHost }}`
>- Portal: `portal.{{ .Values.global.serviceHost }}`
>- Membership: `membership.{{ .Values.global.serviceHost }}`
>- Dex: `dex.{{ .Values.global.serviceHost }}`

> [!TIP]
> A quick win is to use a wildcard certificate for all the components on `*.{{ .Values.global.serviceHost }}}`.
>Then reference the secret same as the example bellow.

> [!TIP]
> You can use [Cert Manager](https://cert-manager.io/docs/) to manage your certificates.

```yaml
global:
  serviceHost: "example.com"

membership:
  ingress:
    enabled: true
    tls:
      - secretName: example-com-wildcard-certificate-tls
  dex:
    ingress:
      enabled: true
      tls:
        - secretName: example-com-wildcard-certificate-tls

portal:
  ingress:
    enabled: true
    tls:
      - secretName: example-com-wildcard-certificate-tls

console:
  ingress:
    enabled: true
    tls:
      - secretName: example-com-wildcard-certificate-tls
```

## Init Cloudprem

### [Install FCTL](https://docs.formance.com/getting-started/fctl-quick-start)

```bash
# Linux amd64, arm64
ARCH="amd64"; curl -L -o fctl.tar.gz "https://github.com/formancehq/stack/releases/download/v2.0.9/fctl_linux-$ARCH.tar.gz" \
&& tar -xvf fctl.tar.gz \
&& sudo mv fctl /usr/local/bin \
&& chmod +x /usr/local/bin/fctl \
&& rm fctl.tar.gz

# MacOS
brew install formancehq/tap/fctl
brew upgrade fctl

## Debian
deb [trusted=yes] https://apt.fury.io/formance/ / > /etc/apt/sources.list
apt update && apt install fctl
```

```bash
fctl version
```

### Login on membership

> [!IMPORTANT]
> According to [Dex default configuration](#dex-configuration), you can login with the following credentials: `admin@formance.com` / `password`.
> You can also define `Google`, `Github`, `Microsoft` as OAuth2 connectors.
> Additional configuration can be found on the [Dex documentation](https://artifacthub.io/packages/helm/dex/dex).

```bash
export BASE_DOMAIN=example.com
fctl -p $user login --membership-uri https://membership.$BASE_DOMAIN/api
```

This will create a new organization and a user.

### (Optional) Add domain for Auto Login

```bash

export EMAIL_DOMAIN_NAME=example.com

fctl cloud organizations list

fctl cloud organizations update ORGANIZATION_ID --domain=$EMAIL_DOMAIN_NAME --default-organization-role=GUEST --default-stack-role=GUEST

fctl cloud organizations list
```

The possible values are GUEST or ADMIN.
This allows to give the rights by default to a user who logs in with an email of domain DOMAIN_NAME.

### Init databases

```sql
insert into membership."regions" (id, base_url, name, creator_id, created_at, production, active) values (
    gen_random_uuid(),
    'https://${BASE_DOMAIN}',
    'default',
    (select id from membership."users" where id = (
        select owner_id from membership."organizations" limit 1
    )),
    now(),
    true,
    true
);
insert into membership."stacks" (name, organization_id, id, region_id, created_at, updated_at, stargate_enabled, client_secret, state, status, expected_status) values (
    'default',
     (select id from membership."organizations" limit 1),
     'sdgsd', -- update if needed, this is your stack id
     (select id from membership."regions" limit 1),
     now(),
     now(),
     false,
     gen_random_uuid(),
     'ACTIVE',
     'READY',
     'READY'
);
```

This query will create the region and a stack associated with your organization in that region.

### Create stack on cluster

After creating your region and your Stack.
You can retrieve your Organization ID and search & replace the value of your organization ID and BASE_URL

> [!IMPORTANT]
> In the Formance CRDs, the stack name has format `<organization ID>-<stack ID>`

```bash
cat <<"EOF" > stack.sh

#!bin/bash

export BASE_DOMAIN_WILDCARD_CERTIFICATE=example-com-wildcard-certificate-tls
export BASE_DOMAIN=example.com
export ORGANIZATION_ID=ylzsigispivc
export STACK_ID=sdgs

cat <<EOF > stack.yaml
---
apiVersion: formance.com/v1beta1
kind: Stack
metadata:
  name: ${ORGANIZATION_ID}-${STACK_ID}
spec:
  debug: true
  dev: true
  versionsFromFile: v2.0
---
apiVersion: formance.com/v1beta1
kind: Gateway
metadata:
  name: ${ORGANIZATION_ID}-${STACK_ID}
spec:
  stack: ${ORGANIZATION_ID}-${STACK_ID}
  ingress:
    host: ${ORGANIZATION_ID}-${STACK_ID}.${BASE_DOMAIN}
    scheme: https
    tls:
      secretName: ${BASE_DOMAIN_WILDCARD_CERTIFICATE}
---
apiVersion: formance.com/v1beta1
kind: Ledger
metadata:
  name: ${ORGANIZATION_ID}-${STACK_ID}
spec:
  stack: ${ORGANIZATION_ID}-${STACK_ID}
---
apiVersion: formance.com/v1beta1
kind: Auth
metadata:
  name: ${ORGANIZATION_ID}-${STACK_ID}
spec:
  stack: ${ORGANIZATION_ID}-${STACK_ID}
  enableScopes: true
  delegatedOIDCServer:
    clientID: stack_${ORGANIZATION_ID}_${STACK_ID}
    clientSecret: changeMe
    issuer: $(echo "https://membership.${BASE_DOMAIN}/api")
EOF

echo "EOF" >> stack.sh && bash stack.sh

kubectl apply -f . /stack.yml
```

Here, we have deployed a basic configuration. Refer to [the Formance operator documentation](https://docs.formance.com/operator/Requirements) for information on possible configurations.

### Access to the portal

```bash
fctl ui
```

## Profiles

See [profiles](./profiles) for more examples.

## Migration

### From v2.X.X To v3.0.0

#### EE Licence

Membership now need a EE licence. You can get a licence from the Formance team. The licence is valid for 1 cluster.
Then configure it through the `global.licence.token` and `global.licence.clusterID` values. See [Licence configuration](#licence-configuration) for more information.

#### RBAC

Membership service contains a behavior-breaking change within the RBAC module.

Before, permissions were managed dynamically on the organization and stack with a *fallback* on the organization resource. (default organization accesses and default stack accesses). Which led to a lot of confusion and inconsistency regarding the user's permissions

The fallback has been removed from the RBAC module and is only used when a new user joins the organization.

#### OAuth clients and cookies

Portal and Console v3 are no longer sharing Oauth clients and cookies. The cookie domain is now set on the app domain. Enabling `console` will set the domain on the parent domain. See #breaking-changes for config changes.

#### Breaking changes

> The structure does not change

- `.global.platform.cookie` has been moved to `.global.platform.console.cookie`
- `.global.platform.portal.cookie` has been removed in favor of `.portal.config.cookie`
  - `.global.platform.portal.cookie.secretKeys.encryptionKey` -> `.portal.config.cookie.secretKeys.secret`
  - `.global.platform.portal.cookie.encryptionKey` -> `.portal.config.cookie.secret`
- `.global.platform.membership.oauthClient` has been moved to `.global.platform.portal.oauth.client` for console backward compatibility but can be different when using console-v3.
- `.console.enabled` -> `.global.platform.console.enabled`
- `.membership.enabled` -> `.global.platform.membership.enabled`
- `.portal.enabled` -> `.global.platform.portal.enabled`

#### Additions

- `global.platform.consoleV3.oauth.client` has been added to manage the new console-v3 oauth client.
- `console-v3.config.cookie` has been added to manage the new console-v3 cookie.

### From v1.0.X To v2.0.X

A global configuration has been introduced to manage values accross different services. To see the detail of the default values, please refer to the [Global Parameters](#global-configuration) section.

Each platform key has beeen moved to `global.platform`

This chart adds several `existingSecret` and `secretKeys` to manage the secret either from configuration or from a secret.

The chart is now divided into 5 charts :
- Portal
- Console
- Membership
- Dex
- Postgresql

#### Breaking changes by service

Labels:
- Each service now depends on the global configuration to manage the labels according to [Kubernetes best recommendations](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
  - Each service now has a static `app.kubernetes.io/app` label overridable by with `.<service>.nameOverride`
- By default, if not using the `.<service>.nameOverride`, the `app.kubernetes.io/name` changes and will generate a breaking change in the deployment.
  - To keep the default behavior managed by formance. Make sure if you use the embedded postgresql to `Retain` the related volume. Then you can `helm uninstall <release> --namespace <namespace>` and then `helm install <release> --namespace <namespace>`. (If you change the name of the release, make sure to bind the `postgresql.primary.persistence.existingClaim` accordingly)
  - This change permits Formance to help you debugging any resources created by the chart by using the `app.kubernetes.io/name`, and ``app.kubernetes.io/instance` labels. (then with `kubectl get pods -l app.kubernetes.io/name=console -A` or all the instance `kubectl get pods -l app.kubernetes.io/instance=cloudprem -A`)
 
Global:
- `.serviceAccount` has been removed, use `.<service>.serviceAccount` instead.
- `.commonLabels` has been removed

Console:
-  `.console.membership` has been removed, and is now managed through the `.global.platform.membership.oauthClient`. It's going to be used by all platform services.

Dex:
- `.dex.config` has been moved `.dex.configOverrides` enabled by default with`.dex.createConfigSecretOverrides` allowing templating.

#### Others changes

Console:
-  `.console.config.stargate_url` has been removed, it will be managed for a kubernetes service.
-  `.console.config.feature_disabled` has been removed, it will be managed through `.console.config.additionalEnv.FEATURE_DISABLED`.
-  `.console.config.managed_stack` has been removed, console now manage the stack through portal.
-  `.console.config.database` has been removed, console now manage the session through portal cookie.

-  `.console.config.redirect_url` has been deprecated, it is now templated with `https://console.global.serviceHost`.
-  `.console.config.encryption_key` has been deprecated, it will be managed through `.global.platform.cookie.encryptionKey`.

Membership:
- `.membership.config.url` has been removed, it will be templated through `.global.platform.membership.host` and `.global.platform.membership.scheme`
- `.membership.config.postgresqlUrl` has been deprecated, it will be mangaged through `.global.postgresql.auth`.
- OAuth clients are now managed within the template and disablable with  `.global.platform.enabled`, `.membership.config.fctl`. Additionaly, you can add new client with `.membership.config.additionalOAuthClients`

Dex:

- `.dex.envVars` and `.dex.configOverrides.staticClients.[].secretEnv` can be used together to set static clients secrets.

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/helm/charts/cloudprem>

## Values

### Global AWS configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.aws.elb | bool | `false` | Enable AWS ELB across all services, appropriate <service>.aws.targertGroup must be set |
| global.aws.iam | bool | `false` | Enable AWS IAM Authentification |
| console-v3.aws | object | `{"targetGroups":{"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Console target groups |
| membership.aws | object | `{"targetGroups":{"grpc":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.grpc.port }}"},"targetGroupARN":"","targetType":"ip"},"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Membership target groups |
| membership.dex.aws | object | `{"targetGroups":{"dex-http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"dex.fullname\" .Subcharts.dex }}","port":"{{ .Values.dex.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Target Groups |
| portal.aws | object | `{"targetGroups":{"http":{"ipAddressType":"ipv4","serviceRef":{"name":"{{ include \"core.fullname\" $ }}","port":"{{ .Values.service.ports.http.port }}"},"targetGroupARN":"","targetType":"ip"}}}` | AWS Portal target groups |

### Global configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.debug | bool | `false` | Enable debug mode |
| global.monitoring.batch | bool | `false` | Enable otel batching |
| global.monitoring.logs.enabled | bool | `true` | Enable logging |
| global.monitoring.logs.format | string | `"json"` | Format |
| global.monitoring.logs.level | string | `"info"` | Level: Info, Debug, Error |
| global.monitoring.traces.enabled | bool | `false` | Enable otel tracing |
| global.monitoring.traces.endpoint | string | `"localhost"` | Endpoint |
| global.monitoring.traces.exporter | string | `"otlp"` | Exporter |
| global.monitoring.traces.insecure | bool | `true` | Insecure |
| global.monitoring.traces.mode | string | `"grpc"` | Mode |
| global.monitoring.traces.port | int | `4317` | Port |
| global.nats.url | string | `""` | NATS URL: nats://nats:4222 nats://$PUBLISHER_NATS_USERNAME:$PUBLISHER_NATS_PASSWORD@nats:4222 |
| global.platform.console.cookie.encryptionKey | string | `"changeMe00"` | is used to encrypt a cookie that share authentication between platform services (console, portal, ...),is used to store the current state organizationId-stackId It is not shared with console-v3 and the domain is only limited to portal app |
| global.platform.console.cookie.existingSecret | string | `""` | is the name of the secret |
| global.platform.console.cookie.secretKeys | object | `{"encryptionKey":""}` | is the key contained within the secret |
| global.platform.console.host | string | `"console.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.console.scheme | string | `"https"` | is the scheme for the console |
| global.platform.consoleV3 | object | `{"host":"console.v3.{{ .Values.global.serviceHost }}","oauth":{"client":{"existingSecret":"","id":"console-v3","secret":"changeMe2","secretKeys":{"secret":""}}},"scheme":"https"}` | Console V3: EXPERIMENTAL |
| global.platform.consoleV3.enabled | bool | `false` | Enable console-v3 |
| global.platform.consoleV3.host | string | `"console.v3.{{ .Values.global.serviceHost }}"` | is the host for the console |
| global.platform.consoleV3.oauth.client.existingSecret | string | `""` | is the name of the secret |
| global.platform.consoleV3.oauth.client.id | string | `"console-v3"` | is the id of the client |
| global.platform.consoleV3.oauth.client.scopes | list | `["supertoken","accesses","remember_me","keep_refresh_token"]` | is the name of the secret |
| global.platform.consoleV3.oauth.client.secret | string | `"changeMe2"` | is the secret of the client |
| global.platform.consoleV3.oauth.client.secretKeys | object | `{"secret":""}` | is the key contained within the secret |
| global.platform.consoleV3.scheme | string | `"https"` | is the scheme for the console |
| global.platform.membership.host | string | `"membership.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.relyingParty.host | string | `"dex.{{ .Values.global.serviceHost }}"` | is the host for the membership |
| global.platform.membership.relyingParty.path | string | `""` | is the path for the relying party issuer |
| global.platform.membership.relyingParty.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.membership.scheme | string | `"https"` | is the scheme for the membership |
| global.platform.portal.host | string | `"portal.{{ .Values.global.serviceHost }}"` | is the host for the portal |
| global.platform.portal.oauth.client.existingSecret | string | `""` | is the name of the secret |
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
| membership.config.migration.enabled | bool | `true` | Enable migration job |
| membership.config.migration.postgresql.auth.existingSecret | string | `""` | Name of existing secret to use for PostgreSQL credentials (overrides `auth.existingSecret`). |
| membership.config.migration.postgresql.auth.password | string | `""` | Password for the "postgres" admin user (overrides `auth.postgresPassword`) |
| membership.config.migration.postgresql.auth.secretKeys.adminPasswordKey | string | `""` | Name of key in existing secret to use for PostgreSQL credentials (overrides `auth.secretKeys.adminPasswordKey`). Only used when `global.postgresql.auth.existingSecret` is set. |
| membership.config.migration.postgresql.auth.username | string | `""` | Name for a custom user to create (overrides `auth.username`) |

### Licence configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.licence.clusterID | string | `""` | Obtain your licence cluster id with `kubectl get ns kube-system -o jsonpath='{.metadata.uid}'` |
| global.licence.existingSecret | string | `""` | Licence Client Token as a secret |
| global.licence.issuer | string | `"https://license.formance.cloud/keys"` | Licence Environment  |
| global.licence.secretKeys.token | string | `""` | Key in existing secret to use for Licence Client Token |
| global.licence.token | string | `""` | Licence Client Token delivered by contacting [Formance](https://formance.com) |

### Stargate configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.platform.stargate.enabled | bool | `false` | if enabled, the stackApiUrl is not required It will be templated with `{{ printf "http://%s-%s:8080/#{organizationId}/#{stackId}/api" .Release.Name "stargate" -}}` |
| global.platform.stargate.stackApiUrl | string | `""` | if stargate is disabled, the stackApiUrl is defaulted to the `http://gateway.#{organizationId}-#{stackId}.svc:8080/api` To allow external access sets the stackApiUrl to an external url |

### Dex configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| membership.dex.configOverrides | object | `{"enablePasswordDB":true,"oauth2":{"responseTypes":["code","token","id_token"],"skipApprovalScreen":true},"staticPasswords":[{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}],"storage":{"type":"postgres"}}` | Config override allow template function. Database is setup on the chart global, make sure that user/password when using kubernetes secret |
| membership.dex.configOverrides.enablePasswordDB | bool | `true` | enable password db |
| membership.dex.configOverrides.oauth2.responseTypes | list | `["code","token","id_token"]` | oauth2 response types |
| membership.dex.configOverrides.oauth2.skipApprovalScreen | bool | `true` | oauth2 skip approval screen |
| membership.dex.configOverrides.staticPasswords[0] | object | `{"email":"admin@formance.com","hash":"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W","userID":"08a8684b-db88-4b73-90a9-3cd1661f5466","username":"admin"}` | static passwords email |
| membership.dex.configOverrides.staticPasswords[0].hash | string | `"$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W"` | static passwords hash |
| membership.dex.configOverrides.staticPasswords[0].userID | string | `"08a8684b-db88-4b73-90a9-3cd1661f5466"` | static passwords user id |
| membership.dex.configOverrides.staticPasswords[0].username | string | `"admin"` | static passwords username |
| membership.dex.configSecret.create | bool | `false` | Dex config secret create Default secret provided by the dex chart |
| membership.dex.configSecret.createConfigSecretOverrides | bool | `true` | Dex config secret create config secret overrides Enable secret config overrides provided by the cloudprem chart |
| membership.dex.configSecret.name | string | `"membership-dex-config"` | Dex config secret name |
| membership.dex.enabled | bool | `true` | Enable dex |
| membership.dex.envVars | list | `[]` | Dex additional environment variables |
| membership.dex.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| membership.dex.image.repository | string | `"ghcr.io/formancehq/dex"` | image repository |
| membership.dex.image.tag | string | `"v1.0.4"` | image tag |
| membership.dex.ingress.annotations | object | `{}` | Dex ingress annotations |
| membership.dex.ingress.className | string | `""` | Dex ingress class name |
| membership.dex.ingress.enabled | bool | `true` | Dex ingress enabled |
| membership.dex.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.relyingParty.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | Dex ingress host |
| membership.dex.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | Dex ingress path refer to .Values.global.platform.membership.relyingParty.host.path |
| membership.dex.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Dex ingress path type |
| membership.dex.ingress.tls | list | `[]` | Dex ingress tls |
| membership.dex.resources | object | `{}` | Dex resources |

### Membership Feature

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| membership.feature.disableEvents | bool | `true` | Membership feature disable events |
| membership.feature.managedStacks | bool | `true` | Membership feature managed stacks |
| membership.feature.migrationHooks | bool | `false` | Run migration in a hook |

### Postgresql configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| membership.postgresql.architecture | string | `"standalone"` | Postgresql architecture |
| membership.postgresql.enabled | bool | `true` | Enable postgresql |
| membership.postgresql.fullnameOverride | string | `"postgresql"` | Postgresql fullname override |
| membership.postgresql.primary | object | `{"persistence":{"enabled":false}}` | Postgresql primary persistence enabled |

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
| global.platform.membership.oidc.host | string | `"dex.{{ .Values.global.serviceHost }}"` | is the host for the oidc |
| global.platform.membership.oidc.scheme | string | `"https"` | is the scheme for the issuer |
| global.platform.portal.enabled | bool | `true` |  |
| console.affinity | object | `{}` | Console affinity |
| console.annotations | object | `{}` | Console annotations  |
| console.autoscaling.enabled | bool | `false` |  |
| console.autoscaling.maxReplicas | int | `100` |  |
| console.autoscaling.minReplicas | int | `1` |  |
| console.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| console.aws.targetGroups.http.ipAddressType | string | `"ipv4"` | Target group IP address type |
| console.aws.targetGroups.http.serviceRef.name | string | `"{{ include \"core.fullname\" $ }}"` | Target group service reference name |
| console.aws.targetGroups.http.serviceRef.port | string | `"{{ .Values.service.ports.http.port }}"` | Target group service reference port |
| console.aws.targetGroups.http.targetGroupARN | string | `""` | Target group ARN |
| console.aws.targetGroups.http.targetType | string | `"ip"` | Target group target type |
| console.config.additionalEnv | list | `[]` | Console additional environment variables |
| console.config.environment | string | `"production"` | Console environment |
| console.config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| console.config.sentry.dsn | string | `""` | Sentry DSN |
| console.config.sentry.enabled | bool | `false` | Sentry enabled |
| console.config.sentry.environment | string | `""` | Sentry environment |
| console.config.sentry.release | string | `""` | Sentry release |
| console.config.stargate_url | string | `""` | Deprecated |
| console.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| console.image.repository | string | `"ghcr.io/formancehq/console"` | image repository |
| console.image.tag | string | `""` | image tag |
| console.imagePullSecrets | list | `[]` | image pull secrets |
| console.ingress.annotations | object | `{}` | ingress annotations |
| console.ingress.className | string | `""` | ingress class name |
| console.ingress.enabled | bool | `true` | ingress enabled |
| console.ingress.hosts[0].host | string | `"{{ tpl .Values.global.platform.console.host $ }}"` | ingress host |
| console.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| console.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| console.ingress.tls | list | `[]` | ingress tls |
| console.livenessProbe | object | `{}` | Console liveness probe |
| console.nodeSelector | object | `{}` | Console node selector |
| console.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| console.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| console.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| console.podSecurityContext | object | `{}` | Pod Security Context |
| console.readinessProbe | object | `{}` | Console readiness probe |
| console.replicas | int | `1` | Number of replicas |
| console.resources | object | `{}` | Console resources |
| console.securityContext | object | `{}` | Container Security Context |
| console.service.annotations | object | `{}` | service annotations |
| console.service.clusterIP | string | `""` | service cluster IP |
| console.service.ports.http | object | `{"port":3000}` | service http port |
| console.service.type | string | `"ClusterIP"` | service type |
| console.serviceAccount.annotations | object | `{}` | Service account annotations |
| console.serviceAccount.create | bool | `true` | Service account creation |
| console.serviceAccount.name | string | `""` | Service account name |
| console.tolerations | list | `[]` | Console tolerations |
| console.volumeMounts | list | `[]` | Console volume mounts |
| console.volumes | list | `[]` | Console volumes |
| console-v3.affinity | object | `{}` | Console affinity |
| console-v3.annotations | object | `{}` | Console annotations  |
| console-v3.autoscaling.enabled | bool | `false` |  |
| console-v3.autoscaling.maxReplicas | int | `100` |  |
| console-v3.autoscaling.minReplicas | int | `1` |  |
| console-v3.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| console-v3.aws.targetGroups.http.ipAddressType | string | `"ipv4"` | Target group IP address type |
| console-v3.aws.targetGroups.http.serviceRef.name | string | `"{{ include \"core.fullname\" $ }}"` | Target group service reference name |
| console-v3.aws.targetGroups.http.serviceRef.port | string | `"{{ .Values.service.ports.http.port }}"` | Target group service reference port |
| console-v3.aws.targetGroups.http.targetGroupARN | string | `""` | Target group ARN |
| console-v3.aws.targetGroups.http.targetType | string | `"ip"` | Target group target type |
| console-v3.config.additionalEnv | list | `[]` | Console additional environment variables |
| console-v3.config.cookie.encryptionKey | string | `"changeMe00"` | is used to encrypt a cookie value |
| console-v3.config.cookie.existingSecret | string | `""` | is the name of the secret |
| console-v3.config.cookie.secretKeys | object | `{"encryptionKey":""}` | is the key contained within the secret |
| console-v3.config.environment | string | `"production"` | Console environment |
| console-v3.config.sentry | object | `{"authToken":{"existingSecret":"","secretKeys":{"value":""},"value":""},"dsn":"","enabled":false,"environment":"","release":""}` | Console additional environment variables FEATURE_DISABLED - name: FEATURE_DISABLED   value: "true" |
| console-v3.config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| console-v3.config.sentry.dsn | string | `""` | Sentry DSN |
| console-v3.config.sentry.enabled | bool | `false` | Sentry enabled |
| console-v3.config.sentry.environment | string | `""` | Sentry environment |
| console-v3.config.sentry.release | string | `""` | Sentry release |
| console-v3.config.stargate_url | string | `""` | Deprecated |
| console-v3.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| console-v3.image.repository | string | `"ghcr.io/formancehq/console-v3"` | image repository |
| console-v3.image.tag | string | `""` | image tag |
| console-v3.imagePullSecrets | list | `[]` | image pull secrets |
| console-v3.ingress.annotations | object | `{}` | ingress annotations |
| console-v3.ingress.className | string | `""` | ingress class name |
| console-v3.ingress.enabled | bool | `true` | ingress enabled |
| console-v3.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.consoleV3.host $ }}","paths":[{"path":"/","pathType":"Prefix"}]}` | ingress host |
| console-v3.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| console-v3.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| console-v3.ingress.tls | list | `[]` | ingress tls |
| console-v3.livenessProbe | object | `{}` | Console liveness probe |
| console-v3.nodeSelector | object | `{}` | Console node selector |
| console-v3.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| console-v3.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| console-v3.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| console-v3.podSecurityContext | object | `{}` | Pod Security Context |
| console-v3.readinessProbe | object | `{}` | Console readiness probe |
| console-v3.replicas | int | `1` | Number of replicas |
| console-v3.resources | object | `{}` | Console resources |
| console-v3.securityContext | object | `{}` | Container Security Context |
| console-v3.service.annotations | object | `{}` | service annotations |
| console-v3.service.clusterIP | string | `""` | service cluster IP |
| console-v3.service.ports.http | object | `{"port":3000}` | service http port |
| console-v3.service.type | string | `"ClusterIP"` | service type |
| console-v3.serviceAccount.annotations | object | `{}` | Service account annotations |
| console-v3.serviceAccount.create | bool | `true` | Service account creation |
| console-v3.serviceAccount.name | string | `""` | Service account name |
| console-v3.tolerations | list | `[]` | Console tolerations |
| console-v3.volumeMounts | list | `[]` | Console volume mounts |
| console-v3.volumes | list | `[]` | Console volumes |
| membership.affinity | object | `{}` | Membership affinity |
| membership.annotations | object | `{}` | Membership annotations  |
| membership.autoscaling | object | `{}` | Membership autoscaling |
| membership.commonLabels | object | `{}` | DEPRECATED Membership service |
| membership.config.additionalEnv | list | `[]` | Additional Environment variables on the main deployment |
| membership.config.auth.additionalOAuthClients | list | `[]` | Membership additional oauth clients |
| membership.config.auth.tokenValidity | object | `{"accessToken":"5m","refreshToken":"72h"}` | According to "nsuµmh" And https://github.com/spf13/cast/blob/e9ba3ce83919192b29c67da5bec158ce024fdcdb/caste.go#L61C3-L61C3 |
| membership.config.fctl | bool | `true` | Enable Fctl |
| membership.config.grpc.existingSecret | string | `""` |  |
| membership.config.grpc.secretKeys.secret | string | `"TOKENS"` |  |
| membership.config.grpc.tokens | list | `[]` | Membership agent grpc token |
| membership.config.job | object | `{"garbageCollector":{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"0 0 * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]},"invitationGC":{"concurrencyPolicy":"Forbid","resources":{},"restartPolicy":"Never","schedule":"0/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]},"stackLifeCycle":{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"*/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}}` | CronJob to manage the stack life cycle and the garbage collector |
| membership.config.job.garbageCollector | object | `{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"0 0 * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}` | Clean expired tokens and refresh tokens after X time |
| membership.config.job.stackLifeCycle | object | `{"concurrencyPolicy":"Forbid","enabled":false,"resources":{},"restartPolicy":"Never","schedule":"*/30 * * * *","startingDeadlineSeconds":200,"suspend":false,"tolerations":[],"volumeMounts":[],"volumes":[]}` | Job create 2 jobs to eaither warn or prune a stacks This does not change the state of the stack WARN: Mark stack Disposable -> trigger a mail PRUNE: Mark stack Warned -> trigger a mail It blocks stack cycles if supendend It is highly recommended to enable it as it is the only way we control |
| membership.config.migration.annotations | object | `{}` | Membership job migration annotations Argo CD translate `pre-install,pre-upgrade` to: argocd.argoproj.io/hook: PreSync |
| membership.config.migration.serviceAccount.annotations | object | `{}` |  |
| membership.config.migration.serviceAccount.create | bool | `true` |  |
| membership.config.migration.serviceAccount.name | string | `""` |  |
| membership.config.migration.ttlSecondsAfterFinished | string | `""` |  |
| membership.config.migration.volumeMounts | list | `[]` |  |
| membership.config.migration.volumes | list | `[]` |  |
| membership.config.oidc | object | `{"clientId":"membership","clientSecret":"changeMe","existingSecret":"","scopes":["openid","email","federated:id"],"secretKeys":{"secret":""}}` | Membership relying party connection url |
| membership.config.oidc.clientId | string | `"membership"` | Membership oidc client id |
| membership.config.oidc.clientSecret | string | `"changeMe"` | Membership oidc client secret |
| membership.config.oidc.existingSecret | string | `""` | Membership oidc existing secret |
| membership.config.oidc.scopes | list | `["openid","email","federated:id"]` | Membership oidc redirect uri |
| membership.config.oidc.scopes[2] | string | `"federated:id"` | Membership Dex federated id scope |
| membership.config.oidc.secretKeys | object | `{"secret":""}` | Membership oidc secret key |
| membership.config.publisher.clientID | string | `"membership"` |  |
| membership.config.publisher.jetstream.replicas | int | `1` |  |
| membership.config.publisher.topicMapping | string | `"membership"` |  |
| membership.config.stack.cycle.delay.disable | string | `"72h"` |  |
| membership.config.stack.cycle.delay.disablePollingDelay | string | `"1m"` |  |
| membership.config.stack.cycle.delay.disposable | string | `"360h"` |  |
| membership.config.stack.cycle.delay.prune | string | `"720h"` |  |
| membership.config.stack.cycle.delay.prunePollingDelay | string | `"1m"` |  |
| membership.config.stack.cycle.delay.warn | string | `"72h"` |  |
| membership.config.stack.cycle.dryRun | bool | `true` |  |
| membership.config.stack.minimalStackModules[0] | string | `"Auth"` |  |
| membership.config.stack.minimalStackModules[1] | string | `"Ledger"` |  |
| membership.config.stack.minimalStackModules[2] | string | `"Payments"` |  |
| membership.config.stack.minimalStackModules[3] | string | `"Gateway"` |  |
| membership.debug | bool | `false` | Membership debug |
| membership.dev | bool | `false` | Membership dev, disable ssl verification |
| membership.fullnameOverride | string | `""` | Membership fullname override |
| membership.image.pullPolicy | string | `"IfNotPresent"` | Membership image pull policy |
| membership.image.repository | string | `"ghcr.io/formancehq/membership"` | Membership image repository |
| membership.image.tag | string | `""` | Membership image tag |
| membership.imagePullSecrets | list | `[]` | Membership image pull secrets |
| membership.ingress.annotations | object | `{}` | Membership ingress annotations |
| membership.ingress.className | string | `""` | Membership ingress class name |
| membership.ingress.enabled | bool | `true` | Membership ingress enabled |
| membership.ingress.hosts[0] | object | `{"host":"{{ tpl .Values.global.platform.membership.host $ }}","paths":[{"path":"/api","pathType":"Prefix"}]}` | Membership ingress host |
| membership.ingress.hosts[0].paths[0] | object | `{"path":"/api","pathType":"Prefix"}` | Membership ingress path |
| membership.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Membership ingress path type |
| membership.ingress.tls | list | `[]` | Membership ingress tls |
| membership.initContainers | list | `[]` | Membership init containers |
| membership.nameOverride | string | `""` | Membership name override |
| membership.nodeSelector | object | `{}` | Membership node selector |
| membership.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| membership.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| membership.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| membership.podSecurityContext | object | `{}` | Membership pod security context |
| membership.replicaCount | int | `1` | Count of replicas |
| membership.resources | object | `{}` | Membership resources |
| membership.securityContext.capabilities | object | `{"drop":["ALL"]}` | Membership security context capabilities drop |
| membership.securityContext.readOnlyRootFilesystem | bool | `true` | Membership security context read only root filesystem |
| membership.securityContext.runAsNonRoot | bool | `true` | Membership security context run as non root |
| membership.securityContext.runAsUser | int | `1000` | Membership security context run as user |
| membership.service.annotations | object | `{}` | service annotations |
| membership.service.clusterIP | string | `""` | service cluster IP |
| membership.service.ports.grpc.port | int | `8082` | service grpc port |
| membership.service.ports.http | object | `{"port":8080}` | service http port |
| membership.service.type | string | `"ClusterIP"` | service type |
| membership.serviceAccount.annotations | object | `{}` | Service account annotations |
| membership.serviceAccount.create | bool | `true` | Service account creation |
| membership.serviceAccount.name | string | `""` | Service account name |
| membership.tolerations | list | `[]` | Membership tolerations |
| membership.volumeMounts | list | `[]` | Membership volume mounts |
| membership.volumes | list | `[]` | Membership volumes |
| portal.affinity | object | `{}` | Portal affinity |
| portal.annotations | object | `{}` | Portal annotations  |
| portal.autoscaling.enabled | bool | `false` |  |
| portal.autoscaling.maxReplicas | int | `100` |  |
| portal.autoscaling.minReplicas | int | `1` |  |
| portal.autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| portal.config.additionalEnv | list | `[]` | Additional environment variables |
| portal.config.cookie.existingSecret | string | `""` | Cookie existing secret |
| portal.config.cookie.secret | string | `"changeMe2"` | Cookie secret |
| portal.config.cookie.secretKeys | object | `{"secret":""}` | Cookie secret key |
| portal.config.environment | string | `"production"` | Portal environment |
| portal.config.featuresDisabled[0] | string | `"console_v3_beta"` |  |
| portal.config.sentry.authToken | object | `{"existingSecret":"","secretKeys":{"value":""},"value":""}` | Sentry Auth Token |
| portal.config.sentry.dsn | string | `""` | Sentry DSN |
| portal.config.sentry.enabled | bool | `false` | Sentry enabled |
| portal.config.sentry.environment | string | `""` | Sentry environment |
| portal.config.sentry.release | string | `""` | Sentry release |
| portal.image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| portal.image.repository | string | `"ghcr.io/formancehq/portal"` | image repository |
| portal.image.tag | string | `""` | image tag |
| portal.imagePullSecrets | list | `[]` |  |
| portal.ingress.annotations | object | `{}` | ingress annotations |
| portal.ingress.className | string | `""` | ingress class name |
| portal.ingress.enabled | bool | `true` | ingress enabled |
| portal.ingress.hosts[0].host | string | `"{{ tpl .Values.global.platform.portal.host $ }}"` | ingress host |
| portal.ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix"}` | ingress path |
| portal.ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | ingress path type |
| portal.ingress.tls | list | `[]` | ingress tls |
| portal.livenessProbe | object | `{}` | Portal liveness probe |
| portal.nodeSelector | object | `{}` | Portal node selector |
| portal.podDisruptionBudget.enabled | bool | `false` | Enable pod disruption budget |
| portal.podDisruptionBudget.maxUnavailable | int | `0` | Maximum unavailable pods |
| portal.podDisruptionBudget.minAvailable | int | `1` | Minimum available pods |
| portal.podSecurityContext | object | `{}` | Pod Security Context |
| portal.readinessProbe | object | `{}` | Portal readiness probe |
| portal.replicas | int | `1` | Number of replicas |
| portal.resources | object | `{}` | Portal resources |
| portal.securityContext | object | `{}` | Container Security Context |
| portal.service.annotations | object | `{}` | service annotations |
| portal.service.clusterIP | string | `""` | service cluster IP |
| portal.service.ports.http | object | `{"port":3000}` | service http port |
| portal.service.type | string | `"ClusterIP"` | service type |
| portal.serviceAccount.annotations | object | `{}` | Service account annotations |
| portal.serviceAccount.create | bool | `true` | Service account creation |
| portal.serviceAccount.name | string | `""` | Service account name |
| portal.tolerations | list | `[]` | Portal tolerations |
| portal.volumeMounts | list | `[]` | Portal volume mounts |
| portal.volumes | list | `[]` | Portal volumes |
