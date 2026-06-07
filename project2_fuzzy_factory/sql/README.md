# SQL 查詢索引

本資料夾包含 Fuzzy Factory 成長品質診斷專案的所有 SQL 查詢，共 14 支。每支查詢的標頭備註均記錄對應構面、核心發現與技術說明。

| 編號 | 檔案名稱 | 對應構面 |核心技術|
|---|---|---|---|
| 01 | 01_cvr_by_year.sql | 轉換效率 |基礎聚合、LEFT JOIN|
| 02 | 02_cvr_by_month.sql | 轉換效率 |月度顆粒度、季節性觀察|
| 03 | 03_cvr_by_traffic_type.sql | 獲客品質 |CASE WHEN流量分類、字串'NULL'處理|
| 04 | 04_paid_share_by_year.sql | 獲客品質 |雙層CTE、Session與Order雙維度計算|
| 05 | 05_paid_campaign_breakdown.sql | 獲客品質 |Campaign、CVR交叉比對|
| 06 | 06_cvr_by_device.sql | 轉換效率 |裝置類型分類、CAST(VARCHAR→FLOAT)|
| 06b | 06b_cvr_device_yoy_lag.sql | 轉換效率 |LAG() OVER PARTITION BY裝置YoY增幅|
| 07 | 07_new_vs_repeat_cvr.sql | 轉換效率 × 顧客複利 |新訪/回訪Session分類、CVR Gap計算|
| 08 | 08_product_revenue_mix.sql | 產品經濟性 |產品組合營收結構、CAST金額轉型|
| 09 | 09_refund_rate_by_product.sql | 產品經濟性 |CTE聚合層分離、退款率逐年趨勢|
| 10 | 10_repeat_order_revenue_share.sql | 顧客複利 |OVER(PARTITION BY yr)回購佔比|
| 11 | 11_repeat_purchase_interval.sql | 顧客複利 |3層CTE、ROW_NUMBER首購/首回購純化、CENTILE_CONT中位數|
| 12 | 12_one_time_vs_repeat_buyers.sql | 顧客複利 |EXISTS / NOT EXISTS用戶分類|
| 13 | scorecard.sql | 成長品質裁決 |7層CTE模組化、LAG動態評分、LEAD次筆訂單追蹤、CASE WHEN加權計分|
