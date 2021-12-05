# <p align="center" style="margin-top: 0px;"> 💰 Case Study #4 - Data Bank 💰
## <p align="center"> B. Customer Transactions

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%234%20-%20Data%20Bank/Scripts).

***

## 1. *What is the unique count and total amount for each transaction type?*

````sql
select 
	txn_type,
	count(txn_type) unique_count,
	sum(txn_amount) total_amount
from customer_transactions
group by txn_type
order by txn_type;
````


#### Answer:

txn_type | unique_count | total_amount
-- | -- |--
deposit | 2671 | 1359168
purchase | 1617 | 806537
withdrawal | 1580 | 793003

- Deposit has 2671 transactions with an amount of $1359168.
- Purchase has 1617 transactions with an amount of $806537.
- Withdrawal has 1580 transactions with an amount of $793003.

***

## 2. *What is the average total historical deposit counts and amounts for all customers?*

#### Steps:
- Use **WITH common_table_expression** to find the number of transactions and the total of transactions
- Use **AVG** and **WHERE** to find the average deposit.

````sql
WITH 
	historical --total historical counts and amounts
AS
	(
		select
			n.customer_id,
			t.txn_type,
			count(t.txn_type) count,
			avg(t.txn_amount) total_amount
		from customer_transactions t
		left join customer_nodes n on t.customer_id = n.customer_id
		left join regions r on n.region_id = r.region_id
		group by n.customer_id, t.txn_type
	)
select
	avg(count) historical_count,
	avg(total_amount) total_amount
from historical
where txn_type = 'deposit';
````


#### Answer:

historical_count | total_amount
-- | --
37 | 508

- On average, historical deposits have 37 counts and an amount of $508.

***

## 3. *For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?*

#### Steps:
- Use **WITH common_table_expression** to find the number of deposit, purchase and withdrawal separately
- Extract month from `txn_date` can use **DATEPART**, **DATENAME** or **MONTH**
- Use **WHERE** to filter deposit > 1 and purchase >= 1 or withdrawal >= 1.

````sql
WITH 
	historical --count data each type transactions
AS
	(
		select
			n.customer_id,
			DATEPART(M, t.txn_date) month_id,
			DATENAME(M, t.txn_date) month_name,
			count(t.txn_type) total
		from customer_transactions t
		left join customer_nodes n on t.customer_id = n.customer_id
		left join regions r on n.region_id = r.region_id
		group by n.customer_id, DATEPART(M, t.txn_date), DATENAME(M, t.txn_date)
	),
	deposit -- type transactions = deposit
AS
	(
		select
			n.customer_id,
			DATEPART(M, t.txn_date) month_id,
			DATENAME(M, t.txn_date) month_name,
			sum(case when t.txn_type = 'deposit' then 1 else 0 end) deposit
		from customer_transactions t
		left join customer_nodes n on t.customer_id = n.customer_id
		group by n.customer_id, DATEPART(M, t.txn_date), DATENAME(M, t.txn_date)
	),
	purchase -- type transactions = purchase
AS
	(
		select
			n.customer_id,
			DATEPART(M, t.txn_date) month_id,
			sum(case when t.txn_type = 'purchase' then 1 else 0 end) purchase
		from customer_transactions t
		left join customer_nodes n on t.customer_id = n.customer_id
		group by n.customer_id, DATEPART(M, t.txn_date)
	),
	withdrawal -- type transactions = withdrawal
AS
	(
		select
			n.customer_id,
			DATEPART(M, t.txn_date) month_id,
			sum(case when t.txn_type = 'withdrawal' then 1 else 0 end) withdrawal
		from customer_transactions t
		left join customer_nodes n on t.customer_id = n.customer_id
		group by n.customer_id, DATEPART(M, t.txn_date)
	),
	data -- join all data
AS
	(
		select
			h.customer_id,
			h.month_id,
			h.month_name,
			h.total,
			d.deposit,
			p.purchase,
			w.withdrawal
		from historical h
		left join deposit d on h.customer_id = d.customer_id and h.month_id = d.month_id
		left join purchase p on h.customer_id = p.customer_id and h.month_id = p.month_id
		left join withdrawal w on h.customer_id = w.customer_id and h.month_id = w.month_id
	)
