SELECT

CAT
,Sucursal
,VNDR
,VNDR_DESC
,CANCEL_DATE
,extract(Year FROM CANCEL_DATE) AS year
,extract(Month FROM CANCEL_DATE) AS Mes
,SUM(QTY_REC_MOD) AS RECIBO
,SUM(QTY_ORD) AS ORDENADO
,SUM(QTY_REC_MOD) / SUM(QTY_ORD) FILLRATE

FROM(

SELECT      
REC.*
,CASE WHEN PO.QTY_REC>PO.QTY_ORD THEN PO.QTY_ORD ELSE PO.QTY_REC END AS QTY_REC_MOD
,PO.QTY_ORD
,PO.COST_ORD
,PO.COST_REC
,TIE As Sucursal

FROM
(
	SELECT
    PO.PO_NBR
    ,PO.LINE
    ,PO.PO_DATE
    ,PO.WMWK_CREATE
    ,PO.SHIP_DATE
    ,PO.CANCEL_DATE
    ,PO.WMWK_CANCEL
    ,PO.ORG_CANCEL_DATE
    ,PO.DAY_ORG_CANCEL
    ,PO.WMWK_ORG_CANCEL
    ,PO.PO_ST
    ,PO.VENDOR
    ,PO.VENDOR_DEPT
    ,PO.VENDOR_SEQ
    ,PO.VENDOR_NAME AS VNDR_DESC
    ,PO.LINE_ST  
    ,PO.DEST
    ,PO.CAT
    ,PO.ITEM_NBR
    ,PO.ITEM_DESC
    ,PO.VNPK
    ,PO.EVENTO
    ,PO.DEST AS TIE
    ,PO.VENDOR AS VNDR
    ,MIN(REC.RECEIVED_DATE) AS REC_DATE
    ,SUM(REC.QTY_REC) AS QTY_REC_TOTAL
    ,SUM(CASE WHEN REC.RECEIVED_DATE = PO.ORG_CANCEL_DATE THEN REC.QTY_REC ELSE 0 END ) AS REC_ON_TIME
    ,SUM(CASE WHEN REC.RECEIVED_DATE = (PO.ORG_CANCEL_DATE-1) THEN REC.QTY_REC ELSE 0 END ) AS REC_ON_TIME_1
    ,SUM(CASE WHEN REC.RECEIVED_DATE < (PO.ORG_CANCEL_DATE-1) THEN REC.QTY_REC ELSE 0 END ) AS REC_EARLY
    ,SUM(CASE WHEN REC.RECEIVED_DATE > PO.ORG_CANCEL_DATE THEN REC.QTY_REC ELSE 0 END ) AS REC_LATE

	FROM            
	(
		SELECT
        t1.po_nbr AS PO_NBR
        ,t2.line_nbr AS LINE
        ,t1.order_date AS PO_DATE
        ,t5.wm_yr_wk AS WMWK_CREATE
        ,t1.ship_date AS SHIP_DATE
        ,t1.cancel_date AS CANCEL_DATE
        ,t4.wm_yr_wk AS WMWK_CANCEL
        ,t1.original_cancel_dt AS ORG_CANCEL_DATE
        ,t6.day_of_wk AS DAY_ORG_CANCEL
        ,t6.wm_yr_wk AS WMWK_ORG_CANCEL
        ,t1.po_status AS PO_ST
        ,t1.ENTRY_COMP_INIT AS USR  
        ,t1.vendor_nbr AS VENDOR
        ,t1.VENDOR_NBR_DEPT AS VENDOR_DEPT
        ,t1.VENDOR_NBR_SEQ AS VENDOR_SEQ
        ,t1.vendor_name AS VENDOR_NAME
        ,t2.seg_status AS LINE_ST  
        ,t1.store_nbr AS DEST
        ,t3.category_nbr AS CAT
        ,t2.vendor_pack_qty AS VNPK
        ,t3.old_nbr AS ITEM_NBR
        ,t3.primary_desc AS ITEM_DESC
		,t1.event_desc AS EVENTO

        FROM
		wmt-edw-prod.MX_WC_VM.PURCHASE_ORDER  t1
        ,wmt-edw-prod.MX_WC_VM.PO_LINE t2
        ,wmt-edw-prod.MX_WC_VM.ITEM_DESC t3
        ,wmt-edw-prod.MX_WC_VM.CALENDAR_DAY t4
        ,wmt-edw-prod.MX_WC_VM.CALENDAR_DAY t5
        ,wmt-edw-prod.MX_WC_VM.CALENDAR_DAY t6
		WHERE
		t1.po_nbr=t2.po_nbr 
        AND t1.order_date=t2.order_date
        AND t2.item_nbr=t3.item_nbr
        AND t4.GREGORIAN_DATE =t1.cancel_date
        AND t5.GREGORIAN_DATE =t1.order_date                  
        AND t6.GREGORIAN_DATE =t1.original_cancel_dt            
        AND t1.sams_po_type IN (20)
        AND t2.whpk_order > 0
        AND t2.seg_status IN ('A') 
        AND t1.po_status='C'
		--AND t1.order_date>=DATE_ADD(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL -10 MONTH)
		--AND t1.order_date <=DATE_TRUNC(CURRENT_DATE(), MONTH) -1
		AND t1.cancel_date BETWEEN  '2023-01-01' AND CURRENT_DATE
        AND t3.category_nbr  IN (5,4,94,60,23,38,62,44,54,48,45,72,32,43,27,19,46,6,28,57,51,98,53,68,42,34,2,29,1,3,83,40,56,14,8,9,92,15,58,33,12,39,47,52,61,24,78,11,17,22,49,21,59,13,31,10,67,41,55)
            AND t1.store_nbr IN (4728,4792,4982,4983,6210,6241,6261,6288,6298,6523,8121,4791,4955,4981,6254,6258,6309,6398,6469,6583,6586,4948,4999,6234,6236,6249,6251,6300,6313,6470,6584,8240,4746,4801,4991,6213,6260,6293,6305,6468,6577,4727,4941,4950,4978,6204,6229,6275,6392,4790,4877,4985,6206,6223,6226,6242,6289,6294,6513,8118,4913,4944,4947,6215,6219,6237,6240,6279,6296,6307,6395,4805,4879,4961,4970,4975,4979,4986,6207,6282,6287,6391,4827,4936,4945,4977,6217,6244,6246,6252,6297,6397,6585,4901,4934,4946,4960,4984,6232,6243,6247,6265,6295,6534,4914,4989,6224,6225,6233,6264,6290,6390,6497,6314,8124,4910,4937,4949,4957,4973,6221,6283,6285,6393,6467,8127,4939,4954,4958,4968,4988,6205,6208,6211,6263,6394,6396,4862,4878,4938,6209,6218,6222,6277,6557,8122,4911,4969,4992,6212,6248,6274,6308,6563,6574,4832,4841,4935,4951,4972,4987,6227,6286,6576,6578,6320,6315) --Directas

        AND t1.store_nbr IN (7506,7505,6550,6388,6317,6238,5780,4995,4971,5885,7504,7500) --CEDIS

	) AS PO
	LEFT JOIN
	(
		SELECT 
        po_nbr
        ,line_nbr
        ,receiver_nbr
        ,received_date
        ,SUM(rcvd_qty) AS QTY_REC 
        FROM
        `wmt-edw-prod.MX_WC_VM.PO_LINE_RECEIVING`
		WHERE received_date BETWEEN  '2023-01-01' AND '2023-01-31'
		GROUP BY 1,2,3,4
	) AS REC  
	ON (PO.po_nbr = REC.po_nbr  AND PO.line = REC.line_nbr )                  
	GROUP BY
	1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22

) AS REC
LEFT JOIN                 
(SELECT
t1.po_nbr AS PO_NBR
,t2.line_nbr AS LINE
,t1.order_date AS PO_DATE
,t2.whpk_order AS QTY_ORD
,t2.whpk_qty_rcvd AS QTY_REC
,SUM((t2.net_vnpk_cost/NULLIF(t2.vendor_pack_qty,0))*t2.whpk_order) AS  COST_ORD
,SUM((t2.net_vnpk_cost/NULLIF(t2.vendor_pack_qty,0))*t2.whpk_qty_rcvd) AS COST_REC
FROM
wmt-edw-prod.MX_WC_VM.PURCHASE_ORDER  t1
,wmt-edw-prod.MX_WC_VM.PO_LINE t2
WHERE
t1.po_nbr=t2.po_nbr 
AND t1.order_date=t2.order_date
GROUP BY
1,2,3,4,5
) AS PO             
ON (PO.po_nbr = REC.po_nbr  AND PO.line = REC.line )
)

Group By 1,2,3,4,5,6

Order BY 2,3
