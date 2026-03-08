# Optimization Log

## Methodology

Every text artifact in this system (agent prompts, skills, templates) is treated as a candidate in an optimization loop using the **optimize-anything** methodology:

1. **Seed**: Current artifact text
2. **Evaluate**: LLM judge scores N dimensions (each 1-10)
3. **ASI (Actionable Side Information)**: Identify the weakest dimension
4. **Reflective mutation**: Propose a targeted fix for the weakest dimension without degrading others
5. **Iterate**: 5-7 rounds per artifact
6. **Pareto frontier**: Track non-dominated solutions across dimensions

This is not blind evolution — it's **diagnostic-driven improvement**. The LLM reads the evaluation feedback, diagnoses the specific weakness, and proposes a surgical fix.

---

## Round 1: Initial Optimization (Post-Build)

**When**: Immediately after all skills and agents were built.
**Target**: 3 agent prompts + orchestration skill.
**Method**: 5-7 rounds of reflective mutation per artifact.

### Researcher Agent (`agents/researcher.md`)

| Dimension | Before | After |
|-----------|--------|-------|
| Specificity | 5 | 7 |
| Source Attribution | 6 | 8 |
| Query Strategy | 5 | 7 |
| Diminishing Returns | 6 | 8 |
| Contradiction Handling | 5 | 7 |
| Structured Output | 7 | 8 |
| Conciseness | 8 | 8 |

**Key changes**: Concrete query tactics (exact phrases, site: filters, comparison queries, date qualifiers). Structured conflict format (Side A/Side B). Explicit "3+ consecutive queries with no new claims" threshold. Verbatim quotes mandated.

### Critic Agent (`agents/critic.md`)

| Dimension | Before | After |
|-----------|--------|-------|
| Gap Detection | 6 | 8 |
| Contradiction Detection | 6 | 8 |
| Source Audit | 5 | 8 |
| Prioritization | 7 | 8 |
| Actionability | 5 | 8 |
| False Positive Rate | 5 | 8 |
| Conciseness | 7 | 8 |

**Key changes**: Corroboration thresholds. Evidence-weighing hierarchy. Follow-up queries for both CRITICAL and IMPORTANT issues. Cross-angle gap detection.

### Synthesizer Agent (`agents/synthesizer.md`)

| Dimension | Before | After |
|-----------|--------|-------|
| Thematic Organization | 7 | 9 |
| Citation Rigor | 8 | 9 |
| Contradiction Presentation | 6 | 9 |
| Perspective Balance | 6 | 9 |
| Writing Quality | 7 | 9 |
| Report Completeness | 8 | 9 |
| Limitation Honesty | 5 | 9 |
| Conciseness | 7 | 8 |

**Key changes**: 4-step clustering process. Structured Position A/B contradiction format. Limitation falsifiability tests. Cross-reference checklist against research plan. Concrete anti-pattern/replacement examples.

### Orchestration Skill (`skills/deep-research/SKILL.md`)

| Dimension | Before | After |
|-----------|--------|-------|
| Pipeline Clarity | 6 | 9 |
| Parallel Dispatch | 7 | 9 |
| Plan Quality | 6 | 9 |
| Critique Integration | 6 | 9 |
| Preset Differentiation | 5 | 9 |
| Red Flag Coverage | 7 | 9 |
| Skill Composability | 6 | 9 |
| Compliance Enforcement | 5 | 9 |

**Key changes**: Per-phase preset behavior table. Skills reference table. Structured critic→action decision table. Per-phase CHECKPOINTs. 11 red flags (up from 8). Hard compliance rules in EXTREMELY-IMPORTANT block.

---

## Benchmark Run: DeepResearch-Bench (5 tasks)

**When**: After Round 1 optimization.
**Method**: 5 English tasks from DeepResearch-Bench (100 PhD-level research tasks), scored by Opus 4.6 judge on 6 dimensions.

### Results

| Task | Topic | Domain | Cites | Comp. | Acc. | Cite Q. | Bal. | Coh. | Src. | Composite |
|------|-------|--------|-------|-------|------|---------|------|------|------|-----------|
| 51 | Japan elderly market | Finance | 31 | 5 | 4 | 4 | 5 | 5 | 4 | 4.50 |
| 56 | Asymmetric auction theory | Math/Econ | 25 | 5 | 5 | 4 | 5 | 5 | 5 | 4.85 |
| 61 | Chub mackerel price dynamics | Marine Sci | 23 | 5 | 4 | 4 | 5 | 5 | 4 | 4.55 |
| 71 | AIGC in K-12 education | Education | 33 | 5 | 4 | 5 | 5 | 5 | 4 | 4.70 |
| 81 | Historical narrative reinterpretation | History | 26 | 5 | 4 | 4 | 4 | 5 | 3 | 4.20 |
| | | **AVG** | **27.6** | **5.0** | **4.2** | **4.2** | **4.8** | **5.0** | **4.0** | **4.56** |

