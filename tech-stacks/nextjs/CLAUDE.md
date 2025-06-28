# Development Guide for Claude - Next.js

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
Framework: Next.js 14+ with App Router
Language: TypeScript (strict mode)
Testing: Vitest + Playwright + Testing Library
Database: Supabase (PostgreSQL)
Validation: Zod
State Management: Zustand + TanStack Query
Styling: Tailwind CSS + shadcn/ui
Package Manager: npm
Auth: NextAuth.js v5
ORM: Drizzle ORM
```

## 📁 Repository Structure

```
/
├── app/                    # Next.js App Router
│   ├── (auth)/             # Route groups
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── register/
│   │       └── page.tsx
│   ├── (dashboard)/        # Protected route group
│   │   ├── dashboard/
│   │   │   ├── loading.tsx
│   │   │   ├── page.tsx
│   │   │   └── error.tsx
│   │   └── layout.tsx      # Dashboard layout
│   ├── api/                # API Routes
│   │   ├── auth/
│   │   │   └── [...nextauth]/
│   │   │       └── route.ts
│   │   ├── users/
│   │   │   ├── route.ts    # GET, POST /api/users
│   │   │   └── [id]/
│   │   │       └── route.ts # GET, PUT, DELETE /api/users/[id]
│   │   └── trpc/
│   │       └── [trpc]/
│   │           └── route.ts
│   ├── globals.css         # Global styles
│   ├── layout.tsx          # Root layout
│   ├── loading.tsx         # Global loading UI
│   ├── error.tsx           # Global error UI
│   ├── not-found.tsx       # 404 page
│   └── page.tsx            # Home page
├── components/             # React components
│   ├── ui/                 # shadcn/ui components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── form.tsx
│   │   └── index.ts
│   ├── forms/              # Form components
│   │   ├── LoginForm.tsx
│   │   ├── UserForm.tsx
│   │   └── index.ts
│   ├── features/           # Feature-specific components
│   │   ├── auth/
│   │   ├── users/
│   │   └── dashboard/
│   └── layout/             # Layout components
│       ├── Header.tsx
│       ├── Sidebar.tsx
│       └── Footer.tsx
├── lib/                    # Utilities and configuration
│   ├── auth.ts             # NextAuth configuration
│   ├── db.ts               # Database configuration
│   ├── trpc.ts             # tRPC configuration
│   ├── validators/         # Zod schemas
│   │   ├── auth.ts
│   │   ├── user.ts
│   │   └── index.ts
│   ├── stores/             # Zustand stores
│   │   ├── authStore.ts
│   │   ├── userStore.ts
│   │   └── index.ts
│   ├── utils.ts            # General utilities
│   └── constants.ts        # App constants
├── hooks/                  # Custom React hooks
│   ├── useAuth.ts
│   ├── useLocalStorage.ts
│   └── index.ts
├── types/                  # TypeScript type definitions
│   ├── auth.ts
│   ├── user.ts
│   └── index.ts
├── server/                 # Server-side code
│   ├── api/                # tRPC routers
│   │   ├── routers/
│   │   │   ├── auth.ts
│   │   │   ├── user.ts
│   │   │   └── index.ts
│   │   └── root.ts         # Root router
│   ├── auth.ts             # Server auth utilities
│   └── db/                 # Database layer
│       ├── schema.ts       # Drizzle schema
│       ├── queries/        # Database queries
│       └── migrations/     # Database migrations
├── __tests__/              # Test files
│   ├── components/
│   ├── pages/
│   ├── api/
│   └── utils/
├── docs/                   # Documentation
│   ├── features/           # Feature specifications
│   ├── db/                 # Database documentation
│   ├── api/                # API documentation
│   └── ADRs/               # Architectural Decision Records
└── .claude/                # AI assistant configuration
    └── commands/           # Custom AI commands
```

## 🗄️ Database Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/db/00_database_overview.md

## Architecture Philosophy
Full-stack Next.js application with Supabase as backend-as-a-service

## Database Technology
- Platform: Supabase (PostgreSQL 15+)
- ORM: Drizzle ORM with type-safe queries
- Client: Supabase JS Client (@supabase/supabase-js)
- Security: Row-Level Security (RLS) policies
- Auth: Supabase Auth with NextAuth.js integration
- Real-time: Supabase Realtime subscriptions

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → Users, Authentication, Profiles
Content Domain    → Posts, Comments, Media
Analytics Domain  → User activity, Performance metrics

### Cross-Domain Integration Points
- User profiles referenced across all domains
- Event-driven updates via Supabase Realtime

## Table Naming Conventions
- Tables: snake_case (users, user_profiles, blog_posts)
- Columns: snake_case (created_at, updated_at)
- Relationships: Clear foreign key naming

## Critical Relationships Map
Users -> UserProfiles (One-to-One)
Users -> Posts (One-to-Many)
Posts -> Comments (One-to-Many)

## Query Performance Guidelines
### Hot Paths (Optimize First)
- User authentication and session queries
- Dashboard data aggregation
- Real-time updates and subscriptions

## Business Context
Full-stack SaaS application with user management, content creation, and real-time features
```

