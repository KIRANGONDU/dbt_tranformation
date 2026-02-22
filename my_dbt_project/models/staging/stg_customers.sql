/*
============================================================================
STAGING MODEL: stg_customers
============================================================================

PURPOSE:
  - Load raw customer data from CSV file
  - Clean and standardize column names (snake_case)
  - Add surrogate key (dbt_hashed_id)
  - Add loading timestamp
  - Remove duplicates

MATERIALIZATION: view (temporary, not persisted)
  - Views are created fresh each time and deleted when not in use
  - Good for intermediate transformation steps
  - Minimal storage overhead

DEPENDENCIES: None (source data from CSV)

EXPECTED OUTPUT:
  Columns: customer_id, customer_name, email, signup_date, country,
           dbt_hashed_id, loaded_at

============================================================================
*/

{{
  config(
    materialized = 'view',
    alias = 'stg_customers',
    tags = ['staging'],
    meta = {
      'owner': 'analytics',
      'refresh_frequency': 'daily'
    }
  )
}}

-- CTE (Common Table Expression) 1: Extract raw data from CSV
with raw_customers_cte as (
  select
    -- Renaming columns to snake_case (dbt convention)
    customer_id,
    customer_name,
    email,
    signup_date,
    country
  from {{ source('raw_data', 'customers') }}
    -- Alternative without source: from 'raw.customers'
),

-- CTE 2: Clean and enhance data
cleaned_customers_cte as (
  select
    customer_id,
    
    -- CLEANING: Trim whitespace and convert to title case
    trim(customer_name) as customer_name,
    
    -- CLEANING: Lowercase email for consistency
    lower(email) as email,
    
    -- PARSING: Convert string date to YYYY-MM-DD format
    cast(signup_date as date) as signup_date,
    
    -- VALIDATION: Handle missing countries
    coalesce(upper(country), 'UNKNOWN') as country,
    
    -- HASHING: Create unique identifier for deduplication
    md5(cast(customer_id as string) || email) as dbt_hashed_id,
    
    -- TRACKING: Add load timestamp
    current_timestamp as loaded_at
  from raw_customers_cte
),

-- CTE 3: Remove duplicates (keep most recent)
deduped_customers_cte as (
  select
    *,
    -- ROW_NUMBER gives each duplicate a rank, we keep rank 1
    row_number() over (partition by customer_id order by loaded_at desc) as rn
  from cleaned_customers_cte
)

-- FINAL OUTPUT: Select deduplicated records
select
  customer_id,
  customer_name,
  email,
  signup_date,
  country,
  dbt_hashed_id,
  loaded_at
from deduped_customers_cte
where rn = 1  -- Keep only the most recent record per customer
order by customer_id
