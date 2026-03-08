#!/usr/bin/env bash
set -euo pipefail

# adapter.sh — Run our deep-research plugin on DeepResearch-Bench tasks
# and format output for their RACE/FACT evaluation pipeline.
#
# Usage:
#   ./tests/deepresearch-bench/adapter.sh \
#     --bench-dir /path/to/deep_research_bench \
#     --model opus \
#     --output our-plugin \
#     [--lang en|zh|all] \
#     [--max N] \
#     [--concurrent N]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Defaults
BENCH_DIR=""
MODEL="opus"
OUTPUT_NAME="our-plugin"
LANG_FILTER="en"
MAX_TASKS=0
CONCURRENT=3

usage() {
  cat >&2 <<EOF
Usage: $0 --bench-dir <path> [options]

Required:
  --bench-dir PATH    Path to cloned deep_research_bench repo

Options:
  --model MODEL       Claude model to use (default: opus)
  --output NAME       Output name for result file (default: our-plugin)
  --lang LANG         Language filter: en|zh|all (default: en)
  --max N             Max tasks to process, 0 = all (default: 0)
  --concurrent N      Parallel tasks (default: 3)
  -h, --help          Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bench-dir)  BENCH_DIR="$2"; shift 2 ;;
    --model)      MODEL="$2"; shift 2 ;;
    --output)     OUTPUT_NAME="$2"; shift 2 ;;
    --lang)       LANG_FILTER="$2"; shift 2 ;;
    --max)        MAX_TASKS="$2"; shift 2 ;;
    --concurrent) CONCURRENT="$2"; shift 2 ;;
    -h|--help)    usage ;;
    *)            echo "Unknown option: $1" >&2; usage ;;
  esac
done

[[ -z "$BENCH_DIR" ]] && { echo "Error: --bench-dir is required" >&2; usage; }

QUERY_FILE="$BENCH_DIR/data/test_data/query.jsonl"
[[ ! -f "$QUERY_FILE" ]] && { echo "Error: query.jsonl not found at $QUERY_FILE" >&2; exit 1; }

OUTPUT_DIR="$BENCH_DIR/data/test_data/raw_data"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/${OUTPUT_NAME}.jsonl"

# Verify claude CLI is available
if ! command -v claude &>/dev/null; then
  echo "Error: 'claude' CLI not found in PATH" >&2
  exit 1
fi

