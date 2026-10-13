
 E-Commerce Retail SQL Analytics Project

-
Overview
- This project demonstrates how to translate real world business questions into structured SQL queries and extract actionable insights from raw data using
Microsoft SQL Server (SSMS).
-
- The dataset represents an (E-Commerce retail store). I designed and built a relational database named `E-Commerce-Retail-dataset`
- Consisting of five normalized tables: `customers`, `orders`, `order_items`, `payments`, and `products`.
- The tables are connected through primary and foreign keys to form a clear Data Modeling (star schema), which supports analysis of customers,
sales, products, delivery performance, and payment behavior.
-
Objectives
- Design a clean relational data model for an E-commerce business.
- Practice writing SQL queries that answer real business questions.
- Explore customer, order, product, and payment data.
- Build a foundation for deeper analysis (aggregations, joins, Window functions, Sub-queries, KPIs, reporting).
-
 Tools And Technologies
- Microsoft SQL Server 
- SQL Server Management Studio (SSMS)
- Data Modeling And Clinging 
- Database Diagrams (ERD)


The diagram below shows the data model of the `E-Commerce Retail dataset` And the relationships between its five tables:

-  `customers` To `orders`     : one customer can place many orders (via `customer_id`).
-  `orders` To `order_items`   : each order contains one or more items (via `order_id`).
-  `orders` To `payments`      : each order has one or more payments (via `order_id`).
-  `products` To `order_items` : each product can appear in many order lines (via `product_id`).
-
- `order_items` acts as the central `bridge table` that connects orders with products, while `orders` links customers, items, and payments together.


-

                                             Database Diagrams (ERD)

<img width="1588" height="910" alt="Screenshot 2026-10-13 065231" src="https://github.com/user-attachments/assets/3182756b-4574-4019-b46a-bcedca41962c" />


-
-
-

Table: Customers

- Stores basic information about each customer and where they are located.
- Use cases: geographic analysis, top cities or states by customers, regional sales.

- `customer_id` (PK)         : Unique identifier for each customer 
- `customer_zip_code_prefix` : Customer's ZIP code prefix 
- `customer_city`            : City of the customer 
- `customer_state`           : State of the customer 
-


                                                     1- Customers Table  
<img width="1555" height="897" alt="Screenshot (276)" src="https://github.com/user-attachments/assets/e3320ea0-3186-4f78-9feb-ed13fdd2c45d" />


-
-
-
Table: Orders
- Contains the lifecycle of every order, from purchase to delivery.
- Use cases: delivery performance, late deliveries, order status breakdown, monthly order trends.

- `order_id` (PK) : Unique identifier for each order 
- `customer_id` (FK) : The customer who placed the order 
- `order_status` : Current status (e.g., delivered, invoiced) 
- `order_purchase_timestamp` : When the order was placed 
- `order_approved_at` : When the payment was approved 
- `order_delivered_timestamp` : When the order was delivered 
- `order_estimated_delivery_date` : Estimated delivery date promised to the customer 
-


 
                                                     2- Orders Table  
<img width="1666" height="897" alt="Screenshot (278)" src="https://github.com/user-attachments/assets/391e6cd8-b480-438c-8615-e5ce96ad6ab7" />

-
-
-
Table: Order_items

- Holds the individual items inside each order (one row per item).
= Use cases: revenue analysis, best selling products, seller performance, shipping cost analysis.

- `order_id` (FK) : The order this item belongs to 
- `order_item_id` : Sequence number of the item within the order 
- `product_id` (FK) - The product that was purchased 
- `seller_id` : The seller who sold the product 
- `price` : Item price 
- `shipping_charges` : Shipping cost for the item 
-

                                                     3- Order_items Table

<img width="1618" height="879" alt="Screenshot (279)" src="https://github.com/user-attachments/assets/09e34a7e-4d57-4802-bf61-975a12b84849" />

-
-
-


Table: Payments

- Records how customers paid for their orders.
- Use cases: payment method distribution, installment behavior, total revenue per payment type.

- `order_id` (FK) : The order that was paid 
- `payment_sequential` : Sequence number when multiple payment methods are used 
- `payment_type` : Payment method (credit_card, wallet, ...) 
- `payment_installments` : Number of installments chosen 
 `payment_value` : Amount paid 
-


                                                     4- Payments Table
<img width="1651" height="895" alt="Screenshot (280)" src="https://github.com/user-attachments/assets/113d62a4-84fe-47e8-a1c1-ec90ed9ed2ba" />

-
-
-


Table: Products

- Describes the catalog of products sold in the store.
- Use cases: sales by category, shipping/size analysis, product catalog exploration.

