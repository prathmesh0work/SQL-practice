-- ============================================
-- SQL Quest: Spend Trends & Concentration Analysis
-- ============================================
-- Run create_tables.sql first.
-- Topics covered: LAG() to detect a spending increase on a
-- customer's most recent order, comparing three consecutive order
-- amounts, AVG() OVER() vs. per-customer totals, DENSE_RANK() for
-- spending position, and revenue concentration analysis (what % of
-- a customer's spend comes from their single biggest product /
-- category).
-- ============================================

USE sql_quest;


-- --------------------------------------------
-- 1. Customers whose most recent order was bigger than the one
--    before it
--    (LAG() ordered ASC to get each order's previous amount, then a
--     separate ROW_NUMBER() ordered DESC to isolate just the latest
--     order row -- two different orderings on the same partition,
--     each doing its own job)
-- --------------------------------------------
WITH customer_order AS (
    SELECT c.customer_id,
           c.customer_name,
           o.order_date,
           p.amount
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
),
lags AS (
    SELECT customer_id,
           customer_name,
           amount,
           LAG(amount) OVER (
               PARTITION BY customer_id
               ORDER BY order_date
           ) AS previous_amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM customer_order
)
SELECT customer_id,
       customer_name,
       previous_amount,
       amount AS latest_amount,
       amount - previous_amount AS difference
FROM lags
WHERE rn = 1
  AND amount > previous_amount;


-- --------------------------------------------
-- 2. Customers on a 3-order upward streak (each of their last three
--    orders bigger than the one before it)
--    (LAG(amount, 1) and LAG(amount, 2) to look back two and three
--     orders from a reference row)
--
--    NOTE: this has a real bug -- the window here is ordered by
--    `order_date DESC`, so position 1 in that ordering is the LATEST
--    order (the same row picked out by `rn = 1`). LAG() always looks
--    at the row(s) *before* the current one in the window's order,
--    and there is no row before position 1 -- so at the exact row
--    where `rn = 1`, both `LAG(amount,1)` and `LAG(amount,2)` return
--    NULL every time. That makes `second_latest_amount` and
--    `third_latest_amount` NULL for every customer, so
--    `second_latest_amount > third_latest_amount` is never true and
--    this query returns zero rows no matter what the data looks
--    like. The fix is the same pattern query 1 uses: order the LAG
--    window ASC by `order_date` (so LAG naturally looks backward in
--    time), then pick out the latest row afterward with a DESC
--    ROW_NUMBER(), same as query 1's `rn = 1`.
-- --------------------------------------------
WITH cust_orders AS (
    SELECT c.customer_id,
           c.customer_name,
           o.order_date,
           p.amount
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
),
lags AS (
    SELECT customer_id,
           customer_name,
           amount AS latest,
           LAG(amount, 1) OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS second_latest_amount,
           LAG(amount, 2) OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS third_latest_amount,
           ROW_NUMBER() OVER (
               PARTITION BY customer_id
               ORDER BY order_date DESC
           ) AS rn
    FROM cust_orders
)
SELECT customer_id,
       customer_name,
       latest,
       second_latest_amount,
       third_latest_amount
FROM lags
WHERE rn = 1
  AND second_latest_amount > third_latest_amount
  AND latest > second_latest_amount;


-- --------------------------------------------
-- 3. Repeat customers (2+ orders) spending above the overall average
--    (AVG() OVER() with no PARTITION BY -- same average repeated on
--     every row -- plus DENSE_RANK() for spending position)
--
--    Note: the GROUP BY in `avg_spend` is redundant here, since
--    `customer_orders` is already exactly one row per customer --
--    grouping by customer_id/customer_name over data that's already
--    unique per customer doesn't change anything, it's just an
--    extra clause that isn't doing any aggregating work.
-- --------------------------------------------
WITH customer_orders AS (
    SELECT c.customer_id,
           c.customer_name,
           COUNT(o.order_id) AS total_orders,
           SUM(p.amount) AS total_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id, c.customer_name
),
avg_spend AS (
    SELECT customer_id,
           customer_name,
           total_orders,
           total_spending,
           AVG(total_spending) OVER () AS avg_spending,
           DENSE_RANK() OVER (ORDER BY total_spending DESC) AS rn
    FROM customer_orders
    GROUP BY customer_id, customer_name
)
SELECT customer_id,
       customer_name,
       total_orders,
       total_spending,
       avg_spending
FROM avg_spend
WHERE total_orders >= 2
  AND total_spending > avg_spending
ORDER BY customer_name;


