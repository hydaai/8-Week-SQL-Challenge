-- 1. How many pizzas were ordered?
select 
	count(*) pizza_ordered
from customer_orders;

-- 2. How many unique customer orders were made?
select 
	count(distinct order_id) unique_ordered
from #customer_orders;

-- 3. How many successful orders were delivered by each runner?
select 
	runner_id,
	count(order_id) as orders
from #runner_orders
where distance <> 0
group by runner_id;

-- 4. How many of each type of pizza was delivered?
select 
	n.pizza_name,
	count(c.pizza_id) as delivered
from #pizza_names n
left join customer_orders c on n.pizza_id = c.pizza_id
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by n.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select 
	c.customer_id,
	sum(case when c.pizza_id = 1 then 1
		else 0 end) Meatlovers,
	sum(case when c.pizza_id = 2 then 1
		else 0 end) Vegetarian
from #pizza_names n
left join customer_orders c on n.pizza_id = c.pizza_id
group by c.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
select max(pizza) max_pizza
from 
	(
		select 
			c.order_id,
			count(c.order_id) as pizza
		from customer_orders c
		left join #runner_orders r on c.order_id = r.order_id
		where r.distance <> 0
		group by c.order_id
	)a;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select 
	c.customer_id,
	sum(case when c.exclusions <> '' or c.extras <> '' then 1
		else 0 end) at_least_1_change,
	sum(case when c.exclusions = '' and c.extras = '' then 1
		else 0 end) no_change
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by c.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
select 
	sum(case when c.exclusions <> '' and c.extras <> '' then 1
		else 0 end) delivered
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
select 
	datepart(HOUR, order_time) hour_of_day,
	count(order_id) total
from #customer_orders
group by datepart(HOUR, order_time);

-- 10. What was the volume of orders for each day of the week?
select 
	datename(DW, DATEADD(day, 2, order_time)) day_of_week, --adjust first day of week as Monday by adding 2
	count(order_id) total
from #customer_orders
group by datename(DW, DATEADD(day, 2, order_time)), datepart(DW, DATEADD(day, 2, order_time))
order by datepart(DW, DATEADD(day, 2, order_time));