- `product_id` (PK) : Unique identifier for each product 
- `product_category_name` : Product category (toys, auto, housewares, ...) 
- `product_weight_g` : Weight in grams 
- `product_length_cm` : Length in centimeters 
- `product_height_cm` : Height in centimeters 
- `product_width_cm` : Width in centimeters 

-

                                                     5- Products Table

<img width="1630" height="892" alt="Screenshot (281)" src="https://github.com/user-attachments/assets/b492b73d-ad93-4ded-b919-d4d919c9d4b2" />

-
-
-
-
-
-


Business Questions And SQL Practice

- After building the `E-Commerce Retail dataset` database and defining its data model (ERD and five tables),
- This section applies the data to practical business questions.
-

Each query below follows the same structure:

1. Business Question: the problem a stakeholder wants answered.
2. Objective: why the question matters and what decision it supports.
3. SQL Concepts Used: the T-SQL techniques practiced.
4. Code: the query written in SQL Server Management Studio (SSMS).
5. Result: a screenshot of the output.

The goal is to practice translating business needs into SQL and to build skills in joins, aggregations, window functions, filtering, and sorting on real world
E-commerce data.

-
-
-


Top Performing Products within Each Category

Business Question

- Which products generate the most revenue within each product category
- How do they compare in order volume, item count,
- Average price and average shipping cost?

Objective

- Rank every product inside its own category by total revenue to identify the best sellers in each category.
- This helps the business decide which products to prioritize in inventory, promotion, and pricing, and shows how shipping
cost relates to each product's performance.

SQL Concepts Used
- `SUM()`, `AVG()`, `COUNT()`, `COUNT(DISTINCT)`, `CAST()`
- `INNER JOIN` (3 tables), `DENSE_RANK()`, `OVER (PARTITION BY ... ORDER BY ...)`
- `GROUP BY`, `ORDER BY`

-
Code 

     Select 
          oi.[product_id]
          ,pr.[product_category_name]
          ,Dense_Rank() over (
                  partition by pr.[product_category_name]
                  order by sum (p.[payment_value]) desc
                  ) As Proudct_Rank
          ,count(distinct oi.[order_id])             As Total_Orders
          ,count(oi.[order_item_id])                 As Total_Item
          ,cast(avg(oi.[price])         as int)      As Avg_Price 
          ,cast(sum (p.[payment_value]) as int)      As Total_Revenue
           ,cast(avg([shipping_charges]) as int)      As Avg_Shipping
      
     From [Retail dataset].[dbo].[payments]                As p 
       inner join  [Retail dataset].[dbo].[order_items]    As oi
          on p.[order_id] = oi.[order_id]
     inner join [Retail dataset].[dbo].[products]        As pr
          on oi.[product_id] = pr.[product_id]

     Group by oi.[product_id], pr.[product_category_name]
      Order by pr.[product_category_name],Proudct_Rank ;

Result

-

<img width="1666" height="895" alt="Screenshot (285)" src="https://github.com/user-attachments/assets/fa3960d9-871b-4c1b-bba4-d14d12bddc67" />

-

<img width="1605" height="940" alt="Screenshot 2026-10-12 122147" src="https://github.com/user-attachments/assets/f2e85117-f9d1-4f22-bdab-5ef53b89fa5f" />

-
-
-

Go 



Product Category Performance Ranking

Business Question

- Which product categories generate the most revenue, and how do they compare in product variety, order volume, items sold, average price, average order value, and shipping cost?

Objective

- Rank all product categories by total revenue to identify the best performing ones and
- Understand what drives their performance (number of products, order volume, price level, or basket size).
- This supports decisions on inventory planning, marketing focus, and pricing and shipping strategy.

SQL Concepts Used
`CTE (Common Table Expressions)`, `Subquery (Derived Table)`, `INNER JOIN`, `Window Functions (SUM() OVER with PARTITION BY`, `DENSE_RANK() OVER with PARTITION BY)`, `SUM()`, `COUNT(DISTINCT)`, `AVG()`, `NULLIF()`, `CAST()`, `GROUP BY`, `ORDER BY`

