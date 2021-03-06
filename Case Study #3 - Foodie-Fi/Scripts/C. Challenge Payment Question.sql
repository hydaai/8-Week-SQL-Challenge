-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
/*	- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
	- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
	- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
	- once a customer churns they will no longer make payments. */
WITH
	join_table --create base table
		AS
	(
		select 
			s.customer_id,
			s.plan_id,
			p.plan_name,
			s.start_date payment_date,
			s.start_date,
			LEAD(s.start_date, 1) OVER(PARTITION BY s.customer_id ORDER BY s.start_date, s.plan_id) next_date,
			p.price amount
		from subscriptions s
		left join plans p on p.plan_id = s.plan_id
	),
		new_join --filter table (deselect trial and churn)
		AS
	(
		select 
			customer_id,
			plan_id,
			plan_name,
			payment_date,
			start_date,
			case when next_date IS NULL or next_date > '20201231' then '20201231' else next_date end next_date,
			amount
		from join_table
		where plan_name not in ('trial', 'churn')
	),
		new_join1 --add new column, 1 month before next_date
		AS
	(
		select 
			customer_id,
			plan_id,
			plan_name,
			payment_date,
			start_date,
			next_date,
			DATEADD(MONTH, -1, next_date) next_date1,
			amount
		from new_join
	),
	Date_CTE  --recursive function (for payment_date)
		AS
	(
		SELECT 
			customer_id,
			plan_id,
			plan_name,
			start_Date,
			payment_date = (select top 1 start_Date FROM new_join1 where customer_id = a.customer_id and plan_id = a.plan_id),
			next_date, 
			next_date1,
			amount
		FROM new_join1 a

			UNION ALL 
    
		SELECT 
			customer_id,
			plan_id,
			plan_name,
			start_Date, 
			DATEADD(M, 1, payment_date) payment_date,
			next_date, 
			next_date1,
			amount
		FROM Date_CTE b
		WHERE payment_date < next_date1 and plan_id != 3
)
SELECT 
	customer_id,
	plan_id,
	plan_name,
	payment_date,
	amount,
	RANK() OVER(PARTITION BY customer_id ORDER BY customer_id, plan_id, payment_date) payment_order
FROM Date_CTE
WHERE YEAR(payment_date) = 2020
order by customer_id, plan_id, payment_date;
