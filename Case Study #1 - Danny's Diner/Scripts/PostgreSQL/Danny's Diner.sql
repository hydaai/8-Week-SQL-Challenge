SET search_path = dannys_diner;

-- 1. What is the total amount each customer spent at the restaurant?
select 
	s.customer_id,
	sum(m.price) amount
from sales s
left join menu m on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
select
	customer_id, 
	count(distinct order_date) days
from sales group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH
	first_item
AS
	(
		select
			s.customer_id,
			s.order_date,
			m.product_name,
			dense_rank() over (partition by s.customer_id 
							   order by s.order_date) rank
		from sales s
		left join menu m on s.product_id = m.product_id
		left join members ms on s.customer_id = ms.customer_id
	)
select
	customer_id,
	product_name
from first_item
where rank = 1
group by customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select
	m.product_name,
	count(s.customer_id) times
from sales s
left join menu m on s.product_id = m.product_id
group by m.product_name
order by times desc
limit 1;

-- 5. Which item was the most popular for each customer?
WITH
	popular_item
AS
	(
		select
			s.customer_id,
			m.product_name,
			count(m.product_name) order_count,
			dense_rank() over (partition by s.customer_id order by count(m.product_name) desc) rank
		from sales s
		left join menu m on s.product_id = m.product_id
		group by s.customer_id, m.product_name
	)
select 
	customer_id,
	product_name
from popular_item
where rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH
	purchased_item
AS
	(
		select
			s.customer_id,
			m.product_name,
			dense_rank() over (partition by s.customer_id 
							   order by s.order_date) rank
		from sales s
		left join menu m on s.product_id = m.product_id
		left join members ms on s.customer_id = ms.customer_id
		where s.order_date > ms.join_date
	)
select
	customer_id,
	product_name
from purchased_item
where rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH
	purchased_item
AS
	(
		select
			s.customer_id,
			s.order_date,
			m.product_name,
			dense_rank() over (partition by s.customer_id 
							   order by s.order_date desc) rank
		from sales s
		left join menu m on s.product_id = m.product_id
		left join members ms on s.customer_id = ms.customer_id
		where s.order_date < ms.join_date
	)
select 
	customer_id,
	product_name
from purchased_item
where rank = 1
order by customer_id, product_name;

-- 8. What is the total items and amount spent for each member before they became a member?
select 
	s.customer_id,
	count(distinct s.product_id) items,
	sum(m.price) amount
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
where s.order_date < ms.join_date
group by s.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select 
	s.customer_id,
	sum(cp.points) points
from sales s
left join (select *, 
			case when product_name = 'sushi' then price*20
				else price*10 end points
			from menu) cp on s.product_id = cp.product_id
group by s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH
	weeks_program
AS
	(
		select
			s.customer_id, 
			case when product_name = 'sushi' and
				s.order_date between ms.join_date + cast(-1 || 'day' as INTERVAL) and 
					ms.join_date + cast(6 || 'day' as INTERVAL) then m.price*40
			when product_name = 'sushi' or
				s.order_date between ms.join_date + cast(-1 || 'day' as INTERVAL) and 
					ms.join_date + cast(6 || 'day' as INTERVAL) then m.price*20
			else m.price*10 end points
		from members ms
		left join sales s on s.customer_id = ms.customer_id
		left join menu m on s.product_id = m.product_id
		where s.order_date <= '20210131'
	)
select 
	customer_id,
	sum(points) points
from weeks_program
group by customer_id;

/*Bonus Questions*/
-- Recreate table with column: customer_id, order_date, product_name, price, member(Y/N)
select 
	s.customer_id, 
	s.order_date, 
	m.product_name, 
	m.price,
	case when s.order_date >= ms.join_date then 'Y' 
		else 'N' end member
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
order by s.customer_id, s.order_date, m.product_name;

-- Rank All
WITH
	RANK_ALL
AS
	(
		select 
			s.customer_id, 
			s.order_date, 
			m.product_name, 
			m.price,
			case when s.order_date >= ms.join_date then 'Y'
				else 'N' end member
		from sales s
		left join menu m on s.product_id = m.product_id
		left join members ms on s.customer_id = ms.customer_id
	)
select *, 
case when member = 'Y' then rank() over (partition by customer_id, 
										 member order by order_date) 
	else NULL end ranking
from RANK_ALL
order by customer_id, order_date, product_name;
