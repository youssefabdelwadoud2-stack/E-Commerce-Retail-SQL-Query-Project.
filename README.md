# Retail-SQL-Query-Project-
E-Commerce Retail SQL Query Project For Translate Business Questions Into Raw Data And Extract It From SQL Server Management.



/*what is total order to every status*/


SELECT   
           [order_status]
    ,count([order_status]) total_order_status
     
FROM [Retail dataset].[dbo].[orders]
group by [order_status]
order by total_order_status desc;

go 


/* what is total sales to every seller */

SELECT 
       distinct [seller_id]
      ,cast(sum([price]) as int) total_sales
      
FROM [Retail dataset].[dbo].[order_items]
group by [seller_id]
order by total_sales desc;

Go 

/* the total sales and avg price to every category */

select 
       cast(avg(oi.price)as int) as avg_price 
      ,cast(sum(p.payment_value)as int) as total_payment

FROM [Retail dataset].[dbo].[order_items]  oi
left join [Retail dataset].[dbo].[payments]  p 
          on oi.order_id = p.order_id;    

Go

/* which city had over 100,000 sales */

select
       c.[customer_city] city_name
      ,cast(sum(oi.[price])as int) total_sales

FROM [Retail dataset].[dbo].[order_items] as oi
 
 inner join [Retail dataset].[dbo].[orders] as o
 on oi.[order_id] = o.[order_id]
 
 inner join [Retail dataset].[dbo].[customers] as c
  on o.[customer_id] = c.[customer_id]

group by c.[customer_city]
having sum(oi.[price]) > 100000
order by total_sales desc;

Go

/* Measure AVG Average Order Value (AVO) */

SELECT
    cast(AVG(order_total) as int) AS AOV
FROM
(
    SELECT
        order_id,
        SUM(price) AS order_total
    FROM [Retail dataset].[dbo].[order_items]
    GROUP BY order_id
) AS order_totals;

GO 
/* measure total sales to every city had over 100,000 $ */

select 
    c.[customer_city] 
   ,sum(oi.[price]) total_salary

FROM [Retail dataset].[dbo].[customers] c

join [Retail dataset].[dbo].[orders] o
on c.[customer_id] = o.[customer_id]

join [Retail dataset].[dbo].[order_items] oi
on o.[order_id] = oi.[order_id]

group by c.[customer_city] 
having sum(oi.[price]) > 100000
order by total_salary desc;


/* what is the total num proudct, and sales
to every category */

select distinct 
      p.[product_category_name]
     ,count (p.[product_id]) num_of_prouduct
     ,sum(oi.[price]) total_sales
FROM [Retail dataset].[dbo].[products] p

join [Retail dataset].[dbo].[order_items] oi
on p.[product_id] = oi.[product_id] 

group by p.[product_category_name]
order by num_of_prouduct desc
        ,total_sales desc;

Go

/* sales team want to know total num of proudct to every month */

select 
       month([order_purchase_timestamp]) order_month
      ,year([order_purchase_timestamp]) order_year
      ,count([order_id])
FROM [Retail dataset].[dbo].[orders]
group by month([order_purchase_timestamp])
        ,year([order_purchase_timestamp])
order by order_month desc
        ,order_year desc;

Go

/* how the price affect on the shipping price */

select 
       p.[product_id]
      ,p.[product_category_name]
      ,p.[product_weight_g]
      ,oi.[shipping_charges]

FROM [Retail dataset].[dbo].[products] p
inner join [Retail dataset].[dbo].[order_items] oi
on p.[product_id] = oi.[product_id]
;

Go

/* Discribe the status of orders about time (on time or late)
   and the total num of every status */

WITH delivery_data AS
(
select 
       [order_id] 
      ,[order_delivered_timestamp]
      ,[order_estimated_delivery_date]
 ,
    case 
      when [order_delivered_timestamp] < 
              [order_estimated_delivery_date] then 'Early'
      when [order_delivered_timestamp] = 
              [order_estimated_delivery_date] then 'on_time'
      when [order_delivered_timestamp] > 
              [order_estimated_delivery_date] then 'late'
     else 'Not_deleverd'
     end as delivery_status

FROM [Retail dataset].[dbo].[orders]
)
SELECT
    order_id,
    order_delivered_timestamp,
    order_estimated_delivery_date,
    delivery_status,
 count (*) over (
              partition by delivery_status)
              as Total_status 
 from delivery_data;

