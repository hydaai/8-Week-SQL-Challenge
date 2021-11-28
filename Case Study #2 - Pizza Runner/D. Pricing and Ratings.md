# <p align="center" style="margin-top: 0px;">🍕 Case Study #2 - Pizza Runner 🍕
## <p align="center"> D. Pricing and Ratings

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Scripts).

***
 
## 1. *If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?*

```sql
select 
	sum(case when pizza_id = 1 then 12
			when pizza_id = 2 then 10 end) money
from #customer_orders c
left join #runner_orders r on r.order_id = c.order_id
where distance != 0;
````


#### Answer:
| money |
|-------|
|  138  |
  
- Pizza Runner earns $138.

***

## 2. *What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra*

```sql
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
````


#### Answer:
| money |
|-------|
|  142  |
  
- Pizza Runner earns $142.

***

## 3. *The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.*

```sql
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
```

#### Answer:
order_id | rating | review
-- | -- | --
1 | 1 | Really bad service
2 | 2 | NULL
3 | 4 | Good service
4 | 2 | Pizza arrived cold and took long
5 | 3 | NULL
7 | 3 | NULL
8 | 5 | It was great, good service and fast
10 | 4 | Not bad
  
- Rating table schema has been created.

***

## 4. *Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries? (customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas)*

```sql
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
```

#### Answer:
customer_id | order_id | runner_id | rating | order_time | pickup_time | time_between_order_and_pickup | delivery_duration | average_speed | Total_number_of_pizzas
-- | -- | -- | -- | -- | -- | -- | -- | --
101 | 1 | 1 | 1 | 2020-01-01 18:05:02.000 | 2020-01-01 18:15:34.000 | 10 | 32 | 37.5 | 1
101 | 2 | 1 | 2 | 2020-01-01 19:00:52.000 | 2020-01-01 19:10:54.000 | 10 | 27 | 44.44 | 1
102 | 3 | 1 | 4 | 2020-01-02 23:51:23.000 | 2020-01-03 00:12:37.000 | 21 | 20 | 40.2 | 2
103 | 4 | 2 | 2 | 2020-01-04 13:23:46.000 | 2020-01-04 13:53:03.000 | 29 | 40 | 35.1 | 3
104 | 5 | 3 | 3 | 2020-01-08 21:00:29.000 | 2020-01-08 21:10:57.000 | 10 | 15 | 40 | 1
105 | 7 | 2 | 3 | 2020-01-08 21:20:29.000 | 2020-01-08 21:30:45.000 | 10 | 25 | 60 | 1
102 | 8 | 2 | 5 | 2020-01-09 23:54:33.000 | 2020-01-10 00:15:02.000 | 20 | 15 | 93.6 | 1
104 | 10 | 1 | 4 | 2020-01-11 18:34:49.000 | 2020-01-11 18:50:20.000 | 15 | 10 | 60 | 2
  
- New table of joining all information.

***

## 5. *If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?*

```sql
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
````


#### Answer:
| money_left |
|------------|
|    94.44   |
  
- After deliveries the left over money $94.44.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
