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

REGULA_OPTS=()
for REGO_PATH in ${INPUT_REGO_PATHS:-}; do
  # Ignore old location of regula rules for backwards compatibility
  if [[ "${REGO_PATH}" == "/opt/regula/rules" ]]; then
    echo "Ignoring rego path /opt/regula/rules. It is no longer necessary to specify this."
    continue
  fi
  REGULA_OPTS+=("-i" ${REGO_PATH})
done

if [[ -v INPUT_SEVERITY && -n "${INPUT_SEVERITY}" ]]; then
  REGULA_OPTS+=("-s" "${INPUT_SEVERITY}")
fi

if [[ -v INPUT_USER_ONLY && "${INPUT_USER_ONLY}" == "true" ]]; then
  REGULA_OPTS+=("-u")
fi

if [[ -v INPUT_INPUT_TYPE && -n "${INPUT_INPUT_TYPE}" ]]; then
  REGULA_OPTS+=("-t" "${INPUT_INPUT_TYPE}")
fi

EXIT_CODE=0
REGULA_OUTPUT=$(cd "$GITHUB_WORKSPACE" && regula run ${REGULA_OPTS[@]} $INPUT_PATH) ||
  EXIT_CODE=$?
echo "${REGULA_OUTPUT}"

RULES_PASSED="$(jq -r '.summary.rule_results.PASS' <<<"$REGULA_OUTPUT")"
RULES_FAILED="$(jq -r '.summary.rule_results.FAIL' <<<"$REGULA_OUTPUT")"
echo "::set-output name=rules_passed::$RULES_PASSED"
echo "::set-output name=rules_failed::$RULES_FAILED"
exit ${EXIT_CODE}
