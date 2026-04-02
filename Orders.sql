SELECT*
FROM `bigquery-public-data.thelook_ecommerce.orders`  limit 1000;

with test as (
SELECT distinct shipped_at ,delivered_at,returned_at
FROM `bigquery-public-data.thelook_ecommerce.orders`  
where status = 'Complete' 
order by 1 desc)
select *
from test 
where shipped_at is null or delivered_at is null or returned_at is null ;

-- Created -> Procecing ( Created_Shipped_time )->   (Shipped_Compeleted_Time(delivary_Time))-> Comeleted -> [Returned]
--         -> Canceled 

select avg(date_diff(shipped_at, created_at, day)) as avg_created_ship_wait
from `bigquery-public-data.thelook_ecommerce.orders`
where status = 'Complete';
-- 1-day

select avg(date_diff(delivered_at, shipped_at, day)) as avg_shipped_deliverd_wait
from `bigquery-public-data.thelook_ecommerce.orders`
where status = 'Complete';
-- 2-day


select avg(date_diff(delivered_at, created_at, day)) as avg_created_deliverd_wait
from `bigquery-public-data.thelook_ecommerce.orders`
where status = 'Complete';
-- 3.5-day

SELECT*
FROM `bigquery-public-data.thelook_ecommerce.orders`  limit 1000;

-- question gonna solved by python (is there a reletion between the gender of the cancelation) 😂😂😂

-- what is the most user has been canceled a orders!! (block mode)
-- what is the most item has been canceled 

-- what is the most user has been canceled a orders!! (block mode)
select users.first_name ,
count(*)
from `bigquery-public-data.thelook_ecommerce.orders` as orders
join `bigquery-public-data.thelook_ecommerce.users`  as users
on orders.user_id =users.id
where status = 'Cancelled'
group by 1
order by 2 desc
limit 5;
-- 1	Michael	449
-- 2	David	321
-- 3	Jennifer	301
-- 4	James	288
-- 5	Christopher	273	

-- what is the most user has been Returned a orders!! (block mode)
select users.first_name ,
count(*)
from `bigquery-public-data.thelook_ecommerce.orders` as orders
join `bigquery-public-data.thelook_ecommerce.users`  as users
on orders.user_id =users.id
where status = 'Returned'
group by 1
order by 2 desc
limit 5;
-- 1	Michael	288
-- 2	David	211
-- 3	Jennifer	210
-- 4	James	185
-- 5	Christopher	178


SELECT distinct num_of_item
FROM `bigquery-public-data.thelook_ecommerce.orders`;

SELECT*
FROM `bigquery-public-data.thelook_ecommerce.orders`  limit 1000;








