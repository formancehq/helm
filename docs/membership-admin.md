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
  auth:
    signingPublicKey:
      existingSecret: membership-signing-public-key
      key: signing.pub
```

Nest this `config` block under `membership` in `cloudprem` and under
`cloudprem.membership` in `formance`. The admin Deployment reads the public key
through `SIGNING_PUBLIC_KEY`. It shares PostgreSQL and event settings with
Membership, and receives static client metadata without OAuth client secrets.
After rotating the signing key, update the matching public key and restart the
admin Deployment; changing a Secret's contents does not restart its pods.

## Call the API

For a release named `formance` in namespace `control`, the API base URL is
`http://formance-membership-admin.control.svc:8080/internal`. From an allowed
pod, get the OpenAPI document at `GET /internal/openapi` with a `system:Read`
or `system:Admin` token. Mutations require `system:Admin`.

The Service appends `-admin` to the public Membership resource name (the chart
shortens the prefix if needed). `ADMIN_SERVICE_URL` contains the Service
origin without a path. Membership adds `/internal` to the routes and the
OpenAPI server URL. Both probes still use `GET /_healthcheck` at the root.
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
   public key, checks ingress policy overlaps, and enables the admin Deployment.
   The existing Membership migration workflow still owns database migrations.
3. The operator verifies readiness, fetches `/internal/openapi` from an allowed
   pod with an authorized token, and checks that unlisted pods cannot connect.
   The caller owners then move their requests to the internal address.
4. After all callers migrate and the breaking API change has approval, the
   Membership maintainer removes the admin operations from the public API and
   SDK. The operator verifies their absence on the public endpoint. After that
   release, disabling the admin Deployment makes those operations unavailable.
