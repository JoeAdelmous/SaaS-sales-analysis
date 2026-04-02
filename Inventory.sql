-- the inventory.

-- how many inventory
SELECT distinct name
FROM `bigquery-public-data.thelook_ecommerce.distribution_centers` ;
-- 10

SELECT *
FROM `bigquery-public-data.thelook_ecommerce.distribution_centers` limit 1000;



select inv.name as Inventory,
count(items.id) as No_items,
count(distinct(items.product_id)) as Total_Product,
round(sum(items.product_retail_price),2) as Revenue, 
round(avg(items.product_retail_price),2) as Avg_Revenue,
round(sum(items.cost),2) as Cost, 
round(avg(items.cost),2) as Avg_Cost,
round(sum(items.product_retail_price)-sum(items.cost),2) as Profit
from `bigquery-public-data.thelook_ecommerce.distribution_centers` as invname, name
join `bigquery-public-data.thelook_ecommerce.inventory_items` as items
  on inv.id = items.product_distribution_center_id
group by inv.name
order by No_items desc;
-- fct_table




































