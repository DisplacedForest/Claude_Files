# Development Guide for Claude - React + Express

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
Frontend: React 18+ with Vite
Backend: Express.js + Node.js
Language: TypeScript (strict mode)
Testing: Vitest + Playwright (frontend) + Jest + Supertest (backend)
Database: Supabase (PostgreSQL)
Validation: Zod (shared schemas)
State Management: Zustand + TanStack Query
Styling: Tailwind CSS
Package Manager: npm
Auth: Custom JWT implementation
```

## 📁 Repository Structure

```
/
├── frontend/               # React + Vite application
│   ├── src/
│   │   ├── components/     # React components
│   │   │   ├── ui/         # Base UI components
│   │   │   ├── forms/      # Form components
│   │   │   ├── features/   # Feature-specific components
│   │   │   └── layout/     # Layout components
│   │   ├── pages/          # Page components
│   │   │   ├── HomePage.tsx
│   │   │   ├── LoginPage.tsx
│   │   │   ├── DashboardPage.tsx
│   │   │   └── NotFoundPage.tsx
│   │   ├── hooks/          # Custom React hooks
│   │   │   ├── useAuth.ts
│   │   │   ├── useApi.ts
│   │   │   └── useLocalStorage.ts
│   │   ├── stores/         # Zustand stores
│   │   │   ├── authStore.ts
│   │   │   ├── userStore.ts
│   │   │   └── index.ts
│   │   ├── lib/            # Utilities and configuration
│   │   │   ├── api.ts      # API client
│   │   │   ├── auth.ts     # Auth utilities
│   │   │   ├── utils.ts    # General utilities
│   │   │   └── constants.ts
│   │   ├── types/          # TypeScript type definitions
│   │   │   ├── api.ts
│   │   │   ├── auth.ts
│   │   │   └── index.ts
│   │   ├── App.tsx         # Root component
│   │   ├── main.tsx        # Entry point
│   │   └── router.tsx      # React Router setup
│   ├── __tests__/          # Test files
│   │   ├── components/
│   │   ├── pages/
│   │   ├── hooks/
│   │   └── utils/
│   ├── public/             # Static assets
│   ├── index.html          # HTML template
│   ├── vite.config.ts      # Vite configuration
│   └── package.json
├── backend/                # Express.js application
│   ├── src/
│   │   ├── routes/         # Express route handlers
│   │   │   ├── auth.ts     # Authentication routes
│   │   │   ├── users.ts    # User management routes
│   │   │   ├── posts.ts    # Posts routes
│   │   │   └── index.ts    # Route aggregator
│   │   ├── controllers/    # Business logic controllers
│   │   │   ├── authController.ts
│   │   │   ├── userController.ts
│   │   │   └── postController.ts
│   │   ├── services/       # Business logic services
│   │   │   ├── authService.ts
│   │   │   ├── userService.ts
│   │   │   ├── postService.ts
│   │   │   └── emailService.ts
│   │   ├── middleware/     # Express middleware
│   │   │   ├── auth.ts     # Authentication middleware
│   │   │   ├── validation.ts # Validation middleware
│   │   │   ├── errorHandler.ts
│   │   │   └── logger.ts
│   │   ├── models/         # Database models/queries
│   │   │   ├── User.ts
│   │   │   ├── Post.ts
│   │   │   └── database.ts
│   │   ├── utils/          # Utility functions
│   │   │   ├── jwt.ts      # JWT utilities
│   │   │   ├── crypto.ts   # Encryption utilities
│   │   │   ├── validation.ts
│   │   │   └── logger.ts
│   │   ├── config/         # Configuration
│   │   │   ├── database.ts
│   │   │   ├── jwt.ts
│   │   │   └── index.ts
│   │   ├── app.ts          # Express app setup
│   │   └── server.ts       # Server entry point
│   ├── __tests__/          # Test files
│   │   ├── routes/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── middleware/
│   │   └── utils/
│   └── package.json
├── shared/                 # Shared code between frontend/backend
│   ├── schemas/            # Zod schemas
│   │   ├── auth.ts         # Authentication schemas
│   │   ├── user.ts         # User schemas
│   │   ├── post.ts         # Post schemas
│   │   └── index.ts
│   ├── types/              # Shared TypeScript types
│   │   ├── api.ts          # API response types
│   │   ├── database.ts     # Database types
│   │   └── index.ts
│   └── constants/          # Shared constants
│       ├── errors.ts       # Error codes/messages
│       ├── validation.ts   # Validation rules
│       └── index.ts
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
Clean separation between React frontend and Express backend with Supabase as database

