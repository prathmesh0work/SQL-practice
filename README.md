# SQL Quest — Advanced SQL Practice

A hands-on MySQL practice repository where I solve SQL problems daily using a realistic e-commerce database. The repository documents my learning journey through progressively advanced SQL concepts, with each practice session saved as a separate SQL file.

## 📌 Schema

The database contains six related tables that model a simple online store.

| Table | Description |
|--------|-------------|
| `Customers` | Customer information (name, city, age, gender, signup date) |
| `Categories` | Product categories |
| `Products` | Products with price, stock, and category |
| `Orders` | Customer orders and order status |
| `Order_Items` | Products included in each order |
| `Payments` | Payment information for orders |

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
├── 2026-07-16_subqueries.sql
├── 2026-07-17_ctes_window_functions.sql
├── 2026-07-20_window_functions.sql
└── ...
```

**Naming Convention**

```
YYYY-MM-DD_topic.sql
```

Example:

```
2026-07-20_window_functions.sql
2026-07-22_joins.sql
2026-07-24_case_statements.sql
```

Each file represents one focused practice session, making the Git commit history a chronological learning log.

---

# 🚀 Getting Started

### 1. Create the database

```sql
source create_tables.sql;
```

### 2. Run any practice session

```sql
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
- Multi-table Joins

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

### Running Calculations

- Running Total
- Cumulative Sales

### Moving Window Calculations

- 2-Order Moving Average
- 3-Order Moving Average
- 4-Order Moving Average

### Window Clauses

- PARTITION BY
- ORDER BY
- ROWS BETWEEN ... PRECEDING AND CURRENT ROW

## Date Functions

- DATEDIFF()
- Order Gap Analysis
- Days Until Next Order

---

# 📝 Practice Sessions

| Date | File | Topics |
|------|------|--------|
| 2026-07-16 | `2026-07-16_subqueries.sql` | Subqueries, EXISTS, NOT EXISTS, Derived Tables |
| 2026-07-17 | `2026-07-17_ctes_window_functions.sql` | CTEs, AVG() OVER(), RANK(), ROW_NUMBER(), LAG(), PARTITION BY |
| 2026-07-20 | `2026-07-20_window_functions.sql` | LEAD(), Running Total, Moving Average, Date Difference, Window Frames |

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
