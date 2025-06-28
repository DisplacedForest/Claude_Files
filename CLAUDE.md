# Development Guide for Claude - Master Template

## 🎯 Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

### Quick Reference
- **Write tests first** (TDD - Red, Green, Refactor)
- **Test behavior, not implementation**
- **No `any` types** or type assertions
- **Immutable data only**
- **Small, pure functions**
- **TypeScript strict mode always**
- **100% behavior coverage** (not just line coverage)
- **Schema-first development** with runtime validation

## ⚡ Tech Stack Configuration

```yaml
# PROJECT SPECIFIC - MODIFY THIS SECTION
Framework: [React + Express | Next.js | Vue + Node | etc.]
Language: TypeScript (strict mode)
Testing: [Jest/Vitest] + [React Testing Library | etc.]
Database: Supabase (PostgreSQL)
Vector DB: [Pinecone | Weaviate | Qdrant] # Only if needed
Schema Validation: Zod
State Management: [Context | Redux | Zustand | etc.]
Styling: [Tailwind CSS | CSS Modules | Styled Components]
Package Manager: [npm | yarn | pnpm]
```

## 📁 Repository Structure

```
/
├── frontend/              # React/Vue/Next.js application
│   ├── src/              # Frontend source code
│   │   ├── components/   # Reusable UI components
│   │   ├── features/     # Feature-based modules
│   │   ├── hooks/        # Custom React hooks
│   │   ├── lib/          # Frontend utilities
│   │   ├── schemas/      # Shared Zod schemas
│   │   └── types/        # TypeScript type definitions
│   └── tests/            # Frontend tests
├── backend/               # Express/Node.js server
│   ├── src/              # Backend source code
│   │   ├── routes/       # API route definitions
│   │   ├── services/     # Business logic layer
│   │   ├── middleware/   # Express middleware
│   │   ├── lib/          # Backend utilities
│   │   └── types/        # Backend type definitions
│   └── tests/            # Backend tests
├── shared/                # Code shared between frontend/backend
│   ├── schemas/          # Zod schemas (single source of truth)
│   ├── types/            # Shared TypeScript types
│   └── constants/        # Shared constants
├── supabase/             # Database configuration
│   ├── migrations/       # Sequential migration files
│   └── seed.sql         # Development seed data
├── docs/                 # Documentation
│   ├── features/         # Feature specs and planning
│   ├── db/              # Database documentation
│   ├── api/             # API documentation
│   ├── ADRs/            # Architectural Decision Records
│   └── audit/           # Code audit reports
├── .claude/             # AI assistant configuration
│   └── commands/        # Custom AI commands
└── [framework-specific] # Additional framework dirs
```

## 🗄️ Database Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/db/00_database_overview.md

## Architecture Philosophy
[Domain-driven design with clear boundaries]

## Database Technology
- Platform: Supabase (PostgreSQL 15+)
- Client: Supabase JS Client (@supabase/supabase-js)
- Security: Row-Level Security (RLS) policies on all user tables
- Auth: Supabase Auth (JWT tokens)
- Scaling: Connection pooling via Supabase

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → [Primary entities and purpose]
Supporting Domain → [Secondary features]
Analytics Domain  → [Tracking and metrics]

### Cross-Domain Integration Points
- Central entities referenced everywhere
- Data flow patterns between domains

## Table Naming Conventions
- Prefixes: user_*, billing_*, analytics_*
- Relationships: junction tables use both names
- Audit tables: add _history or _versions suffix

## Critical Relationships Map
[Visual or text representation of core entity relationships]

## Query Performance Guidelines
### Hot Paths (Optimize First)
- List frequently accessed queries
- Identify bottlenecks

## Business Context
[What kind of application this supports, tiers, key features]
```

### Per-Domain Schema Documentation

```markdown
# docs/db/01_[domain_name].md

> **Domain**: [Clear domain description]
> **Primary Entities**: [Main tables in this domain]
> **Security**: [RLS policies, access patterns]

## Business Context
[How this domain supports the application, key features it enables]

---

## Table Definitions

### [table_name]
**[One-line description of table purpose]**

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | uuid | NO | gen_random_uuid() | Primary key |
| [column] | [type] | YES/NO | [default] | [Business meaning, not just technical] |

**Business Rules:**
- [Key constraints and logic]
- [Validation rules]
- [Side effects or triggers]

---

## Foreign Key Relationships

| From Table | Column | References Table | References Column |
|------------|--------|------------------|-------------------|
| [table] | [column] | [table] | [column] |

---

## Common Query Patterns

### [Query Purpose]
```sql
-- Actual SQL the AI can use/modify
SELECT ... FROM ...
WHERE ...
```

