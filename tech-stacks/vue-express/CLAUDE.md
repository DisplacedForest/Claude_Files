# Development Guide for Claude - Vue + Express Stack

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
# PROJECT SPECIFIC - Vue + Express Stack
Frontend: Vue 3 + Composition API
Backend: Express.js + Node.js
Language: TypeScript (strict mode)
Testing: Vitest + Vue Test Utils (frontend), Jest (backend)
Database: Supabase (PostgreSQL)
Schema Validation: Zod (shared between frontend/backend)
State Management: Pinia
Styling: Tailwind CSS + HeadlessUI
Package Manager: npm
HTTP Client: Axios (backend), fetch API (frontend)

Frontend:
  - Vue 3 (Composition API)
  - Vite (build tool)
  - Vue Router 4
  - Pinia (state management)
  - Tailwind CSS + HeadlessUI
  - VueUse (composables)
  - Vitest + Vue Test Utils (testing)

Backend:
  - Express.js + Node.js
  - Supabase (Database + Auth)
  - Zod (validation)
  - JWT tokens for auth
  - Redis (caching/sessions)
  - Helmet (security)
  - CORS middleware
  - Rate limiting

Shared:
  - TypeScript
  - Zod schemas (single source of truth)
  - Shared types and utilities
  - ESLint + Prettier
```

## 📁 Repository Structure

```
/
├── frontend/              # Vue 3 application
│   ├── src/              # Frontend source code
│   │   ├── components/   # Vue components
│   │   │   ├── ui/       # Reusable UI components
│   │   │   └── feature/  # Feature-specific components
│   │   ├── composables/  # Vue composables
│   │   ├── views/        # Route-level components
│   │   ├── stores/       # Pinia stores
│   │   ├── router/       # Vue Router configuration
│   │   ├── utils/        # Frontend utilities
│   │   ├── types/        # Frontend-specific types
│   │   └── assets/       # Static assets
│   ├── tests/            # Frontend tests
│   │   ├── unit/         # Unit tests
│   │   ├── integration/  # Integration tests
│   │   └── __mocks__/    # Test mocks
│   ├── public/           # Public assets
│   ├── vite.config.ts    # Vite configuration
│   └── package.json      # Frontend dependencies
├── backend/               # Express server
│   ├── src/              # Backend source code
│   │   ├── routes/       # Express routes
│   │   ├── controllers/  # Route controllers
│   │   ├── services/     # Business logic layer
│   │   ├── middleware/   # Express middleware
│   │   ├── models/       # Data models
│   │   ├── utils/        # Backend utilities
│   │   ├── config/       # Configuration
│   │   └── types/        # Backend-specific types
│   ├── tests/            # Backend tests
│   │   ├── unit/         # Unit tests
│   │   ├── integration/  # Integration tests
│   │   └── __mocks__/    # Test mocks
│   ├── dist/             # Compiled JavaScript (gitignored)
│   └── package.json      # Backend dependencies
├── shared/                # Code shared between frontend/backend
│   ├── schemas/          # Zod schemas (single source of truth)
│   ├── types/            # Shared TypeScript types
│   ├── utils/            # Shared utilities
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
├── docker-compose.yml   # Development environment
├── .env.example         # Environment variables template
└── package.json         # Root package.json (workspaces)
```

## 🗄️ Database Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/db/00_database_overview.md

## Architecture Philosophy
[Domain-driven design with clear API boundaries]

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

### Supabase Patterns

```typescript
// Shared Supabase client configuration
import { createClient } from '@supabase/supabase-js'
import type { Database } from '../types/database.types'

const supabaseUrl = process.env.SUPABASE_URL!
const supabaseKey = process.env.SUPABASE_ANON_KEY!

export const supabase = createClient<Database>(supabaseUrl, supabaseKey)

// Type-safe database operations
export const userService = {
  async getUser(id: string) {
    const { data, error } = await supabase
      .from('users')
      .select('*, profiles(*)')
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data
  },
  
  async createUser(userData: CreateUserRequest) {
    const { data, error } = await supabase
      .from('users')
      .insert(userData)
      .select()
      .single()
    
    if (error) throw error
    return data
  }
}

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

