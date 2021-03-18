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
cd "$GITHUB_WORKSPACE" && regula "$INPUT_PATH" /opt/regula/lib $INPUT_REGO_PATHS \
    | tee "$REGULA_OUTPUT"

RULES_PASSED="$(jq -r '.result[0].expressions[0].value.summary.rules_passed' "$REGULA_OUTPUT")"
RULES_FAILED="$(jq -r '.result[0].expressions[0].value.summary.rules_failed' "$REGULA_OUTPUT")"
CONTROLS_PASSED="$(jq -r '.result[0].expressions[0].value.summary.controls_passed' "$REGULA_OUTPUT")"
CONTROLS_FAILED="$(jq -r '.result[0].expressions[0].value.summary.controls_failed' "$REGULA_OUTPUT")"
VALID="$(jq -r '.result[0].expressions[0].value.summary.valid' "$REGULA_OUTPUT")"
echo "::set-output name=rules_passed::$RULES_PASSED"
echo "::set-output name=rules_failed::$RULES_FAILED"
echo "::set-output name=controls_passed::$CONTROLS_PASSED"
echo "::set-output name=controls_failed::$CONTROLS_FAILED"
jq -r '.result[0].expressions[0].value.message' "$REGULA_OUTPUT"
if [[ "$VALID" != "true" ]]; then
    exit 1
fi
