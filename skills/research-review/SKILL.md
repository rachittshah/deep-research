---
name: research-review
description: "Use as the final quality gate before delivering a research report to the user"
---

# Research Review

Quality gate — the final check before delivering a research report. No report ships without passing this review.

## Review Checklist

Run through every item. Mark each as PASS, WARN, or FAIL:

- [ ] **Original question is fully answered** — The report directly addresses what the user asked. Partial answers are flagged.
- [ ] **All planned angles were covered** — Cross-reference the research plan. Every angle that was planned has findings in the report.
- [ ] **Executive summary accurately reflects findings** — The summary does not overstate, understate, or misrepresent what the body contains.
- [ ] **Every factual claim has citation(s)** — Run orphan detection from citation-tracking. Zero `[UNSOURCED]` flags allowed.
- [ ] **No [UNSOURCED] flags remain** — Search the entire document for `[UNSOURCED]`. If any exist, the review fails.
- [ ] **Contradictions are explicitly addressed** — Disagreements between sources are visible in the report, not hidden or silently resolved.
- [ ] **Multiple perspectives are represented** — The report is not one-sided. Minority views are acknowledged proportionally.
- [ ] **Limitations section is honest and specific** — Vague statements like "more research is needed" without specifics are insufficient.
- [ ] **Source credibility scores are reasonable** — Scores reflect actual source quality. No inflated scores for weak sources.
- [ ] **Report is coherent and well-structured** — Follows the required report structure. Narrative flows logically.
- [ ] **No hallucinated citations** — For each citation, the source actually says what the claim says it says. Run citation verification from citation-tracking.

## Severity Levels

### BLOCK — Must fix before delivery

These issues prevent the report from being delivered. Return to the relevant phase and fix them.

- Unsourced core claims (factual assertions central to the answer without any citation)
- Unanswered central question (the report does not address what the user asked)
- Hallucinated citations (a source is cited but does not actually support the claim)
- Missing sections (any required section from the report structure is absent)
- Fabricated data (statistics or facts that cannot be traced to any source)

**Action:** Identify which phase failed (planning, research, synthesis, citation) and return to that phase. Do not attempt to patch — re-do the work properly.

### WARN — Note in limitations

These issues weaken the report but do not prevent delivery. Document them in the limitations section.

- Minor gaps in coverage (a secondary angle was not fully explored)
- Single-perspective sections (a theme has sources from only one viewpoint)
- Weak sources (a key claim relies on a source with credibility score below 5/10)
- Dated sources (key findings rely on sources older than 2 years without noting this)
- Unverifiable sources (URLs that returned errors; source content could not be re-checked)

**Action:** Add a specific note in the Limitations section explaining the weakness. Example: "The market size estimate relies on a single industry report from 2024; more recent data was not available."

### INFO — Optional cleanup

These issues are minor and do not affect report quality materially. Fix if time permits.

- Verbose sections that could be tightened
- Inconsistent formatting between sections
- Redundant citations (same source cited multiple times for the same claim)
- Style inconsistencies (mixing tenses, inconsistent heading levels)

**Action:** Fix if straightforward. Otherwise, leave as-is.

## Review Process

### Step 1: Structure Check
Verify all required sections are present:
1. Executive Summary
2. Methodology
3. Findings (organized by theme)
4. Analysis
5. Limitations
6. Conclusions
7. Sources

If any section is missing: **BLOCK**.

### Step 2: Citation Audit
1. Run orphan detection — scan every factual claim for citations.
2. Run citation verification — confirm each citation actually supports its claim.
3. Check for citation anti-patterns (stuffing, laundering, broken links).
4. Count total sources and verify the source appendix is complete.

If unsourced core claims or hallucinated citations found: **BLOCK**.

### Step 3: Content Quality
1. Read the original question and the executive summary side by side. Does the summary answer the question?
2. Check that findings are organized by theme, not by source agent.
3. Verify contradictions are surfaced and explained, not hidden.
4. Confirm multiple perspectives are represented.
5. Read the limitations section — is it specific and honest?

If central question unanswered: **BLOCK**.
If single-perspective or hidden contradictions: **WARN**.

### Step 4: Coherence Check
1. Read the report from top to bottom.
2. Verify logical flow: methodology explains what was done, findings present what was found, analysis interprets findings, conclusions follow from analysis.
3. Check that the executive summary is consistent with the conclusions.
4. Verify no contradictions between sections.

If major logical gaps: **BLOCK**.
If minor flow issues: **INFO**.

## Approval Format

After completing all steps, issue one of:

### Passed
```
REVIEW PASSED

Checklist: 11/11 items passed
Sources: N total, average credibility M/10
Confidence: [High/Medium/Low] overall
Notes: [any INFO items or minor observations]
```

### Blocked
```
REVIEW BLOCKED

BLOCK issues (must fix):
- [issue 1]: [description and which phase to revisit]
- [issue 2]: [description and which phase to revisit]

WARN issues (note in limitations):
- [issue 1]: [description]

Recommended action: [specific guidance on what to fix and how]
```

## Re-Review After Fixes

When a blocked report is returned after fixes:

1. Re-check ONLY the items that were flagged — do not re-run the entire review unless the fixes were extensive.
2. Verify the fix actually resolves the issue (not just a superficial patch).
3. If new issues were introduced by the fix, flag them.
4. Issue a new approval or block decision.
