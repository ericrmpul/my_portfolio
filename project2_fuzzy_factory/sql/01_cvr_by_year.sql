/*
【構面】
轉換效率（Conversion Efficiency）
【目的】
觀察整體 CVR 是否隨時間持續提升，作為後續流量渠道與裝置分析的基準線。
【關鍵發現】
CVR 由 2012 年 4.1% 提升至 2015 年 8.4%，顯示成長來自轉換效率改善，而非單純流量擴張。
*/

select year(ws.created_at) as yr,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
100.0*count(distinct o.order_id)/nullif(count(distinct ws.website_session_id),0) as cvr

from dbo.[1.website_sessions] ws
left join dbo.[3.orders] o
on ws.website_session_id= o.website_session_id
group by year(ws.created_at)
order by yr;
