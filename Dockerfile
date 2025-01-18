FROM ghcr.io/dtzar/helm-kubectl:3.16.4 AS helm

FROM ghcr.io/jqlang/jq:1.7.1 AS jq

FROM public.ecr.aws/aws-cli/aws-cli:2.21.0
COPY --from=helm /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=helm /usr/local/bin/helm /usr/local/bin/helm
COPY --from=jq /jq /usr/local/bin/jq

COPY action.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
