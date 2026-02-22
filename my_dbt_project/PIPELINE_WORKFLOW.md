# ============================================================================
# DBT DATA PIPELINE WORKFLOW - DETAILED WALKTHROUGH
# ============================================================================
# This document traces data from source (CSV) through the entire pipeline
# showing transformations at each step
# ============================================================================

## PIPELINE OVERVIEW

```
Raw CSV Files (Source Data)
        ↓
   ╔═══════════════════════════════════╗
   ║    STAGING LAYER (stg_*)          ║
   ║  - Clean & Standardize            ║
   ║  - Materialized as VIEWS          ║
   ║  - No persistence                 ║
   ╚═══════════════════════════════════╝
        ↓ (joined)
   ╔═══════════════════════════════════╗
   ║    MART LAYER (dim_*, fct_*)      ║
   ║  - Create tables for reporting    ║
   ║  - Materialized as TABLES         ║
   ║  - Structured for analytics       ║
   ╚═══════════════════════════════════╝
        ↓
   Analytics, Dashboards, Reports
```

---

## STEP 1: RAW DATA (Source CSV Files)

### File: data/customers_raw.csv

```csv
customer_id,customer_name,email,signup_date,country
1,John Smith,john.smith@email.com,2024-01-15,USA
2,Sarah Johnson,sarah.j@email.com,2024-02-20,Canada
3,Michael Brown,m.brown@email.com,2024-03-10,USA
```

**Issues in raw data:**
- Names may have inconsistent casing
- Emails may have varying cases
- Dates are string format, not parsed
- No surrogate keys

### File: data/orders_raw.csv

```csv
order_id,customer_id,order_date,amount,status
101,1,2024-01-20,150.00,completed
102,2,2024-02-25,275.50,completed
103,1,2024-03-15,89.99,completed
```

**Issues in raw data:**
- Amounts are stored as strings
- Dates need type conversion
- No validation flags
- Potential for duplicate records

---

## STEP 2: STAGING LAYER - EXTRACT & CLEAN

### Model: models/staging/stg_customers.sql

**Purpose:** Clean and standardize customer data

**Input Data:**
```
customer_id | customer_name   | email                  | signup_date | country
1           | John Smith      | john.smith@email.com   | 2024-01-15  | USA
2           | sarah johnson   | SARAH.J@EMAIL.COM      | 2024-02-20  | Canada
```

**Transformations Applied:**

```sql
-- 1. CLEAN NAMES: trim() + title case
"John Smith" → "John Smith" (trimmed)
"sarah johnson" → "Sarah Johnson" (title case)

-- 2. CLEAN EMAIL: lowercase
"john.smith@email.com" → "john.smith@email.com"
"SARAH.J@EMAIL.COM" → "sarah.j@email.com"

-- 3. PARSE DATES: string → DATE type
"2024-01-15" → DATE '2024-01-15'
"2024-02-20" → DATE '2024-02-20'

-- 4. HANDLE COUNTRIES: standardize
"USA" → "USA"
"Canada" → "CANADA"
"" → "UNKNOWN" (null handling)

-- 5. CREATE SURROGATE KEY: hash of ID + email
md5(concat(1, "john.smith@email.com")) → "a3d5e4f2c..."

-- 6. ADD TIMESTAMP: loading time
current_timestamp → 2024-11-20 14:30:45
```

**Output: stg_customers**

```
customer_id | customer_name  | email              | signup_date | country | dbt_hashed_id | loaded_at
1           | John Smith     | john.smith@email.com | 2024-01-15 | USA     | a3d5e4f2c... | 2024-11-20 14:30:45
2           | Sarah Johnson  | sarah.j@email.com   | 2024-02-20 | CANADA  | b4e6f5g3d... | 2024-11-20 14:30:45
3           | Michael Brown  | m.brown@email.com   | 2024-03-10 | USA     | c5f7g6h4e... | 2024-11-20 14:30:45
```

**Issues Handled:**
✓ Standardized format
✓ Proper data types
✓ Duplicates removed (using dbt_hashed_id)
✓ Nulls handled
✓ Audit trail added (loaded_at)

---

### Model: models/staging/stg_orders.sql

**Purpose:** Validate and clean order data

**Input Data:**
```
order_id | customer_id | order_date | amount  | status
101      | 1           | 2024-01-20 | 150.00  | completed
102      | 2           | 2024-02-25 | 275.50  | COMPLETED
103      | 1           | 2024-03-15 | 89.99   | completed
```

**Issues to fix:**
- Amount should be decimal type
- Status has inconsistent casing
- No validation flags
- Missing error tracking

**Transformations Applied:**

