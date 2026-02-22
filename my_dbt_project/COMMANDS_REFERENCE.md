# ============================================================================
# DBT QUICK START GUIDE & COMMAND REFERENCE
# ============================================================================

## 🚀 QUICK START (5 Minutes)

### 1. Install dbt
```bash
pip install dbt-core dbt-duckdb
```

### 2. Navigate to project
```bash
cd my_dbt_project
```

### 3. Check database connection
```bash
dbt debug
# Should show: ✓ Connection successful
```

### 4. Run everything
```bash
dbt build
# This runs: seed → run → test
```

### 5. View results
```bash
dbt docs serve
# Opens browser to documentation
```

---

## 📋 COMPLETE COMMAND REFERENCE

### CONNECTION & SETUP

| Command | Purpose | Example |
|---------|---------|---------|
| `dbt debug` | Test connection to database | `dbt debug` |
| `dbt init` | Initialize new dbt project | `dbt init my_project` |
| `dbt parse` | Validate YAML and SQL syntax | `dbt parse` |

### EXECUTION COMMANDS

| Command | Purpose | Example |
|---------|---------|---------|
| `dbt run` | Execute models | `dbt run` |
| `dbt seed` | Load CSV seed files | `dbt seed` |
| `dbt snapshot` | Create point-in-time snapshot | `dbt snapshot` |
| `dbt test` | Run data quality tests | `dbt test` |
| `dbt build` | Seed + run + test | `dbt build` |
| `dbt compile` | Compile SQL without executing | `dbt compile` |
| `dbt freshness` | Check source data freshness | `dbt freshness` |

### SELECTION & FILTERING

These flags work with `run`, `test`, `compile`:

```bash
# Run all models
dbt run

# Run specific model
dbt run --select stg_customers
# or shorthand:
dbt run -s stg_customers

# Run model and parents (upstream dependencies)
dbt run -s +stg_customers

# Run model and children (downstream dependencies)
dbt run -s stg_customers+

# Run model and all dependencies (both directions)
dbt run -s +stg_customers+

# Run by tag
dbt run -s tag:staging
dbt run -s tag:mart

# Run by path
dbt run -s path:models/staging

# Run by package
dbt run -s package:dbt_utils

# Exclude models
dbt run -s tag:staging --exclude tag:deprecated

# Combine selections (OR logic)
dbt run -s tag:staging,tag:mart

# Intersect selections (AND logic)
dbt run -s tag:staging,tag:core
```

### DOCUMENTATION

| Command | Purpose | Example |
|---------|---------|---------|
| `dbt docs generate` | Generate documentation site | `dbt docs generate` |
| `dbt docs serve` | Serve documentation in browser | `dbt docs serve` |
| `dbt list` | List all models | `dbt list` |
| `dbt list -s tag:staging` | List models by tag | `dbt list -s tag:staging` |

### TESTING COMMANDS

```bash
# Run all tests
dbt test

# Test specific model
dbt test -s stg_customers

# Test with detailed output
dbt test --debug

# Fail on first error
dbt test --fail-fast

# Run only generic tests (not singular)
dbt test --select test_type:generic

# Run only singular tests
dbt test --select test_type:singular

# Store test failures in database
dbt test --store-failures
```

### CLEANUP COMMANDS

```bash
# Remove compiled artifacts
dbt clean

# Run operation to drop objects
dbt run-operation drop_old_models

# Drop all tables and views (careful!)
dbt run-operation drop_all_tables
```

### ADVANCED COMMANDS

| Command | Purpose |
|---------|---------|
| `dbt retry` | Retry last failed run |
| `dbt show` | Preview model output (v1.4+) |
| `dbt run-operation` | Execute a macro |
| `dbt expose` | Expose model to downstream systems |

---

## 🎯 COMMON WORKFLOWS

### Workflow 1: Daily Data Pipeline

```bash
# Each morning, run:
dbt build

# That's it! Runs everything:
# 1. dbt seed (load any CSV files)
# 2. dbt run (transform data)
# 3. dbt test (validate quality)
```

### Workflow 2: Development & Testing

```bash
# Work on staging models
# Edit: models/staging/stg_orders.sql

# Test your changes
dbt run -s stg_orders
dbt test -s stg_orders

# Check syntax
dbt compile -s stg_orders

# View the generated SQL
cat target/compiled/my_project/models/staging/stg_orders.sql
```

