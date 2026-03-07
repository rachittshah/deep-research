# {{title}}

**Question**: {{question}}
**Date**: {{date}}
**Configuration**: {{depth}} depth | {{perspective_count}} perspectives | {{max_researchers}} researchers
**Researchers dispatched**: {{agent_count}}
**Sources consulted**: {{source_count}}

---

## Executive Summary

{{executive_summary}}

## Methodology

**Research angles explored:**
{{#each angles}}
- {{this.name}}: {{this.description}}
{{/each}}

**Perspectives applied:** {{perspectives}}
**Source types consulted:** {{source_types}}

## Findings

{{#each themes}}
### {{this.title}}

{{this.content}}

{{/each}}

## Analysis

{{analysis}}

## Contradictions & Debates

{{contradictions}}

## Limitations

{{limitations}}

## Conclusions

{{conclusions}}

---

## Sources

{{#each sources}}
{{this.number}}. [{{this.title}}]({{this.url}}) | {{this.source_type}} | {{this.date}}
{{/each}}
