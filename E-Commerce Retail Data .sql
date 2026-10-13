
/* Top Performing Products within Each Category */
/* - Which products generate the most revenue within each product category
- How do they compare in order volume, item count,
- Average price and average shipping cost? */

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
 From [Retail dataset].[dbo].[products]             As pr
    inner join [Retail dataset].[dbo].[order_items] As oi
     on   pr.[product_id] = oi.[product_id] 
    inner join[Retail dataset].[dbo].[orders]       As o
     on   oi.[order_id] = o.[order_id]
    inner join [Retail dataset].[dbo].[payments]    AS p
     on   o.[order_id] = p.[order_id] 

Group by oi.[product_id], pr.[product_category_name]
Order by pr.[product_category_name],Proudct_Rank ;




Go

/* Product Category Performance Ranking */
/* Which product categories generate the most revenue, and how do they compare in product variety,
 order volume, items sold, average price, average order value, and shipping cost? */

Select  
      pr.[product_category_name]           As Category
     ,rank() over(
             order by cast(sum(p.payment_value) as int) desc
            ) as category_rank
     ,(count(distinct pr.[product_id]))    As Total_Product
     ,cast(sum(p.payment_value) as int)    As Total_Revenue
     ,count(distinct o.[order_id])         As Total_Orders
     ,count(oi.[order_item_id])             As Total_Item
     ,cast(avg (oi.price)as int)           As AVG_Price
     ,cast (sum (p.payment_value) 
          / count( distinct o.[order_id]) as int)  As AVO 
     ,cast(avg(oi.[shipping_charges])as int)       AS AVG_Shpping_Cost  
FROM [Retail dataset].[dbo].[products]    As pr
    inner join [Retail dataset].[dbo].[order_items] As oi
     on   pr.[product_id] = oi.[product_id] 
    inner join[Retail dataset].[dbo].[orders]  As o
     on   oi.[order_id] = o.[order_id]
    inner join [Retail dataset].[dbo].[payments]  AS p
     on   o.[order_id] = p.[order_id] 
  
Group by pr.[product_category_name]
Order by category_rank Asc;
        

Go

/* Best Selling Products (More Than 50 Order Lines) */
/* - Which products are the most in demand, with more than 50 sold order lines */
/* - How do their total orders compare to total items sold? */

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

Go

/* Shipping Cost: Light vs. Heavy Products */
/* How does the average shipping charge differ between light products (under 1 Kg) and heavy products (over 5 Kg), 
and how many items fall into each group?*/

Select
        count(*)                     AS Total_items
        ,avg(oi.[shipping_charges])  As AVG_shipping_Cost
        ,
        case
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

Go

/* Customer Segmentation: Repeat vs. One Time Customers */
/* 
- How many orders has each customer placed?
- How much revenue does each customer generate?
- Which customers are repeat buyers compared to one time buyers? */

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

Go


/* Customer Segmentation: Repeat vs. One-Time Customers */
/* - How many orders has each customer placed, how much revenue does each customer generate */
/* - Which customers are repeat buyers compared to one time buyers? */
Select 
      Customer_id
     ,ntile(4) over( 
         order by Total_Spending desc) As Segment_Rank 
     ,Total_Orders
     ,Total_Spending 
From ( 
     select 
        o.[customer_id]                AS Customer_id
       ,Sum(p.[payment_value])         As Total_Spending
       ,Count(o.[order_id])             As Total_Orders
     from [Retail dataset].[dbo].[orders] as o
     inner join [Retail dataset].[dbo].[payments] as p
      on o.[order_id] = p.[order_id] 
      
     group by  o.[customer_id]
     ) As Total_Spending         
Order by 
       Segment_Rank, Total_Spending desc;


Go 

/*  Customer Segmentation by Spending Value */
/* - How much has each customer spent in total?
   - Which customers fall into the low, medium, or high value segments? */

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

GO




/* Monthly Sales Trend with Running Total */
/* - What are the total sales for each month, and how do sales accumulate over time (running total)? */

Select 
       Years
      ,Months
      ,Total_Revenue
     ,cast (sum(Total_Revenue) over (
             order by Years, Months ) As int ) As Total_Running  
From (
   Select
        YEAR(o.[order_approved_at])            AS  Years
       ,MONTH(o.[order_approved_at])           AS  Months
       ,cast(sum(p.[Payment_value]) as int)    As Total_Revenue 

   From [Retail dataset].[dbo].[payments]    AS p
    inner join [Retail dataset].[dbo].[orders]       As o
     on    p.[order_id] = o.[order_id]
    inner join [Retail dataset].[dbo].[order_items] As oi
     on   o.[order_id] = oi.[order_id]
   
Group by   YEAR(o.[order_approved_at])
          ,MONTH(o.[order_approved_at])
     ) As Monthly_sales
