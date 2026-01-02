
USE sales_db;
CREATE TABLE sales_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    product_id INT,
    region_id INT,
    quantity INT,
    unit_price DECIMAL(10,2)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);
CREATE TABLE regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50)
);
CREATE TABLE sales_reps (
    sales_rep_id INT PRIMARY KEY,
    sales_rep_name VARCHAR(100)
);
select * from sales_orders;
SHOW TABLES;

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

SET SESSION local_infile = 1;

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_order_SQl.csv'
INTO TABLE sales_orders
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(order_id, order_date, product_id, region_id, quantity, unit_price);

select * from products;
select * from sales_orders;
select * from regions;

SELECT COUNT(*) FROM sales_orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM regions;

# for Total revenue
SELECT 
  ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM sales_orders;
 
# for average of order 
 SELECT 
  ROUND(SUM(quantity * unit_price) / COUNT(DISTINCT order_id), 2) AS aov
FROM sales_orders;

# for revenue of product
SELECT
  p.product_name,
  ROUND(SUM(s.quantity * s.unit_price), 2) AS revenue
FROM sales_orders s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

select * from sales_orders;
 
 #for region vise revenue
 SELECT
  r.region_name,
  ROUND(SUM(s.quantity * s.unit_price), 2) AS revenue
FROM sales_orders s
JOIN regions r ON s.region_id = r.region_id
GROUP BY r.region_name
ORDER BY revenue DESC;

#for product vise revenue based on rank
select
 p.product_name,
 round( sum(quantity * unit_price), 2) as revenue,
 rank() over ( order by sum(s.quantity * s.unit_price) desc) as revenue_rank
 from sales_orders s
 join products p on s.product_id=p.product_id
 group by p.product_name;
 
#for CONTRIBUTION%
  SELECT
  r.region_name,
  ROUND(
    SUM(s.quantity * s.unit_price) /
    (SELECT SUM(quantity * unit_price) FROM sales_orders) * 100, 2
  ) AS contribution_pct
FROM sales_orders s
JOIN regions r ON s.region_id = r.region_id
GROUP BY r.region_name
ORDER BY contribution_pct DESC;

# for Monthly Trend + MoM Growth
select
 month,
 revenue,
 round(
 ( revenue-LAG(revenue) over (order by month))/
 lag(revenue) over (order by month)* 100,2
 ) as mom_growth_pct
 from (
 select 
 DATE_FORMAT(ORDER_DATE,'%Y-%m') AS month,
  SUM(quantity * unit_price) AS revenue
  FROM sales_orders
  GROUP BY month
) t;
