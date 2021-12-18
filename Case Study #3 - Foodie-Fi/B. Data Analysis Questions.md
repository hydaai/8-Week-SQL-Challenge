# <p align="center" style="margin-top: 0px;">🥑 Case Study #3 - Foodie-Fi 🥑
## <p align="center"> B. Data Analysis Question

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/Scripts).

***

### 1. *How many customers has Foodie-Fi ever had?*

#### Steps:
- Use **COUNT** and **GROUP BY** to find the `number` of customer.

````sql
select 
	count(distinct customer_id) total_customers
from subscriptions;
````


#### Answer:
|total_customers|
| -- |
|1000|

- 1000's of Foodie-Fi customers.

***

## 2. *What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value*

#### Steps:
- Extract month from `start_date` can use **DATEPART**, **DATENAME** or **MONTH**
- Use **COUNT** and **GROUP BY** to find the `number of monthly distribution` of trial plan.

````sql
select 
	DATEPART(M, start_date) monthly_part,
	DATENAME(M, start_date) monthly_name,
	count(start_date) total_distribution
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'trial'
group by DATEPART(M, start_date), DATENAME(M, start_date)
order by monthly_part;
````


#### Answer:
monthly_part | monthly_name | total_distribution
-- | -- | --
1 | January | 88
2 | February | 68
3 | March | 94
4 | April | 81
5 | May | 88
6 | June | 79
7 | July | 89
8 | August | 88
9 | September | 87
10 | October | 79
11 | November | 75
12 | December | 84

- 68 free trial plan start in February.
- 75 free trial plan start in November.
- 79 free trial plans start in June and October.
- 81 free trial plan start in April.
- 84 free trial plan start in December.
- 87 free trial plan start in September.
- 88 free trial plans start in January, May and August.
- 89 free trial plan start in July.
- 94 free trial plan start in March.

***


## 3. *What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name*

#### Steps:
- Extract year  from `start_date` can use **DATEPART** or **YEAR**
- Use **COUNT** and **GROUP BY** to find the `event count` for each `plan_name`
- Fetch data for 2020 and 2021 separately.
	
***NOTE*** : *2020 data, shown for comparison with 2021 data (year-on-year).*

````sql
WITH
	plants_2021 --plan 2021
		AS
	(
		SELECT 
			s.plan_id, 
			p.plan_name,
			count(s.start_date) events_2021
		FROM subscriptions s
		LEFT JOIN plans p on p.plan_id = s.plan_id
		WHERE YEAR(s.start_date) > 2020
		GROUP BY s.plan_id, p.plan_name
	),
	plants_2020 --plan 2020
		AS
	(
		SELECT 
			s.plan_id, 
			p.plan_name,
			count(s.start_date) events_2020
		FROM subscriptions s
		LEFT JOIN plans p on p.plan_id = s.plan_id
		WHERE YEAR(s.start_date) = 2020
		GROUP BY s.plan_id, p.plan_name
	)
SELECT 
	a.plan_name,
	a.events_2020,
	b.events_2021
FROM plants_2020 a
LEFT JOIN plants_2021 b on a.plan_id = b.plan_id
order by a.plan_id;
````


#### Answer:
plan_name | events_2020 | events_2021
-- | -- | --
trial | 1000 | NULL
basic monthly | 538 | 8
pro monthly | 479 | 60
pro annual | 195 | 63
churn | 236 | 71

- In 2021 there will be no new customers, this can be seen from null on trial.
- In 2021 fewer customers buy plans, or because the data shown is only until April 2021?

***

## 4. *What is the customer count and percentage of customers who have churned rounded to 1 decimal place?*

#### Steps:
- Churn customers are shared with all customers.

````sql
select 
	cast(count(distinct customer_id) as numeric) total_churn,
	round(100 * cast(count(distinct customer_id) as float) / 
		(select count(distinct customer_id) 
		from subscriptions), 1) percentage_churn
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'churn';
````


#### Answer:
total_churn | percentage_churn
-- | --
307 | 30.7

- 307 customers churn, which means 30.7% of the total.

***

## 5. *How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?*

#### Steps:
- Use **RANK** to find out the order based on `start_date` and `plan_id`.
- Churn customers are shared with all customers.

````sql
WITH ranking  --create rank plan
	AS
(
	select *, 
		RANK() OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) rank
	from subscriptions
)
select 
	count(distinct customer_id) total_churn,
	(100 * count(distinct customer_id) / 
		(select count(distinct customer_id) 
		from subscriptions)) percentage_churn
from ranking s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'churn' and s.rank = 2;
````


#### Answer:
total_churn | percentage_churn
-- | --
92 | 9

- 92 customers directly churned after the initial free trial, which means 9% of the total.

***

## 6. *What is the number and percentage of customer plans after their initial free trial?*

#### Steps:
- Use **LEAD** to find the next date after initial `start_date`
- Customers each plan is shared with all customers.

````sql
WITH
	next_plan --create next_date plan
		AS
	(
		select *, 
			LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) plans
		from subscriptions
	), 
	planning --create number and percentage
		AS
	(
		select 
			s.plans,
			count(distinct customer_id) total,
			(100 * cast(count(distinct customer_id)as float) / 
				(select count(distinct customer_id)
				from subscriptions)) percentage
		from next_plan s
		left join plans p on p.plan_id = s.plans
		where s.plan_id = 0 
			and s.plans is not null
		group by s.plans
		)
select
	p.plan_name, 
	s.total, 
	s.percentage
from planning s
left join plans p on p.plan_id = s.plans;
````


#### Answer:
plan_name | total | percentage
-- | -- | --
basic monthly | 546 | 54.6
pro monthly | 325 | 32.5
pro annual | 37 | 3.7
churn | 92 | 9.2

