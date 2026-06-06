/*
【構面】
轉換效率（Conversion Efficiency）

【目的】
比較 Desktop 與 Mobile 的年度 CVR 增幅，量化不同裝置的轉換效率成長動能。

【關鍵發現】
1.Desktop CVR 年增幅長期維持正向成長
2.Mobile CVR 在 2013 年後增幅快速收斂至約 0.2 個百分點，顯示行動端轉換效率已接近停滯。

【技術備註】lag() over (partition by device_type order by yr) 取同裝置上一年 CVR，計算絕對差值
*/
with table1 as(
select 
year(ws.created_at) as yr,
ws.device_type,
count(distinct o.order_id) as orders,
count(distinct ws.website_session_id) as sessions,
100.0*count(distinct o.order_id)
/nullif(count(distinct ws.website_session_id),0) as cvr
from [dbo].[1.website_sessions] ws
left join [dbo].[3.orders] o
on ws.website_session_id= o.website_session_id
group by year(ws.created_at),ws.device_type
)
select
*,
lag(cvr) over (partition by device_type order by yr) as last_yr_cvr,
cvr-lag(cvr) over (partition by device_type order by yr) as cvr_yoy_change
from table1
order by device_type,yr;