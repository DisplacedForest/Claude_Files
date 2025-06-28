# Claude Code Setup for Claude Struct

## Quick Setup

1. **Copy the example settings file:**
   ```bash
   cp .claude/settings.local.json.example .claude/settings.local.json
   ```

2. **Verify Claude Code can access your project:**
   ```bash
   # Claude should now be able to run basic commands
   ls -la
   npm --version
   git status
   ```

3. **Test the multi-agent system:**
   ```bash
   # Try a simple command (if you have the commands set up)
   /add-feature "Test feature for setup"
   ```

## What This Configuration Provides

### ✅ Allowed Operations
- **File Management**: Read, write, edit any project files
- **Development Tools**: npm, testing frameworks, linting, building
- **Git Operations**: Full git and GitHub CLI access
- **Database Tools**: PostgreSQL, Redis, Supabase clients
- **Code Quality**: ESLint, Prettier, TypeScript compiler
- **Testing**: Jest, Vitest, Cypress, Playwright
- **Search & Analysis**: grep, find, ripgrep for code exploration

### ❌ Restricted Operations
- **No File Deletion**: Use git or manual deletion for safety
- **No Server Control**: You control dev servers (npm run dev)
- **No System Admin**: No sudo, no system modifications
- **No Package Removal**: Prevents accidental dependency removal
- **No Script Execution**: No running arbitrary scripts

## Customization

### Adding New Permissions
Edit `.claude/settings.local.json` and add to the "allow" array:
```json
{
  "permissions": {
    "allow": [
      "Bash(your-new-command:*)",
      // ... existing permissions
    ]
  }
}
```

### Framework-Specific Additions

**For Next.js projects:**
```json
"Bash(next:build*)",
"Bash(next:lint*)"
```

**For Python projects:**
```json
"Bash(python:*)",
"Bash(pip:install*)",
"Bash(pytest:*)"
```

**For Docker projects:**
```json
"Bash(docker:build*)",
"Bash(docker:run*)",
"Bash(docker-compose:*)"
```

## Security Notes

- **Server Control**: You maintain control of development servers
- **File Safety**: No accidental file deletion through rm commands
- **System Integrity**: No system-level modifications possible
- **Package Safety**: No accidental dependency removal

## Troubleshooting

### "Permission Denied" Errors
1. Check if the command pattern exists in the "allow" list
2. Verify there's no conflicting "deny" rule
3. Add specific permission if needed

### Command Not Working
1. Verify `.claude/settings.local.json` exists
2. Check JSON syntax is valid
3. Restart Claude Code session if needed

### Need More Permissions
1. Review the command you're trying to run
2. Add appropriate pattern to "allow" list
3. Consider security implications
4. Test with a simple command first

## Example Workflow

```bash
# 1. Claude can help with development
npm install                    # ✅ Allowed
npm test                      # ✅ Allowed
git add .                     # ✅ Allowed
git commit -m "feature"       # ✅ Allowed

# 2. But you control servers
npm run dev                   # ❌ Denied - you control this

# 3. Claude can help with code quality
npm run lint                  # ✅ Allowed
npm run build                 # ✅ Allowed

# 4. And manage project files safely
# (Claude uses Read/Write tools, not rm)
```

This configuration balances development assistance with security, ensuring Claude can help with code while you maintain control over critical operations.