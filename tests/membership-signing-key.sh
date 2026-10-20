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

assert_inline_env() {
  local kind=$1 container=$2 env_name=$3 expected_file=$4
  yq -s -e --arg kind "$kind" --arg container "$container" --arg env_name "$env_name" \
    --rawfile expected "$expected_file" '
      [.[] | select(.kind == $kind) | .spec.template.spec.containers[]
       | select(.name == $container) | .env[] | select(.name == $env_name)]
      | length == 1 and (.[0].value == $expected) and (.[0] | has("valueFrom") | not)
    ' "$test_dir/output.yaml" >/dev/null
}

assert_secret_env() {
  local kind=$1 container=$2 env_name=$3 secret_name=$4 secret_key=$5
  yq -s -e --arg kind "$kind" --arg container "$container" --arg env_name "$env_name" \
    --arg secret_name "$secret_name" --arg secret_key "$secret_key" '
      [.[] | select(.kind == $kind) | .spec.template.spec.containers[]
       | select(.name == $container) | .env[] | select(.name == $env_name)]
      | length == 1
        and (.[0].valueFrom.secretKeyRef == {name:$secret_name, key:$secret_key})
        and (.[0] | has("value") | not)
    ' "$test_dir/output.yaml" >/dev/null
}

# Synthetic multiline text checks serialization, not key validity.
printf 'render-only-signing\nmultiline-value\n' >"$test_dir/signing.pem"
printf 'render-only-crypto\nmultiline-value\n' >"$test_dir/crypto.key"

