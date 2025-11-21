-- =========================================
-- 1. TABLE STRUCTURE FOR RAW SALES DATA
-- =========================================

CREATE TABLE ecommerce_orders (
    order_id        INT,
    order_date      DATE,
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    city            VARCHAR(100),
    state           VARCHAR(100),
    country         VARCHAR(100),
    product_id      VARCHAR(20),
    product_name    VARCHAR(200),
    category        VARCHAR(100),
    sub_category    VARCHAR(100),
    unit_price      DECIMAL(10,2),
    quantity        INT,
    discount        DECIMAL(5,2),
    payment_method  VARCHAR(50),
    order_status    VARCHAR(50)
);

-- Note:
-- Adjust data types (INT/VARCHAR/DECIMAL) based on the database you use
-- (MySQL / PostgreSQL / SQL Server etc.)

-- =========================================
-- 2. BASIC DATA QUALITY CHECKS
-- =========================================

-- Total rows
SELECT COUNT(*) AS total_rows
FROM ecommerce_orders;

-- Check for missing critical fields
SELECT *
FROM ecommerce_orders
WHERE order_id IS NULL
   OR product_id IS NULL;

-- Distinct order statuses
SELECT DISTINCT order_status
FROM ecommerce_orders;

-- =========================================
-- 3. CORE SALES METRICS
-- =========================================

-- Total gross, discount, and net revenue
SELECT
    SUM(unit_price * quantity)                         AS gross_revenue,
    SUM(unit_price * quantity * discount)              AS discount_amount,
    SUM(unit_price * quantity * (1 - discount))        AS net_revenue
FROM ecommerce_orders;

-- Number of unique orders and customers
SELECT
    COUNT(DISTINCT order_id)     AS total_orders,
    COUNT(DISTINCT customer_id)  AS total_customers
FROM ecommerce_orders;

-- =========================================
-- 4. SALES BY CITY / STATE / COUNTRY
-- =========================================

-- Net revenue by city
SELECT
    city,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue
FROM ecommerce_orders
GROUP BY city
ORDER BY net_revenue DESC;

-- Net revenue by state
SELECT
    state,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue
FROM ecommerce_orders
GROUP BY state
ORDER BY net_revenue DESC;

-- Net revenue by country
SELECT
    country,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue
FROM ecommerce_orders
GROUP BY country
ORDER BY net_revenue DESC;

-- =========================================
-- 5. SALES BY CATEGORY / SUB-CATEGORY
-- =========================================

-- Category performance
SELECT
    category,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue,
    COUNT(DISTINCT order_id)                    AS total_orders
FROM ecommerce_orders
GROUP BY category
ORDER BY net_revenue DESC;

-- Sub-category performance
SELECT
    category,
    sub_category,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue,
    COUNT(DISTINCT order_id)                    AS total_orders
FROM ecommerce_orders
GROUP BY category, sub_category
ORDER BY net_revenue DESC;

-- =========================================
-- 6. PAYMENT METHOD & ORDER STATUS ANALYSIS
-- =========================================

-- Revenue by payment method
SELECT
    payment_method,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue,
    COUNT(DISTINCT order_id)                    AS total_orders
FROM ecommerce_orders
GROUP BY payment_method
ORDER BY net_revenue DESC;

-- Order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM ecommerce_orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Return rate
SELECT
    COUNT(CASE WHEN order_status = 'Returned' THEN 1 END) * 1.0
        / COUNT(*) AS return_rate
FROM ecommerce_orders;

-- =========================================
-- 7. TIME-BASED ANALYSIS (MONTHLY / DAILY)
-- =========================================

-- Sales by order date
SELECT
    order_date,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue
FROM ecommerce_orders
GROUP BY order_date
ORDER BY order_date;

-- Sales by month (YYYY-MM)
-- Note: Syntax may vary by database (DATE_FORMAT, TO_CHAR, etc.)

-- MySQL style:
-- SELECT
--     DATE_FORMAT(order_date, '%Y-%m') AS order_month,
--     SUM(unit_price * quantity * (1 - discount)) AS net_revenue
-- FROM ecommerce_orders
-- GROUP BY DATE_FORMAT(order_date, '%Y-%m')
-- ORDER BY order_month;

-- PostgreSQL style:
-- SELECT
--     TO_CHAR(order_date, 'YYYY-MM') AS order_month,
--     SUM(unit_price * quantity * (1 - discount)) AS net_revenue
-- FROM ecommerce_orders
-- GROUP BY TO_CHAR(order_date, 'YYYY-MM')
-- ORDER BY order_month;

-- =========================================
-- 8. TOP CUSTOMERS & PRODUCTS
-- =========================================

-- Top customers by net revenue
SELECT
    customer_id,
    customer_name,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue,
    COUNT(DISTINCT order_id)                    AS total_orders
FROM ecommerce_orders
GROUP BY customer_id, customer_name
ORDER BY net_revenue DESC
LIMIT 10;

-- Top products by net revenue
SELECT
    product_id,
    product_name,
    SUM(unit_price * quantity * (1 - discount)) AS net_revenue,
    SUM(quantity)                                AS total_quantity
FROM ecommerce_orders
GROUP BY product_id, product_name
ORDER BY net_revenue DESC
LIMIT 10;
