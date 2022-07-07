# Formance Helm charts

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
