SELECT

s.product,
p.department,
SUM(s.total_amount) AS revenue

FROM {{ ref('stg_sales') }} s

JOIN {{ ref('product_category') }} p
ON s.product = p.product

GROUP BY s.product, p.department