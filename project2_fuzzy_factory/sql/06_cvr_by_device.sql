/*
【構面】
轉換效率（Conversion Efficiency）

【目的】
比較不同裝置的 CVR 變化，檢視整體轉換率成長是否由各裝置共同貢獻。

【關鍵發現】
1.Desktop CVR 由 5.0% 提升至 10.6%，為整體轉換率成長的主要來源
2.Mobile CVR 雖有成長，但增幅明顯落後，顯示行動端轉換效率存在改善空間。
*/
select
year(ws.created_at) as yr,
ws.device_type,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
100.0*count(distinct o.order_id)
/nullif(count(distinct ws.website_session_id),0) as cvr
from[dbo].[1.website_sessions] ws
left join[dbo].[3.orders] o on
ws.website_session_id=o.website_session_id
group by year(ws.created_at),ws.device_type
order by yr,ws.device_type;