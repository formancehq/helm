VERSION 0.8

IMPORT ./charts AS charts
IMPORT github.com/formancehq/earthly:tags/v0.16.2 AS core

license:
  FROM core+base-image
  WORKDIR /src
  COPY ./LICENSE .
  SAVE ARTIFACT LICENSE

formance-runner:
  FROM earthly/earthly:latest
  RUN apk add --no-cache bash
  ARG REPOSITORY=ghcr.io
  ARG tag=latest
  ENTRYPOINT /bin/bash
  DO core+SAVE_IMAGE --COMPONENT=formance-runner --REPOSITORY=${REPOSITORY} --TAG=$tag

readme:
  FROM core+builder-image
  COPY --dir charts /charts
  COPY (./tools/readme+sources/*) /src
  WORKDIR /src
  RUN touch README.md
  RUN go run ./ readme --chart-dir /charts  >> README.md
  SAVE ARTIFACT README.md AS LOCAL README.md

validate:
  LOCALLY
  FOR chart IN $(ls -d ./charts/*/)
    BUILD $chart+validate
  END

tests:
  BUILD ./test/helm+tests

package:
  LOCALLY
  FOR chart IN $(ls -d ./charts/*/)
    BUILD $chart+package
  END

pre-commit:
  BUILD +validate
  BUILD +readme
  BUILD +tests
