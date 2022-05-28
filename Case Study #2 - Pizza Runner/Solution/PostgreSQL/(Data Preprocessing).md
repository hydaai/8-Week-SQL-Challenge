# <p align="center" style="margin-top: 0px;">🍕 Case Study #2 - Pizza Runner 🍕 
  ## <p align="center"> Data Preprocessing

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Scripts/PostgreSQL). 
  
***
 
### *Investigate data and perform data preprocessing!*

#### Create Tables `customer_orders_new`, `customer_orders_split`
##### Tables `customer_orders_new`
| Column | Actions |
| -- | -- |
| no | Add numbering for each row using **ROW_NUMBER** |
| order_id | no changes |
| customer_id | no changes |
| pizza_id | no changes |
| exclusions | Use CASE with conditional exclusions is [null] or 'null' then '' |
| extras | Use CASE with conditional extras is [null] or 'null' then '' |
| order_time | no changes |

Query SQL.

````sql
DROP TABLE IF EXISTS customer_orders_new;
WITH 
	new_table
AS
	(
		select order_id, customer_id, pizza_id, 
			case when exclusions is null or exclusions = 'null' then ''
				else trim(exclusions) end exclusions, 
			case when extras is null or extras = 'null' then ''
				else trim(extras) end extras, 
			order_time
		from customer_orders
	)
-- add number columns each order & pizza
SELECT ROW_NUMBER() OVER(order by order_id, pizza_id) no, * 
INTO customer_orders_new
FROM new_table;
````

We got a new table.

no | order_id | customer_id | pizza_id | exclusions | extras | order_time
-- | -- | -- | -- | -- | -- | --
1 | 1 | 101 | 1 |  |  | 2020-01-01 18:05:02.000
2 | 2 | 101 | 1 |  |  | 2020-01-01 19:00:52.000
3 | 3 | 102 | 1 |  |  | 2020-01-02 23:51:23.000
4 | 3 | 102 | 2 |  |  | 2020-01-02 23:51:23.000
5 | 4 | 103 | 1 | 4 |  | 2020-01-04 13:23:46.000
6 | 4 | 103 | 1 | 4 |  | 2020-01-04 13:23:46.000
7 | 4 | 103 | 2 | 4 |  | 2020-01-04 13:23:46.000
8 | 5 | 104 | 1 |  | 1 | 2020-01-08 21:00:29.000
9 | 6 | 101 | 2 |  |  | 2020-01-08 21:03:13.000
10 | 7 | 105 | 2 |  | 1 | 2020-01-08 21:20:29.000
11 | 8 | 102 | 1 |  |  | 2020-01-09 23:54:33.000
12 | 9 | 103 | 1 | 4 | 1, 5 | 2020-01-10 11:22:59.000
13 | 10 | 104 | 1 |  |  | 2020-01-11 18:34:49.000
14 | 10 | 104 | 1 | 2, 6 | 1, 4 | 2020-01-11 18:34:49.000

##### Tables `customer_orders_split`
| Column | Actions |
| -- | -- |
| no | no changes |
| order_id | no changes |
| customer_id | no changes |
| pizza_id | no changes |
| exclusions | Use **REGEXP_SPLIT_TO_TABLE** to split the exclusions |
|  | change datatype to **integer** |
| extras | Use **REGEXP_SPLIT_TO_TABLE** to split the exclusions |
|  | change datatype to **integer** |
| order_time | no changes |

Query SQL.

````sql
DROP TABLE IF EXISTS customer_orders_split;
WITH 
	customer_orders_exclusions
AS  
	(
    	SELECT 
			no, order_id, customer_id, pizza_id, 
			REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+') exclusions, 
			extras, order_time 
    	FROM customer_orders_new
	), 
	customer_orders_CTE
AS  
	(
		SELECT
			no, order_id, customer_id, pizza_id, exclusions,
			REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+') extras, order_time  
		FROM customer_orders_exclusions
	)
SELECT 
	no, order_id, customer_id, pizza_id, 
	case when exclusions ='' then 0 else exclusions::int end exclusions, 
	case when extras ='' then 0 else extras::int end extras, 
	order_time  
into customer_orders_split
FROM customer_orders_CTE
order by order_id, customer_id, pizza_id, exclusions, extras;
````

We got a new table.

no | order_id | customer_id | pizza_id | exclusions | extras | order_time
-- | -- | -- | -- | -- | -- | --
1 | 1 | 101 | 1 | 0 | 0 | 2020-01-01 18:05:02.000
2 | 2 | 101 | 1 | 0 | 0 | 2020-01-01 19:00:52.000
3 | 3 | 102 | 1 | 0 | 0 | 2020-01-02 23:51:23.000
4 | 3 | 102 | 2 | 0 | 0 | 2020-01-02 23:51:23.000
5 | 4 | 103 | 1 | 4 | 0 | 2020-01-04 13:23:46.000
6 | 4 | 103 | 1 | 4 | 0 | 2020-01-04 13:23:46.000
7 | 4 | 103 | 2 | 4 | 0 | 2020-01-04 13:23:46.000
8 | 5 | 104 | 1 | 0 | 1 | 2020-01-08 21:00:29.000
9 | 6 | 101 | 2 | 0 | 0 | 2020-01-08 21:03:13.000
10 | 7 | 105 | 2 | 0 | 1 | 2020-01-08 21:20:29.000
11 | 8 | 102 | 1 | 0 | 0 | 2020-01-09 23:54:33.000
12 | 9 | 103 | 1 | 4 | 1 | 2020-01-10 11:22:59.000
12 | 9 | 103 | 1 | 4 | 5 | 2020-01-10 11:22:59.000
13 | 10 | 104 | 1 | 0 | 0 | 2020-01-11 18:34:49.000
14 | 10 | 104 | 1 | 2 | 1 | 2020-01-11 18:34:49.000
14 | 10 | 104 | 1 | 2 | 4 | 2020-01-11 18:34:49.000
14 | 10 | 104 | 1 | 6 | 1 | 2020-01-11 18:34:49.000
14 | 10 | 104 | 1 | 6 | 4 | 2020-01-11 18:34:49.000

