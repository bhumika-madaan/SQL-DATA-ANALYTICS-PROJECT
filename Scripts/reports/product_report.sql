/*
*************************************************************************
	Product Report 
*************************************************************************
This report consolidates key product metrics and behaviors.

		>> Gathers essential fields such as product name, category, subcategory, and cost.
		>> Segments product by revenue to identify High-Performers, Mid_Range, or Low-Performers.
		>> Aggregates product-level metrics :
			- total order 
			- total sales
			- total quantity sold
			- total customers (unique)
			- lifespan (in months)
		>> Calculates valuable KPIs :
			- recency (months since last order)
			- average order value
			- averae month revenue

********************************************************************************
*/

CREATE VIEW gold.product_report AS
WITH base_query AS 
(
SELECT 
	f.Order_number,
	f.customer_key,
	f.order_date,
	f.Quantity,
	f.price,
	f.sales_amount,
	p.product_key,
	p.product_number,
	p.category,
	p.Subcategory,
	p.product_cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_product p
ON f.product_key=p.product_key
WHERE Order_date IS NOT NULL 
),
product_report AS
(
SELECT
	product_key,
	product_number,
	category,
	Subcategory,
	product_cost,
	DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan,
	COUNT(DISTINCT Order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT customer_key) AS total_customers,
	MAX(order_date) AS last_sale_date,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(Quantity,0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
   	product_number,
	category,
	Subcategory,
	product_cost
)


SELECT 
	product_key,
	product_number,
	category,
	Subcategory,
	product_cost,
	lifespan,
	total_orders,
	total_sales,
	CASE WHEN total_sales > 1000000 THEN 'HIGH-PERFORMERS'
		 WHEN total_sales BETWEEN 100000 AND 1000000 THEN 'MID-RANGE'
		 WHEN total_sales < 100000 THEN 'LOW-PERFORMERS'
	END AS product_segmentation,
	DATEDIFF(MONTH,last_sale_date,GETDATE()) AS recency,
	total_quantity,
	total_customers,
	last_sale_date,
	avg_selling_price,
	CASE WHEN total_orders=0 THEN 0
		 ELSE total_sales/total_orders
	END AS avg_order_revenue,
	CASE WHEN lifespan=0 THEN total_sales/1
		 ELSE total_sales/lifespan
	END AS avg_monthly_revenue

FROM product_report


