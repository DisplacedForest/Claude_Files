# File Creation Policy for Multi-Agent System

This document establishes the official policy for when agents should create new files versus editing existing ones.

## Core Principle

**"NEVER create files unless absolutely necessary. ALWAYS prefer editing existing files."**

## Universal Rules for All Agents

### 1. Check Before Create

```javascript
// ALWAYS do this check before any file creation
if (fileExists(targetPath)) {
  // EDIT the existing file
  Edit(targetPath, oldContent, newContent);
} else {
  // Continue to decision tree below
}
```

### 2. Decision Tree for File Creation

```
Does the file exist?
├─ YES → EDIT the existing file
└─ NO → Can similar file be extended?
    ├─ YES → EDIT that file instead
    └─ NO → Is file absolutely necessary?
        ├─ YES → CREATE with justification
        └─ NO → DO NOT create
```

### 3. Files That Should ALWAYS Be Created

These files are exceptions and should be created as needed:

1. **Status Files** - Required for agent coordination
   - `issue-<feature>/.status/<agent>.status`

2. **Summary Files** - Required for inter-agent communication
   - `issue-<feature>/summaries/<agent>_summary.md`

3. **Initial Migration Files** - When no table exists
   - `supabase/migrations/01_create_<table>.sql`

4. **New Domain Documentation** - When truly new domain
   - `docs/db/XX_<new_domain>.md`

## Agent-Specific Guidelines

### Backend Developer

**Check First:**
- Existing service files that could be extended
- Base classes or utilities that could be inherited
- Similar endpoints that could be grouped

**Only Create When:**
- New business domain with no related service
- New API resource with distinct responsibility
- Required by framework conventions

**Example:**
```javascript
// Need: User profile endpoints
// ❌ BAD: Create userProfileService.ts
// ✅ GOOD: Add to existing userService.ts
```

### Frontend Developer

**Check First:**
- Generic components that could be specialized
- Similar components that could be parameterized
- Base components that could be extended

**Only Create When:**
- No existing component can be reasonably extended
- Component represents truly unique UI pattern
- Performance requires component splitting

**Example:**
```javascript
// Need: Recipe card display
// ❌ BAD: Create RecipeCard.tsx when Card.tsx exists
// ✅ GOOD: Extend or wrap existing Card component
```

### Database Architect

**Check First:**
- Existing migrations that haven't been deployed
- Tables that could be extended with columns
- Existing documentation that covers the domain

**Only Create When:**
- New table is required
- Production migration for schema changes
- New business domain not covered in docs

**Example:**
```sql
-- Need: Add rating to recipes
-- ❌ BAD: Create new migration if in development
-- ✅ GOOD: Edit existing recipe migration if not deployed
```

### Test Engineer

**Check First:**
- Existing test files for the same module
- Test utilities that could be reused
- Similar test patterns that could be extended

**Only Create When:**
- Testing entirely new module/component
- Different test type (unit vs integration)
- Framework requires separate files

**Example:**
```javascript
// Need: Test recipe creation
// ❌ BAD: Create recipeCreation.test.ts
// ✅ GOOD: Add test cases to recipeService.test.ts
```

### E2E Test Engineer

**Check First:**
- Existing page objects that could be extended
- Similar user journeys in existing specs
- Shared test utilities and helpers

**Only Create When:**
- Distinct user journey not covered
- New page with unique interactions
- Performance requires test splitting

**Example:**
```javascript
// Need: Test recipe sharing flow
// ❌ BAD: Create new ShareRecipePage when RecipePage exists
// ✅ GOOD: Add sharing methods to existing RecipePage
```

## Common Anti-Patterns to Avoid

### 1. File Per Feature
```
❌ BAD:
services/
├── createRecipe.ts
├── updateRecipe.ts
├── deleteRecipe.ts
└── getRecipe.ts

✅ GOOD:
services/
└── recipeService.ts  // All recipe operations
```

### 2. Duplicate Components
```
❌ BAD:
components/
├── UserCard.tsx
├── RecipeCard.tsx
├── CommentCard.tsx

✅ GOOD:
components/
├── Card.tsx  // Generic card
└── cards/    // Specialized wrappers
    ├── UserCard.tsx
    └── RecipeCard.tsx
```

### 3. Test File Explosion
```
❌ BAD:
tests/
├── createUser.test.ts
├── updateUser.test.ts
├── deleteUser.test.ts

✅ GOOD:
tests/
└── userService.test.ts  // All user tests
```

## Enforcement Checklist

Before creating ANY file, ask:

- [ ] Does this file already exist?
- [ ] Can I extend a similar file?
- [ ] Is this file absolutely necessary?
- [ ] Have I documented why creation is needed?
- [ ] Does this follow project conventions?
- [ ] Will this reduce code duplication?

## Justification Template

When file creation is necessary, document why:

```javascript
// Creating new file: services/paymentService.ts
// Justification: No existing service handles payment processing.
// This is a distinct domain requiring PCI compliance isolation.
// Cannot be added to existing services due to security requirements.
```

## Exceptions

The following are valid reasons to create new files:

1. **Security Isolation** - Sensitive operations need separation
2. **Performance** - Large files impacting build/load times
3. **Framework Requirements** - Framework expects certain file structure
4. **Domain Boundaries** - Clear business domain separation
5. **Legal/Compliance** - Regulatory requirements for code organization

## Summary

The goal is to maintain a clean, organized codebase without unnecessary file proliferation. When in doubt, err on the side of extending existing files rather than creating new ones. This approach leads to:

- Better code discoverability
- Reduced duplication
- Easier maintenance
- Clearer architecture
- Faster development