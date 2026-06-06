/*
【構面】
獲客品質（Acquisition Quality）

【目的】
比較各付費 Campaign 的流量規模與轉換率表現，辨識高效與低效獲客來源。

【關鍵發現】
1.Nonbrand Campaign 的 CVR 由 3.97% 提升至 8.59%，成為付費流量效率提升的主要驅動力
2.Brand Campaign 則同時維持高轉換率與流量成長，顯示品牌資產持續累積。
*/
with rawdata as(
select
year(ws.created_at) as yr,
ws.utm_campaign,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
100.0*count(distinct o.order_id)/nullif(count(distinct ws.website_session_id),0) as cvr
from [dbo].[1.website_sessions] ws
left join [dbo].[3.orders] o on
ws.website_session_id= o.website_session_id
where ws.utm_source !='NULL'
group by year(ws.created_at),ws.utm_campaign
)
select
yr,
utm_campaign,
sessions,
orders,
cvr,
sum(sessions) over (partition by yr) as yearly_total_sessions,
100.0*sessions/sum(sessions) over (partition by yr) as campaign_sharex
from rawdata
order by yr,sessions desc;