## Database Technology
- Platform: Supabase (PostgreSQL 15+)
- Client: Supabase JS Client (@supabase/supabase-js)
- Security: Row-Level Security (RLS) policies + Express middleware
- Auth: Custom JWT implementation with Express middleware
- Real-time: Supabase Realtime for live updates

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → Users, Authentication, Sessions
Content Domain    → Posts, Comments, Media
Analytics Domain  → User activity, API metrics

### Cross-Domain Integration Points
- User entities referenced across all domains
- Event-driven updates via Supabase Realtime
- Express middleware handles cross-cutting concerns

## Table Naming Conventions
- Tables: snake_case (users, user_profiles, blog_posts)
- Columns: snake_case (created_at, updated_at)
- API endpoints: kebab-case (/api/users, /api/blog-posts)

## Critical Relationships Map
Users -> UserProfiles (One-to-One)
Users -> Posts (One-to-Many)
Posts -> Comments (One-to-Many)

## Query Performance Guidelines
### Hot Paths (Optimize First)
- User authentication and session validation
- Dashboard data aggregation
- Real-time notification queries

## Business Context
SPA with React frontend and Express API backend for user management and content creation
```

### Supabase Schema Patterns

```typescript
// shared/types/database.ts
export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          email: string;
          name: string;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          email: string;
          name: string;
          avatar_url?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          name?: string;
          avatar_url?: string | null;
          updated_at?: string;
        };
      };
      posts: {
        Row: {
          id: string;
          title: string;
          content: string;
          slug: string;
          published: boolean;
          author_id: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          title: string;
          content: string;
          slug: string;
          published?: boolean;
          author_id: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          title?: string;
          content?: string;
          slug?: string;
          published?: boolean;
          updated_at?: string;
        };
      };
    };
  };
}

// backend/src/models/database.ts
import { createClient } from '@supabase/supabase-js';
import { Database } from '../../../shared/types/database';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

export const supabase = createClient<Database>(supabaseUrl, supabaseServiceKey);
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```typescript
// Step 1: RED - Write a failing test
// backend/__tests__/routes/users.test.ts
import request from 'supertest';
import { app } from '../../src/app';
import { supabase } from '../../src/models/database';

describe('POST /api/users', () => {
  beforeEach(async () => {
    // Clear test data
    await supabase.from('users').delete().neq('id', '');
  });

  it('should create a new user with valid data', async () => {
    const userData = {
      name: 'John Doe',
      email: 'john@example.com',
    };

    const response = await request(app)
      .post('/api/users')
      .send(userData)
      .expect(201);

    expect(response.body).toMatchObject({
      id: expect.any(String),
      name: userData.name,
      email: userData.email,
      created_at: expect.any(String),
    });

    // Verify user was actually created in database
    const { data: user } = await supabase
      .from('users')
      .select('*')
      .eq('email', userData.email)
      .single();

    expect(user).toBeTruthy();
    expect(user!.name).toBe(userData.name);
  });
});

// Step 2: GREEN - Minimal implementation
// backend/src/routes/users.ts
import { Router } from 'express';
import { createUser } from '../controllers/userController';
import { validateRequest } from '../middleware/validation';
import { CreateUserSchema } from '../../../shared/schemas/user';

const router = Router();

router.post('/', validateRequest(CreateUserSchema), createUser);

export default router;

// backend/src/controllers/userController.ts
import { Request, Response } from 'express';
import { userService } from '../services/userService';
import { CreateUserSchema } from '../../../shared/schemas/user';

export const createUser = async (req: Request, res: Response) => {
  try {
    const validatedData = CreateUserSchema.parse(req.body);
    const user = await userService.create(validatedData);
    
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: 'Failed to create user' });
  }
};

// backend/src/services/userService.ts
import { supabase } from '../models/database';
import { CreateUser, UserResponse } from '../../../shared/schemas/user';

export const userService = {
  async create(userData: CreateUser): Promise<UserResponse> {
    const { data, error } = await supabase
      .from('users')
      .insert(userData)
      .select()
      .single();

    if (error) throw error;
    return data;
  },
};

// Step 3: REFACTOR - Assess improvements
// Only refactor if it adds value. If code is clean, move on.
```

### React Component TDD

