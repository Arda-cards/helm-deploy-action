# changelog

[![Keep a Changelog](https://img.shields.io/badge/Keep%20a%20Changelog-1.0.0-informational)](https://keepachangelog.com/en/1.0.0/)
[![Semantic Versioning](https://img.shields.io/badge/Semantic%20Versioning-2.0.0-informational)](https://semver.org/spec/v2.0.0.html)
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

## [5.0.0] - 2025-08-20

### Changed

- Runs with pre-installed version of jq, aws-cli and helm; this is not a Docker image anymore

### Added

- Display the version of aws, helm, jq, kubectl

### Removed

- Helm values `global.clusterIam` and `global.environment`.

### Fixed

- Bump actions/checkout from 4 to 5

## [4.0.0] - 2025-07-10

### Changed

- Helm's [Naming Conventions](https://helm.sh/docs/chart_best_practices/values/#naming-conventions): «Variable names should begin with a lowercase letter, and words should be separated with camelcase.»
- Renamed *phase* to *purpose*.
- Renamed *module* to *component*.

### Added

- New global value *environment*, which is pass through for the action's input of the same name.

### Fixed

- Rely on branch protection rule, not branch name.
- Skip all work on draft pull requests.
- Bump super-linter from 7 to 8

## [3.0.0] - 2025-04-17

### Changed

- Stop creating the namespace and manually copying the image pull secret to it; it is now the responsibility of the ExternalSecret
  to handle this.

### Removed

- Remove the `-xv` before the call to helm. There is a single toggle of the shell trace and verbose mode, controlled by the action's verbose parameter.

### Added

- New optional parameter `value_file`; use it to add a value file to the helm deployment command.

## [2.1.0] - 2025-03-31

### Added

- New optional parameter `namespace`; it defaults to *phase*`-`*module_name*.

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
