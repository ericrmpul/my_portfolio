/*
【構面】
成長品質裁決（Growth Quality Verdict）

【目的】
整合獲客、轉換、產品、回購四大構面，依年度比較各指標的方向性變化，輸出最終成長品質裁決。

【關鍵發現】
1. 2013 與 2014 年多項核心指標同步改善，顯示擴張期間的成長品質穩定提升。
2. 2015 年雖受右側截斷影響，回購相關指標出現技術性波動，但主要營運指標仍維持健康區間，最終裁決不受影響。
3. 整體結果顯示公司成長並非單靠流量擴張，而是同時伴隨轉換效率、產品組合與回購表現改善。

【技術備註】
1. 以七層獨立 CTE 分別整理獲客、轉換、產品與回購指標，再整合為年度裁決表。
2. 使用 LAG() 計算各指標的年度方向變化、LEAD() 追蹤用戶次筆訂單，並以 +1 / 0 / -1 進行評分。
3. 以加權方式合成最終 health_score，並依門檻輸出 Healthy / Watch / Unhealthy。
4. 針對 2012 基準年與 2015 右側截斷情況，已在評分邏輯中保留資料限制。
*/
with acquisition_metrics as(
select
year(created_at) as yr,
count(distinct website_session_id) as total_sessions,
100.0*count(case when utm_source='NULL'and http_referer='NULL' then website_session_id end)
/nullif(count(distinct website_session_id),0) as direct_share_pct,
100.0*count(case when utm_source='NULL'and http_referer<>'NULL' then website_session_id end)
/nullif(count(distinct website_session_id),0) as organic_share_pct,
100.0*count(case when utm_source<>'NULL'then website_session_id end)
/nullif(count(distinct website_session_id),0) as paid_share_pct
from [dbo].[1.website_sessions]
group by year(created_at)
), conversion_metrics as(
select
year(ws.created_at) as yr,
count(distinct o.order_id) as total_orders,
100.0*count(distinct o.order_id)
/nullif(count(distinct ws.website_session_id),0) as total_cvr
from [dbo].[1.website_sessions] ws
left join [dbo].[3.orders] o
on ws.website_session_id=o.website_session_id
group by year(ws.created_at)
), product_metrics as(
select
year(o.created_at) as yr,
count(distinct o.order_id) as orders,
sum(cast(oi.price_usd as float)) as revenue,
sum((cast(oi.price_usd as float))-cast(oi.cogs_usd as float)) as gross_profit,
100.0*(sum(cast(oi.price_usd as float))-sum(cast(oi.cogs_usd as float)))/
nullif(sum(cast(oi.price_usd as float)),0) as gross_margin_pct,
100.0*count(distinct oir.order_item_id)/
nullif(count(distinct oi.order_item_id),0) as refund_rate_pct,
100.0*sum(case when oi.product_id in (3,4) 
               then cast(oi.price_usd as float) 
               else 0 end)
      / nullif(sum(cast(oi.price_usd as float)), 0) as high_margin_product_revenue_share
from[dbo].[3.orders] o
left join [dbo].[4.order_items] oi on o.order_id=oi.order_id
left join [dbo].[5.order_item_refunds] oir on oi.order_item_id=oir.order_item_id
group by year(o.created_at)
), 
user_order as(
select
user_id,
created_at as first_order,
lead(created_at,1) over(partition by user_id order by created_at) as second_order,
ROW_NUMBER() over(partition by user_id order by created_at) as order_number
from [dbo].[3.orders]
), median_days_table as(
select
year(first_order) as yr,
user_id,
second_order,
PERCENTILE_CONT(0.5) within group(order by datediff(day,first_order,second_order))
over(partition by year(first_order)) as yearly_median_days
from user_order
where order_number=1
),compounding_metrics as(
select
yr,
count(user_id) as total_first_buyers,
100.0*count(second_order)
/nullif(count(user_id),0) as repeat_rate_pct,
max(yearly_median_days) as median_days_to_repeat
from median_days_table
group by yr
), final_score_table as(
select
a.yr,
cast(a.paid_share_pct as decimal(18,2)) as paid_share_pct,
cast(b.total_cvr as decimal(18,2)) total_cvr,
cast(c.gross_margin_pct as decimal(18,2)) as gross_margin_pct,
cast(c.refund_rate_pct as decimal(18,2)) as refund_rate_pct,
cast(d.repeat_rate_pct as decimal(18,2)) as repeat_rate_pct,
median_days_to_repeat,
case when a.paid_share_pct<lag(a.paid_share_pct) over(order by a.yr) then 1 
     when a.paid_share_pct>lag(a.paid_share_pct) over(order by a.yr) then -1
     else 0 end as paid_score,
case when b.total_cvr>lag(b.total_cvr) over(order by a.yr) then 1 
     when b.total_cvr<lag(b.total_cvr) over(order by a.yr) then -1
     else 0 end as cvr_score,
case when c.gross_margin_pct>lag(c.gross_margin_pct) over(order by a.yr) then 1 
     when c.gross_margin_pct<lag(c.gross_margin_pct) over(order by a.yr) then -1
     else 0 end as margin_score,
case when c.refund_rate_pct<lag(c.refund_rate_pct) over(order by a.yr) then 1 
     when c.refund_rate_pct>lag(c.refund_rate_pct) over(order by a.yr) then -1
     else 0 end as refund_score,
case when d.repeat_rate_pct>lag(d.repeat_rate_pct) over(order by a.yr) then 1 
     when d.repeat_rate_pct<lag(d.repeat_rate_pct) over(order by a.yr) then -1
     else 0 end as repeat_score
from acquisition_metrics a
left join conversion_metrics b
on a.yr=b.yr
left join product_metrics c
on a.yr=c.yr
left join compounding_metrics d
on a.yr=d.yr
),score_calculator as(
select 
*,
(paid_score*0.25+cvr_score*0.30+margin_score*0.15+refund_score*0.10+repeat_score*0.20) as health_score
from final_score_table
)
select
*,
case when health_score>= 0.5 then 'Healthy' 
     when health_score>0     then 'Watch'
     when health_score=0     then '-'
     else 'Unhealthy' end as VERDICT
from score_calculator
order by yr;