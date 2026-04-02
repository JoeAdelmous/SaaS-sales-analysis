-- business_overview:
------------------------------------------- (INVENTORY_FACT TABLE) -------------------------------
select inv.name as Inventory,
count(items.id) as No_items,
count(distinct(items.product_id)) as Total_Product,
round(sum(items.product_retail_price),2) as Revenue, 
round(avg(items.product_retail_price),2) as Avg_Revenue,
round(sum(items.cost),2) as Cost, 
round(avg(items.cost),2) as Avg_Cost,
round(sum(items.product_retail_price)-sum(items.cost),2) as Profit
from `bigquery-public-data.thelook_ecommerce.distribution_centers` as inv
join `bigquery-public-data.thelook_ecommerce.inventory_items` as items
  on inv.id = items.product_distribution_center_id
group by inv.name
order by No_items desc;
-- fct_table

------------------------------------------- (EVENTS RATES (MARKETING SECTION)) -------------------

-- what is the top year in events?
SELECT  extract(year from created_at) as year , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
group by  extract(year from created_at)
order by 2 desc
-- 2025 ->	567692

-- what is the top 2 months in each year -- no dublicated 
with year_month as (
SELECT   extract(year from created_at) as year , extract(month from created_at) as month , count(*) as  total_events
FROM `bigquery-public-data.thelook_ecommerce.events`
group by extract(year from created_at) , extract(month from created_at)
order by 3 desc)
, ranked as (
select *, row_number() over(partition by year_month.year order by year_month.total_events desc) as rank
from year_month
order by total_events desc
)

select * except(rank) from ranked 
where ranked.rank <= 2
-- 2026/3	-> 123728

-- which the top 2 browsers has events (purchase)
SELECT browser , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by browser 
order by 2 desc limit 2
-- Chrome	91281
-- Firefox	36312

