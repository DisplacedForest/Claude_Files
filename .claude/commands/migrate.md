# Migrate Command

## Usage
`/migrate {issue-number} [--preview] [--rollback]`

## Description
Manages database migrations tied to feature implementations, ensuring safe schema changes with rollback capabilities.

## Process Flow

1. **Load Migration Requirements**
   - Fetch GitHub issue #{issue-number}
   - Extract data model changes from requirements
   - Identify affected tables and relationships
   - Check for breaking changes

2. **Generate Migration Files**
   - Create timestamped migration files
   - Generate UP migration (apply changes)
   - Generate DOWN migration (rollback)
   - Include data transformation logic
   - Add migration metadata

3. **Impact Analysis**
   - Analyze affected tables and indexes
   - Estimate migration duration
   - Identify blocking operations
   - Check foreign key impacts
   - Calculate downtime requirements

4. **Safety Validation**
   - Test migration on copy of production schema
   - Verify rollback procedures
   - Check data integrity rules
   - Validate performance impact
   - Ensure backup availability

5. **Execute Migration**
   - Create pre-migration backup
   - Apply migration in transaction
   - Verify data consistency
   - Update schema documentation
   - Log migration in history table

6. **Update Tracking**
   - Update GitHub issue with migration status
   - Document schema changes
   - Update ER diagrams
   - Add to migration changelog

## Migration File Format

```sql
-- migrations/20240115143022_issue_234_contact_enrichment.sql
-- Issue #234: Advanced Contact Enrichment
-- Generated: 2024-01-15 14:30:22
-- Author: /migrate command
-- Estimated Duration: 45 seconds
-- Downtime Required: No (online migration)

-- ============ UP MIGRATION ============
BEGIN;

-- Add enrichment data table
CREATE TABLE contact_enrichment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    source VARCHAR(50) NOT NULL,
    source_id VARCHAR(255),
    data JSONB NOT NULL,
    confidence_score DECIMAL(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
    fetched_at TIMESTAMP NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add indexes for performance
CREATE INDEX idx_enrichment_contact_id ON contact_enrichment(contact_id);
CREATE INDEX idx_enrichment_source ON contact_enrichment(source);
CREATE INDEX idx_enrichment_expires ON contact_enrichment(expires_at) WHERE expires_at IS NOT NULL;

-- Add enrichment status to contacts
ALTER TABLE contacts 
ADD COLUMN enrichment_status VARCHAR(20) DEFAULT 'pending',
ADD COLUMN last_enriched_at TIMESTAMP,
ADD COLUMN enrichment_score DECIMAL(3,2);

-- Create update trigger
CREATE TRIGGER update_contact_enrichment_timestamp
    BEFORE UPDATE ON contact_enrichment
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add constraints
ALTER TABLE contacts
ADD CONSTRAINT chk_enrichment_status 
CHECK (enrichment_status IN ('pending', 'enriched', 'failed', 'stale'));

-- Migrate existing data
UPDATE contacts 
SET enrichment_status = 'pending' 
WHERE enrichment_status IS NULL;

-- Add migration metadata
INSERT INTO schema_migrations (version, name, issue_number, applied_at)
VALUES ('20240115143022', 'contact_enrichment', 234, NOW());

COMMIT;

-- ============ DOWN MIGRATION ============
BEGIN;

-- Remove migration metadata
DELETE FROM schema_migrations WHERE version = '20240115143022';

-- Drop new columns from contacts
ALTER TABLE contacts 
DROP COLUMN IF EXISTS enrichment_status,
DROP COLUMN IF EXISTS last_enriched_at,
DROP COLUMN IF EXISTS enrichment_score;

-- Drop enrichment table
DROP TABLE IF EXISTS contact_enrichment CASCADE;

COMMIT;

-- ============ MIGRATION METRICS ============
-- Tables affected: 2 (contacts, contact_enrichment)
-- Rows affected: ~50,000 (UPDATE on contacts)
-- Indexes created: 3
-- Estimated time: 45 seconds
-- Blocking: ALTER TABLE contacts (brief lock)
-- Rollback time: 10 seconds
```

