# Development Guide for Claude - FastAPI + Next.js

## 🎯 Core Philosophy

**TEST-DRIVEN DEVELOPMENT IS NON-NEGOTIABLE.** Every single line of production code must be written in response to a failing test. No exceptions. This is not a suggestion or a preference - it is the fundamental practice that enables all other principles in this document.

### Quick Reference
- **Write tests first** (TDD - Red, Green, Refactor)
- **Test behavior, not implementation**
- **No `any` types** or type assertions
- **Immutable data only**
- **Small, pure functions**
- **TypeScript strict mode always** (frontend)
- **100% behavior coverage** (not just line coverage)
- **Schema-first development** with runtime validation

## ⚡ Tech Stack Configuration

```yaml
Frontend: Next.js 14+ with App Router
Backend: FastAPI 0.100+ with Python 3.11+
Language: TypeScript (frontend) + Python (backend)
Testing: Vitest + Playwright (frontend) + pytest (backend)
Database: PostgreSQL with SQLAlchemy
Validation: Zod (frontend) + Pydantic (backend)
State Management: Zustand + TanStack Query
Styling: Tailwind CSS + shadcn/ui
Package Manager: npm (frontend) + poetry (backend)
Auth: NextAuth.js + FastAPI JWT
```

## 📁 Repository Structure

```
/
├── frontend/               # Next.js application
│   ├── app/                # App Router directory
│   │   ├── (auth)/         # Route groups
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── api/            # API routes (middleware layer)
│   │   ├── dashboard/      # Protected pages
│   │   ├── globals.css     # Global styles
│   │   ├── layout.tsx      # Root layout
│   │   ├── loading.tsx     # Loading UI
│   │   ├── not-found.tsx   # 404 page
│   │   └── page.tsx        # Home page
│   ├── components/         # React components
│   │   ├── ui/             # Base UI components
│   │   ├── forms/          # Form components
│   │   └── features/       # Feature-specific components
│   ├── lib/                # Utilities and configuration
│   │   ├── api.ts          # API client configuration
│   │   ├── auth.ts         # NextAuth configuration
│   │   ├── schemas/        # Zod schemas
│   │   ├── stores/         # Zustand stores
│   │   └── utils.ts        # General utilities
│   ├── hooks/              # Custom React hooks
│   ├── types/              # TypeScript type definitions
│   ├── __tests__/          # Test files
│   └── package.json
├── backend/                # FastAPI application
│   ├── app/
│   │   ├── main.py         # FastAPI app entry point
│   │   ├── api/            # API routes
│   │   │   ├── __init__.py
│   │   │   ├── deps.py     # Dependencies
│   │   │   ├── auth.py     # Authentication routes
│   │   │   ├── users.py    # User routes
│   │   │   └── v1/         # API v1 routes
│   │   ├── core/           # Core configuration
│   │   │   ├── config.py   # Settings
│   │   │   ├── security.py # Security utilities
│   │   │   └── database.py # Database configuration
│   │   ├── crud/           # CRUD operations
│   │   │   ├── __init__.py
│   │   │   ├── base.py     # Base CRUD class
│   │   │   └── user.py     # User CRUD
│   │   ├── db/             # Database related
│   │   │   ├── __init__.py
│   │   │   ├── base.py     # Base model class
│   │   │   ├── session.py  # Database session
│   │   │   └── init_db.py  # Database initialization
│   │   ├── models/         # SQLAlchemy models
│   │   │   ├── __init__.py
│   │   │   └── user.py     # User model
│   │   ├── schemas/        # Pydantic schemas
│   │   │   ├── __init__.py
│   │   │   ├── user.py     # User schemas
│   │   │   └── token.py    # Token schemas
│   │   └── utils/          # Utility functions
│   ├── tests/              # Test files
│   │   ├── conftest.py     # Pytest configuration
│   │   ├── test_auth.py    # Authentication tests
│   │   └── test_users.py   # User tests
│   ├── alembic/            # Database migrations
│   │   ├── versions/       # Migration files
│   │   └── env.py          # Alembic configuration
│   ├── pyproject.toml      # Poetry configuration
│   └── requirements.txt    # Python dependencies
├── shared/                 # Shared code and types
│   ├── types/              # Shared TypeScript types
│   └── constants/          # Shared constants
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
Domain-driven design with SQLAlchemy ORM providing strong typing and relationships

## Database Technology
- Platform: PostgreSQL 15+
- ORM: SQLAlchemy 2.0+ with async support
- Client: asyncpg for PostgreSQL connection
- Security: Database-level constraints + Pydantic validation
- Auth: FastAPI JWT with bcrypt password hashing
- Migrations: Alembic for schema versioning

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → Users, Authentication, Profiles
Supporting Domain → Notifications, File Uploads
Analytics Domain  → Usage tracking, API metrics

### Cross-Domain Integration Points
- User model referenced across all domains
- Event-driven architecture for async operations

## Model Naming Conventions
- Models: PascalCase (User, UserProfile)
- Tables: snake_case (users, user_profiles)
- Relationships: Explicit naming with proper foreign keys

## Critical Relationships Map
Users -> UserProfiles (One-to-One)
Users -> Posts (One-to-Many)
Users -> Roles (Many-to-Many via user_roles)

## Query Performance Guidelines
### Hot Paths (Optimize First)
- User authentication queries
- Dashboard data aggregation
- Real-time API endpoints

## Business Context
Full-stack SaaS application with user management, content creation, and analytics
```

