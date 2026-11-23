#!/usr/bin/env bash
set -euo pipefail

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
output="$test_dir/output.yaml"
enabled=--set=global.platform.membership.admin.enabled=true

assert_manifest() {
  yq -s -e "$@" "$output" >/dev/null
}

cat >"$test_dir/callers.yaml" <<'VALUES'
global:
  platform:
    membership:
      admin:
        allowedCallers:
          - namespace: ops
            podLabels:
              app.kubernetes.io/name: membership-automation
VALUES

read -r -d '' extra_env <<'JSON' || true
[
  {"name":"{{ print \"POSTGRES_MAX_OPEN_CONNS\" }}","value":"3"},
  {"name":"PUBLISHER_NATS_RECONNECT_WAIT","value":"2s"},
  {"name":"SERVICE_URL","value":"https://issuer.example.test/api"},
  {"name":"PUBLIC_ONLY","value":"true"}
]
JSON

custom_config='[{"name":"{{ print \"CONFIG\" }}","valueFrom":{"configMapKeyRef":{"name":"external-membership","key":"configPath"}}}]'
read -r -d '' validation <<'JSON' || true
{
  "staticClients":[{"id":"custom-ops","public":false,"internal":true,"secrets":["synthetic"],"redirectUris":["https://example.test"]}],
  "organizationSSOTrust":{"destination":["source@00000000-0000-4000-8000-000000000001"]},
  "signingKey":"synthetic",
  "connectors":[{"id":"ignored"}]
}
JSON

