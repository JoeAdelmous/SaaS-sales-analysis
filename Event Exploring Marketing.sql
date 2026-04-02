-- any step happens in the website 
SELECT * FROM `bigquery-public-data.thelook_ecommerce.events` LIMIT 1000;

-- explore the sequence_number

SELECT distinct sequence_number FROM `bigquery-public-data.thelook_ecommerce.events` ;
-- the sequence is the moves in the website more moves more badness in ui&ux
-- session is mean a visit for webiste 

-- traffic_source is for marketing

-- what is the types of event_type?
SELECT distinct event_type FROM `bigquery-public-data.thelook_ecommerce.events` ;
-- 1	cart -- but product into cart 😍
-- 2	home -- just in home 👍
-- 3	cancel -- cancle it 😒
-- 4	department -- categories (exploring +) 😁
-- 5	product -- tapped on product 👌
-- 6	purchase -- pay one ❤️
-- KPIs : conversion rate , won_rate , churn_rate
SELECT distinct uri FROM `bigquery-public-data.thelook_ecommerce.events` limit 1000;
-- this is the navigation 

-- how many_uesrs we don't now there users_id
select count(*)
from `bigquery-public-data.thelook_ecommerce.events` 
where user_id is null;
-- 1124450 from 2429823 so there more about half
select count(*)
from `bigquery-public-data.thelook_ecommerce.events` ;


-- what is the renge of cteated_at years?
SELECT distinct extract(year from created_at) as year
FROM `bigquery-public-data.thelook_ecommerce.events`
order by 1 asc
-- 2019 - 2026


-- home → department → product → cart → purchase

-- let's begian year ,events  what is the top year in events?
SELECT  extract(year from created_at) as year , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
group by  extract(year from created_at)
order by 2 desc
-- 2025 ->	567692

-- what is the top 2 months in total 
SELECT  extract(month from created_at) as month , count(*) as total_events
FROM `bigquery-public-data.thelook_ecommerce.events`
group by  extract(month from created_at)
order by 2 desc
-- 3 ->	293768

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



-- (that is purches events)


-- let's begian year ,events  what is the top year in events?
SELECT  extract(year from created_at) as year , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by  extract(year from created_at)
order by 2 desc
-- 2025 ->	57505

-- what is the top 2 months in total 
SELECT  extract(month from created_at) as month , count(*) as total_events
FROM `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by  extract(month from created_at)
order by 2 desc
-- 3 ->	24833

-- what is the top 2 months in each year -- no dublicated 
with year_month as (
SELECT   extract(year from created_at) as year , extract(month from created_at) as month , count(*) as  total_events
FROM `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by extract(year from created_at) , extract(month from created_at)
order by 3 desc)
, ranked as (
select *, row_number() over(partition by year_month.year order by year_month.total_events desc) as rank
from year_month
order by total_events desc
)

select * except(rank) from ranked 
where ranked.rank <= 2
-- 2026/3	-> 14020


-- which the top 2 browsers has events (overall)
SELECT browser , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
group by browser 
order by 2 desc limit 2
-- Chrome	1216771
-- Firefox	485963

-- which the top 2 browsers has events (purchase)
SELECT browser , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by browser 
order by 2 desc limit 2
-- Chrome	91281
-- Firefox	36312

-- which the top 2 sources has events (overall)
SELECT traffic_source , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
group by traffic_source 
order by 2 desc 
-- 1	Email	1094300
-- 2	Adwords	726945

-- which the top 2 sources has events (purchase)
SELECT traffic_source , count(*)
FROM `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'purchase'
group by traffic_source 
order by 2 desc limit 2
-- 1	Email	81858
-- 2	Adwords	54522

-- top two sources for each browser (overall)
with ranked as (
select browser , traffic_source , count(*),
row_number() over ( partition by browser order by count(*) desc) as rank
from `bigquery-public-data.thelook_ecommerce.events`
group by browser , traffic_source
order by 3 desc
)

select *  except(rank) from ranked 
where rank <= 2
order by 1 , 3 desc
-- Chrome	Email	546460
-- Firefox	Email	219509

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

-- top two sources for each browser (cancel)
with ranked as (
select browser , traffic_source , count(*),
row_number() over ( partition by browser order by count(*) desc) as rank
from `bigquery-public-data.thelook_ecommerce.events`
where event_type = 'cancel'
group by browser , traffic_source
order by 3 desc
)
select *  except(rank) from ranked 
where rank <= 2
-- Chrome	Email	28173
-- Firefox	Email	11239


-- the users for each event_type
SELECT 
  event_type,
  COUNT(*) AS total_events
FROM `bigquery-public-data.thelook_ecommerce.events`
GROUP BY event_type
order by 2 desc;
-- 1	product	845119
-- 2	department	595149
-- 3	cart	594892
-- 4	purchase	182021
-- 5	cancel	124647
-- 6	home	87995
-- the lowest thing are (home) because most of users came from (ads) not direct to the website

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

------------------------------------- YoY change in Win Rate / Churn Rate (Final Thing) -----------------------------------------------------
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


SELECT * FROM `bigquery-public-data.thelook_ecommerce.events` limit 1000;


















































