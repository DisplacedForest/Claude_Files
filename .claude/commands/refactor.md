# /refactor Command

## Overview
The `/refactor` command provides a structured approach to safely refactoring code based on GitHub issue requirements. It analyzes impact, creates rollback plans, and ensures no regressions through comprehensive testing.

## Usage
```
/refactor {issue-number}
```

## Description
Loads refactoring requirements from a GitHub issue, analyzes the impact across the codebase, creates a safe refactoring plan with rollback options, and tracks progress while ensuring no regressions occur.

## Process Flow

### 1. Load Requirements
- Fetch refactoring requirements from GitHub issue
- Validate issue is labeled as 'refactoring' and status is 'Ready'
- Extract acceptance criteria and constraints

### 2. Impact Analysis
- Identify all affected files and dependencies
- Map function/class usage across codebase
- Analyze test coverage for affected areas
- Estimate complexity and risk level

### 3. Create Refactoring Plan
- Break down into atomic, reversible steps
- Define rollback procedures for each step
- Establish performance benchmarks
- Create test strategy for validation

### 4. Implement Safely
- Execute refactoring in small, testable increments
- Run tests after each step
- Monitor performance metrics
- Document changes and decisions

### 5. Update Status
- Update GitHub issue from 'Ready' to 'In Progress'
- Post progress comments with completed steps
- Track any discovered issues or scope changes

## Safety Checks

### Pre-Refactoring
- **Test Coverage**: Ensure adequate test coverage (>80%) for affected code
- **Baseline Metrics**: Capture performance benchmarks
- **Dependency Check**: Verify no breaking changes to public APIs
- **Backup State**: Create branch/tag for rollback reference

### During Refactoring
- **Incremental Testing**: Run tests after each atomic change
- **Performance Monitoring**: Compare against baseline metrics
- **Code Review**: Self-review each step before proceeding
- **Regression Detection**: Watch for unexpected behavior changes

### Post-Refactoring
- **Full Test Suite**: Run complete test suite
- **Performance Validation**: Ensure no performance degradation
- **Integration Testing**: Verify downstream dependencies work
- **Documentation Update**: Update any affected documentation

## Output Structure

### Refactoring Plan
```yaml
refactoring_plan:
  issue_number: 123
  risk_level: medium
  estimated_hours: 8
  
  steps:
    - id: step_1
      description: "Extract validation logic to separate module"
      files_affected:
        - src/api/users.py
        - src/api/products.py
      rollback_procedure: "Revert commit {commit_hash}"
      tests_required:
        - test_user_validation
        - test_product_validation
      
    - id: step_2
      description: "Consolidate duplicate error handling"
      dependencies: [step_1]
      files_affected:
        - src/utils/errors.py
      rollback_procedure: "Restore original error handlers"
```

### Impact Analysis
```yaml
impact_analysis:
  affected_modules:
    - name: user_service
      impact: direct
      test_coverage: 85%
      risk: low
      
    - name: payment_processor
      impact: indirect
      test_coverage: 92%
      risk: medium
      
  performance_impact:
    expected: neutral
    areas_to_monitor:
      - API response time
      - Database query count
      
  breaking_changes: []
  
  dependency_graph:
    user_service:
      depends_on: [auth_module, database]
      depended_by: [api_gateway, reporting]
```

### Rollback Procedures
```yaml
rollback_procedures:
  quick_rollback:
    method: "git revert"
    commands:
      - git revert {commit_range}
      - npm test
      - npm run deploy
    estimated_time: 15min
    
  full_rollback:
    method: "restore from tag"
    commands:
      - git checkout pre-refactor-{issue_number}
      - git checkout -b rollback-{issue_number}
      - npm install
      - npm test
    estimated_time: 30min
    
  partial_rollback:
    available_for: [step_1, step_2, step_4]
    procedure: "See individual step rollback procedures"
```

## Example Workflows

### Simple Module Extraction
```bash
/refactor 156

# Output:
Analyzing refactoring requirements for issue #156...

Impact Analysis:
- 3 files directly affected
- 12 files with imports to update
- Current test coverage: 78%
- Risk level: LOW

Refactoring Plan:
Step 1: Create new auth_utils module
Step 2: Move authentication functions
Step 3: Update imports in affected files
Step 4: Remove old code and clean up

Safety checks:
✓ All affected code has tests
✓ No breaking API changes detected
✓ Performance impact: Neutral

Proceed with refactoring? [Y/n]
```

