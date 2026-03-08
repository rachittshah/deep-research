#!/usr/bin/env bash
set -euo pipefail

# compare-runs.sh — A/B comparison of two evaluation runs
# Usage: ./tests/compare-runs.sh --baseline tests/runs/RUN_A --candidate tests/runs/RUN_B

BASELINE_DIR=""
CANDIDATE_DIR=""

usage() {
  cat >&2 <<EOF
Usage: $0 --baseline <run-dir> --candidate <run-dir>

Compares two evaluation runs side-by-side.

Options:
  --baseline    Path to baseline run directory (contains scorecard-*.json files)
  --candidate   Path to candidate run directory
  -h, --help    Show this help

Each run directory should contain scorecard-<question-id>.json files with the
judge output format (dimension_scores, composite_score, etc.).
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --baseline)   BASELINE_DIR="$2"; shift 2 ;;
    --candidate)  CANDIDATE_DIR="$2"; shift 2 ;;
    -h|--help)    usage ;;
    *)            echo "Unknown option: $1" >&2; usage ;;
  esac
done

[[ -z "$BASELINE_DIR" ]] && { echo "Error: --baseline is required" >&2; usage; }
[[ -z "$CANDIDATE_DIR" ]] && { echo "Error: --candidate is required" >&2; usage; }
[[ ! -d "$BASELINE_DIR" ]] && { echo "Error: baseline dir not found: $BASELINE_DIR" >&2; exit 1; }
[[ ! -d "$CANDIDATE_DIR" ]] && { echo "Error: candidate dir not found: $CANDIDATE_DIR" >&2; exit 1; }

if ! command -v jq &>/dev/null; then
  echo "Error: 'jq' not found in PATH" >&2
  exit 1
fi

DIMENSIONS="completeness accuracy citation_quality balance coherence source_credibility"

# Collect question IDs from both runs (union, sorted)
ALL_IDS=""
for f in "$BASELINE_DIR"/scorecard-*.json "$CANDIDATE_DIR"/scorecard-*.json; do
  [[ -f "$f" ]] || continue
  qid=$(basename "$f" | sed 's/scorecard-//;s/\.json//')
  ALL_IDS="$ALL_IDS $qid"
done
ALL_IDS=$(echo "$ALL_IDS" | tr ' ' '\n' | sort -u | tr '\n' ' ')

if [[ -z "$ALL_IDS" ]]; then
  echo "Error: no scorecard files found in either run directory" >&2
  exit 1
fi

# Use jq to build the full comparison as JSON, then format with jq
# Build a temp file with all per-question data
TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

echo "[" > "$TMPFILE"
FIRST=true
for qid in $ALL_IDS; do
  BASE_FILE="$BASELINE_DIR/scorecard-${qid}.json"
  CAND_FILE="$CANDIDATE_DIR/scorecard-${qid}.json"

  BASE_JSON="null"
  CAND_JSON="null"
  [[ -f "$BASE_FILE" ]] && BASE_JSON=$(cat "$BASE_FILE")
  [[ -f "$CAND_FILE" ]] && CAND_JSON=$(cat "$CAND_FILE")

  [[ "$FIRST" == "true" ]] && FIRST=false || echo "," >> "$TMPFILE"

  jq -n \
    --arg qid "$qid" \
    --argjson base "$BASE_JSON" \
    --argjson cand "$CAND_JSON" \
    '{id: $qid, baseline: $base, candidate: $cand}' >> "$TMPFILE"
done
echo "]" >> "$TMPFILE"

# Print the comparison table
echo ""
printf "%-10s" "Question"
for dim in $DIMENSIONS; do
  short=$(echo "$dim" | cut -c1-8)
  printf "  %-4s(B) %-4s(C) %-5s(Δ)" "$short" "$short" "$short"
done
printf "  %-6s(B) %-6s(C) %-7s(Δ)\n" "comp" "comp" "comp"
printf '%0.s─' $(seq 1 160)
printf '\n'

# Per-question rows + accumulate totals
TOTAL_BASE_COMP=0
TOTAL_CAND_COMP=0
COMP_N=0

# Per-dimension totals (use positional: 6 dimensions)
DIM_SUM_B="0 0 0 0 0 0"
DIM_SUM_C="0 0 0 0 0 0"
DIM_SUM_D="0 0 0 0 0 0"
DIM_N="0 0 0 0 0 0"

