# Helm Charts

## Working Per Chart

### Building the Charts

Each chart must implement the common targets interface with the following minimum required files:

- `Chart.yaml`
- `Earthfile`

Each `Earthfile` Chart **must** implement the following targets to integrate with the CI:

- `+sources`: Raw sources of the chart without the dependencies.
> [!IMPORTANT]
> A LICENSE file is included in every chart through the helper [SOURCE](./charts/Earthfile)
- `+dependencies`: Raw sources with dependencies updated.
- `+validate`: Validates the chart, including its dependencies.
- `+package`: Packages the chart from validated sources.
- `+readme`: (Optional): Include README when dependendies are validated.
> The README file is generated with `helm-docs` and included in the chart through the helper [README_GENERATOR](./charts/Earthfile).

> [!TIP]
> A file named `README.md.gotmpl` can be added to the chart to customize the README generation.
- `+schema`: (Optional): Generate a values schema from the `values.yaml` and include it in the chart sources. Then it will be validated with the `+validate` target.


### Core Library

Each chart must implement the core Helm library as a dependency to include the common helpers for:

- Improve resource naming
- [Kubernetes recommended labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)
- Values naming

- Global values structure accross all charts, including settings
  - Monitoring
    - Traces(OTLP)
    - Metrics(OTLP)
    - Logs(JSON)
  - Storage
    - PostgreSQL (Bitnami) (Internal or External)
    - Nats (Nats.io) (Internal)
  
- (Optionals):
  
  - AWS IAM
  - AWS Target Groups
  - Ingress
  - PodDisruptionBudget
  - HorizontalPodAutoscaler
  - ServiceAccount
  - RBAC
  - NetworkPolicy

## Validate repository changes

To validate the all the changes arround the repository, run the following command:

```bash
earthly +pre-commit
```

{{- $operatorVersion := "" }}
{{- $operatorCrdVersion := "" }}
{{- range .Charts }}
{{- if eq .Name "operator" }}
{{- $operatorVersion = .Version }}
{{- end }}
{{- if eq .Name "operator-crds" }}
{{- $operatorCrdVersion = .Version }}
{{- end }}
{{- end }}

>[!TIP]
> On the operator chart,
> use `earthly +pre-commit --OPERATOR_VERSION={{ $operatorVersion }} OPERATOR_CRD_VERSION={{ $operatorCrdVersion }}`

1. First run
once running it for the first time, it will build all the dependencies and validate all the charts and the charts.

2. Second run
It will validate the future changes only where it needs to be validated thanks to caches.

## Tests core and charts

- Naming conventions for included resource
- Labels selection
- Default environment variables bindings
- Resources disablings
  - HorizontalPodAutoscaler
  - Ingress
  - PodDisruptionBudget
  - Subchart disabling
- Secret mapping
- Configmap mapping
- Managed Stacks Features: Disable GRPC communication with any type of Agent

## CI: GitHub Actions

The CI is based on GitHub Actions, triggered on each PR and the main branch. It is composed of the following workflows:

- **Pull Request**: PR
  - Validates the PR name.
  - Labels the PR with the charts who have changed in the `charts/` directory.
  - Lint, Template, Generate Readmes for any charts who has changed. And Test Requirements accross on all charts `earthly +ci`.
- **Release**: Main
    - Lint, Template, Generate Readmes for any charts who has changed. And Test Requirements accross on all charts `earthly +ci`.
  - Release any `Chart.yaml` `.version` that have been upgraded. 
    - `chart-releaser` is based on builded Artifact. - It creates a new tag with the chart version and releases on github it to the Helm repository.

## CD: from sources

External repositories can rely on the `+package` target and artifact to deploy from a specific branch or tag.

```bash
earthly github.com/formancehq/helm/charts/cloudprem+package
```

## CD: from Helm repository

The helm repository is `ghcr.io/formancehq/helm` and can be used to deploy the charts.

```bash
helm upgrade --install regions ghcr.io/formancehq/helm/regions --version v2.0.18
```