# ── Citation converter ───────────────────────────────────────────────
# Converts our plugin's [n] + Sources appendix format into inline
# markdown links [Title](URL) for FACT scoring compatibility.
convert_citations() {
  local article="$1"

  # Extract the Sources section and build a mapping of [n] -> URL and Title
  # Sources format: N. [URL] — [Title] | [source_type] | [date]
  # or:             N. URL — Title | source_type | date
  local -A url_map
  local -A title_map

  while IFS= read -r line; do
    # Match lines like: 1. [URL] — Title | type | date
    #                or: 1. URL — Title | type | date
    #                or: 1. [URL] - Title
    if [[ "$line" =~ ^[[:space:]]*([0-9]+)\.[[:space:]]+\[?(https?://[^][:space:]]+)\]?[[:space:]]*[—–-][[:space:]]*([^|]+) ]]; then
      local num="${BASH_REMATCH[1]}"
      local url="${BASH_REMATCH[2]}"
      local title="${BASH_REMATCH[3]}"
      # Trim trailing whitespace/pipes from title
      title="${title%%[[:space:]]*|*}"
      title="${title%"${title##*[![:space:]]}"}"
      url_map[$num]="$url"
      title_map[$num]="$title"
    fi
  done <<< "$(echo "$article" | sed -n '/^##[[:space:]]*[Ss]ources/,$ p')"

  # If no sources found, return article as-is
  if [[ ${#url_map[@]} -eq 0 ]]; then
    echo "$article"
    return
  fi

  # Replace [n] citations with [Title](URL) inline
  local result="$article"
  for num in "${!url_map[@]}"; do
    local url="${url_map[$num]}"
    local title="${title_map[$num]}"
    # Escape special regex chars in replacement
    local safe_title="${title//\\/\\\\}"
    safe_title="${safe_title//&/\\&}"
    # Replace [N] with [Title](URL) — use perl for reliability
    result=$(echo "$result" | perl -pe "s/\\[${num}\\]/[${safe_title}](${url})/g" 2>/dev/null || echo "$result")
  done

  echo "$result"
}

# ── Task processing ──────────────────────────────────────────────────
process_task() {
  local id="$1"
  local prompt="$2"
  local lang="$3"
  local task_num="$4"
  local total="$5"

  echo "[${task_num}/${total}] Processing task ${id} (${lang})..." >&2

  # Run our plugin via claude CLI in non-interactive mode
  local raw_article
  raw_article=$(claude -p \
    --model "$MODEL" \
    --append-system-prompt "Use the deep-research skill to perform thorough research. Include URLs in all source citations." \
    "Perform deep research on the following topic and produce a comprehensive report with cited sources including URLs: $prompt" \
    2>/dev/null) || {
    echo "[${task_num}/${total}] FAILED task ${id}" >&2
    return 1
  }

  # Convert [n] citations to inline markdown links for FACT scoring
  local article
  article=$(convert_citations "$raw_article")

  # Escape for JSON: handle newlines, quotes, backslashes, tabs
  local json_prompt json_article
  json_prompt=$(printf '%s' "$prompt" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
  json_article=$(printf '%s' "$article" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

  # Write JSONL entry
  echo "{\"id\": ${id}, \"prompt\": ${json_prompt}, \"article\": ${json_article}}"

  echo "[${task_num}/${total}] Completed task ${id}" >&2
}

# ── Main ─────────────────────────────────────────────────────────────
echo "=== DeepResearch-Bench Adapter ===" >&2
echo "Bench dir:   $BENCH_DIR" >&2
echo "Model:       $MODEL" >&2
echo "Output:      $OUTPUT_FILE" >&2
echo "Language:    $LANG_FILTER" >&2
echo "Concurrent:  $CONCURRENT" >&2
echo "" >&2

# Read and filter tasks
TASKS=()
while IFS= read -r line; do
  task_lang=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('language','en'))")
  if [[ "$LANG_FILTER" == "all" ]] || [[ "$task_lang" == "$LANG_FILTER" ]]; then
    TASKS+=("$line")
  fi
done < "$QUERY_FILE"

TOTAL=${#TASKS[@]}
echo "Found $TOTAL tasks after filtering" >&2

if [[ "$MAX_TASKS" -gt 0 ]] && [[ "$MAX_TASKS" -lt "$TOTAL" ]]; then
  TOTAL=$MAX_TASKS
  echo "Limiting to $TOTAL tasks (--max)" >&2
fi

# Truncate output file
> "$OUTPUT_FILE"

# Process tasks with concurrency control
RUNNING=0
COMPLETED=0
FAILED=0
TMPDIR_WORK=$(mktemp -d)
trap "rm -rf $TMPDIR_WORK" EXIT

for ((i=0; i<TOTAL; i++)); do
  line="${TASKS[$i]}"
  task_id=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['id'])")
  task_prompt=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['prompt'])")
  task_lang=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('language','en'))")
  task_num=$((i + 1))

  # Run in background with concurrency limit
  (
    result_file="$TMPDIR_WORK/result_${task_id}.jsonl"
    if process_task "$task_id" "$task_prompt" "$task_lang" "$task_num" "$TOTAL" > "$result_file"; then
      echo "OK" > "$TMPDIR_WORK/status_${task_id}"
    else
      echo "FAIL" > "$TMPDIR_WORK/status_${task_id}"
    fi
  ) &

  RUNNING=$((RUNNING + 1))

  # Wait when we hit concurrency limit
  if [[ "$RUNNING" -ge "$CONCURRENT" ]]; then
    wait -n 2>/dev/null || true
    RUNNING=$((RUNNING - 1))
  fi
done

# Wait for remaining tasks
wait

# Collect results in order
for ((i=0; i<TOTAL; i++)); do
  line="${TASKS[$i]}"
  task_id=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read())['id'])")
  result_file="$TMPDIR_WORK/result_${task_id}.jsonl"
  status_file="$TMPDIR_WORK/status_${task_id}"

  if [[ -f "$status_file" ]] && [[ "$(cat "$status_file")" == "OK" ]] && [[ -s "$result_file" ]]; then
    cat "$result_file" >> "$OUTPUT_FILE"
    COMPLETED=$((COMPLETED + 1))
  else
    FAILED=$((FAILED + 1))
  fi
done

echo "" >&2
echo "=== Adapter Complete ===" >&2
echo "Completed: $COMPLETED / $TOTAL" >&2
echo "Failed:    $FAILED" >&2
echo "Output:    $OUTPUT_FILE" >&2

if [[ "$FAILED" -gt 0 ]]; then
  echo "WARNING: $FAILED tasks failed. Re-run with --max to retry specific tasks." >&2
fi