Go

/* Discribe the status of orders about time (on time or late)
   and the total num of every status on single Row */



 WITH delivery_data AS
(
    SELECT
        order_id,
        order_delivered_timestamp,
        order_estimated_delivery_date,
        CASE
            WHEN order_delivered_timestamp IS NULL
                THEN 'Not Delivered'
            WHEN order_delivered_timestamp < 
                   order_estimated_delivery_date THEN 'Early'
            WHEN order_delivered_timestamp = 
                   order_estimated_delivery_date THEN 'On Time'
            WHEN order_delivered_timestamp >
                   order_estimated_delivery_date THEN 'Late'
        END AS delivery_status
    FROM [Retail dataset].[dbo].[orders]
)

SELECT
    order_id,
    order_delivered_timestamp,
    order_estimated_delivery_date,
    delivery_status,
    COUNT(CASE
        WHEN delivery_status = 'Late' THEN 1
    END) OVER () AS total_late,
    COUNT(CASE
        WHEN delivery_status = 'On Time' THEN 1
    END) OVER () AS total_on_time,
    COUNT(CASE
        WHEN delivery_status = 'Early' THEN 1
    END) OVER () AS total_early,
    COUNT(CASE
        WHEN delivery_status = 'Not Delivered' THEN 1
    END) OVER () AS total_not_delivered

FROM delivery_data;

Go

/* What is the shipping Price to every KG */ 

SELECT
    p.[product_id]
   ,p.[product_weight_g]
   ,oi.[price]
   ,
   price / NULLIF(product_weight_g,0) AS price_per_gram

FROM [Retail dataset].[dbo].[order_items] AS oi
INNER JOIN [Retail dataset].[dbo].[products] AS p
    ON oi.product_id = p.product_id;

GO

/* How much time our orders takes to deliverd */

SELECT
    order_id,
    order_approved_at,
    order_delivered_timestamp,
    DATEDIFF
     (day, 
      order_approved_at,
     order_delivered_timestamp
     ) AS delivery_days
     
FROM [Retail dataset].[dbo].[orders]
WHERE [order_approved_at] IS NOT NULL
order by delivery_days desc;
 /* there are orderes takes over 7 month to deliver ???!!! */

Go 


/* what is the best day of sales */

select distinct
       count([order_id]) total_order 
      ,DATENAME(WEEKDAY,[order_approved_at]) week_day

FROM [Retail dataset].[dbo].[orders]
GROUP BY
    DATENAME(WEEKDAY, [order_approved_at])

ORDER BY
    total_order DESC;


Go

/* How Many Orders didn't Approved */

Select 
       count
        (case 
          when  order_approved_at IS NULL
            THEN 1
          end
        ) * 100.0 / count(order_id) AS pending_approval_percentage

from [Retail dataset].[dbo].[orders];


Go

/* Arrange sillers as thier total_sales */

SELECT
    seller_id,
    total_sales
   ,ROW_NUMBER() OVER (
        ORDER BY total_sales DESC
    ) AS seller_rank
FROM
(
    SELECT
        seller_id,
        SUM(price) AS total_sales
    FROM [Retail dataset].[dbo].[order_items]
    GROUP BY seller_id
) AS seller_sales
ORDER BY seller_rank DESC;
 
 
Go

/* Arrange category as thier total_sales */

Select 
      [product_category_name]
     ,total_sales 
     ,rank() over(
             order by total_sales desc
            )as category_rank
from      
(
select  
       [product_category_name]     
     ,sum(price) total_sales

FROM [Retail dataset].[dbo].[order_items] AS oi
    INNER JOIN [Retail dataset].[dbo].[products] AS p
        ON oi.product_id = p.product_id

GROUP BY [product_category_name]
) AS category_sales
ORDER BY category_rank;


Go

/* Give me a distinct arrangement by sales to every proudct 
     by catogory  */

select 
       oi.[product_id]
      ,sum (oi.[price]) total_sales
      ,p.[product_category_name]   
      ,DENSE_RANK() over (
                  partition by p.[product_category_name]
                  order by sum (oi.[price]) desc
                  ) Proudct_Rank