After their initial free trial:
 - 546 customers bought basic monthly plan (54.6%).
 - 325 customers bought pro monthly plan (32.5%).
 - 37 customers bought pro annual plan (3.7%).
 - 92 customers directly churn (9.2%).

***

## 7. *What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?*

#### Steps:
- Use **LEAD** to find the next date after initial `start_date`
- Fetch data before 2021-01-01
- Customers each plan is shared with all customers.

````sql
WITH
	next_plan --create next_date plan
		AS
	(
		select *, 
			LEAD(start_date, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) next_date
		from subscriptions
		where start_date <= '20201231'
	), 
	breakdown --breakdown plan
		AS
	(
		select 
			plan_id,
			cast(count(distinct customer_id) as float) total,
			cast((select count(distinct customer_id) from subscriptions) as float) total_all
		from next_plan s
		where next_date IS NULL
		group by plan_id
		)
select
	p.plan_name, 
	s.total, 
	ROUND(s.total / s.total_all * 100, 1) percentage
from breakdown s
left join plans p on p.plan_id = s.plan_id
order by s.plan_id;
````


#### Answer:
plan_name | total | percentage
-- | -- | --
trial | 19 | 1.9
basic monthly | 224 | 22.4
pro monthly | 326 | 32.6
pro annual | 195 | 19.5
churn | 236 | 23.6

Customer plan at 2020-12-31:
 - 224 customers still on trial plan (1.9%).
 - 326 customers bought basic monthly plan (22.4%).
 - 195 customers bought pro monthly plan (32.6%).
 - 195 customers bought pro annual plan (19.5%).
 - 236 customers churn (23.6%).

***

## 8. *How many customers have upgraded to an annual plan in 2020?*

#### Steps:
- Use **COUNT** and **GROUP BY** to find the `number` of customers have annual plan in 2020.

````sql
select 
	count(distinct s.customer_id) total_customers
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'pro annual'
	and YEAR(s.start_date) = 2020;
````


#### Answer:
|total_customers|
| -- |
|195|

- 195 customers upgrade to annual plan.

***

## 9. *How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?*

#### Steps:
- Assuming join date same as trial start date, fetch data for trial and annual plan separately
- Use **DATEDIFF** to extract days from the difference between trial and annual `start date`
- Use **AVG** to find the `average` length of days it takes to buy an annual plan.

````sql
WITH
	trial --trial plan
		AS
	(
		select 
			s.customer_id,
			s.start_date trial_date
		from subscriptions s
		left join plans p on p.plan_id = s.plan_id
		where p.plan_name = 'trial'
	),
	annual --annual plan
		AS
	(
		select 
			s.customer_id,
			s.start_date annual_date
		from subscriptions s
		left join plans p on p.plan_id = s.plan_id
		where p.plan_name = 'pro annual'
	)
select
	AVG(DATEDIFF(D, t.trial_date, a.annual_date)) days
from trial t
left join annual a on t.customer_id = a.customer_id;
````


#### Answer:
|days|
| -- |
|104|

- On average, after 104 days the customer buys the annual plan.

***

## 10. *Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)*

#### Steps:
- Assuming join date same as trial start date, fetch data for trial and annual plan separately
- Use **DATEDIFF** to extract days from the difference between trial and annual `start date`
- Use **FLOOR** to return the largest integer that is less than or equal to the specified numeric expression
- Use **CONCAT** returns a string resulting from the concatenation.

````sql
WITH
	trial --trial plan
		AS
	(
		select 
			s.customer_id,
			s.start_date trial_date
		from subscriptions s
		left join plans p on p.plan_id = s.plan_id
		where p.plan_name = 'trial'
	),
	annual --annual plan
		AS
	(
		select 
			s.customer_id,
			s.start_date annual_date
		from subscriptions s
		left join plans p on p.plan_id = s.plan_id
		where p.plan_name = 'pro annual'
	),
	diff --day difference
		AS
	(
		select 
			DATEDIFF(D, t.trial_date, a.annual_date) days
		from trial t
		left join annual a on t.customer_id = a.customer_id
		where a.annual_date is not null
	),
	bucket --bucket
		AS
	(
		select *, 
			FLOOR(days/30) bucket
		from diff
	)
select
	CONCAT((bucket * 30) + 1, ' - ', (bucket + 1) * 30, ' days ') days,
	COUNT(days) total
from bucket
group by bucket;
````


#### Answer:
days | total
-- | --
1 - 30 days  | 48
31 - 60 days  | 25
61 - 90 days  | 33
91 - 120 days  | 35
121 - 150 days  | 43
151 - 180 days  | 35
181 - 210 days  | 27
211 - 240 days  | 4
241 - 270 days  | 5
271 - 300 days  | 1
301 - 330 days  | 1
331 - 360 days  | 1

After further breakdown, we have:
 - Most often customers buy after 1-30 days.
 - After 210 days, rarely a customer buys.
 - After 270 days, almost no customers buy.

***

## 11. *How many customers downgraded from a pro monthly to a basic monthly plan in 2020?*

#### Steps:
- Use **LEAD** to find the next date after initial `start_date`
- Use **COUNT** to find the `number` of customer downgraded plan.

````sql
WITH next_plan --create next_date plan
	AS
(
	select *, 
		LEAD(plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date, plan_id) plans
	from subscriptions
)
select 
	count(distinct customer_id) downgrade
from next_plan s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'pro monthly' and s.plans = 1;
````


#### Answer:
|downgrade|
| -- |
|0|

- No customer downgrade pro monthly to basic monthly plan.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
