# Formance Helm charts 

## How to use Helm charts

Adding the Numary repository:
```
helm repo add numary https://numary.github.io/helm/
```

Installing the ledger:
```
helm install ledger numary/ledger
```

**The Formance Helm chart did not provides any dependencies. For developement purpose only, you can install PostgreSQL database using this command:**
```
helm repo add bitnami https://charts.bitnami.com/bitnami 
helm install postgres bitnami/postgresql --set global.postgresql.auth.username=ledger --set global.postgresql.auth.password=ledger --set global.postgresql.auth.database=ledger
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
