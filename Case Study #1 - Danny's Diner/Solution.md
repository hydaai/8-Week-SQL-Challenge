# <h1 align="center" style="margin-top: 0px;">🍜 Case Study #1 - Danny's Diner 🍜

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner/Scripts).

***

### 1. *What is the total amount each customer spent at the restaurant?*

#### Steps:
- Use **SUM** and **GROUP BY** to find the `total amount` spent by each customer
- **JOIN** `sales` and `menu` tables because `customer_id` and `price` columns are in different tables.

````sql
select 
	s.customer_id,
	sum(m.price) amount
from sales s
left join menu m on s.product_id = m.product_id
group by s.customer_id;
````


#### Answer:
customer_id | total_sales
-- | --
A | 76
B | 74
C | 36

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

### 2. *How many days has each customer visited the restaurant?*

#### Steps:
- Use **COUNT** and **GROUP BY** to find the `the number of days` visited by each customer
- Use **DISTINCT** `order_date` to find unique days.

````sql
select
	customer_id, 
	count(distinct order_date) days
from sales group by customer_id;
````


#### Answer:
customer_id | days
-- | --
A | 4
B | 6
C | 2
  
- Customer A visited 4 days.
- Customer B visited 6 days.
- Customer C visited 2 days.

***

### 3. *What was the first item from the menu purchased by each customer?*

#### Steps:
- Use **RANK** to find out the order based on `order_date` and `customer_id`
- Use **WHERE** to find the `first item` purchased by each customer

````sql
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
````


#### Answer:
customer_id | total_sales
-- | --
A | curry
A | sushi
B | curry
C | ramen

- Customer A first ordered curry and sushi.
- Customer B first ordered curry.
- Customer C first ordered ramen.

***

### 4. *What is the most purchased item on the menu and how many times was it purchased by all customers?*

#### Steps:
- Use **COUNT** and **GROUP BY** to find how many `times` an item purchased
- **JOIN** `sales` and `menu` tables because `customer_id` and `product_name` columns are in different tables.

````sql
select top 1 
	m.product_name,
	count(s.customer_id) times
from sales s
left join menu m on s.product_id = m.product_id
group by m.product_name
order by times desc;
````


#### Answer:
customer_id | total_sales
-- | --
ramen | 8

- Ramen is the most purchased item and has been purchased 8 times.

***

### 5. *Which item was the most popular for each customer?*

#### Steps:
- Use **COUNT** and **GROUP BY** to find the how many `times` an item purchased by each customer
- Use **RANK** to find out the order of popular items based on `product_name` and `customer_id`
- **JOIN** `sales` and `menu` tables because `customer_id` and `product_name` columns are in different tables.
- Use **WHERE** to find the `most popular` item by each customer

````sql
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
````


#### Answer:
customer_id | total_sales
-- | --
A | ramen
B | curry
B | ramen
B | sushi
C | ramen

- Customers A and C love ramen.
- Customer B like all menus.

***

### 6. *Which item was purchased first by the customer after they became a member?*

#### Steps:
- Use **WHERE** to filter days after became a `member`
- **JOIN** `sales`, `menu` and `members` tables because the required columns are in different tables.

````sql
select top 1 with ties
	s.customer_id,
	m.product_name
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
where s.order_date > ms.join_date
order by row_number() over (partition by s.customer_id order by s.order_date);
````


#### Answer:
customer_id | product_name
-- | --
A | ramen
B | sushi
	
- Customer A after becoming a member orders ramen.
- Customer B after becoming a member orders sushi.

***

### 7. *Which item was purchased just before the customer became a member?*

#### Steps:
- Use **RANK** to find out the order based on `order_date` and `customer_id`
- **JOIN** `sales`, `menu` and `members` tables because the required columns are in different tables
- Use **WHERE** to filter days before became a `member` and first order.

````sql
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
````


#### Answer:
customer_id | product_name
-- | --
A | curry
A | sushi
B | sushi

- Customer A before becoming a member orders curry and sushi.
- Customer B before becoming a member orders sushi.

***

### 8. *What is the total items and amount spent for each member before they became a member?*

#### Steps:
- Use **COUNT**, **SUM** and **GROUP BY** to find the `total items` and `total amount` spent by each customer
- **JOIN** `sales`, `menu` and `members` tables because the required columns are in different tables
- Use **WHERE** to filter days before became a `member`.

