# Container image that runs your code
FROM debian:jessie

# Install a number of dependencies using apt.
RUN apt-get update && apt-get install -y curl jq unzip

# Install the OPA executable.
ARG OPA_VERSION=0.15.1
RUN curl -Lo '/usr/local/bin/opa' \
    "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64" &&\
    chmod +x '/usr/local/bin/opa'

# Install terraform.
ARG TERRAFORM_VERSION=0.12.18
RUN curl -Lo "/tmp/terraform-${TERRAFORM_VERSION}.zip" \
    "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
    unzip -d '/usr/local/bin' "/tmp/terraform-${TERRAFORM_VERSION}.zip"

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
