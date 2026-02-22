# ============================================================================
# DBT PROJECT MASTER INDEX & QUICK REFERENCE
# ============================================================================
# A complete guide to all files in this dbt learning project
# ============================================================================

## 📂 COMPLETE PROJECT STRUCTURE

```
my_dbt_project/
│
├── 📄 dbt_project.yml
│   └─ Main configuration file (project name, materializations, hooks)
│
├── 📄 profiles.yml
│   └─ Database connection configurations
│
├── 📄 README.md
│   └─ Complete dbt learning guide with concepts and examples
│
├── 📄 PIPELINE_WORKFLOW.md
│   └─ Step-by-step walkthrough of data transformation pipeline
│      showing actual data at each stage
│
├── 📄 WEBHOOK_INTEGRATION.md
│   └─ How to load data from webhooks/APIs into dbt
│      Complete Flask application example
│
├── 📄 COMMANDS_REFERENCE.md
│   └─ Complete dbt command reference and quick start
│
├── 📄 THIS FILE (MASTER_INDEX.md)
│   └─ You are here!
│
├── 📁 models/
│   │  SQL transformation files
│   │
│   ├── 📄 _sources.yml
│   │  └─ Define raw data sources and tests
│   │     Column descriptions, test configurations
│   │
│   ├── 📁 staging/
│   │  └─ First layer: Clean and standardize raw data
│   │
│   │  ├── 📄 stg_customers.sql
│   │  │  └─ Load + clean customer data from CSV
│   │  │     - Removes duplicates
│   │  │     - Standardizes names/emails
│   │  │     - Parses dates
│   │  │     Materialized as: VIEW
│   │  │
│   │  ├── 📄 stg_orders.sql
│   │  │  └─ Load + validate order data from CSV
│   │  │     - Validates amounts > 0
│   │  │     - Standardizes status field
│   │  │     - Adds quality flags
│   │  │     Materialized as: VIEW
│   │
│   ├── 📁 marts/
│   │  └─ Second layer: Business-ready tables for reporting
│   │
│   │  ├── 📄 dim_customers.sql
│   │  │  └─ Customer dimension table
│   │  │     - One row per customer
│   │  │     - Added region and lifecycle status
│   │  │     - Used for customer reports
│   │  │     Materialized as: TABLE
│   │  │
│   │  ├── 📄 fct_orders.sql
│   │  │  └─ Order fact table (denormalized)
│   │  │     - One row per order
│   │  │     - Joined with customer data
│   │  │     - Pre-calculated aggregates
│   │  │     - Order tier categorization
│   │  │     Materialized as: TABLE
│   │
│   ├── 📁 intermediate/
│   │  └─ (Optional) Complex intermediate transforms
│   │
│
├── 📁 macros/
│   └─ Reusable SQL functions
│   │
│   ├── 📄 common_macros.sql
│   │  ├─ generate_alias_name() - Custom naming
│   │  ├─ insert_metrics() - Post-build logging
│   │  ├─ cents_to_dollars() - Currency conversion
│   │  └─ get_date_boundaries() - Date range logic
│   │
│
├── 📁 tests/
│   └─ Data quality test files
│   │
│   ├── 📄 data_quality_checks.sql
│   │  └─ Singular tests (custom SQL)
│   │     - Check for invalid amounts
│   │     - Check for orphaned records
│   │     - Check for duplicates
│   │     - Check for future dates
│   │     - Validate status values
│   │
│
├── 📁 seeds/
│   └─ Static data files to load
│   │
│   ├── 📄 _seeds.yml
│   │  └─ Seed file documentation
│   │
│
├── 📁 data/
│   └─ Raw source data files
│   │
│   ├── 📄 customers_raw.csv
│   │  └─ Raw customer master data
│   │     8 sample records
│   │     Columns: customer_id, name, email, signup_date, country
│   │
│   ├── 📄 orders_raw.csv
│   │  └─ Raw order transaction data
│   │     10 sample records
│   │     Columns: order_id, customer_id, date, amount, status
│   │
│
├── 📁 target/ (auto-generated)
│   ├─ compiled/
│   │  └─ Compiled SQL files ready for database
│   ├─ manifest.json
│   │  └─ Project metadata and lineage
│   ├─ run_results.json
│   │  └─ Results of last dbt run
│   └─ graph.gpickle
│      └─ Dependency graph
│
└── 📁 dbt_packages/ (if packages installed)
   └─ External dbt packages from dbt hub
```

---

## 🎯 QUICK REFERENCE: FIND WHAT YOU NEED

### I WANT TO...

#### **Understand dbt fundamentals**
→ Read: [README.md](README.md)
- What is dbt?
- Key concepts (models, sources, refs, macros)
- Materializations (view vs table vs incremental)
- CTEs and best practices

#### **See data at each transformation stage**
→ Read: [PIPELINE_WORKFLOW.md](PIPELINE_WORKFLOW.md)
- Raw data examples
- Staging layer transformations
- Mart layer aggregations
- Real data showing before/after