### SQLAlchemy Model Patterns

```python
# backend/app/models/user.py
from sqlalchemy import Boolean, Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    first_name = Column(String, nullable=False)
    last_name = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    posts = relationship("Post", back_populates="author")

class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True)
    bio = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)
    phone = Column(String, nullable=True)
    
    # Relationships
    user = relationship("User", back_populates="profile")
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```python
# Step 1: RED - Write a failing test
# backend/tests/test_users.py
import pytest
from fastapi.testclient import TestClient
from app.schemas.user import UserCreate

def test_create_user(client: TestClient):
    user_data = {
        "email": "test@example.com",
        "password": "securepassword123",
        "first_name": "John",
        "last_name": "Doe"
    }
    
    response = client.post("/api/v1/users/", json=user_data)
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert "password" not in data  # Password should not be returned
    assert "id" in data

# Step 2: GREEN - Minimal implementation
# backend/app/api/v1/users.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserResponse
from app.crud import user as crud_user
from app.api.deps import get_db

router = APIRouter()

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    user_in: UserCreate,
    db: Session = Depends(get_db)
) -> UserResponse:
    user = crud_user.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=400,
            detail="A user with this email already exists"
        )
    
    user = crud_user.create(db, obj_in=user_in)
    return UserResponse.from_orm(user)

# Step 3: REFACTOR - Assess improvements
# Only refactor if it adds value. If code is clean, move on.
```

### Next.js Component TDD

```typescript
// Step 1: RED - Component test
// frontend/__tests__/components/UserForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import UserForm from '@/components/forms/UserForm';

describe('UserForm', () => {
  it('should submit valid user data', async () => {
    const mockOnSubmit = vi.fn();
    
    render(<UserForm onSubmit={mockOnSubmit} />);
    
    fireEvent.change(screen.getByLabelText(/email/i), {
      target: { value: 'test@example.com' }
    });
    fireEvent.change(screen.getByLabelText(/first name/i), {
      target: { value: 'John' }
    });
    fireEvent.change(screen.getByLabelText(/last name/i), {
      target: { value: 'Doe' }
    });
    fireEvent.change(screen.getByLabelText(/password/i), {
      target: { value: 'securepassword123' }
    });
    
    fireEvent.click(screen.getByRole('button', { name: /create user/i }));
    
    await waitFor(() => {
      expect(mockOnSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'securepassword123'
      });
    });
  });
});

// Step 2: GREEN - Component implementation
// frontend/components/forms/UserForm.tsx
'use client';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateUserSchema, type CreateUser } from '@/lib/schemas/user';

interface UserFormProps {
  onSubmit: (data: CreateUser) => void;
}

