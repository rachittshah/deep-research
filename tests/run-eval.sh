#!/usr/bin/env bash
set -euo pipefail

# run-eval.sh — Lightweight proxy evaluator for fast iteration
#
# Runs structural-checks.sh + LLM judge (run-judge.sh) on a research report
# and outputs a composite "Score: X.XX" for optimize-anything compatibility.
#
# Usage:
#   ./tests/run-eval.sh --report report.md --question-id q01
#   ./tests/run-eval.sh --candidate-file report.md --question-id q01
#   ./tests/run-eval.sh --bench-dir tests/deepresearch-bench/results --sample 3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STRUCTURAL_CHECKS="$SCRIPT_DIR/structural-checks.sh"
RUN_JUDGE="$SCRIPT_DIR/run-judge.sh"
QUESTIONS_FILE="$SCRIPT_DIR/eval-questions.json"

REPORT=""
QUESTION_ID=""
BENCH_DIR=""
SAMPLE_N=0

usage() {
  cat >&2 <<EOF
Usage: $0 [options]

Options:
  --report <path>          Path to research report to evaluate
  --candidate-file <path>  Alias for --report (optimize-anything compatibility)
  --question-id <id>       Question ID from eval-questions.json (e.g., q01)
  --questions-file <path>  Override path to questions file (default: tests/eval-questions.json)
  --bench-dir <path>       Directory of bench report files to evaluate in batch
  --sample <N>             When using --bench-dir, evaluate only N random reports
  -h, --help               Show this help

Single report mode:
  Requires --report (or --candidate-file) and --question-id.
  Runs structural checks + LLM judge, outputs composite score.

Batch mode:
  Requires --bench-dir. Expects files named <question-id>.md (e.g., q01.md).
  Evaluates each report and outputs per-question and average scores.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report)          REPORT="$2"; shift 2 ;;
    --candidate-file)  REPORT="$2"; shift 2 ;;
    --question-id)     QUESTION_ID="$2"; shift 2 ;;
    --questions-file)  QUESTIONS_FILE="$2"; shift 2 ;;
    --bench-dir)       BENCH_DIR="$2"; shift 2 ;;
    --sample)          SAMPLE_N="$2"; shift 2 ;;
    -h|--help)         usage ;;
    *)                 echo "Unknown option: $1" >&2; usage ;;
  esac
done

# Validate dependencies
for cmd in jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' not found in PATH" >&2
    exit 1
  fi
done

[[ ! -x "$STRUCTURAL_CHECKS" ]] && { echo "Error: structural-checks.sh not found or not executable at $STRUCTURAL_CHECKS" >&2; exit 1; }
[[ ! -x "$RUN_JUDGE" ]] && { echo "Error: run-judge.sh not found or not executable at $RUN_JUDGE" >&2; exit 1; }
[[ ! -f "$QUESTIONS_FILE" ]] && { echo "Error: questions file not found at $QUESTIONS_FILE" >&2; exit 1; }

# --- Score a single report ---
score_report() {
  local report_file="$1"
  local qid="$2"

  [[ ! -f "$report_file" ]] && { echo "Error: report not found: $report_file" >&2; return 1; }

  # Step 1: Structural checks
  echo "Running structural checks on $report_file..." >&2
  local struct_json
  struct_json=$("$STRUCTURAL_CHECKS" --report "$report_file" 2>/dev/null) || {
    echo "Warning: structural checks failed for $report_file" >&2
    struct_json='{"all_passed": false}'
  }

  local struct_passed
  struct_passed=$(echo "$struct_json" | jq -r '.all_passed')

  # Structural penalty: if checks fail, apply a 0.5 multiplier to final score
  local struct_multiplier="1.0"
  if [[ "$struct_passed" != "true" ]]; then
    struct_multiplier="0.5"
    echo "  Structural checks FAILED (0.5x penalty applied)" >&2

    # Show which checks failed
    echo "$struct_json" | jq -r '
      .sections | to_entries[] | select(.value == false) | "    Missing section: \(.key)"
    ' >&2 2>/dev/null || true

    local unsourced
    unsourced=$(echo "$struct_json" | jq -r '.unsourced_count // 0')
    [[ "$unsourced" != "0" ]] && echo "    Unsourced claims: $unsourced" >&2

    local wc
    wc=$(echo "$struct_json" | jq -r '.word_count // 0')
    if [[ "$wc" -lt 500 ]]; then
      echo "    Word count too low: $wc (min 500)" >&2
    elif [[ "$wc" -gt 10000 ]]; then
      echo "    Word count too high: $wc (max 10000)" >&2
    fi
  else
    echo "  Structural checks PASSED" >&2
  fi

  # Step 2: LLM judge
  echo "Running LLM judge for $qid..." >&2
  local judge_json
  judge_json=$("$RUN_JUDGE" --report "$report_file" --question-id "$qid" --questions-file "$QUESTIONS_FILE" 2>/dev/null) || {
    echo "Error: LLM judge failed for $report_file" >&2
    echo "Score: 0.00"
    return 1
  }

  # Extract composite score
  local composite
  composite=$(echo "$judge_json" | jq -r '.composite_score // 0')

  # Apply structural penalty
  local final_score
  final_score=$(echo "$composite $struct_multiplier" | awk '{printf "%.2f", $1 * $2}')

  # Output full details to stdout (JSON)
  jq -n \
    --argjson structural "$struct_json" \
    --argjson judge "$judge_json" \
    --arg final "$final_score" \
    --arg struct_pass "$struct_passed" \
    '{
      structural_checks: $structural,
      structural_passed: ($struct_pass == "true"),
      judge_scores: $judge,
      final_score: ($final | tonumber)
    }'

  echo "Score: ${final_score}" >&2
}

