VERSION --wildcard-builds --wildcard-copy 0.8

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
  COPY --pass-args (./tools/readme+template/*.md) /src/
  SAVE ARTIFACT /src/*.md AS LOCAL ./

validate:
  BUILD ./charts/*+validate

tests:
  BUILD ./test/helm+tests

package:
  FROM core+base-image
  COPY (./charts/*+package/*) /build/
  SAVE ARTIFACT /build AS LOCAL ./

pre-commit:
  BUILD --pass-args +validate
  BUILD +template --TEMPLATE_FILE=readme.tpl --OUTPUT_FILE=README.md
  BUILD +template --TEMPLATE_FILE=contributing.tpl --OUTPUT_FILE=CONTRIBUTING.md
  BUILD +tests # This target could depend on updated dependencies with the env variable NO_UPDATE
  BUILD +package

releaser:
  FROM core+builder-image
  GIT CLONE --branch=v1.6.1 https://github.com/helm/chart-releaser /src/chart-releaser
  WORKDIR /src/chart-releaser
  DO core+GO_INSTALL --package ./...
  COPY ./cr.yaml .
  
release:
  FROM +releaser
  WORKDIR /src/chart-releaser
  COPY (+package/*) /build
  RUN --secret GITHUB_TOKEN cr upload \
      --config cr.yaml \
      --token ${GITHUB_TOKEN} \
      --skip-existing \
      --package-path /build
      
publish:
  FROM core+base-image
  RUN apk add helm
  WORKDIR /src
  ARG path
  COPY $path /src
  DO --pass-args +HELM_PUBLISH --path=/src/$path

HELM_PUBLISH:
    FUNCTION
    ARG --required path
    WITH DOCKER
        RUN --secret GITHUB_TOKEN echo $GITHUB_TOKEN | docker login ghcr.io -u NumaryBot --password-stdin
    END
    WITH DOCKER
        RUN helm push ${path} oci://ghcr.io/formancehq/helm
    END