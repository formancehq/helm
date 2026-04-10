set dotenv-load
set positional-arguments

import '.just-lib/helm/recipes.just'
export HELM_DIR := "charts"

default:
  @just --list

pre-commit: helm-all template-readme
pc: pre-commit

lint:
  @cd ./tools/readme && golangci-lint run --fix --timeout 5m

tidy: lint
  @cd ./tools/readme && go mod tidy

template-readme: tidy
  #!/bin/bash
  pushd ./tools/readme
  go run ./ \
    --template-file readme.tpl > ../../README.md
  go run ./ \
    --template-file contributing.tpl > ../../CONTRIBUTING.md
  popd

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