```sql
-- 1. PARSE AMOUNT: string → NUMERIC(10,2)
"150.00" → 150.00 (numeric)
"275.50" → 275.50 (numeric)

-- 2. PARSE DATE: string → DATE
"2024-01-20" → DATE '2024-01-20'

-- 3. STANDARDIZE STATUS: lowercase
"completed" → "completed"
"COMPLETED" → "completed"
"Pending" → "pending"

-- 4. ADD VALIDATION FLAGS
amount = 150.00 → is_valid_amount = TRUE
amount = -50 → is_valid_amount = FALSE
amount = 0 → is_valid_amount = FALSE

status = "completed" → is_valid_status = TRUE
status = "unknown" → is_valid_status = FALSE (not in allowed values)

-- 5. ADD TRACKING
loaded_at = 2024-11-20 14:30:52
```

**Output: stg_orders**

```
order_id | customer_id | order_date | amount | status    | is_valid_amount | is_valid_status | loaded_at
101      | 1           | 2024-01-20 | 150.00 | completed | TRUE            | TRUE            | 2024-11-20 14:30:52
102      | 2           | 2024-02-25 | 275.50 | completed | TRUE            | TRUE            | 2024-11-20 14:30:52
103      | 1           | 2024-03-15 | 89.99  | completed | TRUE            | TRUE            | 2024-11-20 14:30:52
```

---

## STEP 3: MART LAYER - AGGREGATE & ENRICH

### Model: models/marts/dim_customers.sql

**Purpose:** Customer master dimension for reporting

**Input:** stg_customers (FROM staging layer)

```
customer_id | customer_name  | email              | signup_date | country
1           | John Smith     | john.smith@email.com | 2024-01-15 | USA
2           | Sarah Johnson  | sarah.j@email.com   | 2024-02-20 | CANADA
3           | Michael Brown  | m.brown@email.com   | 2024-03-10 | USA
```

**Transformations & Enrichments:**

```sql
-- 1. ADD REGION: derived from country
country = "USA" → region = "North America"
country = "CANADA" → region = "North America"
country = "UK" → region = "Europe"
country = "AUSTRALIA" → region = "APAC"

-- 2. CALCULATE DAYS SINCE SIGNUP
signup_date = 2024-01-15, today = 2024-11-20 → days_since_signup = 310

-- 3. CLASSIFY CUSTOMER LIFECYCLE
days_since_signup <= 90 → customer_status = "New"
days_since_signup 91-365 → customer_status = "Active"
days_since_signup > 365 → customer_status = "Mature"
```

**Output: dim_customers (TABLE)**

```
customer_id | customer_name  | email              | country | region        | days_since_signup | customer_status
1           | John Smith     | john.smith@email.com | USA     | North America | 310              | Mature
2           | Sarah Johnson  | sarah.j@email.com   | CANADA  | North America | 274              | Active
3           | Michael Brown  | m.brown@email.com   | USA     | North America | 256              | Active
```

**Benefits:**
- Single source of truth for customer data
- Pre-calculated regions and segments
- Ready for direct reporting
- Optimized for fast queries (no joins needed)

---

### Model: models/marts/fct_orders.sql

**Purpose:** Order fact table with customer attributes and metrics

**Inputs:** 
- stg_orders (orders data)
- dim_customers (customer attributes)

**Join Logic:**
```
stg_orders.customer_id = dim_customers.customer_id
```

**Transformations & Enrichments:**

```sql
-- 1. DENORMALIZE: Add customer attributes to orders
order.order_id=101, customer.customer_id=1
→ Add customer_name="John Smith", country="USA", email="john.smith@email.com"

-- 2. CALCULATE CUSTOMER METRICS
All orders for customer_id = 1:
  order 101: $150.00
  order 103: $89.99
→ customer_lifetime_value = 150.00 + 89.99 = $239.99
→ customer_order_count = 2

-- 3. BUSINESS TIER: Categorize order value
amount = 150.00 → order_tier = "medium_value" (200-499)
amount = 275.50 → order_tier = "high_value" (>=500)
amount = 89.99 → order_tier = "low_value" (<200)

-- 4. ENCODE STATUS
status = "completed" → is_completed = 1 (boolean to numeric)
status = "pending" → is_completed = 0

-- 5. CALCULATE RELATIONSHIP
order_date = 2024-01-20, signup_date = 2024-01-15
→ days_since_signup = 5
```

**Output: fct_orders (TABLE)**

```
order_id | customer_id | customer_name  | order_date | amount | status    | order_tier     | customer_lifetime_value | customer_order_count | is_completed | days_since_signup
101      | 1           | John Smith     | 2024-01-20 | 150.00 | completed | medium_value   | 239.99                  | 2                    | 1            | 5
102      | 2           | Sarah Johnson  | 2024-02-25 | 275.50 | completed | high_value     | 275.50                  | 1                    | 1            | 5
103      | 1           | John Smith     | 2024-03-15 | 89.99  | completed | low_value      | 239.99                  | 2                    | 1            | 59
```

**Benefits:**
- Denormalized → No joins needed for reports
- Pre-calculated → Aggregates ready to use
- Business context → Tiers and segments built-in
- Optimized → Best performance for queries