````sql
select 
	s.customer_id,
	count(distinct s.product_id) items,
	sum(m.price) amount
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
where s.order_date < ms.join_date
group by s.customer_id;
````


#### Answer:
customer_id | items | amount
-- | -- | --
A | 2 | 25
B | 2 | 40
	
- Customer A purchased 2 items for $25.
- Customer B purchased 2 items for $40.

***

### 9. *If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*

#### Steps:
- Use **CASE** to create a `points` column
- Use **SUM** and **GROUP BY** to find the `total points` would by each customer.

````sql
select 
	s.customer_id,
	sum(cp.points) points
from sales s
left join (select *, 
			case when product_name = 'sushi' then price*20
				else price*10 end points
			from menu) cp on s.product_id = cp.product_id
group by s.customer_id;
````


#### Answer:
customer_id | points
-- | --
A | 860
B | 940
C | 360
	
- Customer A has 860 points.
- Customer B has 940 points.
- Customer C has 360 points.

***

### 10. *In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*

#### Steps:
- Use **CASE** to create a `points` column
- **JOIN** `sales`, `menu` and `members` tables because the required columns are in different tables
- Use **WHERE** to filter for January.
- Use **SUM** and **GROUP BY** to find the `total points` would by each customer.

````sql
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
````


#### Answer:
customer_id | points
-- | --
A | 1270
B | 720

- Customer A has 1270 points.
- Customer B has 720 points.

***

### *Join All The Things*

#### Steps:
- Use **CASE** to create a `member` column
- **JOIN** `sales`, `menu` and `members` tables because the required columns are in different tables.

````sql
select s.customer_id, s.order_date, m.product_name, m.price,
		case when s.order_date >= ms.join_date then 'Y'
			else 'N' end member
from sales s
left join menu m on s.product_id = m.product_id
left join members ms on s.customer_id = ms.customer_id
order by s.customer_id, s.order_date, m.product_name;
````


#### Answer:
customer_id | order_date | product_name | price | member
-- | -- | -- | -- | --
A | 2021-01-01 | curry | 15 | N
A | 2021-01-01 | sushi | 10 | N
A | 2021-01-07 | curry | 15 | Y
A | 2021-01-10 | ramen | 12 | Y
A | 2021-01-11 | ramen | 12 | Y
A | 2021-01-11 | ramen | 12 | Y
B | 2021-01-01 | curry | 15 | N
B | 2021-01-02 | curry | 15 | N
B | 2021-01-04 | sushi | 10 | N
B | 2021-01-11 | sushi | 10 | Y
B | 2021-01-16 | ramen | 12 | Y
B | 2021-02-01 | ramen | 12 | Y
C | 2021-01-01 | ramen | 12 | N
C | 2021-01-01 | ramen | 12 | N
C | 2021-01-07 | ramen | 12 | N	
	
***

### *Rank All The Things*

#### Steps:
- Use **CASE** to create a `member` column
- **JOIN** `sales`, `menu` and `members` tables because the required columns are in different tables.
- Use **RANK** to create a `rangking` column based on `order_date`, `customer_id` and `member`

````sql
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
````


#### Answer:
customer_id | order_date | product_name | price | member | rangking
-- | -- | -- | -- | -- | --
A | 2021-01-01 | curry | 15 | N | NULL
A | 2021-01-01 | sushi | 10 | N | NULL
A | 2021-01-07 | curry | 15 | Y | 1
A | 2021-01-10 | ramen | 12 | Y | 2
A | 2021-01-11 | ramen | 12 | Y | 3
A | 2021-01-11 | ramen | 12 | Y | 4
B | 2021-01-01 | curry | 15 | N | NULL
B | 2021-01-02 | curry | 15 | N | NULL
B | 2021-01-04 | sushi | 10 | N | NULL
B | 2021-01-11 | sushi | 10 | Y | 1
B | 2021-01-16 | ramen | 12 | Y | 2
B | 2021-02-01 | ramen | 12 | Y | 3
C | 2021-01-01 | ramen | 12 | N | NULL
C | 2021-01-01 | ramen | 12 | N | NULL
C | 2021-01-07 | ramen | 12 | N	| NULL
	
***

# <h1 align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
