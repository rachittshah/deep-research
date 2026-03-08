---
name: source-evaluation
description: "Use when evaluating the credibility and reliability of research sources before including them in findings"
---

# Source Evaluation Framework

Credibility scoring framework for evaluating research sources before including them in findings.

## Source Hierarchy (Strict Weights)

Sources are ranked by a strict hierarchy. Every source used in research MUST be classified into one of these tiers. The weights determine how much a source can contribute to a claim's confidence.

| Tier | Source Type | Examples | Weight |
|------|-------------|----------|--------|
| 1 | **Peer-reviewed academic** | Journals (Nature, Science, Lancet), conference proceedings with peer review | **1.0** |
| 2 | **Government / International org** | Official government reports, WHO, UN, World Bank, OECD, central bank publications, RFCs | **0.9** |
| 3 | **Institutional reports** | University research centers, established think tanks (Brookings, RAND), foundation reports | **0.8** |
| 4 | **Technical documentation** | Official product/API documentation, technical specifications | **0.75** |
| 5 | **Major news outlets** | Reuters, AP, NYT, BBC, FT, domain-specific trade press with editorial standards | **0.6** |
| 6 | **Industry / analyst reports** | Gartner, McKinsey, Statista (with methodology), trade publications | **0.5** |
| 7 | **Preprints** | arXiv, SSRN, medRxiv (not yet peer-reviewed) | **0.45** |
| 8 | **Blogs / aggregators / community** | Blogs, forums, Stack Overflow, Reddit, personal sites | **0.3** |
| 9 | **Wikipedia** | Any Wikipedia article in any language | **0.0** |

### Minimum Source Quality Threshold

**At least 50% of sources in any research report must have weight >= 0.8** (Tiers 1-3). If this threshold cannot be met, the report MUST include a prominent limitations note explaining the source quality gap.

### Wikipedia Ban (ABSOLUTE)

Wikipedia is **NEVER** an acceptable source. Weight = 0.0. When you encounter relevant information on Wikipedia:
1. **Trace to primary sources** — follow Wikipedia's own footnotes/references to the original source
2. **Cite the primary source directly** — never cite Wikipedia itself
3. If the primary source is inaccessible, note the claim as `[UNVERIFIED — Wikipedia-only]` and deprioritize it
4. This applies to ALL Wikipedia variants: en.wikipedia.org, other language editions, Simple Wikipedia, Wikidata

### Low-Credibility Source Blacklist

The following source categories are classified as **low credibility** (weight 0.3 or below) and require corroboration from a Tier 1-3 source before any claim from them can be stated as fact:

| Category | Examples | Why Low Credibility |
|----------|----------|---------------------|
| **Commodity aggregators** | Selina Wamucii, Tridge, commodity price scraping sites | Unverified data collection, no methodology disclosure |
| **Market-size estimators** | Mordor Intelligence, Grand View Research, Allied Market Research | Pay-to-play reports, inflated TAM estimates, no peer review |
| **Ed-tech / AI list blogs** | DigitalDefynd, AllAboutAI, AnalyticsInsight, Unite.AI | SEO-optimized content, no editorial standards, frequent inaccuracies |
| **Content farms** | Sites with no bylines, mass-produced articles, AI-generated content | No accountability, no fact-checking |
| **Press release wires** | PR Newswire, BusinessWire (as sole source) | Company-controlled messaging, not independently verified |

When using a low-credibility source:
- It MUST be corroborated by at least one Tier 1-3 source
- If uncorroborated, flag the claim as `[LOW-CREDIBILITY SOURCE — UNCORROBORATED]`
- Never present low-credibility-sourced claims as established facts

Weights are starting points. Adjust based on evaluation criteria below.

## Evaluation Criteria

### 1. Recency

| Factor | Score Modifier |
|--------|----------------|
| Published within 1 year | +0.1 (if freshness matters for topic) |
| Published 1-3 years ago | 0 |
| Published 3-5 years ago | -0.1 (for fast-moving fields) |
| Published 5+ years ago | -0.2 (for fast-moving fields) |
| Seminal/foundational work | No penalty regardless of age |

Ask: Is freshness critical for this topic? (e.g., AI research = yes, historical analysis = no)

### 2. Authority

| Factor | Score Modifier |
|--------|----------------|
| Known domain expert with track record | +0.15 |
| Affiliated with reputable institution | +0.1 |
| Relevant credentials stated | +0.05 |
| Anonymous or no credentials | -0.15 |
| Known bias or conflict of interest | -0.2 |

### 3. Cross-Reference Score

| Factor | Score Modifier |
|--------|----------------|
| 3+ independent sources corroborate | +0.15 |
| 1-2 independent sources corroborate | +0.05 |
| No corroboration found | -0.1 |
| Other sources contradict | -0.2 |

