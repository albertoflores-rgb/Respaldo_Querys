Select
--assigned_store_nbr AS Club,
DATE_TRUNC(EXTRACT (DATE FROM order_date),YEAR) AS Fecha_Ano,
DATE_TRUNC(EXTRACT (DATE FROM order_date),Month) AS Fecha_Mes,
--customer_zip_code,
Sum(commercial_sale_qty)-SUM (CASE When subcategory_id = 97 Then Commercial_sale_qty ELSE 0 END) AS Omnicanal,
Sum(net_paid_orders_wo_shipping)-SUM (CASE When subcategory_id = 97 Then net_paid_orders_wo_shipping Else 0 End) AS Omnicanal_Price,
SUM (CASE When subcategory_id = 97 Then Commercial_sale_qty ELSE 0 END) AS Extendido,
SUM (CASE When subcategory_id = 97 Then net_paid_orders_wo_shipping Else 0 End) AS Extendido_Price,
Sum(CASE When assigned_store_nbr = 5854 Then commercial_sale_qty ELSE 0 END) AS TOTAL_FFC,
Sum(CASE When assigned_store_nbr = 5854 Then net_paid_orders_wo_shipping ELSE 0 END) AS Omnicanal_Price_FFC,
SUM (CASE When (subcategory_id = 97 AND assigned_store_nbr = 5854) Then Commercial_sale_qty ELSE 0 END) AS Extendido_FFC,
SUM (CASE When (subcategory_id = 97 AND assigned_store_nbr = 5854) Then net_paid_orders_wo_shipping Else 0 End) AS Extendido_Price_FFC

FROM
wmt-edw-sandbox.WM_AD_HOC_MX.AD_HOC_VENTA_RECONFIG_HIST

Where
Direction IN ("MG")
AND EXTRACT (DATE FROM order_date) between ('2022-01-01') and ('2023-11-30')
--AND ITEM_ID IN (152287)

Group By 1,2

Order by 1 DESC,2 DESC