Code


    

     WITH item_payment AS
        (
      Select
              oi.[order_id]
             ,oi.[order_item_id]
             ,oi.[product_id]
             ,oi.[price]
             ,oi.[shipping_charges]
             ,pay.[order_payment] * (oi.[price] + oi.[shipping_charges])
                  / NULLIF(SUM(oi.[price] + oi.[shipping_charges])
                        OVER (PARTITION BY oi.[order_id]), 0)   As payment_value
      From [Retail dataset].[dbo].[order_items] As oi
         inner join (
               Select [order_id], sum([payment_value]) As order_payment
               From [Retail dataset].[dbo].[payments]
               Group by [order_id]
                     ) As pay
               on oi.[order_id] = pay.[order_id]
         )
      Select 
              p.[product_id]
              ,pr.[product_category_name]
              ,Dense_Rank() over (
              partition by pr.[product_category_name]
              order by sum(p.[payment_value]) desc
                 ) As Proudct_Rank
              ,count(distinct p.[order_id])             As Total_Orders
              ,count(p.[order_item_id])                 As Total_Item
              ,cast(avg(p.[price])         as int)      As Avg_Price 
              ,cast(sum(p.[payment_value]) as int)      As Total_Revenue
              ,cast(avg(p.[shipping_charges]) as int)   As Avg_Shipping

      From item_payment As p
           inner join [Retail dataset].[dbo].[products] As pr
              on p.[product_id] = pr.[product_id]

      Group by p.[product_id], pr.[product_category_name]
      Order by pr.[product_category_name], Proudct_Rank;


Result

-
<img width="1610" height="950" alt="Screenshot 2026-10-12 231304" src="https://github.com/user-attachments/assets/c10d92dd-4d14-4496-a910-8a16adecb30e" />

-

<img width="1606" height="940" alt="Screenshot 2026-10-12 231401" src="https://github.com/user-attachments/assets/7cd6170f-19ca-49aa-8eb0-133d2cb7ca4e" />

-
-
-
Go

Best Selling Products (More Than 50 Order Lines)

Business Question

- Which products are the most in demand, with more than 50 sold order lines
- How do their total orders compare to total items sold?

Objective

- Identify the high volume products that drive the most sales activity so the business can prioritize them in inventory planning, promotions, and supply.
management, and avoid stock-outs on the products customers buy most.

SQL Concepts Used

`INNER JOIN`, `COUNT()`, `COUNT(DISTINCT)`, `GROUP BY`, `HAVING`, `ORDER BY`

Code
​         
    
    Select 
        p.[Product_id]
        ,count (distinct oi.[order_id])            As Total_Orderd
        ,count(oi.[order_item_id])                 As Total_Item
    From [Retail dataset].[dbo].[products] As p
       inner join [Retail dataset].[dbo].[order_items] As oi
         on p.[product_id] = oi.[product_id]
    Group by p.[product_id]
    Having count(oi.[order_id]) > 50
    Order by Total_Item Desc;

Result
-
<img width="1607" height="952" alt="Screenshot 2026-10-12 125823" src="https://github.com/user-attachments/assets/174ebd96-3392-4e7d-8d0d-c0dcf2f64b4d" />


-
-
-
Go


Shipping Cost: Light vs. Heavy Products

Business Question

How does the average shipping charge differ between light products (under 1 Kg) and heavy products (over 5 Kg), and how many items fall into each group?

Objective
Understand how product weight affects shipping cost, to support decisions
on shipping fee policies, free-shipping thresholds, and pricing of heavy
products. It also shows how much of the sales volume comes from each
weight group.

SQL Concepts Used
`INNER JOIN`, `CASE WHEN`, `COUNT()`, `AVG()`, `WHERE`, `GROUP BY`,
`ORDER BY`

Code
​


    Select
         count(*)                     AS Total_items
         ,avg(oi.[shipping_charges])  As AVG_shipping_Cost
         ,case
          when p.[product_weight_g] < 1000 then 'Light_Weight' 
          when p.[product_weight_g] > 5000 then 'Heavy_Weight'
         end As Product_Weight
       
    From [Retail dataset].[dbo].[order_items] as oi
       inner join [Retail dataset].[dbo].[products] as p
          on oi.product_id = p.product_id

    Where p.[product_weight_g] < 1000  
       or p.[product_weight_g] > 5000
    Group by  case
          when p.[product_weight_g] < 1000 then 'Light_Weight' 
          when p.[product_weight_g] > 5000 then 'Heavy_Weight'
          end 
    Order by AVG_shipping_Cost desc;



Result

-
<img width="1603" height="950" alt="image" src="https://github.com/user-attachments/assets/376a8095-8271-466b-9122-edd8d22dc493" />

-
-
-

Go
-

Customer Segmentation: Repeat vs. One Time Customers

Business Question

- How many orders has each customer placed?
- How much revenue does each customer generate?
- Which customers are repeat buyers compared to one time buyers?

Objective

- Segment customers by purchasing behavior to understand loyalty and revenue contribution. 
- This helps the business design retention campaigns for repeat customers, convert one time buyers into returning ones, and measure how much revenue depends on loyal customers.

SQL Concepts Used:

`Subquery (Derived Table)`, `INNER JOIN`, `COUNT(DISTINCT)`, `SUM()`, `CASE WHEN`, `GROUP BY`, `ORDER BY`