#### **Load data from webhooks/APIs**
→ Read: [WEBHOOK_INTEGRATION.md](WEBHOOK_INTEGRATION.md)
- Flask webhook receiver (Python code)
- Database insertion methods
- Incremental loading
- Real-time data streaming

#### **Run dbt and see commands**
→ Read: [COMMANDS_REFERENCE.md](COMMANDS_REFERENCE.md)
- All dbt commands
- Selection flags (-s, +, tag:)
- Workflows and CI/CD
- Performance tips

#### **Understand project configuration**
→ Edit: [dbt_project.yml](dbt_project.yml)
- Project metadata
- Model materializations
- Seed configurations
- Hooks and plugins

#### **Configure database connections**
→ Edit: [profiles.yml](profiles.yml)
- Target environment setup
- Database credentials
- Thread configuration
- Alternative database examples (Postgres, Snowflake)

#### **Define data sources**
→ Edit: [models/_sources.yml](models/_sources.yml)
- Raw data table definitions
- Column descriptions
- Built-in tests (unique, not_null, etc)
- Referential integrity tests

#### **Create staging models**
→ Edit: [models/staging/stg_customers.sql](models/staging/stg_customers.sql) or [stg_orders.sql](models/staging/stg_orders.sql)
- Clean raw data
- Standardize formats
- Remove duplicates
- Add validation flags

#### **Create mart models**
→ Edit: [models/marts/fct_orders.sql](models/marts/fct_orders.sql) or [dim_customers.sql](models/marts/dim_customers.sql)
- Join staging tables
- Create business logic
- Aggregate metrics
- Create reporting tables

#### **Write reusable functions**
→ Edit: [macros/common_macros.sql](macros/common_macros.sql)
- Define Jinja macros
- Create custom logic
- Call in models with {{ macro_name() }}

#### **Write data quality tests**
→ Edit: [tests/data_quality_checks.sql](tests/data_quality_checks.sql)
- Custom SQL tests
- Or add tests to _sources.yml for generic tests

#### **Load static reference data**
→ Edit: [seeds/_seeds.yml](seeds/_seeds.yml)
- Define seed configurations
- Upload CSV files with dbt seed

#### **Access raw source data**
→ View: [data/customers_raw.csv](data/customers_raw.csv) or [orders_raw.csv](data/orders_raw.csv)
- Sample input data
- Edit to test transformations

---

## 🔑 KEY FILES TO KNOW

| File | Purpose | Key Concept |
|------|---------|-------------|
| **dbt_project.yml** | Main config | Project setup, model defaults |
| **profiles.yml** | Database config | Connection details |
| **_sources.yml** | Data sources | Raw data definitions & tests |
| **stg_*.sql** | Staging models | Clean & standardize |
| **dim_*.sql** | Dimension tables | Attributes (what/who/where) |
| **fct_*.sql** | Fact tables | Events/transactions (measurements) |
| **common_macros.sql** | Reusable functions | DRY principle |
| **data_quality_checks.sql** | Tests | Validate transformations |

---

## 📊 KEY CONCEPTS & WHERE TO FIND THEM

### Models
- **Definition:** SQL files that create tables/views
- **Find them:** `models/staging/` and `models/marts/`
- **Learn about:** README.md → Materializations section
- **Example:** stg_customers.sql, fct_orders.sql

### Sources
- **Definition:** References to raw external data
- **Configure in:** _sources.yml
- **Use in models:** `{{ source('raw_data', 'customers') }}`
- **Learn about:** README.md → Sources section

### Refs
- **Definition:** References to other dbt models
- **Use in models:** `{{ ref('stg_customers') }}`
- **Learn about:** README.md → Refs section
- **Purpose:** Create automatic dependencies

### Macros
- **Definition:** Reusable Jinja/SQL functions
- **Define in:** macros/common_macros.sql
- **Use in models:** `{{ generate_alias_name() }}`
- **Learn about:** README.md → Macros section

### Tests
- **Definition:** Data quality validations
- **Generic tests:** Defined in YAML (not_null, unique, etc)
- **Singular tests:** Custom SQL files in tests/
- **Learn about:** README.md → Tests section
- **Examples:** tests/data_quality_checks.sql, _sources.yml

### CTEs
- **Definition:** WITH clauses for readable SQL
- **Example:** stg_customers.sql (uses multiple CTEs)
- **Learn about:** README.md → CTEs section
- **Benefits:** Modular, readable, maintainable

### Lineage
- **Definition:** Dependency graph showing data flow
- **View it:** Run `dbt docs serve` and browse
- **Trace it:** PIPELINE_WORKFLOW.md
- **See it:** Target > manifest.json
- **Track it:** Via ref() and source() calls

---

## 🚀 GETTING STARTED CHECKLIST

- [ ] **Install dbt**
  ```bash
  pip install dbt-core dbt-duckdb
  ```

- [ ] **Test connection**
  ```bash
  cd my_dbt_project
  dbt debug
  ```

- [ ] **Load data**
  ```bash
  dbt seed
  ```

- [ ] **Run models**
  ```bash
  dbt run
  ```

