{{config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy = 'merge'
)}}

select 
order_id,
customer_id,
product,
quantity,
price,
quantity * price  as total_amount,
order_date

from {{source('raw','orders_data')}}

{% if is_incremental() %}
where order_date > (select max(order_date) from {{this}})
{% endif%}