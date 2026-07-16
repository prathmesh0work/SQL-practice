# SQL Quest — Subquery Practice

A small e-commerce-style MySQL schema built to practice **subqueries** — nested, correlated, `EXISTS`/`NOT EXISTS`, `IN`/`NOT IN`, and derived tables.

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
sql-practice/
├── schema/
│   └── create_tables.sql      # CREATE DATABASE, all tables + sample data
└── queries/
    └── practice_queries.sql   # 13 practice queries, commented by topic
```

## How to run

1. Open MySQL and run the schema file to create the database and load sample data:
   ```sql
   source schema/create_tables.sql;
   ```
2. Then run any query from `queries/practice_queries.sql` (each one is self-contained after step 1).

## What's covered

- Simple subqueries in `WHERE` (above/below average)
- Subqueries in `HAVING` after `GROUP BY`
- Nested (two-level) subqueries — e.g. average of a per-customer aggregate
- `IN` / `NOT IN` with a subquery
- Correlated subqueries with `EXISTS` / `NOT EXISTS`
- Correlated subquery comparing a row to the average **within its own group** (e.g. price vs. average price in the same category)
- Derived tables (subquery in `FROM`)
- Correlated scalar subqueries in `SELECT` (per-row calculated columns)

## Notes

- Queries 5 and 8 return the same result (products never ordered) using two different techniques — `NOT IN` vs. `NOT EXISTS` — kept side by side intentionally for comparison.
- Queries 3 and 11 also solve the same problem (customers with above-average order counts) two different ways: `HAVING` vs. a derived table with `WHERE`.