FROM [Retail dataset].[dbo].[order_items] as oi
join [Retail dataset].[dbo].[products] as p
 on oi.[product_id] = p.[product_id]

group by oi.[product_id]
         ,p.[product_category_name]
order by p.[product_category_name]
        ,Proudct_Rank;

Go

/* we want a compare with last two purches date
to every customer */

select 
      [customer_id]
     ,[order_id]
     ,[order_estimated_delivery_date]
     ,lag([order_estimated_delivery_date]) 
               over ( partition by [customer_id]
               order by [order_estimated_delivery_date] 
               ) as perivious_order_date

from [Retail dataset].[dbo].[orders]

order by [customer_id]
        ,[order_estimated_delivery_date];

Go

/* messure the Runing over */

select 
       order_year
      ,order_month
      ,total_sales

    ,sum(total_sales) over(
             order by order_year, order_month
                  ) as total_running  
from
(
   select
        YEAR(o.[order_approved_at]) AS order_year,
        MONTH(o.[order_approved_at]) AS order_month
      ,sum(oi.[price]) total_sales

   FROM [Retail dataset].[dbo].[orders] as o
  join [Retail dataset].[dbo].[order_items] as oi
  on o.order_id = oi.order_id

group by   YEAR(o.[order_approved_at])
          ,MONTH(o.[order_approved_at])
 ) as Monthly_sales
 order by  order_year,
          order_month;

Go

/* who is the best customer from sales */

select Top 1
      [customer_id]
     ,count([order_id]) total_order 

FROM [Retail dataset].[dbo].[orders]
group by [customer_id]
order by total_order desc;

Go

/* which seller atchive over AVG sales */

select
    seller_id,
    SUM(price) AS total_sales
from [Retail dataset].[dbo].[order_items]
group by
    seller_id
having 
   SUM(price) >
(      
       select 
            AVG(total_sales) as avg_sales
     from
(
      select
             seller_id,
             SUM(price) AS total_sales
      from[Retail dataset].[dbo].[order_items]
      group by  seller_id 
)                    as seller_sales
)
order by total_sales desc;

Go

/* give me total orders to every customer */

select 
      [customer_id]
     ,total_orders
   ,case 
      when total_orders > 1  then 'Repeat Customer'
      else 'One Time Customer'
    end as customer_Type
from 
(
     select
           [customer_id]
          ,count([order_id]) as total_orders
     FROM [Retail dataset].[dbo].[orders]
     group by [customer_id]
)    as customer_orders;

Go

/* what is best 3 product on every category by revenue */

select
       [product_id]
      ,[product_category_name]
      ,total_revenue 
      ,product_rank
from 
(
     select
        [product_id]
       ,[product_category_name]
       ,total_revenue 
       ,rank () over(
            partition by [product_category_name]
            order by total_revenue desc
          ) as product_rank 
 from 
 ( 
     select
        pr.[product_id]
       ,pr.[product_category_name]
       ,sum([payment_value]) as total_revenue 
     from [Retail dataset].[dbo].[payments] as p
 inner join [Retail dataset].[dbo].[order_items] as oi
   on p.[order_id] = oi.[order_id]
 inner join [Retail dataset].[dbo].[products] as pr
   on oi.[product_id] = pr.[product_id]

   group by 
         pr.[product_id]
        ,pr.[product_category_name]
   ) as product_sales
) as product_rank
where product_rank <= 3
order by 
   [product_category_name]
  ,product_rank;


Go

/* who sellers achieves over the AVG category sales */

select 
      [seller_id]
     ,primary_category
     ,total_sales
     ,AVG_category_sales
from 
(
     select
         [seller_id]
        ,primary_category
        ,total_sales  
        ,avg(total_sales) over(
           partition by primary_category
           ) as AVG_category_sales
     from
     (
        select
         [seller_id]
        ,[product_category_name] as primary_category
        ,sum([payment_value]) as total_sales        
        ,row_number() over(
          partition by [seller_id]
          order by sum([payment_value]) desc
          ) as category_rank 
    from [Retail dataset].[dbo].[products] as p
   join  [Retail dataset].[dbo].[order_items] as oi 
        on p.[product_id] = oi.[product_id]
   join [Retail dataset].[dbo].[payments] as pa
        on oi.[order_id] = pa.[order_id] 
     group by 
        [seller_id]
       ,[product_category_name]
     ) as seller_category
   where category_rank = 1

) as final_data
where total_sales > AVG_category_sales
order by 
  primary_category
 ,total_sales desc;

