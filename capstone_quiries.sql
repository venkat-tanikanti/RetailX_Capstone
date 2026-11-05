-- Select all orders placed in 2024. Show order_id, customer_id, order_date, total_amount.
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31'
ORDER BY order_date ASC;

-- List distinct payment methods and count of orders for each. Sort by count descending.
SELECT payment_method, COUNT(order_id) AS order_count
FROM orders
GROUP BY payment_method
ORDER BY order_count DESC;

-- Find all orders where discount_pct > 10 AND order_status = 'Delivered'. Use aliases for column names.
SELECT order_id AS "Order ID",
    customer_id AS "Customer ID",
    order_date AS "Date of Order",
    discount_pct AS "Discount Percentage",
    discount_amount AS "Discount Amount (INR)",
    total_amount AS "Final Invoice Amount",
    order_status AS "Status"
FROM orders
WHERE discount_pct > 10 
  AND order_status = 'Delivered'
ORDER BY order_date DESC;

-- Calculate total revenue, total orders, and average order value per product category. Join orders + products.
SELECT p.category AS "Product Category",
    SUM(o.total_amount) AS "Total Revenue",
    COUNT(o.order_id) AS "Total Orders",
    ROUND(AVG(o.total_amount), 2) AS "Average Order Value"
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY "Total Revenue" DESC;

-- Find the month-wise revenue trend for 2023 and 2024. Use date functions to extract year and month.
SELECT EXTRACT(YEAR FROM order_date) AS order_year,
       EXTRACT(MONTH FROM order_date) AS order_month,
       SUM(total_amount) AS total_revenue,
       COUNT(order_id) AS total_orders
FROM orders
WHERE EXTRACT(YEAR FROM order_date) IN (2023, 2024)
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY order_year ASC, order_month ASC;

-- Identify customers who have placed more than 5 orders. List name, tier, and order count.
SELECT c.customer_name AS "Customer Name",
    c.loyalty_tier AS "Loyalty Tier",
    COUNT(o.order_id) AS "Order Count"
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.loyalty_tier
HAVING COUNT(o.order_id) > 5
ORDER BY "Order Count" DESC, "Customer Name" ASC;

-- Write a CASE statement to label orders: 'High Value' if total_amount > 5000, 'Medium' if > 1500, else 'Low'.
SELECT order_id, customer_id, total_amount,
    CASE 
        WHEN total_amount > 5000 THEN 'High Value'
        WHEN total_amount > 1500 THEN 'Medium'
        ELSE 'Low'
    END AS value_band
FROM orders
ORDER BY total_amount DESC;

-- Find products that have never been ordered (use LEFT JOIN + NULL check or NOT IN subquery).
SELECT p.product_id AS "Product ID",
    p.product_name AS "Product Name",
    p.category AS "Category"
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- Use a window function to rank customers by total spend within each loyalty_tier. Show RANK() and DENSE_RANK().
WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name, c.loyalty_tier,
        SUM(o.total_amount) AS total_spend
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_name, c.loyalty_tier)
SELECT customer_id AS "Customer ID",
    customer_name AS "Customer Name",
    loyalty_tier AS "Loyalty Tier",
    ROUND(total_spend, 2) AS "Total Spend (₹)",
    RANK() OVER(
        PARTITION BY loyalty_tier 
        ORDER BY total_spend DESC ) AS "Spend Rank",
    DENSE_RANK() OVER(
        PARTITION BY loyalty_tier 
        ORDER BY total_spend DESC
    ) AS "Spend Dense Rank"
FROM customer_spend
ORDER BY "Loyalty Tier", "Spend Dense Rank" ASC;

-- Calculate running total of revenue ordered by order_date using SUM() OVER (ORDER BY ...).
SELECT order_id AS "Order ID",
    order_date AS "Order Date",
    total_amount AS "Order Revenue (₹)",
    SUM(total_amount) OVER (
        ORDER BY order_date ASC, order_id ASC ) AS "Running Total Revenue (₹)"
FROM orders
ORDER BY order_date ASC, order_id ASC;

-- Find the percentage contribution of each category to total revenue using a subquery or CTE.
WITH category_revenue AS (
    SELECT p.category AS product_category,
        SUM(o.total_amount) AS category_total
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY p.category
)
SELECT product_category AS "Product Category",
    ROUND(category_total, 2) AS "Category Revenue (₹)",
    ROUND((category_total / (SELECT SUM(category_total) FROM category_revenue)) * 100, 2) AS "Percentage Contribution (%)"
FROM category_revenue
ORDER BY "Percentage Contribution (%)" DESC;

-- For each customer, find the days between their first and last order (customer lifetime in days).
SELECT o.customer_id AS "Customer ID",
    c.customer_name AS "Customer Name",
    c.loyalty_tier AS "Loyalty Tier",
    MIN(o.order_date) AS "First Order Date",
    MAX(o.order_date) AS "Last Order Date",
    (MAX(o.order_date) - MIN(o.order_date)) AS "Customer Lifetime (Days)"
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name, c.loyalty_tier
ORDER BY "Customer Lifetime (Days)" DESC, "Customer Name" ASC;

-- Create a VIEW called v_order_summary that shows order_id, customer_name, product_name, category, total_amount, loyalty_tier.
CREATE OR REPLACE VIEW v_order_summary AS
SELECT o.order_id, c.customer_name, p.product_name, p.category, o.total_amount, c.loyalty_tier
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;
-- Retrieve the top 5 highest value orders with customer details
SELECT * FROM v_order_summary
ORDER BY total_amount DESC
LIMIT 5;

-- Identify and count NULL values in each column of the orders table. Write a single query.
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS unit_price_nulls,
    SUM(CASE WHEN discount_pct IS NULL THEN 1 ELSE 0 END) AS discount_pct_nulls,
    SUM(CASE WHEN discount_amount IS NULL THEN 1 ELSE 0 END) AS discount_amount_nulls,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END) AS total_amount_nulls,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_nulls,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS order_status_nulls,
    SUM(CASE WHEN delivery_days IS NULL THEN 1 ELSE 0 END) AS delivery_days_nulls,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_nulls
FROM orders;

-- For the marketing table: calculate CTR (clicks/impressions × 100), Conversion Rate (conversions/clicks × 100), and ROAS (revenue/spend). Round to 2 decimals.
SELECT campaign_id AS "Campaign ID",
    campaign_name AS "Campaign Name",
    channel AS "Channel",
    spend_inr AS "Ad Spend (₹)",
    revenue_generated AS "Revenue Generated (₹)",
    ROUND((clicks::NUMERIC / NULLIF(impressions, 0)) * 100, 2) AS "CTR (%)",
    ROUND((conversions::NUMERIC / NULLIF(clicks, 0)) * 100, 2) AS "Conversion Rate (%)",
    ROUND((revenue_generated::NUMERIC / NULLIF(spend_inr, 0)), 2) AS "ROAS"
FROM marketing
ORDER BY "ROAS" DESC;