-- --------------------------------------------
-- 4. Customers whose spending is heavily concentrated in one product
--    (3+ distinct products bought, but one product accounts for
--     over 40% of their total spend)
--    (per-line-item spend correctly computed as quantity * price --
--     this fixes the overcounting issue from the 2026-08-12 session,
--     where the full order payment amount was attached to every item
--     in a multi-item order instead of each item's own value)
-- --------------------------------------------
WITH customer AS (
    SELECT c.customer_id,
           c.customer_name,
           pr.product_id,
           pr.product_name,
           oi.quantity,
           pr.price
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products pr ON oi.product_id = pr.product_id
),
product_spending AS (
    SELECT
        customer_id,
        customer_name,
        product_id,
        product_name,
        SUM(quantity * price) AS product_spending
    FROM customer
    GROUP BY customer_id, customer_name, product_id, product_name
),
unique_pro AS (
    SELECT customer_id,
           customer_name,
           COUNT(*) AS unique_product,
           SUM(product_spending) AS total_spending,
           MAX(product_spending) AS highest_product_spending
    FROM product_spending
    GROUP BY customer_id, customer_name
),
cust_hist AS (
    SELECT customer_id,
           customer_name,
           unique_product,
           total_spending,
           highest_product_spending,
           (highest_product_spending / total_spending * 100) AS concentration_percentage
    FROM unique_pro
)
SELECT customer_id,
       customer_name,
       unique_product,
       total_spending,
       highest_product_spending,
       concentration_percentage
FROM cust_hist
WHERE unique_product >= 3
  AND concentration_percentage > 40;


-- --------------------------------------------
-- 5. Customers whose spending is heavily concentrated in one
--    category (2+ distinct categories bought, but one category
--    accounts for over 60% of their total spend)
--    (same concentration pattern as query 4, grouped by category
--     instead of product, using RANK() to pick the top category per
--     customer and joining it back to the customer-level summary)
-- --------------------------------------------
WITH customer AS (
    SELECT c.customer_id,
           c.customer_name,
           oi.quantity,
           pr.price,
           pr.category_id
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments p ON o.order_id = p.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products pr ON oi.product_id = pr.product_id
),
category_spending AS (
    SELECT
        customer_id,
        customer_name,
        category_id,
        SUM(quantity * price) AS category_spending
    FROM customer
    GROUP BY customer_id, customer_name, category_id
),
ranked_categories AS (
    SELECT
        customer_id,
        customer_name,
        category_id,
        category_spending,
        RANK() OVER (
            PARTITION BY customer_id
            ORDER BY category_spending DESC
        ) AS category_rank
    FROM category_spending
),
customer_summary AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(*) AS unique_categories,
        SUM(category_spending) AS total_spending
    FROM category_spending
    GROUP BY customer_id, customer_name
)
SELECT
    cs.customer_id,
    cs.customer_name,
    cs.unique_categories,
    cs.total_spending,
    rc.category_id AS top_category,
    rc.category_spending AS top_category_spending,
    ROUND(rc.category_spending / cs.total_spending * 100, 2) AS category_percentage
FROM customer_summary cs
JOIN ranked_categories rc ON cs.customer_id = rc.customer_id
WHERE cs.unique_categories >= 2
  AND rc.category_rank = 1
  AND rc.category_spending / cs.total_spending * 100 > 60
ORDER BY category_percentage DESC;

-- ------------------------------------------------------------
-- 6 : Products that make up more than 20% of their
-- category's total revenue (revenue concentration by product).
-- ------------------------------------------------------------
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        SUM(p.price * oi.quantity) AS product_revenue
    FROM products p
    JOIN categories c
        ON p.category_id = c.category_id
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name
),
category_revenue AS (
    SELECT
        category_id,
        SUM(product_revenue) AS category_revenue
    FROM product_revenue
    GROUP BY category_id
)
SELECT
    p.product_id,
    p.product_name,
    p.category_name AS category,
    p.product_revenue,
    c.category_revenue,
    p.product_revenue / c.category_revenue * 100 AS revenue_percentage
FROM product_revenue p
JOIN category_revenue c
    ON p.category_id = c.category_id
WHERE p.product_revenue / c.category_revenue * 100 > 20
ORDER BY
    p.category_name,
    revenue_percentage DESC;


-- ------------------------------------------------------------
-- 7 : Customers (with 3+ orders) whose latest order
-- value increased compared to their previous order, ranked by
-- the percentage increase.
-- ------------------------------------------------------------
WITH customer_orders AS (
    SELECT
        c.customer_id,
        c.customer_name,
        o.order_id,
        o.order_date,
        p.amount AS order_value,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date DESC
        ) AS rn,
        LAG(p.amount) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date DESC
        ) AS previous_order_value,
        COUNT(*) OVER (
            PARTITION BY c.customer_id
        ) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN payments p
        ON o.order_id = p.order_id
),
latest_orders AS (
    SELECT
        customer_id,
        customer_name,
        order_id AS latest_order_id,
        order_value AS latest_order_value,
        previous_order_value,
        100.0 * (order_value - previous_order_value)
            / previous_order_value AS increase_percentage
    FROM customer_orders
    WHERE rn = 1
      AND order_count >= 3
)
SELECT
    customer_id,
    customer_name,
    latest_order_id,
    latest_order_value,
    previous_order_value,
    increase_percentage
FROM latest_orders
WHERE latest_order_value > previous_order_value
ORDER BY increase_percentage DESC;
