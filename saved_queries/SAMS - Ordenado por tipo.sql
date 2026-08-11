SELECT

 --t1.po_nbr AS PO_NBR
 --,t2.line_nbr AS LINE
 --,t1.order_date AS PO_DATE
  T3.old_nbr AS ITEM
  ,t1.store_nbr AS CLUB
  ,CASE WHEN t1.sams_po_type = 20 THEN 20 END AS TYPE_20
  ,CASE WHEN t1.sams_po_type = 27 THEN 27 END AS TYPE_27
  ,CASE WHEN t1.sams_po_type = 28 THEN 28 END AS TYPE_28
 --,t1.ship_date AS SHIP_DATE
 --,t1.cancel_date AS CANCEL_DATE
  --,t1.original_cancel_dt AS ORG CANCEL DATE")
  ,t1.po_status AS PO_ST
 --,t1.ENTRY_COMP_INIT(NAMED"INIT")
 --,t1.vendor_nbr AS VENDOR
 --,t1.vendor_nbr_dept AS DEPT
 --,t1.VENDOR_NBR_SEQ AS SEQ 
 --,t1.VENDOR_NBR_DEPT (NAMED"VENDOR  DET")
 --,t1.VENDOR_NBR_SEQ (NAMED"VENDOR SEQ")
 --,t1.vendor_name AS VENDOR_NAME
 --,t2.seg_status AS ST_LINE
 --,t1.store_nbr AS CLUB
 --,t3.category_nbr AS CAT
 --,t3.sub_category_nbr AS S_CAT
 --,t3.old_nbr AS ITEM
 --,t3.upc AS UPC
 --t3.primary_desc AS DESCR_1
 --,t3.majority_status_cd AS STATUS_ITEM
 --,t1.event_desc AS EVENTO
  --,t1.po_comment AS PO Comment
  --,t1.routing
 --,t2.whpk_order AS QTY_ORDER
  ,SUM(CASE WHEN t1.sams_po_type = 20 THEN t2.whpk_order END) AS QTY_ORDER_20
  ,SUM(CASE WHEN t1.sams_po_type = 27 THEN t2.whpk_order END) AS QTY_ORDER_27
  ,SUM(CASE WHEN t1.sams_po_type = 28 THEN t2.whpk_order END) AS QTY_ORDER_28
  --,t2.whpk_qty_rcvd AS QTY_RCVD
  ,SUM(CASE WHEN t1.sams_po_type = 20 THEN t2.whpk_qty_rcvd END) AS QTY_RCVD_20
  ,SUM(CASE WHEN t1.sams_po_type = 27 THEN t2.whpk_qty_rcvd END) AS QTY_RCVD_27
  ,SUM(CASE WHEN t1.sams_po_type = 28 THEN t2.whpk_qty_rcvd END) AS QTY_RCVD_28
  --,t2.net_vnpk_cost (Named"CST REAL PAQ")
  --,t2.vendor_pack_qty AS PACK
  --,t2.net_vnpk_cost/t2.vendor_pack_qty (Named "UNIT COST")
  ,SUM(CASE WHEN t1.sams_po_type = 20 THEN (t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_order END ) AS TOTAL_COST_ORD_20
  ,SUM(CASE WHEN t1.sams_po_type = 27 THEN (t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_order END ) AS TOTAL_COST_ORD_27
  ,SUM(CASE WHEN t1.sams_po_type = 28 THEN (t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_order END ) AS TOTAL_COST_ORD_28
  ,SUM(CASE WHEN t1.sams_po_type = 20 THEN (t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_qty_rcvd END ) AS TOTAL_COST_REC_20
  ,SUM(CASE WHEN t1.sams_po_type = 27 THEN (t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_qty_rcvd END ) AS TOTAL_COST_REC_27
  ,SUM(CASE WHEN t1.sams_po_type = 28 THEN (t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_qty_rcvd END ) AS TOTAL_COST_REC_28
  --,SUM((t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_order) AS TOTAL_COST_ORD
  --,SUM((t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_qty_rcvd) AS TOTAL_COST_REC

FROM

  wmt-edw-prod.MX_WC_VM.PURCHASE_ORDER t1,
  wmt-edw-prod.MX_WC_VM.PO_LINE t2,
  wmt-edw-prod.MX_WC_VM.ITEM_DESC t3

WHERE
 1=1
  AND t1.po_nbr=t2.po_nbr 
  AND t1.order_date=t2.order_date 
  AND t2.item_nbr=t3.item_nbr 
  --AND t1.sams_po_type IN (20) 
   AND t1.ORDER_date BETWEEN  '2023-07-01' AND  '2023-08-11' 
  --AND t1.ship_date >= DATE-31 
  AND t2.whpk_order > 0 
  --AND t2.whpk_qty_rcvd > 0 
  --AND t1.store_nbr IN (4995)
  AND t1.po_status IN ('A') 
  --AND t2.seg_status IN ('A') 
  --AND t1.store_nbr IN ()
  --AND t1.cancel_date <= DATE
  --AND t3.category_nbr  IN (60,78,85,3,17,5,9) 
  --AND t3.sub_category_nbr IN (56)
  AND t3.old_nbr IN (981003116)
  --AND t1.vendor_nbr IN ('034454')                             
  --AND t1.po_nbr IN ('201193938')
                    
  GROUP BY
 1,2,3,4,5,6--,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
  
  ORDER   BY
  --t1.po_nbr
 --,t2.line_nbr
 --,t1.cancel_date
 --,t1.order_date
-- ,t1.sams_po_type
 --,t1.ship_date
  TYPE_20
  ,TYPE_27
  ,TYPE_28
  ,t3.old_nbr
  ,t1.store_nbr