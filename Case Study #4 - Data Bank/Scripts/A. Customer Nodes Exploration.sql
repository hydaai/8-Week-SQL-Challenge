-- 1. How many unique nodes are there on the Data Bank system?
select 
	count(distinct node_id) unique_nodes
from customer_nodes;

-- 2. What is the number of nodes per region?
select 
	n.region_id,
	r.region_name,
	count(distinct n.node_id) unique_nodes,
	count(n.node_id) number_of_nodes
from customer_nodes n 
left join regions r on n.region_id = r.region_id
group by n.region_id, r.region_name
order by n.region_id;

-- 3. How many customers are allocated to each region?
select 
	n.region_id,
	r.region_name,
	count(distinct n.customer_id) total_customers
from customer_nodes n 
left join regions r on n.region_id = r.region_id
group by n.region_id, r.region_name
order by n.region_id;

-- 4. How many days on average are customers reallocated to a different node?
select 
	AVG(DATEDIFF(D, start_date, end_date)) average
from customer_nodes
where end_date != '99991231';

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
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
