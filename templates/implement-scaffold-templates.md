# Implementation Scaffolding Templates

## API Endpoint Template
```typescript
// src/api/{resource}/{feature}.ts
import { Router } from 'express';
import { {service}Service } from '../../services/{service}';
import { authenticate } from '../../middleware/auth';
import { validate{Feature}Request } from './validators';

const router = Router();

// {HTTP_METHOD} /api/{resource}/{endpoint}
router.{method}('/{endpoint}', 
  authenticate,
  validate{Feature}Request,
  async (req, res) => {
    try {
      // TODO: Implement {description}
      // Success criteria: {success_criteria}
      
      const result = await {service}Service.{method}(req.params.id, req.body);
      res.json(result);
    } catch (error) {
      // TODO: Implement error handling
      res.status(500).json({ error: error.message });
    }
  }
);

export default router;
```

## Service Template
```typescript
// src/services/{feature}/{feature}Service.ts
import { {Model} } from '../../models/{Model}';
import { {Feature}Repository } from '../../repositories/{feature}Repository';

export class {Feature}Service {
  constructor(
    private repository: {Feature}Repository,
    // Add external service clients as needed
  ) {}

  async {method}({params}): Promise<{ReturnType}> {
    // TODO: Implement {method}
    // Requirements from issue #{issue}:
    // {requirements_list}
    
    throw new Error('Not implemented');
  }
}

export const {feature}Service = new {Feature}Service(
  new {Feature}Repository()
);
```

## Model Template
```typescript
// src/models/{Model}.ts
import { BaseModel } from './BaseModel';

export interface {Model}Data {
  id: string;
  // TODO: Add fields based on requirements
  createdAt: Date;
  updatedAt: Date;
}

export class {Model} extends BaseModel implements {Model}Data {
  id: string;
  // TODO: Implement model fields
  
  constructor(data: {Model}Data) {
    super();
    Object.assign(this, data);
  }

  // TODO: Add validation methods
  validate(): boolean {
    return true;
  }

  // TODO: Add business logic methods
}
```

## Repository Template
```typescript
// src/repositories/{feature}Repository.ts
import { Database } from '../../database';
import { {Model} } from '../models/{Model}';

export class {Feature}Repository {
  constructor(private db: Database = Database.getInstance()) {}

  async findById(id: string): Promise<{Model} | null> {
    // TODO: Implement database query
    const result = await this.db.query(
      'SELECT * FROM {table} WHERE id = $1',
      [id]
    );
    return result.rows[0] ? new {Model}(result.rows[0]) : null;
  }

  async create(data: Partial<{Model}>): Promise<{Model}> {
    // TODO: Implement insert query
    throw new Error('Not implemented');
  }

  async update(id: string, data: Partial<{Model}>): Promise<{Model}> {
    // TODO: Implement update query
    throw new Error('Not implemented');
  }

  async delete(id: string): Promise<boolean> {
    // TODO: Implement delete query
    throw new Error('Not implemented');
  }
}
```

## Test Template
```typescript
// tests/{path}/{feature}.test.ts
import { {Feature}Service } from '../../../src/services/{feature}';
import { mock{Dependency} } from '../../mocks/{dependency}';

describe('{Feature}Service', () => {
  let service: {Feature}Service;
  
  beforeEach(() => {
    // TODO: Set up test dependencies
    service = new {Feature}Service(mock{Dependency});
  });

  describe('{method}', () => {
    // Generate test cases from success criteria
    {testCases}
  });
});
```

## React Component Template
```tsx
// src/components/{Feature}/{Feature}.tsx
import React, { useState, useEffect } from 'react';
import { use{Feature} } from '../../hooks/use{Feature}';
import { {Feature}Props } from './types';

export const {Feature}: React.FC<{Feature}Props> = ({ 
  // TODO: Add props based on requirements
}) => {
  const { data, loading, error, {method} } = use{Feature}();
  
  // TODO: Implement component logic
  // Requirements from issue #{issue}:
  // {ui_requirements}

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return (
    <div className="{feature}-container">
      {/* TODO: Implement UI based on requirements */}
    </div>
  );
};
```

## Migration Template
```sql
-- migrations/{timestamp}_{feature}.sql
-- Issue #{issue}: {feature_name}

-- Up Migration
BEGIN;

-- TODO: Create tables based on data model requirements
CREATE TABLE IF NOT EXISTS {table_name} (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Add columns based on requirements
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- TODO: Add indexes based on query patterns
CREATE INDEX idx_{table}_{field} ON {table_name}({field});

-- TODO: Add foreign key constraints
ALTER TABLE {table_name} 
  ADD CONSTRAINT fk_{table}_{reference}
  FOREIGN KEY ({field}) REFERENCES {reference_table}(id);

COMMIT;

-- Down Migration
BEGIN;
DROP TABLE IF EXISTS {table_name} CASCADE;
COMMIT;
```

## Usage in /implement Command

When `/implement {issue}` is run, these templates are used to:

1. Parse requirements from GitHub issue
2. Identify needed components (API, Service, Model, etc.)
3. Fill templates with issue-specific data:
   - Extract success criteria → test cases
   - Extract technical requirements → TODOs
   - Extract data model → model fields
   - Extract API specs → endpoint definitions
4. Generate file structure maintaining project conventions
5. Create pending tests that map to success criteria
6. Add implementation tracking comments linking back to issue

## Template Variables
- `{issue}` - GitHub issue number
- `{feature}` - Feature name in camelCase
- `{Feature}` - Feature name in PascalCase  
- `{method}` - Method name from requirements
- `{success_criteria}` - Extracted from issue checkboxes
- `{requirements_list}` - Bullet points from technical requirements
- `{ui_requirements}` - Frontend-specific requirements
- `{table_name}` - Database table name
- `{Model}` - Model class name
- `{ReturnType}` - TypeScript return type