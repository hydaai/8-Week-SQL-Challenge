--Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
select distinct
	week_number
from clean_weekly_sales
where week_date = '2020-06-15';

--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
WITH
	weeks
AS
	(
		select
			SUM(case when week_number between 21 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 28 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks;

--2. What about the entire 12 weeks before and after?
WITH
	weeks
AS
	(
		select
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks;

--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH
	weeks
AS
	(
		select
		calendar_year,
			SUM(case when week_number between 21 and 24 then sales end) sales_before4,
			SUM(case when week_number between 25 and 28 then sales end) sales_after4,
			SUM(case when week_number between 13 and 24 then sales end) sales_before12,
			SUM(case when week_number between 25 and 36 then sales end) sales_after12
		from clean_weekly_sales
		group by calendar_year
	)
select calendar_year,
	sales_before4, sales_after4,
	sales_after4 - sales_before4 difference4,
	ROUND(100 * (sales_after4 - sales_before4)/sales_before4,2) percentage4,
	sales_before12, sales_after12,
	sales_after12 - sales_before12 difference12,
	ROUND(100 * (sales_after12 - sales_before12)/sales_before12,2) percentage12
from weeks
order by calendar_year;
