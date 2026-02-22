/*
============================================================================
MART MODEL: dim_customers
============================================================================

MODEL TYPE: DIMENSION TABLE

PURPOSE:
  - Create a clean customer dimension for reporting
  - Add customer metrics and classifications
  - Foundation for customer analytics

MATERIALIZATION: table (persisted, read-optimized)

GRAIN: One row per unique customer

TYPICAL USAGE:
  - Customer reports
  - Segmentation analysis
  - Customer lifetime value calculations

============================================================================
*/

{{
  config(
    materialized = 'table',
    alias = 'dim_customers',
    tags = ['mart', 'dimension']
  )
}}

with customers as (
  select * from {{ ref('stg_customers') }}
),

-- Add customer segment based on country region
customer_with_segment as (
  select
    customer_id,
    customer_name,
    email,
    signup_date,
    country,
    
    -- Add days calculation (calculate first, then use in conditions)
    cast(datediff(day, signup_date, current_date) as int) as days_since_signup,
    
    -- Segment by region
    case
      when country in ('USA', 'Canada', 'Mexico') then 'North America'
      when country in ('UK', 'France', 'Germany', 'Spain') then 'Europe'
      when country = 'Australia' then 'APAC'
      else 'Other'
    end as region,
    
    -- Customer status based on days since signup
    case
      when datediff(day, signup_date, current_date) <= 90 then 'New'
      when datediff(day, signup_date, current_date) <= 365 then 'Active'
      else 'Mature'
    end as customer_status,
    
    -- Surrogate key
    dbt_hashed_id,
    
    -- Timestamps
    loaded_at
  from customers
)

select * from customer_with_segment
order by signup_date
