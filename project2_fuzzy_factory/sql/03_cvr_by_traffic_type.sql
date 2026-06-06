/*
【構面】
獲客品質（Acquisition Quality）

【目的】
比較不同流量來源的 CVR 表現，驗證整體轉換率提升是否來自真實效率改善，而非流量結構變化。

【關鍵發現】
Paid、Organic 與 Direct 三大渠道的 CVR 均呈現連續成長，顯示整體轉換效率提升具有普遍性，而非由單一流量來源驅動。

【技術備註】utm_source 以字串 'NULL' 儲存，篩選條件使用 = 'NULL' 而非 IS NULL。
*/
with rawdata as(
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
on ws.website_session_id= o.website_session_id
)
select
yr,
traffic_type,
count(distinct website_session_id) as sessions,
count(distinct order_id) as orders,
count(distinct order_id)*100.0/count(distinct website_session_id) as cvr
from rawdata
group by yr, traffic_type
order by yr, traffic_type;