```typescript
// Step 1: RED - Component test
// frontend/__tests__/components/UserForm.test.tsx
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
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    });
    
    expect(mockOnSubmit).not.toHaveBeenCalled();
  });
});

// Step 2: GREEN - Component implementation
// frontend/src/components/forms/UserForm.tsx
import React, { useState } from 'react';
import { CreateUserSchema, type CreateUser } from '../../../../shared/schemas/user';
import { ZodError } from 'zod';

interface UserFormProps {
  onSubmit: (data: CreateUser) => void;
}

export default function UserForm({ onSubmit }: UserFormProps) {
  const [formData, setFormData] = useState<CreateUser>({
    name: '',
    email: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setErrors({});

    try {
      const validatedData = CreateUserSchema.parse(formData);
      await onSubmit(validatedData);
    } catch (error) {
      if (error instanceof ZodError) {
        const fieldErrors: Record<string, string> = {};
        error.errors.forEach((err) => {
          if (err.path[0]) {
            fieldErrors[err.path[0] as string] = err.message;
          }
        });
        setErrors(fieldErrors);
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleChange = (field: keyof CreateUser) => (
    e: React.ChangeEvent<HTMLInputElement>
  ) => {
    setFormData(prev => ({ ...prev, [field]: e.target.value }));
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Name
        </label>
        <input
          type="text"
          id="name"
          value={formData.name}
          onChange={handleChange('name')}
          className="mt-1 block w-full border rounded-md px-3 py-2"
        />
        {errors.name && (
          <p className="mt-1 text-sm text-red-600">{errors.name}</p>
        )}
      </div>

      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          Email
        </label>
        <input
          type="email"
          id="email"
          value={formData.email}
          onChange={handleChange('email')}
          className="mt-1 block w-full border rounded-md px-3 py-2"
        />
        {errors.email && (
          <p className="mt-1 text-sm text-red-600">{errors.email}</p>
        )}
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="bg-blue-500 text-white px-4 py-2 rounded disabled:opacity-50"
      >
        {isSubmitting ? 'Creating...' : 'Create User'}
      </button>
    </form>
  );
}
```

## 📐 Architecture Principles

### Schema-First Development with Zod

```typescript
// shared/schemas/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  name: z.string().min(1, 'Name is required').max(255, 'Name too long'),
  email: z.string().email('Invalid email address'),
  avatar_url: z.string().url().optional(),
});

export const UpdateUserSchema = CreateUserSchema.partial();

export const UserResponseSchema = z.object({
  id: z.string().uuid(),
  name: z.string(),
  email: z.string().email(),
  avatar_url: z.string().nullable(),
  created_at: z.string().datetime(),
  updated_at: z.string().datetime(),
});

export type CreateUser = z.infer<typeof CreateUserSchema>;
export type UpdateUser = z.infer<typeof UpdateUserSchema>;
export type UserResponse = z.infer<typeof UserResponseSchema>;

// backend/src/middleware/validation.ts
import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

export const validateRequest = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          error: 'Validation failed',
          details: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        });
      }
      next(error);
    }
  };
};

// frontend/src/lib/api.ts
import { CreateUser, UserResponse, UserResponseSchema } from '../../../shared/schemas/user';

export class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = import.meta.env.VITE_API_URL || 'http://localhost:3001') {
    this.baseUrl = baseUrl;
  }

  async createUser(userData: CreateUser): Promise<UserResponse> {
    const response = await fetch(`${this.baseUrl}/api/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    });

    if (!response.ok) {
      throw new Error(`Failed to create user: ${response.statusText}`);
    }

    const data = await response.json();
    return UserResponseSchema.parse(data); // Validate response
  }
}
```

### Express Middleware Architecture

```typescript
// backend/src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import { verifyJWT } from '../utils/jwt';
import { supabase } from '../models/database';

export interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    email: string;
    name: string;
  };
}

export const authenticateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const token = authHeader.substring(7);
    const payload = verifyJWT(token);
    
    // Verify user still exists in database
    const { data: user, error } = await supabase
      .from('users')
      .select('id, email, name')
      .eq('id', payload.userId)
      .single();

    if (error || !user) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    (req as AuthenticatedRequest).user = user;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// backend/src/middleware/errorHandler.ts
import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';

export interface AppError extends Error {
  statusCode?: number;
  code?: string;
}

export const errorHandler = (
  error: AppError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('Error:', error);

  if (error instanceof ZodError) {
    return res.status(400).json({
      error: 'Validation failed',
      details: error.errors,
    });
  }

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal server error';

  res.status(statusCode).json({
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack }),
  });
};
```

### State Management with Zustand

```typescript
// frontend/src/stores/userStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { ApiClient } from '../lib/api';
import { UserResponse, CreateUser } from '../../../shared/schemas/user';

interface UserState {
  users: UserResponse[];
  loading: boolean;
  error: string | null;
  
  // Actions
  fetchUsers: () => Promise<void>;
  createUser: (userData: CreateUser) => Promise<void>;
  deleteUser: (id: string) => Promise<void>;
  clearError: () => void;
}

const apiClient = new ApiClient();