select
	month_id,
	month_name,
	COUNT(customer_id) customer_count
from data
where deposit > 1 
	and (purchase >= 1 or withdrawal >= 1)
group by month_id, month_name
order by month_id;
````


#### Answer:

month_id | month_name | customer_count
-- | -- | --
1 | January | 295
2 | February | 298
3 | March | 329
4 | April | 138

- In January there were 295 customers.
- In February there were 298 customers.
- In March there were 329 customers.
- In April there were 138 customers.

***

## 4. *What is the closing balance for each customer at the end of the month?*

#### Steps:
- Use **WITH common_table_expression** to find total amount each customers per month
- Extract month from `txn_date` can use **DATEPART**, **DATENAME** or **MONTH**
- Use **SUM OVER** to find the closing balance.

````sql
WITH 
	balance --count data each type transactions
AS
	(
		select
			customer_id,
			DATEPART(M, txn_date) month_id,
			DATENAME(M, txn_date) month_name,
			sum(case when txn_type in ('purchase','withdrawal') then -txn_amount
				else txn_amount end) txn_amount
		from customer_transactions
		group by customer_id, DATEPART(M, txn_date), DATENAME(M, txn_date)
	)
select
	customer_id,
	month_id,
	month_name,
	SUM(txn_amount) OVER(PARTITION BY customer_id ORDER BY month_id 
						ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) closing_balance
from balance
ORDER BY customer_id, month_id;
````


#### Answer:
***NOTE*** : *Not all output is displayed, considering the number of results and will take up space*	
customer_id | month_id | month_name | closing_balance
-- | -- | -- | --
1 | 1 | January | 312
1 | 3 | March | -640
2 | 1 | January | 549
2 | 3 | March | 610
3 | 1 | January | 144
3 | 2 | February | -821
3 | 3 | March | -1222
3 | 4 | April | -729
4 | 1 | January | 848
4 | 3 | March | 655
5 | 1 | January | 954
5 | 3 | March | -1923
5 | 4 | April | -2413

- Customer 1's closing balance in January was $312 and in March $-640.
- Customer 2's closing balance in January was $549 and in March $610.

***


## 5. *What is the percentage of customers who increase their closing balance by more than 5%?*

#### Steps:
- Use **WITH common_table_expression** to find total amount each customers per month
- Use **CTE** again to the opening and closing balance
- Use **CTE** again to find out the increase in percent
- Use **WHERE** to filter increase closing balance by more than 5%.

````sql
WITH 
	balance --count data each type transactions
AS
	(
		select
			customer_id,
			DATEPART(M, txn_date) month_id,
			DATENAME(M, txn_date) month_name,
			sum(case when txn_type in ('purchase','withdrawal') then -txn_amount
				else txn_amount end) txn_amount
		from customer_transactions
		group by customer_id, DATEPART(M, txn_date), DATENAME(M, txn_date)
	),
	balances --first and closing balances
AS
	(
		select
			customer_id,
			month_id,
			month_name,
			LAG(txn_amount) OVER(PARTITION BY customer_id ORDER BY month_id) opening_balance,
			SUM(txn_amount) OVER(PARTITION BY customer_id ORDER BY month_id 
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) closing_balance
		from balance
	),
	cases --when balance null then 0
AS
	(
		select
			customer_id,
			month_id,
			month_name,
			coalesce(opening_balance,0) opening_balance,
			closing_balance,
			case when opening_balance is null then cast((closing_balance - 0) as float)
				else cast((closing_balance - opening_balance) as float) end diff
		from balances
	),
	percents --percentage increase
AS
	(
		select *, 
			case when opening_balance = 0 then round(cast(diff/1*100 as float), 2)
				else round(cast(diff/opening_balance*100 as float), 2) end percentage
		from cases
	),
	minimum --when balance null then 0
AS
	(
		select *,
			MIN(percentage) OVER(PARTITION BY customer_id) mins
		from percents
	)
select ROUND(100 * CAST(COUNT(customer_id) as float) / 
			(select count(*) from customer_transactions), 2) percentage_of_customers
from minimum
where mins > 5;
````


#### Answer:

|percentage_of_customers|
| -- |
|4.24|

- 4.24% of customers increase their closing balance more than 5%.

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻

