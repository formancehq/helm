# Formance Cloudprem Helm Chart

This chart is used to deploy Formance Cloudprem on a Kubernetes cluster.

[Formance Cloudprem](https://docs.formance.com/deployment/cloudprem2/intro) is a platform that allows you to manage your users, organizations and your data plane.

## TL;DR

```bash
export BASE_DOMAIN=example.com
export BASE_DOMAIN_WILDCARD_CERTIFICATE=example-com-wildcard-certificate-tls

helm install cloudprem oci://ghcr.io/formancehq/helm/cloudprem \
  --set global.serviceHost=$BASE_DOMAIN \
  --set membership.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE \
  --set portal.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE \
  --set console.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE \
  --set dex.ingress.tls[0].secretName=$BASE_DOMAIN_WILDCARD_CERTIFICATE
```

## Requirements

- SSL Certificate (Let's Encrypt or another)
- Public domain according to the certificate authority
- Kubernetes Cluster > 1.14

## Control plane components

- Portal > 0.0.1
- Console > 2.2.1
- Membership > 0.28.0
- Dex > 0.28.0

<!-- ![diagram](./controlplane.svg) -->

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
> A quick win is to use a wildcard certificate for all the components on `*.{{ .Values.global.serviceHost }}`.
>Then reference the secret same as the example bellow.

> [!TIP]
> You can use [Cert Manager](https://cert-manager.io/docs/) to manage your certificates.

```yaml

global:
  serviceHost: ""

membership:
  ingress:
    tls:
      - secretName: example-com-wildcard-certificate-tls

portal:
  ingress:
    tls:
      - secretName: example-com-wildcard-certificate-tls

console:
  ingress:
    tls:
      - secretName: example-com-wildcard-certificate-tls

dex:
  ingress:
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

## Migration

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
-  `.console.config.redirect_url` has been deprecated, it is now templated with https://console`.global.serviceHost`.
-  `.console.config.feature_disabled` has been removed, it will be managed through `.console.config.additionalEnv.FEATURE_DISABLED`.
-  `.console.config.encryption_key` has been deprecated, it will be managed through `.global.platform.cookie.encryptionKey`.
-  `.console.config.managed_stack` has been removed, console now manage the stack through portal.
-  `.console.config.database` has been removed, console now manage the session through portal cookie. 
-  `.console.monitoring.traces` has been deprecated, it will be managed through `.global.monitoring.traces`

Membership:
-  `.membership.config.url` is deprecated, it will be templated through `https://memberhsip.{{ .Values.global.serviceHost }}` or ingress

- `.membership.config.postgresqlUrl` has been deprecated, it will be mangaged through `.global.postgresql.auth`. 
  
Dex:

- `.dex.envVars` and `.dex.configOverrides.staticClients.[].secretEnv` can be used together to set static clients secrets.


## Parameters

### Global configuration

| Name                                                       | Description                                                                                                                                                                     | Value             |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------- |
| `global.debug`                                             | Enable debug mode                                                                                                                                                               | `false`           |
| `global.serviceHost`                                       | is the base domain for console, portal, membership                                                                                                                              | `""`              |
| `global.platform.cookie.encryptionKey`                     | is used to encrypt a cookie that share authentication between platform services (console, portal, ...),is used to store the current state organizationId-stackId                | `changeMe00`      |
| `global.platform.cookie.existingSecret`                    | is the name of the secret                                                                                                                                                       | `""`              |
| `global.platform.cookie.secretKeys.encryptionKey`          | is the key contained within the secret                                                                                                                                          | `""`              |
| `global.platform.membership.oauthClient.id`                | is the id of the client                                                                                                                                                         | `platform`        |
| `global.platform.membership.oauthClient.secret`            | is the secret of the client                                                                                                                                                     | `changeMe1`       |
| `global.platform.membership.oauthClient.existingSecret`    | is the name of the secret                                                                                                                                                       | `""`              |
| `global.platform.membership.oauthClient.secretKeys.secret` | is the key contained within the secret                                                                                                                                          | `""`              |
| `global.postgresql.auth.postgresPassword`                  | Password for the "postgres" admin user (overrides `auth.postgresPassword`)                                                                                                      | `formance`        |
| `global.postgresql.auth.username`                          | Name for a custom user to create (overrides `auth.username`)                                                                                                                    | `formance`        |
| `global.postgresql.auth.password`                          | Password for the custom user to create (overrides `auth.password`)                                                                                                              | `formance`        |
| `global.postgresql.auth.database`                          | Name for a custom database to create (overrides `auth.database`)                                                                                                                | `formance`        |
| `global.postgresql.auth.existingSecret`                    | Name of existing secret to use for PostgreSQL credentials (overrides `auth.existingSecret`).                                                                                    | `""`              |
| `global.postgresql.auth.secretKeys.adminPasswordKey`       | Name of key in existing secret to use for PostgreSQL credentials (overrides `auth.secretKeys.adminPasswordKey`). Only used when `global.postgresql.auth.existingSecret` is set. | `""`              |
| `global.postgresql.auth.secretKeys.userPasswordKey`        | Name of key in existing secret to use for PostgreSQL credentials (overrides `auth.secretKeys.userPasswordKey`). Only used when `global.postgresql.auth.existingSecret` is set.  | `""`              |
| `global.postgresql.host`                                   | Host for PostgreSQL (overrides included postgreql `host`)                                                                                                                       | `""`              |
| `global.postgresql.additionalArgs`                         | Additional arguments for PostgreSQL Connection URI                                                                                                                              | `sslmode=disable` |
| `global.postgresql.service.ports.postgresql`               | PostgreSQL service port (overrides `service.ports.postgresql`)                                                                                                                  | `5432`            |

### Portal configuration

| Name                                        | Description                      | Value                                      |
| ------------------------------------------- | -------------------------------- | ------------------------------------------ |
| `portal.enabled`                            | Enable portal                    | `true`                                     |
| `portal.serviceAccount.create`              | Service account creation         | `true`                                     |
| `portal.serviceAccount.name`                | Service account name             | `""`                                       |
| `portal.serviceAccount.annotations`         | Service account annotations      | `{}`                                       |
| `portal.replicas`                           | Number of replicas               | `1`                                        |
| `portal.image.repository`                   | Portal image repository          | `ghcr.io/formancehq/membership-ui`         |
| `portal.image.pullPolicy`                   | Portal image pull policy         | `IfNotPresent`                             |
| `portal.image.tag`                          | Portal image tag                 | `764bb7e199e1d2882e4d5cd205eada0ef0abc283` |
| `portal.ingress.enabled`                    | Enable portal ingress            | `true`                                     |
| `portal.ingress.className`                  | Ingress class name               | `""`                                       |
| `portal.ingress.annotations`                | Ingress annotations              | `{}`                                       |
| `portal.ingress.hosts[0].host`              | Ingress host                     | `portal.{{ .Values.global.serviceHost }}`  |
| `portal.ingress.hosts[0].paths[0].path`     | Ingress path                     | `/`                                        |
| `portal.ingress.hosts[0].paths[0].pathType` | Ingress path type                | `Prefix`                                   |
| `portal.ingress.tls`                        | Ingress tls                      | `[]`                                       |
| `portal.config.environment`                 | Portal environment               | `production`                               |
| `portal.config.cookie.secret`               | Cookie secret                    | `changeMe2`                                |
| `portal.config.cookie.existingSecret`       | Cookie existing secret           | `""`                                       |
| `portal.config.cookie.secretKeys.secret`    | Cookie secret key                | `""`                                       |
| `portal.config.additionalEnv`               | Additional environment variables | `{}`                                       |
| `portal.config.cookie.secret`               | Cookie secret                    | `changeMe2`                                |
| `portal.service.annotations`                | Service annotations              | `{}`                                       |
| `portal.service.type`                       | Service type                     | `ClusterIP`                                |
| `portal.service.clusterIP`                  | Service cluster IP               | `""`                                       |
| `portal.service.ports.http.port`            | Service http port                | `3000`                                     |
| `portal.service.ports.http.nodePort`        | Service node port                | `undefined`                                |
| `portal.volumeMounts`                       | Portal volume mounts             | `[]`                                       |
| `portal.volumes`                            | Portal volumes                   | `[]`                                       |
| `portal.resources`                          | Portal resources                 | `{}`                                       |
| `portal.readinessProbe`                     | Portal readiness probe           | `{}`                                       |
| `portal.livenessProbe`                      | Portal liveness probe            | `{}`                                       |
| `portal.nodeSelector`                       | Portal node selector             | `{}`                                       |
| `portal.tolerations`                        | Portal tolerations               | `[]`                                       |
| `portal.affinity`                           | Portal affinity                  | `{}`                                       |

### Console configuration

| Name                                            | Description                                               | Value                                      |
| ----------------------------------------------- | --------------------------------------------------------- | ------------------------------------------ |
| `console.enabled`                               | Enable console                                            | `true`                                     |
| `console.serviceAccount.create`                 | Service account creation                                  | `true`                                     |
| `console.serviceAccount.name`                   | Service account name                                      | `""`                                       |
| `console.serviceAccount.annotations`            | Service account annotations                               | `{}`                                       |
| `console.replicas`                              | Number of replicas                                        | `1`                                        |
| `console.image.repository`                      | Console image repository                                  | `ghcr.io/formancehq/console`               |
| `console.image.pullPolicy`                      | Console image pull policy                                 | `IfNotPresent`                             |
| `console.image.tag`                             | Console image tag                                         | `9431e5f4b4b1a03cb8f02ef1676507b9c023f2bb` |
| `console.resources`                             | Console resources                                         | `{}`                                       |
| `console.readinessProbe`                        | Console readiness probe                                   | `{}`                                       |
| `console.livenessProbe`                         | Console liveness probe                                    | `{}`                                       |
| `console.service.annotations`                   | Console service annotations                               | `{}`                                       |
| `console.service.type`                          | Console service type                                      | `ClusterIP`                                |
| `console.service.clusterIP`                     | Console service cluster IP                                | `""`                                       |
| `console.service.ports.http.port`               | Console service http port                                 | `3000`                                     |
| `console.service.ports.http.nodePort`           | Console service node port                                 | `undefined`                                |
| `console.ingress.enabled`                       | Console ingress enabled                                   | `true`                                     |
| `console.ingress.className`                     | Console ingress class name                                | `""`                                       |
| `console.ingress.annotations`                   | Console ingress annotations                               | `{}`                                       |
| `console.ingress.hosts[0].host`                 | Console ingress host                                      | `console.{{ .Values.global.serviceHost }}` |
| `console.ingress.hosts[0].paths[0].path`        | Console ingress path                                      | `/`                                        |
| `console.ingress.hosts[0].paths[0].pathType`    | Console ingress path type                                 | `Prefix`                                   |
| `console.ingress.tls`                           | Console ingress tls                                       | `[]`                                       |
| `console.volumeMounts`                          | Console volume mounts                                     | `[]`                                       |
| `console.volumes`                               | Console volumes                                           | `[]`                                       |
| `console.nodeSelector`                          | Console node selector                                     | `{}`                                       |
| `console.tolerations`                           | Console tolerations                                       | `[]`                                       |
| `console.affinity`                              | Console affinity                                          | `{}`                                       |
| `console.config.environment`                    | Console environment                                       | `production`                               |
| `console.config.additionalEnv`                  | Console additional environment variables                  | `{}`                                       |
| `console.config.additionalEnv.HOST`             | Console additional environment variables HOST             |                                            |
| `console.config.additionalEnv.FEATURE_DISABLED` | Console additional environment variables FEATURE_DISABLED |                                            |
| `console.config.monitoring.traces.enabled`      | Console monitoring traces enabled                         | `false`                                    |
| `console.config.monitoring.traces.url`          | Console monitoring traces url                             | `""`                                       |
| `console.config.monitoring.traces.port`         | Console monitoring traces port                            | `4317`                                     |
| `console.config.monitoring.traces.attributes`   | Console monitoring traces attributes                      | `""`                                       |

### Membership configuration

| Name                                                            | Description                                           | Value                                                                                                                            |
| --------------------------------------------------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `membership.enabled`                                            | Enable membership                                     | `true`                                                                                                                           |
| `membership.serviceAccount.create`                              | Membership service account creation                   | `true`                                                                                                                           |
| `membership.serviceAccount.name`                                | Membership service account name                       | `""`                                                                                                                             |
| `membership.serviceAccount.annotations`                         | Membership service account annotations                | `{}`                                                                                                                             |
| `membership.replicaCount`                                       | Count of replicas                                     | `1`                                                                                                                              |
| `membership.image.repository`                                   | Membership image repository                           | `ghcr.io/formancehq/membership`                                                                                                  |
| `membership.image.pullPolicy`                                   | Membership image pull policy                          | `IfNotPresent`                                                                                                                   |
| `membership.image.tag`                                          | Membership image tag                                  | `v0.35.1`                                                                                                                        |
| `membership.imagePullSecrets`                                   | Membership image pull secrets                         | `[]`                                                                                                                             |
| `membership.nameOverride`                                       | Membership name override                              | `""`                                                                                                                             |
| `membership.fullnameOverride`                                   | Membership fullname override                          | `""`                                                                                                                             |
| `membership.feature.managedStacks`                              | Membership feature managed stacks                     | `true`                                                                                                                           |
| `membership.feature.disableEvents`                              | Membership feature disable events                     | `true`                                                                                                                           |
| `membership.podSecurityContext`                                 | Membership pod security context                       | `{}`                                                                                                                             |
| `membership.securityContext.capabilities.drop`                  | Membership security context capabilities drop         | `["ALL"]`                                                                                                                        |
| `membership.securityContext.readOnlyRootFilesystem`             | Membership security context read only root filesystem | `true`                                                                                                                           |
| `membership.securityContext.runAsNonRoot`                       | Membership security context run as non root           | `true`                                                                                                                           |
| `membership.securityContext.runAsUser`                          | Membership security context run as user               | `1000`                                                                                                                           |
| `membership.resources`                                          | Membership resources                                  | `{}`                                                                                                                             |
| `membership.autoscaling`                                        | Membership autoscaling                                | `{}`                                                                                                                             |
| `membership.nodeSelector`                                       | Membership node selector                              | `{}`                                                                                                                             |
| `membership.tolerations`                                        | Membership tolerations                                | `[]`                                                                                                                             |
| `membership.affinity`                                           | Membership affinity                                   | `{}`                                                                                                                             |
| `membership.debug`                                              | Membership debug                                      | `false`                                                                                                                          |
| `membership.dev`                                                | Membership dev                                        | `false`                                                                                                                          |
| `membership.initContainers`                                     | Membership init containers                            | `[]`                                                                                                                             |
| `membership.volumeMounts`                                       | Membership volume mounts                              | `[]`                                                                                                                             |
| `membership.volumes`                                            | Membership volumes                                    | `[]`                                                                                                                             |
| `membership.service.annotations`                                | Membership service annotations                        | `{}`                                                                                                                             |
| `membership.service.type`                                       | Membership service type                               | `ClusterIP`                                                                                                                      |
| `membership.service.clusterIP`                                  | Membership service cluster IP                         | `""`                                                                                                                             |
| `membership.service.ports.http.nodePort`                        | Membership service node port                          | `undefined`                                                                                                                      |
| `membership.service.ports.http.port`                            | Membership service port                               | `8080`                                                                                                                           |
| `membership.service.ports.grpc.port`                            | Membership service grpc port                          | `8082`                                                                                                                           |
| `membership.service.ports.grpc.nodePort`                        | Membership service grpc node port                     | `undefined`                                                                                                                      |
| `membership.ingress.enabled`                                    | Membership ingress enabled                            | `true`                                                                                                                           |
| `membership.ingress.className`                                  | Membership ingress class name                         | `""`                                                                                                                             |
| `membership.ingress.annotations`                                | Membership ingress annotations                        | `{}`                                                                                                                             |
| `membership.ingress.hosts[0].host`                              | Membership ingress host                               | `membership.{{ .Values.global.serviceHost }}`                                                                                    |
| `membership.ingress.hosts[0].paths[0].path`                     | Membership ingress path                               | `/api`                                                                                                                           |
| `membership.ingress.hosts[0].paths[0].pathType`                 | Membership ingress path type                          | `Prefix`                                                                                                                         |
| `membership.ingress.tls`                                        | Membership ingress tls                                | `[]`                                                                                                                             |
| `membership.config.postgresqlUrl`                               | DEPRECATED Membership postgresql coonection url       |                                                                                                                                  |
| `membership.config.url`                                         | DEPRECATED Membership pulic url, use ingress.host     | `https://membership.{{ .Values.global.serviceHost }}`                                                                            |
| `membership.config.oidc.issuer`                                 | Membership oidc issuer                                | `https://dex.{{ .Values.global.serviceHost }}`                                                                                   |
| `membership.config.oidc.clientId`                               | Membership oidc client id                             | `membership`                                                                                                                     |
| `membership.config.oidc.clientSecret`                           | Membership oidc client secret                         | `{}`                                                                                                                             |
| `membership.config.oidc.existingSecret`                         | Membership oidc existing secret                       | `""`                                                                                                                             |
| `membership.config.oidc.secretKeys.secret`                      | Membership oidc secret key                            | `""`                                                                                                                             |
| `membership.config.migration.annotations`                       | Membership migration annotations                      | `{}`                                                                                                                             |
| `membership.config.configMap.clients[0].id`                     | FCTL clients id                                       | `fctl`                                                                                                                           |
| `membership.config.configMap.clients[0].public`                 | FCTL is a public client                               | `true`                                                                                                                           |
| `membership.config.configMap.clients[1].secrets`                | Platform oauth client secret                          | `["$PLATFORM_OAUTH_CLIENT_SECRET"]`                                                                                              |
| `membership.config.configMap.clients[1].id`                     | Platform oauth client id                              | `{{ .Values.global.platform.membership.oauthClient.id }}`                                                                        |
| `membership.config.configMap.clients[1].redirectUris`           | Platform oauth client redirect uris                   | `["https://console.{{ .Values.global.serviceHost }}/auth/login","https://portal.{{ .Values.global.serviceHost }}/auth/login"]`   |
| `membership.config.configMap.clients[1].postLogoutRedirectUris` | Platform oauth client post logout redirect uris       | `["https://console.{{ .Values.global.serviceHost }}/auth/logout","https://portal.{{ .Values.global.serviceHost }}/auth/logout"]` |
| `membership.config.configMap.clients[1].scopes`                 | PLatform oauth client scopes                          | `["supertoken","accesses","remember_me","keep_refresh_token"]`                                                                   |

### Dex configuration

| Name                                                | Description                                                                     | Value                                                                            |
| --------------------------------------------------- | ------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `dex.enabled`                                       | Enable dex                                                                      | `true`                                                                           |
| `dex.image.repository`                              | Dex image repository                                                            | `ghcr.io/formancehq/dex`                                                         |
| `dex.image.pullPolicy`                              | Dex image pull policy                                                           | `IfNotPresent`                                                                   |
| `dex.image.tag`                                     | Dex image tag                                                                   | `v0.33.10`                                                                       |
| `dex.ingress.enabled`                               | Dex ingress enabled                                                             | `true`                                                                           |
| `dex.ingress.className`                             | Dex ingress class name                                                          | `""`                                                                             |
| `dex.ingress.annotations`                           | Dex ingress annotations                                                         | `{}`                                                                             |
| `dex.ingress.hosts[0].host`                         | Dex ingress host                                                                | `dex.{{ .Values.global.serviceHost }}`                                           |
| `dex.ingress.hosts[0].paths[0].path`                | Dex ingress path                                                                | `/`                                                                              |
| `dex.ingress.hosts[0].paths[0].pathType`            | Dex ingress path type                                                           | `Prefix`                                                                         |
| `dex.ingress.tls`                                   | Dex ingress tls                                                                 | `[]`                                                                             |
| `dex.resources`                                     | Dex resources                                                                   | `{}`                                                                             |
| `dex.configSecret.create`                           | Dex config secret create                                                        | `false`                                                                          |
| `dex.configSecret.createConfigSecretOverrides`      | Dex config secret create config secret overrides                                | `true`                                                                           |
| `dex.configSecret.name`                             | Dex config secret name                                                          | `membership-dex-config`                                                          |
| `dex.envVars`                                       | Dex additional environment variables                                            | `[]`                                                                             |
| `dex.envVars[0].name`                               | Membership client secret                                                        |                                                                                  |
| `dex.envVars[0].valueFrom.secretKeyRef.name`        | Membership client secret secret name                                            |                                                                                  |
| `dex.envVars[0].valueFrom.secretKeyRef.key`         | Membership client secret key                                                    |                                                                                  |
| `dex.configOverrides.issuer`                        | issuer url                                                                      | `https://dex.{{ .Values.global.serviceHost }}`                                   |
| `dex.configOverrides.oauth2.skipApprovalScreen`     | oauth2 skip approval screen                                                     | `true`                                                                           |
| `dex.configOverrides.oauth2.responseTypes`          | oauth2 response types                                                           | `["code","token","id_token"]`                                                    |
| `dex.configOverrides.logger.format`                 | logger format                                                                   | `json`                                                                           |
| `dex.configOverrides.storage.type`                  | storage type                                                                    | `postgres`                                                                       |
| `dex.configOverrides.storage.config.host`           | storage config host                                                             | `postgresql.formance-control.svc`                                                |
| `dex.configOverrides.storage.config.port`           | storage config port                                                             | `5432`                                                                           |
| `dex.configOverrides.storage.config.database`       | storage config database                                                         | `formance`                                                                       |
| `dex.configOverrides.storage.config.user`           | storage config user                                                             | `formance`                                                                       |
| `dex.configOverrides.storage.config.password`       | storage config password                                                         | `formance`                                                                       |
| `dex.configOverrides.storage.config.ssl.mode`       | storage config ssl mode                                                         | `disable`                                                                        |
| `dex.configOverrides.staticClients[0].name`         | static clients name                                                             | `membership`                                                                     |
| `dex.configOverrides.staticClients[0].id`           | static clients id                                                               | `{{ .Values.membership.config.oidc.clientId }}`                                  |
| `dex.configOverrides.staticClients[0].secret`       | static clients secret                                                           | `{{ tpl .Values.membership.config.oidc.clientSecret $ }}`                        |
| `dex.configOverrides.staticClients[0].secretEnv`    | static clients secret env var, do not use secret and secretEnv at the same time |                                                                                  |
| `dex.configOverrides.staticClients[0].secret`       | static clients secret string                                                    |                                                                                  |
| `dex.configOverrides.staticClients[0].redirectURIs` | static clients redirect uris                                                    | `["https://membership.{{ .Values.global.serviceHost }}/api/authorize/callback"]` |
| `dex.configOverrides.enablePasswordDB`              | enable password db                                                              | `true`                                                                           |
| `dex.configOverrides.staticPasswords[0].email`      | static passwords email                                                          | `admin@formance.com`                                                             |
| `dex.configOverrides.staticPasswords[0].hash`       | static passwords hash                                                           | `$2a$10$2b2cU8CPhOTaGrs1HRQuAueS7JTT5ZHsHSzYiFPm1leZck7Mc8T4W`                   |
| `dex.configOverrides.staticPasswords[0].username`   | static passwords username                                                       | `admin`                                                                          |
| `dex.configOverrides.staticPasswords[0].userID`     | static passwords user id                                                        | `08a8684b-db88-4b73-90a9-3cd1661f5466`                                           |

### Postgresql configuration

| Name                                     | Description                            | Value        |
| ---------------------------------------- | -------------------------------------- | ------------ |
| `postgresql.enabled`                     | Enable postgresql                      | `true`       |
| `postgresql.fullnameOverride`            | Postgresql fullname override           | `postgresql` |
| `postgresql.architecture`                | Postgresql architecture                | `standalone` |
| `postgresql.primary.persistence.enabled` | Postgresql primary persistence enabled | `false`      |