Code

         
    Select 
      [customer_id]
     ,Total_orders
     ,Total_Revenue
    
    ,case 
      when Total_orders > 1  then 'Repeat Customer'
      else 'One Time Customer'
     end as customer_Type
    From 
     (
      Select
           o.[customer_id] 
          ,count(distinct o.[order_id])    As     Total_Orders
          ,sum(p.[payment_value])          As     Total_Revenue
      From [Retail dataset].[dbo].[orders] As o
        inner join [Retail dataset].[dbo].[payments] As p
         on o.order_id = p.order_id
      Group by o.[customer_id]
       )    As customer_orders
    Order by Total_orders Desc;




-

Result
-
<img width="1613" height="887" alt="Screenshot 2026-10-12 184958" src="https://github.com/user-attachments/assets/c2f2521b-7ac0-4b14-9871-6ec544374a3a" />

-
<img width="1602" height="946" alt="Screenshot 2026-10-12 185120" src="https://github.com/user-attachments/assets/779b819f-2789-4ed5-b2b5-1d2f746a4d9c" />

-
-
-




Go
Customer Segmentation: Repeat vs. One-Time Customers

Business Question

- How many orders has each customer placed, how much revenue does each customer generate
- Which customers are repeat buyers compared to one time buyers?

Objective

- Segment customers by purchasing behavior to understand loyalty and revenue contribution.
- This helps the business to:
  
1- design retention campaigns for repeat customers.
2- Convert one time buyers into returning ones.
3- Measure how much revenue depends on loyal customers.

SQL Concepts Used

`Subquery (Derived Table)`, `INNER JOIN`, `COUNT(DISTINCT)`, `SUM()`, `CASE WHEN`, `GROUP BY`, `ORDER BY`

Code

    Select 
         Customer_id
         ,ntile(4) over( 
             order by Total_Spending desc) As Segment_Rank 
         ,Total_Orders
         ,Total_Spending 
    From ( 
         select 
              o.[customer_id]                AS Customer_id
              ,Sum(p.[payment_value])        As Total_Spending
              ,Count(o.[order_id])           As Total_Orders
        from [Retail dataset].[dbo].[orders] as o
          inner join [Retail dataset].[dbo].[payments] as p
            on o.[order_id] = p.[order_id] 
        Group by  o.[customer_id]
             ) As Total_Spending         
    Order by 
        Segment_Rank, Total_Spending desc;


Result
-
<img width="1604" height="954" alt="Screenshot 2026-10-12 134608" src="https://github.com/user-attachments/assets/981707f6-bbae-4d8c-b1cb-dfb4d81b17d8" />

-
<img width="1600" height="952" alt="Screenshot 2026-10-12 134857" src="https://github.com/user-attachments/assets/de708429-c6e3-42bc-96c2-368e1f87ce32" />


-
-
-

Go
-

Customer Segmentation by Spending Value

Business Question

- How much has each customer spent in total?
- Which customers fall into the low, medium, or high value segments?

Objective

- Group customers into value tiers based on their total spending (under 500 = Low Value, 500 to under 1,500 = Medium Value, 1,500 and above = High Value). 
- This helps the business
  
1- identify its most valuable customers. 2- design targeted offers and loyalty programs for the high value segment 3- build strategies to move low-value customers up to higher tiers.

SQL Concepts Used

`Subquery (Derived Table)`, `INNER JOIN`, `SUM()`, `CASE WHEN`, `GROUP BY`, `ORDER BY`

Code


     Select 
        [Customer_id]
       ,Customer_Value
       ,case
         when Customer_Value < 500 then 'Low_Value'
         when Customer_Value < 1500 then 'Medium_Value'
         else 'High_Value'
       end As Customer_Segment
    From
      ( 
        Select 
            o.[customer_id]
            ,sum(p.[payment_value])         As Customer_Value
        from [Retail dataset].[dbo].[orders] As o
          inner join [Retail dataset].[dbo].[payments] As p
           on o.order_id = p.order_id
            group by [customer_id]
      ) as customer_spending

    Order by Customer_Value desc;

-

Result
-
<img width="1608" height="960" alt="Screenshot 2026-10-12 190029" src="https://github.com/user-attachments/assets/cb8d9e68-e196-48c5-9fbb-edac16e457a5" />


-
-
-

Go
-

Monthly Sales Trend with Running Total

Business Question

- What are the total sales for each month, and how do sales accumulate over time (running total)?

Objective

- Track monthly sales performance and the cumulative growth of revenue over time. 
- This helps the business:
1- Spot seasonality, identify strong and weak months 2- Measure overall growth across the period.

