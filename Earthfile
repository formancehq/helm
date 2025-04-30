VERSION --wildcard-builds --wildcard-copy 0.8

IMPORT github.com/formancehq/earthly:tags/v0.19.0 AS core


sources:
  ARG --required PATH
  FROM core+base-image
  WORKDIR /src
  WORKDIR /src/${PATH}
  COPY --dir ./${PATH} .
  SAVE ARTIFACT /src/${PATH}

# readmes
readme:
  BUILD ./charts/*+readme

# schema target to generate the schema files
template:
  FROM core+base-image
  WORKDIR /src
  COPY --pass-args (./tools/readme+template/*.md) ./
  SAVE ARTIFACT /src/*.md AS LOCAL ./

# validate target to run the helm lint
validate:
  LOCALLY
  LET dirs=$(ls -d ./charts/*/)
  FROM core+base-image
  WORKDIR /src
  FOR dir IN $dirs
    WORKDIR /src/$dir
    COPY --pass-args --dir ${dir}+validate/* .
  END
  SAVE ARTIFACT /src/charts

# tests target to run the helm tests
tests:
  BUILD ./test/*+tests

# package target to package the helm chart
package:
  FROM core+base-image
  COPY (./charts/*+package/*) /build/
  SAVE ARTIFACT /build AS LOCAL ./

# pre-commit target to run the pre-commit checks
pre-commit:
  WAIT
    BUILD --pass-args ./charts/*+validate
    # This target could depend on updated dependencies with the env variable NO_UPDATE
    # Can be done like `+validate`
    BUILD +package
  END
  BUILD +tests 
  BUILD +template --TEMPLATE_FILE=contributing.tpl --OUTPUT_FILE=CONTRIBUTING.md
  BUILD +template --TEMPLATE_FILE=readme.tpl --OUTPUT_FILE=README.md

# releaser target to upload the helm chart to the github release
releaser:
  FROM core+builder-image
  GIT CLONE --branch=v1.6.1 https://github.com/helm/chart-releaser /src/chart-releaser
  WORKDIR /src/chart-releaser
  DO core+GO_INSTALL --package ./...
  
# release target to upload the helm chart to the github release
release:
  FROM +releaser
  WORKDIR /src/chart-releaser
  COPY ./cr.yaml .
  COPY (+package/*) /build
  RUN --secret GITHUB_TOKEN cr upload \
      --config cr.yaml \
      --token ${GITHUB_TOKEN} \
      --skip-existing \
      --package-path /build

# publish the helm chart to the ghcr.io registry
publish:
  DO --pass-args +HELM_PUBLISH

# docs target to generate the markdown files for the charts
docs:
  DO +EARTHLY_DOCS

# EARTHLY_DOCS target to generate the markdown files for the charts
EARTHLY_DOCS:
  FUNCTION
  FROM core+base-image
  WORKDIR /src
  RUN apk add git
  RUN /bin/sh -c 'wget https://github.com/earthly/earthly/releases/latest/download/earthly-linux-amd64 -O /usr/local/bin/earthly && chmod +x /usr/local/bin/earthly'
  COPY . .
  ARG additionalArgs="--long"
  WITH DOCKER
    RUN mkdir -p docs && find . -name 'Earthfile' | while read -r file; do dir=$(dirname "$file"); clean_dir=$(echo "$dir" | sed "s|^\./docs||; s|^\./||; s|/$||;"); markdown_file="docs/$clean_dir/readme.md"; mkdir -p "$(dirname "$markdown_file")"; touch "$markdown_file"; earthly doc $additionalArgs "$dir" >> "$markdown_file"; done
  END
  SAVE ARTIFACT /src/docs AS LOCAL ./docs/earthly

# HELM_PUBLISH target to publish the helm chart to the ghcr.io registry
HELM_PUBLISH:
  FUNCTION
  FROM core+helm-base
  ARG --required path
  COPY $path /src/
  RUN --secret GITHUB_TOKEN echo $GITHUB_TOKEN | helm registry login ghcr.io -u NumaryBot --password-stdin
  RUN helm push /src/${path} oci://ghcr.io/formancehq/helm
  