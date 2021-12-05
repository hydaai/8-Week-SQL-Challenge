-- 1. What is the unique count and total amount for each transaction type?
select 
	txn_type,
	count(txn_type) unique_count,
	sum(txn_amount) total_amount
from customer_transactions
group by txn_type
order by txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?
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

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
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

-- 4. What is the closing balance for each customer at the end of the month?
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

-- 5. What is the percentage of customers who increase their closing balance by more than 5%?
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
