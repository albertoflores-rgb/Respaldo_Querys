SELECT

                    t1.po_nbr AS PO_NBR
  ,t2.line_nbr AS LINE
                    ,t1.order_date AS PO_DATE
                    ,t1.sams_po_type AS TYPE
                    ,t1.ship_date AS SHIP_DATE
  ,t1.cancel_date AS CANCEL_DATE
                    --,t1.original_cancel_dt AS ORG CANCEL DATE")
                    ,t1.po_status AS PO_ST
                    --,t1.ENTRY_COMP_INIT(NAMED"INIT")
                    ,t1.vendor_nbr AS VENDOR
                    --,t1.VENDOR_NBR_DEPT (NAMED"VENDOR  DET")
                    --,t1.VENDOR_NBR_SEQ (NAMED"VENDOR SEQ")
                    ,t1.vendor_name AS VENDOR_NAME
                    ,t2.seg_status AS ST_LINE
                    ,t1.store_nbr AS CLUB
                    ,t3.category_nbr AS CAT
                    ,t3.sub_category_nbr AS S_CAT
                    ,t3.old_nbr AS ITEM
                    ,t3.upc AS UPC
                    ,t3.primary_desc AS DESCR_1
                    ,t3.majority_status_cd AS STATUS_ITEM
                    ,t1.event_desc AS EVENTO
--                 ,t1.po_comment AS PO Comment
--                 ,t1.routing
                    ,t2.whpk_order AS QTY_ORDER
                    ,t2.whpk_qty_rcvd AS QTY_RCVD
                    --,t2.net_vnpk_cost (Named"CST REAL PAQ")
                    ,t2.vendor_pack_qty AS PACK
                    --,t2.net_vnpk_cost/t2.vendor_pack_qty (Named "UNIT COST")
                    ,SUM((t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_order) AS TOTAL_COST_ORD
                    ,SUM((t2.net_vnpk_cost/t2.vendor_pack_qty)*t2.whpk_qty_rcvd) AS TOTAL_COST_REC

FROM

                    wmt-edw-prod.MX_WC_VM.PURCHASE_ORDER t1
                    ,wmt-edw-prod.MX_WC_VM.PO_LINE t2
                    ,wmt-edw-prod.MX_WC_VM.ITEM_DESC t3

WHERE

                    t1.po_nbr=t2.po_nbr AND
                    t1.order_date=t2.order_date AND
                    t2.item_nbr=t3.item_nbr AND

                    t1.sams_po_type IN (27) AND
t1.cancel_date BETWEEN  '2022-11-10' AND  '2022-12-31' AND
                    --t1.ship_date >= DATE-31 AND
                    t2.whpk_order > 0 AND
                    --t2.whpk_qty_rcvd > 0 AND
                    --t1.store_nbr IN (7502,4996,6239,6245) AND
                    -- AND
t1.po_status IN ('A') AND
t2.seg_status IN ('A') 
                    --t1.store_nbr IN ) AND
                    --AND        t1.cancel_date <= DATE
                    --AND--
          AND t3.category_nbr  IN (60,78,85,3,17,5,9) 
--t3.sub_category_nbr IN (56)
--t3.old_nbr IN (930962,798067,797185,176344,796940)
--t1.vendor_nbr IN ('094221' )                             


                    
                    GROUP BY
                    
                    t1.po_nbr 
  ,t2.line_nbr 
  ,t1.order_date 
                    ,t1.sams_po_type 
                    ,t1.ship_date 
                    ,t1.cancel_date 
                    --,t1.original_cancel_dt (NAMED"ORG CANCEL DATE")
                    ,t1.po_status
                    --,t1.ENTRY_COMP_INIT(NAMED"INIT")
                    ,t1.vendor_nbr 
                    ,t1.vendor_name 
                    --,t1.VENDOR_NBR_DEPT (NAMED"VENDOR  DET")
                    --,t1.VENDOR_NBR_SEQ (NAMED"VENDOR SEQ")
                    ,t2.seg_status 
                    ,t1.store_nbr
                    ,t3.category_nbr
                                        ,t3.sub_category_nbr 
                    ,t3.old_nbr 
                    ,t3.upc
                    ,t3.primary_desc 
                    ,t3.majority_status_cd 
  ,t1.event_desc 
                    --,t1.po_comment (NAMED "PO Comment")
--                 ,t1.routing
,t2.vendor_pack_qty 
                    ,t2.whpk_order 
                    ,t2.whpk_qty_rcvd

                                        
                    ORDER   BY

t1.po_nbr,
--                 ,t2.line_nbr
--                 ,t1.cancel_date
                    --,t1.order_date
                    t1.sams_po_type
                    --,t1.ship_date
