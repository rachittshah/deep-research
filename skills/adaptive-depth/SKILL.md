---
name: adaptive-depth
description: "Use when deciding whether to explore a research angle deeper, broaden to new angles, or stop researching"
---

# Adaptive Depth Control

Decide in real-time whether to go deeper on a research angle, broaden to new angles, or stop. This prevents both premature termination (missing critical information) and runaway research (diminishing returns).

## Complexity Classifier

Before researching an angle, classify its complexity to set expectations for effort and stopping criteria.

### Atomic
- **Effort**: 1-2 searches
- **Nature**: Factual lookup, single authoritative answer expected
- **Stop when**: Authoritative source found and confirmed
- **Example**: "What year was company X founded?"

### Moderate
- **Effort**: 3-5 searches
- **Nature**: Requires synthesis across a few sources, some nuance
- **Stop when**: 3+ sources converge on consistent answer, key nuances captured
- **Example**: "What is company X's current pricing model and how does it compare to Y?"

### Deep
- **Effort**: 6+ searches, may require recursive sub-decomposition
- **Nature**: Multiple source types needed, contradictions likely, requires judgment
- **Stop when**: Major perspectives covered, contradictions identified and addressed, confidence plateau reached
- **Example**: "What are the long-term implications of regulation X on industry Y?"

## Diminishing Returns Detection

After each search or research step, evaluate whether continuing adds value.

### Signals That Research Is Saturating

1. **Redundant information**: New searches return facts already captured in your notes. Track the novelty ratio — percentage of genuinely new information in each result.

2. **Confidence plateau**: Your confidence in the answer stops increasing. You could answer the question almost as well without the last 2 searches.

3. **Circular sourcing**: Sources start citing each other rather than providing independent evidence. The same original study or report keeps appearing as the ultimate source.

4. **Diminishing specificity**: New results are more general or tangential than earlier results. The search space is exhausted for this specific angle.

### Stopping Rule

**Stop researching an angle when 2 consecutive searches yield less than 20% novel information.**

Measure novelty as: distinct facts, perspectives, or data points not already in your accumulated notes for this angle.

```
Search N:   [■■■■■■■■□□] 80% novel → continue
Search N+1: [■■■■□□□□□□] 40% novel → continue
Search N+2: [■■□□□□□□□□] 20% novel → continue (borderline)
Search N+3: [■□□□□□□□□□] 10% novel → STOP (2nd consecutive <20%)
```

## Breadth vs Depth Decision Framework

At each decision point, use this tree:

```
Has the current angle reached its expected complexity level?
├── NO → Go deeper on current angle
│   └── But check: Am I hitting diminishing returns early?
│       ├── YES → Reclassify complexity downward, wrap up angle
│       └── NO → Continue depth exploration
│
└── YES → Evaluate whether to broaden
    ├── Are there unresearched angles from the plan?
    │   ├── YES → Move to next planned angle (prefer independent ones)
    │   └── NO → Check for emergent angles
    │       ├── Research revealed unexpected important dimension?
    │       │   ├── YES → Add new angle (respect max_breadth)
    │       │   └── NO → Proceed to synthesis
    │
    └── Are there critical gaps flagged by the critic?
        ├── YES → Address gaps before synthesis
        └── NO → Proceed to synthesis
```

### Decision Priorities (highest to lowest)

1. **Address critical gaps** — if the critic flagged missing evidence for a key claim, that takes priority
2. **Complete dependent angles** — unblock downstream work
3. **Deepen high-value angles** — angles where depth yields disproportionate insight
4. **Broaden to new angles** — cover new ground
5. **Refine existing angles** — polish low-priority details (often skip this)

## Hard Safety Limits

These limits prevent runaway agent spawning and excessive cost:

| Parameter | Limit | Rationale |
|-----------|-------|-----------|
| **max_depth** | 3 | No angle should require more than 3 levels of recursive decomposition |
| **max_breadth** | 5 | No single research task should explore more than 5 top-level angles simultaneously |
| **max_total_agents** | 15 | Total researcher + critic + synthesizer agents across entire research task |

When approaching limits:
- At 80% of max_total_agents (12 agents): switch to sequential processing, stop parallel dispatch
- At max_total_agents: no new agents. Work with information gathered so far.
- If max_depth reached on an angle: synthesize what you have, flag as "depth-limited" in output

## Cost Awareness

Before spawning a new agent, estimate its cost:

```
Estimated cost = (complexity_searches × avg_search_time) + synthesis_overhead

Atomic:   ~2 searches  → low cost
Moderate: ~4 searches  → medium cost
Deep:     ~8+ searches → high cost (consider splitting)
```

**Prefer fewer deeper agents over many shallow ones.** A single moderate-complexity agent that synthesizes well is more valuable than three atomic agents that each return isolated facts.

Decision heuristic:
- Can two atomic angles be combined into one moderate agent? → Combine
- Is a deep angle decomposable into independent sub-angles? → Split only if sub-angles are truly independent
- Would spawning another agent yield information worth more than its cost? → If uncertain, don't spawn

## When to Trigger Follow-up Research

Even after initial angles are complete, additional research may be warranted:

### Triggers

1. **Critical gaps from critic**: The critic agent identifies claims without sufficient evidence or missing perspectives that undermine the synthesis. These gaps must be addressed.

2. **Unresolved contradictions**: Sources disagree on material points and no resolution was reached. Dispatch a targeted follow-up to find adjudicating evidence.

3. **User-specified areas**: The user highlighted specific areas of interest in their original question. If coverage on those areas is thin, deepen.

4. **Confidence below threshold**: If confidence on any key claim is below "moderate," and the claim is central to the answer, research further.

### Follow-up Protocol

1. Identify the specific gap or contradiction
2. Formulate a targeted sub-question (not a broad re-research)
3. Check against safety limits before dispatching
4. Classify as atomic or moderate — follow-ups should not be deep
5. Integrate findings into existing synthesis rather than producing a separate output
