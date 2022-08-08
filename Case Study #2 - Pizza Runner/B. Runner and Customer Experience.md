# <p align="center" style="margin-top: 0px;">🍕 Case Study #2 - Pizza Runner 🍕
## <p align="center"> B. Runner and Customer Experience

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Query).

***

### 1. *How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*

````sql
select 
	datepart(WK, registration_date) weeks,
	count(runner_id) total
from runners
group by datepart(WK, registration_date);
````


#### Answer:
weeks | total
-- | --
1 | 2
2 | 1
3 | 1

- In week 1, 2 runners signed up.
- In week 2, 1 runners signed up.
- In week 3, 1 runners signed up.

***

## 2. *What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?*

````sql
select 
	runner_id,
	AVG(times) times
from 
	(
		select distinct 
			c.order_id, r.runner_id, 
			datediff(MINUTE, c.order_time, r.pickup_time) times
		from #customer_orders c
		left join #runner_orders r on c.order_id = r.order_id
		where r.distance <> 0
	)a
group by runner_id;
````


#### Answer:
runner_id | times
-- | --
1 | 14
2 | 20
3 | 10

- The average time required for runner 1 to take an order is 14 minutes.
- The average time required for runner 2 to take an order is 20 minutes.
- The average time required for runner 3 to take an order is 10 minutes.

***

## 3. *Is there any relationship between the number of pizzas and how long the order takes to prepare?*

````sql
select 
	number_of_pizzas,
	avg(times) order_prepare
from 
	(
		select distinct 
			c.order_id, COUNT(c.pizza_id) number_of_pizzas, c.order_time, r.pickup_time, 
			datediff(MINUTE, c.order_time, r.pickup_time) times
		from #customer_orders c
		left join #runner_orders r on c.order_id = r.order_id
		where r.distance <> 0
		group by c.order_id, c.order_time, r.pickup_time
	)a
group by number_of_pizzas;
````


#### Answer:
number_of_pizzas | order_prepare
-- | --
1 | 12
2 | 18
3 | 30

- Yes, there is.
- The number of pizzas ordered seems to be correlated to the preparation time.

***

## 4. *What was the average distance travelled for each customer?*

````sql
select 
	c.customer_id,
	AVG(distinct r.distance) distance
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by c.customer_id;
````


#### Answer:
customer_id | distance
-- | --
101 | 20
102 | 18.4
103 | 23.4
104 | 10
105 | 25

*(Assuming distance is calculated from how far the runner has to travel to deliver the order to the customer's place)*
- The average distance traveled for Customer 101 is 20 km.
- The average distance traveled for Customer 102 is 18.4 km.
- The average distance traveled for Customer 103 is 23.4 km.
- The average distance traveled for Customer 104 is 10 km.
- The average distance traveled for Customer 105 is 25 km.

***

## 5. *What was the difference between the longest and shortest delivery times for all orders?*

````sql
select 
	MAX(duration) - min(duration) diff_delivery_time
from #runner_orders
where duration <> 0;
````


#### Answer:
| distance |
| -- |
| 30 |

- The difference between the longest and shortest delivery time is 30 minutes.

***

## 6. *What was the average speed for each runner for each delivery and do you notice any trend for these values?*

````sql
select distinct 
	c.order_id, r.runner_id, COUNT(c.pizza_id) number_of_pizzas, 
	r.distance, r.duration, round((r.distance/r.duration*60),2) speed
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by c.order_id, r.runner_id, r.distance, r.duration;
````


#### Answer:
order_id | runner_id | number_of_pizzas | distance | duration | speed
-- | -- | -- | -- | -- | --
1 | 1 | 1 | 20 | 32 | 37.5
2 | 1 | 1 | 20 | 27 | 44.44
3 | 1 | 2 | 13.4 | 20 | 40.2
4 | 2 | 3 | 23.4 | 40 | 35.1
5 | 3 | 1 | 10 | 15 | 40
7 | 2 | 1 | 25 | 25 | 60
8 | 2 | 1 | 23.4 | 15 | 93.6
10 | 1 | 2 | 10 | 10 | 60

- The average speed for runner 1 between 37.5 km/h to 60 km/h.
- The average speed for runner 2 between 35.1 km/h to 93.6 km/h.
- The average speed for runner 3 is 40 km/h.

***

## 7. *What is the successful delivery percentage for each runner?*

````sql
select 
	runner_id, 
	ROUND(100 * SUM(case when distance <> 0 then 1 
						else 0 end)/COUNT(*),0) percentage
from #runner_orders
group by runner_id;
````


#### Answer:
runner_id | percentage
-- | --
1 | 100
2 | 75
3 | 50

- Runner 1 delivery percentage is 100%.
- Runner 2 delivery percentage is 75%.
- Runner 3 delivery percentage is 50%.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
