# Formance Helm charts 

## How to use Helm charts

| Readme | Chart Version | App Version | Description | Hub |
|--------|---------------|-------------|-------------|-----|
{{- range (listCharts "../../charts") }}
| [{{ .Name | title }}](./charts/{{ .Name }}/README.md) | {{ .Version }} | {{ .AppVersion }} | {{ .Description }} | [![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/{{ .Name }})](https://artifacthub.io/packages/search?repo={{ .Name }}) |
{{- end }}

## How to contribute

Please refer to the [CONTRIBUTING.md](./CONTRIBUTING.md) file for information on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

