# changelog

[![Keep a Changelog](https://img.shields.io/badge/Keep%20a%20Changelog-1.0.0-informational)](https://keepachangelog.com/en/1.0.0/)
[![Semantic Versioning](https://img.shields.io/badge/Sematic%20Versioning-2.0.0-informational)](https://semver.org/spec/v2.0.0.html)
![clq validated](https://img.shields.io/badge/clq-validated-success)

Keep the newest entry at top, format date according to ISO 8601: `YYYY-MM-DD`.

Categories, defined in [changemap.json](.github/clq/changemap.json):

- *major* release trigger:
  - `Changed` for changes in existing functionality.
  - `Removed` for now removed features.
- *minor* release trigger:
  - `Added` for new features.
  - `Deprecated` for soon-to-be removed features.
- *bugfix* release trigger:
  - `Fixed` for any bugfixes.
  - `Security` in case of vulnerabilities.

## [2.0.0] - 2025-03-17

### Changed

- CLUSTER_IAM does not end with trailing `:`
- The secret to access the GitHub OCI registry is now named `ghcr-secret`.

### Added

- Run in verbose/debug mode when the workflow runs in debug mode; this mode propagates to helm execution.
- Logs the aws caller identity in verbose mode

### Fixed

- The `clean-up` option should leave what was installed; it now triggers `--wait` instead of `--atomic`

## [1.1.0] - 2025-01-17

### Added

- Pass `global.AWS_REGION` to helm

## [1.0.0] - 2025-01-17

### Added

- Deploy from GitHub package to AWS EKS with Helm
