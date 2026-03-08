#!/usr/bin/env bash
set -euo pipefail

# run-bench.sh — Run the full DeepResearch-Bench evaluation (RACE + FACT)
# after the adapter has produced output.
#
# Usage:
#   ./tests/deepresearch-bench/run-bench.sh \
#     --bench-dir /path/to/deep_research_bench \
#     --model-name our-plugin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"

# Defaults
BENCH_DIR=""
MODEL_NAME="our-plugin"

usage() {
  cat >&2 <<EOF
Usage: $0 --bench-dir <path> [options]

Required:
  --bench-dir PATH       Path to cloned deep_research_bench repo

Options:
  --model-name NAME      Model name matching adapter output (default: our-plugin)
  -h, --help             Show this help
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bench-dir)    BENCH_DIR="$2"; shift 2 ;;
    --model-name)   MODEL_NAME="$2"; shift 2 ;;
    -h|--help)      usage ;;
    *)              echo "Unknown option: $1" >&2; usage ;;
  esac
done

[[ -z "$BENCH_DIR" ]] && { echo "Error: --bench-dir is required" >&2; usage; }

# ── Verify prerequisites ─────────────────────────────────────────────
echo "=== DeepResearch-Bench Evaluation ===" >&2
echo "Bench dir:   $BENCH_DIR" >&2
echo "Model name:  $MODEL_NAME" >&2
echo "" >&2

# Check API keys
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "Error: GEMINI_API_KEY not set (required for RACE evaluation)" >&2
  exit 1
fi

if [[ -z "${JINA_API_KEY:-}" ]]; then
  echo "Error: JINA_API_KEY not set (required for FACT citation scraping)" >&2
  exit 1
fi

# Check data file exists
DATA_FILE="$BENCH_DIR/data/test_data/raw_data/${MODEL_NAME}.jsonl"
if [[ ! -f "$DATA_FILE" ]]; then
  echo "Error: Adapter output not found: $DATA_FILE" >&2
  echo "Run adapter.sh first to generate this file." >&2
  exit 1
fi

ENTRY_COUNT=$(wc -l < "$DATA_FILE" | tr -d ' ')
echo "Found $ENTRY_COUNT entries in $DATA_FILE" >&2
echo "" >&2

# Check bench repo has required scripts
for script in deepresearch_bench_race.py; do
  if [[ ! -f "$BENCH_DIR/$script" ]]; then
    echo "Error: Expected $script in bench dir. Is this the correct repo?" >&2
    exit 1
  fi
done

mkdir -p "$RESULTS_DIR"

# ── RACE Evaluation ──────────────────────────────────────────────────
echo "=== Running RACE Evaluation ===" >&2
echo "(Uses Gemini 2.5 Pro as judge across 4 dimensions)" >&2
echo "" >&2

cd "$BENCH_DIR"

RACE_LOG="$RESULTS_DIR/race-${MODEL_NAME}.log"
python deepresearch_bench_race.py "$MODEL_NAME" 2>&1 | tee "$RACE_LOG" >&2

# Copy RACE results if they exist
RACE_RESULTS="$BENCH_DIR/data/test_data/race_results"
if [[ -d "$RACE_RESULTS" ]]; then
  cp -r "$RACE_RESULTS" "$RESULTS_DIR/race_results_${MODEL_NAME}" 2>/dev/null || true
fi

echo "" >&2
echo "RACE evaluation complete. Log: $RACE_LOG" >&2

# ── FACT Evaluation ──────────────────────────────────────────────────
echo "" >&2
echo "=== Running FACT Evaluation ===" >&2
echo "(Extract → Deduplicate → Scrape → Validate → Stat)" >&2
echo "" >&2

FACT_LOG="$RESULTS_DIR/fact-${MODEL_NAME}.log"

# FACT pipeline stages
echo "  [1/5] Extracting citations..." >&2
python -m utils.extract "$MODEL_NAME" 2>&1 | tee -a "$FACT_LOG" >&2

echo "  [2/5] Deduplicating citations..." >&2
python -m utils.deduplicate "$MODEL_NAME" 2>&1 | tee -a "$FACT_LOG" >&2

echo "  [3/5] Scraping cited pages (uses Jina API)..." >&2
python -m utils.scrape "$MODEL_NAME" 2>&1 | tee -a "$FACT_LOG" >&2

echo "  [4/5] Validating citations against scraped content..." >&2
python -m utils.validate "$MODEL_NAME" 2>&1 | tee -a "$FACT_LOG" >&2

echo "  [5/5] Computing citation statistics..." >&2
python -m utils.stat "$MODEL_NAME" 2>&1 | tee -a "$FACT_LOG" >&2

# Copy FACT results if they exist
FACT_RESULTS="$BENCH_DIR/data/test_data/fact_results"
if [[ -d "$FACT_RESULTS" ]]; then
  cp -r "$FACT_RESULTS" "$RESULTS_DIR/fact_results_${MODEL_NAME}" 2>/dev/null || true
fi

echo "" >&2
echo "FACT evaluation complete. Log: $FACT_LOG" >&2

# ── Summary ──────────────────────────────────────────────────────────
echo "" >&2
echo "========================================" >&2
echo "  Evaluation Complete: $MODEL_NAME" >&2
echo "========================================" >&2
echo "" >&2
echo "Results saved to: $RESULTS_DIR/" >&2
echo "" >&2
echo "Score interpretation:" >&2
echo "  RACE: 50 = parity with Gemini 2.5 Pro reference" >&2
echo "         >50 = better than reference" >&2
echo "         <50 = worse than reference" >&2
echo "  FACT: Citation accuracy = % of citations that are verifiable" >&2
echo "        Effective citations = total valid, unique cited sources" >&2
echo "" >&2

# Print results files
echo "Result files:" >&2
ls -la "$RESULTS_DIR"/ >&2 2>/dev/null || true
