/*
【構面】
獲客品質（Acquisition Quality）

【目的】
追蹤付費流量的流量佔比與訂單佔比變化，評估付費獲客效率是否隨時間改善。

【關鍵發現】
1.Paid Session Share 由 90.8% 下降至 76.8%，顯示企業對付費流量的依賴逐步降低。
2.2015 年 Paid Order Share 首次超越 Paid Session Share，代表付費流量開始產生高於其流量占比的訂單貢獻。
*/
with raw_data as(
select
ws.website_session_id,
o.order_id,
year(ws.created_at) as yr,
case 
	when ws.utm_source='NULL' and ws.http_referer='NULL' then 'direct'
	when ws.utm_source='NULL' then 'organic'
	else 'paid'
	end as traffic_type
from [dbo].[1.website_sessions] ws
left join [dbo].[3.orders] o
on ws.website_session_id=o.website_session_id
)
select
yr,
count(distinct website_session_id) as total_sessions,
count(distinct case when traffic_type = 'paid' then website_session_id end) as paid_sessions,
100.0 * count(distinct case when traffic_type = 'paid' then website_session_id end)/ 
nullif(count(distinct website_session_id), 0) as paid_session_share,
count(distinct order_id) as total_orders,
count(distinct case when traffic_type='paid' then order_id end) as paid_orders,
100.0*count(distinct case when traffic_type='paid' then order_id end)/
nullif(count(order_id),0) as paid_orders_share
from raw_data
group by yr
order by yr;
