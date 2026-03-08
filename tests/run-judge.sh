#!/usr/bin/env bash
set -euo pipefail

# run-judge.sh — Standalone LLM judge invocation for scoring a research report
# Usage: ./tests/run-judge.sh --report path/to/report.md --question-id q01 --questions-file tests/eval-questions.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUBRIC_FILE="$SCRIPT_DIR/judge-rubric.md"

REPORT=""
QUESTION_ID=""
QUESTIONS_FILE=""

usage() {
  cat >&2 <<EOF
Usage: $0 --report <path> --question-id <id> --questions-file <path>

Options:
  --report          Path to the research report markdown file
  --question-id     Question ID (e.g., q01) from the questions file
  --questions-file  Path to eval-questions.json
  -h, --help        Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report)          REPORT="$2"; shift 2 ;;
    --question-id)     QUESTION_ID="$2"; shift 2 ;;
    --questions-file)  QUESTIONS_FILE="$2"; shift 2 ;;
    -h|--help)         usage ;;
    *)                 echo "Unknown option: $1" >&2; usage ;;
  esac
done

[[ -z "$REPORT" ]] && { echo "Error: --report is required" >&2; usage; }
[[ -z "$QUESTION_ID" ]] && { echo "Error: --question-id is required" >&2; usage; }
[[ -z "$QUESTIONS_FILE" ]] && { echo "Error: --questions-file is required" >&2; usage; }
[[ ! -f "$REPORT" ]] && { echo "Error: report not found: $REPORT" >&2; exit 1; }
[[ ! -f "$QUESTIONS_FILE" ]] && { echo "Error: questions file not found: $QUESTIONS_FILE" >&2; exit 1; }
[[ ! -f "$RUBRIC_FILE" ]] && { echo "Error: rubric not found: $RUBRIC_FILE" >&2; exit 1; }

if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found in PATH" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' not found in PATH" >&2
  exit 1
fi

# Extract question and criteria from questions file
QUESTION_OBJ=$(jq -r --arg id "$QUESTION_ID" '.questions[] | select(.id == $id)' "$QUESTIONS_FILE")
if [[ -z "$QUESTION_OBJ" || "$QUESTION_OBJ" == "null" ]]; then
  echo "Error: question ID '$QUESTION_ID' not found in $QUESTIONS_FILE" >&2
  exit 1
fi

QUESTION_TEXT=$(echo "$QUESTION_OBJ" | jq -r '.question')
CRITERIA=$(echo "$QUESTION_OBJ" | jq -r '.rubric_criteria[] | "- [" + .dimension + "] " + .criterion' 2>/dev/null || echo "No specific criteria")

# Read rubric and replace criteria placeholder
RUBRIC=$(cat "$RUBRIC_FILE")
RUBRIC="${RUBRIC//\{\{QUESTION_CRITERIA\}\}/$CRITERIA}"

# Read report
REPORT_TEXT=$(cat "$REPORT")

# Construct the full judge prompt
JUDGE_PROMPT=$(cat <<PROMPT_EOF
${RUBRIC}

---

## Research Question

${QUESTION_TEXT}

---

## Report to Evaluate

${REPORT_TEXT}
PROMPT_EOF
)

# Invoke claude CLI
echo "Judging report for question ${QUESTION_ID}..." >&2
RESPONSE=$(echo "$JUDGE_PROMPT" | claude -p --model sonnet --output-format json 2>/dev/null) || {
  echo "Error: claude CLI invocation failed" >&2
  exit 1
}

# Extract JSON from the response — handle both raw JSON and wrapped responses
# Try parsing directly first
if echo "$RESPONSE" | jq empty 2>/dev/null; then
  # If the response has a "result" field (output-format json), extract it
  if echo "$RESPONSE" | jq -e '.result' &>/dev/null; then
    RESULT_TEXT=$(echo "$RESPONSE" | jq -r '.result')
  else
    RESULT_TEXT="$RESPONSE"
  fi
else
  RESULT_TEXT="$RESPONSE"
fi

# Try to extract JSON block from the text (might be wrapped in markdown code fences)
JSON_OUTPUT=$(echo "$RESULT_TEXT" | sed -n '/^```json/,/^```/p' | sed '1d;$d' || true)
if [[ -z "$JSON_OUTPUT" ]]; then
  # Try to find raw JSON object
  JSON_OUTPUT=$(echo "$RESULT_TEXT" | sed -n '/^{/,/^}/p' || true)
fi
if [[ -z "$JSON_OUTPUT" ]]; then
  # Last resort: use entire response
  JSON_OUTPUT="$RESULT_TEXT"
fi

# Validate JSON
if ! echo "$JSON_OUTPUT" | jq empty 2>/dev/null; then
  echo "Warning: judge output is not valid JSON, returning raw response" >&2
  echo "$RESULT_TEXT"
  exit 1
fi

# Output the parsed scorecard
echo "$JSON_OUTPUT" | jq .

# Print composite score as final line
COMPOSITE=$(echo "$JSON_OUTPUT" | jq -r '.composite_score // "N/A"')
echo "Score: ${COMPOSITE}" >&2
