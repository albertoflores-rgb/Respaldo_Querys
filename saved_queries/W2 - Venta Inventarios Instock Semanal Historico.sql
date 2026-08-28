SELECT 
                                            
    f.Formato AS FORMATO,
    f.Squad AS SQUAD_LEAD,
    f.Distrito AS DISTRITO,
    f.Det AS DET,
    f.Tienda AS TIENDA,
    f.Type_Cluster AS TIPO_TIENDA,
    f.Nielsen AS NIELSEN, 
    f.Estado AS ESTADO,
    h.Tribu AS TRIBU,
    h.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    g.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    h.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    b.upc_nbr AS UPC,
    b.old_nbr AS ITEM_NBR,
    b.item1_desc AS ITEM_DESC1,
    b.item2_desc AS ITEM_DESC2,
    b.signing_desc AS SIGNING_DESC,
    --d.GREGORIAN_DATE AS Fecha,
    a.WM_YR_WK AS WM_WEEK,
    --d.WM_MONTH AS WM_MONTH,
    --d.FISCAL_YEAR AS YEAR,
    eXTRACT(MONTH FROM d.gregorian_date) AS Month,
    EXTRACT(YEAR FROM d.gregorian_date ) AS Year,

    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_T,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_T,

    SUM(j.FRI_ON_HAND_QTY) AS OH_QTY,
    SUM(j.FRI_ON_HAND_QTY * j.RETAIL_AMT) AS OH_RTL,
    SUM(j.INSTOCK_IND) AS INSTOCK


FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
Left JoIN  wmt-edw-prod.MX_WM_VM.REPL_SKU_WKLY_INV j on (j.item_nbr = b.item_nbr and j.wm_yr_wk = d.wm_yr_wk and j.store_nbr = f.Det)
WHERE d.gregorian_date BETWEEN DATE '2024-01-01' AND  CURRENT_DATE
AND c.order_dept_nbr IN (46,40,69,8,2)
AND c.VENDOR_NBR IN ('316342')
AND CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) in ('40-27')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24