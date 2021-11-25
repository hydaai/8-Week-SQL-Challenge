# <h1 align="center" style="margin-top: 0px;">🍜 Case Study #1 - Danny's Diner 🍜

<p align="center" style="margin-bottom: 0px !important;">
  <img src="https://user-images.githubusercontent.com/43850912/143439678-6e4474a8-abbe-4914-8f7d-fcfaa6371a2b.png" width="540" height="540">

## 🧾 Table of Contents
- [Business Case](#business-case)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Case Study Questions](#case-study-questions)
- [Solution on GitHub](https://github.com/hydaai/8-Week-SQL-Challenge/blob/2245231af860087ae4833dba43da0af6481e36ae/Case%20Study%20%231%20-%20Danny's%20Diner/Solution.md)
- [Solution on Medium](https://medium.com/@ai.z.hida/8-week-sql-challenge-1-dannys-diner-9a6e54e023ab)
    
***

## Business Case
  
In early 2021 Danny opened a little restaurant (Danny's Diner) which sells 3 foods: sushi, curry and ramen. To help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation.

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. "Whether he should expand the existing customer loyalty program?"
    
***
    
## Entity Relationship Diagram
<p align="center" style="margin-bottom: 0px !important;">
  <img src="https://user-images.githubusercontent.com/43850912/143439961-d2a99289-bd1d-4a52-b095-6c1feb4ad9b2.png">
    
***
  
## Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  
<details><summary>
  Bonus Questions</summary>
  
### Join All The Things
Recreate table with column: customer_id, order_date, product_name, price, member(Y/N).
  
### Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.
</details>
  
# <h1 align="center" style="margin-top: 0px;">👩‍💻👩‍💻👩‍💻
