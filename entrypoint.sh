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

if [[ -v INPUT_CONFIG && -n "${INPUT_CONFIG}" ]]; then
  REGULA_OPTS+=("--config" "${INPUT_CONFIG}")
fi

if [[ -v INPUT_ENVIRONMENT_ID && -n "${INPUT_ENVIRONMENT_ID}" ]]; then
  REGULA_OPTS+=("--environment-id" "${INPUT_ENVIRONMENT_ID}")
fi

for EXCLUDE in ${INPUT_EXCLUDE:-}; do
  REGULA_OPTS+=("--exclude" ${EXCLUDE})
done

if [[ -v INPUT_FORMAT && -n "${INPUT_FORMAT}" ]]; then
  REGULA_OPTS+=("--format" ${FORMAT})
fi

for REGO_PATH in ${INPUT_REGO_PATHS:-} ${INPUT_INCLUDE:-}; do
  # Ignore old location of regula rules for backwards compatibility
  if [[ "${REGO_PATH}" == "/opt/regula/rules" ]]; then
    echo "Ignoring rego path /opt/regula/rules. It is no longer necessary to specify this."
    continue
  fi
  REGULA_OPTS+=("--include" ${REGO_PATH})
done

for INPUT_TYPE in ${INPUT_INPUT_TYPE:-}; do
  REGULA_OPTS+=("--input-type" ${INPUT_TYPE})
done

# Deprecated
if [[ -v INPUT_USER_ONLY && "${INPUT_USER_ONLY}" == "true" ]] || [[ -v INPUT_NO_BUILT_INS && "${INPUT_NO_BUILT_INS}" == "true" ]]; then
  REGULA_OPTS+=("--no-built-ins")
fi

if [[ -v INPUT_NO_CONFIG && "${INPUT_NO_CONFIG}" == "true" ]]; then
  REGULA_OPTS+=("--no-config")
fi

if [[ -v INPUT_NO_IGNORE && "${INPUT_NO_IGNORE}" == "true" ]]; then
  REGULA_OPTS+=("--no-ignore")
fi

for ONLY in ${INPUT_ONLY:-}; do
  REGULA_OPTS+=("--only" ${ONLY})
done

if [[ -v INPUT_SEVERITY && -n "${INPUT_SEVERITY}" ]]; then
  REGULA_OPTS+=("--severity" "${INPUT_SEVERITY}")
fi

if [[ -v INPUT_SYNC && "${INPUT_SYNC}" == "true" ]]; then
  REGULA_OPTS+=("--sync")
fi

if [[ -v INPUT_UPLOAD && "${INPUT_UPLOAD}" == "true" ]]; then
  REGULA_OPTS+=("--upload")
fi


if [[ -v DEBUG && -n "${DEBUG}" ]]; then
  echo ${REGULA_OPTS[@]} $INPUT_PATH
fi

EXIT_CODE=0
REGULA_OUTPUT=$(cd "$GITHUB_WORKSPACE" && regula run ${REGULA_OPTS[@]} $INPUT_PATH) ||
  EXIT_CODE=$?
echo "${REGULA_OUTPUT}"

RULES_PASSED="$(jq -r '.summary.rule_results.PASS' <<<"$REGULA_OUTPUT")"
RULES_FAILED="$(jq -r '.summary.rule_results.FAIL' <<<"$REGULA_OUTPUT")"
echo "rules_passed=$RULES_PASSED" >>$GITHUB_OUTPUT
echo "rules_failed=$RULES_FAILED" >>$GITHUB_OUTPUT
exit ${EXIT_CODE}
