
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






Business Question

- What are the total revenue and the average item price for each category?

Objective:

- Identify which product categories generate the highest revenue and compare their average price points.

SQL Concepts Used:  aggregation functions`SUM()`, `AVG()`, `LEFT JOIN`, `GROUP BY`, `ORDER BY`. 

-


   
     Select 
  
           P.Product_Category_Name
           ,cast(avg(oi.price)as int) as AVG_Price 
          ,cast(sum(py.payment_value)as int) as Total_Payment
  
     From [Retail dataset].[dbo].[products] as p
          left join [Retail dataset].[dbo].[order_items] as oi
          on p.product_id = oi.product_id
          left join [Retail dataset].[dbo].[payments] as py 
          on oi.order_id = py.order_id
     Group By  P.Product_Category_Name 
     Order By  Total_Payment desc ;    
-
<img width="1820" height="873" alt="Screenshot (274)" src="https://github.com/user-attachments/assets/47db5bc7-9669-429d-8986-c5f49c28a48a" />


-
-
-
GO

Business Question

- Which cities generated more than 300,000 in total revenue?**

Objective:

- Identify the top-performing cities by revenue to support regional sales strategy and market prioritization.

**SQL Concepts Used: `SUM()`, ``, `INNER JOIN`, `GROUP BY`, `HAVING`, `ORDER BY`.


    Select
             c.[customer_city] As City
            ,cast(sum(p.[payment_value])as int) As Total_Revenue

    From [Retail dataset].[dbo].[customers] As c
            inner join [Retail dataset].[dbo].[orders] As o
               on c.[customer_id] = o.[customer_id]
            inner join [Retail dataset].[dbo].[order_items] As oi
               on o.[order_id] = oi.[order_id]
            inner join [Retail dataset].[dbo].[payments] As p
               on oi.[order_id] = p.[order_id]
    Group By c.[customer_city]
    Having   sum(p.[payment_value]) > 300000
    Order By Total_Revenue desc;

-

<img width="1604" height="887" alt="Screenshot (282)" src="https://github.com/user-attachments/assets/96bfc9c4-e37a-482e-ad93-4eb6026d1563" />







   



Select 
      

[Retail Database.sql](https://github.com/user-attachments/files/32296399/Retail.Database.sql)
