-- products
SELECT * FROM `bigquery-public-data.thelook_ecommerce.products` LIMIT 1000;

-- how many product 29120

-- how many category
select distinct category from `bigquery-public-data.thelook_ecommerce.products`;
-- 26

-- how many brand 
select distinct brand from `bigquery-public-data.thelook_ecommerce.products`;
-- 2757

-- what is the number of brand for each category
select category, count( distinct(brand)) as num_brand
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc;

-- 1	Accessories	419
-- 2	Fashion Hoodies & Sweatshirts	404
-- 3	Tops & Tees	391
-- 4	Shorts	390
-- 5	Intimates	356


-- what is the  number of brand for each category
select category, count( distinct(brand)) as num_brand
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 asc;
-- 1	Suits	18
-- 2	Clothing Sets	23
-- 3	Jumpsuits & Rompers	56
-- 4	Blazers & Jackets	143
-- 5	Underwear	145



-- what is the avg number of brand for each category
with no_cat as (
select category, count( distinct(brand)) as num_brand
from `bigquery-public-data.thelook_ecommerce.products`
group by 1
order by 2 desc
)
select avg(num_brand)
from no_cat;
-- 225

SELECT * FROM `bigquery-public-data.thelook_ecommerce.products` LIMIT 1000;



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

