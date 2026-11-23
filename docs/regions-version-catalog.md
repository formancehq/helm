# Regions version catalog

The `regions` chart renders `versions.files` into `Versions` resources. The
`formance` chart includes the same catalog through its `regions` dependency.

## `regions` 3.27.0

- Profiles `v3.2` and `v4.0-beta` use [Gateway v2.5.0](https://github.com/formancehq/gateway/releases/tag/v2.5.0). This update includes audit changes and dependency security fixes.
- Profile `v3.2` uses [Auth v2.6.3](https://github.com/formancehq/auth/releases/tag/v2.6.3), which always enforces management API scopes. Check that management API clients request the scopes they need before upgrading.
- MCP is deprecated. The `v3.2` catalog no longer provides an MCP version. Remove any explicitly configured MCP module or `versions.files.v3.2.mcp` override before upgrading. The chart does not remove MCP resources managed outside this release.
- The `v3.2` catalog no longer provides a Transaction Plane version.
