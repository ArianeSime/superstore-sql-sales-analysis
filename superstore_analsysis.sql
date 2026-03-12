-- 1. Database Setup
DROP DATABASE superstore_db;

CREATE DATABASE superstore_db;
USE superstore_db;

-- 2. Raw staging table 
CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(50),
    order_date VARCHAR(20),
    ship_date VARCHAR(20),
    ship_mode VARCHAR(100),
    customer_id VARCHAR(50),
    customer_name VARCHAR(150),
    segment VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2)
); 

-- 3. Relational tables
CREATE TABLE customers (
     customer_id VARCHAR(50) PRIMARY KEY,
     customer_name VARCHAR(150),
     segment VARCHAR(100),
     country VARCHAR(100),
     city VARCHAR(100),
     state VARCHAR(100),
     postal_code VARCHAR(20),
     region VARCHAR(50)
);

CREATE TABLE orders (
     order_id VARCHAR(50) PRIMARY KEY,
     order_date DATE,
     ship_date DATE,
    ship_mode VARCHAR(100),
    customer_id VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100),
    sub_category VARCHAR(100),
    product_name VARCHAR(255)
);

CREATE TABLE order_items (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

SELECT COUNT(*) AS total_rows
FROM superstore_raw;

-- 4. Populate relational table 
INSERT INTO customers
SELECT
    customer_id,
    MAX(customer_name),
    MAX(segment),
    MAX(country),
    MAX(city),
    MAX(state),
    MAX(postal_code),
    MAX(region)            
FROM superstore_raw
GROUP BY customer_id;

INSERT INTO orders
SELECT
    order_id,
    STR_TO_DATE(MAX(order_date), '%m/%d/%Y') AS order_date, 
    STR_TO_DATE(MAX(ship_date), '%m/%d/%Y') AS ship_date,
    MAX(ship_mode),
    MAX(customer_id)
FROM superstore_raw
GROUP BY order_id;

INSERT INTO products
SELECT
    product_id,
    MAX(category),
    MAX(sub_category),
    MAX(product_name)
FROM superstore_raw
GROUP BY product_id;

INSERT INTO order_items
SELECT
    row_id,
    order_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
FROM superstore_raw;

-- 5. Data quality check 
SELECT COUNT(*) AS customers_count FROM customers;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS orders_count FROM orders;
SELECT COUNT(*) AS order_items_count FROM order_items;

-- 6. Business analysis queries
-- Analysis 1: What are the total revenue, total profit, and overall profit margin?
SELECT 
     SUM(sales) AS total_revenue_$,
	 SUM(profit) AS total_profit_$,
	Round(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_100
FROM order_items ;

-- Analysis 2 : Which product categories drive the most revenue and profit?
SELECT 
    p.category ,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    Round(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_100
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC ;

-- classification of categories by profit level
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

-- -- Analysis 3 : What is the sales trend by Years ?
SELECT
    YEAR(o.order_date) AS order_year,
    ROUND(SUM(oi.sales), 2) AS total_revenue,
    ROUND(SUM(oi.profit), 2) AS total_profit
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_date)
ORDER BY order_year;

-- Analysis 4 : Which customers generate the most revenue?
SELECT 
	o.customer_id,
	c.customer_name,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    Round(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_100
FROM orders o
JOIN  customers c
	ON o.customer_id = c.customer_id
JOIN  order_items oi
	ON o.order_id = oi.order_id
GROUP BY o.customer_id, c.customer_name
ORDER BY total_revenue DESC 
LIMIT 10 ;

-- Analysis 5: Which regions generate the most revenue and profit?
SELECT 
	c.region,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    Round(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_percentage
FROM orders o
JOIN  customers c
	ON o.customer_id = c.customer_id
JOIN  order_items oi
	ON o.order_id = oi.order_id
GROUP BY  c.region
ORDER BY total_profit DESC ; -- After running the query ,geographic attributes are not stable 

-- since the regional distribution above looks extremely skewed (west app. 90% of revenue , statement above for verification
SELECT region, COUNT(*) 
FROM customers
GROUP BY region; -- after running the query i realize the data is unrealistic

-- conceptual fix 
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

-- Analysis 5 : Which regions generate the most revenue and profit?
SELECT
    o.region,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY total_revenue DESC; -- the data is now realistic 

-- Analysis 6 : What are the top 5 product sub-categories by revenue and profit?
SELECT 
    p.sub_category ,
    SUM(oi.sales) AS total_revenue,
    SUM(oi.profit) AS total_profit,
    Round(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_100
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id
GROUP BY p.sub_category
ORDER BY total_revenue DESC
LIMIT 5 ;












