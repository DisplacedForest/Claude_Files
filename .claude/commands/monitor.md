# Monitor Command

## Usage
`/monitor {metric} [--period {time}] [--alert]`

## Description
Performance monitoring and alerting system that tracks application health, identifies bottlenecks, and provides actionable insights.

## Metrics Available

### Application Metrics
- `api` - API response times and error rates
- `database` - Query performance and connection pools
- `cache` - Cache hit rates and memory usage
- `queue` - Job processing times and backlog
- `memory` - Application memory usage
- `cpu` - CPU utilization by service

### Business Metrics  
- `users` - Active users and growth
- `features` - Feature adoption rates
- `errors` - Error rates by category
- `performance` - Core workflow performance

## Process Flow

1. **Metric Collection**
   - Connect to monitoring systems
   - Aggregate time-series data
   - Calculate percentiles
   - Identify anomalies

2. **Analysis**
   - Compare to baselines
   - Detect trends
   - Correlate with deployments
   - Identify root causes

3. **Reporting**
   - Generate visualizations
   - Create actionable insights
   - Suggest optimizations
   - Update dashboards

4. **Alerting**
   - Check against thresholds
   - Send notifications
   - Create issues for problems
   - Track resolution

## Example Reports

### API Performance Report
```
/monitor api --period 24h
```

Output:
```
📊 API Performance Report (Last 24 Hours)

## Response Times
Endpoint               | P50   | P95   | P99   | Requests | Errors
----------------------|-------|-------|-------|----------|--------
GET /api/contacts     | 45ms  | 120ms | 250ms | 12,450   | 0.1%
POST /api/contacts    | 89ms  | 234ms | 567ms | 3,234    | 0.5%
GET /api/enrichment   | 342ms | 890ms | 2.1s  | 5,678    | 2.3%
POST /api/bulk        | 1.2s  | 3.4s  | 8.9s  | 234      | 5.1%

## Error Analysis
- 500 Internal Error: 23 (0.2%)
  - Majority from enrichment timeout
- 429 Rate Limited: 45 (0.4%)  
  - Spike at 14:30 UTC
- 400 Bad Request: 67 (0.6%)
  - Validation errors on bulk endpoint

## Performance Trends
📈 Improving: /api/contacts (15% faster than yesterday)
📉 Degrading: /api/enrichment (25% slower, investigate)
⚠️  Alert: /api/bulk P99 exceeds 5s threshold

## Recommendations
1. Investigate enrichment service slowdown
2. Add caching for frequently accessed contacts
3. Optimize bulk processing with batching
4. Review rate limits for peak hours
```

### Database Performance
```
/monitor database --period 1h
```

Output:
```
🗄️ Database Performance Report (Last Hour)

## Query Performance
Query Pattern                      | Avg    | Count | Total Time
----------------------------------|--------|-------|------------
SELECT * FROM contacts WHERE...   | 12ms   | 5,234 | 62.8s
INSERT INTO enrichment_queue...   | 5ms    | 1,234 | 6.2s  
UPDATE contacts SET enriched...   | 45ms   | 892   | 40.1s
Complex JOIN on 5 tables...       | 234ms  | 123   | 28.8s

## Slow Queries (>100ms)
1. SELECT contacts.*, enrichment.* FROM contacts 
   LEFT JOIN enrichment ON... (Avg: 234ms)
   💡 Missing index on enrichment.contact_id

2. UPDATE contacts SET data = jsonb_set(...) 
   WHERE id IN (...1000 ids...) (Avg: 567ms)
   💡 Consider batching updates

## Connection Pool
- Active: 34/100 connections
- Idle: 66 connections
- Wait Time: 0ms (healthy)
- Timeouts: 0

## Recommendations
1. Add index: CREATE INDEX idx_enrichment_contact_id
2. Batch large UPDATE operations  
3. Review complex JOIN query for optimization
4. Current connection pool is healthy
```

### Memory Usage Analysis
```
/monitor memory --alert
```

