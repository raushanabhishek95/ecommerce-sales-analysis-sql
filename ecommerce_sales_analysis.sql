/* ============================================================
   E-COMMERCE SALES ANALYSIS USING SQL
   ============================================================
   
   Project: E-Commerce Sales Analysis
   Database: EcommerceDB
   SQL Dialect: MySQL

   Tables:
   1. customers
   2. orders
   3. order_items
   4. products

   Analysis Areas:
   - Sales Performance
   - Product Analysis
   - Category Analysis
   - Customer Analysis
   - Time-Based Analysis
   - Revenue Analysis
   - Advanced SQL Analysis
   ============================================================ */


/* ============================================================
   01. DATABASE SETUP
   ============================================================ */

CREATE DATABASE IF NOT EXISTS EcommerceDB;

USE EcommerceDB;


/* ============================================================
   02. VIEW DATABASE TABLES
   ============================================================ */

SHOW TABLES;


/* View sample records */

SELECT *
FROM customers
LIMIT 10;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM order_items
LIMIT 10;

SELECT *
FROM products
LIMIT 10;


/* ============================================================
   03. DATASET OVERVIEW
   ============================================================ */


/* Total number of customers */

SELECT 
    COUNT(DISTINCT customer_id) AS total_customers
FROM customers;


/* Total number of orders */

SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;


/* Total number of products */

SELECT 
    COUNT(DISTINCT product_id) AS total_products
FROM products;


/* Total number of order items */

SELECT 
    COUNT(*) AS total_order_items
FROM order_items;


/* ============================================================
   04. TOTAL REVENUE
   ============================================================ */

/*
Revenue is calculated as:

Quantity × Product Price
*/

SELECT 
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id;


/* ============================================================
   05. AVERAGE ORDER VALUE
   ============================================================ */

