# demo

![Version: 2.1.1](https://img.shields.io/badge/Version-2.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: latest](https://img.shields.io/badge/AppVersion-latest-informational?style=flat-square)

Formance Private Regions Demo

**Homepage:** <https://formance.com>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Formance Team | <support@formance.com> |  |

## Source Code

* <https://github.com/formancehq/stack>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://nats-io.github.io/k8s/helm/charts/ | nats | 1.1.4 |
| oci://registry-1.docker.io/bitnamicharts | opensearch | 0.6.1 |
| oci://registry-1.docker.io/bitnamicharts | postgresql | 13.2.24 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nats.config.cluster.enabled | bool | `true` |  |
| nats.config.cluster.replicas | int | `3` |  |
| nats.config.jetstream.enabled | bool | `true` |  |
| nats.config.jetstream.fileStore.dir | string | `"/data"` |  |
| nats.config.jetstream.fileStore.enabled | bool | `true` |  |
| nats.config.jetstream.fileStore.pvc.enabled | bool | `false` |  |
| nats.config.jetstream.fileStore.pvc.size | string | `"20Gi"` |  |
| nats.enabled | bool | `false` |  |
| nats.fullnameOverride | string | `"nats"` |  |
| opensearch.coordinating.replicaCount | int | `0` |  |
| opensearch.dashboards.enabled | bool | `true` |  |
| opensearch.data.persistence.enabled | bool | `false` |  |
| opensearch.data.replicaCount | int | `2` |  |
| opensearch.enabled | bool | `false` |  |
| opensearch.fullnameOverride | string | `"opensearch"` |  |
| opensearch.ingest.enabled | bool | `false` |  |
| opensearch.ingest.replicaCount | int | `0` |  |
| opensearch.master.persistence.enabled | bool | `false` |  |
| opensearch.master.replicaCount | int | `1` |  |
| opensearch.security.enabled | bool | `false` |  |
| postgresql.architecture | string | `"standalone"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.fullnameOverride | string | `"postgresql"` |  |
| postgresql.global.postgresql.auth.database | string | `"formance"` |  |
| postgresql.global.postgresql.auth.password | string | `"formance"` |  |
| postgresql.global.postgresql.auth.postgresPassword | string | `"formance"` |  |
| postgresql.global.postgresql.auth.username | string | `"formance"` |  |
| postgresql.primary.persistence.enabled | bool | `false` |  |
