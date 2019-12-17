#!/bin/bash

TERRAFORM_PLAN="$(mktemp)"

cd "$GITHUB_WORKSPACE"
terraform init
terraform plan -refresh=false -out="$TERRAFORM_PLAN"
terraform show -json "$TERRAFORM_PLAN"
