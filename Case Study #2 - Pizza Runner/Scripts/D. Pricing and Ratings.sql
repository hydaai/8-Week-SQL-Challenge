-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select 
	sum(case when pizza_id = 1 then 12
			when pizza_id = 2 then 10 end) money
from #customer_orders c
left join #runner_orders r on r.order_id = c.order_id
where distance != 0;

-- 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra
select 
	sum(money) profit
from
	(
		select 
			sum(case when pizza_id = 1 then 12
					when pizza_id = 2 then 10 end) money
		from #customer_orders c
		left join #runner_orders r on r.order_id = c.order_id
		where distance != 0
	UNION ALL
		select 
			sum(case when extras != 0 then 1 
					else 0 end) money
		from 
			(
				SELECT 
					pizza_id, 
					cast(trim(value) as int) extras
				FROM #customer_orders c
				left join #runner_orders r on r.order_id = c.order_id
				CROSS APPLY STRING_SPLIT(extras, ',')
				where distance != 0
		)a
	)b;

select 'create schema' as title
-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS #rating_orders;
CREATE TABLE #rating_orders (
  order_id INTEGER,
  rating INTEGER,
  review VARCHAR(max)
);

INSERT INTO #rating_orders
  (order_id, rating, review)
VALUES
  (1, 1, 'Really bad service'),
  (2, 2, null),
  (3, 4, 'Good service'),
  (4, 2, 'Pizza arrived cold and took long'),
  (5, 3, null),
  (7, 3, null),
  (8, 5, 'It was great, good service and fast'),
  (10, 4, 'Not bad');
select * from #rating_orders;

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? (customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas)
DROP TABLE IF EXISTS #generated_table;
select 
	c.customer_id, c.order_id, r.runner_id,
	ro.rating, c.order_time, r.pickup_time,
	DATEPART(MINUTE, r.pickup_time - c.order_time) time_between_order_and_pickup,
	r.duration delivery_duration,
	round(r.distance/r.duration * 60, 2) average_speed,
	count(*) Total_number_of_pizzas
into #generated_table
from #rating_orders ro
left join #customer_orders c on c.order_id = ro.order_id
left join #runner_orders r on ro.order_id = r.order_id
where r.distance != 0
group by c.customer_id, c.order_id, r.runner_id, ro.rating, c.order_time, r.pickup_time, r.distance, r.duration;
select * from #generated_table
order by order_id;

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
select 
	sum(money) money_left
from
	(
		select 
			sum(case when pizza_id = 1 then 12
					when pizza_id = 2 then 10 end) money
		from #customer_orders c
		left join #runner_orders r on r.order_id = c.order_id
		where distance != 0
	UNION ALL
		select 
			sum(distance) * -0.3 money
		from #runner_orders 
		where distance != 0
	)a;
