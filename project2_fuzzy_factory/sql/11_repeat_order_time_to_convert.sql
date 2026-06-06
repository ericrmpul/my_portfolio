/*
【構面】
顧客複利（Customer Compounding）

【目的】
衡量用戶從首購到首次回購的時間間隔，找出最具價值的回購促動時機。

【關鍵發現】
1. 首次回購中位數約落在首購後 30～37 天，顯示首購後一個月內為關鍵回購窗口。
2. 2015 年資料僅涵蓋第一季，回購間隔數據存在觀察期間不足的限制（Right-Censoring）。

【技術備註】
1. 以 ROW_NUMBER() 排定每位用戶購買順序，再用 case when+min 條件聚合抽出第 1 筆（首購）與第 2 筆（首次回購）
   ，純化為單一回購間隔，排除多次回購污染。
2. 以 PERCENTILE_CONT() 計算各年度首次回購天數中位數。*/
with purchase_time_table as(
select
created_at,
order_id,
user_id,
primary_product_id,
ROW_NUMBER() over (partition by user_id order by created_at) as purchase_time 
from [dbo].[3.orders]
), purchase_count as(
select
user_id,
min(case when purchase_time=1 then created_at end) as first_purchase,
min(case when purchase_time=2 then created_at end) as second_purchase,
datediff(day,min(case when purchase_time=1 then created_at end),min(case when purchase_time=2 then created_at end)) as gap_days
from purchase_time_table
group by user_id
), final_table as(
select distinct
year(first_purchase) as yr,
user_id,
gap_days,
PERCENTILE_CONT(0.5) within group(order by gap_days) over(partition by year(first_purchase)) as median_days
from purchase_count
)
select
yr,
count(user_id) as return_customers,
min(gap_days) as min_days,
max(gap_days) as max_days,
avg(gap_days) as avg_days,
median_days
from final_table
where gap_days is not NULL
group by yr,median_days
order by yr;