### Workflow 3: Add New Model

```bash
# 1. Create new SQL file
echo "select * from raw_data" > models/marts/my_new_model.sql

# 2. Parse to check syntax
dbt parse

# 3. Run the new model
dbt run -s my_new_model

# 4. Test it
dbt test -s my_new_model

# 5. Document it (add to YAML)
# Edit: models/_models.yml

# 6. Regenerate docs
dbt docs generate
```

### Workflow 4: Debugging a Failed Model

```bash
# See what failed
dbt run --debug

# Run just the failing model
dbt run -s model_name --debug

# View compiled SQL
cat target/compiled/my_project/models/.../model_name.sql

# Check for issues:
# - SQL syntax errors
# - Wrong column names
# - Missing source tables
# - Type mismatches

# Fix the model

# Test again
dbt run -s model_name
```

### Workflow 5: Running on Schedule (Airflow/Cron)

```bash
# In cron (daily at 2 AM):
0 2 * * * cd /path/to/project && dbt build

# Or in Airflow DAG:
from airflow.operators.bash_operator import BashOperator

run_dbt = BashOperator(
    task_id='dbt_run',
    bash_command='cd /path/to/project && dbt build',
)
```

---

## 📊 EXAMPLE: WORKING WITH MODELS

### Run a Single Model

```bash
$ dbt run -s stg_customers

Running with dbt version 1.5.0
Found 1 model, 0 tests...
Executing create view model stg_customers...
✓ Success
```

**What it does:**
1. Finds all parent models that stg_customers depends on
2. Checks if parents were already built
3. Creates the view
4. Tracks lineage for next run

### Run with Dependencies

```bash
$ dbt run -s +fct_orders

Running with dbt version 1.5.0
Found 3 models...

Executing create view model stg_customers...
✓ Success
Executing create view model stg_orders...
✓ Success
Executing create table model fct_orders...
✓ Success

Built 3 models in 2.45 seconds.
```

**What it does:**
1. fct_orders depends on stg_customers and stg_orders
2. Builds parents first (stg_* models)
3. Then builds the main model (fct_orders)
4. Maintains dependency order

### Run and Test

```bash
$ dbt test -s stg_customers

Running with dbt version 1.5.0
Found 5 tests...

Executing test not_null_stg_customers_customer_id...
✓ PASS - 8 records (execution in 0.45s)
Executing test unique_stg_customers_customer_id...
✓ PASS - 8 records (execution in 0.34s)
Executing test relationships_stg_customers_email...
✓ PASS - 8 records (execution in 0.28s)

Built 3 tests passing
```

**What it does:**
1. Queries the transformed data
2. Looks for violations of test rules
3. Returns results

---

## 🔍 INSPECTING YOUR PROJECT

### List All Models

```bash
$ dbt list

my_dbt_project://models/staging/stg_customers.sql
my_dbt_project://models/staging/stg_orders.sql
my_dbt_project://models/marts/dim_customers.sql
my_dbt_project://models/marts/fct_orders.sql
```

### List by Tag

```bash
$ dbt list -s tag:mart

my_dbt_project://models/marts/dim_customers.sql
my_dbt_project://models/marts/fct_orders.sql
```

### Preview Model Output

```bash
$ dbt show -s stg_customers limit 5

customer_id | customer_name | email
1           | John Smith    | john.smith@email.com
2           | Sarah Johnson | sarah.j@email.com
3           | Michael Brown | m.brown@email.com
4           | Emily Davis   | emily.davis@email.com
5           | David Wilson  | d.wilson@email.com
```

---

## 📝 VIEWING GENERATED SQL

All compiled SQL goes to `target/compiled/`:

```bash
# See what dbt actually runs in the database
ls target/compiled/my_dbt_project/models/staging/

# View compiled SQL
cat target/compiled/my_dbt_project/models/staging/stg_customers.sql

# Output example:
-- Original model (stg_customers.sql):
with raw as (
  select * from {{ source('raw_data', 'customers') }}
)
select * from raw

-- Compiled to:
with raw as (
  select * from raw_data.customers
)
select * from raw
```

---

## 🧪 TESTING IN DETAIL

### All Available Test Types

