-- ============================================
-- SQL Quest: CASE, Date Functions & Analytics
-- ============================================
-- Run create_tables.sql first.
-- Topics covered: LEFT JOIN + IS NULL (anti-join), CTE + CROSS JOIN
-- against an aggregate, GROUP BY + HAVING with COUNT(DISTINCT),
-- EXISTS with a join condition inside, CASE WHEN categorization,
-- DATEDIFF(), DATE_FORMAT() for monthly grouping, LAG() for
-- month-over-month comparison.
-- ============================================

USE sql_quest;


-- --------------------------------------------
-- 1. Customers who have never placed an order
--    (LEFT JOIN + IS NULL anti-join pattern)
-- --------------------------------------------
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE order_id IS NULL;


-- --------------------------------------------
-- 2. Customers with more orders than the average order count
--    (CTE + a second CTE for the average, joined with CROSS JOIN
--     instead of a subquery in WHERE -- same result, different style)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS total_orders
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
),
average_orders AS (
    SELECT AVG(total_orders) AS avg_orders
    FROM customer_orders
)
SELECT
    co.customer_id,
    co.customer_name,
    co.total_orders
FROM customer_orders co
CROSS JOIN average_orders ao
WHERE co.total_orders > ao.avg_orders;


-- --------------------------------------------
-- 3. Products that have never been ordered
--    (LEFT JOIN + IS NULL, same anti-join pattern as query 1)
-- --------------------------------------------
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.order_id IS NULL;


-- --------------------------------------------
-- 4. Each customer's first order, last order, and the gap between
--    them in days
--    (MIN/MAX + DATEDIFF())
-- --------------------------------------------
SELECT c.customer_id, c.customer_name,
       MIN(o.order_date) AS first_order,
       MAX(o.order_date) AS last_order,
       DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS difference
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;


-- --------------------------------------------
-- 5. Cities with 3 or more distinct customers
--    (GROUP BY + HAVING with COUNT(DISTINCT ...))
-- --------------------------------------------
SELECT city, COUNT(DISTINCT customer_id) AS customer_count
FROM customers
GROUP BY city
HAVING COUNT(DISTINCT customer_id) >= 3;


-- --------------------------------------------
-- 6. Customers who have spent more than 10,000 total
--    (basic CTE + filter)
-- --------------------------------------------
WITH total_spend AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spending
FROM total_spend
WHERE total_spending > 10000;


-- --------------------------------------------
-- 7. Customers who made at least one payment over 5,000
--    (EXISTS with a join + extra condition inside the subquery)
-- --------------------------------------------
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    WHERE o.customer_id = c.customer_id
      AND p.amount > 5000);


-- --------------------------------------------
-- 8. Categorize customers as VIP / Regular / Low Value based on
--    total spending
--    (CTE + CASE WHEN)
-- --------------------------------------------
WITH total_spend AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
),
customer_cate AS (
    SELECT customer_id, customer_name, total_spending,
           CASE
               WHEN total_spending >= 20000 THEN 'VIP'
               WHEN total_spending >= 10000 THEN 'Regular'
               ELSE 'Low Value'
           END AS customer_category
    FROM total_spend
)
SELECT customer_id, customer_name, total_spending, customer_category
FROM customer_cate;


-- --------------------------------------------
-- 9. Customers spending above the average total spend
--    (two CTEs joined with an explicit CROSS JOIN, same pattern
--     as query 2, filtered afterward in WHERE)
-- --------------------------------------------
WITH total_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spend,
           AVG(p.amount) AS avg_amt
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
),
avg_per AS (
    SELECT AVG(total_spend) AS avg_amt
    FROM total_spending
)
SELECT customer_id, customer_name, total_spend
FROM total_spending t
CROSS JOIN avg_per a
WHERE t.total_spend > a.avg_amt;


-- --------------------------------------------
-- 10. Monthly revenue and order count
--     (DATE_FORMAT() to bucket dates into 'YYYY-MM', GROUP BY the
--      formatted string)
-- --------------------------------------------
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS years_month,
    SUM(p.amount) AS total_rev,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN payments p ON o.order_id = p.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY years_month;


-- --------------------------------------------
-- 11. Month-over-month revenue change
--     (LAG() over the monthly revenue CTE, ordered by month --
--      no PARTITION BY needed here since we want to compare each
--      month against the one immediately before it, across the
--      whole table)
-- --------------------------------------------
WITH total_rev AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m') AS years_month,
        SUM(p.amount) AS total_rev
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
),
lags AS (
    SELECT
        years_month,
        total_rev,
        LAG(total_rev) OVER (
            ORDER BY years_month
        ) AS previous_rev
    FROM total_rev
)
SELECT
    years_month,
    total_rev,
    previous_rev,
    total_rev - previous_rev AS difference
FROM lags
ORDER BY years_month;
