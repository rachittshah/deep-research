## Source Evaluation Card

**URL**: {{url}}
**Title**: {{title}}
**Source Type**: {{source_type}}
**Publication Date**: {{date}}
**Author/Organization**: {{author}}

### Credibility Assessment

**Overall Score**: {{credibility_score}} / 5

| Factor | Rating | Notes |
|--------|--------|-------|
| Authority | {{authority_rating}} | {{authority_notes}} |
| Accuracy | {{accuracy_rating}} | {{accuracy_notes}} |
| Currency | {{currency_rating}} | {{currency_notes}} |
| Objectivity | {{objectivity_rating}} | {{objectivity_notes}} |
| Coverage | {{coverage_rating}} | {{coverage_notes}} |

### Key Claims Extracted

{{#each claims}}
- **Claim**: {{this.claim}}
  **Evidence**: {{this.evidence}}
  **Confidence**: {{this.confidence}}
{{/each}}

### Cross-Reference Status

- Corroborated by: {{corroborated_by}}
- Contradicted by: {{contradicted_by}}
- Unique information: {{unique_info}}
