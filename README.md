# SQL Quest — Advanced SQL Practic

A hands-on MySQL practice repository where I solve SQL problems daily using a realistic e-commerce database. The repository documents my learning journey through progressively advanced SQL concepts, with each practice session saved as a separate SQL file.

## 📌 Schema

The database contains six related tables that model a simple online store.

| Table         | Description                                                 |
| ------------- | ----------------------------------------------------------- |
| `Customers`   | Customer information (name, city, age, gender, signup date) |
| `Categories`  | Product categories                                          |
| `Products`    | Products with price, stock, and category                    |
| `Orders`      | Customer orders and order status                            |
| `Order_Items` | Products included in each order                             |
| `Payments`    | Payment information for orders                              |

### Relationships

- `Products.category_id` → `Categories.category_id`
- `Orders.customer_id` → `Customers.customer_id`
- `Order_Items.order_id` → `Orders.order_id`
- `Order_Items.product_id` → `Products.product_id`
- `Payments.order_id` → `Orders.order_id`

---

# 📂 Repository Structure

```
SQL-Quest/

├── create_tables.sql
├── 2026-07-14_basics_aggregations.sql
├── 2026-07-15_joins.sql
├── 2026-07-16_subqueries.sql
├── 2026-07-17_ctes_window_functions.sql
├── 2026-07-20_window_functions.sql
├── 2026-07-21_advanced_window_functions.sql
├── 2026-08-05_advanced_window_functions.sql
├── 2026-08-07_top_customers_and_products_window_functions.sql
├── 2026-08-10_case_dates_analytics.sql
├── 2026-08-11_datalemur_easy.sql
├── 2026-08-12_self_joins_advanced_analytics.sql
├── 2026-08-13_window_functions_retention.sql
├── 2026-08-14_spend_trends_concentration.sql
└── ...
```

**Naming Convention**

```
YYYY-MM-DD_topic.sql
```

Each file represents one focused practice session, making the Git commit history a chronological learning log.

---

# 🚀 Getting Started

### 1. Create the database

```
source create_tables.sql;
```

### 2. Run any practice session

```
source 2026-07-20_window_functions.sql;
```

---

# 📚 SQL Topics Covered

## Basic SQL
- SELECT
- WHERE
- ORDER BY
- LIMIT
- DISTINCT

## Aggregations
- COUNT()
- SUM()
- AVG()
- MIN()
- MAX()
- GROUP BY
- HAVING

## Joins
- INNER JOIN
- LEFT JOIN
- CROSS JOIN
- Multi-table Joins
- LEFT JOIN + IS NULL (anti-join pattern)
- Self-Joins (matching rows within the same table)

## Subqueries
- Simple subqueries
- Nested subqueries
- Correlated subqueries
- Scalar subqueries
- Subqueries in WHERE
- Subqueries in HAVING
- Subqueries in FROM (Derived Tables)
- EXISTS / NOT EXISTS
- IN / NOT IN

## Common Table Expressions (CTEs)
- Single CTE
- Multiple CTEs
- Chained CTEs
- CTE with Window Functions
- CTE + Aggregations
- CTE + CROSS JOIN against an aggregate

## Window Functions

### Ranking
- ROW_NUMBER()
- RANK()
- DENSE_RANK()

### Analytical Functions
- LAG()
- LEAD()

### Aggregate Window Functions
- AVG() OVER()
- SUM() OVER()

### Value Functions
- FIRST_VALUE()
- LAST_VALUE()
- NTH_VALUE()

### Distribution Functions
- NTILE()
- CUME_DIST()
- PERCENT_RANK()

### Running Calculations
- Running Total
- Cumulative Sales
- Spend Concentration (cumulative share of total spend)

### Moving Window Calculations
- 2-Order Moving Average
- 3-Order Moving Average
- 4-Order Moving Average

### Window Clauses
- PARTITION BY
- ORDER BY
- ROWS BETWEEN ... PRECEDING AND CURRENT ROW
- ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING

## CASE Statements
- CASE WHEN ... THEN ... ELSE ... END
- Categorizing rows based on an aggregate (e.g. VIP / Regular / Low Value by spend)

## NULL-Safe Functions
- COALESCE() — substituting a default for a NULL aggregate
- NULLIF() — avoiding divide-by-zero in an average calculation

## Analytical Patterns
- Top-N-per-group (RANK() partitioned by a category, filtered via a wrapping CTE)
- Top customers and products by spend/units, using window functions
- Retention-style / cohort analysis combining LAG(), ROW_NUMBER(), DATEDIFF(), and CROSS JOIN against an aggregate across several chained CTEs
- Spend trend and concentration analysis (cumulative/running share of total revenue)
- Interview-style problems (DataLemur easy set)

## Date Functions
- DATEDIFF()
- DATE_FORMAT() (bucketing dates into year-month groups)
- Order Gap Analysis
- Days Until Next Order
- Month-over-month comparisons

---

# 📝 Practice Sessions

