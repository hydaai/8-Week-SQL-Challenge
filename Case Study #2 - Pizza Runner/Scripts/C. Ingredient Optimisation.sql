/* 1. What are the standard ingredients for each pizza? */
select 
	n.pizza_name,
	STRING_AGG(t.topping_name,', ') ingredients
from #pizza_names n
left join #pizza_recipes r on n.pizza_id = r.pizza_id
left join #pizza_toppings t on r.toppings = t.topping_id
group by n.pizza_name;

/* 2. What was the most commonly added extra? */
SELECT 
	t.topping_id, 
	t.topping_name, 
	COUNT(c.extras) added
FROM #pizza_toppings t 
left join 
	(
		select distinct 
			order_id, 
			extras 
		from #customer_orders_split
	)c on t.topping_id = c.extras
group by t.topping_id, t.topping_name
having COUNT(c.extras) <> 0;

-- 3. What was the most common exclusion? */
SELECT 
	t.topping_id, 
	t.topping_name, 
	COUNT(c.exclusions) removed
FROM #pizza_toppings t 
left join 
	(
		select distinct 
			order_id, 
			exclusions 
		from #customer_orders_split
	)c on t.topping_id = c.exclusions
group by t.topping_id, t.topping_name
having COUNT(c.exclusions) <> 0;

select 'generate order item' as title
/* 4. Generate an order item for each record in the customers_orders table in the format of one of the following: 
	* Meat Lovers. 
	* Meat Lovers - Exclude Beef. 
	* Meat Lovers - Extra Bacon. 
	* Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
select 
	order_id, customer_id, pizza_id, exclusions, extras, order_time,
	CONCAT(pizza_name, ' ', exc, ' ', ext) order_item
from
	(
		select 
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
		from
			(
				select 
					order_id, customer_id, 
					a.pizza_id, exclusions, 
					extras, order_time,
					case when exc1 is null then '' else exc1 end exc1,
					case when exc2 is null then '' else exc2 end exc2,
					case when ext1 is null then '' else ext1 end ext1,
					case when ext2 is null then '' else ext2 end ext2
					, n.pizza_name
					, tc1.topping_name tc1, tc2.topping_name tc2
					, tx1.topping_name tx1, tx2.topping_name tx2
				from
					(
						select *,
							CAST(LEFT(exclusions, CHARINDEX(',', exclusions + ',') -1) as int) exc1,
							CAST(STUFF(exclusions, 1, Len(exclusions) +1- CHARINDEX(',',Reverse(exclusions)), '') as int) exc2,
							CAST(LEFT(extras, CHARINDEX(',', extras + ',') -1) as int) ext1,
							CAST(STUFF(extras, 1, Len(extras) +1- CHARINDEX(',',Reverse(extras)), '') as int) ext2
						from #customer_orders
					)a
				left join #pizza_names n on a.pizza_id = n.pizza_id
				left join #pizza_toppings tc1 on a.exc1 = tc1.topping_id
				left join #pizza_toppings tc2 on a.exc2 = tc2.topping_id
				left join #pizza_toppings tx1 on a.ext1 = tx1.topping_id
				left join #pizza_toppings tx2 on a.ext2 = tx2.topping_id
			)b
	)c;

select 'ingredient list' as title
/* 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */
SELECT
	f.order_id, cn.customer_id, cn.pizza_id, cn.exclusions, cn.extras, cn.order_time,
	CONCAT(f.pizza_name, ': ', f.list) ingredient_list
FROM 
	(
		SELECT
			no, order_id, pizza_id, pizza_name,
			STRING_AGG(counts, ', ') list
		FROM
			(
				SELECT
					no, order_id, pizza_id, pizza_name, topping_id,
					CASE WHEN counts = 1 THEN topping_name 
						ELSE CONCAT(counts, 'x ',topping_name) END counts
				FROM
					(
						SELECT
							no, order_id, customer_id, pizza_id,
							pizza_name, topping_id, topping_name,
							COUNT(topping_id) counts
						FROM 
						(
SELECT 
	b.*, t.topping_name
FROM
(
	SELECT 
		no, order_id, customer_id, 
		pizza_id, pizza_name, topping_id
	FROM
	(	-- orders ingredient recipes
		select c.no, c.order_id, c.customer_id, n.*, t.*
		from #customer_orders_no c
		left join #pizza_names n on c.pizza_id = n.pizza_id
		left join #pizza_recipes r on c.pizza_id = r.pizza_id
		left join #pizza_toppings t on r.toppings = t.topping_id
	)a
		EXCEPT
SELECT
	*
	FROM
	(	-- split row in exclusions column
		SELECT 
			c.no, c.order_id, c.customer_id, c.pizza_id, 
			n.pizza_name, cast(trim(value) as int) exclusions
		FROM #customer_orders_no c
		left join #pizza_names n on c.pizza_id = n.pizza_id
		CROSS APPLY STRING_SPLIT(c.exclusions, ',')
	)exclusions_orders
		UNION ALL
SELECT
	*
FROM
	(	-- split row in extras column
		SELECT 
			c.no, c.order_id, c.customer_id, c.pizza_id, 
			n.pizza_name, cast(trim(value) as int) extras
		FROM #customer_orders_no c
		left join #pizza_names n on c.pizza_id = n.pizza_id
		CROSS APPLY STRING_SPLIT(c.extras, ',')
		where cast(trim(value) as int) != 0
	)extras_orders
)b
left join #pizza_toppings t on b.topping_id = t.topping_id
						)c
						GROUP BY
							no, order_id, customer_id, pizza_id,
							pizza_name, topping_id, topping_name
					)d
			)e
		GROUP BY
			no, order_id, pizza_id, pizza_name
	)f
left join #customer_orders_no cn on cn.no = f.no
ORDER BY f.no, f.order_id, f.pizza_id;

select 'total quantity of each ingredient' as title
/* 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first? */
SELECT
	topping_id, topping_name,
	COUNT(topping_id) counts
						FROM 
						(
SELECT 
	b.*, t.topping_name
FROM
(
	SELECT 
		no, order_id, customer_id, pizza_id, 
		pizza_name, topping_id
	FROM
	(	-- orders ingredient recipes
		select 
			c.no, c.order_id, 
			c.customer_id, n.*, t.*
		from #customer_orders_no c
		left join #pizza_names n on c.pizza_id = n.pizza_id
		left join #pizza_recipes r on c.pizza_id = r.pizza_id
		left join #pizza_toppings t on r.toppings = t.topping_id
	)a
		EXCEPT
SELECT
	*
	FROM
	(	-- split row in exclusions column
		SELECT 
			c.no, c.order_id, c.customer_id, c.pizza_id, 
			n.pizza_name, cast(trim(value) as int) exclusions
		FROM #customer_orders_no c
		left join #pizza_names n on c.pizza_id = n.pizza_id
		CROSS APPLY STRING_SPLIT(c.exclusions, ',')
	)exclusions_orders
		UNION ALL
SELECT
	*
FROM
	(	-- split row in extras column
		SELECT 
			c.no, c.order_id, c.customer_id, c.pizza_id, 
			n.pizza_name, cast(trim(value) as int) extras
		FROM #customer_orders_no c
		left join #pizza_names n on c.pizza_id = n.pizza_id
		CROSS APPLY STRING_SPLIT(c.extras, ',')
		where cast(trim(value) as int) != 0
	)extras_orders
)b
left join #pizza_toppings t on b.topping_id = t.topping_id
left join #runner_orders r on b.order_id = r.runner_id
where r.distance != 0
						)c
GROUP BY topping_id, topping_name
Order by counts desc, topping_id;
