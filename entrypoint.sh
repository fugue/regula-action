#!/bin/bash
set -o nounset -o errexit -o pipefail

TERRAFORM_DIR="$1"
shift 1
REGULA_OUTPUT="$(mktemp)"
cd "$GITHUB_WORKSPACE" && /opt/regula/bin/regula "$TERRAFORM_DIR" /opt/regula/lib $@ \
    | tee "$REGULA_OUTPUT"

FAILED="$(jq '.result[0].expressions[0].value.failed | @sh' "$REGULA_OUTPUT")"
NUM_PASSED="$(jq -r '.result[0].expressions[0].value.num_passed' "$REGULA_OUTPUT")"
NUM_FAILED="$(jq -r '.result[0].expressions[0].value.num_failed' "$REGULA_OUTPUT")"
VALID="$(jq -r '.result[0].expressions[0].value.valid' "$REGULA_OUTPUT")"
echo "$NUM_PASSED rules passed, $NUM_FAILED rules failed"
echo "::set-output name=rules_passed::$NUM_PASSED"
echo "::set-output name=rules_failed::$NUM_FAILED"
if [[ "$VALID" != "true" ]]; then
    echo "::error ::Rules failed: $FAILED"
    exit 1
fi
