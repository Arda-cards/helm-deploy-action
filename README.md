# helm-deploy-action

[![ci](https://github.com/Arda-cards/helm-deploy-action/actions/workflows/ci.yaml/badge.svg?branch=main)](https://github.com/Arda-cards/helm-deploy-action/actions/workflows/ci.yaml?query=branch%3Amain)
[CHANGELOG.md](CHANGELOG.md)

Given a component, applies necessary infrastructure changes and deploys its chart.

## Assumptions

There is one component per deployable GitHub repository, which is packaged as one helm Chart. And optionally a `pre-deploy.cfn.yml` and a `post-deploy.cfn.yml` Cloud Formation templates to configure required AWS resources.
The component might have submodules, whose charts are aggregated into the main top-level chart.

During the continuous deployment pipeline, this action will need to deploy each purpose independently.

Each purpose will map to one or multiple `Environment`s, identifying particular `Infrastructure` and `Partition` combinations.

In order to support the case of purposes deploying to `Partition`s that share an `Infrastructure`, and therefore deploy their components into a single K8s cluster, a component is deployed to a namespace that identify both the component and the purpose.
The naming pattern will be `<purpose>-<component name>`.

This action expects configuration values for the chart for the *purpose* in `src/main/helm/values-${purpose}.yaml`.

This action supports a 2nd configuration values to be used. This is extending, not replacing, the default value files and is
intended for deployment pipeline tha need to extract values from their environment at deployment time.

## Arguments

See [action.yaml](action.yaml).

### A note on names

Helm deploys a *chart* to a *namespace* and names that a *release*, which is how helm tracks the deployments.

The name of the chart is the required parameter `chart_name`.

The name of the release is the required parameter `component_name`.

The name of the namespace is the concatenation of the `purpose` and the `component_name`.

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
          component_name: <insert your component name here>
          purpose: "prod"
```

## Permission Required

```yaml
    permissions:
      contents: read
      id-token: write
      packages: read
```
