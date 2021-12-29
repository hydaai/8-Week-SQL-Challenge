# <p align="center" style="margin-top: 0px;">🛒 Case Study #5 - Data Mart 🛒
## <p align="center"> C. Before & After Analysis

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Scripts).

***
### *Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.*
  ***We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.
  Using this analysis approach - answer the following questions:***
  1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
  2. What about the entire 12 weeks before and after?
  3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

#### Steps:
- Take week_date value 2020-06-15 as the baseline week.
- Find out the total sales before after baseline week for 4 and 12 weeks.
- Compare these 2 periods before and after with previous years in 2018 and 2019.
- Find out what is the growth or reduction rate in actual values and percentage of sales.

## Answer

### *First, find the baseline week.*

````sql
select distinct
	week_number
from clean_weekly_sales
where week_date = '2020-06-15';
````

| week_number |
| -- |
| 25 |

Obtained the value `week_date` 2020-06-15 is in the 25th week. 
  Next, find the total sales for the 4 weeks before and after the baseline week. 
  Also look for the rate of growth or reduction in actual value and sales percentage.

````sql
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
````

sales_before | sales_after | difference | percentage
-- | -- | -- | --
2345878357 | 2318994169 | -26884188 | -1.15

Since the new sustainable packaging came into effect, 
	sales have fallen by $26884188 (-1.15%).
	Next in the same way look for the 12 weeks before and after.

````sql
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
````

sales_before | sales_after | difference | percentage
-- | -- | -- | --
7126273147 | 6973947753 | -152325394 | -2.14

Looks like the sales are down further to negative 2.14% (-$152325394).
	Finally compare these 2 periods before and after with previous years in 2018 and 2019.

````sql
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
````

calendar_year | sales_before4 | sales_after4 | difference4 | percentage4 | sales_before12 | sales_after12 | difference12 | percentage12
-- | -- | -- | -- | -- | -- | -- | -- | --
2018 | 2125140809 | 2129242914 | 4102105 | 0.19 | 6396562317 | 6500818510 | 104256193 | 1.63
2019 | 2249989796 | 2252326390 | 2336594 | 0.1 | 6883386397 | 6862646103 | -20740294 | -0.3
2020 | 2345878357 | 2318994169 | -26884188 | -1.15 | 7126273147 | 6973947753 | -152325394 | -2.14

When compared to previous years (with a 25th base week), 
	there is a slight difference in percentage between 2018 and 2019. 
	However, in 2020 there was a significant decline in sales (down to more than negative 1 percent).

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
