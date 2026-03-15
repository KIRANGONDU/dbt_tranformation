{{config(materialized='table')}}

select 

customer_id,
count(order_id) as total_orders,
sum(total_amount) as total_spent,
avg(total_amount)  as avg_order_value

from {{ ref('stg_sales') }}
group by customer_id