### 4. Methodology (for research sources)

| Factor | Score Modifier |
|--------|----------------|
| Clear methodology, reproducible | +0.1 |
| Peer-reviewed methodology | +0.1 |
| Sample size appropriate | +0.05 |
| Methodology unclear or absent | -0.15 |
| Known methodological issues | -0.25 |

## Confidence Levels

After scoring, assign a confidence level to each claim:

| Level | Criteria | How to Present |
|-------|----------|----------------|
| **Verified** | 3+ independent authoritative sources agree | State as established fact with citations |
| **Likely** | 1-2 authoritative sources, no contradictions | State with attribution ("According to...") |
| **Unverified** | Single source, no corroboration | Flag explicitly ("One source suggests...") |
| **Contradicted** | Authoritative sources disagree | Present the disagreement with both sides |

## Source Card Template

For each source used in research, create a source card:

```
Source: [Title]
URL: [URL — must be actually fetched, never fabricated]
Author: [Name / Organization]
Date: [Publication date]
Tier: [1-9 from Source Hierarchy]
Type: [Peer-reviewed | Government | Institutional | Technical | News | Industry | Preprint | Blog | Wikipedia]
Base Weight: [from hierarchy table]
Adjusted Weight: [after evaluation criteria]
Confidence: [Verified | Likely | Unverified | Contradicted]
Temporal Check: [PASS | TEMPORAL GAP: details]
Key Claims: [What this source contributes]
Notes: [Any caveats, biases, or limitations]
Blacklisted: [Yes/No — if Yes, corroboration source #]
```

## Red Flags

Watch for and flag these issues:

1. **Outdated sources presented as current** — A 2019 source cited for 2024 market data
2. **Single-source claims presented as consensus** — "It is widely known that..." backed by one blog post
3. **Circular citations** — Source A cites Source B which cites Source A (or both cite a single original)
4. **Self-serving sources** — Company's own blog as evidence of their product's superiority
5. **Survivorship bias** — Only successful case studies, no failures mentioned
6. **Appeal to authority without substance** — "Expert says X" without methodology or evidence
7. **Predatory journals** — Papers from journals with no real peer review process
8. **Undated content** — No publication date, impossible to assess recency
9. **Wikipedia pass-through** — Information clearly sourced from Wikipedia without tracing to primary references
10. **URL not fetched** — Source URL was never actually retrieved during the research session (hallucinated citation)
11. **Temporal impossibility** — Source publication date is earlier than the data year it claims to report

When a red flag is detected, downgrade the source weight by 0.2 and note the flag in the source card. Red flags #9-11 are **hard rejections** — the source must be replaced, not merely downgraded.

## Temporal Consistency Check

Before accepting a source for a claim, verify temporal alignment:

1. **Publication date must be plausible for the data** — A source published in 2022 cannot contain 2025 data. If a source claims to report data from a year after its publication, reject it.
2. **Data vintage must match the claim** — If the research question asks about "2024 trends," a source with 2019 data is insufficient unless used explicitly for historical comparison.
3. **Projection vs. actuals** — Clearly distinguish between forward-looking projections/forecasts and actual observed data. A 2021 source projecting 2025 values is NOT the same as a 2025 source reporting 2025 actuals.
4. **Flag temporal mismatches** — If the best available source has a temporal gap, note it: `[TEMPORAL GAP: source from YYYY, claim about YYYY]`

## Source Quality Audit

Before finalizing a research report, run this audit:

1. Count sources by tier and verify >= 50% are Tier 1-3
2. Verify zero Wikipedia citations appear anywhere
3. Verify all low-credibility sources are corroborated
4. Verify no temporal consistency violations
5. If any check fails, the report cannot be delivered until resolved

## Quick Evaluation Workflow

1. **Verify URL was fetched** — if the URL was not actually retrieved during this session, STOP. Do not evaluate; the source cannot be used. (See citation-tracking skill, Anti-Hallucination Safeguards.)
2. **Check Wikipedia ban** — if the URL contains wikipedia.org, STOP. Trace to primary source instead.
3. **Check blacklist** — if the source matches the Low-Credibility Source Blacklist, note it and require corroboration.
4. **Classify** the source type and assign base weight from the hierarchy table.
5. **Temporal check** — verify publication date is plausible for the data claimed.
6. **Check** recency, authority, cross-references, methodology modifiers.
7. **Adjust** the weight based on evaluation criteria.
8. **Assign** confidence level to claims from this source.
9. **Flag** any red flags (hard-reject flags #9-11 block the source entirely).
10. **Record** a source card for the research record.
