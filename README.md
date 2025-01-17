# helm-deploy-action

The deployment process for a module.

## Assumptions

There is one module per deployable GitHub repository, which is packaged as one helm Chart.
The module might have submodules, whose charts are aggregated into the main top-level chart.

During the continuous deployment pipeline, this action will need to deploy each phase independently.

The phases can map to one or many aws accounts and clusters.

In order to support the case of all phases into a single cluster, a module is deployed to a namespace that identify both the module and the phase.
The naming pattern will be `<phase>-<module name>`.

This action expects configuration values for the chart for the *phase* in `src/main/helm/values-${phase}.yaml`

## Arguments

See [action.yaml](action.yaml).

### A note on names

Helm deploys a *chart* to a *namespace* and names that a *release*, which is how helm tracks the deployments.

The name of the chart is the required parameter `chart_name`.

The name of the release is the required parameter `module_name`.

The name of the namespace is the concatenation of the `phase` and the `module_name`.

## Usage

```yaml
jobs:
  deploy-prod:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
      packages: read
    environment: "prod"
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: ${{ vars.AWS_REGION }}
          role-to-assume: ${{ vars.AWS_ROLE }}
          role-duration-seconds: 900
      - uses: arda-cards/helm-deploy-action@v1
        with:
          aws_region: ${{ vars.AWS_REGION }}
          chart_name: ${{ needs.build.outputs.chart_name }}
          chart_version: ${{ needs.build.outputs.chart_version }}
          cluster_name: ${{ vars.AWS_CLUSTER_NAME }}
          github_token: ${{ github.token }}
          helm_registry: ${{ vars.HELM_REGISTRY }}
          module_name: <insert your module name here>
          phase: "prod"
```

## Permission Required

```yaml
    permissions:
      contents: read
      id-token: write
      packages: read
```
