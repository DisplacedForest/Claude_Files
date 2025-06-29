# Claude Development Methodology & Templates

A comprehensive collection of development best practices, methodology guides, and project templates for building high-quality applications with Claude Code.

## 🎯 What This Provides

This repository contains:

- **Development Methodology** - Test-driven development principles and practices
- **Tech Stack Guides** - Detailed recommendations for choosing the right technology stack
- **Project Templates** - Ready-to-use CLAUDE.md files for different frameworks
- **Configuration Guides** - Security, permissions, and integration setup
- **Best Practices** - Code quality, architecture, and workflow guidelines

## 📁 Repository Structure

```
claude-development-methodology/
├── CLAUDE.md                 # Core development methodology and principles
├── TECHSTACKS.md             # Comprehensive tech stack selection guide
├── README.md                 # This file
│
├── guides/                   # Setup and configuration guides
│   ├── claude-permissions-guide.md  # Security and permissions
│   └── github-integration-guide.md  # GitHub workflow setup
│
├── tech-stacks/             # Framework-specific templates
│   ├── react-express/       # React + Express configuration
│   ├── nextjs/             # Next.js configuration
│   ├── vue-express/        # Vue + Express configuration
│   ├── angular-nestjs/     # Angular + NestJS configuration
│   ├── fastapi-nextjs/     # FastAPI + Next.js configuration
│   ├── ruby-on-rails/      # Ruby on Rails configuration
│   ├── swift-coredata/     # Swift + CoreData configuration
│   └── astro-strapi/       # Astro + Strapi configuration
│
├── docs/                    # Documentation templates
│   ├── features/           # Feature planning templates
│   ├── bugs/              # Bug tracking templates
│   └── templates/         # Reusable documentation templates
│
├── templates/               # Project templates
│   ├── github-issue-template.md
│   └── implement-scaffold-templates.md
│
└── .claude/                 # Claude Code configuration and commands
    ├── CLAUDE.md           # Project-specific development methodology
    ├── SETUP.md            # Claude Code setup instructions
    ├── settings.local.json.example  # Example permissions configuration
    ├── settings.local.json # Local permissions (gitignored)
    ├── commands/           # Claude custom commands
    │   ├── agents/         # Multi-agent development system
    │   └── [commands]      # Individual command definitions
    └── scripts/            # PowerShell scripts for agent spawning
        ├── claude-spawn.ps1        # Core script to spawn Claude instances
        ├── backend_dev.ps1         # Backend developer agent script
        ├── db_architect.ps1        # Database architect agent script
        ├── e2e_test_engineer.ps1   # E2E test engineer agent script
        ├── frontend_dev.ps1        # Frontend developer agent script
        ├── lint_fixer.ps1          # Lint fixer agent script
        ├── monitor-agent.ps1       # Agent monitoring script
        ├── qa_agent.ps1            # QA agent script
        └── test_engineer.ps1       # Test engineer agent script
```

## 🚀 Getting Started

### 1. Choose Your Tech Stack

Start with the [Tech Stack Selection Guide](TECHSTACKS.md) to choose the best framework combination for your project:

- **SaaS Dashboard** → React + Express
- **E-commerce** → Next.js  
- **Content Site** → Astro + Strapi
- **Enterprise App** → Angular + NestJS
- **AI Application** → FastAPI + Next.js
- **iOS App** → Swift + CoreData
- **MVP/Prototype** → Ruby on Rails

### 2. Set Up Your Development Environment

1. **Copy the appropriate template:**
   ```bash
   cp tech-stacks/[your-stack]/CLAUDE.md .claude/
   ```

2. **Configure Claude permissions:**
   Follow the [Claude Permissions Guide](guides/claude-permissions-guide.md)

3. **Set up GitHub integration:**
   Follow the [GitHub Integration Guide](guides/github-integration-guide.md)

### 3. Follow the Development Methodology

The [Master Development Guide](CLAUDE.md) provides:

- **Test-Driven Development** - Write tests first, always
- **Schema-First Development** - Define types and validation upfront
- **Functional Programming** - Immutable data, pure functions
- **Type Safety** - Strict TypeScript configuration
- **Code Quality** - Standards and best practices

## 🎯 Core Principles

### Test-Driven Development (TDD)
Every line of production code must be written in response to a failing test:

1. **RED** - Write a failing test
2. **GREEN** - Write minimal code to pass
3. **REFACTOR** - Improve code quality

