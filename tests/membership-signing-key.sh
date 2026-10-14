#!/usr/bin/env bash
set -euo pipefail

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

expect_failure() {
  local message=$1
  shift
  if "$@" >"$test_dir/output.yaml" 2>"$test_dir/error.log"; then
    echo "Expected rendering to fail: $*" >&2
    exit 1
  fi
  if ! [[ $(cat "$test_dir/error.log") == *"$message"* ]]; then
    cat "$test_dir/error.log" >&2
    exit 1
  fi
}

# Synthetic multiline text checks serialization, not RSA validity.
printf 'render-only\nmultiline-value\n' >"$test_dir/value.pem"

for chart in membership cloudprem formance; do
  case "$chart" in
    membership) prefix=config.auth.signingKey; edition=() ;;
    cloudprem) prefix=membership.config.auth.signingKey; edition=() ;;
    formance)
      prefix=cloudprem.membership.config.auth.signingKey
      edition=(--set tags.EnterpriseEdition=true --set global.licence.existingSecret=render-test-licence --set global.licence.clusterID=render-test-cluster)
      ;;
  esac
  render=(helm template signing-test "charts/$chart" "${edition[@]}")

  # Given no key configuration, When rendering, Then fail with recovery guidance.
  expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' "${render[@]}"
  expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' "${render[@]}" --set "$prefix=null"
  expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' "${render[@]}" --set-string "$prefix.value= "

  # Given inline multiline text, Then preserve it and emit SIGNING_KEY once.
  "${render[@]}" --set-file "$prefix.value=$test_dir/value.pem" >"$test_dir/output.yaml"
  yq -s -e --rawfile expected "$test_dir/value.pem" '
    [.[] | select(.kind == "Deployment") | .spec.template.spec.containers[]
     | select(.name == "membership") | .env[] | select(.name == "SIGNING_KEY")]
    | length == 1 and (.[0].value == $expected) and (.[0] | has("valueFrom") | not)
  ' "$test_dir/output.yaml" >/dev/null

  # Given an existing Secret and an inline value, Then the Secret takes precedence.
  "${render[@]}" --set "$prefix.existingSecret=render-test-signing-key" --set "$prefix.key=rsa.pem" \
    --set-file "$prefix.value=$test_dir/value.pem" >"$test_dir/output.yaml"
  yq -s -e '
    [.[] | select(.kind == "Deployment") | .spec.template.spec.containers[]
     | select(.name == "membership") | .env[] | select(.name == "SIGNING_KEY")]
    | length == 1 and (.[0].valueFrom.secretKeyRef == {name:"render-test-signing-key", key:"rsa.pem"})
      and (.[0] | has("value") | not)
  ' "$test_dir/output.yaml" >/dev/null
  yq -s -e '
    [.[] | select(.kind == "Deployment") | .spec.template.spec.containers[]
     | select(.name == "membership") | .image] == ["ghcr.io/formancehq/membership:v2.8.0"]
  ' "$test_dir/output.yaml" >/dev/null

  expect_failure 'config.auth.signingKey.key is required' "${render[@]}" \
    --set "$prefix.existingSecret=render-test-signing-key" --set "$prefix.key="
  expect_failure 'config.auth.signingKey.existingSecret must not be blank' "${render[@]}" \
    --set-string "$prefix.existingSecret= "

  # Given only a Secret name, Then use the documented default key.
  "${render[@]}" --set "$prefix.existingSecret=render-test-signing-key" >"$test_dir/output.yaml"
  yq -s -e '
    [.[] | select(.kind == "Deployment") | .spec.template.spec.containers[]
     | select(.name == "membership") | .env[] | select(.name == "SIGNING_KEY")]
    | length == 1 and (.[0].valueFrom.secretKeyRef == {name:"render-test-signing-key", key:"signing.key"})
  ' "$test_dir/output.yaml" >/dev/null
  echo "$chart: required key, inline value, Secret reference, precedence and image passed"
done

# Ordinary preview commands must not inject the CI fixture or conceal missing values.
expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' \
  just helm-template-only charts/membership
just helm-template-only charts/membership "--set-file config.auth.signingKey.value=$test_dir/value.pem" "$test_dir/output.yaml"
yq -s -e --rawfile expected "$test_dir/value.pem" '
  [.[] | select(.kind == "Deployment") | .spec.template.spec.containers[]
   | select(.name == "membership") | .env[] | select(.name == "SIGNING_KEY")]
  | length == 1 and (.[0].value == $expected) and (.[0] | has("valueFrom") | not)
' "$test_dir/output.yaml" >/dev/null

# Given Membership is disabled, Then the mandatory key must not affect other services.
helm template signing-test charts/cloudprem --set global.platform.membership.enabled=false >"$test_dir/output.yaml"
yq -s -e '[.[] | select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.name == "membership")] | length == 0' "$test_dir/output.yaml" >/dev/null
helm template signing-test charts/formance >"$test_dir/output.yaml"
yq -s -e '[.[] | select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.name == "membership")] | length == 0' "$test_dir/output.yaml" >/dev/null
echo 'Ordinary previews, disabled Membership and Community Edition passed'
