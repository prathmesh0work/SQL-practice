-- ============================================
-- SQL Quest: Self-Joins & Advanced Analytics
-- ============================================
-- Run create_tables.sql first.
-- Topics covered: COALESCE + NULLIF for null-safe averages, HAVING
-- with multiple conditions, self-joins (finding related rows within
-- the same table), RANK() partitioned by category for top-N-per-group,
-- multi-CTE retention analysis combining LAG(), ROW_NUMBER(),
-- DATEDIFF(), and CROSS JOIN against an aggregate.
-- ============================================

USE sql_quest;


-- --------------------------------------------
-- 1. Average order value per customer, including customers with
--    zero orders
--    (LEFT JOIN twice to keep customers with no orders/payments,
--     COALESCE to turn a NULL sum into 0, NULLIF to avoid dividing
--     by zero for customers with no orders)
-- --------------------------------------------
WITH total_spending AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(p.amount), 0) AS total_spending,
           COUNT(o.order_id) AS total_orders
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name,
       ROUND(total_spending / NULLIF(total_orders, 0), 2) AS avg_total_value
FROM total_spending;


-- --------------------------------------------
-- 2. Customers with 2+ orders AND total spending over 10,000
--    (HAVING with two conditions combined by AND)
-- --------------------------------------------
SELECT c.customer_id, c.customer_name,
       COUNT(o.order_id) AS total_orders,
       SUM(p.amount) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) >= 2
   AND SUM(p.amount) > 10000;


-- --------------------------------------------
-- 3. Pairs of customers who placed an order on the same date
--    (self-join on orders -- o1.customer_id < o2.customer_id avoids
--     matching a customer with themselves and avoids listing each
--     pair twice in reverse order)
-- --------------------------------------------
SELECT
    c1.customer_id AS customer1_id,
    c1.customer_name AS customer1_name,
    c2.customer_id AS customer2_id,
    c2.customer_name AS customer2_name,
    o1.order_date
FROM orders o1
JOIN orders o2
    ON o1.order_date = o2.order_date
   AND o1.customer_id < o2.customer_id
JOIN customers c1 ON o1.customer_id = c1.customer_id
JOIN customers c2 ON o2.customer_id = c2.customer_id;


-- --------------------------------------------
-- 4. Number of distinct products each customer has ordered
--    (multi-table JOIN + COUNT(DISTINCT ...))
-- --------------------------------------------
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT oi.product_id) AS unique_products
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name;


-- --------------------------------------------
-- 5. Best-selling product in each category (top-1-per-group pattern)
--    (RANK() partitioned by category, wrapped in a CTE so the rank
--     can be filtered to 1 -- window functions can't go in WHERE)
-- --------------------------------------------
WITH top_prod AS (
    SELECT p.product_id, p.category_id, p.product_name,
           SUM(o.quantity) AS total_quantity,
           RANK() OVER (
               PARTITION BY p.category_id
               ORDER BY SUM(o.quantity) DESC
           ) AS top_product
    FROM products p
    JOIN order_items o ON p.product_id = o.product_id
    GROUP BY p.product_id, p.category_id, p.product_name
)
SELECT product_id, product_name, category_id, total_quantity
FROM top_prod
WHERE top_product = 1
ORDER BY category_id;


-- --------------------------------------------
-- 6. Customers who might be re-engaging: 3+ orders, above-average
--    total spend, and their last two orders were within 30 days
--    of each other
--    (five chained CTEs: raw order/payment rows -> per-row previous
--     order date via LAG() -> just the most recent order's "previous
--     date" via ROW_NUMBER() -> per-customer totals -> overall
--     average, all combined in the final SELECT)
-- --------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.order_date,
        p.amount
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
),
customer_history AS (
    SELECT
        customer_id,
        customer_name,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_date
    FROM customer_orders
),
customer_summary AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(*) AS total_orders,
        SUM(amount) AS total_spending,
        MAX(order_date) AS latest_order_date
    FROM customer_orders
    GROUP BY customer_id, customer_name
),
latest_order_history AS (
    -- pulls the previous_order_date that belongs specifically to each
    -- customer's most recent order (rn = 1 after ordering by date DESC)
    SELECT customer_id, previous_order_date
    FROM (
        SELECT
            customer_id,
            order_date,
            previous_order_date,
            ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY order_date DESC
            ) AS rn
        FROM customer_history
    ) x
    WHERE rn = 1
),
average_spending AS (
    SELECT AVG(total_spending) AS avg_spending
    FROM customer_summary
)
SELECT
    cs.customer_id,
    cs.customer_name,
    cs.total_orders,
    cs.total_spending,
    cs.latest_order_date,
    lh.previous_order_date,
    DATEDIFF(cs.latest_order_date, lh.previous_order_date) AS days_between_orders
FROM customer_summary cs
JOIN latest_order_history lh ON cs.customer_id = lh.customer_id
CROSS JOIN average_spending av
WHERE cs.total_orders >= 3
  AND cs.total_spending > av.avg_spending
  AND DATEDIFF(cs.latest_order_date, lh.previous_order_date) <= 30;


-- --------------------------------------------
-- 7. Each customer's most expensive product by total spending, for
--    customers who've bought 3+ unique products and have at least
--    one product over 3,000 in spending
--    (chained CTEs + RANK() to pick the top product per customer)
--
--    NOTE ON DATA ACCURACY: the `cust` CTE joins each order line
--    item to the order's full PAYMENT amount (not to
--    quantity * price for that specific item). If an order contains
--    more than one line item, that order's whole payment amount gets
--    attached to every item in it -- so `product_spending` (a SUM of
--    `amount` per product) overstates real per-product spending for
--    any customer with multi-item orders. For an accurate per-product
--    spend, replace `p.amount` with `oi.quantity * pr.price` in the
--    `cust` CTE and drop the join to `payments` entirely.
-- --------------------------------------------
WITH cust AS (
    SELECT c.customer_id,
           c.customer_name,
           pr.product_name,
           p.amount,
           pr.price,
           pr.category_id
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    JOIN order_items oi ON p.order_id = oi.order_id
    JOIN products pr ON oi.product_id = pr.product_id
),
product_spending AS (
    SELECT customer_id, customer_name, product_name,
           SUM(amount) AS product_spending
    FROM cust
    GROUP BY customer_id, customer_name, product_name
),
product_rank AS (
    SELECT customer_id, customer_name, product_name, product_spending,
           RANK() OVER (
               PARTITION BY customer_id
               ORDER BY product_spending DESC
           ) AS top_product
    FROM product_spending
),
customer_summ AS (
    SELECT customer_id, customer_name,
           COUNT(*) AS unique_products,
           MAX(product_spending) AS max_product_spending
    FROM product_spending
    GROUP BY customer_id, customer_name
)
SELECT cs.customer_id,
       cs.customer_name,
       cs.unique_products,
       cs.max_product_spending,
       pr.product_name AS most_expensive_product
FROM customer_summ cs
JOIN product_rank pr
    ON cs.customer_id = pr.customer_id
   AND pr.top_product = 1
WHERE cs.unique_products >= 3
  AND cs.max_product_spending > 3000;