for qid in $ALL_IDS; do
  BASE_FILE="$BASELINE_DIR/scorecard-${qid}.json"
  CAND_FILE="$CANDIDATE_DIR/scorecard-${qid}.json"

  printf "%-10s" "$qid"

  dim_idx=0
  new_sum_b="" new_sum_c="" new_sum_d="" new_n=""
  for dim in $DIMENSIONS; do
    b="—"
    c="—"
    d="—"

    [[ -f "$BASE_FILE" ]] && b=$(jq -r ".dimension_scores.${dim}.score // \"—\"" "$BASE_FILE")
    [[ -f "$CAND_FILE" ]] && c=$(jq -r ".dimension_scores.${dim}.score // \"—\"" "$CAND_FILE")

    old_sb=$(echo "$DIM_SUM_B" | awk -v i=$((dim_idx+1)) '{print $i}')
    old_sc=$(echo "$DIM_SUM_C" | awk -v i=$((dim_idx+1)) '{print $i}')
    old_sd=$(echo "$DIM_SUM_D" | awk -v i=$((dim_idx+1)) '{print $i}')
    old_n=$(echo "$DIM_N" | awk -v i=$((dim_idx+1)) '{print $i}')

    if [[ "$b" != "—" && "$c" != "—" ]]; then
      d=$(echo "$c - $b" | bc)
      old_sb=$(echo "$old_sb + $b" | bc)
      old_sc=$(echo "$old_sc + $c" | bc)
      old_sd=$(echo "$old_sd + $d" | bc)
      old_n=$((old_n + 1))
    fi

    new_sum_b="$new_sum_b $old_sb"
    new_sum_c="$new_sum_c $old_sc"
    new_sum_d="$new_sum_d $old_sd"
    new_n="$new_n $old_n"

    printf "  %5s    %5s   %+5s  " "$b" "$c" "$d"
    dim_idx=$((dim_idx + 1))
  done
  DIM_SUM_B=$(echo "$new_sum_b" | xargs)
  DIM_SUM_C=$(echo "$new_sum_c" | xargs)
  DIM_SUM_D=$(echo "$new_sum_d" | xargs)
  DIM_N=$(echo "$new_n" | xargs)

  # Composite
  bc_val="—"
  cc_val="—"
  cd_val="—"
  [[ -f "$BASE_FILE" ]] && bc_val=$(jq -r '.composite_score // "—"' "$BASE_FILE")
  [[ -f "$CAND_FILE" ]] && cc_val=$(jq -r '.composite_score // "—"' "$CAND_FILE")
  if [[ "$bc_val" != "—" && "$cc_val" != "—" ]]; then
    cd_val=$(echo "$cc_val - $bc_val" | bc)
    TOTAL_BASE_COMP=$(echo "$TOTAL_BASE_COMP + $bc_val" | bc)
    TOTAL_CAND_COMP=$(echo "$TOTAL_CAND_COMP + $cc_val" | bc)
    COMP_N=$((COMP_N + 1))
  fi
  printf "  %6s    %6s   %+7s\n" "$bc_val" "$cc_val" "$cd_val"
done

# Averages row
printf '%0.s─' $(seq 1 160)
printf '\n'
printf "%-10s" "AVG"

dim_idx=0
for dim in $DIMENSIONS; do
  cnt=$(echo "$DIM_N" | awk -v i=$((dim_idx+1)) '{print $i}')
  if [[ "$cnt" -gt 0 ]]; then
    sb=$(echo "$DIM_SUM_B" | awk -v i=$((dim_idx+1)) '{print $i}')
    sc=$(echo "$DIM_SUM_C" | awk -v i=$((dim_idx+1)) '{print $i}')
    sd=$(echo "$DIM_SUM_D" | awk -v i=$((dim_idx+1)) '{print $i}')
    avg_b=$(echo "scale=2; $sb / $cnt" | bc)
    avg_c=$(echo "scale=2; $sc / $cnt" | bc)
    avg_d=$(echo "scale=2; $sd / $cnt" | bc)
    printf "  %5s    %5s   %+5s  " "$avg_b" "$avg_c" "$avg_d"
  else
    printf "  %5s    %5s   %5s  " "—" "—" "—"
  fi
  dim_idx=$((dim_idx + 1))
done

if [[ $COMP_N -gt 0 ]]; then
  avg_bc=$(echo "scale=2; $TOTAL_BASE_COMP / $COMP_N" | bc)
  avg_cc=$(echo "scale=2; $TOTAL_CAND_COMP / $COMP_N" | bc)
  avg_cd=$(echo "scale=2; ($TOTAL_CAND_COMP - $TOTAL_BASE_COMP) / $COMP_N" | bc)
  printf "  %6s    %6s   %+7s\n" "$avg_bc" "$avg_cc" "$avg_cd"
else
  printf "  %6s    %6s   %7s\n" "—" "—" "—"
fi

# Cost comparison
COST_BASE=0
COST_CAND=0
HAS_COST=false
for qid in $ALL_IDS; do
  BASE_FILE="$BASELINE_DIR/scorecard-${qid}.json"
  CAND_FILE="$CANDIDATE_DIR/scorecard-${qid}.json"
  if [[ -f "$BASE_FILE" ]]; then
    val=$(jq -r '.cost_usd // 0' "$BASE_FILE" 2>/dev/null)
    if [[ "$val" != "0" && "$val" != "null" ]]; then
      COST_BASE=$(echo "$COST_BASE + $val" | bc)
      HAS_COST=true
    fi
  fi
  if [[ -f "$CAND_FILE" ]]; then
    val=$(jq -r '.cost_usd // 0' "$CAND_FILE" 2>/dev/null)
    if [[ "$val" != "0" && "$val" != "null" ]]; then
      COST_CAND=$(echo "$COST_CAND + $val" | bc)
      HAS_COST=true
    fi
  fi
done

if [[ "$HAS_COST" == "true" ]]; then
  cost_delta=$(echo "$COST_CAND - $COST_BASE" | bc)
  printf "\nCost: baseline=\$%.2f  candidate=\$%.2f  delta=\$%.2f\n" "$COST_BASE" "$COST_CAND" "$cost_delta"
fi

# Verdict
printf "\n"
if [[ $COMP_N -gt 0 ]]; then
  avg_delta=$(echo "scale=4; ($TOTAL_CAND_COMP - $TOTAL_BASE_COMP) / $COMP_N" | bc)
  verdict=$(echo "$avg_delta" | awk '{
    if ($1 > 0.1) print "BETTER"
    else if ($1 < -0.1) print "WORSE"
    else print "MIXED"
  }')
  printf "Verdict: %s (avg composite delta: %s)\n" "$verdict" "$avg_delta"
else
  printf "Verdict: INCONCLUSIVE (no overlapping questions)\n"
fi