// Frontend test (Vitest + Vue Test Utils)
import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import PaymentForm from '@/components/PaymentForm.vue'
import { usePaymentStore } from '@/stores/payment'

describe('PaymentForm', () => {
  it('processes valid payment successfully', async () => {
    const wrapper = mount(PaymentForm)
    const paymentStore = usePaymentStore()
    
    // Given
    await wrapper.find('[data-testid="amount-input"]').setValue('100.00')
    await wrapper.find('[data-testid="currency-select"]').setValue('USD')
    
    // When
    await wrapper.find('[data-testid="submit-button"]').trigger('click')
    
    // Then
    expect(paymentStore.processPayment).toHaveBeenCalledWith({
      amount: 100.00,
      currency: 'USD'
    })
  })
})

// Backend test (Jest)
import request from 'supertest'
import { app } from '../src/app'
import { PaymentService } from '../src/services/PaymentService'

describe('POST /api/payments', () => {
  it('processes valid payment', async () => {
    const mockProcessPayment = jest.spyOn(PaymentService.prototype, 'processPayment')
      .mockResolvedValue({ success: true, paymentId: 'pay_123' })
    
    const response = await request(app)
      .post('/api/payments')
      .send({ amount: 100.00, currency: 'USD' })
      .expect(200)
    
    expect(response.body.success).toBe(true)
    expect(mockProcessPayment).toHaveBeenCalledWith({
      amount: 100.00,
      currency: 'USD'
    })
  })
})

// Step 2: GREEN - Minimal implementation

// Frontend component (Vue 3 Composition API)
<template>
  <form @submit.prevent="handleSubmit" class="space-y-4">
    <div>
      <label for="amount">Amount</label>
      <input
        id="amount"
        v-model="form.amount"
        type="number"
        step="0.01"
        data-testid="amount-input"
        required
      />
    </div>
    
    <div>
      <label for="currency">Currency</label>
      <select v-model="form.currency" data-testid="currency-select" required>
        <option value="USD">USD</option>
        <option value="EUR">EUR</option>
        <option value="GBP">GBP</option>
      </select>
    </div>
    
    <button 
      type="submit" 
      data-testid="submit-button"
      :disabled="isProcessing"
    >
      {{ isProcessing ? 'Processing...' : 'Pay Now' }}
    </button>
  </form>
</template>

<script setup lang="ts">
import { reactive } from 'vue'
import { usePaymentStore } from '@/stores/payment'
import type { PaymentRequest } from '@/types/payment'

const paymentStore = usePaymentStore()
const { processPayment, isProcessing } = paymentStore

const form = reactive<PaymentRequest>({
  amount: 0,
  currency: 'USD'
})

const handleSubmit = async () => {
  await processPayment(form)
}
</script>

// Backend route (Express + TypeScript)
import { Router } from 'express'
import { PaymentService } from '../services/PaymentService'
import { validatePaymentRequest } from '../middleware/validation'
import type { PaymentRequest, PaymentResponse } from '../../shared/types/payment'

const router = Router()
const paymentService = new PaymentService()

router.post('/payments', validatePaymentRequest, async (req, res) => {
  try {
    const paymentData: PaymentRequest = req.body
    const result = await paymentService.processPayment(paymentData)
    
    const response: PaymentResponse = {
      success: true,
      paymentId: result.paymentId
    }
    
    res.json(response)
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    })
  }
})

export { router as paymentRouter }

// Step 3: REFACTOR - Assess improvements
// Extract validation, add error handling, optimize performance
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
git commit -m "feat: add payment processing API"
git commit -m "fix: correct currency validation"
git commit -m "refactor: extract payment validation logic"
git commit -m "test: add edge cases for payment flow"

# ❌ Never include
# - "Generated with Claude"
# - "AI-assisted"
# - Any mention of AI/Claude
```

## 📐 Architecture Principles

### Schema-First Development

```typescript
// 1. Define schema first (shared/schemas/payment.ts)
import { z } from 'zod'