Output:
```
💾 Memory Usage Analysis

## Current Status: ⚠️ WARNING
- Heap Used: 1.8GB / 2GB (90%)
- RSS: 2.3GB
- External: 145MB

## Memory by Component
Service         | Memory | Growth | Status
----------------|--------|--------|--------
EnrichmentQueue | 890MB  | +45MB/h| ⚠️
ContactCache    | 456MB  | Stable | ✅
APIServer       | 234MB  | +5MB/h | ✅
ImageProcessor  | 220MB  | Stable | ✅

## Memory Leaks Detected
⚠️ EnrichmentQueue showing linear growth
- Possible cause: Uncleared event listeners
- Location: src/queue/enrichment.ts:145

## Garbage Collection
- Minor GC: 234 times (345ms total)
- Major GC: 5 times (123ms total)
- GC Overhead: 2.3% (acceptable)

## Alert Created
🚨 GitHub Issue #567 created: Memory leak in EnrichmentQueue
Assigned to: On-call engineer
Priority: High

## Immediate Actions
1. Restart enrichment service
2. Enable heap profiling
3. Review recent changes to queue
4. Consider memory limit increase
```

### Feature Adoption Tracking
```
/monitor features --period 7d
```

Output:
```
✨ Feature Adoption Report (Last 7 Days)

## Feature Usage
Feature              | Users | Usage | Growth | Health
--------------------|-------|-------|---------|--------
Contact Enrichment  | 1,234 | 45%   | +12%    | 🟢
Bulk Import         | 567   | 20%   | +34%    | 🟢
Advanced Search     | 2,345 | 85%   | +5%     | 🟢
Email Templates     | 234   | 8%    | -2%     | 🟡
API Integration     | 89    | 3%    | +67%    | 🟢

## Enrichment Feature Deep Dive
- Total Enrichments: 45,678
- Success Rate: 92.3%
- Avg Fields Added: 6.7
- User Satisfaction: 4.2/5

## Usage Patterns
📅 Peak Usage: Weekdays 9-11 AM
📉 Low Usage: Weekends
🌍 Top Markets: US (45%), UK (23%), DE (12%)

## Recommendations
1. Email Templates showing low adoption
   - Consider user education campaign
2. API Integration growing rapidly  
   - Prepare for scale
3. Enrichment hitting capacity
   - Plan infrastructure upgrade
```

## Dashboard Generation

### Real-time Dashboard Config
```yaml
# monitor-dashboard.yml
# Generated by /monitor command

dashboards:
  api_health:
    refresh: 30s
    panels:
      - title: "Request Rate"
        metric: "api.requests.rate"
        visualization: "line"
      - title: "Error Rate"
        metric: "api.errors.rate"
        visualization: "line"
        alert: "> 1%"
      - title: "Response Time"
        metric: "api.response.p95"
        visualization: "gauge"
        alert: "> 500ms"
      - title: "Active Users"
        metric: "users.active.count"
        visualization: "stat"

  database_health:
    refresh: 60s
    panels:
      - title: "Query Time"
        metric: "db.query.duration"
        visualization: "heatmap"
      - title: "Connections"
        metric: "db.connections.active"
        visualization: "gauge"
        max: 100
      - title: "Slow Queries"
        metric: "db.slow_queries"
        visualization: "table"
```

## Alert Configuration

```yaml
# alerts.yml
# Generated by /monitor command

alerts:
  - name: "API Response Time"
    metric: "api.response.p95"
    condition: "> 1000ms"
    duration: "5m"
    severity: "warning"
    notify: ["slack", "email"]
    
  - name: "Error Rate Spike"
    metric: "api.errors.rate"
    condition: "> 5%"
    duration: "2m"
    severity: "critical"
    notify: ["pagerduty", "slack"]
    create_issue: true
    
  - name: "Memory Usage"
    metric: "app.memory.heap"
    condition: "> 90%"
    duration: "10m"
    severity: "warning"
    action: "restart_service"
```

## Options
- `--period {time}` - Time range (1h, 24h, 7d, 30d)
- `--alert` - Set up alerting for metric
- `--export` - Export data as CSV/JSON
- `--compare {period}` - Compare to previous period
- `--dashboard` - Generate dashboard config

## Integration Points
- Reads from Prometheus/DataDog/CloudWatch
- Creates GitHub issues for problems
- Updates Slack with critical alerts
- Links to `/fix` for issue resolution
- Correlates with `/release` deployments

## Automation

### Scheduled Reports
```bash
# Daily performance report
0 9 * * * /monitor api --period 24h --export

# Weekly feature adoption
0 9 * * 1 /monitor features --period 7d

# Hourly health check
0 * * * * /monitor health --alert
```

### Continuous Monitoring
```yaml
# GitHub Action for monitoring
name: Performance Monitoring
on:
  schedule:
    - cron: '*/15 * * * *'

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - name: Check API Performance
        run: |
          claude-code monitor api --period 1h
          if [ $? -ne 0 ]; then
            claude-code add-bug "API performance degradation detected"
          fi
```