for chart in membership cloudprem formance; do
  case "$chart" in
    membership)
      signing_prefix=config.auth.signingKey
      crypto_prefix=config.auth.cryptoKey
      edition=()
      ;;
    cloudprem)
      signing_prefix=membership.config.auth.signingKey
      crypto_prefix=membership.config.auth.cryptoKey
      edition=()
      ;;
    formance)
      signing_prefix=cloudprem.membership.config.auth.signingKey
      crypto_prefix=cloudprem.membership.config.auth.cryptoKey
      edition=(--set tags.EnterpriseEdition=true --set global.licence.existingSecret=render-test-licence --set global.licence.clusterID=render-test-cluster)
      ;;
  esac
  render=(helm template signing-test "charts/$chart" "${edition[@]}")
  signing_secret=(--set "$signing_prefix.existingSecret=render-test-signing-key")
  crypto_secret=(--set "$crypto_prefix.existingSecret=render-test-crypto-key")

  # Given no signing key configuration, When rendering, Then fail with recovery guidance.
  expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' \
    "${render[@]}" "${crypto_secret[@]}"
  expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' \
    "${render[@]}" "${crypto_secret[@]}" --set "$signing_prefix=null"
  expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' \
    "${render[@]}" "${crypto_secret[@]}" --set-string "$signing_prefix.value= "

  # Given no crypto key configuration, Then reject missing, blank and legacy default values.
  expect_failure 'config.auth.cryptoKey.value or config.auth.cryptoKey.existingSecret is required' \
    "${render[@]}" "${signing_secret[@]}"
  expect_failure 'config.auth.cryptoKey.value or config.auth.cryptoKey.existingSecret is required' \
    "${render[@]}" "${signing_secret[@]}" --set "$crypto_prefix=null"
  expect_failure 'config.auth.cryptoKey.value or config.auth.cryptoKey.existingSecret is required' \
    "${render[@]}" "${signing_secret[@]}" --set-string "$crypto_prefix.value= "
  expect_failure 'config.auth.cryptoKey.value must not use the insecure default value "default"' \
    "${render[@]}" "${signing_secret[@]}" --set-string "$crypto_prefix.value=default"

  # Given independent inline values, Then preserve both and emit each variable once.
  "${render[@]}" --set-file "$signing_prefix.value=$test_dir/signing.pem" \
    --set-file "$crypto_prefix.value=$test_dir/crypto.key" >"$test_dir/output.yaml"
  assert_inline_env Deployment membership SIGNING_KEY "$test_dir/signing.pem"
  assert_inline_env Deployment membership CRYPTO_KEY "$test_dir/crypto.key"

  # Given signing Secret and inline values, Then the signing Secret takes precedence.
  "${render[@]}" "${crypto_secret[@]}" --set "$signing_prefix.existingSecret=render-test-signing-key" \
    --set "$signing_prefix.key=rsa.pem" --set-file "$signing_prefix.value=$test_dir/signing.pem" >"$test_dir/output.yaml"
  assert_secret_env Deployment membership SIGNING_KEY render-test-signing-key rsa.pem
  expect_failure 'config.auth.signingKey.key is required' "${render[@]}" \
    "${crypto_secret[@]}" --set "$signing_prefix.existingSecret=render-test-signing-key" --set "$signing_prefix.key="
  expect_failure 'config.auth.signingKey.existingSecret must not be blank' "${render[@]}" \
    "${crypto_secret[@]}" --set-string "$signing_prefix.existingSecret= "

  # Given a crypto Secret and inline value, Then the Secret takes precedence.
  "${render[@]}" "${signing_secret[@]}" --set "$crypto_prefix.existingSecret=render-test-crypto-key" \
    --set "$crypto_prefix.key=cookie.key" --set-file "$crypto_prefix.value=$test_dir/crypto.key" >"$test_dir/output.yaml"
  assert_secret_env Deployment membership CRYPTO_KEY render-test-crypto-key cookie.key
  yq -s -e '
    [.[] | select(.kind == "Deployment") | .spec.template.spec.containers[]
     | select(.name == "membership") | .image] == ["ghcr.io/formancehq/membership:v2.8.0"]
  ' "$test_dir/output.yaml" >/dev/null

  expect_failure 'config.auth.cryptoKey.key is required' "${render[@]}" \
    "${signing_secret[@]}" --set "$crypto_prefix.existingSecret=render-test-crypto-key" --set "$crypto_prefix.key="
  expect_failure 'config.auth.cryptoKey.existingSecret must not be blank' "${render[@]}" \
    "${signing_secret[@]}" --set-string "$crypto_prefix.existingSecret= "

  # Given only Secret names, Then use the documented default keys.
  "${render[@]}" "${signing_secret[@]}" "${crypto_secret[@]}" >"$test_dir/output.yaml"
  assert_secret_env Deployment membership SIGNING_KEY render-test-signing-key signing.key
  assert_secret_env Deployment membership CRYPTO_KEY render-test-crypto-key crypto.key
  assert_secret_env Job wizard CRYPTO_KEY render-test-crypto-key crypto.key
  yq -s -e '
    [.[] | select(.kind == "Secret")
     | select(((.data // {}) | has("crypto.key")) or ((.stringData // {}) | has("crypto.key")))]
    | length == 0
  ' "$test_dir/output.yaml" >/dev/null
  echo "$chart: required auth keys, independence, inline values, Secret precedence and image passed"
done

# Ordinary preview commands must not inject the CI fixture or conceal missing values.
expect_failure 'config.auth.signingKey.value or config.auth.signingKey.existingSecret is required' \
  just helm-template-only charts/membership
expect_failure 'config.auth.cryptoKey.value or config.auth.cryptoKey.existingSecret is required' \
  just helm-template-only charts/membership "--set config.auth.signingKey.existingSecret=render-test-signing-key"
just helm-template-only charts/membership \
  "--set-file config.auth.signingKey.value=$test_dir/signing.pem --set-file config.auth.cryptoKey.value=$test_dir/crypto.key" \
  "$test_dir/output.yaml"
assert_inline_env Deployment membership SIGNING_KEY "$test_dir/signing.pem"
assert_inline_env Deployment membership CRYPTO_KEY "$test_dir/crypto.key"

# Given Membership is disabled, Then the mandatory key must not affect other services.
helm template signing-test charts/cloudprem --set global.platform.membership.enabled=false >"$test_dir/output.yaml"
yq -s -e '[.[] | select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.name == "membership")] | length == 0' "$test_dir/output.yaml" >/dev/null
helm template signing-test charts/formance >"$test_dir/output.yaml"
yq -s -e '[.[] | select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.name == "membership")] | length == 0' "$test_dir/output.yaml" >/dev/null
helm template signing-test charts/formance \
  --set tags.EnterpriseEdition=true \
  --set global.licence.existingSecret=render-test-licence \
  --set global.licence.clusterID=render-test-cluster \
  --set global.platform.membership.enabled=false >"$test_dir/output.yaml"
yq -s -e '[.[] | select(.kind == "Deployment") | .spec.template.spec.containers[] | select(.name == "membership")] | length == 0' "$test_dir/output.yaml" >/dev/null
echo 'Ordinary previews, disabled Membership and Community Edition passed'

# Shipped profiles must remain renderable after both auth keys become mandatory.
helm template signing-test charts/cloudprem \
  -f charts/cloudprem/profiles/1-minimal.yaml >"$test_dir/output.yaml"
assert_secret_env Deployment membership CRYPTO_KEY membership-crypto-key crypto.key
helm template signing-test charts/cloudprem \
  -f charts/cloudprem/profiles/1-minimal.yaml \
  -f charts/cloudprem/profiles/2-map-all-secrets.yaml >"$test_dir/output.yaml"
assert_secret_env Deployment membership CRYPTO_KEY membership crypto.key
helm template signing-test charts/formance \
  -f charts/formance/profiles/ee-minimal.yaml \
  -f charts/formance/profiles/ee-demo.yaml \
  --set tags.EnterpriseEdition=true \
  --set global.licence.existingSecret=render-test-licence \
  --set global.licence.clusterID=render-test-cluster >"$test_dir/output.yaml"
assert_secret_env Deployment membership CRYPTO_KEY membership-crypto-key crypto.key
echo 'Cloudprem and Formance profiles passed'