---

## Performance Considerations

### Indexes
- `table(column)` - [Why this index exists]
- Composite indexes with explanation

### Scaling Notes
- Expected data volume
- Partitioning strategy if needed
```

### Database Documentation Best Practices

1. **Domain-Driven Organization**
   - Group tables by business capability
   - Minimize cross-domain queries
   - Clear ownership boundaries

2. **AI-Optimized Format**
   - Self-contained domain files
   - Business context before technical details
   - Common queries ready to use

3. **Column Descriptions Must Include**
   - Business meaning (not just "user ID")
   - Valid values/enums
   - Relationships to other data
   - Any side effects

4. **Always Document**
   - Every table with full column details
   - Business rules that affect queries
   - Performance hot paths
   - Data flow patterns
   - Security boundaries

5. **Query Examples Should**
   - Solve real business problems
   - Include JOIN patterns
   - Show parameter usage ($1, $2)
   - Demonstrate best practices

### Migration File Convention

```
/supabase/migrations/
├── 00_initial_schema.sql
├── 01_update_user_table.sql
├── 02_add_activities_table.sql
├── 03_add_billing_tables.sql
├── 04_add_indexes_performance.sql
└── 05_add_analytics_tables.sql
```

**Migration Naming Rules:**
- Sequential numbering: `00_`, `01_`, `02_` (ensures execution order)
- Descriptive names: what the migration does
- Use underscores, not camelCase
- Group related changes in single migration when possible
- Never modify existing migrations - always create new ones

### Supabase-Specific Patterns

```typescript
// Always use Supabase client for queries
import { createClient } from '@supabase/supabase-js'

// Type-safe queries with generated types
const { data, error } = await supabase
  .from('users')
  .select('*, projects(*)')
  .eq('id', userId)
  .single()

// RLS policies example
-- Enable RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- Users can only see their own projects
CREATE POLICY "Users can view own projects" ON projects
  FOR SELECT USING (auth.uid() IN (
    SELECT user_id FROM user_projects WHERE project_id = projects.id
  ));
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```typescript
// Step 1: RED - Write a failing test
describe("Payment Processing", () => {
  it("should process valid payment", () => {
    const payment = createMockPayment({ amount: 100 });
    const result = processPayment(payment);
    expect(result.success).toBe(true);
  });
});

// Step 2: GREEN - Minimal implementation
const processPayment = (payment: Payment): Result<ProcessedPayment> => {
  return { success: true, data: { ...payment, status: 'processed' } };
};

// Step 3: REFACTOR - Assess improvements
// Only refactor if it adds value. If code is clean, move on.
```

### Feature Development Process

1. **Plan**: Define feature requirements and acceptance criteria
2. **Test**: Write failing tests for each acceptance criterion
3. **Implement**: Write minimal code to pass tests
4. **Refactor**: Assess and improve code quality
5. **Document**: Update relevant documentation
6. **Commit**: Use conventional commits (NO AI signatures)

### Commit Standards

```bash
# ✅ Good commits
git commit -m "feat: add payment processing"
git commit -m "fix: correct currency conversion"
git commit -m "refactor: extract validation logic"
git commit -m "test: add edge cases for payment"

# ❌ Never include
# - "Generated with Claude"
# - "AI-assisted"
# - Any mention of AI/Claude
```

## 📐 Architecture Principles

### Schema-First Development

```typescript
// 1. Define schema first (src/schemas/payment.ts)
export const PaymentSchema = z.object({
  amount: z.number().positive(),
  currency: z.enum(['USD', 'EUR', 'GBP']),
  cardId: z.string().uuid(),
  customerId: z.string().uuid(),
});

// 2. Derive types from schema
export type Payment = z.infer<typeof PaymentSchema>;

// 3. Use at runtime boundaries
export const parsePayment = (data: unknown): Payment => {
  return PaymentSchema.parse(data);
};

// 4. CRITICAL: Tests import from shared schemas
// ❌ NEVER redefine schemas in tests
// ✅ ALWAYS import from src/schemas
import { PaymentSchema, type Payment } from '@/schemas/payment';
```

### Functional Programming Principles

```typescript
// ✅ Good: Immutable updates
const updateUser = (user: User, updates: Partial<User>): User => {
  return { ...user, ...updates };
};

// ❌ Bad: Mutation
const updateUser = (user: User, updates: Partial<User>): User => {
  Object.assign(user, updates); // Mutates!
  return user;
};
```

### Options Objects Pattern

