# ============================================================================
# DBT CHEAT SHEET - Quick Reference Card
# ============================================================================
# Print this or bookmark for quick lookup while working with dbt
# ============================================================================

## INSTALLATION & SETUP

```bash
# Install dbt
pip install dbt-core dbt-duckdb

# Initialize new project
dbt init my_project
cd my_project

# Test connection
dbt debug
```

## CORE CONCEPTS AT A GLANCE

| Concept | What | Where | File Extension |
|---------|------|-------|-----------------|
| **Model** | SQL transformation | `models/` | `.sql` |
| **Source** | Raw external data | `_sources.yml` | `.yml` |
| **Ref** | Reference to model | In SQL | `{{ ref() }}` |
| **Macro** | Reusable function | `macros/` | `.sql` |
| **Test** | Data quality check | `tests/` or YAML | `.sql` / `.yml` |
| **Seed** | Static CSV data | `seeds/` | `.csv` |

## MATERIALIZATION TYPES

```
VIEW        - Virtual table (temporary, lightweight)
TABLE       - Physical table (persisted, fast queries)
INCREMENTAL - Only new/changed rows (efficient)
EPHEMERAL   - Temporary compile-time logic
```

## MODEL STRUCTURE TEMPLATE

```sql
{{
  config(
    materialized = 'view',
    tags = ['staging']
  )
}}

-- CTE 1: Raw data
with source_data as (
  select * from {{ source('raw_data', 'table_name') }}
),

-- CTE 2: Cleaned data
cleaned_data as (
  select
    column1,
    upper(column2) as column2,
    cast(column3 as date) as column3
  from source_data
)

-- Final select
select * from cleaned_data
```

## YAML TEST TEMPLATE

```yaml
version: 2

sources:
  - name: raw_data
    tables:
      - name: customers
        columns:
          - name: customer_id
            tests:
              - unique
              - not_null
          - name: email
            tests:
              - unique
              - relationships:
                  to: ref('stg_customers')
                  field: email
```

## COMMON COMMANDS

```bash
# Connection & Validation
dbt debug                    # Test DB connection
dbt parse                    # Check syntax
dbt compile                  # Compile without executing

# Execution
dbt seed                     # Load CSV seeds
dbt run                      # Execute models
dbt test                     # Run quality tests
dbt build                    # seed + run + test (full pipeline)

# Documentation
dbt docs generate            # Create docs
dbt docs serve               # View in browser
dbt list                     # Show all models

# Selection Filters (add to run/test/compile)
dbt run -s stg_customers     # Run one model
dbt run -s +fct_orders       # Run with parents
dbt run -s fct_orders+       # Run with children
dbt run -s +fct_orders+      # Run with all deps
dbt run -s tag:staging       # By tag
dbt run -s path:models/marts # By path
```

## QUICK REFERENCES

### ref() - Reference Another Model
```sql
select * from {{ ref('stg_customers') }}
-- Tells dbt: stg_customers is a dependency
-- Creates automatic execution order
```

### source() - Reference Raw Data
```sql
select * from {{ source('raw_data', 'customers') }}
-- raw_data = source name in _sources.yml
-- customers = table name
```

### Config Block Options
```sql
{{ config(
  materialized = 'table',      -- or: view, incremental, ephemeral
  alias = 'fact_orders',        -- custom table name
  tags = ['mart', 'core'],      -- for selection filtering
  unique_key = 'order_id',      -- for incremental models
  depends_on = [],              -- explicit dependencies
  pre_hook = "...",             -- run before model
  post_hook = "..."             -- run after model
) }}
```

### Built-in Generic Tests
```yaml
- unique                  # No duplicates
- not_null               # No NULL values
- accepted_values:       # Only these values
    values: ['a', 'b']
- relationships:         # Foreign key
    to: ref('other_model')
    field: other_id
```

### Date Functions
```sql
current_date              -- Today
current_timestamp         -- Now with time
cast('2024-01-15' as date) -- String to date
date_trunc('month', date_col) -- Start of month
datediff(day, date1, date2)  -- Days between
extract(year from date_col)  -- Extract part
```

### String Functions
```sql
upper(col)               -- UPPERCASE
lower(col)               -- lowercase
trim(col)                -- Remove spaces
concat(col1, col2)       -- Combine
split_part(col, ',', 1)  -- Split string
like 'pattern%'          -- Pattern matching
```

### Aggregation Functions
```sql
count(*)                 -- Row count
sum(col)                 -- Total
avg(col)                 -- Average
min(col) / max(col)      -- Min/max
count(distinct col)      -- Unique count
```

