#!/usr/bin/env bash

set -eu

for i in "$@"; do
  case $i in
  AWS_REGION=*)
    readonly aws_region="${i#*=}"
    ;;
  CHART_NAME=*)
    readonly chart_name="${i#*=}"
    ;;
  CHART_VERSION=*)
    readonly chart_version="${i#*=}"
    ;;
  # if CLEAN_UP is true, create the variable, otherwise recognize that it exists but without creating the variable
  CLEAN_UP=true)
    readonly clean_up=true
    ;;
  CLEAN_UP=*) ;;

  CLUSTER_NAME=*)
    readonly cluster_name="${i#*=}"
    ;;
  # if DRY_RUN is true, create the variable, other recognize that it exists but without creating the variable
  DRY_RUN=true)
    readonly dry_run=true
    ;;
  DRY_RUN=*) ;;

  GITHUB_TOKEN=*)
    readonly github_token="${i#*=}"
    ;;
  HELM_REGISTRY=*)
    readonly helm_registry="${i#*=}"
    ;;
  MODULE_NAME=*)
    readonly module_name="${i#*=}"
    ;;
  PHASE=*)
    readonly phase="${i#*=}"
    ;;
  TIMEOUT=*)
    readonly timeout="${i#*=}"
    ;;
  # if VERBOSE is true, create the variable, other recognize that it exists but without creating the variable
  VERBOSE=true)
    readonly verbose=true
    ;;
  VERBOSE=*) ;;
  *)
    echo "Unknown option $i"
    exit 1
    ;;
  esac
done

/usr/local/bin/aws eks --region "${aws_region}" update-kubeconfig --name "${cluster_name}"
cluster_iam=$(
  aws eks describe-cluster --name "${cluster_name}" |
    /usr/local/bin/jq -r '.cluster.arn | capture(":(?<id>[[:digit:]]+):").id'
)

echo "${github_token}" | helm registry login ghcr.io -u $ --password-stdin

echo "🚀🚀🚀 Upgrading ${phase} in ${cluster_name} 🚀🚀🚀"
echo "${chart_name}:${chart_version}"
set +u
[ "${dry_run}" ] && echo "🟧🟧🟧 dry run 🟧🟧🟧"
set -u
echo "🚀🚀🚀 ==================== 🚀🚀🚀"

set -vx
namespace="${phase}-${module_name}"

kubectl create namespace "${namespace}"
kubectl get secret regcred --namespace=default --export -o yaml | \
  kubectl apply --namespace="${namespace}" -f -

/usr/local/bin/helm upgrade --install --render-subchart-notes \
  ${dry_run:+--dry-run} ${verbose:+--debug} \
  --namespace "${namespace}" \
  --atomic ${clean_up:+--cleanup-on-fail} \
  --timeout "${timeout}" \
  --values "src/main/helm/values-${phase}.yaml" \
  --set "global.CLUSTER_IAM=arn:aws:iam::${cluster_iam}:" --set "global.phase=${phase}" \
  --version "${chart_version}" "${module_name}" "${helm_registry}/${chart_name}"
