--Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
/*	- region
	- platform
	- age_band
	- demographic
	- customer_type */

--region
WITH
	weeks
AS
	(
		select
			region,
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
		group by region
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks
order by percentage;

--platform
WITH
	weeks
AS
	(
		select
			platform,
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
		group by platform
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks
order by percentage;

--age_band
WITH
	weeks
AS
	(
		select
			age_band,
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
		group by age_band
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks
order by percentage;

--demographic
WITH
	weeks
AS
	(
		select
			demographic,
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
		group by demographic
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks
order by percentage;

--customer_type
WITH
	weeks
AS
	(
		select
			customer_type,
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
		group by customer_type
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks
order by percentage;

--all of the business areas
WITH
	weeks
AS
	(
		select
			region,
			platform,
			age_band,
			demographic,
			customer_type,
			SUM(case when week_number between 13 and 24 then sales end) sales_before,
			SUM(case when week_number between 25 and 36 then sales end) sales_after
		from clean_weekly_sales
		where calendar_year = 2020
		group by region, platform, age_band, demographic, customer_type
	)
select *,
	sales_after - sales_before difference,
	ROUND(100 * (sales_after - sales_before)/sales_before,2) percentage
from weeks
order by percentage;
