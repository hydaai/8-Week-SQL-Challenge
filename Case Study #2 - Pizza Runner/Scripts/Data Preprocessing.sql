/* ----- perprocessing customer_orders table -----*/
-- split row in exclusions and extras columns
DROP TABLE IF EXISTS #customer_orders;
select order_id, customer_id, pizza_id, value exclusions, extras, order_time
into #customer_orders
FROM (SELECT order_id, customer_id, pizza_id, exclusions, value extras, order_time 
-- change null values into ' '(blank space)
		FROM (select order_id, customer_id, pizza_id, 
					case when exclusions is null or exclusions = 'null' or exclusions = '' then ' '
						else trim(exclusions) end exclusions, 
					case when extras is null or extras = 'null' or extras = '' then ' '
						else trim(extras) end extras, 
					order_time
				from customer_orders) a
		CROSS APPLY STRING_SPLIT(extras, ',')) b
CROSS APPLY STRING_SPLIT(exclusions, ',')
order by order_id, customer_id, pizza_id, exclusions, extras;

/* ----- perprocessing runner_orders table -----*/
DROP TABLE IF EXISTS #runner_orders;
select order_id, runner_id, 
	case when pickup_time is null or pickup_time = 'null' or pickup_time = '' then ' '
		else pickup_time end pickup_time,
	case when distance is null or distance = 'null' or distance = '' then ' '
		when distance like '%km' then trim('km' from distance)
		else distance end distance,
	case when duration is null or duration = 'null' or duration = '' then ' '
		when duration like '%mins' then trim('mins' from duration)
		when duration like '%minute' then trim('minute' from duration)
		when duration like '%minutes' then trim('minutes' from duration)
		else duration end duration,
	case when cancellation is null or cancellation = 'null' or cancellation = '' then ' '
		else cancellation end cancellation
into #runner_orders
from runner_orders;
-- change data type 
alter table #runner_orders
	alter column pickup_time datetime;
alter table #runner_orders
	alter column distance float;
alter table #runner_orders
	alter column duration int;

/* ----- perprocessing pizza_names table -----*/
-- change data type
DROP TABLE IF EXISTS #pizza_names;
select pizza_id, cast(pizza_name as varchar(max)) pizza_name
into #pizza_names
from pizza_names;

/* ----- perprocessing pizza_recipes table -----*/
-- split row in toppings column
DROP TABLE IF EXISTS #pizza_recipes;
select pizza_id, trim(value) toppings
into #pizza_recipes
-- change data type to varchar for split row
from (select pizza_id, cast(toppings as varchar(max)) toppings
		from pizza_recipes) a 
CROSS APPLY STRING_SPLIT(toppings, ',')
order by pizza_id;

/* ----- perprocessing pizza_toppings table -----*/
-- change data type
DROP TABLE IF EXISTS #pizza_toppings;
select topping_id, cast(topping_name as varchar(max)) topping_name
into #pizza_toppings
from pizza_toppings;
