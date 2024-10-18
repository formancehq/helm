# Formance Helm charts 

## How to use Helm charts

| Readme | Chart Version | App Version | Description | Hub |
|--------|---------------|-------------|-------------|-----|
| [Agent](./charts/agent/README.md) | v2.1.0 |v2.0.18 | Formance Membership Agent Helm Chart | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/agent)](https://artifacthub.io/packages/search?repo=agent) |
| [Cloudprem](./charts/cloudprem/README.md) | v2.0.0-beta.23 |v0.35.3 | Formance control-plane | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/cloudprem)](https://artifacthub.io/packages/search?repo=cloudprem) |
| [Console](./charts/console/README.md) | v1.0.0-beta.8 |9431e5f4b4b1a03cb8f02ef1676507b9c023f2bb | Formance Console | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/console)](https://artifacthub.io/packages/search?repo=console) |
| [Core](./charts/core/README.md) | v1.0.0-beta.6 |latest | Formance Core Library | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/core)](https://artifacthub.io/packages/search?repo=core) |
| [Demo](./charts/demo/README.md) | 2.0.0 |latest | Formance Private Regions Demo | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/demo)](https://artifacthub.io/packages/search?repo=demo) |
| [Membership](./charts/membership/README.md) | v1.0.0-beta.13 |v0.35.3 | Formance Membership API. Manage stacks, organizations, regions, invitations, users, roles, and permissions. | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/membership)](https://artifacthub.io/packages/search?repo=membership) |
| [Portal](./charts/portal/README.md) | v1.0.0-beta.7 |764bb7e199e1d2882e4d5cd205eada0ef0abc283 | Formance Portal | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/portal)](https://artifacthub.io/packages/search?repo=portal) |
| [Regions](./charts/regions/README.md) | v2.1.1 |latest | Formance Private Regions Helm Chart | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/regions)](https://artifacthub.io/packages/search?repo=regions) |
| [Stargate](./charts/stargate/README.md) | 0.5.2 |latest | Formance Stargate gRPC Gateway | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/stargate)](https://artifacthub.io/packages/search?repo=stargate) |

## Test


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


## How to contribute

Please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) file for information on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