SQL Concepts Used

`Subquery (Derived Table)`, `INNER JOIN (3 tables)`, `SUM()`, `Window Function` , `YEAR()`, `MONTH()`, `CAST()`, `GROUP BY`, `ORDER BY`

Code

     Select 
          Years
          ,Months
          ,Total_Sales
          ,cast (sum(Total_Sales) over(
                order by Years, Months
                     ) As int ) As Total_Running  
     From
       (
        Select
           YEAR(o.[order_approved_at])            AS  Years
           ,MONTH(o.[order_approved_at])           AS  Months
           ,cast(sum(p.[Payment_value]) as int)    As Total_Sales

         From [Retail dataset].[dbo].[orders]            As o
            inner join [Retail dataset].[dbo].[order_items] As oi
               on o.order_id = oi.order_id
            inner join [Retail dataset].[dbo].[payments]    As p
               on o.order_id = p.order_id

     Group by   YEAR(o.[order_approved_at])
            ,MONTH(o.[order_approved_at])
        ) As Monthly_sales
     Order by Total_Running DESC;


-

Result
-
<img width="1610" height="953" alt="Screenshot 2026-10-12 190745" src="https://github.com/user-attachments/assets/b313aca8-7cc3-4dd6-bd7e-c5a4088420f2" />




-
-
-

Go
-   

Sales Performance by Day of the Week

Business Question

Which days of the week receive the most orders and generate the most revenue?

Objective

- Understand weekly buying patterns by comparing order volume and revenue for each weekday.
- This helps the business:
1- choose the best days for promotions, plan staffing and inventory 2- Schedule marketing campaigns when customers are most active.

SQL Concepts Used:

`INNER JOIN (3 tables)`,` DATENAME()`, `COUNT(DISTINCT)`, `SUM()`, `CAST()`, `GROUP BY`, `ORDER BY`

Code


    Select distinct
         DATENAME(WEEKDAY,[order_approved_at]) week_day
         ,count(o.[order_id])          As total_order 
         ,cast(sum(p.[payment_value]) As int)   As Total_Revenue

    From [Retail dataset].[dbo].[orders] as o 
       inner join [Retail dataset].[dbo].[order_items] as oi
          on o.[order_id] = oi.[order_id] 
       inner join [Retail dataset].[dbo].[payments] as p
          on oi.[order_id] = p.[order_id] 
    GROUP BY
         DATENAME(WEEKDAY, [order_approved_at])
    ORDER BY
         Total_order DESC;



-

Result
-

<img width="1612" height="942" alt="Screenshot 2026-10-12 191456" src="https://github.com/user-attachments/assets/2e3f2118-f2ca-49da-a6b5-8bc045db9f0a" />



-
-
-

Go
-   

Yearly Sales and Average Order Value

Business Question

What are the total sales, total number of orders, and average order value (AOV) for each year?

Objective

- Track yearly business performance and measure growth in revenue and order volume over time.
-  Comparing the average order value across years also shows whether customers are spending more per order, which supports decisions on pricing, promotions, and long term planning.

SQL Concepts Used

`INNER JOIN`, `YEAR()`, `SUM()`, `COUNT(DISTINCT)`, `CAST()`,`GROUP BY`, `ORDER BY`

Code

     Select
          year(o.[order_estimated_delivery_date])   As Years
         ,sum(p.[payment_value])                    As Total_Sales
         ,count(distinct o.[order_id])              As Total_Orders           
         ,sum(p.[payment_value]) /
         count(distinct o.[order_id])               As AVO
    From [Retail dataset].[dbo].[payments] as p
         inner join [Retail dataset].[dbo].[orders] as o
           on p.order_id = o.order_id

    Group by year(o.[order_estimated_delivery_date])
    Order by Years;



-

Result
-


<img width="1600" height="947" alt="Screenshot 2026-10-12 192311" src="https://github.com/user-attachments/assets/58ee84ad-4e29-47f0-a8ba-5b784463db0c" />



-
-
-

Go
-   


Monthly Revenue, Orders, and Average Order Value Report

Business Question

What are the total revenue, number of orders, and average order value (AOV) for each month?

Objective

- Build a monthly performance report that tracks revenue, order volume, and the average amount spent per order.
- This helps the business spot seasonality, compare strong and weak months, and see whether revenue growth comes from more orders or from higher spending per order.

SQL Concepts Used

`INNER JOIN`, `YEAR()`, `MONTH()`, `SUM()`, `COUNT(DISTINCT)`,`ROUND()`, `NULLIF()`, `CAST()`, `GROUP BY`,`ORDER BY`


