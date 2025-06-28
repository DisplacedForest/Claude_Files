# Documentation Structure

This directory contains all project documentation organized by type.

## Directory Structure

```
docs/
├── features/           # Feature specifications and tracking
│   ├── ready.md       # Features ready for implementation
│   ├── specs/         # Detailed feature specifications
│   └── implementation/ # Implementation progress tracking
│
├── bugs/              # Bug tracking and fixes
│   ├── tracked.md     # Active bug list
│   └── fixes/         # Bug fix documentation
│
├── audit/             # Codebase audit reports
│   └── audit-{date}.md
│
├── api/               # API documentation
│   ├── README.md      # API overview
│   └── endpoints/     # Endpoint details
│
├── database/          # Database documentation
│   ├── schema.md      # Current schema
│   ├── erd.png        # Entity relationship diagram
│   └── migrations.md  # Migration history
│
├── architecture/      # System design documentation
│   ├── README.md      # Architecture overview
│   └── diagrams/      # Architecture diagrams
│
└── guides/            # Development guides
    ├── setup.md       # Environment setup
    ├── contributing.md # Contribution guidelines
    └── deployment.md  # Deployment procedures
```

## Key Documents

### Feature Management
- **ready.md** - List of features with GitHub issue links
- **specs/** - Detailed specifications created by `/plan` command
- **implementation/** - Progress tracking for active development

### Bug Tracking
- **tracked.md** - Central bug registry with issue numbers
- **fixes/** - Documentation of bug resolutions

### Technical Documentation
- **api/** - Auto-generated API documentation
- **database/** - Schema and relationship documentation
- **architecture/** - System design and component interaction

## Documentation Standards

1. **Markdown Format** - All docs use GitHub-flavored markdown
2. **Issue Linking** - Always reference GitHub issue numbers
3. **Auto-Generation** - Use `/document` command when possible
4. **Version Control** - Track all changes in git
5. **Regular Updates** - Keep in sync with code changes

## Quick Links

- [Command Documentation](../commands/README.md)
- [Feature Specifications](./features/specs/)
- [API Reference](./api/README.md)
- [Database Schema](./database/schema.md)
- [Architecture Overview](./architecture/README.md)