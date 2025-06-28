# Review Command

## Usage
`/review {pr-number} [--security] [--performance]`

## Description
Automated code review that validates PRs against issue requirements, checks quality standards, and ensures implementation completeness.

## Process Flow

1. **Load PR and Issue Context**
   - Fetch PR #{pr-number} details
   - Extract linked issue from PR description
   - Load issue requirements and success criteria
   - Map changed files to requirements

2. **Automated Checks**
   - Code quality and linting
   - Test coverage requirements
   - Security vulnerability scanning
   - Performance impact analysis
   - Documentation completeness

3. **Requirements Validation**
   - Check all success criteria addressed
   - Verify test coverage for requirements
   - Validate API contracts
   - Ensure error handling
   - Check accessibility compliance

4. **Generate Review Report**
   - Requirements completion status
   - Code quality metrics
   - Security findings
   - Performance analysis
   - Suggested improvements

5. **Update PR and Issue**
   - Comment detailed review on PR
   - Update issue checkboxes for completed items
   - Add review status labels
   - Request changes if needed

## Review Categories

### 1. Requirements Compliance
```markdown
## ✅ Requirements Review

### Success Criteria Coverage
- [x] "Enrich 90% of business emails within 10 seconds"
      ✓ Implemented in enrichmentService.ts:45
      ✓ Tested in enrichmentService.test.ts:67
      
- [x] "Provide minimum 5 data points per contact"  
      ✓ Validation in enrichmentValidator.ts:23
      ✓ E2E test covers this scenario
      
- [ ] "GDPR/CCPA compliant data handling"
      ❌ Missing consent check implementation
      ❌ No test for EU data handling

### Missing Requirements
1. GDPR compliance not implemented
2. Rate limiting for API calls not found
3. Bulk enrichment error handling incomplete
```

### 2. Code Quality
```markdown
## 📊 Code Quality Analysis

### Metrics
- Complexity: 8.2 (Target: <10) ✅
- Duplication: 2.1% (Target: <3%) ✅
- Test Coverage: 76% (Target: >80%) ⚠️
- Type Coverage: 94% ✅

### Issues Found
1. **Complex Method**: `enrichContact()` has cyclomatic complexity of 15
   - Consider extracting validation logic
   - Split source-specific enrichment

2. **Missing Types**: 
   - `src/api/enrichment.ts:34` - any type used
   - `src/services/queue.ts:56` - implicit any

3. **Code Smells**:
   - Duplicate API error handling in 3 files
   - Magic numbers in retry logic
```

### 3. Security Review
```markdown
## 🔒 Security Analysis

### ✅ Passed Checks
- No hardcoded credentials
- API keys in environment variables
- SQL injection protection
- XSS prevention in place

### ⚠️ Warnings
1. **Rate Limiting**: No rate limiting on enrichment endpoint
2. **Data Validation**: Email validation too permissive
3. **Audit Trail**: Missing audit log for data access

### 🚨 Critical Issues
None found

### Recommendations
- Implement rate limiting: 100 req/min per user
- Add request signing for webhook endpoints
- Enable audit logging for GDPR compliance
```

### 4. Performance Analysis
```markdown
## ⚡ Performance Review

### Database Queries
- New indexes will improve query performance
- N+1 query detected in bulkEnrich method
- Consider batch loading for relationships

### API Response Times
- Single enrichment: 342ms avg (Target: <500ms) ✅
- Bulk enrichment: 4.5s/100 records ✅
- Memory usage: +15MB per request ⚠️

### Recommendations
1. Implement connection pooling for external APIs
2. Add caching layer for repeated enrichments
3. Use streaming for bulk operations
```

### 5. Testing Review
```markdown
## 🧪 Test Analysis

### Coverage by File
- enrichmentService.ts: 89% ✅
- enrichmentController.ts: 67% ⚠️
- enrichmentQueue.ts: 45% ❌

### Test Quality
- Unit tests: Comprehensive ✅
- Integration tests: Missing error scenarios
- E2E tests: Covers happy path only

### Missing Tests
1. Error handling for API timeouts
2. Concurrent enrichment race conditions
3. Data validation edge cases
4. GDPR compliance scenarios
```

## Review Summary Format

```markdown
# 🔍 Automated Review for PR #456

**Linked Issue**: #234 - Advanced Contact Enrichment
**Status**: CHANGES REQUESTED

## Summary
- ✅ 4/6 requirements implemented
- ⚠️ Code quality issues found
- ⚠️ Test coverage below threshold (76% < 80%)
- ✅ No critical security issues
- ⚠️ Performance concerns for high load

## Required Changes
1. 🚨 Implement GDPR compliance checks
2. 🚨 Add missing test coverage (enrichmentQueue.ts)
3. ⚠️ Fix N+1 query in bulk operations
4. ⚠️ Add rate limiting to API endpoints

## Checklist Update
Updated issue #234:
- [x] Core enrichment logic ✅
- [x] API endpoints ✅
- [ ] GDPR compliance ❌
- [x] Bulk operations ✅
- [ ] Rate limiting ❌

## Next Steps
Please address required changes before merge.
```

## Options
- `--security` - Deep security analysis
- `--performance` - Detailed performance profiling
- `--quick` - Fast review (linting + tests only)
- `--auto-approve` - Approve if all checks pass

## Example Workflows

### Standard Review
```
/review 456
```

### Security-Focused Review
```
/review 456 --security
```
Output includes:
- Dependency vulnerability scan
- OWASP top 10 checks
- Authentication/authorization review
- Data encryption validation

### Performance Review
```
/review 456 --performance
```
Output includes:
- Query execution plans
- Memory profiling
- CPU usage analysis
- Bottleneck identification

## Integration Points
- Triggered by PR creation/update
- Links to issue requirements
- Updates issue checkboxes
- Integrates with CI/CD pipeline
- Can block merge if critical issues

## Review Rules Configuration

```yaml
review_rules:
  require_issue_link: true
  minimum_coverage: 80
  maximum_complexity: 10
  security_scan: required
  performance_check: warning
  
  auto_approve:
    coverage: ">= 90%"
    complexity: "< 8"
    security: "pass"
    all_tests: "pass"
    
  block_merge:
    - critical_security_issue
    - coverage "< 60%"
    - no_tests
    - missing_requirements
```

## Review Automation

The review can be automated via GitHub Actions:

```yaml
name: Automated PR Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Review
        run: claude-code review ${{ github.event.pull_request.number }}
```