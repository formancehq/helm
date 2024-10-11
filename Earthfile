VERSION --wildcard-builds --wildcard-copy 0.8

IMPORT ./charts AS charts
IMPORT github.com/formancehq/earthly:tags/v0.16.2 AS core

sources:
  ARG --required PATH
  FROM core+base-image
  WORKDIR /src
  WORKDIR /src/${PATH}
  COPY --dir ./${PATH} .
  SAVE ARTIFACT /src/${PATH}

readme:
  FROM core+base-image
  RUN apk add go
  RUN touch README.md
  COPY --dir charts /charts
  COPY (./tools/readme+sources/*) /src
  WORKDIR /src
  RUN --mount=type=cache,id=gomod,target=${GOPATH}/pkg/mod \
      --mount=type=cache,id=gobuild,target=/root/.cache/go-build \ 
    go run ./ readme --chart-dir /charts  >> README.md
  SAVE ARTIFACT README.md AS LOCAL README.md

validate:
  BUILD ./charts/*+validate

tests:
  BUILD ./test/helm+tests

package:
  FROM core+base-image
  COPY (./charts/*+package/*) /build/
  SAVE ARTIFACT /build AS LOCAL ./

ci:  
  FROM core+base-image
  BUILD +pre-commit
  BUILD +tests
  COPY (+package/*) /build
  SAVE ARTIFACT /build

pre-commit:
  BUILD +validate
  BUILD +readme

release:
  FROM core+builder-image
  GIT CLONE --branch=v1.6.1 https://github.com/helm/chart-releaser /src/chart-releaser
  WORKDIR /src/chart-releaser
  DO core+GO_INSTALL --package ./...
  COPY ./cr.yaml .
  COPY (+ci/*) /build
  RUN --secret GITHUB_TOKEN cr upload \
      --config cr.yaml \
      --git-repo helm \
      --token ${GITHUB_TOKEN} \
      --skip-existing \
      --package-path /build
  
  
