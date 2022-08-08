# <p align="center" style="margin-top: 0px;">🍕 Case Study #2 - Pizza Runner 🍕 
  ## <p align="center"> Data Preprocessing

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Query/SQL%20Server). 
  
***
 
### *Investigate data and perform data preprocessing!*

#### Create Temporary Tables `customer_orders`, `customer_orders_split`
##### Tables `#customer_orders`
| Column | Actions |
| -- | -- |
| no | Add numbering for each row using **ROW_NUMBER** |
| order_id | no changes |
| customer_id | no changes |
| pizza_id | no changes |
| exclusions | Use CASE with conditional exclusions is NULL or 'null' then '' |
| extras | Use CASE with conditional extras is NULL or 'null' then '' |
| order_time | no changes |

Query SQL.

````sql
DROP TABLE IF EXISTS #customer_orders, #customer_orders_split;
-- change null values into ''(blank space)
-- add number rows each order & pizza
select 
	ROW_NUMBER() OVER(order by order_id, pizza_id) no,
	order_id, customer_id, pizza_id, 
	case when exclusions is null or exclusions = 'null' then ''
		else trim(exclusions) end exclusions, 
	case when extras is null or extras = 'null' then ''
		else trim(extras) end extras, 
	order_time
into #customer_orders
from customer_orders;
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

##### Tables `#customer_orders_split`
| Column | Actions |
| -- | -- |
| no | no changes |
| order_id | no changes |
| customer_id | no changes |
| pizza_id | no changes |
| exclusions | Use **STRING_SPLIT** to split the exclusions |
|  | Use **TRIM** to remove spaces |
|  | change datatype to **integer** |
| extras | Use **STRING_SPLIT** to split the extras |
|  | Use **TRIM** to remove spaces |
|  | change datatype to **integer** |
| order_time | no changes |

Query SQL.

````sql
-- split row in exclusions and extras columns
WITH customer_orders_CTE (no, order_id, customer_id, pizza_id, exclusions, extras, order_time)  
AS  
(
    SELECT no, order_id, customer_id, 
	  pizza_id, trim(value) exclusions, extras, order_time 
    FROM #customer_orders 
    CROSS APPLY STRING_SPLIT(exclusions, ',')  
)  
SELECT no, order_id, customer_id, pizza_id, 
	  exclusions,trim(value) extras, order_time  
into #customer_orders_split
FROM customer_orders_CTE
CROSS APPLY STRING_SPLIT(extras, ',')
order by order_id, customer_id, pizza_id, exclusions, extras;
alter table #customer_orders_split
	alter column exclusions int;
alter table #customer_orders_split
	alter column extras int;
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

#### Create Temporary Table `runner_orders`
| Column | Actions |
| -- | -- |
| order_id | no changes |
| runner_id | no changes |
| pickup_time | Use CASE with conditional exclusions is NULL or 'null' then '' |
| distance | Use CASE with conditional exclusions is NULL or 'null' then '' |
|  | Use **TRIM** to remove 'km' or ' km' |
| duration | Use CASE with conditional exclusions is NULL or 'null' then '' |
|  | Use **TRIM** to remove 'mins' or ' mins' or ' minute' or 'minutes' or ' minutes' |
| cancellation | Use CASE with conditional exclusions is NULL or 'null' or '' then ' ' |

Query SQL.

````sql
DROP TABLE IF EXISTS #runner_orders;
select order_id, runner_id, 
	CAST(case when pickup_time is null or pickup_time = 'null' then ''
		else pickup_time end as datetime) pickup_time,
	CAST(case when distance is null or distance = 'null' then ''
		when distance like '%km' then trim('km' from distance)
		else distance end as float) distance,
	CAST(case when duration is null or duration = 'null' then ''
		when duration like '%mins' then trim('mins' from duration)
		when duration like '%minute' then trim('minute' from duration)
		when duration like '%minutes' then trim('minutes' from duration)
		else duration end as int) duration,
	case when cancellation is null or cancellation = 'null' or cancellation = '' then ' '
		else cancellation end cancellation
into #runner_orders
from runner_orders;
````

We got a new table.

order_id | runner_id | pickup_time | distance | duration | cancellation
-- | -- | -- | -- | -- | --
1 | 1 | 2020-01-01 18:15:34.000 | 20 | 32 |  
2 | 1 | 2020-01-01 19:10:54.000 | 20 | 27 |  
3 | 1 | 2020-01-03 00:12:37.000 | 13.4 | 20 |  
4 | 2 | 2020-01-04 13:53:03.000 | 23.4 | 40 |  
5 | 3 | 2020-01-08 21:10:57.000 | 10 | 15 |  
6 | 3 | 1900-01-01 00:00:00.000 | 0 | 0 | Restaurant Cancellation
7 | 2 | 2020-01-08 21:30:45.000 | 25 | 25 |  
8 | 2 | 2020-01-10 00:15:02.000 | 23.4 | 15 |  
9 | 2 | 1900-01-01 00:00:00.000 | 0 | 0 | Customer Cancellation
10 | 1 | 2020-01-11 18:50:20.000 | 10 | 10 | 

#### Create Temporary Table `pizza_names`
| Column | Actions |
| -- | -- |
| pizza_id | no changes |
| pizza_name | change datatype to **varchar** |

Query SQL.

````sql
DROP TABLE IF EXISTS #pizza_names;
select 
	pizza_id, 
	cast(pizza_name as varchar(max)) pizza_name
into #pizza_toppings
from pizza_toppings;
````

We got a new table.

pizza_id | pizza_name
-- | -- 
1 | Meatlovers
2 | Vegetarian

#### Create Temporary Table `pizza_recipes`
| Column | Actions |
| -- | -- |
| pizza_id | no changes |
| toppings | change datatype to **varchar** |
|  | Use **STRING_SPLIT** to split the toppings |

Query SQL.

````sql
DROP TABLE IF EXISTS #pizza_recipes;
select 
	  pizza_id, 
	  trim(value) toppings
into #pizza_recipes
-- change data type to varchar for split row
from (
	  select 
	  	pizza_id, 
	  	cast(toppings as varchar(max)) toppings
	  from pizza_recipes) a 
CROSS APPLY STRING_SPLIT(toppings, ',')
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

#### Create Temporary Table `pizza_toppings`
| Column | Actions |
| -- | -- |
| topping_id | no changes |
| topping_name | change datatype to **varchar** |

Query SQL.

````sql
DROP TABLE IF EXISTS #pizza_toppings;
select 
	topping_id, 
	cast(topping_name as varchar(max)) topping_name
into #pizza_toppings
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
