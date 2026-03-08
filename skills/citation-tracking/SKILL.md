---
name: citation-tracking
description: "Use when tracking source provenance and generating inline citations for research findings"
---

# Citation Tracking

Provenance tracking and inline citation system for research findings. Every factual claim must be traceable to its source.

## Citation Format

### Inline Citations

Use superscript-style references after claims:

- Single source: `[claim text]^[n]` where `n` is the source number
- Multiple sources: `[claim text]^[1,3,7]`
- Direct quotes: `"quoted text"^[n, Section 2.3]` (must include page/section reference)

### Source Appendix

At the end of every research report, include a numbered source list:

```
## Sources

1. **Title of Article** — Author Name
   URL: https://example.com/article
   Date: 2026-01-15 | Accessed: 2026-03-08
   Source Type: peer-reviewed journal | Credibility: 9/10

2. **Title of Blog Post** — Author Name
   URL: https://example.com/blog
   Date: 2025-11-20 | Accessed: 2026-03-08
   Source Type: industry blog | Credibility: 6/10
```

Source types: peer-reviewed journal, government report, news outlet, industry blog, corporate whitepaper, social media, personal blog, official documentation, press release

**IMPORTANT**: "wiki" is NOT a valid source type. Wikipedia sources are banned — see source-evaluation skill. The credibility score must align with the source hierarchy weights defined in the source-evaluation skill (Tier 1 = 10/10, Tier 8 = 3/10, Tier 9/Wikipedia = 0/10).

## Provenance Chain

For each citation, maintain a full provenance record:

1. **Original URL** — the exact page where the information was found
2. **Extracted passage** — the exact text from the source that supports the claim (quote it verbatim)
3. **Access date** — when the source was retrieved
4. **Researcher agent** — which subagent found this source (e.g., "researcher-angle-1")
5. **Credibility score** — 1-10 rating based on source evaluation skill

Format:

```
### Provenance: Source [n]
- URL: <url>
- Passage: "<exact quoted text from source>"
- Accessed: <date>
- Found by: <agent identifier>
- Credibility: <score>/10
```

## Rules

1. **Every factual claim MUST have at least one citation.** No exceptions.
2. Claims without citations get flagged as `[UNSOURCED]` and must be resolved before report delivery.
3. Opinions, analysis, and synthesis by the research system itself do not require citations, but the underlying facts they draw on do.
4. When multiple sources support the same claim, cite all of them: `[claim]^[1,3,7]`
5. Direct quotes MUST include a page number, section reference, or paragraph indicator.
6. **Never cite a source you have not actually read and verified.** If you did not fetch and read the actual page content during this research session, you MUST NOT cite it. No exceptions — this is the #1 anti-hallucination rule.
7. **URL verification**: Every URL in the Sources appendix must correspond to a page that was actually fetched (via WebFetch or equivalent) during the research session. Do not reconstruct URLs from memory or guess at URL patterns.
8. **No Wikipedia citations**: Wikipedia URLs must never appear in the Sources appendix. See source-evaluation skill for the Wikipedia ban.

## Bidirectional Citation-Source Check

Before finalizing any report, verify bidirectional integrity:

1. **Forward check (text → sources)**: Every `^[n]` reference in the report body must map to a numbered entry in the Sources appendix. If `^[5]` appears in text, source #5 must exist.
2. **Backward check (sources → text)**: Every numbered source in the Sources appendix must be referenced by at least one `^[n]` in the report body. If source #5 exists but is never cited, it is an orphan source — either cite it or remove it.
3. **No gaps in numbering**: Sources must be numbered sequentially (1, 2, 3...) with no gaps. If source #3 is removed, renumber #4 onward.
4. Flag violations: `[ORPHAN SOURCE: #n never cited]` or `[DANGLING REF: ^[n] has no source entry]`

## Temporal Consistency for Citations

Each citation must pass a temporal plausibility check:

1. **publication_year >= earliest_data_year**: A source's publication date must be equal to or later than the earliest year of data it claims to report. A 2021 paper cannot report 2023 actual statistics.
2. **Distinguish projections from actuals**: If a source published in 2022 discusses 2025 figures, those are projections/forecasts, not observed data. Label them as such: `[PROJECTION from YYYY source]`
3. **Flag stale data**: If the research question concerns recent events (last 1-2 years), flag citations older than 3 years: `[STALE: published YYYY]`

