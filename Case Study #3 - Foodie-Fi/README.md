# <p align="center" style="margin-top: 0px;">🥑 Case Study #3 - Foodie-Fi 🥑

<p align="center" style="margin-bottom: 0px !important;">
  <img src="https://user-images.githubusercontent.com/43850912/143991760-d160dbfd-14c3-40c8-8c1a-823716f6ef8e.png" width="540" height="540">

## 🧾 Table of Contents
- [Business Case](#business-case)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Available Data](#available-data)
- [Case Study Questions](#case-study-questions)
- Solution 
  - GitHub
    - [A. Customer Journey](https://github.com/hydaai/8-Week-SQL-Challenge/blob/c45dfc8a626f0cf86361a59edfcb78cfa099cd4d/Case%20Study%20%233%20-%20Foodie-Fi/A.%20Customer%20Journey.md)
    - [B. Data Analysis Questions](https://github.com/hydaai/8-Week-SQL-Challenge/blob/c45dfc8a626f0cf86361a59edfcb78cfa099cd4d/Case%20Study%20%233%20-%20Foodie-Fi/B.%20Data%20Analysis%20Questions.md)
    - [C. Challenge Payment Question](https://github.com/hydaai/8-Week-SQL-Challenge/blob/c45dfc8a626f0cf86361a59edfcb78cfa099cd4d/Case%20Study%20%233%20-%20Foodie-Fi/C.%20Challenge%20Payment%20Question.md)
  - [Medium]
    
***

## Business Case
  
Danny launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, 
	giving their customers unlimited on-demand access to exclusive food videos from around the world!

Danny created Foodie-Fi with a data driven mindset and wanted to ensure all future investment decisions and new features were decided using data. 
	**Using subscription style digital data to answer important business questions.**

***
    
## Entity Relationship Diagram
<p align="center" style="margin-bottom: 0px !important;">
  <img src="https://user-images.githubusercontent.com/43850912/143993105-c30ab129-8a50-4788-aaf7-9e6fb2e830d8.png">

***

## Available Data
  
<details><summary>
    All datasets exist in database schema.
  </summary> 
  
 #### ``Table 1: plans``
plan_id | plan_name | price
-- | -- | --
0 | trial | 0
1 | basic monthly | 9.90
2 | pro monthly | 19.90
3 | pro annual | 199
4 | churn | null

#### ``Table 2: subscriptions``
*Note: this is only customer sample*
customer_id | plan_id | start_date
-- | -- | --
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

  </details>

***

## Case Study Questions
<details><summary>
Each of the following case study questions can be answered using a single SQL statement.
</summary> 

<details><summary>
  A. Customer Journey</summary>
  
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!
</details>
  
<details><summary>
  B. Data Analysis Questions</summary>
  
1. How many customers has Foodie-Fi ever had?
2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
6. What is the number and percentage of customer plans after their initial free trial?
7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
8. How many customers have upgraded to an annual plan in 2020?
9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
</details>

<details><summary>
  C. Challenge Payment Question</summary>
  
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
 - monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
 - upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
 - upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
 - once a customer churns they will no longer make payments
</details>

<details><summary>
  D. Outside The Box Questions</summary>
  
The following are open ended questions which might be asked during a technical interview for this case study - there are no right or wrong answers, but answers that make sense from both a technical and a business perspective make an amazing impression!
1. How would you calculate the rate of growth for Foodie-Fi?
2. What key metrics would you recommend Foodie-Fi management to track over time to assess performance of their overall business?
3. What are some key customer journeys or experiences that you would analyse further to improve customer retention?
4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include in the survey?
5. What business levers could the Foodie-Fi team use to reduce the customer churn rate? How would you validate the effectiveness of your ideas?
	</details></details>
  
# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
