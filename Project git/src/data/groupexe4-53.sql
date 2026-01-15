WITH product_sales AS (
    SELECT 
        product_id,
        SUM(quantity * price_at_purchase) AS product_revenue,
        PERCENT_RANK() OVER (
			ORDER BY SUM(quantity * price_at_purchase) DESC
			) AS sales_rank
    FROM order_items
    GROUP BY product_id
)
SELECT 
    ROUND(
		(SUM(product_revenue) FILTER (WHERE sales_rank <= 0.10) / 
		NULLIF(SUM(product_revenue)), 3)
		) * 100 AS percentage_contribution
FROM product_sales;