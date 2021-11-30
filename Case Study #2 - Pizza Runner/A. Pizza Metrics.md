# <p align="center" style="margin-top: 0px;">🍕 Case Study #2 - Pizza Runner 🍕
## <p align="center"> A. Pizza Metrics

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%232%20-%20Pizza%20Runner/Scripts).

***

### 1. *How many pizzas were ordered?*

````sql
select 
	count(*) pizza_ordered
from customer_orders;
````


#### Answer:
|pizza_ordered|
|-------------|
|     14      |
  
- 14 pizzas ordered.

***

### 2. *How many unique customer orders were made?*

````sql
select 
	count(distinct order_id) unique_ordered
from #customer_orders;
````


#### Answer:
|unique_ordered|
|--------------|
|     10       |
  
- 10 unique customer orders made.

***
 
### 3. *How many successful orders were delivered by each runner?*

```sql
select 
	runner_id,
	count(order_id) as orders
from #runner_orders
where distance <> 0
group by runner_id;
```

#### Answer:
runner_id | orders
-- | --
1 | 4
2 | 3
3 | 1
  
- Runner 1 delivers 4 pizzas.
- Runner 2 delivers 3 pizzas.
- Runner 3 delivers 1 pizza.

***
 
### 4. *How many of each type of pizza was delivered?*

```sql
select 
	n.pizza_name,
	count(c.pizza_id) as delivered
from #pizza_names n
left join customer_orders c on n.pizza_id = c.pizza_id
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by n.pizza_name;
```

#### Answer:
pizza_name | delivered
-- | --
Meatlovers | 9
Vegetarian | 3
  
- 9 Vegetarian pizzas have been delivered.
- 3 Meat Lovers pizzas have been delivered.

***

### 5. *How many Vegetarian and Meatlovers were ordered by each customer?*

```sql
select 
	c.customer_id,
	sum(case when c.pizza_id = 1 then 1
		else 0 end) Meatlovers,
	sum(case when c.pizza_id = 2 then 1
		else 0 end) Vegetarian
from #pizza_names n
left join customer_orders c on n.pizza_id = c.pizza_id
group by c.customer_id;
```

#### Answer:
customer_id | Meatlovers | Vegetarian
-- | -- | --
101 | 2 | 1
102 | 2 | 1
103 | 3 | 1
104 | 3 | 0
105 | 0 | 1  

- Customer 101 ordered 2 Vegetarian pizzas and 1 Meat Lovers pizza.
- Customer 102 ordered 2 Vegetarian pizzas and 1 Meat Lovers pizza.
- Customer 103 ordered 3 Vegetarian pizzas and 1 Meat Lovers pizza.
- Customer 104 ordered 3 Vegetarian pizzas.
- Customer 105 ordered 1 Meat Lovers pizza.

***

### 6. *What was the maximum number of pizzas delivered in a single order?*

```sql
select 
  max(pizza) max_pizza
from 
	(
		select 
			c.order_id,
			count(c.order_id) as pizza
		from customer_orders c
		left join #runner_orders r on c.order_id = r.order_id
		where r.distance <> 0
		group by c.order_id
	)a;
```

#### Answer:
|max_pizza|
|---------|
|    3    |
  
- Maximum 3 pizzas delivered in a single order.

### 7. *For each customer, how many delivered pizzas had at least 1 change and how many had no changes?*

```sql
select 
	c.customer_id,
	sum(case when c.exclusions <> '' or c.extras <> '' then 1
		else 0 end) at_least_1_change,
	sum(case when c.exclusions = '' and c.extras = '' then 1
		else 0 end) no_change
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0
group by c.customer_id;
```

#### Answer:
customer_id | at_least_1_change | no_change
-- | -- | --
101 | 0 | 2
102 | 0 | 3
103 | 3 | 0
104 | 2 | 1
105 | 1 | 0
  
- Customer 101 ordered 2 pizzas without change.
- Customer 102 ordered 3 pizzas without change.
- Customer 103 ordered 3 with pizzas change.
- Customer 104 ordered pizzas 2 with change and 1 without change.
- Customer 105 ordered 1 pizza without change.

***

### 8. *How many pizzas were delivered that had both exclusions and extras?*

```sql
select 
	sum(case when c.exclusions <> '' and c.extras <> '' then 1
		else 0 end) delivered
from #customer_orders c
left join #runner_orders r on c.order_id = r.order_id
where r.distance <> 0;
```

#### Answer:
|delivered|
|---------|
|    1    |
  
- 1 pizza delivered had both exclusions and extras.

***

### 9. *What was the total volume of pizzas ordered for each hour of the day?*

```sql
select 
	datepart(HOUR, order_time) hour_of_day,
	count(order_id) total
from #customer_orders
group by datepart(HOUR, order_time);
```

#### Answer:
hour_of_day | total
-- | --
11 | 1
13 | 3
18 | 3
19 | 1
21 | 3
23 | 3
  
- At 11, 1 pizza ordered.
- At 13, 3 pizzas ordered.
- At 18, 3 pizzas ordered.
- At 19, 1 pizza ordered.
- At 21, 3 pizzas ordered.
- At 23, 3 pizzas ordered.

***

### 10. *What was the volume of orders for each day of the week?*

```sql
select 
	datename(DW, order_time) day_of_week,
	count(order_id) total
from #customer_orders
group by datename(DW, order_time), datepart(DW, order_time)
order by datepart(DW, order_time);
```

#### Answer:
day_of_week | total
-- | --
Wednesday | 5
Thursday | 3
Friday | 1
Saturday | 5
  
- On Wednesday, 5 pizzas ordered.
- On Thursday, 3 pizzas ordered.
- On Friday, 1 pizzas ordered.
- On Saturday, 5 pizza ordered.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
