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
└── templates/               # Project templates
    ├── github-issue-template.md
    └── implement-scaffold-templates.md
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