### Complex System Refactoring
```bash
/refactor 289

# Output:
Analyzing refactoring requirements for issue #289...

⚠️ HIGH RISK REFACTORING DETECTED

Impact Analysis:
- 47 files directly affected
- 156 files with potential impacts
- Critical paths affected: payment, authentication
- Current test coverage: 72% (Below recommended 80%)

Recommendations:
1. Increase test coverage to 80% before proceeding
2. Schedule refactoring during low-traffic window
3. Have rollback plan ready
4. Consider feature flags for gradual rollout

Generated comprehensive plan with 12 steps...
View full plan? [Y/n]
```

### Performance-Critical Refactoring
```bash
/refactor 312

# Output:
Loading performance refactoring requirements...

Baseline Performance Metrics:
- Average response time: 145ms
- P95 response time: 320ms
- Database queries per request: 8.2

Refactoring Goals:
- Reduce database queries by 50%
- Improve response time by 30%

Performance Test Plan:
1. Load test current implementation
2. Implement query optimization
3. Measure after each change
4. Stress test final implementation

Monitoring dashboard created at: /metrics/refactor-312
```

## Integration with Other Commands

### With /test
```bash
# After refactoring step completion
/test --scope=affected --coverage-threshold=80

# Validates refactoring hasn't broken anything
```

### With /architect
```bash
# Before complex refactoring
/architect review --focus=refactoring-impact

# Provides architectural guidance for refactoring
```

### With /implement
```bash
# For implementing refactoring steps
/implement --type=refactoring --step=2

# Implements specific refactoring step with safety checks
```

### With /document
```bash
# After refactoring completion
/document --scope=refactored-modules

# Updates documentation for refactored code
```

## Best Practices

### Planning
- Always analyze impact before starting
- Break large refactorings into multiple PRs
- Ensure adequate test coverage exists
- Document the "why" behind refactoring decisions

### Execution
- Make atomic, reversible commits
- Test after each significant change
- Keep refactoring separate from feature changes
- Use feature flags for risky changes

### Validation
- Run full test suite frequently
- Monitor performance metrics
- Get code review at checkpoints
- Verify no behavior changes (unless intended)

### Communication
- Update issue with progress regularly
- Document any scope changes
- Communicate risks to stakeholders
- Create rollback communication plan

## Error Handling

### Insufficient Test Coverage
```
Error: Test coverage (65%) below minimum threshold (80%)

Suggested actions:
1. Run: /test generate --for=uncovered-code
2. Increase coverage before refactoring
3. Or accept risk with: /refactor 123 --force --accept-risk
```

### Breaking Changes Detected
```
Warning: Potential breaking changes detected in public API

Affected endpoints:
- POST /api/users (parameter renamed)
- GET /api/products (response format changed)

Options:
1. Create compatibility layer
2. Version the API
3. Coordinate with consumers
```

### Performance Regression
```
Alert: Performance regression detected after step 3

Metrics:
- Response time increased by 23%
- Memory usage up by 15%

Automatic rollback initiated...
Investigating root cause...
```

## Configuration

### .refactor.yml
```yaml
refactoring:
  safety_checks:
    minimum_test_coverage: 80
    require_performance_benchmarks: true
    max_risk_level: high
    
  rollback:
    auto_rollback_on_regression: true
    keep_rollback_branches: 7d
    
  monitoring:
    performance_threshold: 10  # percent degradation allowed
    error_rate_threshold: 0.1  # percent increase allowed
    
  notifications:
    slack_channel: "#refactoring"
    notify_on: [start, completion, rollback, error]
```

## Metrics and Reporting

### Refactoring Metrics
- Time to complete vs. estimate
- Number of rollbacks required
- Test coverage before/after
- Performance impact
- Lines of code changed
- Cyclomatic complexity reduction

### Success Indicators
- No production incidents
- Performance maintained or improved
- Test coverage increased
- Code complexity reduced
- Developer velocity improved

### Report Generation
```bash
/refactor report --issue=123

# Generates comprehensive report of refactoring outcomes
```