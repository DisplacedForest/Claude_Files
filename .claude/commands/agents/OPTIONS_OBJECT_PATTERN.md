# Options Object Pattern Guidelines

This document establishes the official guidelines for using the options object pattern across all agent-generated code.

## Core Principle


"Functions should use options objects except for single-parameter pure functions."

## Why Options Objects?

1. **Extensibility**: Easy to add new parameters without breaking existing calls
2. **Clarity**: Named parameters are self-documenting
3. **Flexibility**: Optional parameters with defaults are cleaner
4. **Maintainability**: Refactoring is safer with named parameters
5. **Type Safety**: TypeScript provides better IntelliSense

## The Pattern

### ✅ Required: Multi-Parameter Functions

```typescript
// Define the options type
type CreateUserOptions = {
  email: string;
  password: string;
  profile?: UserProfile;
  sendWelcomeEmail?: boolean;
};

// Use in function signature
export const createUser = async (options: CreateUserOptions): Promise<Result<User>> => {
  const { 
    email, 
    password, 
    profile = {}, 
    sendWelcomeEmail = true 
  } = options;
  
  // Implementation
};

// Usage
const user = await createUser({
  email: 'user@example.com',
  password: 'secure123',
  sendWelcomeEmail: false
});
```

### ❌ Avoid: Multiple Positional Parameters

```typescript
// DON'T DO THIS
export const createUser = async (
  email: string,
  password: string,
  profile?: UserProfile,
  sendWelcomeEmail?: boolean
): Promise<Result<User>> => {
  // Hard to read, easy to mix up parameters
};

// Usage is error-prone
const user = await createUser(
  'user@example.com',
  'secure123',
  undefined,  // What is this?
  false       // And this?
);
```

## Exceptions: Single-Parameter Pure Functions

### ✅ Allowed Exceptions

```typescript
// Pure transformations
export const toLowerCase = (str: string): string => str.toLowerCase();
export const double = (n: number): number => n * 2;

// Simple validations
export const isEmail = (email: string): boolean => emailRegex.test(email);
export const isPositive = (n: number): boolean => n > 0;

// Type guards
export const isUser = (value: unknown): value is User => {
  return typeof value === 'object' && 'email' in value;
};

// Single-value getters
export const getUserId = (user: User): string => user.id;

// Event handlers
const handleClick = (event: MouseEvent): void => {
  event.preventDefault();
};
```

### ⚠️ Borderline Cases

If a function might need additional parameters in the future, use options object:

```typescript
// Current need: Just hash password
export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, 10);
};

// But if you might need configuration later, use options:
type HashPasswordOptions = {
  password: string;
  rounds?: number;  // Might add this later
};

export const hashPassword = async (options: HashPasswordOptions): Promise<string> => {
  const { password, rounds = 10 } = options;
  return bcrypt.hash(password, rounds);
};
```

## Framework-Specific Patterns

### React Components

React component props are already an options object:

```typescript
// ✅ Props are an options object
type ButtonProps = {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
};

export const Button = ({ label, onClick, variant = 'primary', disabled = false }: ButtonProps) => {
  // Component implementation
};

// Usage
<Button 
  label="Submit" 
  onClick={handleSubmit}
  variant="primary"
/>
```

### Express Route Handlers

Route handlers have fixed signatures, but service functions should use options:

```typescript
// Route handler (fixed signature)
router.post('/users', async (req, res) => {
  // Service function uses options object
  const result = await userService.createUser({
    email: req.body.email,
    password: req.body.password,
    profile: req.body.profile
  });
  
  res.json(result);
});
```

### Test Factories

Test factories should always use options for flexibility:

```typescript
// ✅ Good: Options object allows partial overrides
type CreateMockUserOptions = {
  overrides?: Partial<User>;
  includeProfile?: boolean;
  includeSettings?: boolean;
};

export const createMockUser = (options: CreateMockUserOptions = {}): User => {
  const { overrides = {}, includeProfile = false, includeSettings = false } = options;
  // Implementation
};

// Usage is clear and flexible
const user = createMockUser({
  overrides: { email: 'custom@test.com' },
  includeProfile: true
});
```

## Common Patterns

### Optional Parameters with Defaults

```typescript
type SearchOptions = {
  query: string;
  filters?: SearchFilters;
  pagination?: {
    page?: number;
    limit?: number;
  };
  sortBy?: 'relevance' | 'date' | 'rating';
};

export const searchRecipes = async (options: SearchOptions): Promise<SearchResult> => {
  const {
    query,
    filters = {},
    pagination = { page: 1, limit: 20 },
    sortBy = 'relevance'
  } = options;
  
  // Implementation
};
```

### Nested Options

For complex operations, nest related options:

```typescript
type ProcessOrderOptions = {
  order: Order;
  payment: {
    method: PaymentMethod;
    saveCard?: boolean;
  };
  shipping: {
    address: Address;
    method: ShippingMethod;
    insurance?: boolean;
  };
  notifications?: {
    email?: boolean;
    sms?: boolean;
  };
};
```

### Builder Pattern Alternative

When options get very complex, consider a builder pattern:

```typescript
class QueryBuilder {
  private options: QueryOptions = {};
  
  select(fields: string[]): this {
    this.options.select = fields;
    return this;
  }
  
  where(conditions: WhereConditions): this {
    this.options.where = conditions;
    return this;
  }
  
  orderBy(field: string, direction: 'asc' | 'desc' = 'asc'): this {
    this.options.orderBy = { field, direction };
    return this;
  }
  
  build(): QueryOptions {
    return this.options;
  }
}

// Usage
const query = new QueryBuilder()
  .select(['id', 'name', 'email'])
  .where({ active: true })
  .orderBy('createdAt', 'desc')
  .build();
```

## Migration Guide

### Converting Existing Functions

```typescript
// Before: Multiple parameters
export const updateUser = async (
  userId: string,
  updates: Partial<User>,
  notify: boolean = true
): Promise<User> => {
  // Implementation
};

// After: Options object
type UpdateUserOptions = {
  userId: string;
  updates: Partial<User>;
  notify?: boolean;
};

export const updateUser = async (options: UpdateUserOptions): Promise<User> => {
  const { userId, updates, notify = true } = options;
  // Implementation (unchanged)
};

// Update all callers
// Before: updateUser('123', { name: 'Jane' }, false)
// After:  updateUser({ userId: '123', updates: { name: 'Jane' }, notify: false })
```

## Enforcement Checklist

When reviewing functions, ask:

- [ ] Does the function have multiple parameters?
- [ ] Is it a pure function with a single parameter?
- [ ] Could the function need additional parameters in the future?
- [ ] Are the parameters clearly named in an options type?
- [ ] Are optional parameters properly defaulted?
- [ ] Is the options parameter properly destructured?

## Benefits in Practice

### Before (Confusion)
```typescript
// What do these parameters mean?
processPayment(order, true, false, 3, 'USD', null, true);
```

### After (Clarity)
```typescript
processPayment({
  order,
  validateCard: true,
  saveCard: false,
  retryAttempts: 3,
  currency: 'USD',
  notifications: { email: true }
});
```

## Summary

The options object pattern is mandatory for all functions except single-parameter pure functions. This consistency leads to:

- More maintainable code
- Better developer experience
- Safer refactoring
- Self-documenting function calls
- Easier testing

When in doubt, use an options object. The small overhead in defining the type is worth the long-term benefits.