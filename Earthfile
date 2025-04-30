VERSION --wildcard-builds --wildcard-copy 0.8

IMPORT github.com/formancehq/earthly:tags/v0.19.0 AS core


sources:
  ARG --required PATH
  FROM core+base-image
  WORKDIR /src
  WORKDIR /src/${PATH}
  COPY --dir ./${PATH} .
  SAVE ARTIFACT /src/${PATH}