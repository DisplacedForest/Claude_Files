# Claude Permissions Configuration Guide

## Overview
Claude Code requires specific permissions to assist with development while maintaining security. This guide explains the permission system and recommended settings.

## Permission File Location
- **Local Project**: `.claude/settings.local.json`
- **Global Settings**: `~/.claude/settings.json`

## Recommended Development Permissions

```json
{
  "permissions": {
    "allow": [
      // File System Operations
      "Bash(mkdir:*)",      // Create directories
      "Bash(cp:*)",         // Copy files
      "Bash(ls:*)",         // List directories
      "Bash(mv:*)",         // Move/rename files
      "Bash(cd:*)",         // Change directories
      "Bash(pwd)",          // Print working directory
      "Bash(touch:*)",      // Create empty files
      "Bash(cat:*)",        // View file contents
      "Bash(head:*)",       // View file beginning
      "Bash(tail:*)",       // View file end
      "Bash(find:*)",       // Find files
      "Bash(grep:*)",       // Search in files
      
      // Development Tools
      "Bash(npm:install*)", // Install dependencies
      "Bash(npm:test*)",    // Run tests
      "Bash(npm:run:lint*)", // Run linting
      "Bash(npm:run:build*)", // Build project
      "Bash(npm:run:typecheck*)", // Type checking
      "Bash(npm:audit*)",   // Security audit
      "Bash(npx:*)",        // Run npx commands
      
      // Git Operations
      "Bash(git:*)",        // All git commands
      "Bash(gh:*)",         // GitHub CLI
      
      // Database Tools
      "Bash(psql:*)",       // PostgreSQL client
      "Bash(redis-cli:*)",  // Redis client
      
      // File Editing Tools
      "Read(*)",            // Read any file
      "Write(*)",           // Write files
      "Edit(*)",            // Edit files
      "MultiEdit(*)",       // Multiple edits
      "Glob(*)",            // Pattern matching
      "Grep(*)",            // Content search
      "LS(*)",              // List files
      
      // Other Safe Commands
      "Bash(echo:*)",       // Output text
      "Bash(which:*)",      // Find commands
      "Bash(curl:*)",       // HTTP requests
      "Bash(true)",         // No-op command
      "Bash(false)",        // No-op command
      "Bash(test:*)",       // File tests
      "Bash([:*)",          // Bash tests
      
      // Development Utilities
      "Bash(jq:*)",         // JSON processing
      "Bash(sed:*)",        // Stream editing
      "Bash(awk:*)",        // Text processing
      "Bash(sort:*)",       // Sort output
      "Bash(uniq:*)",       // Unique lines
      "Bash(wc:*)",         // Word count
      "Bash(date:*)",       // Date operations
      
      // Tool Access
      "WebSearch(*)",       // Web search
      "WebFetch(*)",        // Fetch web content
      "Task(*)",            // Launch tasks
      "TodoRead",           // Read todos
      "TodoWrite(*)",       // Write todos
      "NotebookRead(*)",    // Read notebooks
      "NotebookEdit(*)"     // Edit notebooks
    ],
    "deny": [
      // Destructive Operations
      "Bash(rm:*)",         // No file deletion
      "Bash(rmdir:*)",      // No directory deletion
      "Bash(dd:*)",         // No disk operations
      "Bash(format:*)",     // No formatting
      
      // Server Management
      "Bash(npm:run:dev*)", // User starts dev server
      "Bash(npm:start*)",   // User starts production
      "Bash(node:server*)", // No direct server start
      "Bash(nodemon:*)",    // User manages nodemon
      
      // System Administration
      "Bash(sudo:*)",       // No elevated privileges
      "Bash(su:*)",         // No user switching
      "Bash(chmod:777*)",   // No unsafe permissions
      "Bash(chown:root*)",  // No root ownership
      
      // Dangerous Redirects
      "Bash(>:*)",          // No file overwrite
      "Bash(>>:*)",         // No file append
      
      // Network Operations
      "Bash(kill:*)",       // No process killing
      "Bash(killall:*)",    // No mass process killing
      "Bash(shutdown:*)",   // No system shutdown
      "Bash(reboot:*)",     // No system reboot
      
      // Package Management
      "Bash(npm:uninstall*)", // Careful with removals
      "Bash(apt:*)",        // No system packages
      "Bash(brew:uninstall*)", // No brew removals
      
      // Security Sensitive
      "Bash(ssh:*)",        // No SSH operations
      "Bash(scp:*)",        // No secure copy
      "Bash(gpg:*)",        // No encryption ops
      
      // Environment Modification
      "Bash(export:*)",     // No env var changes
      "Bash(unset:*)",      // No env var removal
      "Bash(source:*)",     // No sourcing files
      "Bash(./*)",          // No script execution
      "Bash(bash:*)",       // No subshells
      "Bash(sh:*)",         // No shell execution
      "Bash(zsh:*)",        // No zsh execution
    ]
  }
}
```

## Permission Patterns

### Allow Patterns
- `"Tool(*)"` - Allow all uses of a tool
- `"Bash(command:*)"` - Allow command with any arguments
- `"Bash(command:arg1:*)"` - Allow specific first argument
- `"Tool"` - Allow tool without arguments

### Deny Patterns
- Takes precedence over allow rules
- Use for specific dangerous operations
- Can be more specific than allow rules

## Security Best Practices

1. **Never Allow**:
   - Direct file deletion (`rm`, `unlink`)
   - System administration commands
   - Server startup (user should control)
   - Direct script execution

2. **Always Review**:
   - Any command that modifies system state
   - Network operations
   - Package installations

3. **User Responsibility**:
   - Starting development servers
   - Running production builds
   - System-level changes
   - Deployment operations

## Common Scenarios

### Frontend Development
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:install*)",
      "Bash(npm:run:build*)",
      "Bash(npm:run:test*)",
      "Bash(npm:run:lint*)",
      "Bash(npm:run:format*)"
    ]
  }
}
```

### API Development
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:run:migrate*)",
      "Bash(npm:run:seed*)",
      "Bash(psql:*)",
      "Bash(curl:*)"
    ]
  }
}
```

### Testing Focus
```json
{
  "permissions": {
    "allow": [
      "Bash(npm:test*)",
      "Bash(npm:run:test:*)",
      "Bash(jest:*)",
      "Bash(vitest:*)"
    ]
  }
}
```

## Troubleshooting

### Permission Denied
If Claude can't execute a command:
1. Check `settings.local.json` exists
2. Verify the command pattern matches
3. Check deny rules aren't blocking
4. Add specific permission if needed

### Adding New Permissions
1. Edit `.claude/settings.local.json`
2. Add to `allow` array
3. Save file
4. Claude immediately has access

### WSL Considerations
On Windows with WSL:
- Permissions apply within WSL environment
- Windows paths need proper escaping
- Some commands may differ from native Linux

## Example Setup Script Integration

The `/setup` command automatically creates this permission file:

```bash
# Create Claude settings directory
mkdir -p .claude

# Generate permissions file
cat > .claude/settings.local.json << 'EOF'
{
  "permissions": {
    "allow": [...],
    "deny": [...]
  }
}
EOF

echo "✅ Claude permissions configured"
```