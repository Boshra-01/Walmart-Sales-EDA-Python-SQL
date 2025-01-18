-- basic queries:
SHOW DATABASES;
SHOW tables;
SELECT * from walmart;
SELECT DISTINCT payment_method FROM walmart;
SHOW COLUMNS FROM walmart;

-- convert all column names into lowercase, otherwise it'll cause issues querying in MySQL df.columns = df.columns.str.lower()
ALTER TABLE walmart
CHANGE Branch branch text,
CHANGE City city text;

-- show all branches
SELECT branch from walmart;
-- show distinct all branches
SELECT count(distinct branch) from walmart;
-- show max quantity of product someone bought
SELECT MAX(quantity) as max_quantity from walmart;

-- -- -- -- Analysis -- -- -- --

-- Q1: Count how much payment have been done each way?
SELECT payment_method, count(*) 
FROM walmart GROUP BY payment_method;

-- Q2: (for each payment) find different payment methods, no of transactions, no of qunatity sold?
SELECT payment_method, count(*) as no_payment,
SUM(quantity) as sold
FROM walmart GROUP BY payment_method;

-- Q3: identity the highest rated category in each branch, displaying the branch, category and the average rating
SELECT * from walmart;
SELECT branch, category, AVG(rating) as average_rating 
FROM walmart
GROUP BY branch, category
-- additional command for descending, specifically desc by branch-wise
ORDER BY branch, AVG(rating) DESC;    -- alternative: ORDER BY 1, 3 DESC

-- Q4: set a ranking column alongside rating to see which category ranked 1st in each branch
SELECT branch, category, AVG(rating) as average_rating,
RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as ranking
FROM walmart
GROUP BY branch, category;

-- Q5: Getting only the 1st ranked categories from each branch?
SELECT *
FROM (
    SELECT branch, category, AVG(rating) AS average_rating,
           RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
    FROM walmart
    GROUP BY branch, category
) AS ranked_data
WHERE ranking = 1;

-- Q6: Identify the busiest day for each branch based on the number of transactions?
-- preprocess date: convert the textual DATE column type to Date type and get the day name:

-- getting the dates only:
SELECT 
    date,
    DAYNAME(STR_TO_DATE(date, '%m/%d/%y')) AS which_day -- STR_TO_DATE.../%y:Converts date string in format DD/MM/YY into a MySQL DATE type.
FROM walmart;

-- getting the branches:
SELECT 
    branch,
    DAYNAME(STR_TO_DATE(date, '%m/%d/%y')) AS which_day, -- STR_TO_DATE.../%y:Converts date string in format DD/MM/YY into a MySQL DATE type.
	COUNT(*) as no_transactions
FROM walmart
GROUP BY 1,2;

-- Q7: Branch with highest transactions?
SELECT 
    branch,
    DAYNAME(STR_TO_DATE(date, '%m/%d/%y')) AS which_day, -- STR_TO_DATE.../%y:Converts date string in format DD/MM/YY into a MySQL DATE type.
	COUNT(*) as no_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Q8: calculate the total quantity of items sold per payment method. List payment_method and the total quantity
SELECT payment_method,
SUM(quantity) as sold
FROM walmart GROUP BY payment_method;

-- Q9: determine the avg,min,max rating of category for each city | List the city, avg_rating, min_rating, max_rating
SELECT
	city,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
	AVG(rating) as avg_rating
from walmart
GROUP BY 1,2;

-- Q10: How much revenue each category is generating, based on their profit margins?
SELECT 
    category,
    SUM(total_cost) AS total_revenue,
    SUM(total_cost * profit_margin) AS final_profit
FROM walmart
GROUP BY category;

-- Q11: Identify the Top 3 categories of products sold(based on quantity).
SELECT category, sum(quantity) as total_quantity
from walmart
GROUP BY category -- groups sales data by category, so the totals are calculated per category.
ORDER BY total_quantity DESC
LIMIT 3;

-- Q12: Total revenue for each payment method?
SELECT * from walmart;
SELECT payment_method, SUM(total_cost) as total_revenue -- sums total_cost values for all transactions grouped by payment method.
from walmart
GROUP BY payment_method; --  ensures the revenue is calculated separately for each payment method.

-- Q13: Total revenue by each branch made?
SELECT branch, SUM(total_cost) as total_rev_branch
from walmart
GROUP BY branch; -- ensures the revenue is calculated separately for each branch.

-- Q14: how often each payment method is used in 'each branch'?
SELECT branch, payment_method, 
count(*) as popular_payway -- counts the no of payments for each combination of branch and payment_method |also, Count() align with GROUP BY
from walmart
GROUP BY branch, payment_method -- groups transactions/paymnents by branch and payment method to count them separately for each
ORDER BY branch, popular_payway DESC; -- sorts the results for each branch by the highest usage count.

-- Q15: Top 5 branches on the busiest day?
SELECT branch, date, 
SUM(total_cost) AS total_revenue -- Sums the revenue for each branch on each date and shows the top 5 highest-revenue days.
FROM walmart
GROUP BY branch, date 
ORDER BY total_revenue DESC
LIMIT 3;


