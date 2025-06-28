# Development Guide for Claude - Angular + NestJS

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
Framework: Angular 17+ + NestJS 10+
Language: TypeScript (strict mode)
Testing: Jest + Cypress + Angular Testing Library
Database: PostgreSQL with TypeORM
Validation: class-validator + class-transformer
State Management: NgRx (Signal Store)
Styling: Angular Material + Tailwind CSS
Package Manager: npm
Auth: NestJS Passport + JWT
```

## 📁 Repository Structure

```
/
├── apps/                    # Nx workspace apps
│   ├── frontend/           # Angular application
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── core/           # Singletons, guards, interceptors
│   │   │   │   ├── shared/         # Shared components, directives, pipes
│   │   │   │   ├── features/       # Feature modules (lazy-loaded)
│   │   │   │   ├── store/          # NgRx store configuration
│   │   │   │   └── app.module.ts
│   │   │   ├── assets/
│   │   │   ├── environments/
│   │   │   └── main.ts
│   │   └── cypress/         # E2E tests
│   └── backend/            # NestJS application
│       ├── src/
│       │   ├── app.module.ts
│       │   ├── main.ts
│       │   ├── auth/              # Authentication module
│       │   ├── users/             # User management module
│       │   ├── database/          # TypeORM configuration
│       │   ├── common/            # Guards, decorators, filters
│       │   └── [feature-modules]/ # Domain-specific modules
│       └── test/            # E2E tests
├── libs/                   # Shared libraries
│   ├── shared/
│   │   ├── types/          # Shared TypeScript interfaces
│   │   ├── dtos/           # Data Transfer Objects
│   │   ├── validators/     # Shared validation classes
│   │   └── constants/      # Shared constants
│   └── [domain-libs]/      # Domain-specific libraries
├── database/               # Database configuration
│   ├── migrations/         # TypeORM migrations
│   ├── seeds/             # Database seed files
│   └── data-source.ts     # TypeORM data source config
├── docs/                  # Documentation
│   ├── features/          # Feature specs and planning
│   ├── db/               # Database documentation
│   ├── api/              # API documentation
│   └── ADRs/             # Architectural Decision Records
└── .claude/              # AI assistant configuration
    └── commands/         # Custom AI commands
```

## 🗄️ Database Documentation (CRITICAL FOR AI)

### Overview Documentation Structure

```markdown
# docs/db/00_database_overview.md

## Architecture Philosophy
Domain-driven design with clear module boundaries using TypeORM entities

## Database Technology
- Platform: PostgreSQL 15+
- ORM: TypeORM with migrations
- Client: TypeORM Repository pattern
- Security: Database-level constraints + application validation
- Auth: NestJS Passport with JWT tokens
- Connection: TypeORM connection pooling

## Schema Organization Strategy
### Domain Boundaries
Core Domain       → Users, Authentication, Core Business Logic
Supporting Domain → Notifications, File Management
Analytics Domain  → Usage tracking, Performance metrics

### Cross-Domain Integration Points
- Users entity referenced across all domains
- Event-driven architecture for cross-module communication

## Entity Naming Conventions
- Entities: PascalCase (User, OrderItem)
- Tables: snake_case (users, order_items)
- Relationships: Explicit naming for junction tables

## Critical Relationships Map
Users -> Posts (One-to-Many)
Users -> Roles (Many-to-Many via user_roles)
Posts -> Categories (Many-to-Many via post_categories)

## Query Performance Guidelines
### Hot Paths (Optimize First)
- User authentication queries
- Dashboard data loading
- Real-time notification queries

## Business Context
Enterprise application supporting multi-tenant SaaS with role-based access control
```

### TypeORM Entity Patterns

```typescript
// libs/shared/entities/user.entity.ts
import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { IsEmail, IsNotEmpty, MinLength } from 'class-validator';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  @IsEmail()
  email: string;

  @Column()
  @IsNotEmpty()
  @MinLength(2)
  firstName: string;

  @Column()
  @IsNotEmpty()
  @MinLength(2)
  lastName: string;

  @Column({ select: false })
  @MinLength(8)
  password: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Post, post => post.author)
  posts: Post[];
}
```

## 🔄 Development Workflow

### Test-Driven Development Cycle

```typescript
// Step 1: RED - Write a failing test
describe('UserService', () => {
  it('should create user with valid data', async () => {
    const createUserDto: CreateUserDto = {
      email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      password: 'securepass123'
    };
    
    const result = await userService.create(createUserDto);
    
    expect(result.email).toBe(createUserDto.email);
    expect(result.password).toBeUndefined(); // Password should not be returned
  });
});

