# SQL Analysis Description

This file documents the main SQL queries used in the **Superstore Sales Analysis using SQL** project.

The objective of these queries is to answer key business questions related to revenue, profit, customers, products, and regional performance.

---

## Analysis 1 — Overall Business Performance

### Business Question
What are the total revenue, total profit, and overall profit margin?

### SQL Query
```sql
SELECT 
    SUM(sales) AS total_revenue_$,
    SUM(profit) AS total_profit_$,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM order_items;

---

### Purpose

Result : 