### Window Functions
```sql
row_number() over (partition by col order by date) -- Rank
rank() over (...)    -- With gaps
dense_rank() over (...) -- Without gaps
lag(col) over (...)  -- Previous row value
lead(col) over (...) -- Next row value
sum(col) over (...)  -- Running total
```

## FILE LOCATIONS QUICK MAP

```
dbt_project.yml          -- Configuration (name, materializations)
profiles.yml             -- Database credentials
models/                  -- SQL transformation files
  staging/               -- Clean raw data (VIEWs)
  marts/                 -- Business tables (TABLEs)
macros/                  -- Reusable functions
tests/                   -- Custom quality tests
seeds/                   -- CSV files to load
data/                    -- Raw source data
target/                  -- Generated files (compiled SQL, metadata)
  compiled/              -- Generated SQL ready for database
  manifest.json          -- Project lineage & metadata
```

## TROUBLESHOOTING QUICK FIX

| Problem | Solution |
|---------|----------|
| "Connection refused" | Check `profiles.yml` credentials |
| "Table/view does not exist" | Check `{{ source() }}` or `{{ ref() }}` names |
| "Column X not found" | Check upstream model has the column |
| "test failed" | Review test logic or check data |
| "Circular dependency" | Check for circular `ref()` calls |
| "Doesn't run in database" | Run `dbt compile` to see generated SQL |
| "Takes too long" | Use `dbt run -s tag:mart` to run selective |

## ENVIRONMENT SETUP

```bash
# Create virtual environment
python -m venv dbt_env

# Activate (Windows)
dbt_env\Scripts\activate

# Activate (Mac/Linux)
source dbt_env/bin/activate

# Install dbt
pip install dbt-core dbt-duckdb
# Or: pip install dbt-core dbt-postgres
# Or: pip install dbt-core dbt-snowflake

# Check version
dbt --version
```

## PROFILE SETUP QUICK START

Edit `~/.dbt/profiles.yml`:

```yaml
my_dbt_project:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ':memory:'        # In-memory database (great for learning)
      # or
      # type: postgres
      # host: localhost
      # user: analytics
      # pass: password
      # port: 5432
      # dbname: analytics_db
      # schema: dbt_dev
      # threads: 4
```

## NAMING CONVENTIONS

```
stg_*    -- Staging models (cleaned raw data, VIEWs)
dim_*    -- Dimension tables (attributes, TABLEs)
fct_*    -- Fact tables (events/metrics, TABLEs)
tmp_*    -- Temporary working models
rpt_*    -- Reports/outputs
```

## GIT VERSION CONTROL

```bash
# Initialize
git init

# Add all files
git add .

# Commit
git commit -m "Initial dbt project"

# Ignore compiled files
echo "target/" > .gitignore
echo "dbt_packages/" >> .gitignore

# Push
git push origin main
```

## CI/CD (GitHub Actions Quick Example)

```yaml
# .github/workflows/dbt.yml
name: dbt

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      
      - run: pip install dbt-core dbt-postgres
      
      - run: dbt parse
      
      - run: dbt build
```

## COMMON PATTERNS

### Deduplication
```sql
select * from (
  select *,
    row_number() over (partition by id order by updated_at desc) as rn
  from raw_table
)
where rn = 1
```

### Type Conversion
```sql
cast(amount as numeric(10,2))
cast(date_string as date)
cast(flag as integer)
```

### Null Handling
```sql
coalesce(nullable_col, 'DEFAULT')
nullif(col, 'value_to_null')
case when col is null then 'N/A' else col end
```

### Categorization
```sql
case
  when amount > 500 then 'High'
  when amount > 100 then 'Medium'
  else 'Low'
end as amount_tier
```

## PERFORMANCE TIPS

1. **Use VIEWs for staging** (lightweight)
2. **Use TABLEs for marts** (fast queries)
3. **Use INCREMENTAL for large tables** (only new data)
4. **Increase threads** for parallel execution
5. **Write selective tests** (not everything needs all tests)
6. **Use appropriate types** (not all columns need strings)

## KEY RESOURCES

- **Official Docs:** https://docs.getdbt.com/
- **Community Forum:** https://community.getdbt.com/
- **Learning Hub:** https://learn.getdbt.com/
- **dbt Hub (Packages):** https://hub.getdbt.com/

## DAILY WORKFLOW

```bash
# Morning: Run full pipeline
dbt build

# During day: Run specific models
dbt run -s -s tag:core
dbt test -s tag:core

# Afternoon: Check for issues
dbt docs serve
# Browse to see lineage and issues

# Evening: Commit changes
git add .
git commit -m "Updated transformations"
```

---

**Print this card and keep it handy while learning dbt!** 🚀

Version: 1.0 | Created: 2024 | For dbt 1.5+
