#!/usr/bin/env bash
set -euo pipefail

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

cat >"$test_dir/values.yaml" <<'VALUES'
topologySpreadConstraints:
- maxSkew: 1
  topologyKey: omitted
  whenUnsatisfiable: DoNotSchedule
- maxSkew: 1
  topologyKey: empty
  whenUnsatisfiable: DoNotSchedule
  labelSelector: {}
- maxSkew: 1
  topologyKey: populated
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      custom: label
VALUES

for chart in membership portal; do
  helm template spread-test "charts/$chart" \
    --values tests/values/signing-key.yaml \
    --values "$test_dir/values.yaml" >"$test_dir/output.yaml"

  # Deployment: a constraint without labelSelector gets the chart's selector
  # labels, an explicit one (empty included) is kept as is.
  yq -s -e --arg chart "$chart" '
    [.[] | select(.kind == "Deployment" and .metadata.name == "spread-test-\($chart)")
       | .spec.template.spec.topologySpreadConstraints]
    | length == 1
      and (.[0] | length == 3)
      and (.[0][0].labelSelector == {matchLabels: {"app.kubernetes.io/name": $chart, "app.kubernetes.io/instance": "spread-test"}})
      and (.[0][1].labelSelector == {})
      and (.[0][2].labelSelector == {matchLabels: {custom: "label"}})
  ' "$test_dir/output.yaml" >/dev/null

  # Jobs (migration, wizard) are not constrained.
  yq -s -e '
    [.[] | select(.kind == "Job") | .spec.template.spec | has("topologySpreadConstraints")]
    | all(. == false)
  ' "$test_dir/output.yaml" >/dev/null

  # No constraint without the value.
  helm template spread-test "charts/$chart" \
    --values tests/values/signing-key.yaml >"$test_dir/output.yaml"
  yq -s -e '
    [.[] | select(.kind == "Deployment") | .spec.template.spec | has("topologySpreadConstraints")]
    | all(. == false)
  ' "$test_dir/output.yaml" >/dev/null

  echo "$chart: omitted, empty and populated labelSelector, Jobs and default passed"
done
