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

Source types: peer-reviewed journal, government report, news outlet, industry blog, corporate whitepaper, social media, personal blog, wiki, official documentation, press release

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
6. Never cite a source you have not actually read and verified.

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
