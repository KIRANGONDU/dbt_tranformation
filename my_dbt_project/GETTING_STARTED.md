# 🎓 DBT COMPLETE LEARNING PROJECT - GETTING STARTED
# ============================================================================

## 📚 WHAT YOU NOW HAVE

A **fully-featured, production-ready dbt learning project** with:

✅ **4 Sample Transformation Models**
- 2 Staging models (clean raw data)
- 2 Mart models (business-ready tables)

✅ **Complete Documentation** (6 detailed guides)
- README - Core concepts
- PIPELINE_WORKFLOW - Data transformations illustrated
- WEBHOOK_INTEGRATION - Real-time data loading
- COMMANDS_REFERENCE - All dbt commands
- MASTER_INDEX - Complete file guide
- CHEAT_SHEET - Quick reference

✅ **Ready-to-Use Components**
- Sample CSV source data
- Configuration files
- Test suite
- Macros (reusable functions)

---

## 🚀 QUICK START (Next 5 Minutes)

### Step 1: Install dbt

```bash
# Open terminal in the project directory
cd C:\Users\srinu\OneDrive\Documents\dbt\my_dbt_project

# Install dbt (if not already installed)
pip install dbt-core dbt-duckdb

# Verify installation
dbt --version
```

**Expected output:**
```
Core: 1.x.x
...
```

### Step 2: Test Connection

```bash
dbt debug
```

**Expected output:**
```
dbt version: 1.x.x
...
Connection test: ✓ Connection successful
```

### Step 3: Run the Pipeline

```bash
dbt build
```

**What this does:**
1. **dbt seed** - Loads CSV files from `data/`
2. **dbt run** - Executes SQL models
3. **dbt test** - Validates data quality

**Expected output:**
```
Found 4 models, 0 tests...
Running create view model stg_customers...
✓ stg_customers (view)
Running create view model stg_orders...
✓ stg_orders (view)
Running create table model dim_customers...
✓ dim_customers (table)
Running create table model fct_orders...
✓ fct_orders (table)

Completed successfully
```

### Step 4: View Documentation

```bash
dbt docs generate
dbt docs serve
```

**What happens:**
- Browser opens to documentation website
- Shows all models, columns, tests
- Displays data lineage graph
- Lets you explore relationships

---

## 📂 PROJECT FILES OVERVIEW

### Documentation Files (Read These First)

```
📄 README.md
   └─ Start here! Complete dbt learning guide
   └─ Read time: 30 minutes
   └─ Learn: All core concepts

📄 PIPELINE_WORKFLOW.md
   └─ See actual data transformations
   └─ Read time: 20 minutes
   └─ Learn: How data flows through pipeline

📄 WEBHOOK_INTEGRATION.md
   └─ Load real-time data from APIs
   └─ Read time: 25 minutes
   └─ Learn: Flask webhook server, incremental models

📄 COMMANDS_REFERENCE.md
   └─ All dbt commands with examples
   └─ Read time: 20 minutes
   └─ Learn: How to run and operate dbt

📄 MASTER_INDEX.md
   └─ Complete file index
   └─ Read time: 15 minutes
   └─ Learn: Where to find everything

📄 CHEAT_SHEET.md
   └─ Quick reference card
   └─ Read time: 5 minutes
   └─ Learn: Common patterns and commands
```

### Configuration Files (Edit These)

```
📄 dbt_project.yml
   └─ Main project configuration
   └─ Edit to: Change materializations, add hooks

📄 profiles.yml
   └─ Database connection setup
   └─ Edit to: Connect to Postgres, Snowflake, etc.
```

### Model Files (SQL Transformations)

```
📄 models/staging/stg_customers.sql
   └─ Clean customer data from CSV
   └─ Demonstrations: Deduplication, type casting, CTE usage

📄 models/staging/stg_orders.sql
   └─ Validate order data from CSV
   └─ Demonstrations: Validation, flags, standardization

📄 models/marts/dim_customers.sql
   └─ Customer dimension table (business-ready)
   └─ Demonstrations: Categorization, aggregation, joins

📄 models/marts/fct_orders.sql
   └─ Order fact table (denormalized for reporting)
   └─ Demonstrations: Complex joins, window functions, metrics

📄 models/_sources.yml
   └─ Define raw data sources and add tests
   └─ Edit to: Add column documentation, test configurations
```

### Macro Files (Reusable Functions)

```
📄 macros/common_macros.sql
   └─ Reusable SQL functions
   └─ Includes: Custom naming, metrics logging, calculations
```

### Test Files

```
📄 tests/data_quality_checks.sql
   └─ Custom data validation tests
   └─ Checks: Amounts > 0, orphaned records, duplicates
```

### Data Files

```
📄 data/customers_raw.csv
   └─ Sample customer master data (8 records)
   └─ Columns: ID, name, email, signup_date, country

📄 data/orders_raw.csv
   └─ Sample order transaction data (10 records)
   └─ Columns: ID, customer_id, date, amount, status
```

