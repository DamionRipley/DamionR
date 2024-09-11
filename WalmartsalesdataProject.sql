CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
	gender VARCHAR(10) NOT NULL, 
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL, 
    time TIME NOT NULL, 
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9) NOT NULL,
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1) NOT NULL
    );
    
    
    
    
    
    
    

-- -------------------------------------------------------------------------------------------------
-- -------------------------------- FEATURE ENGINEERING --------------------------------------------

-- Adding time_of_day column

SELECT time,
(CASE 
	WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
	ELSE "Evening"
END
 ) AS time_of_date
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (CASE 
	WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
	ELSE "Evening"
END
);

-- Adding day_name column

SELECT date, DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales Add COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- Adding month column

SELECT date, MONTHNAME(date) AS month
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);
-- ---------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------
-- --------------------------------- Generic ---------------------------------------------

-- How many unique cities does this data have?
SELECT DISTINCT city
FROM sales;

-- How many branches?
SELECT DISTINCT branch
FROM sales;

-- In which city does each branch correspond with?
SELECT DISTINCT city, branch
FROM sales;

-- ---------------------------------------------------------------------------------------
-- -------------------------------Product ------------------------------------------------

-- How many unqiue product lines does this data contain?
SELECT COUNT(DISTINCT product_line)
FROM sales;

-- What is the most common payment method?
SELECT payment_method, COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the highest selling product line?
SELECT product_line, COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;

-- What is the total revenue by month?
SELECT month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the highest COGS (cost of goods sold)?
SELECT month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,
	SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What city had the highest revenue?
SELECT branch, city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line,
	AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Which branch sold more products than the average products sold?
SELECT branch, 
	SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT gender, product_line,
	COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT ROUND(AVG(rating) , 2) AS avg_rating, product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ---------------------------------------------------------------------------------------
-- ------------------------------- Sales ---------------------------------------------

-- Number of sales made in each time of day per weekday.
SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings in the most revenue?
SELECT customer_type, SUM(total) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- Which city has the largest tax percent/VAT (value after tax)?
SELECT city, AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ----------------------------------------------------------------------------
-- -------------------------------- Customers ---------------------------------

-- How Many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales;

-- How many unique payment types does the data have?
SELECT DISTINCT payment_method
FROM sales;

-- What is the most common customer type?
SELECT DISTINCT customer_type, COUNT(*) AS total_cust
FROM sales
GROUP BY customer_type
ORDER BY total_cust DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*) AS cstm_cnt
FROM sales
GROUP BY customer_type;

-- What gender shops the most?
SELECT gender, COUNT(*) AS gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender DESC;

-- What is the gender distrubition per branch?
SELECT gender, COUNT(*) AS gender_cnt
FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender DESC;

-- What time of day do customers give the most ratings?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of day do customers give the most ratings per branch?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'B'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best rating?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating;

-- Which day of the week has the best average rating per branch?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY avg_rating;


-- ----------------------------------------------------------------------------