```yaml
# Generic Tests (built-in, declarative)
tests:
  - not_null           # No NULLs
  - unique             # No duplicates
  - accepted_values    # Whitelist
  - relationships      # Foreign key

# Singular Tests (custom SQL)
# File: tests/my_test.sql
# Query returns rows = test fails
```

### Test Execution Order

```bash
$ dbt test --debug

Building 5 tests...
Running test: not_null_customer_id
Running test: unique_customer_id
Running test: relationships_customer_id
Running test: dbt_expectations_customer_email_format
Running test: custom_positive_amounts

Results:
✓ 5 tests passed
```

### Storing Test Failures

```bash
dbt test --store-failures

# Creates table: dbt_test_failures.not_null_customer_id
# Contains rows that failed the test
# Useful for investigation
```

---

## 🚨 TROUBLESHOOTING COMMANDS

### Debug Mode

```bash
# Verbose output showing every step
dbt run --debug

# Shows:
# - Connection details
# - SQL being executed
# - Timing info
# - Errors with full stack trace
```

### Parse Only (No Execution)

```bash
# Check syntax without running in database
dbt parse

# Finds:
# - YAML errors
# - SQL syntax issues
# - Missing references
# - Circular dependencies
```

### Check Freshness

```bash
# Validate source data freshness
dbt freshness

# Report:
# - When sources were last updated
# - If data is stale
# - Warnings based on max_age settings
```

### Run with Profile

```bash
# Use specific profile (dev/prod/staging)
dbt run --profiles-dir ~/.dbt --target prod

# Helpful when managing multiple environments
```

---

## 🔄 CI/CD INTEGRATION

### GitHub Actions Example

```yaml
# .github/workflows/dbt.yml
name: dbt-test

on: [push, pull_request]

jobs:
  dbt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      
      - name: Install dbt
        run: pip install dbt-core dbt-postgres
      
      - name: dbt parse
        run: dbt parse
      
      - name: dbt build
        run: dbt build

      - name: dbt test
        run: dbt test
```

---

## 📚 USEFUL RESOURCES

### Within dbt

```bash
# View all available commands
dbt --help

# Help for specific command
dbt run --help

# View project documentation
dbt docs serve
```

### External

- **Docs:** https://docs.getdbt.com/
- **Community:** https://community.getdbt.com/
- **dbt Learn:** https://learn.getdbt.com/

---

## 💰 PERFORMANCE OPTIMIZATION

### Run Specific Models Only

```bash
# Don't rebuild everything, just what changed
dbt run -s state:modified

# Requires: dbt docs generate --store-metadata
```

### Use Incremental Models

```sql
{{ config(
    materialized='incremental',
    unique_key='id'
) }}

select * from raw_data

{% if is_incremental() %}
  where created_at > (select max(created_at) from {{ this }})
{% endif %}
```

### Parallelize Runs

```bash
# Build 4 models at once
dbt run --threads 4

# Check your database limits first!
```

---

## 🎓 PRACTICE EXERCISES

### Exercise 1: Run a model
```bash
cd my_dbt_project
dbt run -s stg_customers
# Check: Did table/view get created?
```

### Exercise 2: Run tests
```bash
dbt test
# Check: How many pass/fail?
```

### Exercise 3: Add a new column
```
1. Edit: models/staging/stg_customers.sql
2. Add: upper(country) as country_upper
3. Run: dbt run -s stg_customers
4. Verify with: dbt show -s stg_customers
```

### Exercise 4: Document a model
```
1. Edit: models/_sources.yml
2. Add description field to stg_customers
3. Run: dbt docs generate
4. View: dbt docs serve
```

### Exercise 5: Write a test
```
1. Edit: models/_sources.yml
2. Add test: not_null to customer_id
3. Run: dbt test -s stg_customers
4. Check: Task passes
```

---

## ⚡ SPEED TIPS

1. **Use `dbt compile`** before `dbt run` to catch errors early
2. **Run selective** using `-s` flag instead of everything
3. **Increase threads** for parallel execution
4. **Use views** for staging (faster than tables)
5. **Use tables** for marts (faster to query)
6. **Incremental** models for large datasets
7. **Test in dev** before prod

---

## 🎯 Next Steps

1. ✅ Run `dbt build`
2. ✅ Run `dbt docs serve`
3. ✅ Explore the documentation
4. ✅ Modify a model and see changes
5. ✅ Create a new model
6. ✅ Write a test
7. ✅ Version control your changes

You're ready to transform data! 🚀
