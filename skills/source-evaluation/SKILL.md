---
name: source-evaluation
description: "Use when evaluating the credibility and reliability of research sources before including them in findings"
---

# Source Evaluation Framework

Credibility scoring framework for evaluating research sources before including them in findings.

## Source Type Taxonomy

| Source Type | Examples | Base Credibility Weight |
|-------------|----------|------------------------|
| **Academic** | Peer-reviewed journals, conference papers, preprints | 0.9 (peer-reviewed) / 0.6 (preprint) |
| **Official** | Government reports, WHO, company official docs, RFCs | 0.85 |
| **News — Major** | Reuters, AP, NYT, BBC, domain-specific trade press | 0.7 |
| **Technical** | Official documentation, specifications, RFCs | 0.8 |
| **News — Specialized** | Industry trade publications, analyst reports | 0.65 |
| **Community** | Blogs, forums, Stack Overflow, Reddit, personal sites | 0.4 |

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
URL: [URL]
Author: [Name / Organization]
Date: [Publication date]
Type: [Academic | Official | News | Technical | Community]
Base Weight: [from taxonomy]
Adjusted Weight: [after evaluation criteria]
Confidence: [Verified | Likely | Unverified | Contradicted]
Key Claims: [What this source contributes]
Notes: [Any caveats, biases, or limitations]
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

When a red flag is detected, downgrade the source weight by 0.2 and note the flag in the source card.

## Quick Evaluation Workflow

1. **Classify** the source type and assign base weight
2. **Check** recency, authority, cross-references, methodology
3. **Adjust** the weight based on evaluation criteria
4. **Assign** confidence level to claims from this source
5. **Flag** any red flags
6. **Record** a source card for the research record