#### Create Table `runner_orders_new`
| Column | Actions |
| -- | -- |
| order_id | no changes |
| runner_id | no changes |
| pickup_time | Use CASE with conditional exclusions is [null] or 'null' then '' |
| distance | Use CASE with conditional exclusions is [null] or 'null' then '' |
|  | Use **TRIM** to remove 'km' or ' km' |
| duration | Use CASE with conditional exclusions is [null] or 'null' then '' |
|  | Use **TRIM** to remove 'mins' or ' mins' or ' minute' or 'minutes' or ' minutes' |
| cancellation | Use CASE with conditional exclusions is [null] or 'null' or '' then ' ' |

Query SQL.

````sql
DROP TABLE IF EXISTS runner_orders_new;
select order_id, runner_id, 
	case when pickup_time is null or pickup_time = 'null' then '1900-01-01 00:00:00.000'::timestamp
		else pickup_time::timestamp end as pickup_time,
	case when distance is null or distance = 'null' then 0
		when distance like '%km' then trim('km' from distance)::float
		else distance::float end distance,
	case when duration is null or duration = 'null' then 0
		when duration like '%mins' then trim('mins' from duration)::int
		when duration like '%minute' then trim('minute' from duration)::int
		when duration like '%minutes' then trim('minutes' from duration)::int
		else duration::int end duration,
	case when cancellation is null or cancellation = 'null' or cancellation = '' then ' '
		else cancellation end cancellation
into runner_orders_new
from runner_orders;
````

We got a new table.

order_id | runner_id | pickup_time | distance | duration | cancellation
-- | -- | -- | -- | -- | --
1 | 1 | 2020-01-01 18:15:34.000 | 20 | 32 | [...] 
2 | 1 | 2020-01-01 19:10:54.000 | 20 | 27 | [...] 
3 | 1 | 2020-01-03 00:12:37.000 | 13.4 | 20 | [...] 
4 | 2 | 2020-01-04 13:53:03.000 | 23.4 | 40 | [...] 
5 | 3 | 2020-01-08 21:10:57.000 | 10 | 15 | [...] 
6 | 3 | 1900-01-01 00:00:00.000 | 0 | 0 | Restaurant Cancellation
7 | 2 | 2020-01-08 21:30:45.000 | 25 | 25 | [...] 
8 | 2 | 2020-01-10 00:15:02.000 | 23.4 | 15 | [...] 
9 | 2 | 1900-01-01 00:00:00.000 | 0 | 0 | Customer Cancellation
10 | 1 | 2020-01-11 18:50:20.000 | 10 | 10 | [...]

#### Create Table `pizza_names_new`
| Column | Actions |
| -- | -- |
| pizza_id | no changes |
| pizza_name | change datatype to **varchar** |

Query SQL.

````sql
DROP TABLE IF EXISTS pizza_names_new;
select 
  pizza_id, 
  cast(pizza_name as varchar(255)) pizza_name
into pizza_names_new
from pizza_names;
````

We got a new table.

pizza_id | pizza_name
-- | -- 
1 | Meatlovers
2 | Vegetarian

#### Create Table `pizza_recipes_new`
| Column | Actions |
| -- | -- |
| pizza_id | no changes |
| toppings | change datatype to **varchar** |
|  | Use **REGEXP_SPLIT_TO_TABLE** to split the toppings |

Query SQL.

````sql
DROP TABLE IF EXISTS pizza_recipes_new;
select 
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER toppings
into pizza_recipes_new
from pizza_recipes 
order by pizza_id;
````

We got a new table.

pizza_id | toppings
-- | -- 
1 | 1
1 | 2
1 | 3
1 | 4
1 | 5
1 | 6
1 | 8
1 | 10
2 | 4
2 | 6
2 | 7
2 | 9
2 | 11
2 | 12

#### Create Table `pizza_toppings_new`
| Column | Actions |
| -- | -- |
| topping_id | no changes |
| topping_name | change datatype to **varchar** |

Query SQL.

````sql
DROP TABLE IF EXISTS pizza_toppings_new;
select 
  topping_id,
  cast(topping_name as varchar(255)) topping_name
into pizza_toppings_new
from pizza_toppings;
````

We got a new table.

topping_id | topping_name
-- | -- 
1 | Bacon
2 | BBQ Sauce
3 | Beef
4 | Cheese
5 | Chicken
6 | Mushrooms
7 | Onions
8 | Pepperoni
9 | Peppers
10 | Salami
11 | Tomatoes
12 | Tomato Sauce

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