Order by Total_Running DESC;


Go

/* Sales Performance by Day of the Week */
/* Which days of the week receive the most orders and generate the most revenue? */

Select distinct
      DATENAME(WEEKDAY,[order_approved_at]) week_day
      ,count(o.[order_id])          As Total_Order 
      ,cast(sum(p.[payment_value]) As int)   As Total_Revenue

From [Retail dataset].[dbo].[payments]    AS p
    inner join [Retail dataset].[dbo].[orders]       As o
     on    p.[order_id] = o.[order_id]
    inner join [Retail dataset].[dbo].[order_items] As oi
     on   o.[order_id] = oi.[order_id]
GROUP BY
    DATENAME(WEEKDAY, [order_approved_at])
ORDER BY
    Total_Order DESC;




Go


/* Yearly Sales and Average Order Value */
/* What are the total sales, total number of orders, and average order value (AOV) for each year? */

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



Go


/* Monthly Revenue, Orders, and Average Order Value Report */
/* What are the total revenue, number of orders, and average order value (AOV) for each month? */

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
       Years  Asc, Months ASC;

Go


/* Order Distribution by Hour of the Day */
/* At which hours of the day do customers place the most orders? */ 

Select 
     DATEPART
      (hour,[order_purchase_timestamp])  As order_hours
     ,count(*)                           As Total_Orders
From  [Retail dataset].[dbo].[orders]

Group By  DATEPART
            (hour,[order_purchase_timestamp])
Order By Order_Hours asc;

Go




/* Cities Exceeding 300,000 in Revenue, with Orders and Sellers */
/* - Which cities generated more than 300,000 in total revenue?
   - How many orders and distinct sellers contributed to that revenue? */

WITH
order_payment AS
(
    Select order_id, SUM(payment_value) AS order_value
    From [Retail dataset].[dbo].[payments]
    Group By order_id
), order_sellers AS (
    Select DISTINCT order_id, seller_id
    From [Retail dataset].[dbo].[order_items]
)
Select
      c.customer_city AS City,
      CAST(SUM(op.order_value) AS DECIMAL(12,2)) AS Total_Revenue,
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





Go

/* Top 10 States by Revenue and Customers */
/* Which are the top 10 states by total revenue, and how many customers does each state have? */

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



/* Delivery Performance: Early, On Time, Late, and Not Delivered */
/* - What percentage of orders were delivered early, on time, 
      or late compared to the estimated delivery date 
   - How many orders were never delivered? */

Select 
      Delivery_Status
     ,Count(*)        AS Total_Orders
     ,Cast(Cast(Count(*) * 100.0 / Sum(Count(*)) 
        Over () As Decimal(5,2)) AS Varchar(10)) + '%' As Percentage
From ( 
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
     
Go

/* Shipping Cost Analysis by State */
/* What are the highest, lowest, and average shipping charges for each customer state? */

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

Go


/*  Order Delivery Rate */
/* What percentage of all orders were successfully delivered? */

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

Go

/* Shipping Cost per Gram and per Cubic Centimeter */
/* - How much does shipping cost per gram and per cubic centimeter for each product
   - How do weight and volume relate to the shipping charge? */ 

Select
    p.[product_id]
   ,oi.[shipping_charges]
   ,p.[product_weight_g]
   ,[shipping_charges]/NULLIF(product_weight_g,0) 
      AS shipping_price_per_gram
   
   ,p.[product_height_cm] * p.[product_length_cm]
      * p.[product_width_cm]  As Volum_CM3
   
   ,[shipping_charges]/NULLIF(
    p.[product_height_cm] * p.[product_length_cm]
      * p.[product_width_cm]   
        ,0) AS shipping_price_per_CM3
From [Retail dataset].[dbo].[order_items] AS oi
Inner Join [Retail dataset].[dbo].[products] AS p
    ON oi.product_id = p.product_id;

Go

/* Seller Performance Ranking by Revenue */
/* - Which sellers generate the most revenue */
/* - How do they compare in order volume, average order value, and average item price? */

Select
    seller_id,
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

Go

/* Orders with Price Above Twice the Product Average */
/* Which order items were sold at a price more than double the average price of the same product? */

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