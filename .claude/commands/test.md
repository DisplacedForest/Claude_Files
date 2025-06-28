# Test Command - Write Tests First (TDD)

## Usage
`/test {issue-number} [--watch] [--run]`

## Description
**Test-Driven Development command that writes failing tests BEFORE any implementation code exists.**

This command implements the RED phase of TDD by creating comprehensive failing tests based on GitHub issue requirements. Tests must be written first to drive the implementation.

## Core TDD Process
1. **RED**: Write failing tests (this command)
2. **GREEN**: Implement code to make tests pass (`/implement`)
3. **REFACTOR**: Improve code while keeping tests green (`/refactor`)

## Process Flow
1. **Load Issue Requirements**
   - Fetch GitHub issue #{issue-number}
   - Extract acceptance criteria and success conditions
   - Parse user stories and edge cases
   - Identify business rules and constraints

2. **Schema Generation**
   - Create or update Zod schemas from requirements
   - Generate TypeScript types from schemas
   - Validate schema against existing shared schemas
   - Ensure type safety across the codebase

3. **Test File Creation**
   - Generate test files for each acceptance criterion
   - Create test data factories using schemas
   - Write failing tests that describe expected behavior
   - Include edge cases and error conditions

4. **Test Validation**
   - Verify all tests fail initially (RED phase)
   - Ensure tests are testing behavior, not implementation
   - Validate test data factories work correctly
   - Check that tests follow naming conventions

## Options
- `--watch` - Watch mode for continuous test development
- `--run` - Run tests after writing them (to verify they fail)

## Critical TDD Rules
- **NEVER write implementation code before tests**
- **All generated tests MUST fail initially**
- **Tests describe WHAT the code should do, not HOW**
- **One test per acceptance criterion**
- **Test factories MUST use shared schemas**

## Generated Test Files Structure
```
tests/
├── {feature-name}.test.ts        # Main behavior tests
├── {feature-name}.integration.ts # Integration tests
├── factories/
│   └── {feature-name}.factory.ts # Test data factories
└── schemas/
    └── {feature-name}.schema.ts  # Zod schemas (if new)
```

## Test Requirements
- **100% behavior coverage** - Every acceptance criterion has a test
- **Failing tests only** - All tests must fail before implementation
- **Schema validation** - All test data uses Zod schemas
- **No implementation details** - Tests only describe expected behavior

## Example Generated Test File

```typescript
// tests/payment-processing.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { createMockPayment } from './factories/payment.factory';
import { PaymentSchema } from '@/schemas/payment';

describe('Payment Processing - Issue #234', () => {
  // ACCEPTANCE CRITERION: Process valid credit card payments
  it('should process valid credit card payment successfully', async () => {
    const payment = createMockPayment({ 
      amount: 100,
      currency: 'USD',
      paymentMethod: 'credit_card'
    });
    
    // This will fail until implementation exists
    const result = await processPayment(payment);
    
    expect(result.success).toBe(true);
    expect(result.data.status).toBe('completed');
    expect(result.data.transactionId).toBeDefined();
  });

  // ACCEPTANCE CRITERION: Handle insufficient funds
  it('should reject payment when insufficient funds', async () => {
    const payment = createMockPayment({ 
      amount: 1000000,
      paymentMethod: 'credit_card'
    });
    
    // This will fail until implementation exists
    const result = await processPayment(payment);
    
    expect(result.success).toBe(false);
    expect(result.error.code).toBe('INSUFFICIENT_FUNDS');
  });
});
```

## Workflow Integration
- **Follows `/plan`** - Reads detailed specifications
- **Precedes `/implement`** - Must run before any code is written
- **Enables `/implement`** - Provides failing tests to make pass
- **Required for `/fix`** - Bug fixes must have failing tests first

## Status Updates
- Updates GitHub issue status to "In Progress - Tests Written"
- Adds comment with test file links
- Marks acceptance criteria as "Test Ready"