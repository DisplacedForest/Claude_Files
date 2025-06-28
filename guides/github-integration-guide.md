# GitHub Integration Guide

## Overview
Enhanced commands can automatically create GitHub issues with standardized templates for bugs and features.

## Setup Requirements
1. GitHub CLI (`gh`) must be authenticated: `gh auth login`
2. Repository must be initialized: `git remote add origin ...`
3. Appropriate labels should exist in the repository

## Quick Usage

### Bug Reporting
```bash
# Basic bug report (creates GitHub issue automatically)
/add-bug "Login fails with special characters"

# With priority
/add-bug "Payment webhook timeout" --priority P1

# With priority and effort
/add-bug "Export fails for large datasets" --priority P0 --effort complex
```

### Feature Requests
```bash
# Basic feature (creates GitHub issue automatically)
/add-feature "Dashboard redesign"

# With effort estimate
/add-feature "API rate limiting" --effort complex

# With project board  
/add-feature "OAuth2 integration" --effort complex
```

## Standardized Labels

### Common Labels
- `status:Backlog|Ready|In progress|In review|Done` - Work status
- `effort:quick-win|medium|complex|unknown` - Complexity estimate

### Bug-Specific Labels
- `bug` - Core bug identifier
- `priority:P0` through `priority:P3` - Urgency levels
- `severity:critical|high|medium|low` - Impact levels

### Feature-Specific Labels
- `enhancement` - Core feature identifier
- `impact:high|medium|low` - Value assessment

### Effort Definitions
- `effort:quick-win` - Simple, straightforward change
- `effort:medium` - Moderate complexity, well-understood scope
- `effort:complex` - High complexity, multiple components or unknowns
- `effort:unknown` - Needs investigation to estimate

## Template Benefits

### Bugs Get
- Structured reproduction steps
- Environment details
- Impact assessment
- Investigation checklist
- Clear severity/priority

### Features Get
- User stories with acceptance criteria
- Technical considerations
- Success metrics
- Business value scoring
- Open questions section

## Workflow Integration

### Bug Flow
```
/add-bug → GitHub Issue → /fix {issue-number} → PR → /test → Close Issue
```

### Feature Flow  
```
/add-feature → GitHub Issue → /plan → /implement → PR → /test → /release → Close Issue
```

## Best Practices

1. **GitHub issues are created automatically**
   - Both commands now create issues by default
   - Local tracking + GitHub visibility

2. **Use clear priorities and effort estimates**
   - Set priority for bugs (P0-P3)
   - Set effort for both bugs and features (quick-win/medium/complex/unknown)

3. **Use milestones for release planning**
   - Bugs: Target hotfix or next release
   - Features: Quarter or version milestone

4. **Link related issues**
   - Use "Fixes #123" in PRs
   - Reference dependencies in issue body

## Advanced Usage

### Bulk Operations
```bash
# Create multiple related bugs
/add-bug "Search fails for Chinese characters" --priority P2 --effort medium
/add-bug "Search fails for Arabic RTL text" --priority P2 --effort medium
/add-bug "Search fails for emoji" --priority P2 --effort quick-win
```

### Integration with Other Commands
```bash
# Full feature development cycle
/add-feature "Customer portal" --effort complex
/plan "Customer portal"  # Uses issue for context
/implement 123  # Uses issue number
/test 123  # Uses issue number
/release v3.0.0 --dry-run
```

## Automation Possibilities

### GitHub Actions Integration
- Auto-label based on file changes
- Auto-assign based on code ownership
- Auto-move cards in project boards
- Auto-close with PR merges

### Webhooks
- Slack notifications for P0 bugs
- Email alerts for new features
- Update external tracking systems
- Trigger CI/CD pipelines

## Repository Setup Script
```bash
# Create standard labels
gh label create "priority:P0" --color "FF0000" --description "Critical priority"
gh label create "priority:P1" --color "FF6600" --description "High priority"
gh label create "priority:P2" --color "FFAA00" --description "Medium priority"
gh label create "priority:P3" --color "FFDD00" --description "Low priority"

gh label create "effort:quick-win" --color "00FF00" --description "Quick win (1-2 hours)"
gh label create "effort:medium" --color "00CC00" --description "Medium complexity (1-3 days)"
gh label create "effort:complex" --color "009900" --description "Complex (1-2 weeks)"
gh label create "effort:unknown" --color "006600" --description "Unknown - needs investigation"

# Create issue templates
mkdir -p .github/ISSUE_TEMPLATE
cp /path/to/templates/bug_report.yml .github/ISSUE_TEMPLATE/
cp /path/to/templates/feature_request.yml .github/ISSUE_TEMPLATE/
```