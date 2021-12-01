# <p align="center" style="margin-top: 0px;">🥑 Case Study #3 - Foodie-Fi 🥑
## <p align="center"> A. Customer Journey

## Solution

View the complete syntax [*here*](https://github.com/hydaai/8-Week-SQL-Challenge/tree/main/Case%20Study%20%233%20-%20Foodie-Fi/Scripts).

***

### *Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.*

customer_id | plan_id | start_date
--| -- | -- 
1 | 0 | 2020-08-01
1 | 1 | 2020-08-08
2 | 0 | 2020-09-20
2 | 3 | 2020-09-27
11 | 0 | 2020-11-19
11 | 4 | 2020-11-26
13 | 0 | 2020-12-15
13 | 1 | 2020-12-22
13 | 2 | 2021-03-29
15 | 0 | 2020-03-17
15 | 2 | 2020-03-24
15 | 4 | 2020-04-29
16 | 0 | 2020-05-31
16 | 1 | 2020-06-07
16 | 3 | 2020-10-21
18 | 0 | 2020-07-06
18 | 2 | 2020-07-13
19 | 0 | 2020-06-22
19 | 2 | 2020-06-29
19 | 3 | 2020-08-29

#### Steps:
- Create a base table with columns:
	- customer_id,
	- plan_id,
	- plan_name,
	- start_date
- Separately fetch data where `customer_id` is in 11, 15, 19.

#### Answer:
````sql
select
	s.customer_id,
	s.plan_id,
	p.plan_name,
	s.start_date
from subscriptions s
left join plans p on p.plan_id = s.plan_id
where s.customer_id in (1, 2, 11, 13, 15, 16, 18, 19);
````

customer_id | plan_id | plan_name | start_date
--| -- | -- | --
1 | 0 | trial | 2020-08-01
1 | 1 | basic monthly | 2020-08-08
2 | 0 | trial | 2020-09-20
2 | 3 | pro annual | 2020-09-27
11 | 0 | trial | 2020-11-19
11 | 4 | churn | 2020-11-26
13 | 0 | trial | 2020-12-15
13 | 1 | basic monthly | 2020-12-22
13 | 2 | pro monthly | 2021-03-29
15 | 0 | trial | 2020-03-17
15 | 2 | pro monthly | 2020-03-24
15 | 4 | churn | 2020-04-29
16 | 0 | trial | 2020-05-31
16 | 1 | basic monthly | 2020-06-07
16 | 3 | pro annual | 2020-10-21
18 | 0 | trial | 2020-07-06
18 | 2 | pro monthly | 2020-07-13
19 | 0 | trial | 2020-06-22
19 | 2 | pro monthly | 2020-06-29
19 | 3 | pro annual | 2020-08-29

From the sample it is known that the first customer signed up to an initial 7 day free trial on March 17, 2020 (customer  15). 
  On average after the free trial runs out customers only choose 1 plan.
  Furthermore, from the existing sample, 3 customers will be selected a brief description of the orientation journey.

customer_id | plan_id | plan_name | start_date
--| -- | -- | --
19 | 0 | trial | 2020-06-22
19 | 2 | pro monthly | 2020-06-29
19 | 3 | pro annual | 2020-08-29

Subscriber 19 started subscribing on June 22, 2020. 
  After the 7 day free trial period ran out he continued with the pro monthly plan. 
  After two months he switched to the pro annual plan.

customer_id | plan_id | plan_name | start_date
--| -- | -- | --
15 | 0 | trial | 2020-03-17
15 | 2 | pro monthly | 2020-03-24
15 | 4 | churn | 2020-04-29

Subscriber 15 started subscribing on March 17, 2020. 
  After free trial period ran out he continued with the pro monthly plan. 
  Unfortunately next month he canceled the service (churn).

customer_id | plan_id | plan_name | start_date
--| -- | -- | --
11 | 0 | trial | 2020-11-19
11 | 4 | churn | 2020-11-26

Subscriber 11 started subscribing on November 11, 2020. 
  Unfortunately after free trial period ran out he canceled the service (churn).

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻

