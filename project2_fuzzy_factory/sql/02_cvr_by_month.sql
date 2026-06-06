/*
【構面】
轉換效率（Conversion Efficiency）

【目的】
以月為單位觀察 CVR 變化，捕捉年度分析無法呈現的短期波動與季節性特徵。

【關鍵發現】
CVR 自 2013 年起出現結構性跳升，並於 2015 年第一季穩定站上 8% 以上，顯示轉換效率提升具有持續性而非短期波動。
*/
select 
YEAR(ws.created_at) as yr,
month(ws.created_at) as mt,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
100.0*count(distinct o.order_id)/count(distinct ws.website_session_id) as cvr

from dbo.[1.website_sessions] ws
left join dbo.[3.orders] o
on	ws.website_session_id=o.website_session_id
group by 
year(ws.created_at),
month(ws.created_at)
order by yr,mt;