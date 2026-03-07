# deep-research

A Claude Code plugin that turns any session into a SOTA deep research engine. Multi-agent, multi-perspective, citation-verified research with adaptive depth control and contradiction detection.

Say `/research "your question"` and get a publication-quality report backed by sources.

## How It Works

```
User: /research "What is the current state of nuclear fusion energy?"

                    ┌─────────────┐
                    │    PLAN      │  Decompose into 3-5 research angles
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ PERSPECTIVES │  Assign researcher personas (STORM-style)
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │Researcher│ │Researcher│ │Researcher│  Parallel agents with
        │ Agent 1  │ │ Agent 2  │ │ Agent 3  │  WebSearch + WebFetch
        └────┬─────┘ └────┬─────┘ └────┬─────┘
             └─────────────┼─────────────┘
                           │
                    ┌──────▼──────┐
                    │   CRITIQUE   │  Find gaps, contradictions, weak sources
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  SYNTHESIZE  │  Themed report with inline citations
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   REVIEW     │  Quality gate before delivery
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   DELIVER    │  Final report with sources
                    └─────────────┘
```

## Installation

```bash
# From the Claude Code plugin marketplace
claude plugins install deep-research

# Or from git
claude plugins install --url https://github.com/rachittshah/deep-research.git
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `/research "question"` | Run the full research pipeline |
| `/research-plan "question"` | Generate a research plan for review (without executing) |
| `/research-review` | Review and verify the most recent research report |

### Configuration Presets

Specify a preset in your request: "do a quick/standard/thorough research on..."

| Preset | Angles | Perspectives | Critic | Follow-up | Best for |
|--------|--------|-------------|--------|-----------|----------|
| **quick** | 2-3 | 2 | skip | skip | Simple factual questions |
| **standard** | 3-5 | 3 | yes | 1 round | Most research (default) |
| **thorough** | 5-7 | 4-5 | yes | up to 2 | Complex or high-stakes topics |

## What Makes This Different

**Multi-perspective research** — Based on Stanford STORM: generates distinct researcher personas (academic, practitioner, skeptic, etc.) to prevent single-viewpoint tunnel vision.

**Adaptive depth control** — Agents detect diminishing returns and stop when searches repeat. Complexity classification routes questions to the right depth level.

**Contradiction detection** — Actively searches for both supporting AND contradicting evidence. Conflicts are surfaced in the report, never silently resolved.

**Source credibility scoring** — Every source gets evaluated: type (academic, news, government), recency, cross-reference count. Claims get confidence levels (verified, likely, unverified, contradicted).

**Citation verification** — Every factual claim requires an inline citation `[n]` mapping to the sources appendix. Unsourced claims are flagged `[UNSOURCED]`. The review phase catches gaps.

**Critic agent** — A dedicated agent reviews all findings before synthesis, identifying gaps, contradictions, and weak sources. Critical gaps trigger targeted follow-up research.

## Skills Reference

| Skill | Purpose |
|-------|---------|
| `deep-research` | Primary orchestration — the full 8-phase pipeline |
| `research-planning` | Decompose questions into structured research angles |
| `multi-perspective` | Generate researcher personas for balanced coverage |
| `adaptive-depth` | Decide when to go deeper, broaden, or stop |
| `source-evaluation` | Credibility scoring framework for sources |
| `contradiction-detection` | Cross-source conflict identification and resolution |
| `citation-tracking` | Inline citations and provenance tracking |
| `research-synthesis` | Multi-source synthesis methodology |
| `research-review` | Final quality gate before delivery |

## Agents Reference

| Agent | Role | Spawned by |
|-------|------|------------|
| `researcher` | Investigates a single angle with WebSearch/WebFetch, returns structured findings | Orchestrator (parallel, one per angle) |
| `critic` | Evaluates combined findings for gaps, contradictions, source quality issues | Orchestrator (after researchers complete) |
| `synthesizer` | Produces the final report with citations from all findings | Orchestrator (after critique) |

## Example Output Format

```markdown
# The Current State of Nuclear Fusion Energy

**Question**: What is the current state of nuclear fusion energy?
**Date**: 2026-03-08
**Researchers**: 4 agents across 4 angles
**Sources consulted**: 23

---

## Executive Summary
- Commercial fusion timelines have shifted from "30 years away" to active
  construction of pilot plants, with Commonwealth Fusion Systems targeting
  first plasma by 2026 [1][4]
- Total private investment exceeded $6.2B by end of 2025 [3]
- ...

## Sources
1. https://example.com/cfs-sparc — "SPARC Construction Update" | industry | 2026-01
2. https://example.com/iter-status — "ITER Project Status Report" | government | 2025-12
...
```

## Architecture

```
deep-research/
├── .claude-plugin/          Plugin metadata
├── hooks/                   SessionStart capability injection
├── skills/                  9 methodology skills
│   ├── deep-research/       Primary orchestration
│   ├── research-planning/   Question decomposition
│   ├── multi-perspective/   STORM-style perspectives
│   ├── adaptive-depth/      Depth/breadth/stop decisions
│   ├── source-evaluation/   Credibility scoring
│   ├── contradiction-detection/
│   ├── citation-tracking/   Provenance tracking
│   ├── research-synthesis/  Report generation
│   └── research-review/     Quality gate
├── agents/                  3 subagent prompts
│   ├── researcher.md        Parallel research agent
│   ├── critic.md            Gap/contradiction finder
│   └── synthesizer.md       Report writer
├── commands/                Slash commands
│   ├── research.md          /research
│   ├── research-plan.md     /research-plan
│   └── research-review.md   /research-review
└── templates/               Report and source-card templates
```

## Requirements

- Claude Code CLI with plugin support
- No other dependencies

## License

MIT