### Schema-First Development
Define your data structures with Zod schemas:

```typescript
// 1. Define schema
export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  role: z.enum(['user', 'admin']),
});

// 2. Derive types
export type User = z.infer<typeof UserSchema>;

// 3. Validate at runtime
export const parseUser = (data: unknown): User => {
  return UserSchema.parse(data);
};
```

### Functional Programming
- Immutable data structures
- Pure functions
- Options objects for parameters
- Result types for error handling

## 🔧 Tech Stack Templates

Each tech stack template includes:

- **Development workflow** - TDD, testing, linting
- **Architecture patterns** - Component structure, state management
- **Database setup** - Schema, migrations, queries
- **Security configuration** - Authentication, authorization
- **Deployment guidelines** - Build, test, deploy

### Available Templates

| Stack | Use Case | Strengths |
|-------|----------|-----------|
| **React + Express** | Complex SPAs, dashboards | Maximum flexibility, microservices |
| **Next.js** | E-commerce, content sites | SEO, performance, full-stack |
| **Vue + Express** | Internal tools, forms | Gentle learning curve, templates |
| **Angular + NestJS** | Enterprise applications | Type safety, dependency injection |
| **FastAPI + Next.js** | AI/ML applications | Python ecosystem, async |
| **Ruby on Rails** | MVPs, prototypes | Rapid development, conventions |
| **Swift + CoreData** | iOS applications | Native performance, Apple ecosystem |
| **Astro + Strapi** | Content platforms | Static generation, headless CMS |

## 📊 Development Standards

### Code Quality
- **No `any` types** - Use `unknown` if truly unknown
- **Strict TypeScript** - All compiler checks enabled
- **Self-documenting code** - No comments needed
- **Small functions** - Single responsibility principle

### Testing
- **Behavior-driven tests** - Test what code should do
- **Test factories** - Reusable test data creation
- **Schema validation** - Import schemas from production code
- **100% behavior coverage** - Every requirement tested

### Architecture
- **Domain-driven design** - Clear bounded contexts
- **Functional core** - Pure business logic
- **Immutable data** - No mutations
- **Result types** - Explicit error handling

## 🛡️ Security & Safety

### Claude Configuration
- **Safe operations only** - No destructive commands
- **User-controlled servers** - No automatic startup
- **Explicit permissions** - Clear allow/deny rules
- **Regular audits** - Review permission usage

### Development Security
- **Environment variables** - No secrets in code
- **Input validation** - Zod schemas at boundaries
- **SQL injection prevention** - Parameterized queries
- **Authentication** - JWT tokens, proper sessions

## 📖 How to Use This Repository

### For New Projects
1. Review the [Tech Stack Guide](TECHSTACKS.md)
2. Copy the appropriate template from `tech-stacks/`
3. Follow the [Master Development Guide](MASTER_CLAUDE.md)
4. Configure permissions with the [Claude Permissions Guide](guides/claude-permissions-guide.md)

### For Existing Projects
1. Review your current stack against the recommendations
2. Adopt the TDD methodology from the master guide
3. Implement schema-first development with Zod
4. Configure Claude permissions for your specific needs

### For Teams
1. Use this as your development standards document
2. Reference specific sections during code reviews
3. Onboard new developers with the methodology guide
4. Customize templates for your organization's needs

## 🤝 Contributing

This is a living document. To contribute:

1. **Templates** - Add new tech stack combinations
2. **Guides** - Improve setup and configuration instructions
3. **Best Practices** - Share lessons learned from real projects
4. **Documentation** - Clarify existing content

## 📚 Documentation

- **[Master Development Guide](MASTER_CLAUDE.md)** - Core methodology and principles
- **[Tech Stack Selection](TECHSTACKS.md)** - Framework decision matrix
- **[Claude Permissions](guides/claude-permissions-guide.md)** - Security configuration
- **[GitHub Integration](guides/github-integration-guide.md)** - Issue and PR workflows
- **[Project Templates](tech-stacks/)** - Framework-specific configurations

## 🤖 Claude Commands & Agents

### Available Commands

#### Planning & Tracking
- **`/add-feat`** - Create and track new features with GitHub issues
- **`/add-bug`** - Report and track bugs with structured templates
- **`/plan`** - Create detailed specifications from feature requirements

#### Development
- **`/implement`** - Generate scaffolding from issue requirements
- **`/test`** - Validate implementation against requirements
- **`/fix`** - Structured bug fixing workflow
- **`/refactor`** - Safe code refactoring with impact analysis

