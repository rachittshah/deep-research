---
name: research-synthesis
description: "Use when combining findings from multiple research agents into a coherent, balanced report"
---

# Research Synthesis

Multi-source synthesis methodology. This is NOT concatenation — it is genuine synthesis: finding patterns, resolving tensions, and building a coherent narrative from diverse sources and perspectives.

## Synthesis Methodology

### 1. Group Findings by Theme, Not by Source Agent

Never structure a report as "Agent 1 found X, Agent 2 found Y." Instead:

1. Collect all findings from all researcher agents.
2. Identify recurring themes, topics, and concepts across sources.
3. Create thematic groups (e.g., "Market Size Estimates," "Regulatory Landscape," "Technical Challenges").
4. Place each finding into its thematic group regardless of which agent found it.
5. If a finding spans multiple themes, reference it in each relevant section.

### 2. Identify Consensus Points

For each theme, determine what most sources agree on:

- Flag claims that appear in 3+ independent sources as **high-consensus**.
- Flag claims that appear in 2 sources as **moderate-consensus**.
- Flag claims from a single source as **single-source** (note in the text).
- Weight consensus by source credibility — three low-credibility sources agreeing is weaker than one high-credibility source.

### 3. Highlight Areas of Disagreement

When sources contradict each other:

- Invoke the contradiction-detection skill to classify the contradiction.
- Present both (or all) positions clearly and fairly.
- Explain possible reasons for the disagreement (different methodologies, different time periods, different definitions, different interests).
- Do NOT silently pick one side. Let the reader see the full picture.

### 4. Weight Claims by Confidence and Credibility

Assign a confidence level to each synthesized finding:

- **High confidence**: Multiple high-credibility sources agree; evidence is direct and recent.
- **Medium confidence**: Some credible sources support it; evidence is indirect or dated.
- **Low confidence**: Single source, low credibility, or conflicting evidence.

State confidence levels explicitly in the report: "With high confidence, we find that..."

### 5. Present Multiple Perspectives Fairly

- Do not let the volume of sources on one side dominate if quality favors the other.
- Give proportional weight based on source quality, not source count.
- Acknowledge when the research team's own perspective may be limited.

## Report Structure

Every synthesized research report MUST follow this structure:

### Executive Summary
- 3-5 bullet points capturing the key findings
- Each bullet should be a complete, standalone insight
- Include confidence level for each key finding
- This section alone should answer the user's core question

### Methodology
- What question was researched
- How many sources were consulted
- What angles/perspectives were explored
- What tools and approaches were used
- Time span of sources (oldest to newest)

### Findings
- Organized by theme (NOT by source agent)
- Each theme gets its own subsection
- Within each theme: consensus first, then disagreements, then outlier claims
- Every factual claim has inline citations (invoke citation-tracking)
- Confidence levels stated for key claims

### Analysis
- What the findings mean in context
- Implications for the user's question
- Connections between themes that aren't obvious
- Trends or patterns across the data
- Second-order effects and downstream consequences

### Limitations
- What the research could NOT determine
- Potential biases in the source material
- Gaps in coverage (geographic, temporal, demographic)
- Areas where more research would be valuable
- Be honest and specific — vague limitations are useless

### Conclusions
- Direct answer to the original question
- Actionable takeaways (what should the reader do with this information?)
- Ranked recommendations if applicable
- Suggested follow-up questions for deeper research

### Sources
- Full citation appendix following citation-tracking format
- Organized by source number
- Include credibility scores

## Quality Checks

Before delivering a synthesized report, verify:

### Balance
- Are all discovered perspectives represented proportionally to their credibility?
- Does any single source dominate the narrative without justification?
- Are minority viewpoints acknowledged even if the consensus disagrees?

### Completeness
- Does the report answer the original question directly?
- Are there obvious angles that were not explored?
- Does the methodology section accurately describe what was done?

### Coherence
- Does the narrative flow logically from one theme to the next?
- Are transitions between sections smooth?
- Does the analysis follow from the findings (no unsupported leaps)?
- Does the conclusion follow from the analysis?

### Citation Integrity
- Is every factual claim sourced?
- Run orphan detection from citation-tracking skill.
- Verify no citation stuffing or laundering.

## Anti-Patterns to Detect and Reject

### Selection Bias
Presenting only evidence that confirms a particular conclusion while ignoring contradictory evidence. All relevant findings must be included, especially those that complicate the picture.

**Detection:** After drafting, ask: "Is there any finding from the research that contradicts this narrative?" If yes, include it.

### False Balance
Giving equal weight to fringe views and well-supported mainstream positions. A single contrarian blog post does not deserve equal space with multiple peer-reviewed studies.

**Detection:** Compare source credibility scores. If one side is supported by 8+/10 sources and the other by 3/10 sources, weight accordingly and explain why.

### Synthesis by Concatenation
Simply listing what each source or agent said, one after another, without integration. This is not synthesis — it is a bibliography with extra steps.

**Detection:** If removing the source attributions would make the text incoherent, it is concatenation, not synthesis. Rewrite around themes, not sources.
