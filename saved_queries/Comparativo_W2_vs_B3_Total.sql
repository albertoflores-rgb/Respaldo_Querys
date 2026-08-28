Select
TRIBU,
SQUAD,
NUMDEPTO,
DEPARTAMENTO,
NUMCAT,
CATEGORIA,
NUMFL,
FINELINE,
ANO,
MES,
--WM_WEEK,
SUM(VENTA_PIEZAS_SC) AS PIEZAS_SC,
SUM(VENTA_PESOS_SC) AS PESOS_SC,
SUM(CLIENTES_SC) AS CLIENTES_SC,
SUM(VENTA_PIEZAS_BA) AS PIEZAS_BA,
SUM(VENTA_PESOS_BA) AS PESOS_BA,
SUM(CLIENTES_BA) AS CLIENTES_BA,
SUM(VENTA_PIEZAS_WE) AS PIEZAS_WE,
SUM(VENTA_PESOS_WE) AS PESOS_WE,
SUM(CLIENTES_WE) AS CLIENTES_WE


FROM
(
SELECT 
                                            

    h.Tribu AS TRIBU,
    h.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    g.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    b.Fineline_nbr AS NUMFL,
    i.NumFineline AS FINELINE,
    h.NumCategoria AS CATEGORIA,
    EXTRACT(YEAR FROM d.gregorian_date) AS ANO,
    EXTRACT(MONTH FROM d.gregorian_date) AS MES,
    a.WM_YR_WK AS WM_WEEK,



    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_T,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_T,
    COALESCE(SUM(CASE WHEN (e.STORE_NAME like ('SC%')) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0) AS    VENTA_PIEZAS_SC,
    COALESCE(SUM(CASE WHEN (e.STORE_NAME like ('SC%')) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_SC,
    COALESCE(SUM(CASE WHEN (e.STORE_NAME like ('BA%')) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0) AS    VENTA_PIEZAS_BA,
    COALESCE(SUM(CASE WHEN (e.STORE_NAME like ('BA%')) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_BA,
    COALESCE(SUM(CASE WHEN (e.STORE_NAME like ('WE%')) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0) AS    VENTA_PIEZAS_WE,
    COALESCE(SUM(CASE WHEN (e.STORE_NAME like ('WE%')) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_WE,



FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
--INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.SUPPLY_CHAIN_DB j ON (j.UPC_CODE = c.UPC AND e.store_nbr = j.STORE_NBR AND d.gregorian_date = j.Fecha_Act)
WHERE d.gregorian_date BETWEEN DATE '2023-01-01' AND CURRENT_DATE
AND h.Tribu IN ("FOOD", "SALUD Y BIENESTAR")
AND e.STORE_NAME like ANY('BA%','SC%','WE%')


GROUP BY 1,2,3,4,5,6,7,8,9,10,11--,12,13,14,15,16,17,18,19,20,21,22,23,24,25

) AS T1

LEFT JOIN (

SELECT

    i.Tribu AS TRIBU2,
    i.Squad AS SQUAD2,
    c.Dept_nbr AS NUMDEPTO2,
    h.NumDepartamento AS DEPARTAMENTO2,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT2,
    i.NumCategoria AS CATEGORIA2,
    c.Fineline_nbr AS NUMFL2,
    j.NumFineline AS FINELINE2,
    EXTRACT(YEAR FROM e.gregorian_date) AS ANO2,
    EXTRACT(MONTH FROM e.gregorian_date) AS MES2,

    COALESCE(COUNT(DISTINCT(CASE WHEN (f.STORE_NAME like ('SC%')) THEN a.store_nbr||''||a.visit_nbr END)),0) AS CLIENTES_SC,
    COALESCE(COUNT(DISTINCT(CASE WHEN (f.STORE_NAME like ('BA%')) THEN a.store_nbr||''||a.visit_nbr END)),0) AS CLIENTES_BA,
    COALESCE(COUNT(DISTINCT(CASE WHEN (f.STORE_NAME like ('WE%')) THEN a.store_nbr||''||a.visit_nbr END)),0) AS CLIENTES_WE,

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
--INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2023-01-01' AND CURRENT_DATE
AND i.Tribu IN ("FOOD", "SALUD Y BIENESTAR")
AND f.STORE_NAME like ANY('BA%','SC%','WE%')
GROUP BY 1,2,3,4,5,6,7,8,9,10 ) AS T2

ON (T1.TRIBU = T2.TRIBU2
    AND T1.SQUAD = T2.SQUAD2
    AND T1.NUMDEPTO = T2.NUMDEPTO2
    AND T1.DEPARTAMENTO = T2.DEPARTAMENTO2
    AND T1.NUMCAT = T2.NUMCAT2
    AND T1.NUMFL = T2.NUMFL2
    AND T1.ANO = T2.ANO2
    AND T1.MES = T2.MES2)

GROUP BY 1,2,3,4,5,6,7,8,9,10