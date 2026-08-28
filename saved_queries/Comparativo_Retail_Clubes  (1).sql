WITH

cte_pos_diario AS (
  SELECT
    a.STORE_NBR,
    a.ITEM_NBR,
    d.gregorian_date,
    ( a.SAT_QTY * d.sat_mult + a.SUN_QTY * d.sun_mult
    + a.MON_QTY * d.mon_mult + a.TUE_QTY * d.tue_mult
    + a.WED_QTY * d.wed_mult + a.THU_QTY * d.thu_mult
    + a.FRI_QTY * d.fri_mult )                       AS piezas_dia,
    ( a.SAT_SALES_AMT * d.sat_mult + a.SUN_SALES_AMT * d.sun_mult
    + a.MON_SALES_AMT * d.mon_mult + a.TUE_SALES_AMT * d.tue_mult
    + a.WED_SALES_AMT * d.wed_mult + a.THU_SALES_AMT * d.thu_mult
    + a.FRI_SALES_AMT * d.fri_mult )                 AS pesos_dia
  FROM `wmt-edw-prod.MX_WC_VM.SKU_DLY_POS`        AS a
  INNER JOIN `wmt-edw-prod.MX_WM_VM.CALENDAR_DAY`  AS d ON a.WM_YR_WK = d.wm_yr_wk
  WHERE EXTRACT(YEAR FROM d.gregorian_date) IN (
    EXTRACT(YEAR FROM CURRENT_DATE),
    EXTRACT(YEAR FROM CURRENT_DATE) - 1
  )
)

Select
OLD_nbr,
Item_Desc,
UPC,
Departamento,
NUMCAT,
Categoria,
SUM(VENTA_PIEZAS_SC) AS PIEZAS_SC,
SUM(VENTA_PESOS_SC) AS PESOS_SC,
SUM(VENTA_PIEZAS_BA) AS PIEZAS_BA,
SUM(VENTA_PESOS_BA) AS PESOS_BA,
SUM(VENTA_PIEZAS_WE) AS PIEZAS_WE,
SUM(VENTA_PESOS_WE) AS PESOS_WE,
ITEM_NBR_1,
T2.ITEM_DESC_1,
T2.UPC_1,
T2.CAT_NBR,
T2.CAT_NOMBRE,
T2.SUBCAT_NBR,
T2.SUBCAT_NOMBRE,
sum(Venta_Pzas_SAMS_YTD),
sum(VENTA_SAMS_PESOS_YTD)




FROM
(
SELECT 
                                            

    b.Old_nbr AS Old_nbr,
    c.PRIMARY_DESC  AS Item_Desc,
    c.UPC AS UPC,
    g.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    h.NumCategoria AS CATEGORIA,
    --EXTRACT(YEAR FROM d.gregorian_date) AS ANO,
    --EXTRACT(MONTH FROM d.gregorian_date) AS MES,
    --a.WM_YR_WK AS WM_WEEK,



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
WHERE d.gregorian_date BETWEEN DATE '2026-01-01' AND CURRENT_DATE
--AND h.Tribu IN ("FOOD", "SALUD Y BIENESTAR")
AND e.STORE_NAME like ANY('BA%','SC%','WE%')


GROUP BY 1,2,3,4,5,6
 
)AS T1

RIGHT JOIN (

Select 

    b.Old_NBR                                       AS ITEM_NBR_1,
    b.PRIMARY_DESC                                  AS ITEM_DESC_1,
    b.SECONDARY_DESC                                AS ITEM_DESC_2,
    b.UPC                                           AS UPC_1,
    b.CATEGORY_NBR                                  AS CAT_NBR,
    cat.Categoria                                   AS CAT_NOMBRE,
    b.SUB_CATEGORY_NBR                              AS SUBCAT_NBR,
    cat.Sub_Categoria                               AS SUBCAT_NOMBRE,

    COALESCE(SUM(CASE WHEN EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.piezas_dia END), 0) AS Venta_Pzas_SAMS_YTD,
    COALESCE(SUM(CASE WHEN EXTRACT(YEAR FROM v.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE) THEN v.pesos_dia END), 0) AS VENTA_SAMS_PESOS_YTD,

     FROM cte_pos_diario v
  INNER JOIN `wmt-edw-prod.MX_WC_VM.ITEM_DESC` b ON v.ITEM_NBR = b.ITEM_NBR
  LEFT JOIN  `wmt-edw-sandbox.Black_Bird.Catalogo_Clubes` f ON v.STORE_NBR = f.CLUB_NBR
  LEFT JOIN  `wmt-edw-sandbox.Black_Bird.Catalogo_Cat_Subcat` cat
    ON  SAFE_CAST(cat.Categoria_NBR AS INT64) = b.CATEGORY_NBR
    AND SAFE_CAST(cat.Sub_Categoria_Code AS INT64) = b.SUB_CATEGORY_NBR
  GROUP BY
    1,2,3,4,5,6,7,8
) AS T2

ON (T1.UPC = T2.UPC_1) 

Group by 1,2,3,4,5,6,13,14,15,16,17,18,19





