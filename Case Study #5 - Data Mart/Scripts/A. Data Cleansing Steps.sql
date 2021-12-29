--In a single query, perform the following operations and generate a new table named clean_weekly_sales:
/*	- Convert the week_date to a DATE format
	- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
	- Add a month_number with the calendar month for each week_date value as the 3rd column
	- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
	- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value: 1 = Young Adults, 2 = Middle Aged, 3 or 4 = Retirees
	- Add a new demographic column using the following mapping for the first letter in the segment values: C = Couples, F = Families
	- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
	- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record */
select 'Data Cleansing Steps' as title;
SET DATEFORMAT dmy;
DROP TABLE IF EXISTS clean_weekly_sales;
select 
	CAST(week_date as date) week_date,
	DATEPART(WEEK, CAST(week_date as date)) week_number,
	DATEPART(M, CAST(week_date as date)) month_number,
	DATEPART(YY, CAST(week_date as date)) calendar_year,
	region,
	platform,
	segment,
	case when RIGHT(segment, 1) = '1' then 'Young Adults'
		when RIGHT(segment, 1) = '2' then 'Middle Aged'
		when RIGHT(segment, 1) = '3' or RIGHT(segment, 1) = '4' then 'Retirees'
		else 'unknown' end age_band,
	case when LEFT(segment, 1) = 'C' then 'Couples'
		when LEFT(segment, 1) = 'F' then 'Families'
		else 'unknown' end demographic,
	customer_type,
	CAST(transactions as float) transactions,
	CAST(sales as float) sales,
	ROUND(CAST(sales as float)/CAST(transactions as float), 2) avg_transaction
into clean_weekly_sales
from weekly_sales;
select * from clean_weekly_sales;
