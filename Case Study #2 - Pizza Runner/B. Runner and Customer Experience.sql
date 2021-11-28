-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SET DATEFIRST 5; --because January 1, 2021 is a Friday, specifies Friday as the first day of the week
select 
	datepart(WK, registration_date) weeks,
	count(runner_id) total
from runners
group by datepart(WK, registration_date);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select 
	runner_id,
	AVG(times) times
from 
	(
		select distinct 
			c.order_id, r.runner_id, 
			datediff(MINUTE, c.order_time, r.pickup_time) times
		from #customer_orders c
		left join #runner_orders r on c.order_id = r.order_id
		where r.distance <> 0
	)a
group by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
select 
	number_of_pizzas,
	avg(times) order_prepare
from 
	(
		select distinct 
			c.order_id, COUNT(c.pizza_id) number_of_pizzas, c.order_time, r.pickup_time, 
			datediff(MINUTE, c.order_time, r.pickup_time) times
		from #customer_orders c
		left join #runner_orders r on c.order_id = r.order_id
		where r.distance <> 0
		group by c.order_id, c.order_time, r.pickup_time
	)a
group by number_of_pizzas;

-- 4. What was the average distance travelled for each customer?
select 
	c.customer_id,
	AVG(distinct r.distance) distance
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by c.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
select 
	MAX(duration) - min(duration) diff_delivery_time
from #runner_orders
where duration <> 0;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
select distinct 
	c.order_id, r.runner_id, COUNT(c.pizza_id) number_of_pizzas, 
	r.distance, r.duration, round((r.distance/r.duration*60),2) speed
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by c.order_id, r.runner_id, r.distance, r.duration;

-- 7. What is the successful delivery percentage for each runner?
select 
	runner_id, 
	ROUND(100 * SUM(case when distance <> 0 then 1 
						else 0 end)/COUNT(*),0) percentage
from #runner_orders
group by runner_id;
