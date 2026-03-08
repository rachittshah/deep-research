#!/usr/bin/env bash
set -euo pipefail

# run-eval.sh — Lightweight proxy evaluator for fast optimize-anything iterations
#
# For official DeepResearch-Bench scores (RACE+FACT), use:
#   tests/deepresearch-bench/run-bench.sh
#
# This script provides QUICK scoring via structural checks + our own LLM judge.
# It outputs "Score: X.XX" as the final line for optimize-anything compatibility.
#
# Usage:
#   ./tests/run-eval.sh --report report.md --question "What is...?"
#   ./tests/run-eval.sh --bench-dir /path/to/deep_research_bench --sample 3
#   ./tests/run-eval.sh --quick   (alias: --sample 3 from DeepResearch-Bench English tasks)
#   ./tests/run-eval.sh --candidate-file skill.md --candidate-target skills/deep-research/SKILL.md --quick

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
JUDGE_RUBRIC="${SCRIPT_DIR}/judge-rubric.md"
STRUCTURAL_CHECKS="${SCRIPT_DIR}/structural-checks.sh"

REPORT=""
QUESTION=""
BENCH_DIR=""
SAMPLE=0
CANDIDATE_FILE=""
CANDIDATE_TARGET=""
MODEL="claude-sonnet-4-6"
JUDGE_MODEL="claude-sonnet-4-6"
OUTPUT_DIR=""

usage() {
  cat <<'EOF'
Usage: run-eval.sh [OPTIONS]

Modes:
  --report FILE --question TEXT       Score an existing report
  --bench-dir DIR [--sample N]        Run plugin on N DeepResearch-Bench tasks, score each
  --quick                             Alias for --sample 3 with auto-detected bench dir

Optimize-anything integration:
  --candidate-file FILE               Modified skill/agent file to test
  --candidate-target PATH             File in plugin to replace (relative path)

Options:
  --model MODEL                       Model for research runs (default: claude-sonnet-4-6)
  --judge-model MODEL                 Model for LLM judge (default: claude-sonnet-4-6)
  --output-dir DIR                    Custom output directory
  -h, --help                          Show help

Output: Final line is always "Score: X.XX" (optimize-anything compatible)
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report) REPORT="$2"; shift 2 ;;
    --question) QUESTION="$2"; shift 2 ;;
    --bench-dir) BENCH_DIR="$2"; shift 2 ;;
    --sample) SAMPLE="$2"; shift 2 ;;
    --candidate-file) CANDIDATE_FILE="$2"; shift 2 ;;
    --candidate-target) CANDIDATE_TARGET="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --judge-model) JUDGE_MODEL="$2"; shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --quick) SAMPLE=3; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown: $1" >&2; exit 1 ;;
  esac
done

# --- Setup ---
RUN_ID=$(date +%Y%m%d-%H%M%S)
[[ -z "$OUTPUT_DIR" ]] && OUTPUT_DIR="${SCRIPT_DIR}/runs/${RUN_ID}"
mkdir -p "$OUTPUT_DIR"

[[ ! -f "$JUDGE_RUBRIC" ]] && { echo "Error: judge-rubric.md not found at $JUDGE_RUBRIC" >&2; exit 1; }
[[ ! -x "$STRUCTURAL_CHECKS" ]] && { echo "Error: structural-checks.sh not found/executable" >&2; exit 1; }

# --- Candidate swap for optimize-anything ---
EFFECTIVE_PLUGIN_DIR="$PLUGIN_DIR"
if [[ -n "$CANDIDATE_FILE" && -n "$CANDIDATE_TARGET" ]]; then
  TEMP_PLUGIN=$(mktemp -d)
  trap "rm -rf $TEMP_PLUGIN" EXIT
  cp -R "${PLUGIN_DIR}/"* "${PLUGIN_DIR}/".[!.]* "$TEMP_PLUGIN/" 2>/dev/null || true
  mkdir -p "$(dirname "${TEMP_PLUGIN}/${CANDIDATE_TARGET}")"
  cp "$CANDIDATE_FILE" "${TEMP_PLUGIN}/${CANDIDATE_TARGET}"
  EFFECTIVE_PLUGIN_DIR="$TEMP_PLUGIN"
  echo "==> Candidate swap: ${CANDIDATE_TARGET}" >&2
fi

# --- Run LLM judge on a report ---
run_judge() {
  local report_file="$1"
  local question_text="$2"

  local rubric report_text
  rubric=$(cat "$JUDGE_RUBRIC")
  rubric="${rubric//\{\{QUESTION_CRITERIA\}\}/No question-specific criteria provided.}"
  report_text=$(cat "$report_file")

  local prompt="$(cat <<PROMPT
${rubric}

---

## Original Question

${question_text}

## Research Report

${report_text}

---

Evaluate the report above. Return JSON only, no other text.
PROMPT
)"

  claude -p "$prompt" \
    --model "$JUDGE_MODEL" \
    --max-turns 1 \
    --dangerously-skip-permissions 2>/dev/null || echo '{"composite_score": 0}'
}

