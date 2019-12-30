# Container image that runs your code
FROM debian:jessie

# Install a number of dependencies using apt.
RUN apt-get update && apt-get install -y curl jq unzip

# Install OPA.
ARG OPA_VERSION=0.15.1
RUN curl -Lo '/usr/local/bin/opa' \
        "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64" &&\
    chmod +x '/usr/local/bin/opa'

# Install terraform.
ARG TERRAFORM_VERSION=0.12.18
ENV TF_IN_AUTOMATION=true
RUN curl -Lo "/tmp/terraform-${TERRAFORM_VERSION}.zip" \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip -d '/usr/local/bin' "/tmp/terraform-${TERRAFORM_VERSION}.zip"

# Pre-install the `aws` terraform provider.
RUN mkdir /tmp/terraform-aws && \
    echo 'provider "aws" {}' >/tmp/terraform-aws/main.tf && \
    terraform get /tmp/terraform-aws && \
    rm -rf /tmp/terraform-aws

# Install regula modules.
ARG REGULA_VERSION=6d54b0f8b
RUN mkdir -p /opt/regula && \
    curl -L "https://github.com/jaspervdj-luminal/regula/archive/${REGULA_VERSION}.tar.gz" | \
        tar -xz --strip-components=1 -C /opt/regula/

# Code file to execute when the docker container starts up (`entrypoint.sh`)
COPY entrypoint.sh /entrypoint.sh
ENV HOME=/root
ENTRYPOINT ["/entrypoint.sh"]
