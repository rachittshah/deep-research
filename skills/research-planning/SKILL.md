---
name: research-planning
description: "Use when decomposing a research question into structured angles before dispatching researchers"
---

# Research Planning

Decompose a research question into structured, dispatchable research angles. This is the first phase of any deep research task — get planning right and execution follows naturally.

## Step 1: Classify the Core Question

Identify the question type to calibrate decomposition strategy:

| Type | Description | Decomposition Strategy |
|------|-------------|----------------------|
| **Factual** | Has a definitive answer | Few focused angles, authoritative sources |
| **Analytical** | Requires examining causes, mechanisms, or implications | Break by causal chain or analytical framework |
| **Comparative** | Evaluates alternatives or trade-offs | One angle per alternative + cross-cutting criteria |
| **Exploratory** | Maps an emerging or poorly-defined space | Broad initial sweep, then narrow on signal |
| **Predictive** | Forecasts outcomes or trends | Historical precedent + current signals + expert views |

## Step 2: Generate Research Angles

Generate 3-6 angles that collectively cover the question. Each angle becomes a dispatchable unit for a researcher subagent.

For each angle, define:

```yaml
- angle: "<concise sub-question>"
  source_types:
    - <expected source type: academic, news, official docs, industry reports, forums, etc.>
  complexity: atomic | moderate | deep
  web_search_required: true | false
  rationale: "<why this angle matters for the overall question>"
```

### Complexity Guide

- **Atomic**: Answerable with 1-2 searches. Single factual lookup. Example: "What is the current market cap of X?"
- **Moderate**: Needs 3-5 searches with some synthesis. Example: "How has X's pricing strategy evolved over the last 3 years?"
- **Deep**: Requires recursive sub-decomposition, multiple source types, and contradiction resolution. Example: "What are the long-term societal implications of X?"

## Step 3: Map Dependencies

Identify which angles inform others. Dependencies determine dispatch order.

```
angle_1 (atomic) ──→ angle_3 (deep)    # angle_3 needs angle_1's findings
angle_2 (moderate) ──→ angle_3 (deep)  # angle_3 also needs angle_2
angle_4 (atomic) ──→ (none)            # fully independent
```

Rules:
- Independent angles dispatch in parallel
- Dependent angles dispatch sequentially after their dependencies complete
- Circular dependencies indicate a planning error — restructure the angles

## Step 4: Identify Controversy and Contradiction Areas

Flag angles where you expect sources to disagree. This prepares the critic agent for targeted evaluation.

```yaml
expected_contradictions:
  - area: "<topic>"
    likely_sides: ["<position A>", "<position B>"]
    resolution_strategy: "<how to adjudicate: recency, authority, evidence weight>"
```

## Plan Output Format

```markdown
## Research Plan: <question summary>

**Question type**: <factual|analytical|comparative|exploratory|predictive>
**Estimated total complexity**: <low|medium|high>
**Estimated angles**: <N>

### Angles

#### Angle 1: <sub-question>
- **Complexity**: atomic | moderate | deep
- **Source types**: <list>
- **Web search**: yes | no
- **Depends on**: <none | angle IDs>
- **Rationale**: <why this matters>

#### Angle 2: <sub-question>
...

### Dependency Graph
<text diagram showing dispatch order>

### Expected Contradictions
- <area>: <position A> vs <position B>

### Dispatch Strategy
- **Parallel batch 1**: Angles <X, Y> (independent)
- **Sequential after batch 1**: Angle <Z> (depends on X, Y)
```

## Examples

### Good Decomposition

**Question**: "Should our startup adopt Rust for our backend rewrite?"

1. **Current Rust ecosystem maturity for web backends** (moderate, web search) — establishes baseline feasibility
2. **Performance benchmarks: Rust vs current stack** (atomic, web search) — quantifies the gain
3. **Rust hiring market and team ramp-up time** (moderate, web search) — assesses practical feasibility
4. **Case studies of similar migrations** (moderate, web search) — learns from precedent
5. **Risk analysis: ecosystem gaps, library maturity, maintenance burden** (deep, web search) — identifies blockers

Dependencies: 1 → 5 (ecosystem knowledge informs risk analysis). Angles 2, 3, 4 are independent.

### Bad Decomposition

**Question**: Same as above.

1. "Research Rust" — too broad, no clear deliverable
2. "Research backend technologies" — overlaps with #1, still too broad
3. "Look into programming languages" — absurdly broad, not actionable
4. "Check if Rust is good" — subjective, no evaluation criteria

## Anti-patterns

| Anti-pattern | Problem | Fix |
|-------------|---------|-----|
| **Too broad** | Angle cannot be answered in a focused research session | Split into atomic sub-questions |
| **Overlapping angles** | Multiple angles research the same information | Merge or clearly delineate scope boundaries |
| **Missing critical perspective** | Plan has blind spots (e.g., only technical, no business angle) | Review through stakeholder lens: technical, business, user, regulatory |
| **All angles same complexity** | Usually means shallow decomposition | Vary depth — some angles should be quick lookups, others deep dives |
| **No dependencies identified** | Either the question is trivial or dependencies were missed | Re-examine: does any angle's framing change based on another's findings? |
| **Too many angles (>6)** | Diminishing returns, coordination overhead | Consolidate related angles, defer low-priority ones |