---

## 📖 LEARNING ROADMAP

### Hour 1 - Learn the Basics
1. Read: **README.md** (concepts overview)
2. Run: `dbt debug` → `dbt build`
3. View: `dbt docs serve`
4. Explore: The documentation website

**What you'll understand:**
- What dbt does
- Models, sources, refs, tests
- Project structure

### Hour 2 - See Real Data
1. Read: **PIPELINE_WORKFLOW.md** (actual transformations)
2. Look at: Sample CSV files in `data/`
3. Compare: Input data vs output tables
4. Trace: Data lineage in documentation

**What you'll understand:**
- How data transforms step-by-step
- What each model does
- How to read dbt models

### Hour 3 - Get Hands-On
1. Edit: `models/staging/stg_customers.sql`
2. Add: New column (e.g., `upper(country)`)
3. Run: `dbt run -s stg_customers`
4. Test: `dbt test -s stg_customers`
5. Check: Results in documentation

**What you'll understand:**
- How to modify models
- How to test changes
- How dbt recompiles

### Hour 4 - Add Webhook Data
1. Read: **WEBHOOK_INTEGRATION.md** (webhook setup)
2. Try: Flask webhook receiver code
3. Create: New model from webhook data
4. Test: New data pipeline

**What you'll understand:**
- Real-time data ingestion
- API integration
- Incremental loading

### Hour 5 - Advanced Concepts
1. Read: **COMMANDS_REFERENCE.md** (full command guide)
2. Try: Different selection flags
3. Create: New mart model from scratch
4. Write: Custom tests
5. Use: Macros in models

**What you'll understand:**
- Advanced dbt operations
- Performance optimization
- Best practices

---

## 💡 NEXT STEPS AFTER QUICK START

### 1. Explore the Generated SQL

```bash
# See what SQL dbt generates
cat target/compiled/my_dbt_project/models/staging/stg_customers.sql

# View:
# - How {{ source() }} is replaced
# - How {{ ref() }} is replaced
# - Final SQL sent to database
```

### 2. Modify a Model

Edit `models/staging/stg_customers.sql`:

```sql
-- Add a new column before the final select
,upper(country) as country_upper
```

Then run:
```bash
dbt run -s stg_customers
dbt test -s stg_customers
```

### 3. Create a New Model

Create file `models/marts/agg_orders_by_customer.sql`:

```sql
{{ config(materialized = 'table') }}

select
  customer_id,
  count(*) as total_orders,
  sum(amount) as total_spent,
  avg(amount) as avg_order_value
from {{ ref('fct_orders') }}
group by customer_id
order by total_spent desc
```

Run it:
```bash
dbt run -s agg_orders_by_customer
```

### 4. Add a Test

Edit `models/_sources.yml` and add:

```yaml
- name: agg_orders_by_customer
  columns:
    - name: customer_id
      tests:
        - unique
        - not_null
```

Run tests:
```bash
dbt test -s agg_orders_by_customer
```

### 5. Load Different Data

Replace CSV files with your own:
- Put in `data/` folder
- Update `_sources.yml`
- Run `dbt seed`
- Models will transform your data!

---

## 🔍 KEY FILES TO UNDERSTAND

### Must Read First
1. **README.md** - Concepts and architecture
2. **CHEAT_SHEET.md** - Quick syntax reference

### Then Read Specific to Your Interest
- **PIPELINE_WORKFLOW.md** - See transformations
- **WEBHOOK_INTEGRATION.md** - Real-time data
- **COMMANDS_REFERENCE.md** - How to run dbt
- **MASTER_INDEX.md** - Complete reference

### Then Explore Code
1. **models/_sources.yml** - Source definitions
2. **models/staging/stg_*.sql** - How to clean data
3. **models/marts/fct_*.sql** - Complex joins
4. **models/marts/dim_*.sql** - Dimension tables
5. **macros/common_macros.sql** - Reusable functions

---

## 📊 WHAT EACH MODEL DOES

### Staging Layer (Raw Data Cleaning)

**stg_customers.sql**
```
Input:  Raw CSV with messy data
Output: Cleaned, deduplicated customer table
Does:   - Standardize names (title case)
        - Lowercase emails
        - Parse dates
        - Remove duplicates
```

**stg_orders.sql**
```
Input:  Raw CSV with orders
Output: Valid orders with quality flags
Does:   - Validate amounts > 0
        - Standard status field
        - Parse dates and amounts
        - Add quality flags
```

### Mart Layer (Business-Ready Tables)

**dim_customers.sql**
```
Input:  stg_customers (cleaned data)
Output: Customer dimension for reporting
Does:   - Add region classification
        - Add lifecycle status
        - Calculate days since signup
        - One row per customer
```

**fct_orders.sql**
```
Input:  stg_orders + dim_customers
Output: Denormalized orders for analytics
Does:   - Join customer attributes
        - Calculate order tiers
        - Add customer aggregates
        - Encode status as flag
        - One row per order
```