| Date       | File                                                     | Topics                                                                                                                                                                                     |
| ---------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2026-07-14 | `2026-07-14_basics_aggregations.sql`                       | SELECT, WHERE, ORDER BY, LIMIT, DISTINCT, COUNT(), SUM(), AVG(), MIN(), MAX(), GROUP BY, HAVING                                                                                            |
| 2026-07-15 | `2026-07-15_joins.sql`                                     | INNER JOIN, LEFT JOIN, multi-table joins, LEFT JOIN + IS NULL (anti-join pattern)                                                                                                          |
| 2026-07-16 | `2026-07-16_subqueries.sql`                                | Subqueries, EXISTS, NOT EXISTS, Derived Tables                                                                                                                                             |
| 2026-07-17 | `2026-07-17_ctes_window_functions.sql`                     | CTEs, AVG() OVER(), RANK(), ROW_NUMBER(), LAG(), PARTITION BY                                                                                                                              |
| 2026-07-20 | `2026-07-20_window_functions.sql`                          | LEAD(), Running Total, Moving Average, Date Difference, Window Frames                                                                                                                      |
| 2026-07-21 | `2026-07-21_advanced_window_functions.sql`                 | FIRST_VALUE(), LAST_VALUE(), NTH_VALUE(), NTILE(), CUME_DIST(), PERCENT_RANK(), combined RANK/DENSE_RANK/LAG across joined CTEs                                                            |
| 2026-08-05 | `2026-08-05_advanced_window_functions.sql`                 | Further practice on value/distribution window functions (FIRST_VALUE/LAST_VALUE/NTH_VALUE, NTILE, CUME_DIST, PERCENT_RANK) *(inferred from filename — update if needed)*                  |
| 2026-08-07 | `2026-08-07_top_customers_and_products_window_functions.sql` | Ranking top customers and top products using window functions (RANK/DENSE_RANK partitioned by category or customer) *(inferred from filename — update if needed)*                         |
| 2026-08-10 | `2026-08-10_case_dates_analytics.sql`                      | LEFT JOIN + IS NULL, CTE + CROSS JOIN vs. average, HAVING + COUNT(DISTINCT), EXISTS with joined condition, CASE WHEN categorization, DATEDIFF(), DATE_FORMAT(), month-over-month LAG()    |
| 2026-08-11 | `2026-08-11_datalemur_easy.sql`                            | DataLemur easy-level interview SQL problems *(inferred from filename — update if needed)*                                                                                                  |
| 2026-08-12 | `2026-08-12_self_joins_advanced_analytics.sql`             | COALESCE + NULLIF for null-safe averages, HAVING with multiple conditions, self-joins, RANK() top-N-per-category, multi-CTE retention analysis (LAG + ROW_NUMBER + DATEDIFF + CROSS JOIN) |
| 2026-08-13 | `2026-08-13_window_functions_retention.sql`                | Retention/cohort-style analysis using window functions (LAG, ROW_NUMBER, DATEDIFF) *(inferred from filename — update if needed)*                                                           |
| 2026-08-14 | `2026-08-14_spend_trends_concentration.sql`                | Spend trend and concentration analysis — running totals and cumulative share of revenue *(inferred from filename — update if needed)*                                                     |

---

# 💡 Sample Problems Solved

- Customers with above-average order counts
- Products never ordered
- Products priced above their category average
- Previous order amount using `LAG()`
- Next order amount using `LEAD()`
- Running total of customer spending
- Days until a customer's next order
- 2-order moving average
- 3-order moving average
- 4-order moving average
- Customer spending rankings
- Ranking customers within each city
- Overall average customer spending
- First and last order amount per customer using `FIRST_VALUE()` / `LAST_VALUE()`
- Second and third order amount per customer using `NTH_VALUE()`
- Splitting customers into spending quartiles using `NTILE()`
- Cumulative spending distribution using `CUME_DIST()`
- Top-spending percentile customers using `PERCENT_RANK()`
- Combined spending report: overall rank, city rank, and gap to next-highest spender
- Filtering customers by city and age range
- Top 3 most expensive products
- Distinct cities and payment methods in use
- Orders placed per customer, filtered to repeat customers only
- Average, min, and max product price by category
- Full order detail combining customer, product, category, and quantity
- Customers who have never placed an order, using LEFT JOIN + IS NULL
- Orders that don't have a payment yet
- Revenue per category using a multi-table join + GROUP BY
- Number of distinct products each customer has bought
- Customers with above-average order count, using CROSS JOIN against an aggregate CTE
- First order date, last order date, and days between them per customer
- Cities with 3 or more distinct customers
- Customers who made at least one payment over a threshold, via EXISTS
- Categorizing customers as VIP / Regular / Low Value by total spend
- Monthly revenue and order count using DATE_FORMAT()
- Month-over-month revenue change using LAG()
- Average order value including customers with zero orders (COALESCE + NULLIF)
- Customers with 2+ orders and total spending over a threshold, combined in one HAVING
- Pairs of customers who placed an order on the same date (self-join)
- Best-selling product in each category (RANK top-N-per-group)
- Re-engaging customers: 3+ orders, above-average spend, last two orders within 30 days
- Each customer's most expensive product by total spending
- Top customers and top products ranked via window functions
- Customer retention / repeat-purchase cohort analysis
- Cumulative spend concentration (share of total revenue by top customers)
- DataLemur-style interview practice problems

---

# 🎯 Learning Goals

This repository is my personal SQL learning log where I continuously practice:

- Writing clean and optimized SQL
- Solving interview-style SQL problems
- Mastering analytical SQL
- Understanding window functions
- Improving query readability with CTEs
- Building strong SQL fundamentals for Data Analytics and Data Science roles

New practice sessions are added regularly as I learn more advanced SQL concepts.