# --- Batch mode ---
run_batch() {
  local bench_dir="$1"
  local sample_n="$2"

  [[ ! -d "$bench_dir" ]] && { echo "Error: bench directory not found: $bench_dir" >&2; exit 1; }

  # Find all .md report files
  local reports=()
  while IFS= read -r -d '' f; do
    reports+=("$f")
  done < <(find "$bench_dir" -name '*.md' -print0 | sort -z)

  if [[ ${#reports[@]} -eq 0 ]]; then
    echo "Error: no .md files found in $bench_dir" >&2
    exit 1
  fi

  # Sample if requested
  if [[ "$sample_n" -gt 0 && "$sample_n" -lt ${#reports[@]} ]]; then
    echo "Sampling $sample_n of ${#reports[@]} reports..." >&2
    local shuffled=()
    while IFS= read -r line; do
      shuffled+=("$line")
    done < <(printf '%s\n' "${reports[@]}" | sort -R | head -n "$sample_n")
    reports=("${shuffled[@]}")
  fi

  echo "Evaluating ${#reports[@]} reports..." >&2
  echo "---" >&2

  local total_score=0
  local count=0
  local results=()

  for report_file in "${reports[@]}"; do
    local basename
    basename=$(basename "$report_file" .md)
    # Use filename as question ID
    local qid="$basename"

    # Check if question exists in the questions file
    local exists
    exists=$(jq -r --arg id "$qid" '.questions[] | select(.id == $id) | .id' "$QUESTIONS_FILE" 2>/dev/null || true)
    if [[ -z "$exists" ]]; then
      echo "Skipping $report_file: question ID '$qid' not found in questions file" >&2
      continue
    fi

    echo "" >&2
    echo "=== Evaluating $qid ===" >&2
    local result_json
    result_json=$(score_report "$report_file" "$qid") || continue

    local score
    score=$(echo "$result_json" | jq -r '.final_score')
    total_score=$(echo "$total_score $score" | awk '{printf "%.2f", $1 + $2}')
    count=$((count + 1))
    results+=("$result_json")
  done

  echo "" >&2
  echo "---" >&2

  if [[ $count -eq 0 ]]; then
    echo "No reports evaluated successfully." >&2
    echo "Score: 0.00" >&2
    exit 1
  fi

  local avg_score
  avg_score=$(echo "$total_score $count" | awk '{printf "%.2f", $1 / $2}')

  # Output summary JSON
  echo "{"
  echo "  \"reports_evaluated\": $count,"
  echo "  \"total_score\": $total_score,"
  echo "  \"average_score\": $avg_score"
  echo "}"

  echo "Reports evaluated: $count" >&2
  echo "Score: ${avg_score}" >&2
}

# --- Main ---
if [[ -n "$BENCH_DIR" ]]; then
  run_batch "$BENCH_DIR" "$SAMPLE_N"
elif [[ -n "$REPORT" ]]; then
  [[ -z "$QUESTION_ID" ]] && { echo "Error: --question-id is required in single report mode" >&2; usage; }
  score_report "$REPORT" "$QUESTION_ID"
else
  echo "Error: must specify --report or --bench-dir" >&2
  usage
fi
