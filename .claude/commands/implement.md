# Implement Command - Make Tests Pass (TDD)

## Usage
`/implement {issue-number} [--phase {phase-number}]`

## Description
**Test-Driven Development command that implements code to make existing failing tests pass.**

This command implements the GREEN phase of TDD by reading failing tests and writing minimal code to make them pass. Tests must already exist before running this command.

## Core TDD Process
1. **RED**: Write failing tests (`/test` command)
2. **GREEN**: Implement code to make tests pass (this command)
3. **REFACTOR**: Improve code while keeping tests green (`/refactor`)

## Process Flow
1. **Verify TDD Prerequisites**
   - Load GitHub issue #{issue-number}
   - Verify failing tests exist (fail if not)
   - Confirm tests are running and failing
   - Check test coverage of acceptance criteria
   - Ensure no implementation code exists yet

2. **GitHub Issue Update**
   - Update labels: Set status to `In progress`
   - Add comment: "Starting implementation of {phase or full feature}"
   - Review acceptance criteria from issue

3. **Pre-Implementation Setup**
   - Create feature branch: `feature/issue-{number}-{brief-description}`
   - Analyze codebase for integration points
   - Verify dependencies from issue are available
   - Check for conflicts with current work
   - Set up development environment

4. **Generate Implementation Checklist**
   - Convert success criteria to development tasks
   - Extract technical requirements as subtasks
   - Order by dependency and phase
   - Map to specific files/components
   - Include test requirements for each task

5. **Implementation Tracking**
   - Create `/docs/features/implementation/issue-{number}-progress.md`
   - Check off completed items in GitHub issue
   - Log technical decisions and trade-offs
   - Track test coverage per component
   - Comment progress updates on issue

6. **Test-Driven Implementation**
   - Read failing tests to understand expected behavior
   - Implement minimal code to make tests pass
   - Follow schemas already defined in tests
   - Use existing patterns from codebase
   - Write only enough code to turn tests green
   - No premature optimization or extra features

7. **TDD Validation**
   - Run tests to confirm they now pass
   - Verify no tests were broken
   - Check TypeScript strict mode compliance
   - Ensure functional programming principles
   - Validate schema usage matches tests

## Options
- `--phase {number}` - Implement specific phase only
- `--minimal` - Write only minimal code to pass tests
- `--interactive` - Step-by-step confirmation mode

## Critical TDD Rules
- **NEVER implement without failing tests first**
- **Write minimal code to make tests pass**
- **Don't add features not covered by tests**
- **Use schemas and types from test files**
- **Follow functional programming patterns**

## Example Workflows

### Basic Implementation
```
/implement 234
```
This will:
1. Fetch issue #234 from GitHub
2. Verify it's in `Ready` status
3. Parse requirements and success criteria
4. Generate implementation checklist
5. Create file scaffolding
6. Update status to `In progress`

### Phase-Specific Implementation
```
/implement 234 --phase 1
```
This will:
1. Load issue #234
2. Extract Phase 1 tasks only
3. Generate relevant files for phase
4. Create phase-specific tests
5. Track phase progress separately

## Output Structure
```
/docs/features/implementation/
  └── issue-{number}/
      ├── progress.md      # Implementation tracking
      ├── decisions.md     # Technical decisions log  
      ├── checklist.md     # Tasks mapped to issue requirements
      └── generated.md     # List of generated files

/src/
  ├── api/
  │   └── [Generated endpoints]
  ├── services/
  │   └── [Generated services]
  ├── models/
  │   └── [Generated models]
  └── components/
      └── [Generated UI components]

/tests/
  └── [Mirrored test structure]

/migrations/
  └── [Generated database migrations]
```

## Status Progression
1. `Ready` → `In progress` (on start)
2. `In progress` → `In review` (PR created)
3. `In review` → `Done` (after merge and deployment)

## Integration Points
- **Requires `/test` to be run first** - No implementation without failing tests
- Links with `/plan` output and GitHub issues
- Reads test files to understand expected behavior
- Makes existing failing tests pass
- Updates `/audit` tracking
- Can trigger `/migrate` for database changes
- Creates PR referencing issue

## Example Generated Files

### Reading Existing Tests to Drive Implementation

```typescript
// First, read the failing test to understand expected behavior:
// tests/payment-processing.test.ts (written by /test command)
describe('Payment Processing - Issue #234', () => {
  it('should process valid credit card payment successfully', async () => {
    const payment = createMockPayment({ 
      amount: 100,
      currency: 'USD',
      paymentMethod: 'credit_card'
    });
    
    const result = await processPayment(payment);
    
    expect(result.success).toBe(true);
    expect(result.data.status).toBe('completed');
    expect(result.data.transactionId).toBeDefined();
  });
});
```

```typescript
// Then implement minimal code to make the test pass:
// src/services/payment-processing.ts
import { Payment, ProcessedPayment, Result } from '@/schemas/payment';

export const processPayment = async (payment: Payment): Promise<Result<ProcessedPayment>> => {
  // Minimal implementation to make test pass
  const processedPayment: ProcessedPayment = {
    ...payment,
    status: 'completed',
    transactionId: crypto.randomUUID(),
    processedAt: new Date()
  };

  return {
    success: true,
    data: processedPayment
  };
};
```

```typescript
// Factory and schema were already created by /test command:
// tests/factories/payment.factory.ts
import { PaymentSchema, type Payment } from '@/schemas/payment';

export const createMockPayment = (overrides?: Partial<Payment>): Payment => {
  const base = {
    amount: 100,
    currency: 'USD' as const,
    paymentMethod: 'credit_card' as const,
    customerId: 'cust_123',
    cardId: 'card_456'
  };
  
  return PaymentSchema.parse({ ...base, ...overrides });
};
```

## Example Progress Tracking

```markdown
# Implementation Progress: Issue #234 - Advanced Contact Enrichment

**Status**: In Progress  
**Branch**: feature/issue-234-contact-enrichment
**Started**: 2024-01-15

## GitHub Issue Checklist Sync

### Phase 1: Core Infrastructure ✅
- [x] Design enrichment service architecture
- [x] Set up job queue system  
- [x] Create enrichment data models
- [ ] Build rate limiter for APIs
- [ ] Implement basic Clearbit integration

### Phase 2: Multi-source Integration 🚧
- [ ] Add Hunter.io integration
- [ ] Add LinkedIn integration (blocked - awaiting API access)
- [ ] Build data conflict resolution
- [ ] Create quality scoring algorithm
- [ ] Implement caching layer

## Generated Files
- ✅ src/api/contacts/enrichment.ts
- ✅ src/services/enrichment/enrichmentService.ts
- ✅ src/services/enrichment/types.ts
- ✅ src/models/EnrichedContact.ts
- ✅ src/queue/enrichmentQueue.ts
- ✅ tests/services/enrichment/*.test.ts
- ⏳ migrations/20240115_add_enrichment_tables.sql

## Technical Decisions
1. **Architecture**: Microservice pattern for enrichment to isolate API dependencies
2. **Queue**: Redis-based queue to handle rate limits and retries
3. **Storage**: Separate enrichment_data table to maintain audit trail
4. **Caching**: 24-hour Redis cache to reduce API costs

## Blockers
- LinkedIn API access pending legal review
- Clearbit contract negotiation for enterprise tier
```