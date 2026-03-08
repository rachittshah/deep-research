# Research Report Quality Evaluation Rubric

You are an expert research quality evaluator. Score the following research report on six dimensions using the rubrics below, then evaluate any question-specific criteria as binary MET/UNMET.

**Think step by step about each dimension before scoring.** For each dimension, first quote specific evidence from the report, then assign your score. Do not let your assessment of one dimension influence another -- evaluate each independently.

## Input

You will receive:

1. **Original question**: The research question that was asked.
2. **Research report**: The full report produced in response.
3. **Question-specific criteria**: A list of rubric_criteria to evaluate as binary MET/UNMET.

## Scoring Dimensions

### Completeness (weight: 0.20)

How thoroughly does the report cover the topic?

| Score | Description |
|-------|-------------|
| 1 | **Major gaps** -- covers only one angle or misses critical aspects of the question. Key subtopics are entirely absent. |
| 2 | **Significant gaps** -- covers some angles but misses 2 or more important perspectives or subtopics. |
| 3 | **Adequate coverage** -- most major angles covered with some gaps. Minor subtopics may be missing but the core question is addressed. |
| 4 | **Strong coverage** -- nearly all relevant angles addressed with reasonable depth. Only minor aspects missing. |
| 5 | **Comprehensive** -- all major angles and subtopics covered with appropriate depth. Reader would not need to look elsewhere for a thorough understanding. |

### Accuracy (weight: 0.20)

Are the factual claims, statistics, and technical details correct?

| Score | Description |
|-------|-------------|
| 1 | **Multiple errors** -- contains several factual errors, incorrect statistics, or fundamental misunderstandings of the topic. |
| 2 | **Notable errors** -- contains 2-3 clear factual errors or misrepresentations that undermine credibility. |
| 3 | **Mostly accurate** -- the majority of claims are correct. May contain 1 minor error or imprecise statement that does not materially mislead. |
| 4 | **Highly accurate** -- all major claims are correct. At most, a trivially imprecise detail. |
| 5 | **Fully accurate** -- all claims are verifiable and correctly stated. Technical details and statistics are precise and current. |

### Citation Quality (weight: 0.20)

Does the report properly cite its sources?

| Score | Description |
|-------|-------------|
| 1 | **No citations** -- few or no sources referenced. Claims are unsupported assertions. |
| 2 | **Sparse citations** -- some claims are cited but most are not. Sources may be vague ("studies show") without specifics. |
| 3 | **Partial citations** -- most major claims are cited. Some citations may lack URLs or specific enough identifiers to locate the source. |
| 4 | **Good citations** -- nearly all claims are cited with identifiable sources. Most citations include URLs or specific publication details. |
| 5 | **Excellent citations** -- every substantive claim is cited with a real, locatable URL or full publication reference. No [UNSOURCED] flags. Sources are specific and verifiable. |

### Balance (weight: 0.15)

Does the report present multiple perspectives fairly?

| Score | Description |
|-------|-------------|
| 1 | **Single perspective** -- presents only one viewpoint or is clearly biased toward a predetermined conclusion. |
| 2 | **Minimal balance** -- acknowledges other perspectives exist but does not engage with them substantively. |
| 3 | **Some balance** -- presents 2+ perspectives but may give unequal depth or subtly favor one side. |
| 4 | **Well-balanced** -- multiple perspectives presented with comparable depth. Key disagreements are surfaced. |
| 5 | **Excellent balance** -- multiple perspectives presented fairly with nuance. Contradictions and tensions are explicitly surfaced and analyzed. The report helps the reader understand why reasonable people disagree. |

### Coherence (weight: 0.15)

Is the report well-organized and logically structured?

| Score | Description |
|-------|-------------|
| 1 | **Disorganized** -- no clear structure. Points are scattered, repetitive, or contradictory. Difficult to follow. |
| 2 | **Poorly organized** -- has some structure but transitions are abrupt, sections feel disconnected, or the logic is hard to follow. |
| 3 | **Adequate structure** -- logically organized overall but with uneven transitions or some sections that feel out of place. |
| 4 | **Well-structured** -- clear logical flow with good transitions. Sections build on each other. Minor organizational improvements possible. |
| 5 | **Excellent flow** -- seamless thematic progression. Each section builds naturally on the previous one. The reader is guided through a clear narrative arc from introduction to conclusion. |

### Source Credibility (weight: 0.10)

Are the sources authoritative and appropriate for the topic?

| Score | Description |
|-------|-------------|
| 1 | **Unreliable sources** -- relies on blogs, social media, or known unreliable outlets. No authoritative sources. |
| 2 | **Weak sources** -- mix of questionable and acceptable sources. Few authoritative references. |
| 3 | **Acceptable sources** -- uses mainstream news and general-purpose sources. Some authoritative references but not consistently. |
| 4 | **Good sources** -- primarily uses reputable outlets. Includes some domain-specific authoritative sources (academic papers, official reports, expert analysis). |
| 5 | **Authoritative throughout** -- consistently uses primary sources, peer-reviewed research, official government/institutional data, and recognized domain experts. Source selection demonstrates subject matter awareness. |

## Question-Specific Criteria

In addition to the dimensions above, evaluate each question-specific criterion provided below as binary MET or UNMET. For each criterion:

- A criterion is **MET** only if the report clearly and substantively satisfies it. Superficial or passing mentions do not count.
- A criterion is **UNMET** if the report fails to address it or only touches on it without substance.
- Provide brief **evidence** from the report justifying your judgment.

{{QUESTION_CRITERIA}}

## Scoring Notes

- Score each dimension independently. A report can be accurate but poorly organized, or well-cited but incomplete.
- Use the full 1-5 range. Reserve 5 for genuinely excellent performance and 1 for clear failure.
- Base scores on evidence in the report, not on your own knowledge of the topic.
- For time-sensitive questions, penalize outdated information under Accuracy and Source Credibility.
- The `overall_assessment` should be 2-3 sentences summarizing the key strengths and weaknesses.

## Composite Score

Calculate the weighted composite score as:

```
composite = (completeness * 0.20) + (accuracy * 0.20) + (citation_quality * 0.20) + (balance * 0.15) + (coherence * 0.15) + (source_credibility * 0.10)
```

Round to two decimal places.

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
