/* 
****************************************************************************
    EDA - Exploratory Data Analysis
***************************************************************************
This script of SQL Explore and analyze the gold layer of the Data Warehourse 
to understand the data structure , dimensions, dates, key business metrics,
distributions, and performance patterns.

Analysis Covered : 
                >> Database Exploration.
                >> Dimension Exploration.
                >> Date analysis.
                >> Measure Exploration
                >> Magnitude analysis.
                >> Ranking based analysis
*/

-- *****************************************************
--			Database exploration
-- *****************************************************


-- Explore All Objects in the database 
	 SELECT * FROM INFORMATION_SCHEMA.TABLES

 -- Explore All Objects in the database 

	 SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_NAME='dim_product'

	 SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_NAME='dim_customers'

	 SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	 WHERE TABLE_NAME='fact_sales'

-- *****************************************************
--			Dimension exploration
-- *****************************************************

-- Explore all the countries our customers comes from.
	SELECT DISTINCT country FROM Gold.dim_customers

-- -- Explore all the category "The Major Divisions"
	SELECT DISTINCT category , Subcategory ,product_name FROM Gold.dim_product
	ORDER BY 1,2,3

-- *****************************************************
--			Date exploration
-- *****************************************************

-- Find the date of the first and last order 
-- How many years of sales are available
		SELECT MIN (Order_date) AS First_order,
			   MAX (Order_date) AS Last_order,
			   DATEDIFF(MONTH,MIN (Order_date),MAX (Order_date)) AS order_range_month
		FROM gold.fact_sales

-- Find the youngest and the oldest customer
		SELECT MIN(birthdate) AS oldest_customer,
			   MAX(birthdate) AS youngest_customer
		FROM Gold.dim_customers

-- *****************************************************
--			Measure exploration
-- *****************************************************

-- Find the Total Sales.
		SELECT SUM(sales_amount) AS TOTAL_SALES FROM Gold.fact_sales

-- Find how many items are sold.
		SELECT SUM(Quantity) AS total_quantity FROM gold.fact_sales
	
-- Find the average selling price.
		SELECT AVG(Price) AS average_price FROM gold.fact_sales

-- Find the total numbers of orders.
		SELECT COUNT(DISTINCT Order_number) AS Total_orders FROM gold.fact_sales

-- Find the total numbers of products.
		SELECT COUNT(product_id) AS Total_products FROM gold.dim_product
		
-- Find the total numbers of customers.
		SELECT COUNT(customer_id) AS Total_products FROM gold.dim_customers

-- Find the toatl numbers of customers that has placed an order.
		SELECT COUNT(DISTINCT customer_key) AS total_cust FROM Gold.fact_sales

-- Generating a report that shows all key metrics of the business.
		SELECT 'Total_sales' AS measure_name , SUM(sales_amount) AS measure_value FROM Gold.fact_sales
		UNION ALL 
		SELECT 'Total_quantity' AS measure_name , SUM(quantity) AS measure_value FROM Gold.fact_sales
		UNION ALL 
		SELECT 'Average_price' AS measure_name , AVG(Price) AS measure_value FROM Gold.fact_sales
		UNION ALL 
		SELECT 'Total_orders' AS measure_name , COUNT(DISTINCT Order_number) AS measure_value FROM Gold.fact_sales
		UNION ALL 
		SELECT 'Average_products' AS measure_name , COUNT(product_id) AS measure_value FROM Gold.dim_product
		UNION ALL 
		SELECT 'Total_customers' AS measure_name , COUNT(DISTINCT customer_key) AS measure_value FROM Gold.fact_sales

-- *****************************************************
--			Magnitude analysis
-- *****************************************************	

-- Find the total customers by countries.
		SELECT country , COUNT(customer_key) FROM gold.dim_customers GROUP BY country
		
-- Find the total customers by gender.
		SELECT gender , COUNT(customer_key) FROM gold.dim_customers GROUP BY gender

-- Find the total products by category.
		SELECT category , COUNT(product_key) FROM gold.dim_product GROUP BY category

-- What is the average costs in each category ?
		SELECT category , AVG(product_cost) AS Avg_cost FROM gold.dim_product
		GROUP BY category ORDER BY avg_cost DESC

-- What is the Total revenue generated for each category?
		SELECT p.category , SUM(f.sales_amount) AS Total_revenue
		FROM gold.fact_sales f 
		LEFT JOIN gold.dim_product p
		ON f.product_key=p.product_key 
		GROUP BY p.category
		ORDER BY Total_revenue DESC

-- What is the distribution of sold items across countries?	
		SELECT 
			c.country ,
			SUM(f.quantity) AS Total_quantity
		FROM gold.fact_sales f 
		LEFT JOIN gold.dim_customers c
		ON f.customer_key=c.customer_key 
		GROUP BY c.country
		ORDER BY Total_quantity DESC


-- *****************************************************
--			Ranking baseed analysis
-- *****************************************************

-- Which 5 products generate the highest revenue ? 
		SELECT TOP 5
			p.product_id,
			p.product_name,
			p.category,
			SUM(sales_amount) AS Total_revenue
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_product P
		ON f.product_key=p.product_key
		GROUP BY p.product_id,
				 p.product_name,
			     p.category
		ORDER BY Total_revenue DESC

-- Top 10 customers which  generate the highest revenue (Using window Function ) ? 
	SELECT
			customer_id,
			first_name,
			last_name,
			Total_revenue
	FROM 
		(SELECT
			c.customer_id,
			c.first_name,
			c.last_name,
			SUM(sales_amount) AS Total_revenue,
			ROW_NUMBER() OVER(ORDER BY SUM(sales_amount) DESC) AS p_rank
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_customers c
		ON f.customer_key=c.customer_key
		GROUP BY c.customer_id,
				 c.first_name,
				 c.last_name) t 
	WHERE p_rank<=10

-- Which are the 5 worst performing products in the terms of sales?
		SELECT TOP 5
			p.product_id,
			p.product_name,
			p.category,
			SUM(sales_amount) AS Total_revenue
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_product P
		ON f.product_key=p.product_key
		GROUP BY p.product_id,
				 p.product_name,
			     p.category
		ORDER BY Total_revenue











