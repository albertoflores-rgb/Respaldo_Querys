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
    --b.upc_nbr AS UPC,
    --b.old_nbr AS ITEM_NBR,
    --b.item1_desc AS ITEM_DESC1,
    --b.item2_desc AS ITEM_DESC2,
    --b.signing_desc AS SIGNING_DESC,
    a.WM_YR_WK AS WM_WEEK,
    d.WM_MONTH AS WM_MONTH,
    d.FISCAL_YEAR AS YEAR,
    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE d.gregorian_date BETWEEN DATE '2023-01-01' AND  CURRENT_DATE
--AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,
                         --58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
AND c.order_dept_nbr IN (92,95,69,08,02,69)
AND CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) IN ('92-23','92-22','95-20','69-17','69-12','2-11','8-11','8-12','38-14','82-11','97-10','97-11','97-12')
--AND h.tribu IN ("SALUD Y BIENESTAR")
AND f.Formato IN ('SUPERCENTER')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19--,20,21,22,23,24

--Limit 12
