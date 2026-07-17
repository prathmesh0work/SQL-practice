# SQL Quest — Advanced SQL Practice

A small e-commerce-style MySQL schema I'm using as an ongoing daily practice ground — subqueries, CTEs, and window functions so far, with joins/aggregations and more to come. New queries get added regularly, so this repo grows over time rather than being a one-off snapshot.

## Schema

6 related tables modeling a simple online store:

| Table | Description |
|---|---|
| `Customers` | Customer profile info (name, city, age, gender, signup date) |
| `Categories` | Product categories (Electronics, Clothing, Furniture, Books, Sports) |
| `Products` | Products with price, stock, and a category FK |
| `Orders` | Customer orders with status (Delivered / Pending / Cancelled) |
| `Order_Items` | Line items linking orders to products (many-to-many) |
| `Payments` | Payments made against orders |

**Relationships:**
- `Products.category_id` → `Categories.category_id`
- `Orders.customer_id` → `Customers.customer_id`
- `Order_Items.order_id` → `Orders.order_id`, `Order_Items.product_id` → `Products.product_id`
- `Payments.order_id` → `Orders.order_id`

## Files

```
SQL-practice/
├── create_tables.sql                    # CREATE DATABASE, all tables + sample data
├── 2026-07-16_subqueries.sql            # session 1: subqueries, EXISTS, derived tables
├── 2026-07-17_ctes_window_functions.sql # session 2: CTEs, window functions
└── ...                                  # one file per session, added as I practice
```

**Naming convention for new sessions:** `YYYY-MM-DD_topic.sql` (e.g. `2026-07-20_joins.sql`, `2026-07-22_window_functions.sql`). Keeps each day's practice self-contained and makes the commit history double as a practice log.

## How to run

1. Open MySQL and run the schema file to create the database and load sample data:
   ```sql
   source create_tables.sql;
   ```
2. Then run any session query file (each is self-contained after step 1):
   ```sql
   source 2026-07-16_subqueries.sql;
   ```

## What's covered

- Simple subqueries in `WHERE` (above/below average)
- Subqueries in `HAVING` after `GROUP BY`
- Nested (two-level) subqueries — e.g. average of a per-customer aggregate
- `IN` / `NOT IN` with a subquery
- Correlated subqueries with `EXISTS` / `NOT EXISTS`
- Correlated subquery comparing a row to the average **within its own group** (e.g. price vs. average price in the same category)
- Derived tables (subquery in `FROM`)
- Correlated scalar subqueries in `SELECT` (per-row calculated columns)
- CTEs (`WITH`) — single and chained/multiple CTEs in one query
- Window functions — `AVG() OVER()`, `RANK() OVER()`, `ROW_NUMBER() OVER()`, `LAG() OVER()`, with and without `PARTITION BY`
- Filtering on a window function's result via an outer CTE (since `RANK()` etc. can't go directly in `WHERE`)

## Notes

- Queries 5 and 8 return the same result (products never ordered) using two different techniques — `NOT IN` vs. `NOT EXISTS` — kept side by side intentionally for comparison.
- Queries 3 and 11 also solve the same problem (customers with above-average order counts) two different ways: `HAVING` vs. a derived table with `WHERE`.

## Practice Log

| Date | File | Topics |
|---|---|---|
| 2026-07-16 | `2026-07-16_subqueries.sql` | Subqueries, correlated subqueries, EXISTS/NOT EXISTS, derived tables |
| 2026-07-17 | `2026-07-17_ctes_window_functions.sql` | CTEs (single & chained), CTE + subquery, window functions: `AVG() OVER()`, `RANK()`, `ROW_NUMBER()`, `LAG()`, `PARTITION BY` |
