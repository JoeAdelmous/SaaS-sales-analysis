-- this the thing which in the inventory (item) and will gonna but in the distribution_center_id
SELECT * FROM `bigquery-public-data.thelook_ecommerce.inventory_items` limit 1000;
-- each id has only one item

-- how many items 
SELECT count(*) FROM `bigquery-public-data.thelook_ecommerce.inventory_items` ;
-- 491963 item

-- how many sold items
SELECT count(*) 
FROM `bigquery-public-data.thelook_ecommerce.inventory_items` 
where sold_at is not null;
--180665 sold

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


-- created_at the time the item built in
-- sold_at the time the item but out --> null = not sold yet

-- product_retail_price the price for customers not wholesale 

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



