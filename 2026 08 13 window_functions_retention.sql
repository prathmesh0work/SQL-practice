-- ============================================================
-- SQL Quest — Advanced SQL Practice
-- Session: 2026-08-13
-- Database: sql_quest
-- Topic: Window Functions, Customer Retention & Order Analysis
-- ============================================================

USE sql_quest;

-- ============================================================
-- QUESTION 1
-- Find customers who placed their second order within 30 days
-- of their first order.
--
-- Concepts:
--   * ROW_NUMBER()
--   * PARTITION BY
--   * CTEs
--   * CASE WHEN
--   * DATEDIFF()
-- ============================================================

WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date
        ) AS order_number
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
),

customer_orders AS (
    SELECT
        customer_id,
        customer_name,
        MAX(CASE
            WHEN order_number = 1 THEN order_date
        END) AS first_order_date,
        MAX(CASE
            WHEN order_number = 2 THEN order_date
        END) AS second_order_date
    FROM ranked_orders
    GROUP BY
        customer_id,
        customer_name
),

customer_retention AS (
    SELECT
        customer_id,
        customer_name,
        first_order_date,
        second_order_date,
        DATEDIFF(second_order_date, first_order_date) AS days_to_return
    FROM customer_orders
)

SELECT
    customer_id,
    customer_name,
    first_order_date,
    second_order_date,
    days_to_return
FROM customer_retention
WHERE second_order_date IS NOT NULL
  AND days_to_return <= 30
ORDER BY days_to_return, customer_id;


-- ============================================================
-- QUESTION 2
-- Calculate the customer retention rate based on whether a
-- customer placed a second order within 30 days of their first.
--
-- Output:
--   * Total customers
--   * Retained customers
--   * Retention rate (%)
--
-- Concepts:
--   * ROW_NUMBER()
--   * CTEs
--   * CASE WHEN
--   * Conditional aggregation
--   * ROUND()
-- ============================================================

WITH ranked_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date
        ) AS order_number
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
),

customer_orders AS (
    SELECT
        customer_id,
        customer_name,
        MAX(CASE
            WHEN order_number = 1 THEN order_date
        END) AS first_order_date,
        MAX(CASE
            WHEN order_number = 2 THEN order_date
        END) AS second_order_date
    FROM ranked_orders
    GROUP BY
        customer_id,
        customer_name
),

customer_retention AS (
    SELECT
        customer_id,
        customer_name,
        first_order_date,
        second_order_date,
        CASE
            WHEN second_order_date IS NOT NULL
             AND DATEDIFF(second_order_date, first_order_date) <= 30
            THEN 1
            ELSE 0
        END AS retained
    FROM customer_orders
)

SELECT
    COUNT(*) AS total_customers,
    SUM(retained) AS retained_customers,
    ROUND(
        SUM(retained) * 100.0 / COUNT(*),
        2
    ) AS retention_rate
FROM customer_retention;


-- ============================================================
-- QUESTION 3
-- Find customers who have placed at least 4 orders and whose
-- average number of days between orders is 30 days or less.
--
-- Concepts:
--   * LAG()
--   * PARTITION BY
--   * CTEs
--   * DATEDIFF()
--   * AVG()
--   * COUNT()
--   * HAVING / WHERE
-- ============================================================

WITH order_history AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date
        ) AS previous_order_date
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
),

customer_history AS (
    SELECT
        customer_id,
        customer_name,
        order_date,
        previous_order_date,
        DATEDIFF(order_date, previous_order_date) AS days_between_orders
    FROM order_history
),

customer_summary AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(days_between_orders) + 1 AS total_orders,
        ROUND(AVG(days_between_orders), 2) AS avg_days_between_orders
    FROM customer_history
    GROUP BY
        customer_id,
        customer_name
)

SELECT
    customer_id,
    customer_name,
    total_orders,
    avg_days_between_orders
FROM customer_summary
WHERE total_orders >= 4
  AND avg_days_between_orders <= 30
ORDER BY avg_days_between_orders, customer_id;


-- ============================================================
-- END OF SESSION
-- ============================================================
