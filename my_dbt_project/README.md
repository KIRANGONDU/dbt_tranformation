# DBT Project - Complete Learning Guide

## 📚 Table of Contents
1. [Project Structure](#project-structure)
2. [DBT Concepts](#dbt-concepts)
3. [Data Pipeline Flow](#data-pipeline-flow)
4. [File Descriptions](#file-descriptions)
5. [Running the Project](#running-the-project)
6. [Key DBT Commands](#key-dbt-commands)
7. [Transformation Examples](#transformation-examples)
8. [Data Quality & Testing](#data-quality--testing)
9. [Best Practices](#best-practices)

---

## 🗂️ Project Structure

```
my_dbt_project/
├── dbt_project.yml              # Main project config
├── profiles.yml                 # Database connection config
├── README.md                    # This file
│
├── models/                      # SQL transformation files
│   ├── staging/                # Staging models (raw data cleanup)
│   │   ├── stg_customers.sql   # Customer data cleaning
│   │   └── stg_orders.sql      # Order data cleaning
│   │
│   ├── marts/                  # Mart models (business-ready tables)
│   │   ├── dim_customers.sql   # Customer dimension table
│   │   ├── fct_orders.sql      # Order fact table
│   │   └── _models.yml         # Model documentation
│   │
│   └── _sources.yml            # Source definitions & tests
│
├── macros/                      # Reusable SQL functions
│   └── common_macros.sql       # Macro definitions
│
├── seeds/                       # Static data files (CSVs)
│   └── (seed files here)
│
├── tests/                       # Data quality tests
│   └── (custom tests here)
│
├── data/                        # Raw source data (CSVs)
│   ├── customers_raw.csv
│   └── orders_raw.csv
│
├── target/                      # Generated files (auto-created)
│   ├── compiled/               # Compiled SQL
│   ├── manifest.json           # Project metadata
│   └── run_results.json        # Execution results
│
└── dbt_packages/               # External packages (if used)
```

---

## 💡 DBT Concepts

### What is DBT?

**Data Build Tool (dbt)** is a tool that enables data engineers to:
- Write SQL transformations as reusable, modular code
- Version control and test data pipelines
- Generate documentation automatically
- Manage dependencies between models
- Run transformations efficiently in the data warehouse

### Key Concepts

#### 1. **Models**
SQL files that represent tables or views in your database.

**Types:**
- **View**: Virtual table (temporary, not persisted)
- **Table**: Materialized, permanent table
- **Incremental**: Only processes new/changed data (efficient for large datasets)
- **Ephemeral**: Temporary, only exists during compilation

```sql
{{ config(materialized = 'view') }}
select * from raw_data
```

#### 2. **Sources**
References to raw data external to dbt (e.g., CSV files, raw database tables).

```sql
-- In _sources.yml:
sources:
  - name: raw_data
    tables:
      - name: customers

-- In model:
select * from {{ source('raw_data', 'customers') }}
```

#### 3. **Refs**
References to other dbt models, creating dependency tracking.

```sql
-- In a model:
select * from {{ ref('stg_customers') }}

-- This tells dbt that this model depends on stg_customers
-- dbt builds stg_customers FIRST, then this model
```

**Key Benefits:**
- Automatic dependency resolution
- Can change table names without breaking logic
- Creates lineage for data governance

#### 4. **CTEs (Common Table Expressions)**
Using `WITH` clauses to break complex logic into readable steps.

```sql
with step_1_cte as (
  select * from raw_table
),

step_2_cte as (
  select 
    col1,
    upper(col2) as col2
  from step_1_cte
)

select * from step_2_cte
```

#### 5. **Materializations**
How dbt stores the model output.

| Type | Use Case | Storage | Speed | Cost |
|------|----------|---------|-------|------|
| **View** | Intermediate transforms | Virtual | Slow | Low |
| **Table** | Final outputs | Physical | Fast | Medium |
| **Incremental** | Large datasets | Delta updates | Fastest | Very Low |
| **Ephemeral** | Reusable queries | Template | N/A | None |

#### 6. **Macros**
Reusable Jinja/SQL functions similar to functions in programming.

```sql
-- Define macro:
{% macro cents_to_dollars(amount) %}
  ({{ amount }} / 100)
{% endmacro %}

-- Use in model:
select {{ cents_to_dollars('amount_cents') }} as amount_dollars
```

#### 7. **Tests**
Validate data quality. Two types:

**Generic Tests** (built-in):
```yaml
tests:
  - unique      # No duplicates
  - not_null    # No NULL values
  - accepted_values  # Only these values allowed
  - relationships    # Foreign key constraint
```

**Singular Tests** (custom SQL):
```sql
-- tests/check_positive_amounts.sql
select * from {{ ref('stg_orders') }}
where amount <= 0
```

---

## 🔄 Data Pipeline Flow

### Architecture: Medallion (Bronze-Silver-Gold)

```
Raw Data (CSV)
      ↓
   [STAGING LAYER]
   (stg_customers, stg_orders)
   - Clean, validate, standardize
   - Materialized as VIEWS (temporary)
      ↓
   [MART LAYER]
   (dim_*, fct_*) 
   - Join, aggregate, enrich
   - Materialized as TABLES (persistent)
      ↓
   [REPORTING LAYER]
   - Analytics, dashboards
   - SQL queries on MART tables
```

### Data Flow Example: Customer Orders Pipeline

```
Input: customers_raw.csv, orders_raw.csv
                ↓
        stg_customers.sql
        -------→ Cleanup, deduplicate
        (VIEW)
                ↓
        stg_orders.sql
        -------→ Validate amounts, dates
        (VIEW)
                ↓
        dim_customers.sql        fct_orders.sql
        -------→ Customer    +
        (TABLE)  dimension        (TABLE)
                 table      Join ←-------
                            on customer
                            Aggregate
                            ↓
                         Ready for
                         reporting

```

---

## 📄 File Descriptions

### 1. **dbt_project.yml** (Main Configuration)

Controls:
- Project metadata (name, version)
- Model directories and materializations
- Seed file configurations
- Hooks (on-run-start, on-run-end)
- Profiles (database connection)

```yaml
name: 'my_dbt_project'
config-version: 2
profile: 'my_dbt_project'

models:
  my_dbt_project:
    staging:
      materialized: view      # All staging as views
    marts:
      materialized: table     # All marts as tables
```

### 2. **profiles.yml** (Database Connections)

Defines how dbt connects to your data warehouse:

```yaml
my_dbt_project:
  target: dev              # Default target to use
  outputs:
    dev:                   # Development environment
      type: postgres       # Database type
      host: localhost
      user: analytics
      port: 5432
      
    prod:                  # Production environment
      type: postgres
      host: prod-server
```

### 3. **_sources.yml** (Source Definitions & Documentation)

Declares:
- External data sources (CSVs, database tables)
- Data quality tests
- Model descriptions and column metadata

```yaml
sources:
  - name: raw_data
    tables:
      - name: customers
        columns:
          - name: customer_id
            tests:
              - unique
              - not_null
```

### 4. **Staging Models** (`models/staging/`)

**Purpose:** Clean and standardize raw data

**Characteristics:**
- Materialized as VIEWS (lightweight)
- One staging model per source table
- 80% of dbt project work happens here
- Contains business logic for cleaning

Example transformations:
```sql
-- Rename columns to snake_case
-- Parse dates and types
-- Remove duplicates
-- Add quality flags
-- Create surrogate keys
```

**File: stg_customers.sql**
- Loads customers from CSV
- Cleans names (trim, title case)
- Standardizes email (lowercase)
- Adds deduplication logic

**File: stg_orders.sql**
- Loads orders from CSV
- Validates amounts (> 0)
- Standards status field
- Adds quality flags

### 5. **Mart Models** (`models/marts/`)

**Purpose:** Create business-ready tables for reporting

**Two Types:**

**Dimension Tables (dim_*):**
- One row per entity (customer, product, date)
- Contains attributes (descriptive columns)
- Used for filtering and grouping
- Example: `dim_customers` - one row per customer

**Fact Tables (fct_*):**
- One row per event/transaction
- Contains foreign keys and measures
- Numerical data for aggregation
- Example: `fct_orders` - one row per order

**File: dim_customers.sql**
- Cleansed customer master data
- Adds region, lifecycle status
- Ready for use in reports

**File: fct_orders.sql**
- Denormalized orders with customer info
- Includes aggregates (customer lifetime value)
- Business tiers (order value categorization)

### 6. **Macros** (`macros/`)

Reusable code templates:

```sql
{% macro generate_alias_name(custom_alias_name=none) %}
  -- Custom table naming logic
{% endmacro %}

{% macro insert_metrics(table_name) %}
  -- Post-build logging
{% endmacro %}

{% macro cents_to_dollars(amount) %}
  -- Currency conversion
{% endmacro %}
```

### 7. **Raw Data** (`data/`)

CSV files with source data:
- `customers_raw.csv` - Customer master data
- `orders_raw.csv` - Transaction data

### 8. **Seeds** (`seeds/`)

Static data loaded via `dbt seed` command:
- Useful for reference tables
- Version controlled
- Loaded before models run

---

## ▶️ Running the Project

### Installation

```bash
# Create virtual environment
python -m venv dbt_env

# Activate it
# Windows:
dbt_env\Scripts\activate
# Mac/Linux:
source dbt_env/bin/activate

# Install dbt
pip install dbt-core dbt-postgres
# For DuckDB:
pip install dbt-duckdb
```

### Initial Setup

```bash
# Navigate to project
cd my_dbt_project

# Test database connection
dbt debug

# Check configuration
dbt docs generate  # Creates documentation website
```

### Running Models

```bash
# Run all models
dbt run

# Run specific model and its parents
dbt run --models stg_customers

# Run specific model and its children
dbt run --models +fct_orders

# Run with specific tag
dbt run --select tag:mart

# Load seed data
dbt seed

# Run tests
dbt test

# Full pipeline: seed → run → test
dbt build

# Drop all objects (careful!)
dbt run-operation drop_old_models
```

---

## 🔧 Key DBT Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `dbt debug` | Test DB connection | `dbt debug` |
| `dbt run` | Execute models | `dbt run --models staging` |
| `dbt test` | Run data tests | `dbt test --models stg_customers` |
| `dbt seed` | Load CSV files | `dbt seed` |
| `dbt docs generate` | Create documentation | `dbt docs generate` |
| `dbt docs serve` | Browse documentation | `dbt docs serve` (opens browser) |
| `dbt parse` | Parse project without executing | `dbt parse` |
| `dbt snapshot` | Create point-in-time snapshot | `dbt snapshot` |
| `dbt refresh` | Update materialized views | `dbt refresh` |
| `dbt build` | Full pipeline (seed+run+test) | `dbt build` |

---

## 📊 Transformation Examples

### Example 1: Loading Data

```sql
-- Load from source (CSV via {{ source() }})
select *
from {{ source('raw_data', 'customers') }}
```

**Output:** Raw customer data from CSV

---

### Example 2: Cleaning Data

```sql
-- Clean and standardize
with raw as (
  select
    customer_id,
    upper(customer_name) as customer_name,  -- Uppercase
    lower(email) as email,                   -- Lowercase
    cast(signup_date as date) as signup_date -- Parse to DATE
  from {{ source('raw_data', 'customers') }}
)

select * from raw
```

**Output:** Standardized customer data

---

### Example 3: Data Quality Checks

```sql
-- Add quality flags
with orders as (
  select
    order_id,
    amount,
    status,
    -- Flag invalid records
    case 
      when amount <= 0 then false
      else true
    end as is_valid_amount,
    case
      when status not in ('completed', 'pending', 'cancelled') then false
      else true
    end as is_valid_status
  from {{ source('raw_data', 'orders') }}
)

select * from orders
where is_valid_amount and is_valid_status
```

**Output:** Only valid orders passed forward

---

### Example 4: Joining Tables

```sql
-- Combine customer and order data
with orders as (
  select * from {{ ref('stg_orders') }}
),

customers as (
  select * from {{ ref('stg_customers') }}
)

select
  o.order_id,
  o.order_date,
  o.amount,
  c.customer_name,  -- From customer table
  c.country
from orders o
left join customers c on o.customer_id = c.customer_id
```

**Output:** Orders enriched with customer attributes

---

### Example 5: Aggregations

```sql
-- Calculate customer metrics
with orders as (
  select
    customer_id,
    amount
  from {{ ref('stg_orders') }}
)

select
  customer_id,
  count(*) as order_count,           -- Number of orders
  sum(amount) as customer_lifetime_value,  -- Total spent
  avg(amount) as avg_order_value     -- Average order size
from orders
group by customer_id
```

**Output:** Customer aggregates

---

### Example 6: Using Macros

```sql
-- Reuse macro logic
select
  order_id,
  {{ cents_to_dollars('amount_cents') }} as amount_dollars
from {{ ref('stg_orders') }}

-- Expands to: (amount_cents / 100) as amount_dollars
```

---

## ✅ Data Quality & Testing

### Built-in Generic Tests

```yaml
# In _sources.yml or models YAML
tests:
  - unique              # No duplicates
  - not_null            # No NULL values
  - accepted_values     # Whitelist of allowed values
  - relationships       # Foreign key constraint
```

### Test Example

```yaml
columns:
  - name: customer_id
    tests:
      - unique      # No duplicate customer IDs
      - not_null    # Every order has a customer

  - name: status
    tests:
      - accepted_values:
          values: ['completed', 'pending', 'cancelled']

  - name: customer_id
    tests:
      - relationships:
          to: source('raw_data', 'customers')
          field: customer_id
```

### Running Tests

```bash
# Run all tests
dbt test

# Test specific model
dbt test --models stg_customers

# Run tests with detailed output
dbt test --debug
```

---

## 🎯 Best Practices

### 1. **Naming Conventions**
```
stg_* → Staging models (views)
dim_* → Dimension tables (attributes)
fct_* → Fact tables (events/transactions)
tmp_* → Temporary/ephemeral models
```

### 2. **Model Organization**
```
models/
  ├── staging/
  │   └── [one model per source table]
  ├── intermediate/
  │   └── [complex joins/calculations]
  └── marts/
      ├── dimensions/
      └── facts/
```

### 3. **Documentation**
```sql
{{ config(
  materialized = 'table'
) }}

-- Document in YAML file
description: "Clear description of what this model does"
columns:
  - name: customer_id
    description: "Unique customer identifier"
```

### 4. **Testing**
- Add tests to source tables
- Test critical calculations
- Test referential integrity

### 5. **Code Quality**
```sql
-- Use CTEs for readability
with staging as (
  select * from {{ source() }}
),

transformed as (
  select * from staging where is_valid
)

select * from transformed
```

### 6. **Dependencies**
Use `ref()` not raw table names:
```sql
❌ select * from public.stg_customers
✅ select * from {{ ref('stg_customers') }}
```

### 7. **Version Control**
```bash
# Keep in git
git init
git add .
git commit -m "Initial dbt project setup"
```

---

## 🚀 Next Steps to Learn

1. **Run the project:**
   ```bash
   dbt seed          # Load CSV data
   dbt run           # Build tables
   dbt test          # Validate data
   dbt docs serve    # View documentation
   ```

2. **Experiment:**
   - Modify SQL in `stg_customers.sql`
   - Add new columns to marts
   - Create new models for your own data

3. **Learn More:**
   - [dbt Docs](https://docs.getdbt.com/)
   - [dbt Community](https://community.getdbt.com/)
   - Create snapshots, tests, and hooks

---

## 📞 Tips & Troubleshooting

**Models not building?**
- Run `dbt parse` to check syntax
- Check `dbt debug` for DB connection issues
- Look at compiled SQL in `target/compiled/`

**Tests failing?**
- Run `dbt test --debug` for details
- Check source CSV files for issues
- Review test definitions in YAML

**Want to see generated SQL?**
- Check `target/compiled/` after running
- Use `dbt compile` to generate without executing
- Enable verbose logging: `dbt --debug`

---

This project is a complete learning resource for dbt! 🎓