### Drizzle Schema Patterns

```typescript
// server/db/schema.ts
import { pgTable, uuid, varchar, text, timestamp, boolean, integer } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  name: varchar('name', { length: 255 }).notNull(),
  image: text('image'),
  emailVerified: timestamp('email_verified'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const userProfiles = pgTable('user_profiles', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }).notNull(),
  bio: text('bio'),
  website: varchar('website', { length: 255 }),
  location: varchar('location', { length: 255 }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id: uuid('id').defaultRandom().primaryKey(),
  title: varchar('title', { length: 255 }).notNull(),
  slug: varchar('slug', { length: 255 }).notNull().unique(),
  content: text('content').notNull(),
  excerpt: text('excerpt'),
  published: boolean('published').default(false).notNull(),
  authorId: uuid('author_id').references(() => users.id, { onDelete: 'cascade' }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

// Relations
export const usersRelations = relations(users, ({ one, many }) => ({
  profile: one(userProfiles, {
    fields: [users.id],
    references: [userProfiles.userId],
  }),
  posts: many(posts),
}));

export const userProfilesRelations = relations(userProfiles, ({ one }) => ({
  user: one(users, {
    fields: [userProfiles.userId],
    references: [users.id],
  }),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}));
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```typescript
// Step 1: RED - Write a failing test
// __tests__/api/users.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { testClient } from '../helpers/testClient';

describe('/api/users', () => {
  beforeEach(async () => {
    await testClient.clearDatabase();
  });

  it('should create a new user', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com',
    };

    const response = await testClient.post('/api/users', userData);

    expect(response.status).toBe(201);
    expect(response.data).toMatchObject({
      id: expect.any(String),
      name: userData.name,
      email: userData.email,
      createdAt: expect.any(String),
    });
  });
});

// Step 2: GREEN - Minimal implementation
// app/api/users/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import { users } from '@/server/db/schema';
import { CreateUserSchema } from '@/lib/validators/user';
import { ZodError } from 'zod';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const validatedData = CreateUserSchema.parse(body);

    const [newUser] = await db
      .insert(users)
      .values({
        name: validatedData.name,
        email: validatedData.email,
      })
      .returning();

    return NextResponse.json(newUser, { status: 201 });
  } catch (error) {
    if (error instanceof ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// Step 3: REFACTOR - Assess improvements
// Only refactor if it adds value. If code is clean, move on.
```

### Server Component TDD

```typescript
// Step 1: RED - Component test
// __tests__/components/UserList.test.tsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import UserList from '@/components/features/users/UserList';

// Mock the database query
vi.mock('@/lib/db', () => ({
  db: {
    select: vi.fn().mockReturnValue({
      from: vi.fn().mockResolvedValue([
        { id: '1', name: 'John Doe', email: 'john@example.com' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
      ]),
    }),
  },
}));

describe('UserList', () => {
  it('should render list of users', async () => {
    const UserListResolved = await UserList();
    render(UserListResolved);

    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
    expect(screen.getByText('Jane Smith')).toBeInTheDocument();
    expect(screen.getByText('jane@example.com')).toBeInTheDocument();
  });
});

// Step 2: GREEN - Component implementation
// components/features/users/UserList.tsx
import { db } from '@/lib/db';
import { users } from '@/server/db/schema';

async function getUsers() {
  return await db.select().from(users);
}

export default async function UserList() {
  const userList = await getUsers();

  return (
    <div className="space-y-4">
      {userList.map((user) => (
        <div key={user.id} className="border rounded-lg p-4">
          <h3 className="text-lg font-semibold">{user.name}</h3>
          <p className="text-gray-600">{user.email}</p>
        </div>
      ))}
    </div>
  );
}
```

## 📐 Architecture Principles

### Schema-First Development with Zod

```typescript
// lib/validators/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  name: z.string().min(1, 'Name is required').max(255, 'Name too long'),
  email: z.string().email('Invalid email address'),
  image: z.string().url().optional(),
});

export const UpdateUserSchema = CreateUserSchema.partial();

export const UserResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  image: z.string().nullable(),
  emailVerified: z.date().nullable(),
  createdAt: z.date(),
  updatedAt: z.date(),
});

