-- 1. What are the standard ingredients for each pizza?
select 
	n.pizza_name,
	STRING_AGG(t.topping_name,', ') ingredients
from pizza_names_new n
left join pizza_recipes_new r on n.pizza_id = r.pizza_id
left join pizza_toppings_new t on r.toppings = t.topping_id
group by n.pizza_name;

-- 2. What was the most commonly added extra?
SELECT t.topping_id, t.topping_name, COUNT(c.extras) added
FROM pizza_toppings_new t 
left join (select distinct order_id, extras from customer_orders_split)c on t.topping_id = c.extras
group by t.topping_id, t.topping_name
having COUNT(c.extras) <> 0
order by t.topping_id;

-- 3. What was the most common exclusion?
SELECT t.topping_id, t.topping_name, COUNT(c.exclusions) removed
FROM pizza_toppings_new t 
left join (select distinct order_id, exclusions from customer_orders_split)c on t.topping_id = c.exclusions
group by t.topping_id, t.topping_name
having COUNT(c.exclusions) <> 0
order by t.topping_id;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following: Meat Lovers. Meat Lovers - Exclude Beef. Meat Lovers - Extra Bacon. Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH
	basic
AS
	(
		Select *,
			SPLIT_PART(CONCAT(exclusions, ', '), ', ', 1) exc1,
			SPLIT_PART(CONCAT(exclusions, ', '), ', ', 2) exc2,
			SPLIT_PART(CONCAT(extras, ', '), ', ', 1) ext1,
			SPLIT_PART(CONCAT(extras, ', '), ', ', 2) ext2
		from customer_orders_new
	),
	to_int
AS
	(
		Select 
			no, order_id, customer_id,pizza_id, 
			exclusions, extras, order_time,
			case when exc1 = '' then 0 else exc1::int end exc1,
			case when exc2 = '' then 0 else exc2::int end exc2,
			case when ext1 = '' then 0 else ext1::int end ext1,
			case when ext2 = '' then 0 else ext2::int end ext2
		from basic
	),
	to_text
AS
	(
		Select
			order_id, customer_id, a.pizza_id,
			exclusions, extras, order_time,
			case when exc1 = 0 then '' else exc1::text end exc1,
			case when exc2 = 0 then '' else exc2::text end exc2,
			case when ext1 = 0 then '' else ext1::text end ext1,
			case when ext2 = 0 then '' else ext2::text end ext2,
			n.pizza_name,
			tc1.topping_name tc1, tc2.topping_name tc2,
			tx1.topping_name tx1, tx2.topping_name tx2
		from to_int a
		left join pizza_names_new n on a.pizza_id = n.pizza_id
		left join pizza_toppings_new tc1 on a.exc1 = tc1.topping_id
		left join pizza_toppings_new tc2 on a.exc2 = tc2.topping_id
		left join pizza_toppings_new tx1 on a.ext1 = tx1.topping_id
		left join pizza_toppings_new tx2 on a.ext2 = tx2.topping_id
	),
	generate
AS
	(
		Select
			order_id, customer_id, pizza_id, exclusions, 
			extras, order_time, pizza_name,
			case when tc1 is null then ''
				when tc2 is null then CONCAT('- Exclude', ' ', tc1)
				else CONCAT('- Exclude', ' ', tc1, ', ', tc2)
				end exc,
			case when tx1 is null then ''
				when tx2 is null then CONCAT('- Extra', ' ', tx1)
				else CONCAT('- Extra', ' ', tx1, ', ', tx2)
				end ext
		from to_text
	)
SELECT
	order_id, customer_id, pizza_id, 
	exclusions, extras, order_time,
	CONCAT(pizza_name, ' ', exc, ' ', ext) order_item
FROM generate;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH 
	ALLIN
