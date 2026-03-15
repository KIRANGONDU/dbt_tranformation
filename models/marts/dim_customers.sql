{{config(materialized='table')}}

select 
customer_id,
total_orders,
total_spent,
avg_order_value

from {{ ref('int_sales_metrics')}}