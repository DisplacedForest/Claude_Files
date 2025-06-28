# Fix Command - Test-First Bug Fixing

## Usage
`/fix {bug-id | issue-number}`

## Description
**Test-Driven bug fixing workflow that writes a failing test to reproduce the bug BEFORE implementing the fix.**

This command follows TDD principles by first creating a failing test that demonstrates the bug, then implementing the minimal fix to make the test pass.

## Process Flow

1. **Bug Loading**
   - If numeric (e.g., `123`): Load GitHub issue #123
   - If bug ID (e.g., `BUG-2024-01-15-001`): Find in tracked.md, get GitHub issue number
   - Fetch full issue details including description and comments

2. **Issue Status Update**
   - Update GitHub issue labels: Set status to `In progress`
   - Add comment: "Starting investigation and fix"
   - Update local tracked.md status

3. **Investigation Phase**
   - Review issue description and acceptance criteria
   - Check investigation checklist from issue
   - Search codebase for related components
   - Attempt to reproduce the issue
   - Document findings

4. **Test-First Bug Reproduction**
   - Create fix branch: `fix/issue-{number}-{brief-description}`
   - Write failing test that reproduces the bug
   - Verify test fails (demonstrates bug exists)
   - Ensure test uses proper schemas and factories
   - Document expected vs actual behavior in test

5. **Minimal Fix Implementation**
   - Implement minimal code to make test pass
   - Follow existing patterns and schemas
   - Make only necessary changes to fix the bug
   - Verify test now passes

6. **Verification Phase**
   - Run all related test suites
   - Verify no regressions introduced
   - Test edge cases mentioned in issue
   - Update documentation if needed

7. **Completion**
   - Update tracked.md with resolution details
   - Create PR with "Fixes #123" in description
   - Update issue labels: Set status to `In review`
   - Add implementation notes to issue

## Example Workflow

### Starting from GitHub Issue
```
/fix 123
```
This will:
1. Fetch issue #123 from GitHub
2. Display bug details and acceptance criteria
3. Update status to investigating
4. Guide through fix process

### Starting from Bug ID
```
/fix BUG-2024-01-15-001
```
This will:
1. Look up bug in tracked.md
2. Find GitHub issue number (#123)
3. Proceed as above

## Output Structure
```
/docs/bugs/fixes/
  └── issue-{number}/
      ├── investigation.md    # Findings and root cause
      ├── implementation.md   # What was changed
      ├── test-plan.md       # How to verify fix
      └── pr-link.md         # Link to pull request
```

## Status Progression
1. `Ready` → `In progress` (on start)
2. `In progress` → `In review` (PR created)
3. `In review` → `Done` (PR merged)

## Integration Points
- Reads from `/add-bug` output (tracked.md)
- Uses GitHub issue as source of truth
- **Writes failing test first** (TDD approach)
- **Implements minimal fix** to make test pass
- Creates PR linking to issue
- Updates both local and GitHub tracking

## Example Investigation Output
```markdown
# Investigation: Issue #123

## Bug Summary
Contact sync fails for Gmail accounts

## Root Cause
OAuth token refresh logic was not handling Gmail's new token format introduced in v105.0.0.

## Components Affected
- ContactSync.refreshToken()
- GmailAdapter.authenticate()

## Fix Approach
Update token parsing to handle both old and new formats.

## Risks
- None identified, backward compatible

## Test-First Approach
1. **Write failing test** that reproduces the bug
2. **Implement minimal fix** to make test pass
3. **Verify fix** with additional test cases
4. **Ensure no regressions** by running full test suite

## Example Test Implementation
```typescript
// First: Write a failing test that reproduces the bug
it('should handle Gmail v105 token format', async () => {
  const newFormatToken = createMockToken({ 
    format: 'v105',
    refresh_token: 'new_format_token'
  });
  
  // This should fail before fix
  const result = await refreshToken(newFormatToken);
  expect(result.success).toBe(true);
});
```
```