# Audit Command

## Usage
`/audit`

## Description
Performs a comprehensive audit of the codebase to identify issues and improvement opportunities.

## Audit Scope
1. **Code Quality**
   - Identify code duplication
   - Find unused imports/variables
   - Check for consistent naming conventions
   - Verify TypeScript strict mode compliance

2. **Security**
   - Scan for hardcoded credentials
   - Check for exposed API keys
   - Verify secure data handling
   - Review authentication/authorization implementation

3. **Database**
   - Analyze table structure for redundancies
   - Check for missing indexes
   - Verify foreign key relationships
   - Document current schema

4. **Documentation**
   - Verify all features are documented
   - Check for outdated documentation
   - Ensure API endpoints are documented
   - Validate database documentation matches schema

5. **Dependencies**
   - Check for outdated packages
   - Identify security vulnerabilities
   - Find unused dependencies
   - Verify license compliance

## Output
Creates `/docs/audit/audit-{timestamp}.md` with:
- Executive summary of findings
- Detailed issues by category
- Risk assessment (High/Medium/Low)
- Mitigation plan with priorities
- Estimated effort for fixes

## Example Output Structure
```markdown
# Codebase Audit - {date}

## Executive Summary
- Total issues found: X
- High priority: X
- Medium priority: X
- Low priority: X

## Critical Issues
### 1. Hardcoded API Key in backend/src/config.ts
- Risk: High
- File: backend/src/config.ts:45
- Mitigation: Move to environment variable
- Effort: 15 minutes

## Redundancies
### 1. Duplicate User Type Definition
- Files: backend/types/user.ts, frontend/types/user.ts
- Mitigation: Use shared types package
- Effort: 30 minutes

## Mitigation Plan
1. Week 1: Address all high-priority security issues
2. Week 2: Fix database redundancies
3. Week 3: Update documentation
```