---

## 🧪 TESTING YOUR SETUP

### Quick Health Check

```bash
# 1. Connection test
dbt debug

# 2. Syntax check
dbt parse

# 3. Compile without running
dbt compile

# 4. Full pipeline
dbt build

# 5. View models created
dbt list

# 6. See documentation
dbt docs serve
```

**All should succeed with no errors!**

---

## 🐛 TROUBLESHOOTING

### "dbt: command not found"
```bash
# Make sure you installed dbt:
pip install dbt-core dbt-duckdb

# Or for other databases:
pip install dbt-core dbt-postgres
pip install dbt-core dbt-snowflake
```

### "Connection refused"
```bash
# Check profiles.yml
# Make sure database credentials are correct
# For DuckDB (no setup needed):
# - path: 'dbt_warehouse.duckdb' (creates local file)

dbt debug  # Should show connection details
```

### "Table not found"
```bash
# Check _sources.yml
# Make sure table names match CSV files
# Run dbt seed first:

dbt seed    # This loads CSV files

# Then run models:
dbt run
```

### "Column not found"
```bash
# Check model SQL
# Make sure all column names exist in upstream models
# View upstream model:

dbt show -s upstream_model_name

# Then check your SQL for typos
```

---

## 💻 EXAMPLE: YOUR FIRST MODIFICATION

**Goal:** Add "customer_status" (New/Active/Mature) to stg_customers

**Step 1:** Open `models/staging/stg_customers.sql`

**Step 2:** Find the SELECT section and add:

```sql
with raw_customers_cte as (
  select
    customer_id,
    customer_name,
    email,
    signup_date,
    country
  from {{ source('raw_data', 'customers') }}
),

cleaned_customers_cte as (
  select
    customer_id,
    trim(customer_name) as customer_name,
    lower(email) as email,
    cast(signup_date as date) as signup_date,
    coalesce(upper(country), 'UNKNOWN') as country,
    md5(cast(customer_id as string) || email) as dbt_hashed_id,
    current_timestamp as loaded_at,
    
    -- NEW: Add customer status
    case
      when datediff(day, cast(signup_date as date), current_date) <= 90 then 'New'
      when datediff(day, cast(signup_date as date), current_date) <= 365 then 'Active'
      else 'Mature'
    end as customer_status
  from raw_customers_cte
)
```

**Step 3:** Save the file

**Step 4:** Test the change:

```bash
dbt run -s stg_customers
dbt test -s stg_customers
dbt show -s stg_customers
```

**Step 5:** View the result:

```bash
dbt docs serve
# Navigate to stg_customers
# See the new customer_status column
```

---

## 🎯 COMMON QUESTIONS ANSWERED

**Q: Can I use my own database?**
A: Yes! Edit `profiles.yml` to connect to PostgreSQL, Snowflake, BigQuery, etc.

**Q: Can I add my own data?**
A: Yes! Replace CSV files in `data/` folder, update `_sources.yml`

**Q: How do I deploy to production?**
A: Create prod profile in `profiles.yml`, run `dbt run --target prod`

**Q: How do I automate daily runs?**
A: Use cron, Airflow, dbt Cloud, or any scheduler

**Q: How do I add more models?**
A: Create new `.sql` file in `models/`, follow the template

**Q: How do I test my changes?**
A: Run `dbt test -s model_name` after making edits

---

## 📚 ADDITIONAL RESOURCES

### Official Documentation
- **dbt Docs:** https://docs.getdbt.com/
- **dbt Learn:** https://learn.getdbt.com/

### Community
- **dbt Community:** https://community.getdbt.com/
- **dbt Slack:** https://www.getdbt.com/community/join-us-on-slack/

### Packages
- **dbt Hub:** https://hub.getdbt.com/
- Explore pre-built dbt packages

---

## ✅ COMPLETION CHECKLIST

- [ ] Install dbt
- [ ] Run `dbt debug` (connection test)
- [ ] Run `dbt build` (full pipeline)
- [ ] Run `dbt docs serve` (view docs)
- [ ] Read README.md
- [ ] Read PIPELINE_WORKFLOW.md
- [ ] Read CHEAT_SHEET.md
- [ ] Modify a model (add a column)
- [ ] Create a new model
- [ ] Write a test
- [ ] Review generated SQL in target/
- [ ] Explore dbt documentation
- [ ] Try webhook example (optional)

---

## 🎉 YOU'RE READY!

You now have:
✅ A complete dbt learning project
✅ Sample data and transformations
✅ Comprehensive documentation
✅ Working examples
✅ Test suite
✅ Commands and best practices

### Start with:
```bash
cd my_dbt_project
dbt build
dbt docs serve
```

Then explore and modify to learn!

---

**Happy learning with dbt!** 🚀

Need help? Check MASTER_INDEX.md for where to find specific topics.
