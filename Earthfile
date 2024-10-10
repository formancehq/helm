VERSION 0.8

IMPORT ./charts AS charts
IMPORT github.com/formancehq/earthly:tags/v0.16.2 AS core

sources:
  ARG --required PATH
  FROM core+base-image
  WORKDIR /src
  COPY --dir ./${PATH} .
  SAVE ARTIFACT /src

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
  FROM core+base-image
  FOR chart IN $(ls -d ./charts/*/)
    BUILD $chart+validate
  END

tests:
  BUILD ./test/helm+tests

package:
  FROM core+base-image
  FOR chart IN $(ls -d ./charts/*/)
    BUILD $chart+package
  END

ci:
  BUILD +pre-commit
  BUILD +tests
  BUILD +package

pre-commit:
  BUILD +validate
  BUILD +readme