---

## STEP 4: QUALITY ASSURANCE - TESTING

### dbt Test Execution

```bash
$ dbt test

Running with dbt version 1.5.0
Found 4 models, 0 tests, 0 snapshots...

Running test: not_null_stg_customers_customer_id
✓ PASS - All customer_ids are not null

Running test: unique_stg_customers_customer_id
✓ PASS - No duplicate customer ids

Running test: not_null_stg_orders_amount
✓ PASS - All amounts are not null

Running test: accepted_values_stg_orders_status
✓ PASS - All statuses are valid

Running test: relationships_stg_orders_customer_id
✓ PASS - All customer_ids exist in stg_customers

5 tests passed
```

**Test Results:**
- Validates source data quality
- Checks referential integrity
- Confirms transformations worked
- Ensures data consistency

---

## STEP 5: REPORTING & ANALYTICS

### Example Report Query on fct_orders

```sql
-- Revenue by customer region
select
  c.region,
  count(*) as order_count,
  sum(fct.amount) as total_revenue,
  avg(fct.amount) as avg_order_value,
  sum(fct.is_completed) as completed_orders
from fct_orders fct
join dim_customers c on fct.customer_id = c.customer_id
group by c.region
order by total_revenue desc
```

**Output (ready for dashboards):**

```
region        | order_count | total_revenue | avg_order_value | completed_orders
North America | 8           | 2,327.24      | 290.91          | 8
Europe        | 1           | 450.00        | 450.00          | 1
APAC          | 1           | 800.00        | 800.00          | 1
```

This data would power dashboards, BI tools, and executive reports.

---

## DATA TRACEABILITY - LINEAGE

### How to trace a value from source to report:

```
Report Output: Customer_id=1, customer_name="John Smith", order_count=2

↓ Trace backwards

Query table: fct_orders
  SELECT customer_name FROM fct_orders WHERE customer_id = 1
  Source: dim_customers (denormalized)

↓ Trace back

Query table: dim_customers
  SELECT customer_name FROM dim_customers WHERE customer_id = 1
  Source: stg_customers

↓ Trace back

Query table: stg_customers
  SELECT customer_name FROM {{ source('raw_data', 'customers') }}
  Source: data/customers_raw.csv

↓ Trace back

CSV File: data/customers_raw.csv
  Raw value from upload
```

This complete lineage is tracked by dbt!

**View lineage in dbt docs:**
```
$ dbt docs serve
```
Click on a column to see full upstream/downstream dependencies.

---

## KEY CONCEPTS ILLUSTRATED

### 1. **Materialization Strategy**
- **Staging (VIEW):** 
  - Lightweight, temporary
  - Not persisted
  - Fast to generate
  - Good for intermediate steps

- **Marts (TABLE):**
  - Persistent, indexed
  - Optimized for queries
  - Final reporting layer
  - Generate once, query multiple times

### 2. **Grain (Granularity)**
- **stg_customers:** One row per customer
- **stg_orders:** One row per order
- **dim_customers:** One row per customer (dimension)
- **fct_orders:** One row per order (fact)

### 3. **Normalization vs Denormalization**
- **Normalized (staging):** Clean, single sources
- **Denormalized (marts):** Customer attributes added to orders

This balances data integrity with query performance.

### 4. **Idempotency**
Running the pipeline multiple times produces same results:

```bash
$ dbt run
Creating table dbt.fct_orders...
5 rows

$ dbt run  # Run again
Dropping table dbt.fct_orders...
Creating table dbt.fct_orders...
5 rows  # Same result!
```

---

## EXAMPLE: ADDING NEW COLUMN

### Task: Add "order_quarter" column to fct_orders

**Step 1: Modify Model (fct_orders.sql)**

```sql
...
with orders_with_customers as (
  select
    o.order_id,
    ...
    -- NEW: Extract quarter from order_date
    'Q' || quarter(o.order_date) || '-' || year(o.order_date) as order_quarter,
    ...
  from orders o
  left join customers c on o.customer_id = c.customer_id
)
```

**Step 2: Update Documentation (_sources.yml)**

```yaml
- name: fct_orders
  columns:
    ...
    - name: order_quarter
      description: "Quarter of order (Q1-2024, Q2-2024, etc)"
```

**Step 3: Run dbt**

```bash
$ dbt run
$ dbt test
$ dbt docs serve
```

**Step 4: New column available**

New orders table has `order_quarter` and documentation is updated.

---

## SUMMARY: THE DBT WORKFLOW

```
1. Write SQL → 2. Configure YAML → 3. Add Tests → 4. Document
        ↓              ↓               ↓            ↓
   models/        config/tests      _sources.yml   README
        ↓              ↓               ↓            ↓
   5. dbt run → 6. dbt test → 7. dbt docs serve → 8. Share with team
```

Each step is automated, version controlled, and repeatable!
