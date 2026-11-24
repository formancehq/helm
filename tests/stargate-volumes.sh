#!/usr/bin/env bash
set -euo pipefail

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

cat >"$test_dir/values.yaml" <<'VALUES'
volumes:
- name: database-ca
  configMap:
    name: database-ca
volumeMounts:
- name: database-ca
  mountPath: /etc/ssl/database-ca
  readOnly: true
VALUES

helm template volumes-test charts/stargate --values "$test_dir/values.yaml" >"$test_dir/output.yaml"

# The Deployment gets the volumes and the container their mounts.
yq -s -e '
  [.[] | select(.kind == "Deployment") | .spec.template.spec]
  | length == 1
    and (.[0].volumes == [{name: "database-ca", configMap: {name: "database-ca"}}])
    and (.[0].containers[0].volumeMounts == [{name: "database-ca", mountPath: "/etc/ssl/database-ca", readOnly: true}])
' "$test_dir/output.yaml" >/dev/null

# Nothing without the values.
helm template volumes-test charts/stargate >"$test_dir/output.yaml"
yq -s -e '
  [.[] | select(.kind == "Deployment") | .spec.template.spec | (has("volumes") or (.containers[0] | has("volumeMounts")))]
  | length == 1 and all(. == false)
' "$test_dir/output.yaml" >/dev/null

echo "stargate: volumes, volumeMounts and default passed"
