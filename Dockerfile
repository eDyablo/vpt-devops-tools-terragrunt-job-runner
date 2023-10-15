ARG DOCKER_REGISTRY

FROM ${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}alpine

ENV \
	TERRAFORM_VERSION=1.5.1 \
	TERRAGRUNT_VERSION=v0.45.14

RUN \
	echo "Installing basic tooling" \
		&& apk add --update --no-cache \
			aws-cli \
			bash \
			curl \
			git \
			jq \
			openssl \
	&& OS_NAME=$(uname -o | tr '[:upper:]' '[:lower:]') \
    && ARCH_NAME=$(uname -m) \
      && ARCH_NAME=${ARCH_NAME/aarch64/arm64} \
      && ARCH_NAME=${ARCH_NAME/x86_64/amd64} \
	&& echo "Installing terraform version ${TERRAFORM_VERSION#v}" \
    && curl -fL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS_NAME}_${ARCH_NAME}.zip \
      --output /tmp/terraform.zip \
      --no-progress-meter \
    && unzip -q /tmp/terraform.zip terraform -d /usr/local/bin \
    && rm /tmp/terraform.zip \
  && echo "Installing terragrunt version ${TERRAGRUNT_VERSION#v}" \
    && curl -fL https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_${OS_NAME}_${ARCH_NAME} \
      --output /usr/local/bin/terragrunt \
      --no-progress-meter \
  && chmod +x /usr/local/bin/terragrunt

ARG CONTAINER_USER=default

RUN addgroup -S ${CONTAINER_USER#*:} \
  && adduser -S ${CONTAINER_USER%:*} -G ${CONTAINER_USER#*:}

USER $CONTAINER_USER

WORKDIR /var/workspace
