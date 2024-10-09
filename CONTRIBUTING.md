# Day to day

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


### Core Dependencies

Each chart must implement the core helm library as a dependency to include the common helper:
- resources naming
- values naming
- values structure
- kubernetes recommended labels
- (optional): aws, tgb, ingress, pdp, hpa


# CI

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

# CD

Some external repository relies on the `+package` target to be able to deploy the chart on the dev environment.

- Membership, Stargate, Report: https://github.com/formancehq/membership-api
- Platform-UI: https://github.com/formancehq/platform-ui
  - Portal
- Console: https://github.com/formancehq/console