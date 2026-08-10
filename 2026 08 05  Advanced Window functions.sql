USE sql_quest;

/*
=========================================================
SQL QUEST - WINDOW FUNCTIONS PRACTICE
Author: Prathmesh Ingole

Topics Covered:
- LAG()
- LEAD()
- RANK()
- SUM() OVER()
- AVG() OVER()
- FIRST_VALUE()
- CTEs
- CASE Statements
- Window Frames

=========================================================
*/


/*
=========================================================
Challenge 1:
Compare each customer's payment with their previous payment.

Required:
- customer_id
- order_date
- amount
- previous_amount
- difference

Concept Used:
- LAG()
- PARTITION BY
- ORDER BY
=========================================================
*/

WITH customer_orders AS (
    SELECT
        o.customer_id,
        o.order_date,
        p.amount
    FROM orders o
    JOIN payments p
        ON o.order_id = p.order_id
)

SELECT
    customer_id,
    order_date,
    amount,

    LAG(amount) OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_amount,

    amount -
    LAG(amount) OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS difference

FROM customer_orders;



/*
=========================================================
Challenge 2:
Find the next order date and number of days until
the customer's next order.

Concept Used:
- LEAD()
- DATEDIFF()
=========================================================
*/

SELECT
    customer_id,
    order_date,

    LEAD(order_date) OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS next_order_date,

    DATEDIFF(
        LEAD(order_date) OVER(
            PARTITION BY customer_id
            ORDER BY order_date
        ),
        order_date
    ) AS days_until_next_order

FROM orders;



/*
=========================================================
Challenge 3:
Find the top-selling product in each category.

Requirement:
- Include ties for first place.

Concept Used:
- CTE
- SUM()
- RANK()
- PARTITION BY
=========================================================
*/

WITH product_sales AS (

    SELECT
        p.product_id,
        p.product_name,
        p.category_id,
        SUM(o.quantity) AS total_sold

    FROM products p

    JOIN order_items o
        ON p.product_id = o.product_id

    GROUP BY
        p.product_id,
        p.product_name,
        p.category_id
),

product_rank AS (

    SELECT
        *,
        RANK() OVER(
            PARTITION BY category_id
            ORDER BY total_sold DESC
        ) AS category_rank

    FROM product_sales
)

SELECT
    product_id,
    product_name,
    category_id,
    total_sold

FROM product_rank

WHERE category_rank = 1;



/*
=========================================================
Challenge 4:
Calculate each customer's running spending total.

Concept Used:
- SUM() OVER()
- Running Total
=========================================================
*/

WITH customer_orders AS (

    SELECT
        customer_id,
        order_date,
        amount

    FROM orders o

    JOIN payments p
        ON o.order_id = p.order_id
)

SELECT
    customer_id,
    order_date,
    amount,

    SUM(amount) OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS running_total

FROM customer_orders;



/*
=========================================================
Challenge 5:
Calculate a 3-order moving average for customers.

Concept Used:
- AVG()
- Window Frame
- ROWS BETWEEN
=========================================================
*/

WITH customer_orders AS (

    SELECT
        customer_id,
        order_date,
        amount

    FROM orders o

    JOIN payments p
        ON o.order_id = p.order_id
)

SELECT
    customer_id,
    order_date,
    amount,

    AVG(amount) OVER(
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_average

FROM customer_orders;



/*
=========================================================
Challenge 6:
Compare every order with customer's first order.

Concept Used:
- FIRST_VALUE()
- CTE
=========================================================
*/

WITH customer_orders AS (

    SELECT
        customer_id,
        order_date,
        amount

    FROM orders o

    JOIN payments p
        ON o.order_id = p.order_id
),

customer_analysis AS (

    SELECT
        customer_id,
        order_date,
        amount,

        FIRST_VALUE(amount) OVER(
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS first_order_amount

    FROM customer_orders
)

SELECT
    *,
    amount - first_order_amount AS difference

FROM customer_analysis;



/*
=========================================================
Challenge 7:
Identify loyal customers (3+ orders).

Show whether payment increased,
decreased, or stayed the same compared
to previous payment.

Concept Used:
- CTE
- GROUP BY
- HAVING
- LAG()
- CASE Statement
=========================================================
*/

WITH customer_order_count AS (

    SELECT
        customer_id,
        COUNT(order_id) AS total_orders

    FROM orders

    GROUP BY customer_id

    HAVING COUNT(order_id) >= 3
),

customer_payments AS (

    SELECT
        c.customer_id,
        c.customer_name,
        o.order_date,
        p.amount

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN payments p
        ON o.order_id = p.order_id

    JOIN customer_order_count coc
        ON c.customer_id = coc.customer_id
),

payment_history AS (

    SELECT
        *,
        LAG(amount) OVER(
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_amount

    FROM customer_payments
)

SELECT
    customer_id,
    customer_name,
    order_date,
    amount,
    previous_amount,

    CASE

        WHEN previous_amount IS NULL
            THEN 'First Order'

        WHEN amount > previous_amount
            THEN 'Increased'

        WHEN amount < previous_amount
            THEN 'Decreased'

        ELSE 'No Change'

    END AS payment_status

FROM payment_history;