// Step 2: GREEN - Minimal implementation
@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(createUserDto: CreateUserDto): Promise<UserResponseDto> {
    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);
    
    const user = this.userRepository.create({
      ...createUserDto,
      password: hashedPassword,
    });
    
    const savedUser = await this.userRepository.save(user);
    
    return {
      id: savedUser.id,
      email: savedUser.email,
      firstName: savedUser.firstName,
      lastName: savedUser.lastName,
      createdAt: savedUser.createdAt,
    };
  }
}

// Step 3: REFACTOR - Assess improvements
// Only refactor if it adds value. If code is clean, move on.
```

### Angular Component TDD

```typescript
// Step 1: RED - Component test
describe('UserListComponent', () => {
  it('should display users when loaded', () => {
    const mockUsers: User[] = [
      { id: '1', email: 'test@example.com', firstName: 'John', lastName: 'Doe' }
    ];
    
    component.users.set(mockUsers);
    fixture.detectChanges();
    
    const userElements = fixture.debugElement.queryAll(By.css('[data-testid="user-item"]'));
    expect(userElements.length).toBe(1);
    expect(userElements[0].nativeElement.textContent).toContain('John Doe');
  });
});

// Step 2: GREEN - Component implementation
@Component({
  selector: 'app-user-list',
  template: `
    <div class="user-grid">
      @for (user of users(); track user.id) {
        <div data-testid="user-item" class="user-card">
          <h3>{{ user.firstName }} {{ user.lastName }}</h3>
          <p>{{ user.email }}</p>
        </div>
      }
    </div>
  `,
  standalone: true,
})
export class UserListComponent {
  users = signal<User[]>([]);
}
```

## 📐 Architecture Principles

### Schema-First Development with class-validator

```typescript
// 1. Define DTO with validation (apps/backend/src/users/dto/create-user.dto.ts)
import { IsEmail, IsNotEmpty, MinLength, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsEmail({}, { message: 'Please provide a valid email address' })
  email: string;

  @IsNotEmpty({ message: 'First name is required' })
  @MinLength(2, { message: 'First name must be at least 2 characters' })
  firstName: string;

  @IsNotEmpty({ message: 'Last name is required' })
  @MinLength(2, { message: 'Last name must be at least 2 characters' })
  lastName: string;

  @MinLength(8, { message: 'Password must be at least 8 characters' })
  password: string;

  @IsOptional()
  avatar?: string;
}

// 2. Use in controller with validation pipe
@Post()
@UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
async create(@Body() createUserDto: CreateUserDto): Promise<UserResponseDto> {
  return this.userService.create(createUserDto);
}

// 3. Angular service uses same DTO structure
@Injectable({
  providedIn: 'root'
})
export class UserApiService {
  constructor(private http: HttpClient) {}

  createUser(userData: CreateUserDto): Observable<UserResponseDto> {
    return this.http.post<UserResponseDto>('/api/users', userData);
  }
}
```

### NgRx Signal Store Pattern

```typescript
// apps/frontend/src/app/store/users.store.ts
import { patchState, signalStore, withComputed, withMethods, withState } from '@ngrx/signals';
import { computed, inject } from '@angular/core';

interface UsersState {
  users: User[];
  loading: boolean;
  error: string | null;
  selectedUserId: string | null;
}

const initialState: UsersState = {
  users: [],
  loading: false,
  error: null,
  selectedUserId: null,
};

