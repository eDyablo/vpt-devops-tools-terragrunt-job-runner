ARG CONTAINER_IMAGE_REGISTRY

FROM ${CONTAINER_IMAGE_REGISTRY:+${CONTAINER_IMAGE_REGISTRY}/}alpine:3.20.1

ENV TERRAGRUNT_VERSION=v0.59.3

RUN \
  echo "Installing basic tooling" \
    && apk add --update --no-cache \
      aws-cli=2.15.57-r0 \
      bash=5.2.26-r0 \
      curl=8.7.1-r0 \
      git=2.45.2-r0 \
      jq=1.7.1-r0 \
      openssh=9.7_p1-r3 \
      openssl=3.3.1-r0 \
      opentofu=1.7.2-r1 \
  && OS_NAME=$(uname -o | tr '[:upper:]' '[:lower:]') \
    && ARCH_NAME=$(uname -m) \
      && ARCH_NAME=${ARCH_NAME/aarch64/arm64} \
      && ARCH_NAME=${ARCH_NAME/x86_64/amd64} \
  && echo "Installing terragrunt version ${TERRAGRUNT_VERSION#v}" \
    && curl -fL https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_${OS_NAME}_${ARCH_NAME} \
      --output /usr/local/bin/terragrunt \
      --no-progress-meter \
  && chmod +x /usr/local/bin/terragrunt

ARG CONTAINER_USER=default
ARG CONTAINER_USER_GROUP=default

RUN addgroup -S ${CONTAINER_USER_GROUP} \
  && adduser -S ${CONTAINER_USER} -G ${CONTAINER_USER_GROUP}

USER ${CONTAINER_USER}:${CONTAINER_USER_GROUP}

WORKDIR /var/workspace