Code

     Select
          year([order_estimated_delivery_date])     As Years 
         ,month([order_estimated_delivery_date])    As Months
         ,sum(p.[payment_value])                    As Revenue
         ,count(distinct (o.[order_id]))            As Total_Orders
         ,Round(
            sum(p.[payment_value]) / nullif(count(distinct o.[order_id]),0),2
               )  As AVO

     From [Retail dataset].[dbo].[orders]              AS o
        inner join [Retail dataset].[dbo].[payments]   AS p
            on o.order_id = p.order_id
     Group by 
          month([order_estimated_delivery_date]) 
         ,year([order_estimated_delivery_date])     
     Order by 
         Years  Asc
        ,Months ASC;


-

Result
-

<img width="1600" height="944" alt="Screenshot 2026-10-12 193021" src="https://github.com/user-attachments/assets/e6e31ee7-af36-4ad2-8c59-0bd0e479da29" />





-
-
-

Go
- 


Order Distribution by Hour of the Day

Business Question

At which hours of the day do customers place the most orders?

Objective

- Understand the daily ordering pattern by counting orders for each hour of the day.
- This helps the business
1- Pick the best times for promotions and email campaigns
2- Plan customer support staffing
3- Make sure systems and inventory are ready during peak hours.

SQL Concepts Used

`DATEPART()`, `COUNT()`, `GROUP BY`, `ORDER BY`

Code

     Select 
          DATEPART
          (hour,[order_purchase_timestamp])  As Order_Hours
         ,count(*)                           As Total_Orders
     From  [Retail dataset].[dbo].[orders]
     Group By  DATEPART
            (hour,[order_purchase_timestamp])
     Order By Order_Hours asc;

-

Result
-

<img width="1596" height="950" alt="Screenshot 2026-10-12 193521" src="https://github.com/user-attachments/assets/7fa44a82-a6c6-424e-9e56-2a5406ae52c1" />


-
-
-

Go
-  

Cities Exceeding 300,000 in Revenue, with Orders and Sellers

Business Question

- Which cities generated more than 300,000 in total revenue?
- How many orders and distinct sellers contributed to that revenue?

Objective

- Identify the top-performing cities by revenue and understand what supports their performance: order volume and the number of sellers serving them.
- This helps the business:
1- Prioritize regional marketing.
2- Plan logistics and warehousing.
3- Decide where to recruit more sellers.

SQL Concepts Used

`CTE (Common Table Expressions)`, `INNER JOIN`, `SUM()`, `COUNT(DISTINCT)`, `CAST()`, `GROUP BY`, `HAVING`, `ORDER BY`

Code

 
     WITH
     order_payment AS
       (
         Select order_id, SUM(payment_value) AS order_value
         From [Retail dataset].[dbo].[payments]
         Group By order_id
        ),
     order_sellers AS
        (
         Select DISTINCT order_id, seller_id
         From [Retail dataset].[dbo].[order_items]
        )
     Select
         c.customer_city AS City,
         Cast(Sum(op.order_value) AS DECIMAL(12,2)) AS Total_Revenue,
         Count(Distinct o.order_id)                 AS Total_Orders,
         Count(Distinct os.seller_id)               AS Total_Sellers
     From [Retail dataset].[dbo].[customers]       AS c
       Inner Join [Retail dataset].[dbo].[orders] AS o
         ON c.customer_id = o.customer_id
     Inner Join order_payment AS op
         ON o.order_id = op.order_id
     Inner Join order_sellers AS os
         ON o.order_id = os.order_id
     Group By c.customer_city
     Having sum(op.order_value) > 300000
     Order By Total_Revenue Desc;
-

Result
-

-
<img width="1603" height="939" alt="Screenshot 2026-10-12 201741" src="https://github.com/user-attachments/assets/8b72edd5-1fbb-46e7-b762-9ac484a345ee" />

-

<img width="1603" height="939" alt="Screenshot 2026-10-12 201741" src="https://github.com/user-attachments/assets/dfe42265-22ba-4c98-995e-74e38e6fa118" />

-
-
-

Go



Top 10 States by Revenue and Customers

Business Question

Which are the top 10 states by total revenue, and how many customers does each state have?

Objective

- Identify the highest revenue states and compare them with their customer counts.
- This helps the business:
1-Focus regional marketing, plan logistics and warehouse locations.
1-See whether a state’s revenue comes from a large customer base or from higher spending per customer.

SQL Concepts Used

`TOP`, `INNER JOIN` , `SUM()`, `COUNT(DISTINCT)`, `CAST()`, `GROUP BY`, `ORDER BY`

