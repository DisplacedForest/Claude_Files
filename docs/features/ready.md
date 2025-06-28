# Features Ready for Planning

> Features in **Backlog** status that have been added via `/add-feature` command and are ready for detailed planning via `/plan` command.

## Current Backlog

*No features currently in backlog. Use `/add-feature "Feature Name"` to add new features.*

---

## Recently Moved to Planning

### FEAT-2024-01-15-001: Advanced Contact Enrichment
**GitHub Issue**: #234  
**Status**: Ready (moved to planning)  
**Effort**: Medium  
**Added**: 2024-01-15  
**Moved to Planning**: 2024-01-15  

*Feature moved to `/docs/features/planning/FEAT-2024-01-15-001.md`*

---

## Feature Entry Template

When `/add-feature` command runs, it adds entries using this format:

```markdown
## FEAT-YYYY-MM-DD-XXX: [Feature Title]
**GitHub Issue**: #[issue-number]  
**Status**: Backlog  
**Effort**: [quick-win|medium|complex|unknown]  
**Added**: YYYY-MM-DD  

### Key Questions
1. [Generated question based on feature analysis]
2. [Generated question based on feature analysis]
3. [Generated question based on feature analysis]
4. [Generated question based on feature analysis]

### Initial Considerations
- **Impact**: [Estimated based on feature analysis]
- **Components Affected**: [Preliminary assessment]
- **Dependencies**: [Any obvious dependencies identified]

---
```

## Usage Instructions

### Adding New Features
```bash
# Basic feature addition
/add-feature "Real-time notifications"

# With effort estimation
/add-feature "Advanced search filters" --effort medium

# Quick win features
/add-feature "Add tooltips to buttons" --effort quick-win
```

### Moving to Planning
```bash
# Plan by feature ID
/plan FEAT-2024-01-15-001

# Plan by GitHub issue number
/plan 234

# This moves the feature from ready.md to planning/ directory
```

## Feature Status Flow

```mermaid
graph LR
    A[/add-feature] -->|Creates| B[ready.md Entry]
    B -->|GitHub Issue| C[Issue #XXX Created]
    C -->|/plan command| D[planning/FEAT-XXX.md]
    D -->|/test command| E[implementation/issue-XXX/]
    E -->|/implement| F[Code Implementation]
    F -->|PR & Review| G[completed/]
```

## Backlog Management

### Prioritization Criteria
1. **Business Impact**: High-impact features get priority
2. **User Value**: Features that directly benefit users
3. **Technical Debt**: Quick wins that improve code quality
4. **Dependencies**: Features that unblock other work

### Regular Reviews
- **Weekly**: Review new features added to backlog
- **Sprint Planning**: Move ready features to planning phase
- **Monthly**: Reassess effort estimates and priorities
- **Quarterly**: Archive completed features and analyze velocity

## Integration Notes

- **GitHub Issues**: Every feature gets a corresponding GitHub issue
- **Planning Phase**: `/plan` command converts to detailed specification
- **Implementation**: TDD workflow with `/test` and `/implement` commands
- **Multi-Agent**: Complex features use orchestrated agent workflow

## Metrics Tracking

### Backlog Health
- Number of features in backlog
- Average time from add to planning
- Effort distribution (quick-win vs complex)

### Planning Efficiency
- Features successfully moved to implementation
- Accuracy of initial effort estimates
- Time spent in planning phase

This file is automatically maintained by the `/add-feature` command and serves as the central backlog for feature development.