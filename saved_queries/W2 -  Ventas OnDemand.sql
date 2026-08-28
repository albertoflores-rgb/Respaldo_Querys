select
case when z.align_sub_division_nbr='D' then 'WME' when z.align_sub_division_nbr='E' then 'WM' end  as formato,
--c.VISIT_NBR
c.STORE_NBR,
EXTRACT( Month FROM CAST(c.visit_date AS DATE)) AS mes,
EXTRACT( Year FROM CAST(c.visit_date AS DATE)) AS Anio,
--c.visit_date,
--,c.TRANSACTION_NBR
--,T.TC_NBR AS TC
--,c.REGISTER_NBR
--,c.OPERATOR_NBR
b.ACCT_DEPT_NBR
,SUBSTR (b.FINELINE,1,2) AS CATG_NBR
,ACCT_DEPT_NBR||SUBSTR (b.FINELINE,1,2) AS CATG_NBR2
--,b.FINELINE
,b.Vendor_nbr
--,b.Vendor_nbr_dept
---,b.Vendor_nbr_fineline
,b.vendor_name
,b.UPC
--,a.SCAN_ID
,b.ITEM_NBR
,b.OLD_NBR
--,b.STATUS_CODE
---,b.TYPE_CODE
---,b.PLU_NBR
,b.PRIMARY_DESC
,b.SIGNING_DESC
---,c.TOT_VISIT_AMT
---,c.Tot_retail_price

--,c.TOT_UNIT_COST
,SUM (a.UNIT_QTY) AS piezas
,SUM (a.RETAIL_PRICE) AS Venta_neta
 
FROM    
 
  wmt-edw-prod.MX_WM_MB_VM.VISIT c,
  wmt-edw-prod.MX_WM_MB_VM.SCAN a,
  wmt-edw-prod.MX_WM_VM.ITEM_DESC b,
(
    SELECT
    z.visit_nbr
    ,z.Store_nbr
    ,z.visit_date
    ,t.align_sub_division_nbr
    FROM    
    wmt-edw-prod.MX_WM_MB_VM.SCAN z,
    wmt-edw-prod.MX_WM_VM.STORE_INFO t
   
    WHERE
  z.STORE_NBR = t.STORE_NBR
  and
  z.visit_date   BETWEEN  "2026-01-01" AND Current_Date
  and
  t.align_sub_division_nbr IN("D","E")
    AND      
(z.scan_id IN (47133610)  OR z.scan_id IN (51995709))
 
    GROUP BY z.visit_nbr
    ,z.Store_nbr
    ,z.visit_date
    ,t.align_sub_division_nbr
 ) AS z  
    ,wmt-edw-prod.MX_WM_MB_VM.STORE_TRANSACTION T
 
WHERE
b.item_nbr = a.SCAN_ID
                AND       c.visit_nbr = a.visit_nbr
                AND       c.store_nbr = a.Store_nbr
                AND       c.visit_date = a.visit_date
  AND a.visit_nbr = z.visit_nbr
  AND a.Store_nbr = z.Store_nbr
  AND a.visit_date = z.visit_date
 
             AND C.VISIT_NBR=T.VISIT_NBR
             AND C.VISIT_DATE=T.VISIT_DATE
             AND c.store_nbr = T.Store_nbr
             --AND T.PURCHASE_STORE_NBR=0
           
 
                --AND a.visit_nbr||a.Store_nbr||a.visit_date IN
 
--AND ACCT_DEPT_NBR||SUBSTR (b.FINELINE,1,2) NOT IN ('9922')
--AND b.Vendor_nbr IN ('067742')
--and ACCT_DEPT_NBR in (4,13)----###QUITANDO LOS GUIONES ANTES DE "AND"PODEMO ACTIVAR EL FILTRO POR DEPTO###
--AND ACCT_DEPT_NBR||SUBSTR (b.FINELINE,1,2) IN ('4610','1311','1312') ## Categoria
GROUP  BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14--,15,16,17,18,19,20,21,22,23,24,25,26,27