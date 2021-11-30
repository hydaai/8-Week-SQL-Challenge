-- 1. How many customers has Foodie-Fi ever had?
select 
	count(distinct customer_id) total_customers
from subscriptions;

--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
select 
	DATEPART(M, start_date) monthly_part,
	DATENAME(M, start_date) monthly_name,
	count(start_date) total_distribution
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'trial'
group by DATEPART(M, start_date), DATENAME(M, start_date)
order by monthly_part;

--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
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

--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
select 
	cast(count(distinct customer_id) as numeric) total_churn,
	round(100 * cast(count(distinct customer_id) as float) / 
		(select count(distinct customer_id) 
		from subscriptions), 1) percentage_churn
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'churn';

--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
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

--6. What is the number and percentage of customer plans after their initial free trial?
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

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
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

--8. How many customers have upgraded to an annual plan in 2020?
select 
	count(distinct s.customer_id) total_customers
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where p.plan_name = 'pro annual'
	and YEAR(s.start_date) = 2020;

--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
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

--10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
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
	CONCAT((bucket * 30) + 1, ' - ', (bucket + 1) * 30, ' days ') breakdown,
	COUNT(days) days
from bucket
group by bucket;

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
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
