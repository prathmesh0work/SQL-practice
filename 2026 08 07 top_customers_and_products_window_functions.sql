-- ============================================================
-- SQL Quest — Daily Session: 2026-08-07
-- Topics: CTEs, Window Functions (RANK, ROW_NUMBER, LAG), Subqueries
-- Schema: sql_quest (customers, orders, payments, order_items, products)
-- ============================================================

USE sql_quest;

-- --------------------------------------------------------------
-- 1. Top 2 highest-spending customers per city
--    (RANK, so ties share a rank within the same city)
-- --------------------------------------------------------------
WITH total_spending AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        SUM(p.amount) AS total_spend
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city
),

ranking AS (
    SELECT
        customer_id,
        customer_name,
        city,
        total_spend,
        RANK() OVER (
            PARTITION BY city
            ORDER BY total_spend DESC
        ) AS city_rank
    FROM total_spending
)

SELECT
    customer_id,
    customer_name,
    city,
    city_rank,
    total_spend
FROM ranking
WHERE city_rank <= 2;


-- --------------------------------------------------------------
-- 2. Customers with a consistently non-decreasing spend pattern
--    (LAG to compare each order's amount against the previous one;
--     flag as a "violation" whenever spend drops)
-- --------------------------------------------------------------
WITH total_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.order_date,
        p.amount
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
),

cust_history AS (
    SELECT
        customer_id,
        customer_name,
        amount,
        order_date,
        LAG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_amt
    FROM total_orders
),

customer_consistency AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(*) AS total_orders,
        SUM(
            CASE
                WHEN previous_amt IS NOT NULL
                     AND amount < previous_amt
                THEN 1
                ELSE 0
            END
        ) AS violation
    FROM cust_history
    GROUP BY
        customer_id,
        customer_name
)

SELECT
    customer_id,
    customer_name,
    total_orders
FROM customer_consistency
WHERE violation = 0
ORDER BY total_orders DESC, customer_name;


-- --------------------------------------------------------------
-- 3. Top customer per city by spend/orders/loyalty
--    (min. 3 orders; ROW_NUMBER with a 3-key tiebreaker)
-- --------------------------------------------------------------
WITH customer_summary AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        COUNT(o.order_id) AS total_orders,
        SUM(p.amount) AS total_spending,
        MIN(o.order_date) AS first_order_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        c.city
    HAVING COUNT(o.order_id) >= 3
),

city_winners AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY
                total_spending DESC,
                total_orders DESC,
                first_order_date ASC
        ) AS rn
    FROM customer_summary
)

SELECT
    customer_id,
    customer_name,
    city,
    total_orders,
    total_spending,
    first_order_date
FROM city_winners
WHERE rn = 1
ORDER BY city;


-- --------------------------------------------------------------
-- 4. Each customer's #1 most-purchased product
--    (ROW_NUMBER with quantity/spend/recency tiebreaker)
-- --------------------------------------------------------------
WITH orders_summ AS (
    SELECT
        c.customer_id,
        c.customer_name,
        pr.product_name,
        SUM(oi.quantity) AS total_orders,
        SUM(p.amount) AS total_spend,
        MIN(o.order_date) AS first_purchased_date
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
    JOIN order_items oi
        ON p.order_id = oi.order_id
    JOIN products pr
        ON oi.product_id = pr.product_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        pr.product_name
),

ranking AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY
                total_orders DESC,
                total_spend DESC,
                first_purchased_date ASC
        ) AS product_rank
    FROM orders_summ
)

SELECT
    customer_id,
    customer_name,
    product_name,
    total_orders,
    total_spend,
    first_purchased_date
FROM ranking
WHERE product_rank = 1;


-- --------------------------------------------------------------
-- 5. Second-highest payment amount
--    (correlated-style subquery: max amount strictly less than the max)
-- --------------------------------------------------------------
SELECT MAX(amount) AS second_highest_amount
FROM payments
WHERE amount < (SELECT MAX(amount) FROM payments);
