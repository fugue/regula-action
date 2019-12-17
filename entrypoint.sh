#!/bin/bash

TERRAFORM_PLAN="$(mktemp)"
REGULA_INPUT="$(mktemp)"
REGULA_OUTPUT="$(mktemp)"

cd "$GITHUB_WORKSPACE"
terraform init
terraform plan -refresh=false -out="$TERRAFORM_PLAN"
terraform show -json "$TERRAFORM_PLAN" >"$REGULA_INPUT"

opa eval -i "$REGULA_INPUT" -d '/opt/regula' 'data.fugue.regula.report' \
    | tee "$REGULA_OUTPUT"

FAILED=$(jq '.result[0].expressions[0].value.failed' "$REGULA_OUTPUT")
NUM_PASSED=$(jq -r '.result[0].expressions[0].value.num_passed' "$REGULA_OUTPUT")
NUM_FAILED=$(jq -r '.result[0].expressions[0].value.num_failed' "$REGULA_OUTPUT")
VALID=$(jq -r '.result[0].expressions[0].value.valid' "$REGULA_OUTPUT")
echo "$NUM_PASSED rules passed, $NUM_FAILED rules failed"
if [[ "$VALID" != "true" ]]; then
    echo "::error ::Rules failed: ${FAILED}"
    exit 1
fi
