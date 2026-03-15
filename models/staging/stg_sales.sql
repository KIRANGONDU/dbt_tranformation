{{config(materialized='table')}}
select 
order_id,
customer_id,
product,
category,
quantity,
price,
quantity * price as total_amount,
order_date

from {{ source('raw','orders_data')}}

where quantity > 0