export type CreateUser = z.infer<typeof CreateUserSchema>;
export type UpdateUser = z.infer<typeof UpdateUserSchema>;
export type User = z.infer<typeof UserResponseSchema>;

// Usage in API routes
// app/api/users/route.ts
export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const validatedData = CreateUserSchema.parse(body);
    
    // Database operation with validated data
    const [newUser] = await db
      .insert(users)
      .values(validatedData)
      .returning();

    return NextResponse.json(newUser, { status: 201 });
  } catch (error) {
    if (error instanceof ZodError) {
      return NextResponse.json(
        { error: 'Validation failed', details: error.errors },
        { status: 400 }
      );
    }
    // Handle other errors...
  }
}
```

### App Router with Server and Client Components

```typescript
// app/users/page.tsx (Server Component)
import { Suspense } from 'react';
import UserList from '@/components/features/users/UserList';
import UserListSkeleton from '@/components/ui/UserListSkeleton';
import CreateUserButton from '@/components/features/users/CreateUserButton';

export default function UsersPage() {
  return (
    <div className="container mx-auto py-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">Users</h1>
        <CreateUserButton />
      </div>
      
      <Suspense fallback={<UserListSkeleton />}>
        <UserList />
      </Suspense>
    </div>
  );
}

// app/users/[id]/page.tsx (Dynamic Route)
import { notFound } from 'next/navigation';
import { db } from '@/lib/db';
import { users } from '@/server/db/schema';
import { eq } from 'drizzle-orm';

interface UserPageProps {
  params: { id: string };
}

async function getUser(id: string) {
  const [user] = await db
    .select()
    .from(users)
    .where(eq(users.id, id))
    .limit(1);

  return user;
}

export default async function UserPage({ params }: UserPageProps) {
  const user = await getUser(params.id);

  if (!user) {
    notFound();
  }

  return (
    <div className="container mx-auto py-8">
      <div className="bg-white rounded-lg shadow-sm border p-6">
        <div className="flex items-center space-x-4">
          {user.image && (
            <img
              src={user.image}
              alt={user.name}
              className="w-16 h-16 rounded-full"
            />
          )}
          <div>
            <h1 className="text-2xl font-bold">{user.name}</h1>
            <p className="text-gray-600">{user.email}</p>
          </div>
        </div>
        
        <div className="mt-6 space-y-2">
          <p><strong>Member since:</strong> {user.createdAt.toLocaleDateString()}</p>
          <p><strong>Email verified:</strong> {user.emailVerified ? 'Yes' : 'No'}</p>
        </div>
      </div>
    </div>
  );
}

// components/features/users/CreateUserButton.tsx (Client Component)
'use client';
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { CreateUserDialog } from './CreateUserDialog';

export default function CreateUserButton() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <Button onClick={() => setIsOpen(true)}>
        Create User
      </Button>
      
      <CreateUserDialog 
        open={isOpen} 
        onOpenChange={setIsOpen}
      />
    </>
  );
}
```

### State Management with Zustand

```typescript
// lib/stores/userStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { User, CreateUser } from '@/lib/validators/user';

interface UserState {
  users: User[];
  loading: boolean;
  error: string | null;
  
  // Actions
  fetchUsers: () => Promise<void>;
  createUser: (userData: CreateUser) => Promise<void>;
  deleteUser: (id: string) => Promise<void>;
  clearError: () => void;
}

