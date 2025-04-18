#!/usr/bin/env bash

if [ "${RUNNER_DEBUG}" == 1 ]; then
  set -xv
  readonly verbose=true
fi
set -u

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
  # if DRY_RUN is true, create the variable, otherwise recognize that it exists but without creating the variable
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
  NAMESPACE=*)
    readonly namespace="${i#*=}"
    ;;
  PHASE=*)
    readonly phase="${i#*=}"
    ;;
  TIMEOUT=*)
    readonly timeout="${i#*=}"
    ;;
  VALUE_FILE=*)
    readonly value_file="${i#*=}"
    ;;
  # if VERBOSE is true, create the variable, otherwise recognize that it exists but without creating the variable
  # Overridden by GitHub Workflow's verbosity
  VERBOSE=true)
    [ ! -v verbose ] && readonly verbose=true
    ;;
  VERBOSE=*) ;;
  *)
    echo "Unknown option $i"
    exit 1
    ;;
  esac
done

[ "${verbose:-false}" = "true" ] && aws sts get-caller-identity

/usr/local/bin/aws eks --region "${aws_region}" update-kubeconfig --name "${cluster_name}"
cluster_iam=$(
  aws eks describe-cluster --name "${cluster_name}" |
    /usr/local/bin/jq -r '.cluster.arn | capture(":(?<id>[[:digit:]]+):").id'
)

echo "${github_token}" | helm registry login ghcr.io -u $ --password-stdin

echo "🚀🚀🚀 Upgrading ${phase} in ${cluster_name} 🚀🚀🚀"
echo "${chart_name}:${chart_version}"
[ "${dry_run:-false}" = "false" ] && echo "🟧🟧🟧 dry run 🟧🟧🟧"
echo "🚀🚀🚀 ==================== 🚀🚀🚀"

waitOrAtomic=()
if [ "${clean_up:-false}" = "false" ]; then
  waitOrAtomic+=("--wait")
else
  waitOrAtomic+=("--atomic" "--cleanup-on-fail")
fi

buildTimeValues=("--values" "src/main/helm/values-${phase}.yaml")
[ -n "${value_file}" ] && [ -r "${value_file}" ] && buildTimeValues+=("--values" "${value_file}")

/usr/local/bin/helm upgrade --install --render-subchart-notes \
  ${dry_run:+--dry-run} ${verbose:+--debug} "${waitOrAtomic[@]}" \
  --create-namespace --namespace "${namespace}" \
  --timeout "${timeout}" \
  "${buildTimeValues[@]}" \
  --set "global.CLUSTER_IAM=arn:aws:iam::${cluster_iam}" --set "global.AWS_REGION=${aws_region}" \
  --set "global.phase=${phase}" \
  --version "${chart_version}" "${module_name}" "${helm_registry}/${chart_name}"
