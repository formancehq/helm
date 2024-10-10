# Helm Charts

## Validating the PR

```bash
earthly +pre-commit
```

## Working Per Chart

### Building the chart

Each chart  must implement the common targets interface with the minimum required files:
- Chart.yaml
- Earthfile
- values.yaml <--- It can be empty with {} as content

Each chart **must** implement the following targets:
- `+sources`: raw sources of the chart without the dependendies
- `+dependencies`: raw sources + dependencies updated
- `+validate`: validate the chart from the dependencies
- `+package`: package the chart from validated sources

> LICENCE is included in every chart throught the helper [SOURCE](./charts/Earthfile)

> README is generated with `helm-docs` and it is included in the chart throught the helper [README_GENERATOR](./charts/Earthfile)

### Core Dependencies

Each chart must implement the core helm library as a dependency to include the common helper:

- resources naming 
- values naming
- values structure
- kubernetes recommended labels
- (optional): aws, tgb, ingress, pdp, hpa

## CI: Github Actions

The CI is based on github actions and it is triggered on each PR and push to the main branch.

The CI is composed by the following workflows:

- Labeler:
  - It checks for changes in the `charts/` folder and labels the PR with the chart name
- Main: 
  - Validate the PR name
  - Check if readme has been regenerated
  - Validate & Package each chart labeled in the PR
- Release:
  - Use chart-releaser to release the charts where the PR has been merged on main. It will create a new tag with the version of the chart and release it to the helm repo.

## CD

External repository can relies on the `+package` target and artifact to be able to deploy from specific branch or tag.

```bash
earthly github.com/formancehq/helm/charts/cloudprem+package
```

<!-- Each chart are published to the [Artifact HUB](https://artifacthub.io/packages/search?repo=formancehq) and can be installed with helm:

```bash
helm repo add formancehq https://formancehq.github.io/helm
helm install formancehq/cloudprem
``` -->