### Structural Checks: 5/5 PASS

All reports: 7/7 required sections, inline citations, source URLs, zero [UNSOURCED] flags.

### Weakness Analysis

| Weakness | Evidence | Root Cause |
|----------|----------|------------|
| **Source credibility: 4.0/5** | Task 81: 9/26 sources from Wikipedia | Researcher prompt didn't ban Wikipedia |
| **Citation quality: 4.2/5** | Task 56: 3 URL mismatches (URL doesn't match cited paper) | No URL verification requirement |
| **Accuracy: 4.2/5** | Task 61: 2022 paper cited for 2023 data | No temporal consistency check |

---

## Round 2: Post-Benchmark Targeted Optimization

**When**: After benchmark weakness analysis.
**Target**: All 3 agent prompts + 2 skills + orchestration skill.
**Method**: 5-7 rounds of reflective mutation, targeting ONLY the three identified weaknesses.

### What Changed

#### Researcher Agent (`agents/researcher.md`) — Commit `9b97f30`

| New Rule | Purpose |
|----------|---------|
| Wikipedia BANNED | "NEVER cite Wikipedia. Find the primary source Wikipedia cites." |
| 4-tier source hierarchy | peer-reviewed > institutional > industry > blogs |
| URL verification | "Only cite URLs you actually fetched via WebFetch in this session" |
| Temporal consistency | "Publication year must be >= earliest data year in your claim" |
| Data period field | Output format now includes "Data period" separate from publication date |

#### Critic Agent (`agents/critic.md`) — Commit `9fa15c3`

| New Audit | Severity |
|-----------|----------|
| Wikipedia detection | CRITICAL — require primary source replacement |
| URL plausibility | IMPORTANT — domain must match claimed source type |
| Temporal audit | IMPORTANT — publication year vs data period check |
| Source diversity | IMPORTANT — flag if >30% sources from same domain |
| Cross-reference | For critical claims, require 2+ independent sources |

#### Synthesizer Agent (`agents/synthesizer.md`) — Commit `acb9e5e`

| New Feature | Description |
|-------------|-------------|
| Citation deduplication | Merge same-URL citations across researchers |
| URL mandate | Every source must have fetchable URL; URL-less = [WEAKLY SOURCED] |
| Source type labeling | Each source tagged: peer-reviewed, government, institutional, news, industry, other |
| Credibility ordering | Sources listed peer-reviewed first, then government, etc. |
| Anti-Wikipedia | Trace to primary or mark [WEAKLY SOURCED] |

#### Source Evaluation Skill — Commit `da49272`

| New Rule | Detail |
|----------|--------|
| Wikipedia weight: 0.0 | Explicitly banned from source hierarchy |
| Source hierarchy table | peer-reviewed (1.0) > government (0.9) > institutional (0.8) > news (0.6) > industry (0.5) > blogs (0.3) > Wikipedia (0.0) |
| Minimum quality threshold | 50% of sources must be weight >= 0.8 |
| Named low-credibility sources | Selina Wamucii, Mordor Intelligence, DigitalDefynd, AllAboutAI explicitly listed |

#### Citation Tracking Skill — Commit `da49272`

| New Rule | Detail |
|----------|--------|
| URL verification | Every URL in Sources must have been fetched during the session |
| Temporal consistency | publication_year >= earliest_data_year |
| Bidirectional check | Every [n] maps to a source AND every source maps to at least one [n] |
| Anti-hallucination | "If you didn't read the actual page content, don't cite it" |

#### Orchestration Skill — Commit `d733a03`

| Phase | New Gate |
|-------|----------|
| Phase 3 DISPATCH | Source Quality Rules block in researcher prompt |
| Phase 4 CRITIQUE | Extended source quality audit (Wikipedia, URLs, temporal) |
| Phase 5 FOLLOW-UP | Prioritize source quality upgrades before content gaps |
| Phase 6 SYNTHESIZE | Deduplication, type tagging, credibility ordering |
| Phase 7 REVIEW | 3 new checklist items (#12 no Wikipedia, #13 URLs fetched, #14 temporal consistency) |

---

## Expected Impact

Based on the specific weaknesses addressed:

| Dimension | Before (avg) | Expected After | Change Driver |
|-----------|-------------|----------------|---------------|
| Source Credibility | 4.0 | 4.6-4.8 | Wikipedia ban, source hierarchy |
| Citation Quality | 4.2 | 4.5-4.7 | URL verification, deduplication |
| Accuracy | 4.2 | 4.4-4.6 | Temporal consistency checks |
| Completeness | 5.0 | 5.0 | No change needed |
| Coherence | 5.0 | 5.0 | No change needed |
| Balance | 4.8 | 4.8-5.0 | Cross-reference requirements |
| **Composite** | **4.56** | **4.70-4.85** | |

To validate: re-run the same 5 benchmark tasks and compare scores via `tests/compare-runs.sh`.
