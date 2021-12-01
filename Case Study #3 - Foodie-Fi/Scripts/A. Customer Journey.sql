/*Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!*/
--join the table and filter id customer
select
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where s.customer_id in (1, 2, 11, 13, 15, 16, 18, 19);

--select customer 19
select
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where s.customer_id = 19;

--select customer 15
select
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where s.customer_id = 15;

--select customer 11
select
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where s.customer_id = 11;
