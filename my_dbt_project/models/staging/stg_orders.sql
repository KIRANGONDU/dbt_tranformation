/*
============================================================================
STAGING MODEL: stg_orders
============================================================================

PURPOSE:
  - Load raw order data from CSV file
  - Clean amounts and dates
  - Validate and standardize status field
  - Add metadata for tracking

DATA QUALITY CHECKS:
  - Amount should be > 0
  - Status should be in (completed, pending, cancelled)
  - Order date should not be in future

============================================================================
*/

{{
  config(
    materialized = 'view',
    tags = ['staging']
  )
}}

with raw_orders_cte as (
  select
    order_id,
    customer_id,
    order_date,
    amount,
    status
  from {{ source('raw_data', 'orders') }}
),

cleaned_orders_cte as (
  select
    order_id,
    customer_id,
    
    -- Parse order date
    cast(order_date as date) as order_date,
    
    -- Convert amount to decimal (2 decimal places for currency)
    cast(amount as numeric(10, 2)) as amount,
    
    -- Standardize status to lowercase
    lower(status) as status,
    
    -- Data quality flags
    case
      when cast(amount as numeric) <= 0 then false
      else true
    end as is_valid_amount,
    
    case
      when lower(status) not in ('completed', 'pending', 'cancelled') then false
      else true
    end as is_valid_status,
    
    -- Tracking
    current_timestamp as loaded_at
  from raw_orders_cte
)

select * from cleaned_orders_cte
order by order_id
