#!/usr/bin/env bash
set -euo pipefail

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

cat >"$test_dir/values.yaml" <<'VALUES'
config:
  migration:
    additionalEnv:
    - name: NODE_EXTRA_CA_CERTS
      value: /etc/ssl/certs/database-ca.pem
    - name: FROM_SECRET
      valueFrom:
        secretKeyRef:
          name: some-secret
          key: some-key
    - name: TEMPLATED
      value: '{{ .Release.Name }}-value'
VALUES

helm template env-test charts/ledger-ui --values "$test_dir/values.yaml" >"$test_dir/output.yaml"

# The migration Job gets the variables, after the postgres ones, with template
# expressions rendered.
yq -s -e '
  [.[] | select(.kind == "Job") | .spec.template.spec.containers[0].env]
  | length == 1
    and (.[0][-3:] == [
      {name: "NODE_EXTRA_CA_CERTS", value: "/etc/ssl/certs/database-ca.pem"},
      {name: "FROM_SECRET", valueFrom: {secretKeyRef: {name: "some-secret", key: "some-key"}}},
      {name: "TEMPLATED", value: "env-test-value"}
    ])
' "$test_dir/output.yaml" >/dev/null

# The Deployment does not get them: config.additionalEnv is its own list.
yq -s -e '
  [.[] | select(.kind == "Deployment") | [.spec.template.spec.containers[].env[]?.name]]
  | length == 1 and (.[0] | index("NODE_EXTRA_CA_CERTS") == null)
' "$test_dir/output.yaml" >/dev/null

# Without the value, the Job ends with the postgres URI as before.
helm template env-test charts/ledger-ui >"$test_dir/output.yaml"
yq -s -e '
  [.[] | select(.kind == "Job") | .spec.template.spec.containers[0].env[-1].name]
  == ["POSTGRES_URI"]
' "$test_dir/output.yaml" >/dev/null

echo "ledger-ui: migration Job additionalEnv, templating, Deployment and default passed"
