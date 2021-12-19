# <p align="center" style="margin-top: 0px;"> 💰 Case Study #4 - Data Bank 💰
## <p align="center"> A. Customer Nodes Exploration

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank/Scripts).

***

## 1. *How many unique nodes are there on the Data Bank system?*

#### Steps:
- Use **COUNT DISTINCT** and **GROUP BY** to find the `number` of unique nodes.

````sql
select 
	count(distinct node_id) unique_nodes
from customer_nodes;
````


#### Answer:
|unique_nodes |
| -- |
|5|

- 5 unique nodes.

***

## 2. *What is the number of nodes per region?*

#### Steps:
- Use **COUNT DISTINCT** and **GROUP BY** to find the `number` of nodes each region.

````sql
select 
	n.region_id,
	r.region_name,
	count(distinct n.node_id) unique_nodes,
	count(n.node_id) number_of_nodes
from customer_nodes n 
left join regions r on n.region_id = r.region_id
group by n.region_id, r.region_name
order by n.region_id;
````


#### Answer:
region_id | region_name | unique_nodes | number_of_nodes
-- | -- | -- 
1 | Australia | 5 | 770
2 | America | 5 | 735
3 | Africa | 5 | 714
4 | Asia | 5 | 665
5 | Europe | 5 | 616

- Each region has 5 unique nodes.

***

## 3. *How many customers are allocated to each region?*

#### Steps:
- Use **COUNT** and **GROUP BY** to find the `number` of customers each region.

````sql
select 
	n.region_id,
	r.region_name,
	count(distinct n.customer_id) total_customers
from customer_nodes n 
left join regions r on n.region_id = r.region_id
group by n.region_id, r.region_name
order by n.region_id;
````


#### Answer:
region_id | region_name | total_customers
-- | -- | -- 
1 | Australia | 110
2 | America | 105
3 | Africa | 102
4 | Asia | 95
5 | Europe | 88

- Australian have 110 customers.
- American have 105 customers.
- African have 102 customers.
- Asia have 95 customers.
- European have 88 customers.

***

## 4. *How many days on average are customers reallocated to a different node?*

#### Steps:
- Use **DATEDIFF** to find the day difference between `start_date` and `end_date`.

````sql
select 
	AVG(DATEDIFF(D, start_date, end_date)) average
from customer_nodes
where end_date != '99991231';
````


#### Answer:
|average |
| -- |
|14|

- On average, customers are reallocated to different nodes, which is 14 days.

***

## 5. *What is the median, 80th and 95th percentile for this same reallocation days metric for each region?*

#### Steps:
- Use **DATEDIFF** to find the day difference between start_date and end_date
- Use **PERCENTILE_CONT** and **WITHIN GROUP** to find the `median`, 80th and 95th `percentile`.

````sql
WITH 
	diff_data --difference between start_date and end_date
AS
	(
		select 
			n.customer_id,
			n.region_id, 
			r.region_name,
			DATEDIFF(D, n.start_date, n.end_date) diff
		from customer_nodes n
		left join regions r on n.region_id = r.region_id
		where end_date != '99991231'
	)
select distinct
	region_id,
	region_name,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diff)
		OVER (PARTITION BY region_name) AS median,
	PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY diff)
		OVER (PARTITION BY region_name) AS percentile_80,
	PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY diff)
		OVER (PARTITION BY region_name) AS percentile_95
from diff_data
order by region_id;
````


#### Answer:
region_id | region_name | median | percentile_80 | percentile_95
--| -- | -- | -- | --
1 | Australia | 15 | 23 | 28
2 | America | 15 | 23 | 28
3 | Africa | 15 | 24 | 28
4 | Asia | 15 | 23 | 28
5 | Europe | 15 | 24 | 28

- For Australian reallocation days, the median, 80th and 95th percentiles, respectively, are 15, 23, 28.
- For American reallocation days, the median, 80th and 95th percentiles, respectively, are 15, 23, 28.
- For African reallocation days, the median, 80th and 95th percentiles, respectively, are 15, 24, 28.
- For Asian reallocation days, the median, 80th and 95th percentiles, respectively, are 15, 23, 28.
- For European reallocation days, the median, 80th and 95th percentiles, respectively, are 15, 24, 28.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
