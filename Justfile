set dotenv-load
set positional-arguments

default:
  @just --list

pre-commit: helm-all template-readme
pc: pre-commit

lint:
  cd ./tools/readme && golangci-lint run --fix --timeout 5m
  cd ./test/helm && golangci-lint run --fix --timeout 5m

tidy: lint
  cd ./tools/readme && go mod tidy
  cd ./test/helm && go mod tidy

helm-schema-install:
  helm plugin install https://github.com/losisin/helm-values-schema-json.git || true

helm-schema path='':
  helm schema -input {{path}}/values.yaml -output {{path}}/values.schema.json 
  
helm-docs:
  go run github.com/norwoodj/helm-docs/cmd/helm-docs@v1.14 --chart-search-root=charts --document-dependency-values --skip-version-footer

helm-all package="false": helm-docs helm-schema-install
  #!/bin/bash
  for chart in $(find ./charts -name Chart.yaml | xargs -n1 dirname); do
    echo "---------- $chart ----------"
    just helm-schema $chart
    if [ "$package" = "true" ]; then
      just helm-package $chart
    else
      just helm-template $chart
    fi
  done

template-readme: tidy
  #!/bin/bash
  pushd ./tools/readme
  go run ./ \
    --template-file readme.tpl > ../../README.md
  go run ./ \
    --template-file contributing.tpl > ../../CONTRIBUTING.md
  popd

tests args='': tidy
  #!/bin/bash
  pushd ./test/helm
  go test ./... -race

helm-update path='' args='': helm-login
  #!/bin/bash
  set -e

    update_chart() {
    local chart_dir="$1"

    echo "🔍 Checking $chart_dir"

    # Vérifie si le dossier est une chart Helm
    if [[ ! -f "$chart_dir/Chart.yaml" ]]; then
      echo "❌ Pas de Chart.yaml dans $chart_dir, ignoré"
      return
    fi

    # Liste les dépendances locales
    local deps
    deps=$(helm dependency list "$chart_dir" 2>/dev/null | grep 'file://' | awk '{print $1, $2, $3}' || true)

    # Recurse d'abord dans les dépendances locales
    while read -r name version repo; do
      if [[ "$repo" == file://* ]]; then
        local subchart_path
        subchart_path=$(echo "$repo" | sed 's|file://||')
        local full_path="$chart_dir/$subchart_path"
        update_chart "$full_path"
      fi
    done <<< "$deps"

    # Puis update les dépendances de cette chart
    echo "🔁 helm dependency update $chart_dir {{args}}"
    helm dependency update "$chart_dir" {{args}}
  }

  update_chart {{path}}

helm-lint path='' args="":
  just helm-update {{path}}
  helm lint {{path}} --strict; \

helm-template path='' args='':
  #!/bin/bash
  just helm-lint {{path}}
  isLibrary=$(yq -r '.type' {{path}}/Chart.yaml)
  if [ "$isLibrary" = "library" ]; then
    echo "Skipping template for library chart"
  else
    echo "Rendering chart $path"
    helm template {{path}} {{args}}
  fi

helm-package path='' args='':
  just helm-template {{path}}
  helm package {{path}} --destination ./build {{args}}

helm-publish path='': helm-login
  helm push {{path}} oci://ghcr.io/formancehq/helm

helm-login:
  echo $GITHUB_TOKEN | helm registry login ghcr.io -u NumaryBot --password-stdin

install-releaser:
  #!/bin/bash
  rm -rf /tmp/chart-releaser
  git clone --branch=v1.7.0 git@github.com:helm/chart-releaser.git /tmp/chart-releaser
  pushd /tmp/chart-releaser
  go install ./...
  popd

release: install-releaser 
  just helm-all "true"
  cr upload \
    --config cr.yaml \
    --token ${GITHUB_TOKEN} \
    --skip-existing \
    --package-path /build