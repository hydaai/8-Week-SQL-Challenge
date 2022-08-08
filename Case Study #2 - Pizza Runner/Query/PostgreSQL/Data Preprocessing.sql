SET search_path = pizza_runner;

/* ----- perprocessing customer_orders table -----*/
DROP TABLE IF EXISTS customer_orders_new;
WITH 
	new_table -- change null values into ''(blank space)
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

-- split row in exclusions and extras columns
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

/* ----- perprocessing runner_orders table -----*/
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

/* ----- perprocessing pizza_names table -----*/
-- change data type
DROP TABLE IF EXISTS pizza_names_new;
select pizza_id, cast(pizza_name as varchar(255)) pizza_name
into pizza_names_new
from pizza_names;

/* ----- perprocessing pizza_recipes table -----*/
-- split row in toppings column
DROP TABLE IF EXISTS pizza_recipes_new;
select pizza_id, REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER toppings
into pizza_recipes_new
from pizza_recipes 
order by pizza_id;

/* ----- perprocessing pizza_toppings table -----*/
-- change data type
DROP TABLE IF EXISTS pizza_toppings_new;
select topping_id, cast(topping_name as varchar(255)) topping_name
into pizza_toppings_new
from pizza_toppings;