export const PaymentRequestSchema = z.object({
  amount: z.number().positive().max(999999.99),
  currency: z.enum(['USD', 'EUR', 'GBP']),
  cardId: z.string().uuid(),
  customerId: z.string().uuid(),
  description: z.string().optional()
})

export const PaymentResponseSchema = z.object({
  success: z.boolean(),
  paymentId: z.string().optional(),
  error: z.string().optional()
})

// 2. Derive types from schema (shared/types/payment.ts)
export type PaymentRequest = z.infer<typeof PaymentRequestSchema>
export type PaymentResponse = z.infer<typeof PaymentResponseSchema>

// 3. Use at runtime boundaries

// Backend validation middleware
import { Request, Response, NextFunction } from 'express'
import { PaymentRequestSchema } from '../../shared/schemas/payment'

export const validatePaymentRequest = (req: Request, res: Response, next: NextFunction) => {
  try {
    req.body = PaymentRequestSchema.parse(req.body)
    next()
  } catch (error) {
    res.status(400).json({
      success: false,
      error: 'Invalid payment request',
      details: error.errors
    })
  }
}

// Frontend validation (Vue composable)
import { computed } from 'vue'
import { PaymentRequestSchema } from '@/schemas/payment'
import type { PaymentRequest } from '@/types/payment'

export function usePaymentValidation(payment: Ref<PaymentRequest>) {
  const isValid = computed(() => {
    const result = PaymentRequestSchema.safeParse(payment.value)
    return result.success
  })
  
  const errors = computed(() => {
    const result = PaymentRequestSchema.safeParse(payment.value)
    return result.success ? [] : result.error.errors
  })
  
  return { isValid, errors }
}

// 4. CRITICAL: Tests import from shared schemas
// ❌ NEVER redefine schemas in tests
// ✅ ALWAYS import from shared/schemas
import { PaymentRequestSchema } from '../../../shared/schemas/payment'
```

### Functional Programming Principles

```typescript
// ✅ Good: Immutable updates (Frontend - Vue)
const updateUser = (user: User, updates: Partial<User>): User => {
  return { ...user, ...updates }
}

// Vue store with immutable state
import { defineStore } from 'pinia'
import type { User } from '@/types/user'

export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  
  const updateUser = (updates: Partial<User>) => {
    if (user.value) {
      user.value = { ...user.value, ...updates }
    }
  }
  
  return { user: readonly(user), updateUser }
})

// ✅ Good: Pure functions (Backend)
const calculateTotal = (items: OrderItem[]): number => {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0)
}

const applyDiscount = (total: number, discount: number): number => {
  return total * (1 - discount)
}

// ❌ Bad: Mutation
const updateUser = (user: User, updates: Partial<User>): User => {
  Object.assign(user, updates) // Mutates!
  return user
}
```

### API Design Patterns

```typescript
// RESTful API design with proper error handling

// Backend service layer
export class PaymentService {
  constructor(
    private paymentRepository: PaymentRepository,
    private paymentGateway: PaymentGateway
  ) {}
  
  async processPayment(request: PaymentRequest): Promise<PaymentResult> {
    const validation = PaymentRequestSchema.safeParse(request)
    if (!validation.success) {
      throw new ValidationError(validation.error.errors)
    }
    
    const payment = await this.paymentRepository.create({
      ...request,
      status: 'pending'
    })
    
    try {
      const gatewayResult = await this.paymentGateway.charge(payment)
      
      await this.paymentRepository.update(payment.id, {
        status: 'completed',
        gatewayTransactionId: gatewayResult.transactionId
      })
      
      return { success: true, paymentId: payment.id }
    } catch (error) {
      await this.paymentRepository.update(payment.id, {
        status: 'failed',
        errorMessage: error.message
      })
      throw new PaymentProcessingError(error.message)
    }
  }
}

// Frontend API client
export class PaymentAPI {
  private baseURL = '/api'
  
