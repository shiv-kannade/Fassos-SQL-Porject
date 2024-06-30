CREATE DATABASE FAASO ;
USE FAASO ;

CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');


CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');


CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),
duration VARCHAR(10),cancellation VARCHAR(23));

INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2020 21:30:45','25km','25mins',null),
(8,2,'01-10-2020 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2020 18:50:20','10km','10minutes',null);


CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),
extra_items_included VARCHAR(4),order_date datetime);

INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');



select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


---1) HOW MANY ROLL'S ARE OORDER ?

SELECT COUNT(ORDER_ID) AS TOTAL_ORDERS FROM customer_orders ;



----2) HOW MANY UNIQUE CUSTOMER ORDER ?

SELECT COUNT(DISTINCT(CUSTOMER_ID)) AS TOTAL_UNIQUE_CUST FROM CUSTOMER_ORDERS ;



---3) HOW MANY SUCCESFULL ORDERS DELIVERD BY EACH DRIVER ; 

SELECT  DRIVER_ID , COUNT(ORDER_ID) AS TOTAL_ORDERS  FROM driver_order 
WHERE cancellation  NOT IN ('CANCELLATION' , 'CUSTMOER CANCELLATION')
GROUP BY DRIVER_ID 
ORDER BY COUNT(ORDER_ID) DESC ;




---4) HOW MANY EACH TYPE OF ROLLS DELIVERED 


select roll_id , count(roll_id) as total_rolls from customer_orders where order_id in(
select order_id from
(SELECT * , CASE WHEN cancellation IN('cancellation' , 'CUSTOMER cancellation') THEN 'C' ELSE 'NC' END AS CANCEL FROM DRIVER_ORDER)a
where cancel ='nc')
group by roll_id;


----5) how many veg & non veg rolls order by each customer 

select a.* , b.roll_name from (
select customer_id , roll_id , count(roll_id) as total_rolls 
from customer_orders
group by customer_id , roll_id)a inner join rolls b
on a.roll_id = b.roll_id ;

 

 ---6) what is the maximum number of rolls deliverd in single order 

 select top 1 order_id , count(roll_id) as total_roll
 from customer_orders
 where order_id in (select order_id from driver_order where cancellation not in ('cancellation','customer cancellation'))
 group by order_id 
 order by count(roll_id) desc ;


 ---7) for each customer how many deliered rolls had at least 1 change and how many had no change 

 with customer_orders_2(order_id ,customer_id ,roll_id ,not_include_items ,extra_items_included ,order_date) as 
( select order_id , customer_id , roll_id , case when not_include_items is null or not_include_items =' '   then  'no change' else  'change' end  ,
case when extra_items_included is null or extra_items_included =' ' or extra_items_included = 'NaN'   then  'no change' else  'change' end  , order_date
from customer_orders ) 
select customer_id , count(customer_id) as total_orders , case when ((not_include_items ='change' and extra_items_included ='change') and (not_include_items ='change' and extra_items_included ='no change') and (not_include_items ='no change' and extra_items_included ='change')) then 'change' else 'no change' end as change_status from customer_orders_2 
where order_id in(select order_id from driver_order where cancellation not in ('cancellation','customer cancellation'))
group by customer_id , not_include_items, extra_items_included ;

                            


---8) how many rolls were delivered that has both exclusions & extras 


---9) what was the total number of rolls order for each hour of the day 

select  concat(cast(DATEPART(hour , order_date ) as varchar) ,'-', cast(DATEPART(hour , order_date )+1 as varchar)) as time_duration, count(order_id) as total_rolls 
from customer_orders
group by DATEPART(hour , order_date ) ;


---10) what was the number of orders by each day of the week 

select  DATENAME(dw , order_date)  as dow  , count(distinct(order_id))as total_orders 
from customer_orders
group by DATENAME(dw , order_date) ; 


select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;

----11) what was the average time in minutes it took for each driver to arrive at the hade quater to pickup the order
----HERE INPUT VALUES CHANGES SO SHOWING LARGE VALUE BUT LOGIC IS CORRECT


