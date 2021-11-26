/* ----- perprocessing customer_orders table -----*/
DROP TABLE IF EXISTS #customer_orders, #customer_orders_split;
-- change null values into ''(blank space)
select order_id, customer_id, pizza_id, 
		case when exclusions is null or exclusions = 'null' then ''
			else trim(exclusions) end exclusions, 
		case when extras is null or extras = 'null' then ''
			else trim(extras) end extras, 
		order_time
into #customer_orders
from customer_orders;
-- split row in exclusions and extras columns
WITH customer_orders_CTE (order_id, customer_id, pizza_id, exclusions, extras, order_time)  
AS  
(
    SELECT order_id, customer_id, pizza_id, trim(value) exclusions, extras, order_time 
    FROM #customer_orders 
    CROSS APPLY STRING_SPLIT(exclusions, ',')  
)  
SELECT order_id, customer_id, pizza_id, exclusions,trim(value) extras, order_time  
into #customer_orders_split
FROM customer_orders_CTE
CROSS APPLY STRING_SPLIT(extras, ',')
order by order_id, customer_id, pizza_id, exclusions, extras;

/* ----- perprocessing runner_orders table -----*/
DROP TABLE IF EXISTS #runner_orders, #runner_orders_change;
select order_id, runner_id, 
	case when pickup_time is null or pickup_time = 'null' then ''
		else pickup_time end pickup_time,
	case when distance is null or distance = 'null' then ''
		when distance like '%km' then trim('km' from distance)
		else distance end distance,
	case when duration is null or duration = 'null' then ''
		when duration like '%mins' then trim('mins' from duration)
		when duration like '%minute' then trim('minute' from duration)
		when duration like '%minutes' then trim('minutes' from duration)
		else duration end duration,
	case when cancellation is null or cancellation = 'null' or cancellation = '' then ' '
		else cancellation end cancellation
into #runner_orders
from runner_orders;
-- change data type 
select * into #runner_orders_change from #runner_orders;
alter table #runner_orders_change
	alter column pickup_time datetime;
alter table #runner_orders_change
	alter column distance float;
alter table #runner_orders_change
	alter column duration int;
select * from #runner_orders_change

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
