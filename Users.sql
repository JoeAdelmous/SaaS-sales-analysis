-- users 
SELECT *  FROM `bigquery-public-data.thelook_ecommerce.users` LIMIT 1000;

-- how many users?
SELECT count(*)  FROM `bigquery-public-data.thelook_ecommerce.users`;
-- 100,000 😂😂

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
-- 1	2023	Search	2175	1
-- 2	2020	Search	2166	1
-- 3	2021	Search	2131	1
-- 4	2024	Search	2112	1
-- 5	2025	Search	2107	1
-- 6	2022	Search	2070	1
-- 7	2019	Search	2023	1
-- 8	2026	Search	941	  1

-------------- The End ------------------



























