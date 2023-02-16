# Formance Helm charts

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/formance-ledger)](https://artifacthub.io/packages/search?repo=formance-ledger)
## How to use Helm charts

Adding the Formance repository:
```
helm repo add formance https://helm.formance.com/
```

Installing the ledger:
```
helm install ledger formance/ledger
```

## For developement purposes only!

**The Formance Helm chart does not provide any dependencies. You can install the PostgreSQL database using this command:**
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install postgres bitnami/postgresql --set global.postgresql.auth.username=ledger --set global.postgresql.auth.password=ledger --set global.postgresql.auth.database=ledger
```

**Due to bitnami's docker image only supporting AMD processors, a few helm values need to be updated to install PostgreSQL for ARM processors:**
```
helm install postgres bitnami/postgresql --set global.postgresql.auth.username=ledger --set global.postgresql.auth.password=ledger --set global.postgresql.auth.database=ledger --set image.repository=postgres --set image.tag=15-alpine --set nameOverride=postgres
```

## Installation
helm-docs can be installed using homebrew:
```
brew install norwoodj/tap/helm-docs
```

## Usage
### Pre-commit hook
If you want to automatically generate README.md files with a pre-commit hook, make sure you install the pre-commit binary, and add a .pre-commit-config.yaml file to your project. Then run:
```
pre-commit install
pre-commit install-hooks
```
Future changes to your chart's `requirements.yaml`, `values.yaml`, `Chart.yaml`, or `README.md.gotmpl` files will cause an update to documentation when you commit.
