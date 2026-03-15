select 

order_id,
product,
{{revenue('quantity','price')}} as total_amount

from {{ ref('stg_sales')}}