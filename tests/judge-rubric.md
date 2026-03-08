# Research Report Quality Evaluation Rubric

You are an expert research quality evaluator. Score the following research report on six dimensions using the rubrics below, then evaluate any question-specific criteria as binary MET/UNMET.

Think step by step about each dimension before scoring. For each dimension, first quote specific evidence from the report, then assign your score.

## Scoring Dimensions

### Completeness (weight: 0.20)

| Score | Description |
|-------|-------------|
| 1 | Major gaps — key aspects of the question are unaddressed |
| 2 | Several important angles missing |
| 3 | Most angles covered with some gaps remaining |
| 4 | Thorough coverage with only minor omissions |
| 5 | Comprehensive coverage — all facets of the question addressed in depth |

### Accuracy (weight: 0.20)

| Score | Description |
|-------|-------------|
| 1 | Multiple factual errors or unsubstantiated claims |
| 2 | Several inaccuracies or poorly supported claims |
| 3 | Mostly accurate; minor errors or vague claims present |
| 4 | Accurate with only negligible issues |
| 5 | All claims verifiable and precisely stated |

### Citation Quality (weight: 0.20)

| Score | Description |
|-------|-------------|
| 1 | Few or no citations; claims lack sourcing |
| 2 | Some citations but many claims unsourced |
| 3 | Most claims cited; some gaps in sourcing |
| 4 | Nearly all claims cited with real, retrievable URLs |
| 5 | Every claim cited with real, accessible URLs; no [UNSOURCED] flags |

### Balance (weight: 0.15)

| Score | Description |
|-------|-------------|
| 1 | Single perspective; no counterarguments |
| 2 | Slight acknowledgment of alternatives |
| 3 | Some balance; multiple viewpoints mentioned |
| 4 | Good balance with contradictions surfaced |
| 5 | Multiple perspectives explored in depth with contradictions and trade-offs explicitly surfaced |

### Coherence (weight: 0.15)

| Score | Description |
|-------|-------------|
| 1 | Disorganized; hard to follow |
| 2 | Some structure but uneven flow |
| 3 | Logical structure but transitions are rough |
| 4 | Well-organized with good thematic flow |
| 5 | Excellent thematic flow; each section builds on the last |

### Source Credibility (weight: 0.10)

| Score | Description |
|-------|-------------|
| 1 | Unreliable or dubious sources throughout |
| 2 | Mix of unreliable and acceptable sources |
| 3 | Acceptable sources with some authoritative ones |
| 4 | Mostly authoritative, credible sources |
| 5 | Authoritative, credible sources throughout (academic papers, official reports, established outlets) |

## Question-Specific Criteria

In addition to the dimensions above, evaluate each question-specific criterion provided below as binary MET or UNMET. For each criterion, cite specific evidence from the report supporting your judgment.

{{QUESTION_CRITERIA}}

## Required Output Format

Return your evaluation as JSON only, with no other text outside the JSON block:

```json
{
  "dimension_scores": {
    "completeness": {"score": N, "justification": "..."},
    "accuracy": {"score": N, "justification": "..."},
    "citation_quality": {"score": N, "justification": "..."},
    "balance": {"score": N, "justification": "..."},
    "coherence": {"score": N, "justification": "..."},
    "source_credibility": {"score": N, "justification": "..."}
  },
  "criteria_results": [
    {"criterion": "...", "met": true, "evidence": "..."}
  ],
  "composite_score": N.NN,
  "overall_assessment": "..."
}
```

The `composite_score` is the weighted average: (completeness * 0.20) + (accuracy * 0.20) + (citation_quality * 0.20) + (balance * 0.15) + (coherence * 0.15) + (source_credibility * 0.10).
