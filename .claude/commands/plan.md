# Plan Command (Enhanced)

## Usage
`/plan {feature name} [--risk-assessment] [--effort-estimate]`

## Description
Creates comprehensive feature specifications with enhanced planning capabilities.

## Enhanced Process Flow
1. **Feature Loading**
   - Load from `/docs/features/planned.md`
   - Validate feature prerequisites
   - Check for conflicting features

2. **Codebase Analysis** (Existing)
   - Identify integration points
   - Map dependencies
   - Find similar patterns

3. **Risk Assessment** (New)
   - Technical complexity score (1-10)
   - Integration risk analysis
   - Performance impact prediction
   - Security vulnerability assessment
   - Data migration complexity

4. **Comprehensive Specification**
   - Problem statement and goals
   - User stories with acceptance criteria
   - Technical approach and architecture
   - **Migration Strategy** (New)
   - **Rollback Procedures** (New)
   - Data model changes
   - API endpoints needed
   - UI/UX considerations
   - **Performance Requirements** (New)
   - **Security Requirements** (New)
   - Testing strategy
   - **Monitoring Plan** (New)
   - Implementation phases
   - **Effort Estimation** (New)

5. **Dependency Mapping** (New)
   - Feature dependencies
   - External service dependencies
   - Package dependencies
   - Team dependencies

6. **GitHub Issue Update**
   - Update issue status from `Backlog` to `Ready`
   - Replace issue description with comprehensive spec
   - Add checklist items for all success criteria
   - Include technical requirements as tasks

## New Sections in Output

### Risk Assessment Matrix
```markdown
## Risk Assessment

### Technical Risks
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Database migration failure | Medium | High | Staged rollout with backups |
| Performance degradation | Low | Medium | Load testing before release |
| API breaking changes | Low | High | Versioning strategy |

### Overall Risk Score: 6.5/10
```

### Migration Strategy
```markdown
## Migration Strategy

### Phase 1: Data Preparation
- Backup existing data
- Create migration scripts
- Test on staging environment

### Phase 2: Gradual Rollout
- Feature flag for 10% users
- Monitor performance metrics
- Gradual increase to 100%

### Rollback Plan
1. Feature flag to disable
2. Revert database migrations
3. Clear cache layers
4. Restore from backup if needed
```

### Performance Requirements
```markdown
## Performance Requirements

### API Response Times
- GET /contacts: < 200ms (p95)
- POST /contacts/enrich: < 500ms (p95)
- Bulk operations: < 5s for 1000 records

### Resource Limits
- Memory: < 500MB per instance
- CPU: < 80% sustained load
- Database connections: < 50 concurrent
```

### Monitoring Plan
```markdown
## Monitoring Plan

### Key Metrics
- Enrichment success rate
- API response times
- Error rates by type
- Data quality scores

### Alerts
- Success rate < 95%
- Response time > 1s
- Error rate > 1%
- Memory usage > 80%

### Dashboards
- Real-time enrichment stats
- Historical trends
- Cost per enrichment
```

### Effort Estimation
```markdown
## Effort Estimation

### Development Effort
- Backend API: 3 developer-days
- Frontend UI: 2 developer-days
- Database changes: 1 developer-day
- Testing: 2 developer-days
- Documentation: 1 developer-day

### Total: 9 developer-days (2 weeks with buffer)

### Dependencies
- Design approval: 2 days
- Security review: 1 day
- Load testing: 1 day
```

## Options
- `--risk-assessment` - Deep risk analysis
- `--effort-estimate` - Detailed effort breakdown
- `--quick` - Basic spec only (original behavior)
- `--compare {feature}` - Compare with similar feature

## Example
```
/plan "Advanced Contact Enrichment" --risk-assessment --effort-estimate
```

This generates a comprehensive spec that:
1. Creates detailed specification in `/docs/features/specs/`
2. Updates GitHub issue #234 with:
   - Complete problem statement and user flows
   - Success criteria as checkboxes
   - Technical requirements as tasks
   - Implementation phases
   - Business impact and metrics
   - Dependencies and risks
3. Changes issue status from `Backlog` to `Ready`
4. Transforms initial feature request into actionable work item