Go


/* How can we segment customers into four equal groups 
      based on their total spending? */
select 
      [customer_id]
     ,total_spending
     ,ntile(4) over( 
         order by total_spending desc  ) as quartile 
from
(    select 
        o.[customer_id]
       ,sum(p.[payment_value]) as total_spending
     from [Retail dataset].[dbo].[orders] as o
     inner join [Retail dataset].[dbo].[payments] as p
      on o.[order_id] = p.[order_id] 
      
     group by 
         o.[customer_id]
) as total_spending          
order by 
        quartile ,total_spending desc;


Go 

/* Which orders had more than dobel price of the same product */

select 
       [order_id]
      ,[product_id]
      ,[price]
      ,avg_product_price
from 
(    select
       [order_id]
      ,[product_id]
      ,[price]
      ,avg(price) over(
           partition by ([product_id])
             ) as avg_product_price
    from [Retail dataset].[dbo].[order_items]
  )  as product_price
where price > avg_product_price * 2
order by price desc;


Go


/* Makr classes to customer about customer life value (CLV) */

select 
      [customer_id]
     ,total_spending
    ,case
       when total_spending < 500 then 'low_value'
       when total_spending < 1500 then 'medium_value'
       else 'high_value'
     end as customer_segment
from
(    select 
           o.[customer_id]
          ,sum(p.[payment_value]) total_spending
     from [Retail dataset].[dbo].[orders] as o
     inner join [Retail dataset].[dbo].[payments] as p
     on o.order_id = p.order_id

     group by [customer_id]
) as customer_spending
order by total_spending desc;

GO

/* what is total sales last two years */

select
      sum(p.[payment_value]) Total_sales
     ,year(o.[order_estimated_delivery_date]) years

from [Retail dataset].[dbo].[payments] as p
inner join [Retail dataset].[dbo].[orders] as o
on p.order_id = o.order_id

where [order_estimated_delivery_date] >= dateadd ( year,-2
                    ,(select max([order_estimated_delivery_date])
                      from [Retail dataset].[dbo].[orders])
                      )
group by year(o.[order_estimated_delivery_date])
order by years;


go

/* who is the top 20 customer by spending */

select top 20
       c.[customer_id]
      ,sum(p.[payment_value]) total_spending

from [Retail dataset].[dbo].[customers] as c 
    inner join [Retail dataset].[dbo].[orders] as o
    on   c.customer_id = o.customer_id
    inner join [Retail dataset].[dbo].[payments] as p
    on o.order_id = p.order_id
group by c.[customer_id]
order by total_spending desc;

go
 

/* which category most profit */


select top 7
       pr.[product_category_name]
      ,sum(p.[payment_value]) total_revenue

from [Retail dataset].[dbo].[payments] as p 
    inner join [Retail dataset].[dbo].[orders] as o
    on p.order_id = o.order_id
    inner join [Retail dataset].[dbo].[order_items] oi
    on o.order_id = oi.order_id
    inner join [Retail dataset].[dbo].[products] as pr
    on oi.product_id = pr.product_id
group by pr.[product_category_name]
order by  total_revenue desc;


Go 

/* give a KPIS to every seller */

select 
      oi.[seller_id]
     ,count(o.[order_id]) total_order 
     ,sum(p.[payment_value]) revenue
     ,avg(oi.[price]) avg_item_price

from [Retail dataset].[dbo].[payments]  as p
     inner join [Retail dataset].[dbo].[orders] as o
     on p.order_id = o.order_id
     inner join [Retail dataset].[dbo].[order_items] as oi
     on o.order_id = oi.order_id
group by oi.[seller_id]
order by total_order desc
        ,revenue 
        ,avg_item_price;


Go

/* we need a report about shpping cost to every state */

select 
       c.[customer_state]
      ,max(oi.[shipping_charges])  max_shpping
      ,min(oi.[shipping_charges])  low_shpping
      ,avg(oi.[shipping_charges])  avg_shpping