Code



    Select Top 10
         c.[Customer_State]
        ,cast(sum(p.[payment_value]) as int)     As Revenue 
        ,count( c.[customer_id])                 As Total_Customer
    From [Retail dataset].[dbo].[customers]         As c
      inner join [Retail dataset].[dbo].[orders]   As o
         on c.[customer_id] = o.[customer_id]
      inner join [Retail dataset].[dbo].[payments] As p
         on o.[order_id] = p.[order_id]

    Group by [customer_state] 
    Order by Revenue desc
         ,Total_Customer desc;


-

Result
-

<img width="1608" height="957" alt="Screenshot 2026-10-12 202604" src="https://github.com/user-attachments/assets/a5b221d6-10d1-43e3-bf23-badf8f03d20e" />


-
-
-

Go
-  


Delivery Performance: Early, On Time, Late, and Not Delivered

Business Question

- What percentage of orders were delivered early, on time, or late compared to the estimated delivery date
- How many orders were never delivered?

Objective

- Measure delivery performance by counting orders in each delivery status and showing each status as a share of all orders.
- This helps the business:
1- evaluate logistics reliability
2- Find how many orders are late or undelivered
3- Improve customer satisfaction and delivery promises.

SQL Concepts Used

`Subquery` , `CASE WHEN`, `COUNT()`, `Window Function OVER)`, `CAST()`, `GROUP BY`, `ORDER BY`

Code


      Select 
              Delivery_Status
             ,Count(*)                                         AS Total_Orders
             ,Cast(Cast(Count(*) * 100.0 / Sum(Count(*)) 
              Over () As Decimal(5,2)) AS Varchar(10)) + '%'    As Percentage
      From
        ( 
          select [order_id],
        case 
           when [order_delivered_timestamp] < 
                [order_estimated_delivery_date] then 'Early'
           when [order_delivered_timestamp] = 
                [order_estimated_delivery_date] then 'on_time'
           when [order_delivered_timestamp] > 
                [order_estimated_delivery_date] then 'late'
        else 'Not_Delivered'
        end as Delivery_Status
        FROM [Retail dataset].[dbo].[orders]
           ) as delivary_date
      Group By Delivery_Status
      Order By Total_Orders;
     

-

Result
-

<img width="1607" height="943" alt="Screenshot 2026-10-12 203511" src="https://github.com/user-attachments/assets/9aed9928-f074-449b-b8ac-c942347fd26f" />


-
-
-

Go
-  

Shipping Cost Analysis by State

Business Question

What are the highest, lowest, and average shipping charges for each customer state?

Objective

- Compare shipping costs across states to find which regions are the most and least expensive to ship to.
- This helps the business:
1- Review shipping fee policies.
2- Negotiate with carriers for costly regions.
3- decide where free-shipping offers or regional warehouses would reduce costs.

SQL Concepts Used

`INNER JOIN`, `MAX()`, `MIN()`, `AVG()`, `CAST()`, `GROUP BY`, `ORDER BY`

Code


     Select 
           c.[Customer_State]
           ,max(oi.[shipping_charges])                  As   Max_Shpping_Cost
           ,min(oi.[shipping_charges])                  As   Low_Shpping_Cost
           ,cast(avg(oi.[shipping_charges]) as int)     As   AVG_Shpping_Cost

     From [Retail dataset].[dbo].[customers] as c 
         inner join [Retail dataset].[dbo].[orders] as o
            on c.customer_id = o.customer_id
         inner join [Retail dataset].[dbo].[order_items] as oi
            on o.order_id = oi.order_id

     Group by c.[customer_state]
     Order by Max_Shpping_Cost
             ,Low_Shpping_Cost
             ,AVG_Shpping_Cost;

-

Result
-

<img width="1607" height="951" alt="Screenshot 2026-10-12 210200" src="https://github.com/user-attachments/assets/01690446-88bb-4054-8236-e186afc15374" />


-
-
-

Go
-  

Order Delivery Rate

Business Question

What percentage of all orders were successfully delivered?

Objective

- Measure the overall order fulfillment rate by comparing delivered orders to the total number of orders.
- This helps the business:
1- Evaluate logistics performance at a glance
2- Track fulfillment over time,
3- Spot problems such as high cancellation or undelivered rates.

SQL Concepts Used

`COUNT()`, `CASE WHEN (conditional aggregation)`, `ROUND()`, `NULLIF()`, `CAST()`

Code

     Select
          count(*) as Total_Orders
          ,
          count(
        case
            when [order_status] = 'delivered'
            then 1
        end ) as Delivered_Orders
        ,
        cast ( ROUND(
           count(
        case
            when [order_status] = 'delivered'
            then 1
        end
           ) * 100.0 / nullif(count(*),0),
           0
           ) as int) as Delivary_Rate 
     From [Retail dataset].[dbo].[orders];


-

