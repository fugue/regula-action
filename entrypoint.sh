#!/bin/bash
set -o nounset -o errexit -o pipefail

# Set defaults again; these don't seem to take the default from actions.yml.
INPUT_TERRAFORM_DIRECTORY="${INPUT_TERRAFORM_DIRECTORY:-.}"
INPUT_REGO_PATHS="${INPUT_REGO_PATHS:-/opt/regula/rules}"

TERRAFORM_DIR="$INPUT_TERRAFORM_DIRECTORY"
REGULA_OUTPUT="$(mktemp)"
cd "$GITHUB_WORKSPACE" && /opt/regula/bin/regula "$TERRAFORM_DIR" /opt/regula/lib $INPUT_REGO_PATHS \
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