export const useUserStore = create<UserState>()(
  devtools(
    (set, get) => ({
      users: [],
      loading: false,
      error: null,

      fetchUsers: async () => {
        set({ loading: true, error: null });
        try {
          const response = await fetch('/api/users');
          if (!response.ok) throw new Error('Failed to fetch users');
          
          const users = await response.json();
          set({ users, loading: false });
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Failed to fetch users',
            loading: false 
          });
        }
      },

      createUser: async (userData: CreateUser) => {
        set({ loading: true, error: null });
        try {
          const response = await fetch('/api/users', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(userData),
          });
          
          if (!response.ok) throw new Error('Failed to create user');
          
          const newUser = await response.json();
          set(state => ({ 
            users: [...state.users, newUser],
            loading: false 
          }));
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Failed to create user',
            loading: false 
          });
        }
      },

      deleteUser: async (id: string) => {
        set({ loading: true, error: null });
        try {
          const response = await fetch(`/api/users/${id}`, {
            method: 'DELETE',
          });
          
          if (!response.ok) throw new Error('Failed to delete user');
          
          set(state => ({ 
            users: state.users.filter(user => user.id !== id),
            loading: false 
          }));
        } catch (error) {
          set({ 
            error: error instanceof Error ? error.message : 'Failed to delete user',
            loading: false 
          });
        }
      },

      clearError: () => set({ error: null }),
    }),
    { name: 'user-store' }
  )
);
```

## 🧪 Testing Guidelines

### API Route Testing

```typescript
// __tests__/api/users/route.test.ts
import { describe, it, expect, beforeEach } from 'vitest';
import { POST, GET } from '@/app/api/users/route';
import { NextRequest } from 'next/server';

describe('/api/users', () => {
  beforeEach(async () => {
    // Clear test database
    await testDb.clearAll();
  });

  describe('POST', () => {
    it('should create user with valid data', async () => {
      const userData = {
        name: 'John Doe',
        email: 'john@example.com',
      };

      const request = new NextRequest('http://localhost:3000/api/users', {
        method: 'POST',
        body: JSON.stringify(userData),
        headers: { 'Content-Type': 'application/json' },
      });

      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(201);
      expect(data).toMatchObject({
        id: expect.any(String),
        name: userData.name,
        email: userData.email,
      });
    });

    it('should return 400 for invalid email', async () => {
      const userData = {
        name: 'John Doe',
        email: 'invalid-email',
      };

      const request = new NextRequest('http://localhost:3000/api/users', {
        method: 'POST',
        body: JSON.stringify(userData),
        headers: { 'Content-Type': 'application/json' },
      });

      const response = await POST(request);
      const data = await response.json();

      expect(response.status).toBe(400);
      expect(data.error).toBe('Validation failed');
    });
  });
});
```

### Component Testing

```typescript
// __tests__/components/UserForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import UserForm from '@/components/forms/UserForm';

describe('UserForm', () => {
  it('should submit valid user data', async () => {
    const mockOnSubmit = vi.fn();
    
    render(<UserForm onSubmit={mockOnSubmit} />);
    
    fireEvent.change(screen.getByLabelText(/name/i), {
      target: { value: 'John Doe' }
    });
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'john@example.com' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /create/i }));
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        name: 'John Doe',
        email: 'john@example.com'
      });
    });
  });

  it('should show validation errors for invalid data', async () => {
    const mockOnSubmit = vi.fn();
    
    render(<UserForm onSubmit={mockOnSubmit} />);
    
    fireEvent.click(screen.getByRole('button', { name: /create/i }));
    
    await waitFor(() => {
      expect(screen.getByText(/name is required/i)).toBeInTheDocument();
      expect(screen.getByText(/invalid email/i)).toBeInTheDocument();
    });
    
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });
});
```

## 🚀 Development Practices

### Error Handling

```typescript
// lib/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public errors: any[] = []) {
    super(message, 400, 'VALIDATION_ERROR');
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

// app/api/users/[id]/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import { users } from '@/server/db/schema';
import { eq } from 'drizzle-orm';
import { NotFoundError } from '@/lib/errors';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const [user] = await db
      .select()
      .from(users)
      .where(eq(users.id, params.id))
      .limit(1);

    if (!user) {
      throw new NotFoundError('User');
    }

    return NextResponse.json(user);
  } catch (error) {
    if (error instanceof NotFoundError) {
      return NextResponse.json(
        { error: error.message },
        { status: error.statusCode }
      );
    }

    console.error('Unexpected error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
```

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
- Use Zod for validation at API boundaries
- Import schemas from shared location in tests
- Prefer editing existing files
- Run tests after implementation
- Check database documentation before queries
- Use conventional commits
- Use Server Components by default, Client Components when needed
- Validate all external data with Zod schemas

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
- Database changes (Drizzle migrations)
- API endpoints (App Router)
- Testing strategy (Vitest + Playwright)

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Drizzle ORM Documentation](https://orm.drizzle.team/)
- [Supabase Documentation](https://supabase.com/docs)
- [Zod Documentation](https://zod.dev/)
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [shadcn/ui Documentation](https://ui.shadcn.com/)
- [NextAuth.js Documentation](https://next-auth.js.org/)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.