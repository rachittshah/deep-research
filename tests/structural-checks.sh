#!/usr/bin/env bash
set -euo pipefail

# structural-checks.sh — deterministic, non-LLM checks on a research report
# Usage: ./tests/structural-checks.sh --report path/to/report.md

usage() {
  echo "Usage: $0 --report <path/to/report.md>" >&2
  exit 1
}

REPORT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --report) REPORT="$2"; shift 2 ;;
    *) usage ;;
  esac
done

[[ -z "$REPORT" ]] && usage
[[ ! -f "$REPORT" ]] && { echo "Error: file not found: $REPORT" >&2; exit 1; }

CONTENT=$(cat "$REPORT")

# --- Section checks ---
check_section() {
  local heading="$1"
  if echo "$CONTENT" | grep -qiE "^##\s+${heading}"; then
    echo "true"
  else
    echo "false"
  fi
}

has_executive_summary=$(check_section "Executive Summary")
has_methodology=$(check_section "Methodology")
has_analysis=$(check_section "Analysis")
has_limitations=$(check_section "Limitations")
has_conclusions=$(check_section "Conclusions")
has_sources=$(check_section "Sources")

# Findings: must have ## Findings AND at least one ### subsection under it
has_findings="false"
if echo "$CONTENT" | grep -qiE "^##\s+Findings"; then
  # Extract content from ## Findings to the next ## heading (or EOF)
  findings_block=$(echo "$CONTENT" | sed -n '/^##[[:space:]]*[Ff]indings/,/^## /p' | tail -n +2)
  if echo "$findings_block" | grep -qE "^###\s+"; then
    has_findings="true"
  fi
fi

# --- Citation count: unique [N] references ---
citation_count=$(echo "$CONTENT" | grep -oE '\[[0-9]+\]' | sort -u | wc -l | tr -d ' ')

# --- Source count: numbered entries in Sources section ---
sources_block=$(echo "$CONTENT" | sed -n '/^##[[:space:]]*[Ss]ources/,/^## /p' | tail -n +2)
source_count=$(echo "$sources_block" | grep -cE '^\s*[0-9]+\.' || true)

# --- Unsourced flag count ---
unsourced_count=$(echo "$CONTENT" | grep -coF '[UNSOURCED]' || true)

# --- Word count ---
word_count=$(echo "$CONTENT" | wc -w | tr -d ' ')

# --- URL count in sources section ---
url_count=$(echo "$sources_block" | grep -coE 'https?://' || true)

# --- Determine all_passed ---
all_passed="true"
for s in "$has_executive_summary" "$has_methodology" "$has_findings" "$has_analysis" "$has_limitations" "$has_conclusions" "$has_sources"; do
  [[ "$s" == "false" ]] && all_passed="false"
done
[[ "$unsourced_count" -ne 0 ]] && all_passed="false"
[[ "$word_count" -lt 500 || "$word_count" -gt 10000 ]] && all_passed="false"

# --- Output JSON ---
cat <<EOF
{
  "sections": {
    "executive_summary": ${has_executive_summary},
    "methodology": ${has_methodology},
    "findings": ${has_findings},
    "analysis": ${has_analysis},
    "limitations": ${has_limitations},
    "conclusions": ${has_conclusions},
    "sources": ${has_sources}
  },
  "citation_count": ${citation_count},
  "source_count": ${source_count},
  "unsourced_count": ${unsourced_count},
  "word_count": ${word_count},
  "url_count": ${url_count},
  "all_passed": ${all_passed}
}
EOF
