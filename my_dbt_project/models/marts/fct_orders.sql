/*
============================================================================
MART MODEL: fct_orders
============================================================================

MODEL TYPE: FACT TABLE

PURPOSE:
  - Join staging customer and order tables
  - Create business-ready order summary
  - Aggregate metrics at order level
  - Calculate derived fields (days since signup, order priority)

MATERIALIZATION: table (persisted in database)
  - Tables are permanent and fast to query
  - Good for reporting and analytics
  - Regenerated on each dbt run

GRAIN: One row per order (fact grain)

USAGE: 
  - Revenue reporting
  - Customer order analysis
  - Order status tracking

============================================================================
*/

{{
  config(
    materialized = 'table',
    alias = 'fct_orders',
    tags = ['mart', 'core']
  )
}}

with orders as (
  select * from {{ ref('stg_orders') }}
  where is_valid_amount and is_valid_status
),

customers as (
  select * from {{ ref('stg_customers') }}
),

-- JOIN: Combine customer and order data
orders_with_customers as (
  select
    -- Order keys
    o.order_id,
    o.customer_id,
    
    -- Customer attributes
    c.customer_name,
    c.email,
    c.country,
    
    -- Order attributes
    o.order_date,
    o.amount,
    o.status,
    
    -- Derived metrics
    cast(o.order_date - c.signup_date as int) as days_since_signup,
    
    -- Order value tiers
    case
      when o.amount >= 500 then 'high_value'
      when o.amount >= 200 then 'medium_value'
      else 'low_value'
    end as order_tier,
    
    -- Status categorization
    case
      when o.status = 'completed' then 1
      else 0
    end as is_completed,
    
    -- Aggregates
    sum(o.amount) over (partition by o.customer_id) as customer_lifetime_value,
    count(*) over (partition by o.customer_id) as customer_order_count,
    
    -- Tracking
    current_timestamp as refined_at
  from orders o
  left join customers c on o.customer_id = c.customer_id
)

select * from orders_with_customers
order by order_date desc, order_id
