# Release Command

## Usage
`/release {version} [--dry-run] [--hotfix]`

## Description
Manages the release process with automated checks, changelog generation, and deployment coordination.

## Process Flow

1. **Pre-Release Validation**
   - Verify all tests passing
   - Check no critical bugs in "Ready" status
   - Validate all "In review" items are merged
   - Ensure documentation is updated
   - Verify dependency security

2. **Gather Release Items**
   - Find all issues with status "Done" since last release
   - Categorize by type (features, bugs, improvements)
   - Extract breaking changes
   - Calculate effort metrics

3. **Generate Changelog**
   - Create CHANGELOG.md entry
   - Group by category
   - Link to GitHub issues
   - Include breaking changes section
   - Add contributor credits

4. **Version Updates**
   - Update version in package.json
   - Update version in documentation
   - Update API version if needed
   - Tag database migrations

5. **Create Release**
   - Create git tag
   - Generate GitHub release
   - Close included issues
   - Move issues to "Released" milestone
   - Trigger deployment pipeline

6. **Post-Release**
   - Update project boards
   - Send release notifications
   - Archive release metrics
   - Create next version milestone

## Changelog Format

```markdown
# Changelog

## [2.1.0] - 2024-01-15

### 🎉 New Features
- **Advanced Contact Enrichment** (#234) - Automatic enrichment from multiple sources
- **Bulk Import** (#245) - CSV import with validation

### 🐛 Bug Fixes  
- **Fixed login timeout** (#123) - Sessions now persist correctly
- **Export corruption** (#156) - UTF-8 characters now handled properly

### 🔧 Improvements
- **Performance: API response time** (#267) - 40% faster responses
- **UI: Loading states** (#289) - Better user feedback

### 💥 Breaking Changes
- API: `/contacts/list` now requires pagination parameters
- Database: Removed deprecated `user_profiles` table

### 📊 Release Stats
- Issues Closed: 15
- Contributors: 3
- Total Effort: 45 story points
- Days Since Last Release: 14

### 🙏 Contributors
- @john-doe - 8 issues
- @jane-smith - 5 issues  
- @bob-wilson - 2 issues
```

## Version Strategy

### Semantic Versioning
- **Major (X.0.0)**: Breaking changes
- **Minor (0.X.0)**: New features, backward compatible
- **Patch (0.0.X)**: Bug fixes only

### Version Calculation
```
IF breaking_changes THEN increment MAJOR
ELSE IF new_features THEN increment MINOR  
ELSE increment PATCH
```

## Safety Checks

### Required Checks
- [ ] All tests passing
- [ ] No security vulnerabilities
- [ ] Documentation updated
- [ ] Migration tested
- [ ] Performance benchmarks pass

### Deployment Readiness
```yaml
ready_to_release:
  tests:
    unit: passing
    integration: passing
    e2e: passing
  coverage: ">= 80%"
  security_scan: clean
  documentation: updated
  breaking_changes: documented
```

## Options
- `--dry-run` - Preview release without creating
- `--hotfix` - Fast-track critical fixes
- `--include {issue}` - Force include specific issue
- `--exclude {issue}` - Exclude specific issue

## TDD Requirement
**All tests must pass before release.** This is non-negotiable and aligns with our test-driven development principles. No skip-tests option is provided to maintain code quality standards.

## Example Workflows

### Standard Release
```
/release 2.1.0
```
Output:
```
📦 Preparing Release v2.1.0

✅ Pre-Release Checks:
  - Tests: PASSED (1,245 tests)
  - Security: CLEAN
  - Documentation: UPDATED
  - Breaking Changes: NONE

📋 Included Issues (15):
  Features (3):
    - #234: Advanced Contact Enrichment
    - #245: Bulk Import
    - #256: API Rate Limiting
    
  Bugs (8):
    - #123: Fixed login timeout
    - #156: Export corruption
    ... 6 more
    
  Improvements (4):
    - #267: API performance
    ... 3 more

📝 Changelog generated: CHANGELOG.md
🏷️  Version updated: 2.0.0 → 2.1.0
🚀 GitHub Release created: v2.1.0
✅ Issues updated: 15 closed, moved to v2.1.0 milestone

🎉 Release v2.1.0 completed successfully!
```

### Hotfix Release
```
/release 2.0.1 --hotfix
```
Output:
```
🚨 Hotfix Release v2.0.1

⚡ Fast-track mode enabled
✅ Critical bug #301 verified fixed
📝 Hotfix changelog generated
🚀 Deployed to production

Hotfix v2.0.1 released in 5 minutes
```

### Dry Run
```
/release 3.0.0 --dry-run
```
Output:
```
🔍 Dry Run: Release v3.0.0

Would include:
  - 25 features
  - 14 bug fixes
  - 3 BREAKING CHANGES

⚠️  Breaking Changes Detected:
  1. API: Removed v1 endpoints (#345)
  2. Database: Changed user schema (#356)
  3. Config: New format required (#367)

📊 Impact Analysis:
  - Estimated migration time: 2 hours
  - Affected services: API, Auth, Reports
  - Customer impact: HIGH - requires migration

No changes made. Run without --dry-run to proceed.
```

## Release Metrics

### Tracked Metrics
- Time since last release
- Number of issues included
- Story points delivered
- Bug fix percentage
- Average issue age
- Contributor count

### Release Report
```yaml
release_v2.1.0:
  date: "2024-01-15"
  stats:
    issues_closed: 15
    features: 3
    bugs: 8
    improvements: 4
    story_points: 45
    contributors: 3
    days_since_last: 14
    average_issue_age: "7 days"
  performance:
    build_time: "3m 24s"
    test_time: "5m 12s"
    deploy_time: "2m 45s"
  quality:
    test_coverage: "84.3%"
    code_quality: "A"
    security_score: "98/100"
```

## Integration Points
- Uses `/test` results for validation
- Reads from GitHub issues and milestones
- Updates issue status to "Released"
- Triggers deployment pipelines
- Creates git tags and GitHub releases
- Updates project documentation

## Rollback Plan

If issues arise post-release:

1. **Quick Rollback**
   ```bash
   git revert --no-commit v2.1.0
   /release 2.0.2 --hotfix
   ```

2. **Database Rollback**
   - Migration rollback scripts included
   - Point-in-time recovery available

3. **Feature Flags**
   - Disable features without rollback
   - Gradual rollout supported