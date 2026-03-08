#!/usr/bin/env bash
set -euo pipefail

# extract-questions.sh — Utility to inspect DeepResearch-Bench's query.jsonl
#
# Prints a summary: counts by language, counts by topic, and a listing
# of all task IDs with the first 80 chars of their prompt.
#
# Usage:
#   ./tests/deepresearch-bench/extract-questions.sh --bench-dir /path/to/deep_research_bench

BENCH_DIR=""

usage() {
  cat >&2 <<EOF
Usage: $0 --bench-dir <path>

Options:
  --bench-dir PATH    Path to cloned deep_research_bench repo
  -h, --help          Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bench-dir)  BENCH_DIR="$2"; shift 2 ;;
    -h|--help)    usage ;;
    *)            echo "Unknown option: $1" >&2; usage ;;
  esac
done

[[ -z "$BENCH_DIR" ]] && { echo "Error: --bench-dir is required" >&2; usage; }

QUERY_FILE="$BENCH_DIR/data/test_data/query.jsonl"
[[ ! -f "$QUERY_FILE" ]] && { echo "Error: query.jsonl not found at $QUERY_FILE" >&2; exit 1; }

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 not found in PATH" >&2
  exit 1
fi

python3 - "$QUERY_FILE" <<'PYEOF'
import json
import sys
from collections import Counter

query_file = sys.argv[1]

tasks = []
with open(query_file, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        tasks.append(json.loads(line))

total = len(tasks)
print(f"=== DeepResearch-Bench: {total} tasks ===")
print()

# Count by language
lang_counts = Counter(t.get("language", "unknown") for t in tasks)
print("--- By Language ---")
for lang, count in sorted(lang_counts.items()):
    print(f"  {lang}: {count}")
print()

# Count by topic (field may be 'topic', 'category', 'domain', or absent)
topic_field = None
for candidate in ("topic", "category", "domain", "type"):
    if any(candidate in t for t in tasks):
        topic_field = candidate
        break

if topic_field:
    topic_counts = Counter(t.get(topic_field, "unknown") for t in tasks)
    print(f"--- By {topic_field.title()} ---")
    for topic, count in sorted(topic_counts.items(), key=lambda x: -x[1]):
        print(f"  {topic}: {count}")
    print()
else:
    print("--- No topic/category field found in tasks ---")
    print()

# List all fields found (for debugging/exploration)
all_fields = set()
for t in tasks:
    all_fields.update(t.keys())
print(f"--- Fields: {', '.join(sorted(all_fields))} ---")
print()

# List all tasks
print("--- Task Listing ---")
print(f"{'ID':>5}  {'Lang':>4}  Prompt (first 80 chars)")
print(f"{'---':>5}  {'----':>4}  {'-' * 80}")
for t in tasks:
    tid = t.get("id", "?")
    lang = t.get("language", "?")
    prompt = t.get("prompt", "")
    # Truncate to 80 chars
    prompt_short = prompt[:80].replace("\n", " ")
    if len(prompt) > 80:
        prompt_short += "..."
    print(f"{tid:>5}  {lang:>4}  {prompt_short}")
PYEOF
