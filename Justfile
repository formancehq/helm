set dotenv-load
set positional-arguments

default:
  @just --list

pre-commit: helm-all template-readme
pc: pre-commit

lint:
  @cd ./tools/readme && golangci-lint run --fix --timeout 5m

tidy: lint
  @cd ./tools/readme && go mod tidy

helm-schema-install:
  helm plugin install https://github.com/losisin/helm-values-schema-json.git --version v1.9.2 || true

helm-schema path='':
  helm schema -input {{path}}/values.yaml -output {{path}}/values.schema.json
  
helm-docs:
  go run github.com/norwoodj/helm-docs/cmd/helm-docs@v1.14 --chart-search-root=charts --document-dependency-values --skip-version-footer

helm-all package="false" publish='false' packageArgs="": helm-docs helm-schema-install
  #!/bin/bash
  set -euo pipefail

  charts=$(find ./charts -name Chart.yaml | xargs -n1 dirname)

  # Phase 1: Update dependencies sequentially to avoid race conditions on shared subcharts
  for chart in $charts; do
    just helm-schema "$chart"
    just helm-update "$chart"
  done

  # Phase 2: Lint, template, and package in parallel (dependencies are already resolved)
  for chart in $charts; do
    (
      if [ "{{package}}" = "true" ]; then
        just helm-package-only "$chart" {{packageArgs}}
      else
        just helm-template-only "$chart"
      fi
    ) &
  done
  wait
  if [ "{{publish}}" = "true" ]; then
    for chart in $(find ./build -name "*.tgz"); do
      (
        just helm-publish "$chart"
      ) 
    done
  fi

template-readme: tidy
  #!/bin/bash
  pushd ./tools/readme
  go run ./ \
    --template-file readme.tpl > ../../README.md
  go run ./ \
    --template-file contributing.tpl > ../../CONTRIBUTING.md
  popd

helm-update path='' args='': helm-login
  #!/bin/bash
  set -e

  update_chart() {
    local chart_dir="$1"

    echo "🔍 Checking $chart_dir"

    if [[ ! -f "$chart_dir/Chart.yaml" ]]; then
      echo "❌ No Chart.yaml in $chart_dir"
      return
    fi

    local deps
    deps=$(helm dependency list "$chart_dir" 2>/dev/null | grep 'file://' | awk '{print $1, $2, $3}' || true)

    while read -r name version repo; do
      if [[ "$repo" == file://* ]]; then
        local subchart_path
        subchart_path=$(echo "$repo" | sed 's|file://||')
        local full_path="$chart_dir/$subchart_path"
        update_chart "$full_path"
      fi
    done <<< "$deps"

    echo "🔗 helm dependency update $chart_dir {{args}}"
    helm dependency update "$chart_dir" {{args}} > /dev/null
  }

  update_chart {{path}}

helm-lint path='' args="":
  #!/bin/bash
  set -euo pipefail
  just helm-update {{path}}
  echo "📝 Linting chart {{path}}"
  helm lint {{path}} --strict

helm-template path='' args='' output='/dev/null':
  #!/bin/bash
  set -euo pipefail
  just helm-lint {{path}}

  isLibrary=$(yq -r '.type' {{path}}/Chart.yaml)
  echo "Chart type: $isLibrary"
  if [ "$isLibrary" = "library" ]; then
    echo "❌ Skipping template for library chart"
  else
    echo "✨ Rendering chart {{path}} on {{output}}"
    helm template {{path}} {{args}} > {{output}}
  fi

helm-template-only path='' args='' output='/dev/null':
  #!/bin/bash
  set -euo pipefail
  echo "📝 Linting chart {{path}}"
  helm lint {{path}} --strict

  isLibrary=$(yq -r '.type' {{path}}/Chart.yaml)
  echo "Chart type: $isLibrary"
  if [ "$isLibrary" = "library" ]; then
    echo "❌ Skipping template for library chart"
  else
    echo "✨ Rendering chart {{path}} on {{output}}"
    helm template {{path}} {{args}} > {{output}}
  fi

helm-package path='' args='':
  just helm-template {{path}}
  helm package {{path}} --destination ./build {{args}}

helm-package-only path='' args='':
  #!/bin/bash
  set -euo pipefail
  echo "📝 Linting chart {{path}}"
  helm lint {{path}} --strict

  isLibrary=$(yq -r '.type' {{path}}/Chart.yaml)
  echo "Chart type: $isLibrary"
  if [ "$isLibrary" = "library" ]; then
    echo "❌ Skipping template for library chart"
  else
    echo "✨ Rendering chart {{path}}"
    helm template {{path}} > /dev/null
  fi
  helm package {{path}} --destination ./build {{args}}

helm-publish path='': helm-login
  helm push {{path}} oci://ghcr.io/formancehq/helm

helm-login:
  echo $GITHUB_TOKEN | helm registry login ghcr.io -u NumaryBot --password-stdin || true

release:
  #!/bin/bash
  set -euo pipefail
  just helm-all "true"

  rm -rf /tmp/chart-releaser
  git clone --branch=v1.7.0 https://github.com/helm/chart-releaser.git /tmp/chart-releaser
  pushd /tmp/chart-releaser
  go build -o cr ./... 
  popd

  /tmp/chart-releaser/cr/cr upload \
    --config {{justfile_directory()}}/cr.yaml \
    --token ${GITHUB_TOKEN} \
    --skip-existing \
    --package-path {{justfile_directory()}}/build