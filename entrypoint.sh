#!/bin/bash
set -o nounset -o errexit -o pipefail

if [[ -v INPUT_INPUT_PATH && -n "$INPUT_INPUT_PATH" ]]; then
  INPUT_PATH="$INPUT_INPUT_PATH"
elif [[ -v INPUT_TERRAFORM_DIRECTORY && -n "$INPUT_TERRAFORM_DIRECTORY" ]]; then
  # INPUT_TERRAFORM_DIRECTORY is deprecated.
  INPUT_PATH="$INPUT_TERRAFORM_DIRECTORY"
else
  # Default to the current directory.
  INPUT_PATH="."
fi

INPUT_REGO_PATHS="${INPUT_REGO_PATHS:-/opt/regula/rules}"

REGULA_OUTPUT="$(mktemp)"
cd "$GITHUB_WORKSPACE" && regula -d /opt/regula/lib -d $INPUT_REGO_PATHS $INPUT_PATH \
    | tee "$REGULA_OUTPUT"

RULES_PASSED="$(jq -r '.summary.rule_results.PASS' "$REGULA_OUTPUT")"
RULES_FAILED="$(jq -r '.summary.rule_results.FAIL' "$REGULA_OUTPUT")"
echo "::set-output name=rules_passed::$RULES_PASSED"
echo "::set-output name=rules_failed::$RULES_FAILED"
if [[ ${RULES_FAILED} -gt 0 ]]; then
    exit 1
fi
