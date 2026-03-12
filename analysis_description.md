# SQL Analysis Description

This file documents the main SQL queries used in the **Superstore Sales Analysis using SQL** project.

The objective of these queries is to answer key business questions related to revenue, profit, customers, products, and regional performance.

---

## Analysis 1: Overall Business Performance

### Business Question
What are the total revenue, total profit, and overall profit margin?

### SQL Query
```sql 
SELECT 
    SUM(sales) AS total_revenue_$,
    SUM(profit) AS total_profit_$,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM order_items;
```

### Result
| Metric | Value |
|------|------|
| Total Revenue | $2.27M |
| Total Profit | $282K |
| Profit Margin | 12.45% |

### Insight
The business generated over $2.27M in sales with an overall profitability of around 12.45%.

---
  
## Analysis 2 : Revenue and Profit by Product Category

### Business Question
Which product categories generate the most revenue and profit?

### SQL Query
```sql
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
```

### Result
| Catergory |  Total Revenue |  Total Profit | Profit Margin |
|------|------|-----|------|
| Technology | $835,000 | $145,387 | 17.39% |
| Furniture | $733,047 | $16,980 | 2.32% |
| Office Supplies | $703,502 | $120,489 | 17.13% |

### Insights
- Technology products generate the highest overall profit.
- Office Supplies also show strong profitability.
- Furniture generates revenue but significantly lower profit, suggesting potential margin issues in this category.

---

## Analysis 3: Sales Trend by Year

### Business Question
How have sales and profits evolved over time?

### SQL Query
```sql
SELECT
    YEAR(o.order_date) AS order_year,
    ROUND(SUM(oi.sales), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date)
ORDER BY order_year;
```

### Result
| Order Year | Total Revenue | Total Profit |
|------|------|-----|
| 2014 | $481,763 | $49,044 |
| 2015 | $464,426 | $60,907 |
| 2016 | $601,265 | $80,130 |
| 2017 | $724,994 | $92,775 |



### Insights
- Sales increased consistently between 2015 and 2017, suggesting strong business growth over time.
- After showing a downward trend (2014 to 2015), both revenue and profit show an upward trend across the years.

---

## Analysis 4: Regional Sales Performance

### Business Question
Which customers generate the most revenue and profit?

### SQL Query
```sql
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
```

### Result
| Region | Revenue | Profit | Profit Margin |
|------|------|------|------|
| West | $713,471 | $106,021 | 14.86% |
| East | $672,194 | $90,672 | 13.49% |
| Central | $497,800 | $40,128 | 8.06% |
| South | $388,983 | $46,036 | 11.83% |


### Insights
- The West and East regions generate the highest revenue and profit.
- The Central region shows the lowest profit margin, indicating potential inefficiencies or higher operational costs.

---

## Analysis 5: Top Product Sub-Categories
### Business Question
What are the top 5 product sub-categories by revenue and profit?

### SQL Query
```sql
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
```

### Result
| Sub Category | Total Revenue | Total Profit | Profit Margin |
|------|------|------|------|
| Phones | $329,753 | $44,448 | 13.48% |
| Chairs | $328,449 | $26,590 | 8.10% |
| Storage | $216,803 | $21,528 | 9.93% |
| Tables | $206,965 | $ -17,725 | -8.56% |
| Binders | $199,905 | $29,982 | 15.00% |

### Insights

- Tables produce high revenue but negative profit, suggesting heavy discounting or high operational costs.
- Binders show strong profitability despite lower revenue compared to some other sub-categories.
  
---

## Analysis 6: Product Category Profitability

### Business Question
How can product categories be classified by profit level?

```sql
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
```

### Result
| Category | Total Profit | Profit Level |
|------|------|-----|
| Technology | $145,387 | High Profit |
| Office Supplies | $120,489 | High Profit |
| Furniture | $16,980| Low Profit

### Insight
- Technology and Office Supplies have a hight profit level.

---

## Key Takeaways

- Revenue alone does not always reflect business success.
- Profitability analysis reveals that some high-selling products and regions contribute less to overall profit.

---

# Data Modeling Adjustment

## Business Issue Identified
During the early regional analysis, the regional distribution appeared unrealistic.

## Reason

Geographic attributes such as region, city, and state were initially modeled at the customers level, but in this dataset these attributes are more reliable at the order level.

## Adjustment Made

The geographic fields were added to the orders table and updated from the raw staging table.

## SQL Update Logic 
```sql

ALTER TABLE orders
ADD country VARCHAR(100),
ADD city VARCHAR(100),
ADD state VARCHAR(100),
ADD postal_code VARCHAR(20),
ADD region VARCHAR(50);

UPDATE orders o
JOIN (
    SELECT
        order_id,
        MAX(country) AS country,
        MAX(city) AS city,
        MAX(state) AS state,
        MAX(postal_code) AS postal_code,
        MAX(region) AS region
    FROM superstore_raw
    GROUP BY order_id
) r
ON o.order_id = r.order_id
SET
    o.country = r.country,
    o.city = r.city,
    o.state = r.state,
    o.postal_code = r.postal_code,
    o.region = r.region;

```

## Result
This adjustment produced more realistic regional results and improved the quality of the regional analysis.







