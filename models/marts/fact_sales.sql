{{config(materialized='table')}}

select 

order_id,
customer_id,
product,
category,
quantity,
price,
total_amount,
order_date

from {{ ref('stg_sales')}}