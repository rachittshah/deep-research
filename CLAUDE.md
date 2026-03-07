# Deep Research Plugin

## What This Is
A Claude Code plugin that turns any session into a SOTA deep research engine. Skills teach Claude multi-agent research methodology; the Agent tool spawns parallel researcher subagents with WebSearch/WebFetch.

## Architecture
- `skills/` — methodology skills (how to plan, research, evaluate, synthesize)
- `agents/` — subagent prompts (researcher, critic, synthesizer)
- `commands/` — slash commands (/research, /research-plan, /research-review)
- `hooks/` — SessionStart hook injects research capability awareness
- `templates/` — report and source-card templates

## Conventions
- Skills follow Claude Code plugin conventions: YAML frontmatter with `name` and `description`
- Descriptions say WHEN to use, not WHAT it does
- Agent prompts define structured output formats
- All claims in research output must have source citations
- No external dependencies beyond Claude Code CLI

## Key Principles
- Skills are composable: deep-research orchestrates other skills
- Subagents get full context in their prompt (never make them read files)
- Parallel dispatch for independent research angles
- Sequential for dependent steps (plan → research → critique → synthesize)
- Every assertion needs a source. Unsourced claims get flagged.