select * ,  from
(select customer_orders.order_id,customer_id,roll_id ,order_date,driver_id , pickup_time , distance, duration , cancellation ,
DATEDIFF(MINUTE , order_date , pickup_time) as time_taken_FOR_PICKUP
from customer_orders
inner join driver_order
on customer_orders.order_id = driver_order.order_id
WHERE pickup_time IS NOT NULL ;


--12) IS THERE ANY RELATIONSHIP BETWEEN THE NO OF ROLLS AND HOW LONG THE ORDERS TO PREPARE 
--HERE INPUT VALUES CHANGES SO SHOWING LARGE VALUE BUT LOGIC IS CORRECT

SELECT ORDER_ID , COUNT(ROLL_ID) AS TOLTAL_ROLLS , SUM(time_taken_FOR_PICKUP)/COUNT(ROLL_ID) AS TIMES FROM
(select customer_orders.order_id,customer_id,roll_id ,order_date,driver_id , pickup_time , distance, duration , cancellation ,
DATEDIFF(MINUTE , order_date , pickup_time) as time_taken_FOR_PICKUP
from customer_orders
inner join driver_order
on customer_orders.order_id = driver_order.order_id
WHERE pickup_time IS NOT NULL) A
GROUP BY ORDER_ID ;

--13) WHAT WAS THE AVERAGE DISTANCE TRAVELLED FOR EACH CUSTOMER 

SELECT CUSTOMER_ID , AVG(NEW_DISTANCE) AS AVG_DISTANCE FROM
(SELECT customer_orders.order_id , CUSTOMER_ID , ROLL_ID , DRIVER_ID , DISTANCE , CAST(REPLACE(DISTANCE , 'KM' ,'') AS float) AS NEW_DISTANCE ,  DURATION 
FROM customer_orders
INNER JOIN driver_order
ON customer_orders.order_id = driver_order.order_id
WHERE distance IS NOT NULL) A
GROUP BY CUSTOMER_ID  ;



---14) WHAT IS THE DIFFERENCE BETWEEN THE LONGEST & SHORTEST DELIVERY TIME FOR ALL ORDERS
 
SELECT MAX(ACTUAL_DURATION) - MIN(ACTUAL_DURATION) AS DIFF FROM 
(SELECT ORDER_ID , DRIVER_ID , DURATION , CAST(LEFT(DURATION , 2) AS INT) AS ACTUAL_DURATION FROM driver_order
WHERE DURATION IS NOT NULL) A ;

----15) WHAT WAS THE AVG SPEED FOR  EACH DRIVER FOR EACH DELIVERY AND DO YOU NOTICE ANY TREND OF THE VALUE 

SELECT ORDER_ID , DRIVER_ID , (ACTUAL_DISTANCE / ACTUAL_DURATION) AS AVG_SPEED FROM 
(SELECT ORDER_ID , DRIVER_ID , 
CAST(REPLACE(DISTANCE , 'KM' ,'') AS float) AS ACTUAL_DISTANCE , CAST(LEFT(DURATION , 2) AS INT) AS ACTUAL_DURATION 
FROM DRIVER_ORDER 
WHERE  DISTANCE IS NOT NULL OR DURATION IS NOT NULL) A ;



----16) WHAT IS THE SUCCESFULL DELIVERY PERCENTAGE FOR EACH DRIVER ?

SELECT DRIVER_ID  ,COUNT(ORDER_ID) AS TOTAL_ORDERS_TAKEN ,SUM(NEW_CANCEL) AS TOTAL_ORDER_DELEVER ,  (CAST(SUM(NEW_CANCEL) AS FLOAT) / CAST(COUNT(ORDER_ID) AS FLOAT))*100  AS  DELIVERY_PERCEN FROM
(SELECT ORDER_ID , DRIVER_ID , 
CASE WHEN CANCELLATION IS NULL OR CANCELLATION ='NAN' OR CANCELLATION = '' THEN 1 ELSE 0 END AS NEW_CANCEL 
FROM driver_order) A 
GROUP BY driver_id ;

















