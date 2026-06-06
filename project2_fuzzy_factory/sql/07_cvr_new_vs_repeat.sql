/*
【構面】
轉換效率（Conversion Efficiency）× 顧客複利（Customer Compounding）

【目的】
比較新訪與回訪用戶的 CVR 變化，驗證整體轉換率成長是否來自回購客群占比提升。

【關鍵發現】
新訪與回訪用戶的 CVR 均持續成長，且兩者差距逐年縮小，顯示整體 CVR 提升來自全體用戶轉換效率改善，而非回訪用戶占比提高所造成的表面成長。

【技術備註】2015 為 Q1 部分年資料，佔比數字需謹慎解讀
*/
select
year(ws.created_at) as yr,
ws.is_repeat_session,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
100.0*count(distinct o.order_id)
/nullif(count(distinct ws.website_session_id),0) as cvr
from[dbo].[1.website_sessions] ws
left join[dbo].[3.orders] o on
ws.website_session_id= o.website_session_id
group by year(ws.created_at),ws.is_repeat_session
order by yr,ws.is_repeat_session;