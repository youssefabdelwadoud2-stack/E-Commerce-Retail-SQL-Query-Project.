
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
<img width="1601" height="898" alt="Screenshot (275)" src="https://github.com/user-attachments/assets/958c4494-94fc-4dd3-849a-880f7a1b42b6" />

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

- `SUM()`, `AVG()`,`COUNT()`, `COUNT(DISTINCT)`, `CAST()`
- `INNER JOIN` (4 tables), `Subquery (Derived Table)`, , `RANK()`, `OVER ()`,
- `GROUP BY`, `ORDER BY`

Code


    Select  
         pr.[product_category_name]           As Category
         ,rank() over(
                order by cast(sum(p.order_payment) as int) desc
                     ) as category_rank
         ,(count(distinct pr.[product_id]))    As Total_Product
         ,cast(sum(p.order_payment) as int)    As Total_Revenue
         ,count(distinct o.[order_id])         As Total_Orders
         ,count(oi.[order_item_id])                 As Total_Item
         ,cast(avg (oi.price)as int)           As AVG_Price
         ,cast (sum (p.order_payment) 
               / count( distinct o.[order_id]) as int)  As AVO 
         ,cast(avg(oi.[shipping_charges])as int)       AS AVG_Shpping_Cost
     
    FROM [Retail dataset].[dbo].[orders]  As o
       inner join [Retail dataset].[dbo].[order_items] As oi
          on o.[order_id] = oi.[order_id] 
       inner join [Retail dataset].[dbo].[products]    As pr
          on oi.[product_id] = pr.[product_id] 
       inner join (
           Select [order_id], sum([payment_value]) AS order_payment
           From [Retail dataset].[dbo].[payments]
           Group by [order_id]
             ) AS p
              on  oi.[order_id] = p.[order_id] 
    Group by pr.[product_category_name]
    Order by category_rank Asc;

Result

-
<img width="1564" height="917" alt="Screenshot 2026-10-12 124440" src="https://github.com/user-attachments/assets/6a11f630-b642-4da3-8606-6232092211ac" />


-
<img width="1608" height="949" alt="Screenshot 2026-10-12 124551" src="https://github.com/user-attachments/assets/4d9eba88-63d3-4947-ae9f-0a5f4b645082" />

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