-- top two sources for each browser (purchse)
with ranked as (
select browser , traffic_source , count(*),
row_number() over ( partition by browser order by count(*) desc) as rank
from `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by browser , traffic_source
order by 3 desc
)
select *  except(rank) from ranked 
where rank <= 2
-- Chrome	Email	40875
-- Safari	Email	16455

-- coverstion rate? (cart -> purchase) *win rate --overall--
select 
round(sum( case when event_type = 'purchase' then 1 else 0 end ) *100.0/
sum( case when event_type = 'cart' then 1 else 0 end ) ,2)as CR
from `bigquery-public-data.thelook_ecommerce.events`
-- 30.6 - 0.306

-- coverstion rate? (cart -> purchase) *win rate --each_year--
select extract(year from created_at) as year ,
round(sum( case when event_type = 'purchase' then 1 else 0 end ) *100.0/
sum( case when event_type = 'cart' then 1 else 0 end ) ,2)as CR
from `bigquery-public-data.thelook_ecommerce.events`
group by extract(year from created_at)
order by 2 desc
-- 1  2026	46.64 -- excellent rate
-- 2	2025	40.06
-- 3	2024	34.46
-- 4	2023	29.9

-- coverstion rate? (cart -> cancel) *churn rate --overall--
select 
round(sum( case when event_type = 'cancel' then 1 else 0 end ) *100.0/
sum( case when event_type = 'cart' then 1 else 0 end ) ,2)as CR
from `bigquery-public-data.thelook_ecommerce.events`
-- 20.95

-- coverstion rate? (cart -> cancel) *churn rate --each_year--
select extract(year from created_at) as year ,
round(sum( case when event_type = 'cancel' then 1 else 0 end ) *100.0/
sum( case when event_type = 'cart' then 1 else 0 end ) ,2)as CR
from `bigquery-public-data.thelook_ecommerce.events`
group by extract(year from created_at)
order by 2 desc
-- 1	2019	45.00 worst year
-- 2	2020	37.96
-- 3	2021	31.96
-- 4	2022	25.97
-- 5	2023	21.31

------------------------------------- YoY change in Win Rate / Churn Rate (Final Thing) ---------------
with Win_Rate as (
select extract(year from created_at) as year ,
round(sum( case when event_type = 'purchase' then 1 else 0 end ) *100.0/
sum( case when event_type = 'cart' then 1 else 0 end ) ,2)as wr
from `bigquery-public-data.thelook_ecommerce.events`
group by extract(year from created_at)
order by year
)
select 
year, round( (wr - lag(wr) over (order by year))*100.0/ coalesce(lag(wr) over (order by year),1),2) as YoY_change_Win_Rate 
from Win_Rate
order by 1 asc

-----
with chrun_r as (
select extract(year from created_at) as year ,
round(sum( case when event_type = 'cancel' then 1 else 0 end ) *100.0/
sum( case when event_type = 'cart' then 1 else 0 end ) ,2)as CR
from `bigquery-public-data.thelook_ecommerce.events`
group by extract(year from created_at)
order by year
)
select 
year, round( (cr - lag(cr) over (order by year))*100.0/ coalesce(lag(cr) over (order by year),1),2) as YoY_change_Win_Rate 
from chrun_r
order by 1 asc

-------------------------------------(PODUCTS&SELL THROUGH RATE)-----------------------------------------


-- which items (products) top 5 sold ?
select prod.name ,count(*) as sold_count
from `bigquery-public-data.thelook_ecommerce.inventory_items` as items
     join `bigquery-public-data.thelook_ecommerce.products` as prod
      on items.product_id = prod.id
where sold_at is not null
group by 1 order by 2 desc
-- 1	Wrangler Men's Premium Performance Cowboy Cut Jean	62
-- 2	Wrangler Men's Rugged Wear Classic Fit Jean	47
-- 3	True Religion Men's Ricky Straight Jean	45
-- 4	HUGO BOSS Men's Long Pant	40
-- 5	Puma Men's Socks	39

-- Sell-through Rate ≈ sold items / total inventory (overall)
select 
count(case when sold_at is not null then 1 end) / count(*) as Sell_through_Rate
from `bigquery-public-data.thelook_ecommerce.inventory_items`;
-- 63%

-- Sell-through Rate ≈ sold items / total inventory (for each inventory)
select inv.name,
round( count(case when sold_at is not null then 1 end)*100.0 / count(*) ,2)as Sell_through_Rate
from `bigquery-public-data.thelook_ecommerce.inventory_items` items
join `bigquery-public-data.thelook_ecommerce.distribution_centers` inv
on items.product_distribution_center_id = inv.id
group by inv.name
order by 2 desc
-- 1	Mobile AL	37.1
-- 2	Los Angeles CA	37.1
-- 3	Savannah GA	37.08
-- 4	Memphis TN	37.06
-- 5	Chicago IL	37.03
-- 6	New Orleans LA	36.97
-- 7	Port Authority of New York/New Jersey NY/NJ	36.96
-- 8	Philadelphia PA	36.93
-- 9	Charleston SC	36.92
-- 10	Houston TX	36.86

-------------------------------------(ORDERS - BLOCK USERS & )-----------------------------------------

-- AVG_DAYS_TO_ORDER
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
 
-- ****** BLOCK MODE *******

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

-- COMMON USERS IN CANCELD AND RETURNED:
WITH CANCELED AS (
select users.first_name ,
count(*)
from `bigquery-public-data.thelook_ecommerce.orders` as orders
join `bigquery-public-data.thelook_ecommerce.users`  as users
on orders.user_id =users.id
where status = 'Cancelled'
group by 1
order by 2 desc
limit 5)
, RETURNED AS (
select users.first_name ,
count(*)
from `bigquery-public-data.thelook_ecommerce.orders` as orders
join `bigquery-public-data.thelook_ecommerce.users`  as users
on orders.user_id =users.id
where status = 'Returned'
group by 1
order by 2 desc
limit 5)

SELECT CANCELED.first_name
FROM CANCELED JOIN RETURNED
 ON CANCELED.first_name = RETURNED.first_name
-- 1	Michael
-- 2	James
-- 3	Jennifer
-- 4	John
-- 5	David
-- THESE COMMON USERS IN RETURNED AND CANCELED SO THERE ARE MAYBE BE IN (BLOCK MODE)

------------------------------------- Sales Analysis ----------------------------------------

-- the top costy product, category, brand:

-- the top costy product
select name ,round(sum(cost),2) as total_cost
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	NIKE WOMEN'S PRO COMPRESSION SPORTS BRA *Outstanding Support and Comfort*	1336.44
-- 2	The North Face Apex Bionic Soft Shell Jacket - Men's	1279.55
-- 3	The North Face Denali Down Womens Jacket 2013	832.57
-- 4	Canada Goose Men's The Chateau Jacket	715.57
-- 5	True Religion Men's Ricky Straight Jean	666.62

-- the top costy category.
select category ,round(sum(cost),2) as total_cost
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	Jeans	104775.99
-- 2	Outerwear & Coats	92269.41
-- 3	Sweaters	62684.14
-- 4	Swim	51938.09
-- 5	Fashion Hoodies & Sweatshirts	51880.44

-- the top costy brand.
select brand ,round(sum(cost),2) as total_cost
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	Calvin Klein	14831.75
-- 2	True Religion	14747.55
-- 3	Diesel	14621.7
-- 4	7 For All Mankind	14395.72
-- 5	Carhartt	12473.4

--*******************

-- the top revenue product, category, brand:
-- the top revenue product.
select name ,round(sum(retail_price),2) as total_revenue
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	NIKE WOMEN'S PRO COMPRESSION SPORTS BRA *Outstanding Support and Comfort*	2709.0
-- 2	The North Face Apex Bionic Soft Shell Jacket - Men's	2709.0
-- 3	The North Face Denali Down Womens Jacket 2013	1806.0
-- 4	Canada Goose Men's The Chateau Jacket	1630.0
-- 5	Canada Goose Women's Mystique	1500.0

-- the top revenue category.
select category ,round(sum(retail_price),2) as total_revenue
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	Outerwear & Coats	207344.27
-- 2	Jeans	195608.56
-- 3	Sweaters	130829.07
-- 4	Swim	103952.56
-- 5	Fashion Hoodies & Sweatshirts	100606.5

-- the top revenue brand.
select brand ,round(sum(retail_price),2) as total_revenue
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	Calvin Klein	31639.76
-- 2	Diesel	29179.17
-- 3	True Religion	28234.86
-- 4	7 For All Mankind	27549.48
-- 5	Carhartt	26674.09

-- ****************

-- the top/bottom profit product, category, brand:
--(top_product)
select name ,round(sum(retail_price)-sum(cost),2) as total_profit
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	The North Face Apex Bionic Soft Shell Jacket - Men's	1429.45
-- 2	NIKE WOMEN'S PRO COMPRESSION SPORTS BRA *Outstanding Support and Comfort*	1372.56
-- 3	The North Face Denali Down Womens Jacket 2013	973.43
-- 4	Canada Goose Men's The Chateau Jacket	914.43
-- 5	Canada Goose Women's Mystique	866.25	

--(bottom_product)
select name ,round(sum(retail_price)-sum(cost),2) as total_profit
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 asc;
-- 1	Indestructable Aluminum Aluma Wallet - RED	0.01
-- 2	Set of 2 - Replacement Insert For Checkbook Wallets Card Or Picture Insert	0.31
-- 3	Individual Bra Extenders	0.74
-- 4	Solid Color Leather Adjustable Skinny Belt with	0.87
-- 5	GENUINE LEATHER SNAP ON STUDDED WHITE PIANO BELT FITS ANY BUCKLE	0.88

------------------------

--(top_category)
select category ,round(sum(retail_price)-sum(cost),2) as total_profit
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	Outerwear & Coats	115074.86
-- 2	Jeans	90832.57
-- 3	Sweaters	68144.93
-- 4	Suits & Sport Coats	55983.67
-- 5	Swim	52014.47

--(bottom_category)
select category ,round(sum(retail_price)-sum(cost),2) as total_profit
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 asc;
-- 1	Clothing Sets	1196.45
-- 2	Jumpsuits & Rompers	3446.13
-- 3	Leggings	6128.3
-- 4	Socks & Hosiery	6676.04
-- 5	Socks	7332.1

------------------------

--(top_brand)
select brand ,round(sum(retail_price)-sum(cost),2) as total_profit
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;
-- 1	Calvin Klein	16808.01
-- 2	Diesel	14557.47
-- 3	Carhartt	14200.69
-- 4	True Religion	13487.31
-- 5	7 For All Mankind	13153.76	

--(bottom_brand)
select brand ,round(sum(retail_price)-sum(cost),2) as total_profit
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 asc;
-- 1	marshal	0.01
-- 2	Made in USA	0.31
-- 3	Extenders	0.74
-- 4	Wayfayrer	0.89
-- 5	Sock Company	1.32
-- 6	Skyblue	1.45	


-- top product for each category in (profit):
with ranked as (
select category,name,round(sum(retail_price)-sum(cost),2) as total_profit,
row_number() over(partition by category order by round(sum(retail_price)-sum(cost),2) desc ) as rank
from `bigquery-public-data.thelook_ecommerce.products`
group by 1,2
order by 1,3 desc)
select * except(rank)
from ranked 
where rank = 1
order by total_profit desc
--(top)
-- 1	Blazers & Jackets	Rebecca Minkoff Women's Becky Jacket	597.15
-- 2	Outerwear & Coats	Darla	594.4
-- 3	Jeans	True Religion Men's Ricky Straight Jean	581.33
-- 4	Active	JORDAN DURASHEEN SHORT MENS 404309-109	532.77
-- 5	Shorts	Alpha Industries Rip Stop Short	516.48
--(bottom)
/*
1	Accessories	Indestructable Aluminum Aluma Wallet - RED	0.01
2	Intimates	Individual Bra Extenders	0.74
3	Plus	Blank Long Cuff Beanie Cap (Choose Many Colors Available)	0.93
4	Active	Pink Ribbon Breast Cancer Awareness Knee High Socks Great for Sports Teams Fundraising Relay for Life Walk Survivor (Style 26)	1.03
5	Sleep & Lounge	Alivila.Y Fashion Sexy Lace Lingerie Sleepwear Sleep Dress Set With G-String 402	1.05	
*/

---------------------------------------- User Analysis ------------------------------------

-- the avg of users?
SELECT avg(age)  FROM `bigquery-public-data.thelook_ecommerce.users`;
-- 41
-- what is the total_users for each gender?
select gender , count(*) as total_users
from `bigquery-public-data.thelook_ecommerce.users`
group by gender;
-- F	49868
-- 2	M	50132
--Pct_of_total

SELECT distinct traffic_source 
FROM `bigquery-public-data.thelook_ecommerce.users` ;
-- 1	Search
-- 2	Facebook
-- 3	Organic
-- 4	Display
-- 5	Email

-- how many people from each country?
SELECT  country ,count(*) as total_
FROM `bigquery-public-data.thelook_ecommerce.users` 
group by 1 order by 2 desc;
-- 1	China	33798
-- 2	United States	22564
-- 3	Brasil	14689
-- 4	South Korea	5350
-- 5	France	4664
-- 6	United Kingdom	4541
-- 7	Germany	4209
-- 8	Spain	4004
-- 9	Japan	2526
-- 10	Australia	2154
-- 11	Belgium	1227
-- 12	Poland	257

-- how many people from USA for each state?
SELECT distinct state 
FROM `bigquery-public-data.thelook_ecommerce.users` 
where country = 'United States' and state is null;

-- no nulls in states in USA
SELECT  state , count(*) as total_users 
FROM `bigquery-public-data.thelook_ecommerce.users` 
where country = 'United States'
group by 1 order by 2 desc;
-- 1	California	3748
-- 2	Texas	2390
-- 3	Florida	1718
-- 4	New York	1313
-- 5	Illinois	891


-- which is the most source gives us users?
select traffic_source, count(*) AS total_users
from `bigquery-public-data.thelook_ecommerce.users` 
group by 1 order by 2 desc ;
-- 1	Search	69868
-- 2	Organic	14915
-- 3	Facebook	6120
-- 4	Email	5034
-- 5	Display	4063

-- which is the most year came users in it?
select EXTRACT(YEAR FROM created_at) AS year , count(*) AS total_users
from `bigquery-public-data.thelook_ecommerce.users` 
group by 1
order by 2 desc;
-- 1	2020	13603
-- 2	2025	13574

-- which is the most year came users in it (USA)?
select EXTRACT(YEAR FROM created_at) AS year , count(*) AS total_users
from `bigquery-public-data.thelook_ecommerce.users` 
where country = 'United States'
group by 1
order by 2 desc;
-- 1	2020	3133
-- 2	2023	3079

-- what is the top 1 source in each year (USA)?  
 
select * , row_number() over(partition by year order by total_users desc) as rank
from (
select EXTRACT(YEAR FROM created_at) AS year,traffic_source , count(*) AS total_users
from `bigquery-public-data.thelook_ecommerce.users` 
where country = 'United States'
group by 1,2
order by 2 desc)
order by total_users desc;
-- 1	2023	Search	2175	
-- 2	2020	Search	2166	
-- 3	2021	Search	2131	
-- 4	2024	Search	2112	
-- 5	2025	Search	2107	
-- 6	2022	Search	2070	
-- 7	2019	Search	2023	
-- 8	2026	Search	941	  

-------------- The End ------------------













