SELECT 
    ROUND(
        SUM(oi.quantity * p.price) 
        / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id;


/* ============================================================
   06. TOP-SELLING PRODUCTS
   ============================================================ */

/* Top 10 products by quantity sold */

SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    p.product_id,
    p.product_name
ORDER BY 
    total_quantity_sold DESC
LIMIT 10;


/* ============================================================
   07. TOP PRODUCTS BY REVENUE
   ============================================================ */

SELECT 
    p.product_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    p.product_id,
    p.product_name
ORDER BY 
    total_revenue DESC
LIMIT 10;


/* ============================================================
   08. REVENUE BY CATEGORY
   ============================================================ */

SELECT 
    p.category,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    p.category
ORDER BY 
    total_revenue DESC;


/* ============================================================
   09. SALES QUANTITY BY CATEGORY
   ============================================================ */

SELECT 
    p.category,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    p.category
ORDER BY 
    total_quantity_sold DESC;


/* ============================================================
   10. TOP 5 CUSTOMERS BY REVENUE
   ============================================================ */

SELECT 
    c.customer_id,
    c.name AS customer_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    c.customer_id,
    c.name
ORDER BY 
    total_revenue DESC
LIMIT 5;


/* ============================================================
   11. CUSTOMER ORDER ANALYSIS
   ============================================================ */

SELECT 
    c.customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id,
    c.name
ORDER BY 
    total_orders DESC;


/* ============================================================
   12. ORDERS BY HOUR
   ============================================================ */

SELECT 
    HOUR(order_time) AS order_hour,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY 
    HOUR(order_time)
ORDER BY 
    order_hour;


/* ============================================================
   13. DAILY REVENUE
   ============================================================ */

SELECT 
    o.order_date,
    ROUND(SUM(oi.quantity * p.price), 2) AS daily_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    o.order_date
ORDER BY 
    o.order_date;


/* ============================================================
   14. MONTHLY REVENUE
   ============================================================ */

SELECT 
    YEAR(o.order_date) AS order_year,
    MONTH(o.order_date) AS order_month,
    ROUND(SUM(oi.quantity * p.price), 2) AS monthly_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    YEAR(o.order_date),
    MONTH(o.order_date)
ORDER BY 
    order_year,
    order_month;


/* ============================================================
   15. TOP 5 REVENUE-GENERATING DAYS
   ============================================================ */

SELECT 
    o.order_date,
    ROUND(SUM(oi.quantity * p.price), 2) AS daily_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY 
    o.order_date
ORDER BY 
    daily_revenue DESC
LIMIT 5;


/* ============================================================
   16. CUMULATIVE REVENUE
   ============================================================ */

WITH daily_sales AS (

    SELECT 
        o.order_date,
        SUM(oi.quantity * p.price) AS daily_revenue

    FROM orders AS o

    JOIN order_items AS oi
        ON o.order_id = oi.order_id

    JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY 
        o.order_date
)

SELECT 
    order_date,
    ROUND(daily_revenue, 2) AS daily_revenue,

    ROUND(
        SUM(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_revenue

FROM daily_sales

ORDER BY 
    order_date;


/* ============================================================
   17. TOP PRODUCT IN EACH CATEGORY
   ============================================================ */

WITH product_sales AS (

    SELECT 
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS total_quantity_sold

    FROM products AS p

    JOIN order_items AS oi
        ON p.product_id = oi.product_id

    GROUP BY 
        p.category,
        p.product_id,
        p.product_name
),

ranked_products AS (

    SELECT 
        category,
        product_id,
        product_name,
        total_quantity_sold,

        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_quantity_sold DESC
        ) AS product_rank

    FROM product_sales
)

SELECT 
    category,
    product_name,
    total_quantity_sold,
    product_rank

FROM ranked_products

WHERE product_rank <= 3

ORDER BY 
    category,
    product_rank;


/* ============================================================
   18. TOP 5 CUSTOMERS BY REVENUE WITH RANKING
   ============================================================ */

WITH customer_revenue AS (

    SELECT 
        c.customer_id,
        c.name AS customer_name,
        SUM(oi.quantity * p.price) AS total_revenue

    FROM customers AS c

    JOIN orders AS o
        ON c.customer_id = o.customer_id

    JOIN order_items AS oi
        ON o.order_id = oi.order_id

    JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY 
        c.customer_id,
        c.name
)

SELECT 
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue,

    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank

FROM customer_revenue

ORDER BY 
    revenue_rank

LIMIT 5;


/* ============================================================
   19. REVENUE CONTRIBUTION BY CATEGORY
   ============================================================ */

WITH category_revenue AS (

    SELECT 
        p.category,
        SUM(oi.quantity * p.price) AS category_revenue

    FROM order_items AS oi

    JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY 
        p.category
)

SELECT 
    category,

    ROUND(category_revenue, 2) AS category_revenue,

    ROUND(
        category_revenue * 100.0 /
        SUM(category_revenue) OVER (),
        2
    ) AS revenue_percentage

FROM category_revenue

ORDER BY 
    category_revenue DESC;


/* ============================================================
   20. REVENUE BY CUSTOMER
   ============================================================ */

SELECT 
    c.customer_id,
    c.name AS customer_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS total_revenue

FROM customers AS c

JOIN orders AS o
    ON c.customer_id = o.customer_id

JOIN order_items AS oi
    ON o.order_id = oi.order_id

JOIN products AS p
    ON oi.product_id = p.product_id

GROUP BY 
    c.customer_id,
    c.name

ORDER BY 
    total_revenue DESC;


/* ============================================================
   21. PRODUCTS WITH NO SALES
   ============================================================ */

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price

FROM products AS p

LEFT JOIN order_items AS oi
    ON p.product_id = oi.product_id

WHERE oi.product_id IS NULL;


/* ============================================================
   22. AVERAGE PRODUCT PRICE BY CATEGORY
   ============================================================ */

SELECT 
    category,
    ROUND(AVG(price), 2) AS average_product_price,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price

FROM products

GROUP BY 
    category

ORDER BY 
    average_product_price DESC;


/* ============================================================
   23. ORDER VALUE ANALYSIS
   ============================================================ */

WITH order_value AS (

    SELECT 
        oi.order_id,
        SUM(oi.quantity * p.price) AS order_value

    FROM order_items AS oi

    JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY 
        oi.order_id
)

SELECT 
    ROUND(AVG(order_value), 2) AS average_order_value,
    ROUND(MIN(order_value), 2) AS minimum_order_value,
    ROUND(MAX(order_value), 2) AS maximum_order_value

FROM order_value;


/* ============================================================
   24. CUSTOMER SEGMENTATION
   ============================================================ */

WITH customer_spending AS (

    SELECT 
        c.customer_id,
        c.name AS customer_name,
        SUM(oi.quantity * p.price) AS total_spending

    FROM customers AS c

    JOIN orders AS o
        ON c.customer_id = o.customer_id

    JOIN order_items AS oi
        ON o.order_id = oi.order_id

    JOIN products AS p
        ON oi.product_id = p.product_id

    GROUP BY 
        c.customer_id,
        c.name
)

SELECT 
    customer_id,
    customer_name,
    ROUND(total_spending, 2) AS total_spending,

    CASE
        WHEN total_spending >= 10000 THEN 'High Value Customer'
        WHEN total_spending >= 5000 THEN 'Medium Value Customer'
        ELSE 'Low Value Customer'
    END AS customer_segment

FROM customer_spending

ORDER BY 
    total_spending DESC;


/* ============================================================
   25. FINAL BUSINESS SUMMARY
   ============================================================ */

SELECT

    /* Total Customers */
    (
        SELECT COUNT(DISTINCT customer_id)
        FROM customers
    ) AS total_customers,

    /* Total Orders */
    (
        SELECT COUNT(DISTINCT order_id)
        FROM orders
    ) AS total_orders,

    /* Total Products */
    (
        SELECT COUNT(DISTINCT product_id)
        FROM products
    ) AS total_products,

    /* Total Revenue */
    (
        SELECT ROUND(SUM(oi.quantity * p.price), 2)
        FROM order_items AS oi
        JOIN products AS p
            ON oi.product_id = p.product_id
    ) AS total_revenue;