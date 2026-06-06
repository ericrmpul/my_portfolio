/*
【構面】
顧客複利（Customer Compounding）

【目的】
觀察回購訂單與回購營收占比變化，驗證回訪流量是否持續轉化為實際營收貢獻。

【關鍵發現】
1.回購訂單占比由 12.4% 提升至 22.2%，顯示回購客群對營收的貢獻持續增加。
2.回購營收占比與回購訂單占比走勢高度一致，顯示回購客與新客的平均訂單價值相近。
3.回訪流量成長同步帶動訂單與營收成長，顯示回購機制已形成穩定的複利效果。

【技術備註】
1.先彙總訂單營收，再依年度與回訪狀態進行聚合。
2.使用 Window Function 計算各年度的訂單與營收占比。
*/
with order_menu as(
select 
year(o.created_at) as yr,
o.order_id,
ws.is_repeat_session,
sum(cast(oi.price_usd as float)) as order_revenue
from [dbo].[3.orders] o
join [dbo].[1.website_sessions] ws on
o.website_session_id=ws.website_session_id
join [dbo].[4.order_items] oi on
o.order_id=oi.order_id
group by year(o.created_at),o.order_id,ws.is_repeat_session
),
yearly_menu as(
select
yr,
is_repeat_session,
count(distinct order_id) as orders,
sum(order_revenue) as revenue
from order_menu
group by yr,is_repeat_session
)
select
*,
100.0*orders/sum(orders) over(partition by yr) as order_share_pct,
100.0*revenue/sum(revenue) over(partition by yr) as revenue_share_pct
from yearly_menu
order by yr,is_repeat_session;