# --- Extract composite score from judge JSON ---
extract_score() {
  python3 -c "
import sys, json, re
text = sys.stdin.read()
m = re.search(r'\{[\s\S]*\}', text)
if m:
    try:
        d = json.loads(m.group())
        print(f\"{d.get('composite_score', 0):.2f}\")
    except: print('0.00')
else: print('0.00')
" 2>/dev/null <<< "$1" || echo "0.00"
}

# --- Run deep-research plugin on a question ---
run_research() {
  local question="$1"
  local out_file="$2"
  claude -p "Perform deep research on the following question. Follow the deep-research skill exactly. Question: ${question}" \
    --model "$MODEL" \
    --allowedTools "WebSearch,WebFetch,Agent,Read,Glob,Grep,Bash" \
    --dangerously-skip-permissions \
    --max-turns 50 \
    > "$out_file" 2>/dev/null || echo "Research failed" > "$out_file"
}

# --- Score one report ---
score_one() {
  local report_file="$1"
  local question="$2"
  local label="$3"

  echo "  [$label] Structural checks..." >&2
  local struct
  struct=$("$STRUCTURAL_CHECKS" --report "$report_file" 2>/dev/null || echo '{"all_passed":false}')
  local passed
  passed=$(echo "$struct" | python3 -c "import json,sys; print(json.loads(sys.stdin.read()).get('all_passed',False))" 2>/dev/null || echo "False")

  local penalty="1.0"
  [[ "$passed" != "True" ]] && penalty="0.8" && echo "  [$label] Structural issues (0.8x penalty)" >&2

  echo "  [$label] LLM judge..." >&2
  local judge_out
  judge_out=$(run_judge "$report_file" "$question")
  local raw_score
  raw_score=$(extract_score "$judge_out")
  local final
  final=$(echo "$raw_score $penalty" | awk '{printf "%.2f", $1 * $2}')

  echo "$struct" > "${OUTPUT_DIR}/${label}-structural.json"
  echo "$judge_out" > "${OUTPUT_DIR}/${label}-judge.txt"

  echo "  [$label] Score: ${final}/5.00" >&2
  echo "$final"
}

# ============================================================
# Mode 1: Score an existing report
# ============================================================
if [[ -n "$REPORT" ]]; then
  [[ -z "$QUESTION" ]] && { echo "Error: --question required with --report" >&2; exit 1; }
  [[ ! -f "$REPORT" ]] && { echo "Error: report not found: $REPORT" >&2; exit 1; }

  score=$(score_one "$REPORT" "$QUESTION" "single")
  echo ""
  echo "Score: ${score}"
  exit 0
fi

# ============================================================
# Mode 2: Run on DeepResearch-Bench tasks
# ============================================================
# Auto-detect bench dir if not provided
if [[ -z "$BENCH_DIR" && "$SAMPLE" -gt 0 ]]; then
  for d in /tmp/deep_research_bench "$HOME/deep_research_bench"; do
    [[ -d "$d/data/prompt_data" ]] && BENCH_DIR="$d" && break
  done
fi

if [[ -n "$BENCH_DIR" ]]; then
  QUERY_FILE="${BENCH_DIR}/data/prompt_data/query.jsonl"
  [[ ! -f "$QUERY_FILE" ]] && { echo "Error: query.jsonl not found. Clone DeepResearch-Bench first." >&2; exit 1; }

  # Read English tasks, optionally sample
  mapfile -t TASKS < <(python3 -c "
import json
tasks = []
with open('${QUERY_FILE}') as f:
    for line in f:
        t = json.loads(line)
        if t.get('language') == 'en':
            tasks.append(t)
sample = min(int('${SAMPLE}') if int('${SAMPLE}') > 0 else len(tasks), len(tasks))
for t in tasks[:sample]:
    print(json.dumps(t))
")

  total=${#TASKS[@]}
  echo "==> DeepResearch-Bench proxy eval: ${total} English tasks" >&2
  echo "==> Research model: ${MODEL} | Judge: ${JUDGE_MODEL}" >&2
  echo "==> Output: ${OUTPUT_DIR}" >&2
  echo "" >&2

  scores=()
  for i in "${!TASKS[@]}"; do
    task_json="${TASKS[$i]}"
    tid=$(echo "$task_json" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['id'])")
    prompt=$(echo "$task_json" | python3 -c "import json,sys; print(json.loads(sys.stdin.read())['prompt'])")

    echo "--- [$(( i + 1 ))/${total}] Task ${tid}: ${prompt:0:70}..." >&2

    report_file="${OUTPUT_DIR}/task-${tid}-report.md"

    # Run research
    t0=$(date +%s)
    run_research "$prompt" "$report_file"
    t1=$(date +%s)
    echo "  Research: $(( t1 - t0 ))s" >&2

    # Score
    score=$(score_one "$report_file" "$prompt" "task-${tid}")
    scores+=("$score")
  done

  # Average
  avg=$(python3 -c "
s = [${scores[*]// /,}]
print(f'{sum(s)/len(s):.2f}' if s else '0.00')
")

  echo "" >&2
  echo "==========================================" >&2
  echo "  Run: ${RUN_ID}" >&2
  echo "  Tasks: ${total}" >&2
  echo "  Avg proxy score: ${avg}/5.00" >&2
  echo "  Output: ${OUTPUT_DIR}" >&2
  echo "==========================================" >&2
  echo "" >&2
  echo "Score: ${avg}"
  exit 0
fi

echo "Error: specify --report or --bench-dir or --quick" >&2
usage
