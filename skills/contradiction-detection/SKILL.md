---
name: contradiction-detection
description: "Use when identifying and resolving conflicting claims across multiple research sources"
---

# Contradiction Detection Framework

Identify and resolve conflicting claims across research sources. Based on the "Contradiction to Consensus" approach from SOTA research methodologies.

## Core Principle: Dual-Perspective Retrieval

For each major claim encountered during research, actively search for BOTH supporting AND contradicting evidence. Do not just confirm — seek disconfirmation.

### Search Pattern

For any claim X:
1. **Supporting search**: "[topic] evidence for X", "[topic] X confirmed"
2. **Contradicting search**: "[topic] criticism of X", "[topic] X debunked", "[topic] alternative to X", "[topic] X limitations"
3. **Meta search**: "[topic] X controversy", "[topic] X debate"

Never skip step 2. Confirmation bias is the biggest threat to research quality.

## Fact-Level Conflict Identification

Compare specific claims across sources — not just general topic agreement.

### Conflict Categories

| Category | Description | Example |
|----------|-------------|---------|
| **Factual Disagreement** | Sources cite different numbers, dates, or facts | Source A: "Market size is $5B" vs Source B: "Market size is $12B" |
| **Methodological Disagreement** | Sources reach different conclusions due to different methods | Study A (survey): "Users prefer X" vs Study B (A/B test): "Users prefer Y" |
| **Interpretation Disagreement** | Same facts, different conclusions drawn | Both agree revenue grew 3%, but A says "strong growth" and B says "disappointing" |
| **Temporal Disagreement** | Claims were true at different times | Source from 2020 vs source from 2024 on a fast-moving topic |

### Identification Process

1. **Extract claims** — List specific, testable claims from each source
2. **Cross-reference** — Compare claims across sources on the same sub-topic
3. **Categorize** — Assign each conflict to a category above
4. **Assess scope** — Is this a central finding or a peripheral detail?

## Contradiction Severity Levels

| Severity | Definition | Action Required |
|----------|------------|-----------------|
| **Critical** | Core finding or central claim is disputed by credible sources | Must resolve or present both sides prominently in report |
| **Moderate** | Supporting detail or secondary claim varies across sources | Note the variation, use best-evidenced version |
| **Minor** | Peripheral disagreement that doesn't affect conclusions | Mention in footnotes if relevant, otherwise use most authoritative source |

## Resolution Strategies

### For Factual Disagreements
1. Check source dates — most recent authoritative source wins for current facts
2. Check methodology — better methodology wins
3. Check source authority — use the source-evaluation skill to compare credibility
4. If still unresolved — present the range with attribution

### For Methodological Disagreements
1. Evaluate which methodology is more appropriate for the specific question
2. Note the methodological difference explicitly
3. Present both results with methodology context
4. Let the reader assess which applies to their situation

### For Interpretation Disagreements
1. Present the underlying facts (which both sides agree on)
2. Present both interpretations with reasoning
3. Note the framing differences
4. Avoid silently adopting one interpretation

### For Temporal Disagreements
1. Identify the timeline — when was each claim valid?
2. Use the most recent data for current-state questions
3. Use historical data for trend analysis
4. Note that the situation has evolved

### General Rule
**Never silently pick one side of a contradiction.** Always note the disagreement explicitly in the research output, even if you recommend one position over another.

## Contradiction Card Format

For each detected contradiction, produce a card:

```
Contradiction: [Brief description]
Severity: [Critical | Moderate | Minor]
Category: [Factual | Methodological | Interpretation | Temporal]

Source A Position:
  - Claim: [specific claim]
  - Source: [name, date, type]
  - Evidence Strength: [Strong | Moderate | Weak]

Source B Position:
  - Claim: [specific claim]
  - Source: [name, date, type]
  - Evidence Strength: [Strong | Moderate | Weak]

Resolution:
  - Strategy: [which resolution strategy applied]
  - Recommendation: [what to include in the report]
  - Confidence: [High | Medium | Low]
  - Note: [any caveats for the reader]
```

## Integration with Research Workflow

1. **During research** — flag contradictions as they are discovered, do not wait until synthesis
2. **After initial research** — run a dedicated contradiction sweep across all collected findings
3. **During synthesis** — ensure every critical and moderate contradiction is addressed in the report
4. **In final review** — verify no contradictions were silently resolved without documentation