export const UsersStore = signalStore(
  { providedIn: 'root' },
  withState(initialState),
  withComputed(({ users, selectedUserId }) => ({
    selectedUser: computed(() => 
      users().find(user => user.id === selectedUserId()) ?? null
    ),
    userCount: computed(() => users().length),
  })),
  withMethods((store, userService = inject(UserApiService)) => ({
    async loadUsers(): Promise<void> {
      patchState(store, { loading: true, error: null });
      
      try {
        const users = await userService.getUsers().toPromise();
        patchState(store, { users, loading: false });
      } catch (error) {
        patchState(store, { 
          error: error instanceof Error ? error.message : 'Failed to load users',
          loading: false 
        });
      }
    },
    
    selectUser(userId: string): void {
      patchState(store, { selectedUserId: userId });
    },
  }))
);
```

## 🧪 Testing Guidelines

### NestJS Service Testing

```typescript
// apps/backend/test/users/user.service.spec.ts
describe('UserService', () => {
  let service: UserService;
  let repository: Repository<User>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        {
          provide: getRepositoryToken(User),
          useClass: Repository,
        },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    repository = module.get<Repository<User>>(getRepositoryToken(User));
  });

  describe('create', () => {
    it('should create user with hashed password', async () => {
      const createUserDto: CreateUserDto = {
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        password: 'plaintext',
      };

      const savedUser = { ...createUserDto, id: 'uuid', password: 'hashed' };
      jest.spyOn(repository, 'create').mockReturnValue(savedUser as User);
      jest.spyOn(repository, 'save').mockResolvedValue(savedUser as User);

      const result = await service.create(createUserDto);

      expect(result.password).toBeUndefined();
      expect(result.email).toBe(createUserDto.email);
    });
  });
});
```

### Angular Component Testing

```typescript
// apps/frontend/src/app/features/users/user-list.component.spec.ts
describe('UserListComponent', () => {
  let component: UserListComponent;
  let fixture: ComponentFixture<UserListComponent>;
  let usersStore: InstanceType<typeof UsersStore>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [UserListComponent],
      providers: [UsersStore],
    }).compileComponents();

    fixture = TestBed.createComponent(UserListComponent);
    component = fixture.componentInstance;
    usersStore = TestBed.inject(UsersStore);
  });

  it('should load users on init', () => {
    const loadUsersSpy = jest.spyOn(usersStore, 'loadUsers');
    
    component.ngOnInit();
    
    expect(loadUsersSpy).toHaveBeenCalled();
  });

  it('should display loading state', () => {
    usersStore.patchState({ loading: true });
    fixture.detectChanges();
    
    const loadingElement = fixture.debugElement.query(By.css('[data-testid="loading"]'));
    expect(loadingElement).toBeTruthy();
  });
});
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
    "exactOptionalPropertyTypes": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "angularCompilerOptions": {
    "enableIvy": true,
    "strictInputAccessModifiers": true,
    "strictTemplates": true
  }
}
```

### NestJS Module Structure

```typescript
// apps/backend/src/users/users.module.ts
@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}

// apps/backend/src/users/users.controller.ts
@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async create(@Body() createUserDto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(createUserDto);
  }

  @Get()
  async findAll(): Promise<UserResponseDto[]> {
    return this.usersService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
    return this.usersService.findOne(id);
  }
}
```

## 🚀 Development Practices

### Error Handling

```typescript
// NestJS Custom Exception Filter
@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    
    if (exception instanceof ValidationError) {
      return response.status(400).json({
        statusCode: 400,
        message: 'Validation failed',
        errors: exception.constraints,
      });
    }
    
    if (exception instanceof EntityNotFoundError) {
      return response.status(404).json({
        statusCode: 404,
        message: 'Resource not found',
      });
    }
    
    // Log unexpected errors
    console.error(exception);
    
    return response.status(500).json({
      statusCode: 500,
      message: 'Internal server error',
    });
  }
}

// Angular Error Handling
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  handleError(error: Error): void {
    if (error instanceof HttpErrorResponse) {
      // Handle HTTP errors
      console.error('HTTP Error:', error.message);
      // Show user-friendly message
      this.notificationService.showError('Something went wrong. Please try again.');
    } else {
      // Handle unexpected errors
      console.error('Unexpected error:', error);
      this.notificationService.showError('An unexpected error occurred.');
    }
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
- Use class-validator for validation in DTOs
- Import DTOs from shared location in tests
- Prefer editing existing files
- Run tests after implementation
- Check database documentation before queries
- Use conventional commits
- Use TypeORM Repository pattern
- Implement NgRx Signal Store for state management

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
- Database changes (TypeORM migrations)
- API endpoints (NestJS controllers)
- Testing strategy (Jest + Cypress)

### /add-feature [feature-name]
Adds feature to planning queue with strategic questions for consideration

## 📚 Resources

- [Angular Documentation](https://angular.io/docs)
- [NestJS Documentation](https://docs.nestjs.com/)
- [TypeORM Documentation](https://typeorm.io/)
- [NgRx Documentation](https://ngrx.io/)
- [class-validator Documentation](https://github.com/typestack/class-validator)
- Project-specific ADRs in `/docs/ADRs/`

---

**Remember**: The key is writing clean, testable, functional code that evolves through small, safe increments. Every change should be driven by a test that describes the desired behavior. When in doubt, favor simplicity and readability over cleverness.