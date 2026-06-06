/*
【構面】
顧客複利（Customer Compounding）

【目的】
計算首購客的回購比例，評估回購機制對整體成長的實際貢獻程度。

【關鍵發現】
1.各年度回購率約1~2%，絕大多數客戶僅購買一次，顯示商業模式仍以持續獲取新客為主要成長來源。
2.雖然回購客比例有限，但回購貢獻呈現逐年提升趨勢。
3.結合回購間隔分析可發現，少數回購客多於首購後一個月內完成第二次購買，具備較高的再購潛力。

【技術備註】
1.以每位用戶的首筆訂單作為起點，判斷是否存在後續訂單。
2.使用 EXISTS 進行回購與一次性買家分類，再彙總計算年度回購率。
*/
with first_order as(
select
user_id,
min(created_at) as first_order_date,
year(min(created_at)) as first_purchase_year
from [dbo].[3.orders]
group by user_id
),
buyer_classification as (
select
fo.user_id,
fo.first_purchase_year,
case when exists(
	select 1
	from [dbo].[3.orders] o2
	where o2.user_id=fo.user_id
	and o2.created_at>fo.first_order_date
	)then 'repeat'
	else 'one_time'
end as buyer_status
from first_order fo
)
select
first_purchase_year,
count(*) as total_first_buyers,
sum(case when buyer_status='repeat'		then 1 else 0 end) as repeat_buyers,
sum(case when buyer_status='one_time'	then 1 else 0 end) as one_time_buyers,
100.0*sum(case when buyer_status='repeat' then 1 else 0 end)
	/nullif(count(*),0) as repeat_rate_pct
from buyer_classification
group by first_purchase_year
order by first_purchase_year;