export const useUserStore = create<UserState>()(
  devtools(
    (set, get) => ({
      users: [],
      loading: false,
      error: null,

      fetchUsers: async () => {
        set({ loading: true, error: null });
        try {
          const users = await apiClient.getUsers();
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
          const newUser = await apiClient.createUser(userData);
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
          await apiClient.deleteUser(id);
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

### Express API Testing

```typescript
// backend/__tests__/routes/auth.test.ts
import request from 'supertest';
import { app } from '../../src/app';
import { supabase } from '../../src/models/database';
import bcrypt from 'bcrypt';

describe('POST /api/auth/login', () => {
  beforeEach(async () => {
    // Clear and seed test data
    await supabase.from('users').delete().neq('id', '');
    
    const hashedPassword = await bcrypt.hash('password123', 10);
    await supabase.from('users').insert({
      email: 'test@example.com',
      name: 'Test User',
      password_hash: hashedPassword,
    });
  });

  it('should login with valid credentials', async () => {
    const loginData = {
      email: 'test@example.com',
      password: 'password123',
    };

    const response = await request(app)
      .post('/api/auth/login')
      .send(loginData)
      .expect(200);

    expect(response.body).toMatchObject({
      user: {
        email: loginData.email,
        name: 'Test User',
      },
      token: expect.any(String),
    });
  });

  it('should reject invalid credentials', async () => {
    const loginData = {
      email: 'test@example.com',
      password: 'wrongpassword',
    };

    const response = await request(app)
      .post('/api/auth/login')
      .send(loginData)
      .expect(401);

    expect(response.body).toEqual({
      error: 'Invalid credentials',
    });
  });
});
```

### React Component Testing

```typescript
// frontend/__tests__/pages/DashboardPage.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import DashboardPage from '@/pages/DashboardPage';

// Mock the API
vi.mock('@/lib/api', () => ({
  ApiClient: class {
    async getUsers() {
      return [
        { id: '1', name: 'John Doe', email: 'john@example.com' },
        { id: '2', name: 'Jane Smith', email: 'jane@example.com' },
      ];
    }
  },
}));

describe('DashboardPage', () => {
  const renderWithQuery = (component: React.ReactElement) => {
    const queryClient = new QueryClient({
      defaultOptions: { queries: { retry: false } },
    });
    
    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  it('should display users when loaded', async () => {
    renderWithQuery(<DashboardPage />);

    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('jane@example.com')).toBeInTheDocument();
    });
  });

  it('should show loading state initially', () => {
    renderWithQuery(<DashboardPage />);
    
    expect(screen.getByText(/loading/i)).toBeInTheDocument();
  });
});
```

## 🚀 Development Practices

### Error Handling

```typescript
// shared/constants/errors.ts
export const ERROR_CODES = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  NOT_FOUND: 'NOT_FOUND',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  INTERNAL_ERROR: 'INTERNAL_ERROR',
} as const;

export const ERROR_MESSAGES = {
  [ERROR_CODES.VALIDATION_ERROR]: 'Validation failed',
  [ERROR_CODES.NOT_FOUND]: 'Resource not found',
  [ERROR_CODES.UNAUTHORIZED]: 'Authentication required',
  [ERROR_CODES.FORBIDDEN]: 'Access denied',
  [ERROR_CODES.INTERNAL_ERROR]: 'Internal server error',
} as const;

// backend/src/utils/errors.ts
import { ERROR_CODES, ERROR_MESSAGES } from '../../../shared/constants/errors';

export class AppError extends Error {
  constructor(
    public code: keyof typeof ERROR_CODES,
    public statusCode: number,
    message?: string
  ) {
    super(message || ERROR_MESSAGES[code]);
    this.name = 'AppError';
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(ERROR_CODES.NOT_FOUND, 404, `${resource} not found`);
  }
}

export class ValidationError extends AppError {
  constructor(message: string = ERROR_MESSAGES.VALIDATION_ERROR) {
    super(ERROR_CODES.VALIDATION_ERROR, 400, message);
  }
}

// frontend/src/lib/errorHandler.ts
export class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public code?: string
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export const handleApiError = (error: unknown): never => {
  if (error instanceof ApiError) {
    throw error;
  }
  
  if (error instanceof Error) {
    throw new ApiError(error.message, 500);
  }
  
  throw new ApiError('An unexpected error occurred', 500);
};
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
- Use Zod for validation on both frontend and backend
- Import schemas from shared location in tests
- Prefer editing existing files
- Run tests after implementation
- Check database documentation before queries
- Use conventional commits
- Separate business logic into services
- Use proper Express middleware patterns

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
- Database changes (Supabase migrations)
- API endpoints (Express routes)
- Testing strategy (Jest + Vitest)

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [React Documentation](https://react.dev/)
- [Express.js Documentation](https://expressjs.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Zod Documentation](https://zod.dev/)
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [TanStack Query Documentation](https://tanstack.com/query/latest)
- [Vitest Documentation](https://vitest.dev/)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.