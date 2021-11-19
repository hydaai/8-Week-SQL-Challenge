use sqlchallenge

/*Case Study Questions
Each of the following case study questions can be answered using a single SQL statement:
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
*/

select '1. total amount each customer' as title
-- 1. What is the total amount each customer spent at the restaurant?
select 
	s.customer_id,
	sum(m.price) amount
from sales s
left join menu m on s.product_id = m.product_id
group by s.customer_id;

select '2. total days visited' as title
-- 2. How many days has each customer visited the restaurant?
select
	customer_id, 
	count(distinct order_date) days
from sales group by customer_id;

select '3. first item menu' as title
-- 3. What was the first item from the menu purchased by each customer?
select
	customer_id,
	product_name
from (select
		s.customer_id,
		s.order_date,
		m.product_name,
		dense_rank() over (partition by s.customer_id order by s.order_date) rank
	from sales s
	left join menu m on s.product_id = m.product_id
	left join members ms on s.customer_id = ms.customer_id) a
where rank = 1
group by customer_id, product_name;

select '4. most menu purchased' as title
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select top 1 
	m.product_name,
	count(s.customer_id) times
from sales s
left join menu m on s.product_id = m.product_id
group by m.product_name
order by times desc;

select '5. most popular menu' as title
-- 5. Which item was the most popular for each customer?
select 
	customer_id,
	product_name
from (select
		s.customer_id,
		m.product_name,
		count(m.product_name) order_count,
		dense_rank() over (partition by s.customer_id order by count(m.product_name) desc) rank
	from sales s
	left join menu m on s.product_id = m.product_id
	group by s.customer_id, m.product_name) a
where rank = 1;

select '6. first menu purchased after member' as title
-- 6. Which item was purchased first by the customer after they became a member?
select top 1 with ties --ties untuk pengulangan
	s.customer_id,
	m.product_name
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
where s.order_date > ms.join_date
order by row_number() over (partition by s.customer_id order by s.order_date);

select '7. last menu purchased before member' as title
-- 7. Which item was purchased just before the customer became a member?
select 
	customer_id,
	product_name
from (select
		s.customer_id,
		s.order_date,
		m.product_name,
		dense_rank() over (partition by s.customer_id order by s.order_date desc) rank
	from sales s
	left join menu m on s.product_id = m.product_id
	left join members ms on s.customer_id = ms.customer_id
	where s.order_date < ms.join_date) a
where rank = 1
group by customer_id, product_name;

select '8. total items and amount before member' as title
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

select '8. customer points' as title
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

select '10. total days visited' as title
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select 
	customer_id,
	sum(points) points
from (select s.customer_id, 
		case when s.order_date between dateadd(day,-1,ms.join_date) and dateadd(day, 6, ms.join_date) then m.price*20
			else price*10 end points
		from members ms
		left join sales s on s.customer_id = ms.customer_id
		left join menu m on s.product_id = m.product_id
		where s.order_date <= '20210131') a
group by customer_id;

/*Bonus Questions
#Join All The Things
The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.
Recreate the following table output using the available data:
#Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
*/

select '-------------------- Bonus Questions --------------------' as title
select 'Recreate Table' as title
--Recreate table with column: customer_id, order_date, product_name, price, member(Y/N)
select s.customer_id, s.order_date, m.product_name, m.price,
		case when s.order_date >= ms.join_date then 'Y'
			else 'N' end member
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
order by s.customer_id, s.order_date, m.product_name;

select 'Rank All' as title
--Rank All
select *, 
case when member = 'Y' then rank() over (partition by customer_id, member order by order_date) 
	else NULL end ranking
from (select s.customer_id, s.order_date, m.product_name, m.price,
			case when s.order_date >= ms.join_date then 'Y'
				else 'N' end member
	from sales s
	left join menu m on s.product_id = m.product_id
	left join members ms on s.customer_id = ms.customer_id) a
order by customer_id, order_date, product_name;
