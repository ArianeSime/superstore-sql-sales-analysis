# SQL Analysis Description

This file documents the main SQL queries used in the **Superstore Sales Analysis using SQL** project.

The objective of these queries is to answer key business questions related to revenue, profit, customers, products, and regional performance.

---


## Analysis 1 — Overall Business Performance

### Business Question
What are the total revenue, total profit, and overall profit margin?

### SQL Query
sql ```s
SELECT 
    SUM(sales) AS total_revenue_$,
    SUM(profit) AS total_profit_$,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM order_items; 

### Purpose

This query provides a high-level overview of the company’s overall financial performance.

### Result
table here

### Main Insight
hgjgug

---
  
## Analysis 2 : Revenue and Profit by Product Category

### Business Question
Which product categories generate the most revenue and profit?

### SQL Query
sql ```s
SELECT 
    p.category,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

### Result
table here

### Main Insight
- Technology products generate the highest overall profit.
- Office Supplies also show strong profitability.
- Furniture generates revenue but significantly lower profit, suggesting potential margin issues in this category.

---

## Analysis 3: Sales Trend by Year

### Business Question
How have sales and profits evolved over time?

### SQL Query
sql ```s
SELECT
    YEAR(o.order_date) AS order_year,
    ROUND(SUM(oi.sales), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date)
ORDER BY order_year;


### Result
table here

### Key Insight
- Sales increased consistently between 2014 and 2017, suggesting strong business growth over time.
- Both revenue and profit show an upward trend across the years.

----

## Analysis 4: Top Revenue-Generating Customers

### Business Question
Which customers generate the most revenue?

### SQL Query
sql ```s
SELECT 
    c.customer_name,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

### Result
table here

### Main Insight
hgjgug

---

## Analysis 5: Regional Sales Performance

### Business Question
Which customers generate the most revenue and profit?

### SQL Query
sql ```s
SELECT
    o.region,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY total_revenue DESC;

### Result
table here

### Main Insight
- The West and East regions generate the highest revenue and profit.

- The Central region shows the lowest profit margin, indicating potential inefficiencies or higher operational costs.

---

## Analysis 6: Top Product Sub-Categories
### Business Question
What are the top 5 product sub-categories by revenue and profit?

### SQL Query
sql ```s
SELECT 
    p.sub_category,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_revenue DESC
LIMIT 5;

### Result
table here

### Main Insight
- Some sub-categories generate high revenue but low or negative profit.

**Example:**
- Tables produce high revenue but negative profit, suggesting heavy discounting or high operational costs.

- Binders show strong profitability despite lower revenue compared to some other sub-categories.
  
---


## Analysis 7: Category Profit Classification using CASE

### Business Question
How can product categories be classified by profit level?

SELECT
    p.category,
    ROUND(SUM(oi.profit), 2) AS total_profit,
    CASE
        WHEN SUM(oi.profit) >= 100000 THEN 'High Profit'
        WHEN SUM(oi.profit) >= 50000 THEN 'Medium Profit'
        ELSE 'Low Profit'
    END AS profit_level
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;

### Result
table here

### Main Insight
hgjgug

---

# Key Takeaways

- Revenue alone does not always reflect business success.
- Profitability analysis reveals that some high-selling products and regions contribute less to overall profit.