from [Retail dataset].[dbo].[customers] as c 
     inner join [Retail dataset].[dbo].[orders] as o
     on c.customer_id = o.customer_id
     inner join [Retail dataset].[dbo].[order_items] as oi
     on o.order_id = oi.order_id

group by c.[customer_state]
order by max_shpping 
        ,low_shpping
        ,avg_shpping;

Go

/* How effictive we delivered our orders (the percentage %)  */


SELECT
    count(*) as total_orders
    ,
    count(
        case
            when [order_status] = 'delivered'
            then 1
        end ) as delivered_orders
        ,
  ROUND(
    count(
        case
            when [order_status] = 'delivered'
            then 1
        end
        ) * 100.0 / nullif(count(*),0),
        2
        ) as delivary_rate 
FROM [Retail dataset].[dbo].[orders];

Go

/* which 10 states is the best about customer number and revenue */

select top 10
      c.[customer_state]
     ,sum(p.[payment_value] )as revenue 
     ,count( c.[customer_id]) as total_customer
from [Retail dataset].[dbo].[customers] as c
   inner join [Retail dataset].[dbo].[orders] as o
   on c.[customer_id] = o.[customer_id]
   inner join [Retail dataset].[dbo].[payments] as p
   on o.[order_id] = p.[order_id]

group by [customer_state] 
order by revenue desc
        ,total_customer desc;

Go





/* which product had over 50 reorder */

select distinct
     p.[product_id]
     ,count (oi.[order_id]) total_orderd
from [Retail dataset].[dbo].[products] as p
   inner join [Retail dataset].[dbo].[order_items] as oi
   on p.[product_id] = oi.[product_id]
group by p.[product_id]
having count(oi.[order_id]) < 5
order by total_orderd desc;

Go




/* comper bettwen product weight less than 1kg and more than 5kg
    by price */

select
        count(*) total_item
       ,avg(oi.[shipping_charges]) avg_shipping
      ,
      case
          when p.[product_weight_g] < 1000 then 'light_weight' 
          when p.[product_weight_g] > 5000 then 'havy_weight'
       end as product_weight
       
from [Retail dataset].[dbo].[order_items] as oi
    inner join [Retail dataset].[dbo].[products] as p
    on oi.product_id = p.product_id

where p.[product_weight_g] < 1000  
   or p.[product_weight_g] > 5000

group by  case
          when p.[product_weight_g] < 1000 then 'light_weight' 
          when p.[product_weight_g] > 5000 then 'havy_weight'
       end 
order by avg_shipping desc;

Go






/* how our ordered increse over months */

select
      count (*) total_orders
     ,year([order_approved_at]) years
     ,month([order_approved_at]) months

from [Retail dataset].[dbo].[orders]
group by year([order_approved_at]) 
        ,month([order_approved_at]) 
order by years
        ,months;

Go






/* we want a report about revenue, orders, and AVO to every month */

select
      month([order_estimated_delivery_date]) months
     ,year([order_estimated_delivery_date]) years 
     ,sum(p.[payment_value])        Revenue
     ,count(distinct (o.[order_id]))     total_orders
     ,Round
       (
       sum(p.[payment_value]) / nullif(count(distinct o.[order_id]),0),2
       ) as  AVO
     

FROM [Retail dataset].[dbo].[orders] AS o
    inner join [Retail dataset].[dbo].[payments] AS p
    on o.order_id = p.order_id

group by 
       month([order_estimated_delivery_date]) 
      ,year([order_estimated_delivery_date])  
     
order by 
       years asc
      ,months;

Go





/* customer life value (CLV) to every customer */

select
     c.[customer_id]   customers
     ,sum(p.[payment_value])  CLV

from [Retail dataset].[dbo].[customers] as c
   inner join [Retail dataset].[dbo].[orders] as o
   on c.customer_id = o.customer_id
   inner join [Retail dataset].[dbo].[payments] as p
   on o.order_id = p.order_id

group by 
        c.[customer_id]
order by 
        CLV desc;

     
Go





/* which hour has the most rush during the day */ 

select 
     DATEPART
            (hour,[order_purchase_timestamp])
            as order_hours
            , count(*) as total_orders
from  [Retail dataset].[dbo].[orders]

group by  DATEPART
            (hour,[order_purchase_timestamp])
order by total_orders desc;


Go





