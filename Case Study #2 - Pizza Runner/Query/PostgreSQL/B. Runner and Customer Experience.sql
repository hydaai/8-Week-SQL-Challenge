-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--since in ISO 8601 the year starts on Monday in the week containing January 4th, adjust the week starting 2021-01-01 by adding 3 days
select 
	date_part('Week', registration_date + interval '3 day') weeks,
	count(runner_id) total
from runners
group by date_part('Week', registration_date + interval '3 day')
order by date_part('Week', registration_date + interval '3 day');

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH
	CTE
AS
	(
		select distinct 
			c.order_id, r.runner_id, date_part('MINUTE', r.pickup_time - c.order_time) times
		from customer_orders_new c
		left join runner_orders_new r on c.order_id = r.order_id
		where r.distance <> 0
	)
select 
	runner_id,
	AVG(times)::int times
from CTE
group by runner_id
order by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH
	CTE
AS
	(
		select distinct 
			c.order_id, COUNT(c.pizza_id) number_of_pizzas, c.order_time, r.pickup_time,
			date_part('MINUTE', r.pickup_time - c.order_time) times
		from customer_orders_new c
		left join runner_orders_new r on c.order_id = r.order_id
		where r.distance <> 0
		group by c.order_id, c.order_time, r.pickup_time
	)
select 
	number_of_pizzas,
	avg(times)::int order_prepare
from CTE
group by number_of_pizzas
order by number_of_pizzas;

-- 4. What was the average distance travelled for each customer?
select 
	c.customer_id,
	AVG(distinct r.distance) distance
from customer_orders_new c
left join runner_orders_new r on c.order_id = r.order_id
where r.distance <> 0
group by c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
select 
	MAX(duration) - min(duration) diff_delivery_time
from runner_orders_new
where duration <> 0;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
select distinct c.order_id, r.runner_id, COUNT(c.pizza_id) number_of_pizzas, 
		r.distance, r.duration, round((r.distance/r.duration*60)::numeric,2) speed
from customer_orders_new c
left join runner_orders_new r on c.order_id = r.order_id
where r.distance <> 0
group by c.order_id, r.runner_id, r.distance, r.duration
order by c.order_id;

-- 7. What is the successful delivery percentage for each runner?
select runner_id, 
		ROUND(100 * 
					SUM(case when distance <> 0 then 1 
							else 0 end)/COUNT(*),0) percentage
from runner_orders_new
group by runner_id
order by runner_id;