- [ ] **Run tests**
  ```bash
  dbt test
  ```

- [ ] **View documentation**
  ```bash
  dbt docs generate
  dbt docs serve
  ```

- [ ] **Explore documentation**
  - Click on models
  - View columns and descriptions
  - See lineage graph
  - Review tests

- [ ] **Read the learning materials**
  1. README.md - Fundamentals
  2. PIPELINE_WORKFLOW.md - Data flow
  3. COMMANDS_REFERENCE.md - Operations
  4. WEBHOOK_INTEGRATION.md - Real-time data

- [ ] **Experiment**
  - Edit a model SQL
  - Add a new column
  - Write a test
  - Create a macro

---

## 📝 COMMON MODIFICATIONS

### Add a new column to a staging model
1. Edit: `models/staging/stg_customers.sql`
2. Add: New select column with logic
3. Run: `dbt run -s stg_customers`
4. Test: `dbt test -s stg_customers`
5. Document: Add to `_sources.yml`

### Create a new mart model
1. Create: `models/marts/my_new_model.sql`
2. Base it on: Existing stg_* or dim_*
3. Add: Key business logic
4. Add: Documentation in `_sources.yml`
5. Run: `dbt run -s my_new_model`
6. Test: `dbt test -s my_new_model`

### Add a test to verify data
1. Add to: `_sources.yml` under columns section
   ```yaml
   tests:
     - not_null
     - unique
   ```
2. Or create: `tests/my_test.sql` (custom test)
3. Run: `dbt test -s model_name`

### Load CSV seed data
1. Create: CSV file in `seeds/` folder
2. Configure: Add to `_seeds.yml`
3. Load: `dbt seed`
4. Use in models: `{{ ref('my_seed_filename') }}`

---

## 🧪 TESTING YOUR KNOWLEDGE

### Quiz: Match the Purpose to the File

1. **Define that customer_id must be unique**
   → `_sources.yml` (add `unique` test)

2. **Make stg_customers a VIEW instead of TABLE**
   → `models/staging/stg_customers.sql` (in config block)

3. **Connect to PostgreSQL database**
   → `profiles.yml` (add postgres config)

4. **Create a cents-to-dollars conversion function**
   → `macros/common_macros.sql` (define macro)

5. **Load customer data from CSV**
   → `dbt seed` command (runs files in seeds/)

6. **See all compiled SQL**
   → `target/compiled/` directory (auto-generated)

7. **Join customer and order tables**
   → `models/marts/fct_orders.sql` (using ref() and join)

8. **Add loading timestamp to data**
   → Any model SQL (use `current_timestamp`)

**Answers: 1→_sources.yml, 2→config(), 3→profiles.yml, 4→macros, 5→seeds/, 6→target/, 7→marts, 8→model SQL**

---

## 💡 TROUBLESHOOTING BY FILE

| Issue | Check File |
|-------|-----------|
| "Connection refused" | profiles.yml |
| "Table not found" | _sources.yml or ref() statement |
| "Column not found" | Model SQL or upstream model |
| "Test failed" | YAML test config or data_quality_checks.sql |
| "Circular dependency" | Check ref() calls for loops |
| "Syntax error" | dbt compile or dbt parse output |
| "Missing documentation" | _sources.yml descriptions |

---

## 🎓 LEARNING PATH

1. **Day 1 - Basics**
   - Read: README.md (30 min)
   - Run: `dbt debug` → `dbt seed` → `dbt run` → `dbt test`
   - Browse: `dbt docs serve`

2. **Day 2 - Pipeline**
   - Read: PIPELINE_WORKFLOW.md (30 min)
   - Edit: Add column to stg_customers.sql
   - Run: Test your changes

3. **Day 3 - Real-Time Data**
   - Read: WEBHOOK_INTEGRATION.md (45 min)
   - Try: Flask webhook example
   - Integrate: Into your pipeline

4. **Day 4 - Advanced**
   - Read: COMMANDS_REFERENCE.md
   - Try: Different selection flags
   - Create: New mart model from scratch

5. **Day 5 - Mastery**
   - Experiment: With different model configurations
   - Optimize: Add incremental models
   - Share: With your team!

---

## 🎯 NEXT STEPS

✅ **Complete:** This is a fully functional dbt project!

🔧 **Customize:** Edit the data and transformations for your needs

📚 **Learn More:** Visit https://docs.getdbt.com/

🤝 **Share:** Version control your project with git

🚀 **Deploy:** Move to production environment

---

## 📞 QUICK COMMAND REFERENCE

```bash
# Test connection
dbt debug

# Load seed data
dbt seed

# Run models
dbt run

# Run tests
dbt test

# Full pipeline
dbt build

# View documentation
dbt docs serve

# List all models
dbt list

# Run specific model
dbt run -s stg_customers

# See compiled SQL
dbt compile

# Check syntax
dbt parse

# Refresh docs
dbt docs generate
```

---

**You now have a complete, production-ready dbt learning project!** 🎉

Start with `dbt debug` and build from there.