export default function UserForm({ onSubmit }: UserFormProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  
  const {
    register,
    handleSubmit,
    formState: { errors }
  } = useForm<CreateUser>({
    resolver: zodResolver(CreateUserSchema)
  });

  const handleFormSubmit = async (data: CreateUser) => {
    setIsSubmitting(true);
    try {
      await onSubmit(data);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit(handleFormSubmit)} className="space-y-4">
      <div>
        <label htmlFor="email">Email</label>
        <input
          {...register('email')}
          type="email"
          id="email"
          className="w-full border rounded px-3 py-2"
        />
        {errors.email && <p className="text-red-500">{errors.email.message}</p>}
      </div>
      
      <div>
        <label htmlFor="firstName">First Name</label>
        <input
          {...register('firstName')}
          type="text"
          id="firstName"
          className="w-full border rounded px-3 py-2"
        />
        {errors.firstName && <p className="text-red-500">{errors.firstName.message}</p>}
      </div>
      
      <div>
        <label htmlFor="lastName">Last Name</label>
        <input
          {...register('lastName')}
          type="text"
          id="lastName"
          className="w-full border rounded px-3 py-2"
        />
        {errors.lastName && <p className="text-red-500">{errors.lastName.message}</p>}
      </div>
      
      <div>
        <label htmlFor="password">Password</label>
        <input
          {...register('password')}
          type="password"
          id="password"
          className="w-full border rounded px-3 py-2"
        />
        {errors.password && <p className="text-red-500">{errors.password.message}</p>}
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

### Schema-First Development with Pydantic + Zod

```python
# backend/app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(..., min_length=1, max_length=100)
    is_active: bool = True

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, max_length=100)

class UserUpdate(UserBase):
    email: Optional[EmailStr] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
```

```typescript
// frontend/lib/schemas/user.ts
import { z } from 'zod';

export const CreateUserSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  firstName: z.string().min(1, 'First name is required').max(100),
  lastName: z.string().min(1, 'Last name is required').max(100),
  password: z.string().min(8, 'Password must be at least 8 characters').max(100),
});

export const UserResponseSchema = z.object({
  id: z.number(),
  email: z.string().email(),
  firstName: z.string(),
  lastName: z.string(),
  isActive: z.boolean(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime().nullable(),
});

export type CreateUser = z.infer<typeof CreateUserSchema>;
export type User = z.infer<typeof UserResponseSchema>;

// API client with validation
// frontend/lib/api.ts
export class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000') {
    this.baseUrl = baseUrl;
  }

  async createUser(userData: CreateUser): Promise<User> {
    const response = await fetch(`${this.baseUrl}/api/v1/users/`, {
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

### Next.js App Router with Server Components

```typescript
// frontend/app/users/page.tsx (Server Component)
import { Suspense } from 'react';
import UserList from '@/components/features/UserList';
import UserListSkeleton from '@/components/ui/UserListSkeleton';

export default function UsersPage() {
  return (
    <div className="container mx-auto py-8">
      <h1 className="text-2xl font-bold mb-6">Users</h1>
      <Suspense fallback={<UserListSkeleton />}>
        <UserList />
      </Suspense>
    </div>
  );
}

// frontend/components/features/UserList.tsx (Server Component)
import { ApiClient } from '@/lib/api';

async function getUsers() {
  const api = new ApiClient();
  return await api.getUsers();
}

export default async function UserList() {
  const users = await getUsers();

  return (
    <div className="grid gap-4">
      {users.map((user) => (
        <div key={user.id} className="border rounded-lg p-4">
          <h3 className="font-semibold">{user.firstName} {user.lastName}</h3>
          <p className="text-gray-600">{user.email}</p>
        </div>
      ))}
    </div>
  );
}

// frontend/app/users/[id]/page.tsx (Dynamic Route)
interface UserPageProps {
  params: { id: string };
}

export default async function UserPage({ params }: UserPageProps) {
  const api = new ApiClient();
  const user = await api.getUser(parseInt(params.id));

  return (
    <div className="container mx-auto py-8">
      <h1 className="text-2xl font-bold mb-6">
        {user.firstName} {user.lastName}
      </h1>
      <div className="bg-white rounded-lg shadow p-6">
        <p><strong>Email:</strong> {user.email}</p>
        <p><strong>Status:</strong> {user.isActive ? 'Active' : 'Inactive'}</p>
        <p><strong>Created:</strong> {new Date(user.createdAt).toLocaleDateString()}</p>
      </div>
    </div>
  );
}
```

### State Management with Zustand

```typescript
// frontend/lib/stores/userStore.ts
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { ApiClient } from '@/lib/api';
import { User, CreateUser } from '@/lib/schemas/user';

interface UserState {
  users: User[];
  loading: boolean;
  error: string | null;
  
  // Actions
  fetchUsers: () => Promise<void>;
  createUser: (userData: CreateUser) => Promise<void>;
  deleteUser: (id: number) => Promise<void>;
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
          const api = new ApiClient();
          const users = await api.getUsers();
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
          const api = new ApiClient();
          const newUser = await api.createUser(userData);
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

      deleteUser: async (id: number) => {
        set({ loading: true, error: null });
        try {
          const api = new ApiClient();
          await api.deleteUser(id);
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

### FastAPI Testing with pytest

```python
# backend/tests/conftest.py
import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.core.config import settings
from app.db.base import Base
from app.api.deps import get_db

# Test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

@pytest.fixture
def client():
    Base.metadata.create_all(bind=engine)
    with TestClient(app) as c:
        yield c
    Base.metadata.drop_all(bind=engine)

# backend/tests/test_users.py
import pytest
from fastapi.testclient import TestClient

def test_create_user_success(client: TestClient):
    user_data = {
        "email": "test@example.com",
        "password": "securepassword123",
        "first_name": "John",
        "last_name": "Doe"
    }
    
    response = client.post("/api/v1/users/", json=user_data)
    
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == user_data["email"]
    assert data["first_name"] == user_data["first_name"]
    assert "password" not in data

def test_create_user_duplicate_email(client: TestClient):
    user_data = {
        "email": "test@example.com",
        "password": "securepassword123",
        "first_name": "John",
        "last_name": "Doe"
    }
    
    # Create first user
    client.post("/api/v1/users/", json=user_data)
    
    # Try to create duplicate
    response = client.post("/api/v1/users/", json=user_data)
    
    assert response.status_code == 400
    assert "already exists" in response.json()["detail"]
```

### Next.js Testing with Vitest

```typescript
// frontend/__tests__/lib/api.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ApiClient } from '@/lib/api';

// Mock fetch
global.fetch = vi.fn();

describe('ApiClient', () => {
  let apiClient: ApiClient;

  beforeEach(() => {
    apiClient = new ApiClient('http://localhost:8000');
    vi.clearAllMocks();
  });

  it('should create user successfully', async () => {
    const mockUser = {
      id: 1,
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      isActive: true,
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: null
    };

    (fetch as any).mockResolvedValueOnce({
      ok: true,
      json: async () => mockUser
    });

    const userData = {
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      password: 'securepassword123'
    };

    const result = await apiClient.createUser(userData);

    expect(fetch).toHaveBeenCalledWith(
      'http://localhost:8000/api/v1/users/',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(userData)
      }
    );
    expect(result).toEqual(mockUser);
  });

  it('should handle API errors', async () => {
    (fetch as any).mockResolvedValueOnce({
      ok: false,
      statusText: 'Bad Request'
    });

    const userData = {
      email: 'invalid-email',
      firstName: 'John',
      lastName: 'Doe',
      password: 'short'
    };

    await expect(apiClient.createUser(userData)).rejects.toThrow(
      'Failed to create user: Bad Request'
    );
  });
});
```

## 🚀 Development Practices

### Error Handling

```python
# backend/app/core/exceptions.py
from fastapi import HTTPException, Request
from fastapi.responses import JSONResponse
from starlette.status import HTTP_500_INTERNAL_SERVER_ERROR
import logging

logger = logging.getLogger(__name__)

class CustomHTTPException(HTTPException):
    def __init__(self, status_code: int, detail: str, headers: dict = None):
        super().__init__(status_code=status_code, detail=detail, headers=headers)

async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.status_code,
                "message": exc.detail,
                "type": "http_error"
            }
        }
    )

async def general_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": {
                "code": HTTP_500_INTERNAL_SERVER_ERROR,
                "message": "Internal server error",
                "type": "server_error"
            }
        }
    )
```

```typescript
// frontend/lib/errors.ts
export class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public type: string = 'api_error'
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export async function handleApiResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
    
    try {
      const errorData = await response.json();
      if (errorData?.error?.message) {
        errorMessage = errorData.error.message;
      }
    } catch {
      // Use default error message if JSON parsing fails
    }
    
    throw new ApiError(errorMessage, response.status);
  }
  
  return response.json();
}

// Usage in API client
export class ApiClient {
  async createUser(userData: CreateUser): Promise<User> {
    const response = await fetch(`${this.baseUrl}/api/v1/users/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData),
    });

    const data = await handleApiResponse<User>(response);
    return UserResponseSchema.parse(data);
  }
}
```

## ⚠️ Critical Instructions

### NEVER
- Use `any` types without justification (TypeScript)
- Create files unless absolutely necessary
- Write production code without a failing test first
- Include AI/Claude mentions in commits
- Push to remote unless explicitly asked
- Remove from .env files (only add/comment)
- Update git config
- Create documentation unless requested

### ALWAYS
- Write tests first (TDD)
- Use TypeScript strict mode (frontend)
- Use Pydantic for validation in FastAPI
- Use Zod for validation in Next.js
- Import schemas from shared location in tests
- Prefer editing existing files
- Run tests after implementation
- Check database documentation before queries
- Use conventional commits
- Use async/await patterns consistently
- Validate API responses with schemas

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
- Database changes (Alembic migrations)
- API endpoints (FastAPI routes)
- Testing strategy (pytest + Vitest)

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Next.js Documentation](https://nextjs.org/docs)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Pydantic Documentation](https://docs.pydantic.dev/)
- [Zod Documentation](https://zod.dev/)
- [pytest Documentation](https://docs.pytest.org/)
- [Vitest Documentation](https://vitest.dev/)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.