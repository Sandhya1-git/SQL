####### Amazon Sales Data Analysis ######
-- Overview of Dataset --
-- The data consists of sales record of three cities/branch in Myanmar 
-- which are Naypyitaw, Yangon, Mandalay which took place in first quarter of year 2019 --
-- the data consists of 1000 rows and 17 columns --


-- Objective of Project --
-- The major aim of this project is to gain insight into the sales data of Amazon --
-- and to understand the different factors that affect sales of the different branches --
#-------------------------------------------------------------------------------------------------------#

-- Data Wrangling--
-- step.1] creating database and importing data using table data import wizard --

create database amazon;
use amazon;

select * from amazon 
limit 10;

-- step.2] checking null values and datatypes of columns --
describe amazon;

select count(*) as count_of_null_values from amazon 
where null;
#-------------------------------------------------------------------------------------------------------#

-- Feature Engineering --
-- adding new columns timeofday, dayname, monthname by extracting values from date and time column --
-- this will help to analyse sales based on month, day of week, time of day --- 

SET SQL_SAFE_UPDATES = 0;

alter table amazon
add time_of_day varchar(15) not null;

update amazon set time_of_day =
case 
	when hour(time) between 06 and 11 then 'Morning'
	when hour(time) between 12 and 17 then 'Afternoon'
	else 'Evening'
end;

alter table amazon
add day_name varchar(10) not null;

update amazon set day_name =
(select  dayname(date));

alter table amazon
add month_name varchar(10) not null;

update amazon set month_name =
(select monthname(date)); 

select * from amazon limit 10;
#-------------------------------------------------------------------------------------------------------#


-- Exploratory Data Analysis --
-- step.1] Creating new table named Amazon Sales by adding correct column names, datatypes, constraints while copying values from demo table Amazon --

-- step.2] Checking size of table, count of null values, unique values  in columns --

select count(*) as total_columns from information_schema.columns
where table_name ='Amazon';


select count(*) as total_rows from Amazon;

select count(*) as null_values from Amazon where null;

select * from count_unique_values; 

-- step.3] checking unique values in each categorical column -- 
select distinct(branch) branch from Amazon;
select distinct(city) city from Amazon;
select distinct(customer_type) customer_type from Amazon;
select distinct(gender) gender from Amazon;
select distinct(product_line) product_line from Amazon;
select distinct(payment_method) payment_method from Amazon;
select distinct(time_of_day) time_of_day from Amazon;
select distinct(day_name) day_name from Amazon;
select distinct(month_name) month_name from Amazon;
#-------------------------------------------------------------------------------------------------------#


-- Answering Questions --

# 1. What is the count of distinct cities in the dataset?
select count(distinct(city)) from Amazon;

# 2. For each branch, what is the corresponding city?
select distinct city, branch from Amazon;

# 3. What is the count of distinct product lines in the dataset?
select count(distinct(product_line)) from Amazon;

# 4. Which payment method occurs most frequently?
select payment_method, count(*) as occurance from Amazon 
group by payment_method 
order by occurance desc; 

# 5. Which product line has the highest sales?
select product_line, sum(quantity) as total_sales from Amazon 
group by product_line 
order by total_sales desc;

# 6. How much revenue is generated each month?
select month_name, sum(total) as monthly_revenue$ from Amazon
group by month_name
order by monthly_revenue$ desc;

# 7. In which month did the cost of goods sold reach its peak?
select month_name, sum(cogs) as cost_of_goods_sold from Amazon
group by month_name
order by cost_of_goods_sold desc;

# 8. Which product line generated the highest revenue?
select product_line, sum(total) as total_revenue$ from Amazon 
group by product_line 
order by total_revenue$ desc;

# 9. In which city was the highest revenue recorded?
select city, sum(total) as revenue$ from Amazon
group by city
order by revenue$ desc;

# 10. Which product line incurred the highest Value Added Tax?
select product_line, max(vat) highest_vat  from Amazon
group by product_line
order by highest_vat desc;

# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line, sum(total) as revenue, 
case 
	when sum(total) > (select sum(total)/count(distinct(product_line)) from Amazon) then 'Good'
    else 'Bad'
end performance
from Amazon
group by product_line;

#12. Identify the branch that exceeded the average number of products sold.
select branch, sum(quantity) as product_sold from Amazon
group by branch
having product_sold > (select sum(quantity)/count(distinct branch) as avg_quantity from Amazon);

