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

helm-schema-install:
  helm plugin install https://github.com/losisin/helm-values-schema-json.git || true

helm-schema path='':
  helm schema -input {{path}}/values.yaml -output {{path}}/values.schema.json 
  
helm-docs-install:
  go install github.com/norwoodj/helm-docs/cmd/helm-docs@v1.14

helm-docs: helm-docs-install
  helm-docs --chart-search-root=charts --document-dependency-values --skip-version-footer

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
  helm dependency update {{path}} {{args}}

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