Result
-

<img width="1611" height="950" alt="Screenshot 2026-10-12 214225" src="https://github.com/user-attachments/assets/967bd97e-60d1-46ed-8d1a-282baeb4e21b" />


-
-
-

Go
-  

Shipping Cost per Gram and per Cubic Centimeter

Business Question

- How much does shipping cost per gram and per cubic centimeter for each product
- How do weight and volume relate to the shipping charge?

Objective

- Measure shipping efficiency by comparing each item’s shipping charge to its weight and its physical volume.
- This helps the business:
1- Understand whether shipping cost is driven more by weight or by package size.
2- Detect products with unusually expensive shipping.
3-refine shipping fee policies for heavy or bulky items.

SQL Concepts Used

`INNER JOIN`, `Arithmetic Expressions (volume = height x length x width)`, `NULLIF()`, `CAST()`

Code


      Select
          p.[product_id]
         ,oi.[shipping_charges]
         ,p.[product_weight_g]
         ,[shipping_charges]/NULLIF(product_weight_g,0) 
              AS shipping_price_per_gram
   
         ,p.[product_height_cm] * p.[product_length_cm]
         * p.[product_width_cm]  As Volum_CM
         
         ,[shipping_charges]/NULLIF(
         p.[product_height_cm] * p.[product_length_cm]
         * p.[product_width_cm] ,0)
         AS shipping_price_per_CM3
      From [Retail dataset].[dbo].[order_items] AS oi
         Inner Join [Retail dataset].[dbo].[products] AS p
            ON oi.product_id = p.product_id;

-

Result
-

<img width="1610" height="956" alt="Screenshot 2026-10-12 220049" src="https://github.com/user-attachments/assets/3963af6c-94be-47ef-86b0-0f013d268074" />


-
-
-

Go
-  

Seller Performance Ranking by Revenue

Business Question

- Which sellers generate the most revenue
- How do they compare in order volume, average order value, and average item price?

Objective

- Rank every seller by total revenue to identify the top performing sellers and understand what drives their results: number of orders, average order value, or item price level.
- This helps the business:
1- Reward and support top sellers
2- Spot underperforming ones
3- Decide where to focus seller development and partnerships.

SQL Concepts Used

`Subquery`, `SUM()`, `COUNT(DISTINCT)`, `AVG()`, `NULLIF()`, `Window Function (DENSE_RANK() OVER)`, `CAST()`, `GROUP BY`, `ORDER BY`

Code


    Select
         Seller_id,
         Total_revenue,
         Total_orders,
         Cast(Total_revenue / NULLIF(Total_orders, 0) AS DECIMAL(10,2)) AS Avg_order_value,
         Avg_item_price,
         Dense_Rank() OVER (ORDER BY Total_revenue DESC)     AS Seller_rank
    From
      (
      Select
           oi.seller_id,
           COUNT(DISTINCT oi.order_id)                    AS Total_orders,
           CAST(SUM(oi.price) AS DECIMAL(12,2))           AS Total_revenue,
           CAST(AVG(oi.price) AS DECIMAL(10,2))           AS Avg_item_price
      From [Retail dataset].[dbo].[order_items] AS oi
       Group By oi.seller_id
       ) As seller_sales
    Order By Seller_rank ASC;

-

Result
-

<img width="1612" height="948" alt="Screenshot 2026-10-12 222912" src="https://github.com/user-attachments/assets/a135cba5-cf71-4aa2-ae59-d291f0b7a2fa" />


-
-
-

Go
-  

Orders with Price Above Twice the Product Average

Business Question

Which order items were sold at a price more than double the average price of the same product?

Objective

- Detect unusually high-priced sales by comparing each item’s price with the average price of its product.
- This helps the business:
1- Spot pricing anomalies.
2- Possible data entry errors.
3- Premium or special-edition sales.
4- Sellers who charge far above the normal price for the same product.

SQL Concepts Used

`Subquery`, `Window Function (AVG() OVER with PARTITION BY)`,`WHERE`,`ORDER BY`

Code


Select 
       [Order_id]
      ,[Product_id]
      ,[Price]
      ,AVG_Product_Price
From 
    (   
    Select
       [Order_id]
      ,[Product_id]
      ,[Price]
      ,avg(Price) over(
           partition by ([Product_id])
             ) as AVG_Product_Price
    From [Retail dataset].[dbo].[order_items]
    )  as product_price

Where Price > AVG_Product_Price * 2
Order by Price desc;


Result
-

<img width="1612" height="949" alt="Screenshot 2026-10-12 223456" src="https://github.com/user-attachments/assets/b866301e-9de4-4355-abbd-55273095ccf4" />

-
-  
Go
-  
