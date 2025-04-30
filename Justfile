set dotenv-load
set positional-arguments

default:
  @just --list

pre-commit: tidy lint generate helm-update helm-validate
pc: pre-commit

lint:
  cd ./tools/readme && golangci-lint run --fix --timeout 5m
  cd ./test/helm && golangci-lint run --fix --timeout 5m

tidy:
  cd ./tools/readme && go mod tidy
  cd ./test/helm && go mod tidy

template: tidy
  go run ./tools/readme/main.go \
    --path ./README.md \
    --output ./README.md \
    --template ./tools/readme/template.md

tests args='':
  go test ./... -race

generate:
  go generate -run mockgen ./...

helm-update args='':
  for dir in $(ls -d helm/*); do \
    helm lint ./$dir --strict; \
    helm template ./$dir {{args}}; \
  done

helm-validate args='':
  for dir in $(ls -d helm/*); do \
    helm lint ./$dir --strict {{args}}; \
    helm template ./$dir {{args}}; \
  done

helm-package args='': helm-update
  for dir in $(ls -d helm/*); do \
    helm lint ./$dir --strict {{args}}; \
    helm template ./$dir {{args}}; \
  done

helm-publish args='': helm-package
  echo $GITHUB_TOKEN | docker login ghcr.io -u NumaryBot --password-stdin
  for dir in $(ls -d helm/*); do \
    helm lint ./$dir --strict {{args}}; \
    helm template ./$dir {{args}}; \
  done

install-releaser:
  git clone --branch=v1.7.0 github.com/helm/chart-releaser.git /tmp/chart-releaser
  cd /tmp/chart-releaser
  go install ./...

release: install-releaser
  cr upload \
    --config cr.yaml \
    --token ${GITHUB_TOKEN} \
    --skip-existing \
    --package-path /build