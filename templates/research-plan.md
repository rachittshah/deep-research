## Research Plan

**Question**: {{question}}
**Generated**: {{date}}
**Estimated Complexity**: {{complexity}}
**Recommended Depth**: {{depth}}

---

### Research Angles

{{#each angles}}
#### Angle {{this.number}}: {{this.name}}

**Description**: {{this.description}}
**Perspective**: {{this.perspective}}
**Expected Source Types**: {{this.source_types}}
**Priority**: {{this.priority}}
**Suggested Queries**:
{{#each this.queries}}
- {{this}}
{{/each}}

{{/each}}

### Perspectives to Apply

{{#each perspectives}}
- **{{this.name}}**: {{this.description}}
{{/each}}

### Expected Coverage

**Total angles**: {{angle_count}}
**Total perspectives**: {{perspective_count}}
**Estimated researcher agents**: {{researcher_count}}
**Estimated queries**: {{query_count}}

### Success Criteria

{{#each criteria}}
- [ ] {{this}}
{{/each}}
