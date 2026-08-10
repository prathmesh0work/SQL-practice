-- ============================================
-- SQL Quest: Advanced Window Functions
-- ============================================
-- Run create_tables.sql first.
-- Topics covered: FIRST_VALUE, LAST_VALUE, NTH_VALUE (with frame clause),
-- NTILE, CUME_DIST, PERCENT_RANK, and combining RANK/DENSE_RANK/LAG
-- across two joined CTEs.
-- ============================================

USE sql_quest;


-- --------------------------------------------
-- 1. Each order's amount next to that customer's first order amount
--    (FIRST_VALUE() OVER (PARTITION BY ... ORDER BY ...))
-- --------------------------------------------
WITH customer_orders AS (
    SELECT o.customer_id, o.order_date, p.amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
)
SELECT customer_id, order_date, amount,
       FIRST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
       ) AS first_order_amount
FROM customer_orders;


-- --------------------------------------------
-- 2. Difference between each order and that customer's first order
--    (FIRST_VALUE() used in an arithmetic expression)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT o.customer_id, o.order_date, p.amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
)
SELECT customer_id, order_date, amount,
       FIRST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
       ) AS first_order_amount,
       amount - FIRST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
       ) AS difference
FROM customer_orders;


-- --------------------------------------------
-- 3. Each order's amount next to that customer's latest order amount
--    (LAST_VALUE() needs an explicit frame -- ROWS BETWEEN UNBOUNDED
--     PRECEDING AND UNBOUNDED FOLLOWING -- or it only looks at rows
--     up to the current one and gives the wrong answer)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT o.customer_id, o.order_date, p.amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
)
SELECT customer_id, order_date, amount,
       LAST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS latest_order_amount
FROM customer_orders;


-- --------------------------------------------
-- 4. First order, last order, and the change between them, per customer
--    (FIRST_VALUE + LAST_VALUE combined)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT o.customer_id, o.order_date, p.amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
)
SELECT customer_id, order_date, amount,
       FIRST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
       ) AS first,
       LAST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS last,
       LAST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) - FIRST_VALUE(amount) OVER (
           PARTITION BY customer_id ORDER BY order_date
       ) AS change
FROM customer_orders;


-- --------------------------------------------
-- 5. Each customer's second order amount
--    (NTH_VALUE(amount, 2) -- also needs the full frame clause)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT o.customer_id, o.order_date, p.amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
)
SELECT customer_id, order_date, amount,
       NTH_VALUE(amount, 2) OVER (
           PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS second_order_amount
FROM customer_orders;


-- --------------------------------------------
-- 6. Each customer's third order amount, and the difference between
--    the current order and that third order
--    (NTH_VALUE(amount, 3) used in an arithmetic expression)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT o.customer_id, o.order_date, p.amount
    FROM orders o
    JOIN payments p ON o.order_id = p.order_id
)
SELECT customer_id, order_date, amount,
       NTH_VALUE(amount, 3) OVER (
           PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS third_order_amount,
       amount - NTH_VALUE(amount, 3) OVER (
           PARTITION BY customer_id ORDER BY order_date
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS diff_from_third_amount
FROM customer_orders;


-- --------------------------------------------
-- 7. Split customers into 4 spending quartiles
--    (NTILE(4) OVER (ORDER BY ...))
-- --------------------------------------------
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spending,
       NTILE(4) OVER (ORDER BY total_spending DESC) AS spending_quartiles
FROM customer_spending;


-- --------------------------------------------
-- 8. Same idea, but only for customers with more than 1 order, split
--    into 3 groups instead of 4, with order count joined in
--    (NTILE combined with two CTEs + a WHERE filter)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT c.customer_id,
           COUNT(order_id) AS total_orders
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
),
customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT co.customer_id, cs.customer_name,
       co.total_orders, cs.total_spending,
       NTILE(3) OVER (ORDER BY total_spending DESC) AS spending_quartiles
FROM customer_orders co
JOIN customer_spending cs ON co.customer_id = cs.customer_id
WHERE total_orders > 1;


-- --------------------------------------------
-- 9. Cumulative distribution of customer spending, as a percentage
--    (CUME_DIST() -- proportion of rows with a value <= the current row's)
-- --------------------------------------------
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spending,
       CUME_DIST() OVER (ORDER BY total_spending DESC) * 100 AS cumm_dist
FROM customer_spending;


-- --------------------------------------------
-- 10. Customers in the top 20% by cumulative spending distribution
--     (CUME_DIST() wrapped in a CTE so the result can be filtered)
-- --------------------------------------------
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
),
cumm_dist AS (
    SELECT customer_id, customer_name, total_spending,
           CUME_DIST() OVER (ORDER BY total_spending DESC) * 100 AS cummulative_dist
    FROM customer_spending
)
SELECT customer_id, customer_name, total_spending, cummulative_dist
FROM cumm_dist
WHERE cummulative_dist > 20;


-- --------------------------------------------
-- 11. Spending percentile rank for each customer
--     (PERCENT_RANK() -- relative rank as a fraction from 0 to 1)
-- --------------------------------------------
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, total_spending,
       PERCENT_RANK() OVER (ORDER BY total_spending DESC) AS spending_percentile
FROM customer_spending;


-- --------------------------------------------
-- 12. Top 25% of customers by spending percentile
--     (PERCENT_RANK() wrapped in a CTE, then filtered)
-- --------------------------------------------
WITH customer_spending AS (
    SELECT c.customer_id, c.customer_name,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
),
percent_ran AS (
    SELECT customer_id, customer_name, total_spending,
           PERCENT_RANK() OVER (ORDER BY total_spending DESC) AS spending_percentile
    FROM customer_spending
)
SELECT customer_id, customer_name, total_spending, spending_percentile
FROM percent_ran
WHERE spending_percentile <= 0.25;


-- --------------------------------------------
-- 13. Full customer report: overall spending rank, rank within city,
--     and the gap to the next-highest spender overall
--     (RANK + DENSE_RANK + LAG combined across two CTEs joined together)
-- --------------------------------------------
WITH customer_orders_spending AS (
    SELECT c.customer_id, c.customer_name, c.city,
           COUNT(o.order_id) AS total_orders,
           SUM(p.amount) AS total_spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name, c.city
),
cte AS (
    SELECT customer_id, customer_name, city, total_orders, total_spend,
           RANK() OVER (ORDER BY total_spend DESC) AS spending_rank,
           DENSE_RANK() OVER (
               PARTITION BY city ORDER BY total_spend DESC
           ) AS city_rank,
           LAG(total_spend) OVER (ORDER BY total_spend DESC) AS previous_amount
    FROM customer_orders_spending
)
SELECT co.customer_id, co.customer_name, co.city,
       co.total_orders, co.total_spend,
       ct.spending_rank, ct.city_rank, ct.previous_amount,
       co.total_spend - ct.previous_amount AS diff
FROM customer_orders_spending co
JOIN cte ct ON co.customer_id = ct.customer_id;