/* which category have shpping price over 20% of price */

select
       p.[product_category_name]
      ,avg(oi.[price])  avg_price
      ,avg(oi.[shipping_charges])  avg_shipping
      , round(
              avg(oi.[price]) * 100
              /nullif(avg(oi.[shipping_charges]),0),
              1) as shipping_percentage

from [Retail dataset].[dbo].[order_items] as oi
    inner join [Retail dataset].[dbo].[products] as p
    on oi.product_id = p.product_id

group by 
       p.[product_category_name]
having 
       avg(oi.[shipping_charges]) * 100
       /nullif(avg(oi.[price]),0) > 20
order by shipping_percentage desc;


GO 





/* Compear bettwen the time order to approve 
         and the time approve to delivary */

select 
     avg(
       DATEDIFF(
         HOUR,[order_approved_at],[order_purchase_timestamp]))
       as time_to_approve 
     ,avg(
       DATEDIFF(
         HOUR,[order_estimated_delivery_date],[order_approved_at]))
       as time_to_delivery

from [Retail dataset].[dbo].[orders];


Go


/* which state has the fastest shipping */

select
       c.[customer_state]
      ,COUNT(O.order_id) total_order
      ,avg(
          datediff(day,o.[order_purchase_timestamp],
              o.[order_delivered_timestamp])
            ) as avg_shipping_day

from  [Retail dataset].[dbo].[customers] as c
   inner join [Retail dataset].[dbo].[orders] as o
   on c.customer_id = o.customer_id

where  o.[order_delivered_timestamp] is not null
group by c.[customer_state]
order by avg_shipping_day desc;

Go

/* measure the number of new customer every month */

select 
       format([order_purchase_timestamp], 'yyy_mm') as acquisition_month
       , count(*) as new_customer_count
from (      
     select
         [customer_id]
        ,[order_id]
        ,[order_purchase_timestamp]
        , row_number()
             over (partition by [customer_id]
                  order by [order_purchase_timestamp] asc)
                  as order_rank
     from [Retail dataset].[dbo].[orders]
     ) as ranked_orders 
where order_rank = 1
group by format([order_purchase_timestamp], 'yyy_mm')
order by acquisition_month;


Go


/* what is the percentage of every category */

select
     [product_category_name]
    ,count(*) total_item
    ,round(
         count(*) * 100.0
         / sum(count(*)) over() , 2 
         ) as category_shere_percentage

from [Retail dataset].[dbo].[order_items] as oi
  inner join [Retail dataset].[dbo].[products] as p
  on oi.product_id = p.product_id

group by 
      [product_category_name]
order by 
      category_shere_percentage desc;


/* which state had high reorder purchase */

select 
     c.[customer_state]
    ,count(o.[order_id]) * 1.0
       / count(distinct o.[customer_id])
        as avg_order_per_customer

from [Retail dataset].[dbo].[orders] as o
  inner join [Retail dataset].[dbo].[customers] as c
    on o.customer_id = c.customer_id

group by 
        c.[customer_state]
order by 
        avg_order_per_customer desc;

/* customer churn last 6 month */

Go

select 
     c.[customer_id]
    ,max(o.[order_purchase_timestamp]) as last_order_date

from [Retail dataset].[dbo].[orders] as o
  inner join [Retail dataset].[dbo].[customers] as c
  on o.[customer_id] = c.[customer_id]

group by 
      c.[customer_id]
having
    MAX(o.[order_purchase_timestamp]) < 
    DATEADD(month,-6,(
       select MAX([order_purchase_timestamp])
       from [Retail dataset].[dbo].[orders]
       ) )
order by
     last_order_date desc;


Go


/* Which Category Had Low Reorder */

Select
      [product_category_name]
     ,total_order
     ,Rank() over(
         partition by [product_category_name]
         order by total_order desc
         ) as reorder_number
from 
 (
    select 
        p.product_category_name
       ,count([order_id]) total_order
       from [Retail dataset].[dbo].[products] as p
       inner join [Retail dataset].[dbo].[order_items] as oi
        on p.product_id = oi.product_id
        Group by 
           p.product_category_name
  ) as x
        order by total_order asc;




Select 
      

[Retail Database.sql](https://github.com/user-attachments/files/32296399/Retail.Database.sql)