#### Deployment & Operations
- **`/release`** - Manage releases with changelog generation
- **`/migrate`** - Database migration management
- **`/monitor`** - Performance monitoring and alerting

#### Quality & Documentation
- **`/audit`** - Comprehensive codebase analysis
- **`/review`** - Automated PR review
- **`/document`** - Auto-generate documentation

#### Setup & Configuration
- **`/setup`** - Developer environment setup

### Multi-Agent Development System

The `.claude/commands/agents/` directory contains specialized AI agents that work together to implement complex features using Test-Driven Development (TDD) principles:

#### Agent Roles

1. **Orchestrator** (`/orchestrate`) - Master coordinator that manages the entire workflow
   - Analyzes feature requirements and spawns appropriate agents
   - Enforces TDD practices (tests first, implementation second)
   - Manages inter-agent communication

2. **Test Engineer** - PRIMARY agent that writes failing tests first
   - Creates comprehensive test cases from acceptance criteria
   - Ensures 100% behavior coverage
   - ALWAYS runs before any implementation

3. **Database Architect** - Designs database schemas and migrations
   - Creates structures to support test requirements
   - Documents schema changes and business rules

4. **Backend Developer** - Implements server-side logic and APIs
   - Creates minimal code to make tests pass
   - Follows functional programming patterns

5. **Frontend Developer** - Implements UI components
   - Builds components to satisfy test requirements
   - Uses TypeScript strict mode throughout

6. **E2E Test Engineer** - Creates end-to-end integration tests
   - Validates complete user journeys
   - Tests workflows across full stack

7. **QA Agent** - Final quality validation
   - Runs full test suite
   - Validates code quality standards
   - Ensures documentation completeness

8. **Lint Fixer** - Automated code quality enforcement
   - Fixes style and quality issues
   - Preserves functionality while improving code

#### Usage Examples

```bash
# Simple feature (backend only)
/orchestrate "Add user profile endpoint"

# Complex feature (full stack)
/orchestrate "Implement user dashboard with analytics"

# Starting a new feature workflow
/add-feat "User authentication"       # Creates issue #123
/plan 123                             # Creates detailed spec
/implement 123                        # Generates code scaffolding
/test 123                            # Validates implementation
/review 456                          # Reviews PR #456
/release 2.0.0                       # Creates release
```

### Command Workflow

All commands integrate with GitHub issues using standardized status labels:
- `Backlog` - Initial state for features
- `Ready` - Requirements defined, ready to implement
- `In progress` - Currently being worked on
- `In review` - PR created, under review
- `Done` - Completed and merged

### PowerShell Scripts

The `.claude/scripts/` directory contains PowerShell scripts that enable the multi-agent system to spawn independent Claude instances for parallel development:

#### Core Script
- **`claude-spawn.ps1`** - Main script that spawns Claude in new Windows Terminal windows
  - Handles Windows-to-WSL path conversion
  - Opens Claude with specific tasks in new terminal windows
  - Enables true parallel agent execution

#### Agent Scripts
Each agent has a corresponding PowerShell script that:
- Spawns a new Claude instance with agent-specific instructions
- Passes the appropriate agent markdown file as context
- Enables concurrent execution of multiple agents
- Maintains isolation between agent responsibilities

#### Usage
These scripts are automatically called by the orchestrator when spawning agents:
```powershell
# Example: Spawn test engineer agent
./.claude/scripts/test_engineer.ps1

# Example: Monitor agent execution
./.claude/scripts/monitor-agent.ps1
```

### Claude Code Configuration

#### Setup Process
1. **Copy the example settings:**
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   ```

2. **Permissions Configuration:**
   The `settings.local.json` file controls what Claude can and cannot do:
   - **Allowed**: File operations, development tools, git, testing frameworks
   - **Restricted**: File deletion, server control, system admin, package removal

3. **Verify Setup:**
   Follow `.claude/SETUP.md` for detailed setup instructions and permission customization

## 🎯 Philosophy

**Quality through discipline.** Every practice in this repository is designed to:

- Prevent bugs through testing
- Ensure maintainability through clean code
- Enable collaboration through clear standards
- Deliver value through iterative development

The goal is not to be clever, but to be **reliable, maintainable, and effective**.

## 📝 License

MIT License - Use freely for any project or organization.

---

*This methodology has been refined through real-world application across multiple projects and teams. It emphasizes practical techniques that actually work in production environments.*
