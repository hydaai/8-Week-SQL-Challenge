# <p align="center" style="margin-top: 0px;">🛒 Case Study #5 - Data Mart 🛒
## <p align="center"> B. Data Exploration

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%235%20-%20Data%20Mart/Scripts).

***

## 1. *What day of the week is used for each week_date value?*

#### Steps:
- Find the day used for the `week_date` value using **DATEPART**.

````sql
select distinct
	DATENAME(WEEKDAY, week_date) day_name
from clean_weekly_sales;
````


#### Answer:

| day_name |
| -- |
| Monday |

- Monday is used for each week_date value.

***

## 2. *What range of week numbers are missing from the dataset?*

#### Steps:
- Assume 1 year has 52 weeks
- Look for which weeks are not in the dataset
- Find out how many weeks are missing in the dataset using **COUNT**.

````sql
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
````


#### Answer:

| weeks_missing |
| -- |
| 28 |

- There are 28 week numbers are missing.

***

## 3. *How many total transactions were there for each year in the dataset?*

#### Steps:
- Find out how many total transactions using **SUM**
- Use **GROUP BY** to separate results each year.

````sql
select
	calendar_year,
	SUM(transactions) total_transactions
from clean_weekly_sales
group by calendar_year
order by calendar_year;
````


#### Answer:

calendar_year | total_transactions
--| --
2018 | 346406460
2019 | 365639285
2020 | 375813651

- In 2018 there were 346406460 transactions.
- In 2019 there were 365639285 transactions.
- In 2020 there were 375813651 transactions.

***

## 4. *What is the total sales for each region for each month?*

#### Steps:
- Find out how many total sales using **SUM**
- Use **GROUP BY** to separate by region for each month.

````sql
select
	region,
	month_number,
	SUM(sales) total_sales
from clean_weekly_sales
group by region, month_number
order by region, month_number;
````


#### Answer:
***NOTE*** : *Not all output is displayed, considering the number of results and will take up space*	
region | month_number |  total_sales
-- | -- | --
AFRICA | 3 | 567767480
AFRICA | 4 | 1911783504
AFRICA | 5 | 1647244738
AFRICA | 6 | 1767559760
AFRICA | 7 | 1960219710
AFRICA | 8 | 1809596890
AFRICA | 9 | 276320987
ASIA | 3 | 529770793
ASIA | 4 | 1804628707
ASIA | 5 | 1526285399
ASIA | 6 | 1619482889
ASIA | 7 | 1768844756
ASIA | 8 | 1663320609
ASIA | 9 | 252836807

- In March, Africa had total sales of $567767480, while Asia $529770793.
- In April, Africa had total sales of $1911783504, while Asia $1804628707.

***


## 5. *What is the total count of transactions for each platform*

#### Steps:
- Use **WITH common_table_expression** to find total amount each customers per month
- Use **CTE** again to the opening and closing balance
- Use **CTE** again to find out the increase in percent
- Use **WHERE** to filter increase closing balance by more than 5%.

````sql
select
	platform,
	COUNT(*) total_transactions
from clean_weekly_sales
group by platform;
````


#### Answer:

platform | total_transactions
-- | --
Retail | 8568
Shopify | 8549

- Total transactions for Retail platforms are 8568 while Shopify is 8549.

***

## 6. *What is the percentage of sales for Retail vs Shopify for each month?*

#### Steps:
- Use **WITH common_table_expression** to find the total sales 
- Find out the percentage of Retail and Shopify sales each month.

````sql
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
````


#### Answer:
***NOTE*** : *Not all output is displayed, considering the number of results and will take up space*	
calendar_year | month_number | retail_percentage | shopify_percentage
2018 | 3 | 97.92 | 2.08
2018 | 4 | 97.93 | 2.07
2018 | 5 | 97.73 | 2.27
2018 | 6 | 97.76 | 2.24
2018 | 7 | 97.75 | 2.25
2018 | 8 | 97.71 | 2.29
2018 | 9 | 97.68 | 2.32

- In March 2018, the percentage of retail sales was 97.92% while Shopify was 2.08%.
- In April 2018, the percentage of retail sales was 97.93% while Shopify was 2.07%.

***

## 7. *What is the percentage of sales by demographic for each year in the dataset?*

#### Steps:
- Use **WITH common_table_expression** to find the total sales 
- Find out the percentage of sales by demographic for each year.

````sql
select
	demographic,
	calendar_year,
	ROUND(100 * SUM(sales) / 
			(select SUM(sales) from clean_weekly_sales), 2) percentage_of_sales
from clean_weekly_sales
group by demographic, calendar_year
order by demographic, calendar_year;
````


#### Answer:

calendar_year | couples_percentage | families_percentage | unknown_percentage
-- | -- | -- | --
2018 | 26.38 | 31.99 | 41.63
2019 | 27.28 | 32.47 | 40.25
2020 | 28.72 | 32.73 | 38.55

- In 2018, the percentage of sales by couples was 26.38%, families were 31.99% and unknown was 41.63%.
- In 2019, the percentage of sales by couples was 27.28%, families were 32.47% and unknown was 40.25%.
- In 2020, the percentage of sales by couples was 28.72%, families were 32.73% and unknown was 38.55%.

***

## 8. *Which age_band and demographic values contribute the most to Retail sales?*

#### Steps:
- Find out how many total sales using **SUM**
- - Find the percentage of the contribution
- Use **GROUP BY** to separate results each `age_band` and `demographic`.

````sql
select
	age_band,
	demographic,
	SUM(sales) retail_sales,
	ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER(), 2) contribute_percent
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by retail_sales desc;
````


#### Answer:

age_band | demographic | total_transactions | contribute_percent
-- | -- | -- | --
unknown | unknown | 16067285533 | 40.52
Retirees | Families | 6634686916 | 16.73
Retirees | Couples | 6370580014 | 16.07
Middle Aged | Families | 4354091554 | 10.98
Young Adults | Couples | 2602922797 | 6.56
Middle Aged | Couples | 1854160330 | 4.68
Young Adults | Families | 1770889293 | 4.47

- Unknown age_band and demographic are the most contribute to Retail sales (40.52%), 
  followed by Retirees-Families (16.73%) and followed by Retirees-Couples (16.07%).

***

## 9. *Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?*

#### Steps:
- Find the average of each sales divided by each transaction as `avg_transaction_row`
- Find average of total sales divided by total transactions as `avg_transaction_group`
- Compare `avg_transaction_row` with `avg_transaction_group`, which one is more accurate?

````sql
select
	calendar_year,
	platform,
	ROUND(AVG(avg_transaction), 2) avg_transaction_row,
	ROUND(SUM(sales)/SUM(transactions), 2) avg_transaction_group
from clean_weekly_sales
group by calendar_year, platform
order by calendar_year, platform;
````


#### Answer:

calendar_year | platform | avg_transaction_row | avg_transaction_group
-- | -- | -- | --
2018 | Retail | 42.91 | 36.56
2018 | Shopify | 188.28 | 192.48
2019 | Retail | 41.97 | 36.83
2019 | Shopify | 177.56 | 183.36
2020 | Retail | 40.64 | 36.56
2020 | Shopify | 174.87 | 179.03

- We can use the avg_transaction column to find the average transaction size for each year by platfrom.
- However, `avg_transaction_group` (total sales divided by total transactions) is more accurate.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
