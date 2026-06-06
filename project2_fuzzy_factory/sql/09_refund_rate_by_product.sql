/*
【構面】
產品經濟性（Product Economics）

【目的】
評估各產品的退款率表現，驗證毛利成長是否伴隨售後風險上升。

【關鍵發現】
1. P2 與 P4 長期維持低退款率，顯示產品滿意度與獲利品質穩定。
2. P3 具有最高退款率，雖具備高毛利特性，但實際獲利能力可能受到退款侵蝕。
3. P1 退款率逐年下降，顯示產品品質或市場匹配度持續改善。
4. 整體產品組合擴張未伴隨退款風險惡化，僅 P3 需持續監控。
*/
with dataset as(
select
year(oi.created_at) as yr,
oi.product_id,
count(distinct oi.order_item_id) as items_sold,
count(distinct oir.order_item_refund_id) as items_refunded
from [dbo].[4.order_items] oi
left join [dbo].[5.order_item_refunds] oir on
oi.order_item_id=oir.order_item_id
group by year(oi.created_at), oi.product_id
)
select
yr,
product_id,
items_sold,
items_refunded,
100.0*items_refunded/nullif(items_sold,0) as refund_rate_pct
from dataset
order by yr,product_id;