#13. Which product line is most frequently associated with each gender?
with new as 
(select gender, product_line, count(*) as count from Amazon
group by gender, product_line),

max_count as 
(select max(count) from new group by gender)

select * from new 
where count in (select * from max_count) limit 2;

#14. Calculate the average rating for each product line.
select product_line, avg(rating) as avg_rating from Amazon
group by product_line; 

#15. Count the sales occurrences for each time of day on every weekday.
select day_name, time_of_day, count(*) sales from Amazon 
group by day_name, time_of_day
order by field(day_name, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'), 
field(time_of_day, 'Morning', 'Afternoon', 'Evening');
        
#16. Identify the customer type contributing the highest revenue.
select customer_type, sum(total) as revenue from Amazon 
group by customer_type
order by revenue desc;

#17. Determine the city with the highest VAT percentage.
select city, max('Tax_5%') as vat_percentage from Amazon
group by city 
order by vat_percentage desc; 

#18. Identify the customer type with the highest VAT payments.
select customer_type, max('Tax_5%') as vat_percentage from Amazon
group by customer_type 
order by vat_percentage desc;

#19. What is the count of distinct customer types in the dataset?
select count(distinct(customer_type)) as count_distinct_customer_type from Amazon;

#20. What is the count of distinct payment methods in the dataset?
select count(distinct(payment_method)) as count_distinct_payment from Amazon;

#21. Which customer type occurs most frequently?
select customer_type, count(*) as count from Amazon
group by customer_type
order by count desc;

#22. Identify the customer type with the highest purchase frequency.
select customer_type, sum(total) as purchase_frequency from Amazon
group by customer_type
order by purchase_frequency desc;

#23. Determine the predominant gender among customers.
select gender, count(*) as count from Amazon
group by gender 
order by count desc;

#24. Examine the distribution of genders within each branch. 
select branch, gender, count(*) as count from Amazon
group by branch, gender 
order by branch, gender;

#25. Identify the time of day when customers provide the most ratings.
select time_of_day, count(rating) as rating_count from Amazon
group by time_of_day
order by rating_count desc;

#26. Determine the time of day with the highest customer ratings for each branch.
select branch, time_of_day, max(rating) highest_rating from Amazon
group by branch, time_of_day
having highest_rating = (select max(x.max) from (select branch, time_of_day, max(rating) max from Amazon
group by branch, time_of_day) as x where x.branch= Amazon.branch)
order by branch;

#27. Identify the day of the week with the highest average ratings.
select day_name, avg(rating) as avg_rating from Amazon
group by day_name
order by avg_rating desc;

#28. Determine the day of the week with the highest average ratings for each branch.
with avg_rating as
(select branch, day_name, avg(rating) avg_rat from Amazon
group by branch, day_name),

max_rating as 
(select max(avg_rat) from avg_rating group by branch)

select branch, day_name, avg_rat as highest_avg_rat from avg_rating where avg_rat in (select * from max_rating);

#-------------------------------------------------------------------------------------------------------#

-- Key Findings from Amazon Sales Dataset --

#### Product Analysis: ###
-- Highest Sales Product Line: Electronic Accessories (Units Sold:971) --
-- Highest Revenue Product Line: Food and Beverages ($ 56144.96)--
-- Lowest Sales Product Line: Health and Beauty (Unit Sold: 854) --
-- Lowest Revenue Product Line: Health and Beauty ($ 49193.84) --

#### Sales Analysis: ####
-- Month With Highest Revenue: January ($ 116292.11) --
-- City & Branch With Highest Revenue: Naypyitaw[C] ($ 110568.86)--
-- Month With Lowest Revenue: February ($ 97219.58) --
-- City & Branch With Lowest Revenue: Mandalay[B] ($ 106198.00) --
-- Peak Sales Time Of Day: Afternoon --
-- Peak Sales Day Of Week: Saturday --

#### Customer Analysis: ####
-- Most Predominant Gender: Female --
-- Most Predominant Customer Type: Member --
-- Highest Revenue Gender: Female ($ 167883.26) --
-- Highest Revenue Customer Type: Member ($ 164223.81) --
-- Most Popular Product Line (Male): Health and Beauty --
-- Most Popular Product Line (Female): Fashion Accessories --
-- Distribution Of Members Based On Gender: Male(240) Female(261) --
-- Sales Male: 2641 units --
-- Sales Female: 2869 units --
#-------------------------------------------------------------------------------------------------------#

#Thank You#

