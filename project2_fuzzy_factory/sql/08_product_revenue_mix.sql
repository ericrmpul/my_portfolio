/*
【構面】
產品經濟性（Product Economics）

【目的】
評估新產品上市後是否擴大整體產品組合價值，或對既有產品產生蠶食效應。

【關鍵發現】
1.P2、P3、P4 上市後，P1 訂單量仍持續成長，未出現蠶食效應跡象。
2.高毛利產品（P3+P4）營收占比持續提升，顯示產品組合發生結構性升級。
3.各產品毛利率跨年度維持穩定，整體毛利改善主要來自產品組合變化，而非定價策略調整。

【技術備註】price_usd 與 cogs_usd 為 VARCHAR 格式，所有金額計算需加 cast(... as float)
*/
select
year(o.created_at) as yr,
oi.product_id,
count(distinct o.order_id) as orders,
sum(cast(oi.price_usd as decimal)) as revenue,
sum((cast(oi.price_usd as float))-cast(oi.cogs_usd as float)) as gross_profit,
100.0*(sum(cast(oi.price_usd as float))-sum(cast(oi.cogs_usd as float)))/
nullif(sum(cast(oi.price_usd as float)),0) as gross_margin_pct
from[dbo].[3.orders] o
left join [dbo].[4.order_items] oi on
o.order_id=oi.order_id
group by year(o.created_at),oi.product_id
order by yr,oi.product_id;