```typescript
// ✅ Default pattern for functions
type ProcessOrderOptions = {
  order: Order;
  shipping: ShippingOptions;
  payment: PaymentOptions;
  promotions?: PromotionOptions;
};

const processOrder = (options: ProcessOrderOptions): ProcessedOrder => {
  const { order, shipping, payment, promotions = {} } = options;
  // Implementation
};

// ✅ Exceptions: Single parameter pure functions
const double = (n: number): number => n * 2;
```

## 🧪 Testing Guidelines

### Behavior-Driven Testing

```typescript
// ✅ Test behavior through public API
describe("Order Processing", () => {
  it("should apply free shipping for orders over $50", () => {
    const order = createOrder({ items: [{ price: 60 }] });
    const result = processOrder(order);
    expect(result.shipping).toBe(0);
  });
});

// ❌ Don't test implementation
it("should call calculateShipping function", () => {
  // This tests HOW not WHAT
});
```

### Test Data Factories

```typescript
// Always use factories with optional overrides
const createMockUser = (overrides?: Partial<User>): User => {
  const base = {
    id: 'user_123',
    email: 'test@example.com',
    role: 'user' as const,
    createdAt: new Date(),
  };
  
  // Validate against real schema
  return UserSchema.parse({ ...base, ...overrides });
};
```

## 💻 TypeScript Configuration

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```

### Type Guidelines

- **No `any`** - Use `unknown` if type is truly unknown
- **No type assertions** without clear justification
- **Prefer `type` over `interface`**
- **Create branded types** for domain concepts

```typescript
type UserId = string & { readonly brand: unique symbol };
type PaymentAmount = number & { readonly brand: unique symbol };
```

## 🤖 AI Assistant Collaboration

### Session Management

```markdown
## Starting a Session
1. Use TodoRead to check current tasks
2. Review recent commits for context
3. Verify working directory state
4. Ask about session goals

## During Development
- Work on one task at a time
- Mark todos as in_progress before starting
- Run tests after each implementation
- Commit working code before refactoring
- Update todos in real-time
```

### AI Safety Guidelines

```markdown
✅ AI CAN safely:
- Implement pure functions with clear specs
- Write tests for defined behaviors
- Refactor with passing tests
- Update documentation
- Create type definitions

⚠️ AI SHOULD confirm before:
- Modifying authentication/authorization
- Changing database schemas
- Updating critical business logic
- Installing new dependencies
- Modifying configuration files

❌ AI MUST NOT:
- Store secrets in code
- Remove from .env files
- Push to remote repositories
- Make architectural decisions alone
- Create files unless necessary
```

### Code Boundaries for AI

```typescript
// Use clear section markers for complex edits
export const processPayment = (payment: Payment): Result<ProcessedPayment> => {
  // === VALIDATION SECTION START ===
  const validation = validatePayment(payment);
  if (!validation.success) {
    return { success: false, error: validation.error };
  }
  // === VALIDATION SECTION END ===
  
  // === PROCESSING SECTION START ===
  const processed = executePayment(payment);
  // === PROCESSING SECTION END ===
  
  return { success: true, data: processed };
};
```

## 🚀 Development Practices

### Code Style

1. **Self-documenting code** - No comments
2. **Early returns** - No nested conditionals
3. **Small functions** - Single responsibility
4. **Descriptive names** - Variables and functions should explain themselves

### Error Handling

```typescript
// Use Result types for expected errors
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E };

// Use exceptions for unexpected errors
if (!criticalResource) {
  throw new Error("Critical resource not found");
}
```

### Refactoring Checklist

Before marking refactoring complete:
- [ ] Code improves readability (if not, don't refactor)
- [ ] All tests pass without modification
- [ ] No new public APIs added
- [ ] TypeScript strict mode passes
- [ ] Linting passes
- [ ] Committed separately from features

## ⚠️ Critical Instructions

### NEVER
- Use `any` types without justification
- Create files unless absolutely necessary
- Write production code without a failing test first
- Include AI/Claude mentions in commits
- Push to remote unless explicitly asked
- Remove from .env files (only add/comment)
- Update git config
- Create documentation unless requested

### ALWAYS
- Write tests first (TDD)
- Use TypeScript strict mode
- Import schemas from shared location in tests
- Prefer editing existing files
- Run tests after implementation
- Check database documentation before queries
- Use conventional commits
- Keep functions pure when possible

## 📋 Custom Commands

### /audit
Performs comprehensive codebase analysis across:
- Code quality and duplication
- Security vulnerabilities
- Database optimization
- Documentation gaps
- Dependency issues

### /plan [feature-name]
Creates detailed feature specification including:
- User stories and acceptance criteria
- Technical approach
- Database changes
- API endpoints
- Testing strategy

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Testing Library Principles](https://testing-library.com/docs/guiding-principles)
- [Zod Documentation](https://zod.dev)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.