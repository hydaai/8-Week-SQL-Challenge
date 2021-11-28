# <p align="center" style="margin-top: 0px;">🍕 Case Study #2 - Pizza Runner 🍕
## <p align="center"> C. Ingredient Optimisation

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Scripts).

***

## 1. *What are the standard ingredients for each pizza?*

```sql
select 
	n.pizza_name,
	STRING_AGG(t.topping_name,', ') ingredients
from #pizza_names n
left join #pizza_recipes r on n.pizza_id = r.pizza_id
left join #pizza_toppings t on r.toppings = t.topping_id
group by n.pizza_name;

```

#### Answer:
pizza_name | ingredients
-- | --
Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
  
- Standard ingredients for Meat Lovers pizza are: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami.
- Standard ingredients for Vegetarian pizza are: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce.

***

## 2. What was the most commonly added extra?*

```sql
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
```

#### Answer:
topping_id | topping_name | added
-- | -- | --
1 | Bacon | 4
4 | Cheese | 1
5 | Chicken | 1
  
- The most commonly added extra is Bacon.

***

## 3. *What was the most common exclusion?*

```sql
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
having COUNT(c.exclusions) <> 0
order by t.topping_id;
```

#### Answer:
topping_id | topping_name | removed
-- | -- | --
4 | Cheese | 2
2 | BBQ Sauce | 1
6 | Mushrooms | 1
  
- The most commonly exclusion is Cheese.

***

## 4. *Generate an order item for each record in the customers_orders table in the format of one of the following:*
	- Meat Lovers. 
	- Meat Lovers - Exclude Beef. 
	- Meat Lovers - Extra Bacon. 
	- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers 

```sql
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
```

#### Answer:
order_id | customer_id | pizza_id | exclusions | extras | order_time | order_item
-- | -- | -- | -- | -- | -- | --
1 | 101 | 1 |  |  | 2020-01-01 18:05:02.000 | Meatlovers  
2 | 101 | 1 |  |  | 2020-01-01 19:00:52.000 | Meatlovers  
3 | 102 | 1 |  |  | 2020-01-02 23:51:23.000 | Meatlovers  
3 | 102 | 2 |  |  | 2020-01-02 23:51:23.000 | Vegetarian  
4 | 103 | 1 | 4 |  | 2020-01-04 13:23:46.000 | Meatlovers - Exclude Cheese 
4 | 103 | 1 | 4 |  | 2020-01-04 13:23:46.000 | Meatlovers - Exclude Cheese 
4 | 103 | 2 | 4 | | 2020-01-04 13:23:46.000 | Vegetarian - Exclude Cheese 
5 | 104 | 1 |  | 1 | 2020-01-08 21:00:29.000 | Meatlovers  - Extra Bacon
6 | 101 | 2 |  |  | 2020-01-08 21:03:13.000 | Vegetarian  
7 | 105 | 2 |  | 1 | 2020-01-08 21:20:29.000 | Vegetarian  - Extra Bacon
8 | 102 | 1 |  |  | 2020-01-09 23:54:33.000 | Meatlovers  
9 | 103 | 1 | 4 | 1, 5 | 2020-01-10 11:22:59.000 | Meatlovers - Exclude Cheese - Extra Bacon, Chicken
10 | 104 | 1 |  |  | 2020-01-11 18:34:49.000 | Meatlovers  
10 | 104 | 1 | 2, 6 | 1, 4 | 2020-01-11 18:34:49.000 | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese
  
- Order item column has been added.

***

## 5. *Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients.*
	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
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
```

#### Answer:
order_id | customer_id | pizza_id | exclusions | extras | order_time | ingredient_list
-- | -- | -- | -- | -- | -- | --
1 | 101 | 1 |  |  | 2020-01-01 18:05:02.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
2 | 101 | 1 |  |  | 2020-01-01 19:00:52.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
3 | 102 | 1 |  |  | 2020-01-02 23:51:23.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
3 | 102 | 2 |  |  | 2020-01-02 23:51:23.000 | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
4 | 103 | 1 | 4 |  | 2020-01-04 13:23:46.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami
4 | 103 | 1 | 4 |  | 2020-01-04 13:23:46.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami
4 | 103 | 2 | 4 | | 2020-01-04 13:23:46.000 | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
5 | 104 | 1 |  | 1 | 2020-01-08 21:00:29.000 | Meatlovers: 2x Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
6 | 101 | 2 |  |  | 2020-01-08 21:03:13.000 | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
7 | 105 | 2 |  | 1 | 2020-01-08 21:20:29.000 | Vegetarian: Bacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce
8 | 102 | 1 |  |  | 2020-01-09 23:54:33.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
9 | 103 | 1 | 4 | 1, 5 | 2020-01-10 11:22:59.000 | Meatlovers: 2x Bacon, BBQ Sauce, Beef, 2x Chicken, Mushrooms, Pepperoni, Salami
10 | 104 | 1 |  |  | 2020-01-11 18:34:49.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami
10 | 104 | 1 | 2, 6 | 1, 4 | 2020-01-11 18:34:49.000 | Meatlovers: 2x Bacon, Beef, 2x Cheese, Chicken, Pepperoni, Salami
  
- Ingredient list column has been added.

***

## 6. *What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?*

```sql
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
```

#### Answer:
topping_id | topping_name | counts
-- | -- | --
4 | Cheese | 9
6 | Mushrooms | 9
1 | Bacon | 8
2 | BBQ Sauce | 8
3 | Beef | 8
5 | Chicken | 8
8 | Pepperoni | 8
10 | Salami | 8
7 | Onions | 1
9 | Peppers | 1
11 | Tomatoes | 1
12 | Tomato Sauce | 1
  
- Cheese and Mushrooms used 9 times.
- Bacon, BBQ Sauce, Beef, Chicken, Pepperoni, Salami used 8 times.
- Onions, Peppers, Tomatoes, Tomato Sauce used 1 time.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
