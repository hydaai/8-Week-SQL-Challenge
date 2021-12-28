# <p align="center" style="margin-top: 0px;">💰 Case Study #4 - Data Bank 💰

<p align="center" style="margin-bottom: 0px !important;">
  <img src="https://user-images.githubusercontent.com/43850912/144242375-fa0e601d-ef17-467d-ac70-282a26a2e181.png" width="540" height="540">

## 🧾 Table of Contents
- [Business Case](#business-case)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Available Data](#available-data)
- [Case Study Questions](#case-study-questions)
- Solution 
  - GitHub
    - [A. Customer Nodes Exploration](https://github.com/hydaai/8-Week-SQL-Challenge/blob/83f5ea092b0e305cc61ec4843f0d9559d78c27b0/Case%20Study%20%234%20-%20Data%20Bank/A.%20Customer%20Nodes%20Exploration.md)
    - [B. Customer Transactions.md](https://github.com/hydaai/8-Week-SQL-Challenge/blob/74679d15086153e06f6a2246034119d5172e56bf/Case%20Study%20%234%20-%20Data%20Bank/B.%20Customer%20Transactions.md)
  - [Medium](https://medium.com/@ai.z.hida/8-week-sql-challenge-4-data-bank-ced02ed8e35f)
    
***

## Business Case
  
Another initiative from Danny - Bank Data - some sort of intersection between Neo-Banks 
  (new aged digital only banks without physical branches), cryptocurrency and the data world.

The management team at Data Bank want to increase their total customer base - but also need some help tracking just how much data storage their customers will need.
  **Calculating metrics, growth and analyse data to better forecast and plan for their future developments!**

***
    
## Entity Relationship Diagram
<p align="center" style="margin-bottom: 0px !important;">
  <img src="https://user-images.githubusercontent.com/43850912/144242445-521d1efb-3e05-4f39-87b0-63f468aaa374.png">

***

## Available Data
  
<details><summary>
    All datasets exist in database schema.
  </summary> 
  
 #### ``Table 1: Regions``
region_id | region_name
-- | --
1 | Africa
2 | America
3 | Asia
4 | Europe
5 | Oceania

#### ``Table 2: Customer Nodes``
*Note: this is only customer sample*
customer_id | region_id | node_id | start_date | end_date
-- | -- | -- | -- | --
1 | 3 | 4 | 2020-01-02 | 2020-01-03
2 | 3 | 5 | 2020-01-03 | 2020-01-17
3 | 5 | 4 | 2020-01-27 | 2020-02-18
4 | 5 | 4 | 2020-01-07 | 2020-01-19
5 | 3 | 3 | 2020-01-15 | 2020-01-23
6 | 1 | 1 | 2020-01-11 | 2020-02-06
7 | 2 | 5 | 2020-01-20 | 2020-02-04
8 | 1 | 2 | 2020-01-15 | 2020-01-28
9 | 4 | 5 | 2020-01-21 | 2020-01-25
10 | 3 | 4 | 2020-01-13 | 2020-01-14

#### ``Table 3: Customer Transactions``
*Note: this is only customer sample*
customer_id | txn_date | txn_type | txn_amount
-- | -- | -- | --
429 | 2020-01-21 | deposit | 82
155 | 2020-01-10 | deposit | 712
398 | 2020-01-01 | deposit | 196
255 | 2020-01-14 | deposit | 563
185 | 2020-01-29 | deposit | 626
309 | 2020-01-13 | deposit | 995
312 | 2020-01-20 | deposit | 485
376 | 2020-01-03 | deposit | 706
188 | 2020-01-13 | deposit | 601
138 | 2020-01-11 | deposit | 520

  </details>

***

## Case Study Questions
<details><summary>
Each of the following case study questions can be answered using a single SQL statement.
</summary> 

<details><summary>
  A. Customer Nodes Exploration</summary>
  
1. How many unique nodes are there on the Data Bank system?
2. What is the number of nodes per region?
3. How many customers are allocated to each region?
4. How many days on average are customers reallocated to a different node?
5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
</details>
  
<details><summary>
  B. Customer Transactions</summary>
  
1. What is the unique count and total amount for each transaction type?
2. What is the average total historical deposit counts and amounts for all customers?
3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
4. What is the closing balance for each customer at the end of the month?
5. What is the percentage of customers who increase their closing balance by more than 5%?
</details>

<details><summary>
  C. Challenge Payment Question</summary>
  
To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:
 - Option 1: data is allocated based off the amount of money at the end of the previous month
 - Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
 - Option 3: data is updated real-time

  For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:
 - running customer balance column that includes the impact each transaction
 - customer balance at the end of each month
 - minimum, average and maximum values of the running balance for each customer

Using all of the data available - how much data would have been required for each option on a monthly basis?
</details>

<details><summary>
  D. Outside The Box Questions</summary>
  
Data Bank wants to try another option which is a bit more difficult to implement - they want to calculate data growth using an interest calculation, just like in a traditional savings account you might have with a bank.

If the annual interest rate is set at 6% and the Data Bank team wants to reward its customers by increasing their data allocation based off the interest calculated on a daily basis at the end of each day, how much data would be required for this option on a monthly basis?

Special notes:

 - Data Bank wants an initial calculation which does not allow for compounding interest, however they may also be interested in a daily compounding interest calculation so you can try to perform this calculation if you have the stamina!
	</details>

<details><summary>
  Extension Request</summary>
  
The Data Bank team wants you to use the outputs generated from the above sections to create a quick Powerpoint presentation which will be used as marketing materials for both external investors who might want to buy Data Bank shares and new prospective customers who might want to bank with Data Bank.
1. Using the outputs generated from the customer node questions, 
  generate a few headline insights which Data Bank might use to market it’s world-leading security features to potential investors and customers.
2. With the transaction analysis - prepare a 1 page presentation slide which contains all the relevant information 
  about the various options for the data provisioning so the Data Bank management team can make an informed decision.
</details></details>

***

# <p align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