AS
	(
		select c.*, n.pizza_name, t.*, r.distance
		from customer_orders_split c
		left join pizza_names_new n on c.pizza_id = n.pizza_id
		left join pizza_recipes_new pr on c.pizza_id = pr.pizza_id
		left join pizza_toppings_new t on pr.toppings = t.topping_id
		left join runner_orders_new r on c.order_id = r.runner_id
	),
	exclusions_orders
AS
	(	-- split row in exclusions column
		SELECT distinct 
			no, order_id, customer_id, 
			pizza_id, pizza_name, exclusions
		FROM ALLIN
	),
	extras_orders
AS
	(	-- split row in extras column
		SELECT distinct 
			no, order_id, customer_id, 
			pizza_id, pizza_name, extras
		FROM ALLIN
		where extras != 0
	),
	A
AS
	(
		SELECT distinct 
			no, order_id, customer_id, 
			pizza_id, pizza_name, topping_id
		FROM ALLIN
	),
	CASES
AS
	(
			SELECT * FROM A
		EXCEPT
			SELECT * FROM exclusions_orders
		UNION ALL
			SELECT * FROM extras_orders
	),
	toppings_name
AS
	(
		SELECT c.*, t.topping_name
		FROM CASES c
		left join pizza_toppings_new t on c.topping_id = t.topping_id
	),
	numof_topping
AS
	(
		SELECT
			no, order_id, customer_id, pizza_id,
			pizza_name, topping_id, topping_name,
			COUNT(topping_id) counts
		FROM toppings_name
		GROUP BY no, order_id, customer_id, pizza_id,
			pizza_name, topping_id, topping_name
	),
	generate
AS
	(
		SELECT
			no, order_id, pizza_id, pizza_name, topping_id,
			CASE WHEN counts = 1 THEN topping_name 
				ELSE CONCAT(counts, 'x ',topping_name) END counts
		FROM numof_topping
	),	
	CTE
AS
	(
		SELECT
			no, order_id, pizza_id, pizza_name,
			STRING_AGG(counts, ', ') list
		FROM generate
		GROUP BY no, order_id, pizza_id, pizza_name
	)	
Select 
	c.order_id, cn.customer_id, cn.pizza_id, 
	cn.exclusions, cn.extras, cn.order_time,
	CONCAT(c.pizza_name, ': ', c.list) ingredient_list
FROM CTE c
LEFT JOIN customer_orders_new cn on cn.no = c.no
Order by c.no, c.order_id, c.pizza_id;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH 
	ALLIN
AS
	(
		select c.*, n.pizza_name, t.*, r.distance
		from customer_orders_split c
		left join pizza_names_new n on c.pizza_id = n.pizza_id
		left join pizza_recipes_new pr on c.pizza_id = pr.pizza_id
		left join pizza_toppings_new t on pr.toppings = t.topping_id
		left join runner_orders_new r on c.order_id = r.runner_id
	),
	exclusions_orders
AS
	(	-- split row in exclusions column
		SELECT distinct no, order_id, customer_id, pizza_id, pizza_name, exclusions
		FROM ALLIN
	),
	extras_orders
AS
	(	-- split row in extras column
		SELECT distinct no, order_id, customer_id, pizza_id, pizza_name, extras
		FROM ALLIN
		where extras != 0
	),
	A
AS
	(
		SELECT distinct no, order_id, customer_id, pizza_id, pizza_name, topping_id
		FROM ALLIN
	),
	CASES
AS
	(
			SELECT * FROM A
		EXCEPT
			SELECT * FROM exclusions_orders
		UNION ALL
			SELECT * FROM extras_orders
	),
	CTE
AS
	(
		SELECT c.*, t.topping_name
		FROM CASES c
		left join pizza_toppings_new t on c.topping_id = t.topping_id
		left join runner_orders_new r on c.order_id = r.order_id
		where r.distance != 0
	)
Select 
	topping_id, topping_name,
	COUNT(topping_id) counts
FROM CTE 
GROUP BY topping_id, topping_name
Order by counts desc, topping_id;