for chart in membership cloudprem formance; do
  edition=()
  identity=()
  case "$chart" in
    membership) prefix="" ;;
    cloudprem)
      prefix=membership.
      identity=(--set global.platform.identity.enabled=true --set identity.networkPolicy.enabled=true)
      ;;
    formance)
      prefix=cloudprem.membership.
      edition=(--set tags.EnterpriseEdition=true --set tags.CommunityEdition=false)
      identity=(--set global.platform.identity.enabled=true --set cloudprem.identity.networkPolicy.enabled=true)
      ;;
  esac

  render=(helm template admin-test "charts/$chart" --namespace control
    --values tests/values/signing-key.yaml "${edition[@]}" "${identity[@]}"
    --set global.serviceHost=example.test
    --set global.licence.existingSecret=render-test-licence --set global.licence.secretKeys.token=licence.token
    --set global.licence.clusterID=render-test-cluster
    --set global.nats.enabled=true --set global.nats.auth.existingSecret=render-test-nats
    --set "${prefix}feature.managedStacks=false" --set "${prefix}feature.disableEvents=false")
  public_key=(--set "${prefix}config.auth.signingPublicKey.existingSecret=render-test-public-key")
  tls_secret=(--set "${prefix}config.admin.tls.existingSecret=render-test-admin-tls")
  admin=("$enabled" "${public_key[@]}" "${tls_secret[@]}")

  "${render[@]}" >"$output"
  assert_manifest 'all(.[] | select(. != null); (.metadata.name // "" | endswith("-membership-admin") | not))'

  if "${render[@]}" "$enabled" "${public_key[@]}" >"$output" 2>"$test_dir/error.log"; then
    echo "$chart: enabling admin without a TLS Secret should fail" >&2
    exit 1
  fi
  grep -Fq 'config.admin.tls.existingSecret is required' "$test_dir/error.log"

  if "${render[@]}" "$enabled" "${tls_secret[@]}" >"$output" 2>"$test_dir/error.log"; then
    echo "$chart: enabling admin without a public key Secret should fail" >&2
    exit 1
  fi
  grep -Fq 'config.auth.signingPublicKey.existingSecret is required' "$test_dir/error.log"

  "${render[@]}" "${admin[@]}" >"$output"
  assert_manifest '
    [.[] | select(.kind == "NetworkPolicy" and .metadata.name == "admin-test-membership-admin")
      | .spec.ingress] == [[]]
  '

  # An explicit HTTP opt-out needs no TLS Secret and retains the private boundary.
  "${render[@]}" "$enabled" "${public_key[@]}" --set "${prefix}config.admin.tls.enabled=false" \
    --values "$test_dir/callers.yaml" >"$output"
  assert_manifest '
    "admin-test-membership-admin" as $name
    | ([.[] | select(.kind == "Deployment" and .metadata.name == $name)] | .[0]) as $deployment
    | ($deployment.spec.template.spec.containers[0]) as $container
    | ([.[] | select(.kind == "Deployment" and .metadata.name == "admin-test-membership")][0].spec.template.spec.containers[0]) as $public
    | ($container.args == ["serve-admin", "--bind-address=0.0.0.0:8080"])
      and (all($container.volumeMounts[]; .name != "tls"))
      and (all($deployment.spec.template.spec.volumes[]; .name != "tls"))
      and ($container.readinessProbe.httpGet == {port:"http", path:"/_healthcheck", scheme:"HTTP"})
      and (any($container.env[]; .name == "ADMIN_SERVICE_URL" and .value == "http://admin-test-membership-admin.control.svc:8080"))
      and ([$container.env[] | select(.name == "SERVICE_URL")] == [$public.env[] | select(.name == "SERVICE_URL")])
      and (any(.[]; .kind == "Service" and .metadata.name == $name and .spec.type == "ClusterIP" and .spec.ports[0].name == "http"))
      and (any(.[]; .kind == "NetworkPolicy" and .metadata.name == $name and (.spec.ingress | length) == 1))
  '

  "${render[@]}" "$enabled" "${public_key[@]}" \
    --set "${prefix}config.admin.tls.enabled=false" --set "${prefix}config.admin.networkPolicy.enabled=false" \
    --values "$test_dir/callers.yaml" >"$output"
  assert_manifest '
    "admin-test-membership-admin" as $name
    | (all(.[]; .kind != "NetworkPolicy" or .metadata.name != $name))
      and (any(.[]; .kind == "Service" and .metadata.name == $name and .spec.type == "ClusterIP"))
      and (any(.[]; .kind == "Deployment" and .metadata.name == $name
        and (any(.spec.template.spec.containers[0].env[]; .name == "SIGNING_PUBLIC_KEY"))))
  '

  # Exercise both the public ingress and AWS IP targets with admin enabled.
  "${render[@]}" "${admin[@]}" --set global.aws.elb=true \
    --set-json "${prefix}config.additionalEnv=$extra_env" \
    --values "$test_dir/callers.yaml" >"$output"
  assert_manifest '
    def named($kind; $name): .[] | select(.kind == $kind and .metadata.name == $name);
    def selects($labels):
      to_entries | all(.[]; . as $entry | $labels[$entry.key] == $entry.value);
    def envs: .env | map({key: .name, value: del(.name)}) | from_entries;

    "admin-test-membership" as $public
    | ($public + "-admin") as $admin
    | named("Deployment"; $public) as $publicDeployment
    | named("Deployment"; $admin) as $adminDeployment
    | $adminDeployment.spec.template.metadata.labels as $adminLabels
    | named("Service"; $public) as $publicService
    | named("Service"; $admin) as $adminService
    | ($adminDeployment.spec.template.spec.containers | .[0]) as $adminContainer
    | ($publicDeployment.spec.template.spec.containers[] | select(.name == "membership")) as $publicContainer
    | ($adminContainer | envs) as $adminEnv
    | ($publicContainer | envs) as $publicEnv
    | [$adminDeployment.spec.template.spec.volumes[].configMap.name // empty] == [$admin]
      and ([$adminDeployment.spec.template.spec.volumes[] | select(.name == "tls") | .secret]
        == [{secretName:"render-test-admin-tls", items:[{key:"tls.crt",path:"tls.crt"},{key:"tls.key",path:"tls.key"}]}])
      and ([$adminContainer.volumeMounts[] | select(.name == "tls")] == [{name:"tls",mountPath:"/tls",readOnly:true}])
      and ($adminDeployment.spec.selector.matchLabels | selects($adminLabels))
      and ($adminService.spec.type == "ClusterIP")
      and ($adminService.spec.selector | selects($adminLabels))
      and ($adminService.spec.selector | selects($publicDeployment.spec.template.metadata.labels) | not)
      and ($publicService.spec.selector | selects($adminLabels) | not)
      and ([.[] | select(.kind == "Service" and .metadata.namespace == "control" and .spec.selector)
            | select(.spec.selector | selects($adminLabels)) | .metadata.name] == [$admin])
      and ($adminService.spec.ports == [{name:"https", port:8080, targetPort:"http", protocol:"TCP"}])
      and ($adminContainer.ports == [{name:"http", containerPort:8080, protocol:"TCP"}])
      and ($adminContainer.livenessProbe == {tcpSocket:{port:"http"}})
      and ($adminContainer.readinessProbe.httpGet == {port:"http", path:"/_healthcheck", scheme:"HTTPS"})
      and ($adminContainer.image == $publicContainer.image)
      and ($adminContainer.args == ["serve-admin", "--bind-address=0.0.0.0:8080", "--tls-cert-file=/tls/tls.crt", "--tls-key-file=/tls/tls.key"])
      and ([$adminContainer.env[].name] | length == (unique | length))
      and ($adminEnv.SERVICE_URL == $publicEnv.SERVICE_URL and $adminEnv.SERVICE_URL.value == "https://issuer.example.test/api")
      and ($adminEnv.ADMIN_SERVICE_URL.value == "https://admin-test-membership-admin.control.svc:8080")
      and ($adminEnv.SIGNING_PUBLIC_KEY.valueFrom.secretKeyRef == {name:"render-test-public-key", key:"signing.pub"})
      and ($adminEnv.LICENCE_TOKEN.valueFrom.secretKeyRef == {name:"render-test-licence", key:"licence.token"})
      and ($adminEnv.LICENCE_TOKEN == $publicEnv.LICENCE_TOKEN)
      and ($adminEnv.LICENCE_CLUSTER_ID == $publicEnv.LICENCE_CLUSTER_ID)
      and ($adminEnv.LICENCE_ISSUER == $publicEnv.LICENCE_ISSUER)
      and ($adminEnv | has("SIGNING_KEY") or has("CRYPTO_KEY") or has("GRPC_TOKEN") | not)
      and ($adminEnv.POSTGRES_URI == $publicEnv.POSTGRES_URI)
      and ($adminEnv.POSTGRES_MAX_OPEN_CONNS == {value:"3"} and $adminEnv.POSTGRES_MAX_OPEN_CONNS == $publicEnv.POSTGRES_MAX_OPEN_CONNS)
      and ($adminEnv.PUBLISHER_NATS_ENABLED.value == "true")
      and ($adminEnv.PUBLISHER_NATS_PASSWORD == $publicEnv.PUBLISHER_NATS_PASSWORD)
      and ($adminEnv.PUBLISHER_NATS_RECONNECT_WAIT == {value:"2s"} and $adminEnv.PUBLISHER_NATS_RECONNECT_WAIT == $publicEnv.PUBLISHER_NATS_RECONNECT_WAIT)
      and ($adminEnv | has("PUBLIC_ONLY") | not)
      and (named("ConfigMap"; $admin).data["config.yaml"] | contains("id: fctl") and (test("secrets:|connectors:") | not))
      and ([.[] | select(.kind == "NetworkPolicy" and .metadata.namespace == "control")
            | select(.spec.podSelector.matchLabels // {} | selects($adminLabels)) | .metadata.name] == [$admin])
      and (named("NetworkPolicy"; $admin).spec
        | .policyTypes == ["Ingress"] and .ingress == [{
            ports:[{port:8080, protocol:"TCP"}],
            from:[{namespaceSelector:{matchLabels:{"kubernetes.io/metadata.name":"ops"}},
                   podSelector:{matchLabels:{"app.kubernetes.io/name":"membership-automation"}}}]
          }])
      and ([.[] | select(.kind == "Ingress") | .spec.rules[]?.http.paths[]?.backend.service.name
        ] | index($public) != null and index($admin) == null)
      and ([.[] | select(.kind == "TargetGroupBinding") | .spec.serviceRef.name
        ] | map(select(. == $public)) | length == 2)
      and (all(.[] | select(.kind == "TargetGroupBinding"); .spec.serviceRef.name != $admin))
      and (all(.[] | select(.kind == "HTTPRoute"); all(.spec.rules[]?.backendRefs[]?; .name != $admin)))
      and (all(.[] | select(.kind == "Job" or .kind == "CronJob"); .metadata.name != $admin))
  '

  if "${render[@]}" "${admin[@]}" --set-json "${prefix}config.additionalEnv=$custom_config" \
      >"$output" 2>"$test_dir/error.log"; then
    echo "$chart: overriding the public CONFIG without explicit admin validation must fail" >&2
    exit 1
  fi
  grep -Fq 'config.admin.validation must set staticClients' "$test_dir/error.log"

  "${render[@]}" "${admin[@]}" --set-json "${prefix}config.additionalEnv=$custom_config" \
    --set-json "${prefix}config.admin.validation=$validation" >"$output"
  assert_manifest '
    [.[] | select(.kind == "Deployment" and .metadata.name == "admin-test-membership-admin")
      | .spec.template.spec.containers[0].env[] | select(.name == "CONFIG")]
    == [{name:"CONFIG",value:"/config/config.yaml"}]
  '
  yq -sr '.[] | select(.kind == "ConfigMap" and .metadata.name == "admin-test-membership-admin") | .data["config.yaml"]' "$output" \
    | yq -e '. == {
        staticClients:[{id:"custom-ops",public:false,internal:true}],
        organizationSSOTrust:{"destination":["source@00000000-0000-4000-8000-000000000001"]}
      }' >/dev/null

  for target in aws.targetGroups.http dex.aws.targetGroups.dex-http; do
    if "${render[@]}" "${admin[@]}" --set global.aws.elb=true --set "${prefix}dex.enabled=true" \
        --set-string "${prefix}${target}.serviceRef.name=\"admin-test-membership-admin\"" \
        >"$output" 2>"$test_dir/error.log"; then
      echo "$chart: $target must not be able to target the admin Service" >&2
      exit 1
    fi
    grep -Fq 'AWS target groups cannot reference the Membership admin Service' "$test_dir/error.log"
  done

  if "${render[@]}" "${admin[@]}" \
      --set-json 'global.platform.membership.admin.allowedCallers=[{"namespace":"ops","podLabels":{}}]' \
      >"$output" 2>"$test_dir/error.log"; then
    echo "$chart: an empty pod selector would grant the whole namespace" >&2
    exit 1
  fi
  grep -Fq 'allowedCallers[].podLabels must be a non-empty map' "$test_dir/error.log"

  echo "$chart: Membership admin opt-in, selectors, callers, runtime config and external backends passed"
done
