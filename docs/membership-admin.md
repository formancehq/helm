# Membership admin API

The Membership chart can run a separate HTTP Deployment for administrative
calls. The Deployment uses the same Membership image as the public Deployment,
with the `serve-admin` command. The option defaults to `false` in the
`membership`, `cloudprem`, and Formance Enterprise Edition charts. Leave it off
until the shared image contains `serve-admin`. The default Membership image in
this chart does not contain that command.

## Configure the Service

Use the same global values in any of the three charts:

```yaml
global:
  platform:
    membership:
      admin:
        enabled: true
        allowedCallers:
          - namespace: ops
            podLabels:
              app.kubernetes.io/name: membership-automation
```

Each caller must match both the namespace name and every listed pod label. An
empty list denies pod ingress. The chart rejects an entry with a blank namespace
or no pod labels. The policy allows TCP port 8080 only; it does not restrict
egress to PostgreSQL or the event publisher.

Provision a Secret in the release namespace containing the PEM-encoded RSA
public key that matches Membership's active signing key. Export that key from
the signing key with `openssl pkey -pubout` in your key management environment.
Keep the private signing key in its existing Secret. Configure the public key
reference as follows for the standalone chart:

```yaml
config:
  admin:
    tls:
      existingSecret: membership-admin-tls
  auth:
    signingPublicKey:
      existingSecret: membership-signing-public-key
      key: signing.pub
```

Nest this `config` block under `membership` in `cloudprem` and under
`cloudprem.membership` in `formance`. The admin Deployment reads the public key
through `SIGNING_PUBLIC_KEY`. It shares the Membership licence configuration,
PostgreSQL and event settings.
After rotating the signing key, update the matching public key and restart the
admin Deployment; changing a Secret's contents does not restart its pods.

TLS is enabled by default. The TLS Secret must exist in the release namespace and contain `tls.crt` and
`tls.key` in the standard `kubernetes.io/tls` format. The certificate SAN must
include the exact Service hostname that callers use. For the example below,
that name is `formance-membership-admin.control.svc`. Include any additional
DNS names callers use, such as the cluster's fully qualified Service name.
Configure callers to trust the CA that signed the certificate, and include
the intermediate certificates in `tls.crt` when needed. The Kubernetes HTTPS
probe checks readiness without verifying the certificate's trust chain or
hostname. Verify both from an allowed caller before switching traffic.
Restart the admin Deployment after updating the TLS Secret so Membership
loads the new certificate.

To run the admin listener over plain HTTP on an isolated test network, set
`config.admin.tls.enabled: false`. No TLS Secret is required or mounted in
this mode. The Service URL and readiness probe use HTTP. The ClusterIP,
NetworkPolicy, signing public key and token scopes still apply; bearer
tokens are transmitted in cleartext between the caller and the listener.

Set `config.admin.networkPolicy.enabled: false` to have the chart omit the
admin NetworkPolicy. In that case, `allowedCallers` has no effect. Pods that
can reach the ClusterIP can attempt to authenticate from any namespace
unless another policy restricts ingress. The Service still has no public
route and still requires the configured token scopes.

## Use a custom public CONFIG

By default, the chart derives the admin ConfigMap from the chart's public
ConfigMap. If `config.additionalEnv` points the public `CONFIG` elsewhere,
provide both sets of validation metadata from that file:

```yaml
config:
  admin:
    validation:
      staticClients:
        - id: membership-automation
          internal: true
          public: false
      organizationSSOTrust:
        destination-org:
          - source-org@00000000-0000-4000-8000-000000000001
```

Use `staticClients: []` or `organizationSSOTrust: {}` if the corresponding
section is empty. Keep this metadata in sync with the public configuration.
The chart writes only client IDs, the `public` and `internal` flags, and the
organization trust map. Do not put credentials, signing keys, or connectors
in these values. The admin pod mounts its own ConfigMap.

## Call the API

For a release named `formance` in namespace `control`, the API base URL is
`https://formance-membership-admin.control.svc:8080/internal`. From an allowed
pod, get the OpenAPI document at `GET /internal/openapi` with a `system:Read`
or `system:Admin` token. Mutations require `system:Admin`.

The Service appends `-admin` to the public Membership resource name (the chart
shortens the prefix if needed). `ADMIN_SERVICE_URL` contains the Service
origin without a path. Membership adds `/internal` to the routes and the
OpenAPI server URL. The readiness probe uses `GET /_healthcheck` with the configured scheme at
the root to check PostgreSQL. The liveness probe checks the TCP listener, so a
PostgreSQL outage removes the pod from the Service without restarting it.
`SERVICE_URL` remains the canonical token issuer, such as
`https://membership.example.com/api`.

Use a CNI that enforces Kubernetes NetworkPolicy and check that the source
namespaces have the `kubernetes.io/metadata.name` label (automatic on Kubernetes
1.22 and later). NetworkPolicy rules are additive: any other policy selecting
the admin pods can grant more ingress. Check namespace-wide and CNI-specific
policies for overlaps. Keep the Service private: don't reference it from an
Ingress, Gateway API route, or AWS TargetGroupBinding. The Membership chart
rejects references to it from the AWS target groups it manages for Membership
and Dex. Restrict who can assign the caller labels in allowed namespaces.

## Roll out in order

1. The Membership maintainer publishes an image with `serve-admin` that keeps
   the existing public operations during the caller migration.
2. The operator configures that image for Membership, provisions the matching
   public key, and provisions the TLS certificate and caller trust when TLS
   is enabled. The operator checks ingress policy, then enables the admin
   Deployment.
   The existing Membership migration workflow still owns database migrations.
3. The operator verifies readiness, fetches `/internal/openapi` from an allowed
   pod with an authorized token, and checks that unlisted pods cannot connect.
   The caller owners then move their requests to the internal address.
4. After all callers migrate and the breaking API change has approval, the
   Membership maintainer removes the admin operations from the public API and
   SDK. The operator verifies their absence on the public endpoint. After that
   release, disabling the admin Deployment makes those operations unavailable.