## Anti-Hallucination Safeguards

Citation hallucination — generating plausible-looking but fabricated citations — is the most dangerous failure mode. Enforce these safeguards:

1. **Fetched-content requirement**: Only cite URLs whose content you actually retrieved and read during this session. If you "know" a fact but didn't fetch a source for it in this session, either fetch a source now or mark it `[UNSOURCED]`.
2. **No URL fabrication**: Never construct a URL based on what you think a source's URL might be. Only use URLs returned by WebSearch or followed via links in fetched pages.
3. **No title fabrication**: The source title in the appendix must match the actual page title or article title from the fetched content, not a guess.
4. **No author fabrication**: If the author is not clearly stated on the page, use the organization name or "Unknown author" — never guess.
5. **Passage-quote requirement**: The provenance chain must include an exact quoted passage from the source. If you cannot quote the relevant passage, you did not read the source carefully enough.

## Orphan Detection

Before finalizing any report, scan for orphan assertions — factual claims that lack citations:

1. Read every sentence in the findings and analysis sections.
2. For each factual assertion (statistics, dates, named events, attributed claims), verify a citation exists.
3. Flag any uncited factual assertion as `[UNSOURCED]`.
4. Report the count: "Orphan scan: found N unsourced assertions."
5. If N > 0, the report MUST NOT be delivered until all are resolved (either cite them or remove them).

## Citation Verification

For each citation, verify accuracy — the source must actually say what the claim says:

1. Re-read the extracted passage from the provenance chain.
2. Compare the claim text to the extracted passage.
3. Confirm the passage genuinely supports the specific claim (not just topically related).
4. If verification fails, flag as `[MISATTRIBUTED]` and find the correct source or remove the claim.

Verification statuses:
- **VERIFIED** — passage directly supports the claim
- **PARTIAL** — passage is related but does not fully support the claim; needs additional source
- **MISATTRIBUTED** — passage does not support the claim; citation is incorrect
- **UNVERIFIABLE** — original source is no longer accessible; note in limitations

## Anti-Patterns to Detect and Reject

### Citation Stuffing
Adding irrelevant or tangentially related sources to inflate the citation count. Every citation must directly support the specific claim it is attached to.

**Detection:** If removing a citation would not weaken the claim, it is likely stuffing. Remove it.

### Citation Laundering
Citing a secondary source (e.g., a blog summarizing a study) instead of the primary source (the study itself). Always prefer the primary source.

**Detection:** If source A says "according to [study B]..." then cite study B directly, not source A. If study B is inaccessible, cite source A but note it is a secondary source.

### Broken Links
Sources whose URLs no longer resolve. These weaken report credibility.

**Detection:** If a URL returned an error during research, flag it. In the source appendix, mark as `[LINK DEAD]` and note the access date when it was last working. If possible, find an archived version.

## Citation Density Guidelines

- Executive summary: key claims cited, not every sentence
- Findings sections: every factual claim cited
- Analysis sections: underlying facts cited; interpretive statements attributed to the research process
- Limitations: cite sources that informed the limitations assessment

## Pre-Delivery Citation Checklist

Run ALL checks before delivering any research report. If any check fails, the report is blocked.

- [ ] **Orphan scan**: Zero `[UNSOURCED]` assertions remain
- [ ] **Bidirectional check**: Every ^[n] maps to a source; every source maps to at least one ^[n]
- [ ] **Sequential numbering**: No gaps in source numbering
- [ ] **URL verification**: Every URL in Sources was actually fetched during this session
- [ ] **No Wikipedia**: Zero wikipedia.org URLs in Sources
- [ ] **No URL fabrication**: No URLs constructed from memory
- [ ] **Temporal consistency**: Every source passes publication_year >= earliest_data_year
- [ ] **Projection labels**: All forward-looking data labeled `[PROJECTION]`
- [ ] **Anti-hallucination**: Every source has a quoted passage in the provenance chain
- [ ] **Title/author accuracy**: Titles and authors match fetched content exactly
- [ ] **Misattribution scan**: Every citation's passage actually supports its claim
- [ ] **No citation laundering**: Primary sources preferred over secondary summaries