  async processPayment(request: PaymentRequest): Promise<PaymentResponse> {
    const response = await fetch(`${this.baseURL}/payments`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getAuthToken()}`
      },
      body: JSON.stringify(request)
    })
    
    if (!response.ok) {
      const error = await response.json()
      throw new APIError(error.message, response.status)
    }
    
    return response.json()
  }
}

// Vue composable for API integration
export function usePaymentAPI() {
  const isLoading = ref(false)
  const error = ref<string | null>(null)
  
  const processPayment = async (request: PaymentRequest) => {
    isLoading.value = true
    error.value = null
    
    try {
      const api = new PaymentAPI()
      const result = await api.processPayment(request)
      return result
    } catch (err) {
      error.value = err instanceof Error ? err.message : 'Unknown error'
      throw err
    } finally {
      isLoading.value = false
    }
  }
  
  return {
    processPayment,
    isLoading: readonly(isLoading),
    error: readonly(error)
  }
}
```

## 🧪 Testing Guidelines

### Behavior-Driven Testing

```typescript
// ✅ Frontend tests (Vitest + Vue Test Utils)
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { mount } from '@vue/test-utils'
import PaymentScreen from '@/views/PaymentScreen.vue'

describe('PaymentScreen', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
  })
  
  it('displays success message after successful payment', async () => {
    const wrapper = mount(PaymentScreen)
    
    // Given
    await wrapper.find('[data-testid="amount-input"]').setValue('100.00')
    await wrapper.find('[data-testid="currency-select"]').setValue('USD')
    
    // Mock successful API response
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({ success: true, paymentId: 'pay_123' })
    } as Response)
    
    // When
    await wrapper.find('[data-testid="submit-button"]').trigger('click')
    await wrapper.vm.$nextTick()
    
    // Then
    expect(wrapper.find('[data-testid="success-message"]').exists()).toBe(true)
  })
})

// ✅ Backend tests (Jest)
import request from 'supertest'
import { app } from '../src/app'
import { PaymentService } from '../src/services/PaymentService'

describe('Payment API', () => {
  describe('POST /api/payments', () => {
    it('returns 400 for invalid payment amount', async () => {
      const response = await request(app)
        .post('/api/payments')
        .send({ amount: -100, currency: 'USD' })
        .expect(400)
      
      expect(response.body.success).toBe(false)
      expect(response.body.error).toContain('Invalid payment request')
    })
    
    it('processes valid payment successfully', async () => {
      const mockProcessPayment = jest.spyOn(PaymentService.prototype, 'processPayment')
        .mockResolvedValue({ success: true, paymentId: 'pay_123' })
      
      const response = await request(app)
        .post('/api/payments')
        .send({
          amount: 100.00,
          currency: 'USD',
          cardId: '550e8400-e29b-41d4-a716-446655440000',
          customerId: '550e8400-e29b-41d4-a716-446655440001'
        })
        .expect(200)
      
      expect(response.body.success).toBe(true)
      expect(response.body.paymentId).toBe('pay_123')
    })
  })
})

// ❌ Don't test implementation details
it('calls PaymentGateway.charge', () => {
  // This tests HOW not WHAT - avoid this
})
```

### Test Data Factories

```typescript
// Shared test factories (both frontend and backend)
import type { User, Payment } from '../types'

export const createMockUser = (overrides: Partial<User> = {}): User => {
  return {
    id: crypto.randomUUID(),
    email: 'test@example.com',
    name: 'Test User',
    role: 'user',
    createdAt: new Date(),
    ...overrides
  }
}

export const createMockPayment = (overrides: Partial<Payment> = {}): Payment => {
  return {
    id: crypto.randomUUID(),
    amount: 100.00,
    currency: 'USD',
    status: 'pending',
    createdAt: new Date(),
    customerId: crypto.randomUUID(),
    ...overrides
  }
}

// Vue composable for test data
export function useTestData() {
  const createUser = (overrides?: Partial<User>) => createMockUser(overrides)
  const createPayment = (overrides?: Partial<Payment>) => createMockPayment(overrides)
  
  return { createUser, createPayment }
}
```

## 💻 TypeScript Configuration

```json
// Frontend tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*.ts", "src/**/*.vue"],
  "references": [{ "path": "./tsconfig.node.json" }]
}

// Backend tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020"],
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

### Type Guidelines

- **No `any`** - Use `unknown` if type is truly unknown
- **No type assertions** without clear justification
- **Prefer `type` over `interface`**
- **Create branded types** for domain concepts

```typescript
// Branded types for type safety
type UserId = string & { readonly brand: unique symbol }
type PaymentAmount = number & { readonly brand: unique symbol }

// Helper functions for branded types
export const createUserId = (id: string): UserId => id as UserId
export const createPaymentAmount = (amount: number): PaymentAmount | null => {
  return amount > 0 ? (amount as PaymentAmount) : null
}

// Union types for better error handling
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E }

// Utility types for API responses
type APIResponse<T> = Result<T, { message: string; code: string }>
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
export const processPayment = async (request: PaymentRequest): Promise<PaymentResult> => {
  // === VALIDATION SECTION START ===
  const validation = validatePaymentRequest(request)
  if (!validation.success) {
    return { success: false, error: validation.error }
  }
  // === VALIDATION SECTION END ===
  
  // === PROCESSING SECTION START ===
  const processed = await executePayment(request)
  // === PROCESSING SECTION END ===
  
  // === NOTIFICATION SECTION START ===
  await notifyPaymentProcessed(processed)
  // === NOTIFICATION SECTION END ===
  
  return { success: true, data: processed }
}
```

## 🚀 Development Practices

### Code Style

1. **Self-documenting code** - No comments unless explaining complex algorithms
2. **Early returns** - No nested conditionals
3. **Small functions** - Single responsibility
4. **Descriptive names** - Variables and functions should explain themselves

### Error Handling

```typescript
// Custom error classes
export class APIError extends Error {
  constructor(message: string, public statusCode: number) {
    super(message)
    this.name = 'APIError'
  }
}

export class ValidationError extends Error {
  constructor(public errors: ZodError[]) {
    super('Validation failed')
    this.name = 'ValidationError'
  }
}

// Result pattern for expected errors
type ProcessingResult<T> = 
  | { success: true; data: T }
  | { success: false; error: string }

// Async error handling with proper typing
const processPayment = async (request: PaymentRequest): Promise<ProcessingResult<Payment>> => {
  try {
    const validation = PaymentRequestSchema.safeParse(request)
    if (!validation.success) {
      return { 
        success: false, 
        error: `Validation failed: ${validation.error.message}` 
      }
    }
    
    const payment = await paymentService.process(validation.data)
    return { success: true, data: payment }
    
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error'
    return { success: false, error: message }
  }
}

// Vue error handling
export function useErrorHandling() {
  const error = ref<string | null>(null)
  
  const handleError = (err: unknown) => {
    if (err instanceof APIError) {
      error.value = `API Error: ${err.message}`
    } else if (err instanceof Error) {
      error.value = err.message
    } else {
      error.value = 'An unknown error occurred'
    }
  }
  
  return { error: readonly(error), handleError }
}
```

### Refactoring Checklist

Before marking refactoring complete:
- [ ] Code improves readability (if not, don't refactor)
- [ ] All tests pass without modification
- [ ] No new public APIs added
- [ ] TypeScript strict mode passes
- [ ] ESLint passes
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
- Skip TypeScript type checking
- Use `as` type assertions without clear justification

### ALWAYS
- Write tests first (TDD)
- Use TypeScript strict mode
- Import schemas from shared location in tests
- Prefer editing existing files
- Run tests after implementation (`npm test`)
- Check database documentation before queries
- Use conventional commits
- Keep functions pure when possible
- Validate data at API boundaries
- Handle errors explicitly

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

- [Vue 3 Documentation](https://vuejs.org/guide/)
- [Express.js Guide](https://expressjs.com/en/guide/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vitest Documentation](https://vitest.dev/guide/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Zod Documentation](https://zod.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.