## Preview Mode

```
/migrate 234 --preview
```

Output:
```
🔍 Migration Preview for Issue #234

📊 Schema Changes:
  NEW TABLES:
    - contact_enrichment (9 columns, 3 indexes)
  
  MODIFIED TABLES:
    - contacts (+3 columns)
  
  CONSTRAINTS:
    - FK: contact_enrichment.contact_id → contacts.id
    - CHECK: enrichment_status values
    - CHECK: confidence_score range

⏱️  Performance Impact:
  - Estimated Duration: 45 seconds
  - Lock Required: Yes (ALTER TABLE)
  - Lock Duration: ~2 seconds
  - Affected Rows: 50,000
  - Space Required: ~25 MB

⚠️  Warnings:
  - Brief lock on contacts table during ALTER
  - Ensure enrichment service is ready before migration

✅ Rollback Plan:
  - Rollback Duration: 10 seconds
  - Data Loss Risk: None
  - Complexity: Low

📝 Generated Files:
  - migrations/20240115143022_issue_234_contact_enrichment.sql
  - rollback/20240115143022_rollback.sql
  - docs/schema/contact_enrichment.md
```

## Rollback Procedures

### Immediate Rollback
```
/migrate 234 --rollback
```

### Rollback Strategy
1. **Pre-Rollback Checks**
   - Verify no dependent migrations
   - Check for data in new tables
   - Ensure rollback script exists

2. **Rollback Execution**
   - Run DOWN migration
   - Verify schema restored
   - Update migration history
   - Notify team

3. **Post-Rollback**
   - Update issue status
   - Document rollback reason
   - Plan fixes for retry

## Safety Features

### Automatic Safeguards
- Migrations wrapped in transactions
- Automatic backup before execution
- Lock timeout settings
- Connection pool management
- Health checks after migration

### Migration Rules
```yaml
migration_safety:
  require_review: 
    - DROP TABLE
    - DROP COLUMN  
    - ALTER TYPE
  require_backup:
    - all
  max_lock_duration: "5s"
  max_rows_affected: 1000000
  require_test_run: true
```

## Complex Migration Example

```sql
-- Multi-step migration with zero downtime

-- Step 1: Add new column (no default)
ALTER TABLE users ADD COLUMN email_verified BOOLEAN;

-- Step 2: Backfill in batches (background job)
UPDATE users SET email_verified = true 
WHERE id IN (SELECT id FROM users WHERE email_verified IS NULL LIMIT 1000);

-- Step 3: Add NOT NULL constraint after backfill
ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
ALTER TABLE users ALTER COLUMN email_verified SET DEFAULT false;
```

## Migration History

```
/migrate history
```

Output:
```
📜 Migration History

VERSION          | NAME                  | ISSUE | STATUS  | APPLIED AT
-----------------|----------------------|-------|---------|------------------
20240115143022   | contact_enrichment   | #234  | SUCCESS | 2024-01-15 14:35
20240112091533   | add_user_preferences | #212  | SUCCESS | 2024-01-12 09:20
20240110162244   | optimize_indexes     | #198  | ROLLED  | 2024-01-10 16:45
20240108113021   | payment_tables       | #187  | SUCCESS | 2024-01-08 11:35

Total: 4 migrations (3 active, 1 rolled back)
```

## Integration Points
- Triggered by `/implement` for data model changes
- Updates GitHub issues with migration status
- Links to `/test` for migration testing
- Documented by `/document` command
- Included in `/release` notes

## Best Practices

1. **Always preview first**: `/migrate {issue} --preview`
2. **Test on staging**: Run migration on staging database
3. **Schedule wisely**: Run during low-traffic periods
4. **Monitor closely**: Watch database metrics during migration
5. **Have rollback ready**: Test rollback procedure
6. **Document changes**: Update schema documentation