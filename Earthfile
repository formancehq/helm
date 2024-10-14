VERSION --wildcard-builds --wildcard-copy 0.8

IMPORT ./charts AS charts
IMPORT github.com/formancehq/earthly:tags/v0.16.3 AS core

sources:
  ARG --required PATH
  FROM core+base-image
  WORKDIR /src
  WORKDIR /src/${PATH}
  COPY --dir ./${PATH} .
  SAVE ARTIFACT /src/${PATH}

template:
  FROM core+base-image
  RUN apk add go
  RUN touch README.md
  COPY --dir charts /charts
  COPY (./tools/readme+sources/*) /src
  ARG TEMPLATE_FILE=README.tpl
  ARG OUTPUT_FILE=README.md
  WORKDIR /src
  RUN --mount=type=cache,id=gomod,target=${GOPATH}/pkg/mod \
      --mount=type=cache,id=gobuild,target=/root/.cache/go-build \ 
    go run ./ readme --chart-dir /charts --template-file $TEMPLATE_FILE >> ${OUTPUT_FILE}
  SAVE ARTIFACT $OUTPUT_FILE AS LOCAL $OUTPUT_FILE

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
  WAIT
    BUILD +pre-commit
    BUILD +tests
  END
  COPY (+package/*) /build
  SAVE ARTIFACT /build AS LOCAL ./

pre-commit:
  BUILD --pass-args +validate
  BUILD +template --TEMPLATE_FILE=readme.tpl --OUTPUT_FILE=README.md
  BUILD +template --TEMPLATE_FILE=contributing.tpl --OUTPUT_FILE=CONTRIBUTING.md

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
  
  
