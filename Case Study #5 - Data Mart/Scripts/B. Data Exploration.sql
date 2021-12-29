--1. What day of the week is used for each week_date value?
select distinct
	DATENAME(WEEKDAY, week_date) day_name
from clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?
WITH
	week_no --assume 1 year has 52 weeks
AS
	(
		SELECT top 52 
			ROW_NUMBER() OVER(ORDER BY name) week_no 
		FROM master.sys.all_columns
	)
select 
	COUNT(n.week_no) weeks_missing
from week_no n
left join clean_weekly_sales c on n.week_no = c.week_number
where c.week_number is null;

--3. How many total transactions were there for each year in the dataset?
select
	calendar_year,
	SUM(transactions) total_transactions
from clean_weekly_sales
group by calendar_year
order by calendar_year;

--4. What is the total sales for each region for each month?
select
	region,
	month_number,
	SUM(sales) total_sales
from clean_weekly_sales
group by region, month_number
order by region, month_number;

--5. What is the total count of transactions for each platform
select
	platform,
	COUNT(*) total_transactions
from clean_weekly_sales
group by platform;

--6. What is the percentage of sales for Retail vs Shopify for each month?
WITH 
	sales
AS
	(
		select
			calendar_year,
			month_number,
			platform,
			SUM(sales) total_sales
		from clean_weekly_sales
		group by calendar_year, month_number, platform
	)
select
	calendar_year,
	month_number,
	ROUND(100 * MAX(case when platform = 'Retail' 
		then total_sales else NULL end)/ SUM(total_sales), 2) retail_percentage,
	ROUND(100 * MAX(case when platform = 'Shopify' 
		then total_sales else NULL end)/ SUM(total_sales), 2) shopify_percentage
from sales
group by calendar_year, month_number
order by calendar_year, month_number;

--7. What is the percentage of sales by demographic for each year in the dataset?
WITH 
	sales
AS
	(
		select
			calendar_year,
			demographic,
			SUM(sales) total_sales
		from clean_weekly_sales
		group by calendar_year, demographic
	)
select
	calendar_year,
	ROUND(100 * MAX(case when demographic = 'Couples' 
		then total_sales else NULL end)/ SUM(total_sales), 2) couples_percentage,
	ROUND(100 * MAX(case when demographic = 'Families' 
		then total_sales else NULL end)/ SUM(total_sales), 2) families_percentage,
	ROUND(100 * MAX(case when demographic = 'unknown' 
		then total_sales else NULL end)/ SUM(total_sales), 2) unknown_percentage
from sales
group by calendar_year
order by calendar_year;

--8. Which age_band and demographic values contribute the most to Retail sales?
select
	age_band,
	demographic,
	SUM(sales) retail_sales,
	ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER(), 2) contribute_percent
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by retail_sales desc;

--9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
select
	calendar_year,
	platform,
	ROUND(AVG(avg_transaction), 2) avg_transaction_row,
	ROUND(SUM(sales)/SUM(transactions), 2) avg_transaction_group
from clean_weekly_sales
group by calendar_year, platform
order by calendar_year, platform;
