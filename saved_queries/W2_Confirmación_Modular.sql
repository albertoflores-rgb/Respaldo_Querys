Select
  T1.MODULAR_PLAN_ID,
  T1.MODULAR_DEPT_NBR,
  T1.MODULAR_CATG_NBR,
  T1.MODULAR_PLAN_TITLE,
  T1.MODULAR_EFF_DATE,
  T1.MOD_ITEM_DISC_DATE,
  T1.MODULAR_DIS_DATE,
  T1.DRWG_TEMPLATE_NBR,
  T1.STORE_NBR,
  T1.Formato AS FORMATO,
  T1.Tienda1 AS TIENDA1,
  T1.TIPO_TIENDA1 AS TIPO_TIENDA1,
  T1.TYPE_TIENDA1 AS TYPE_TIENDA1,
  T1.Nielsen1 AS NIELSEN1,
  T1.Estado1 AS ESTADO1,

  T1.MODULAR_UPC_NBR,
  T1.PRIME_OLD_NBR,
  T1.MODULAR_CATG_DESC,
  T1.BASE_UNIT_RTL_AMT,
  T1.SELLING_UNIT_QTY,

  T1.ITEM_DESC1 AS ITEM_DESC1,
  T1.ITEM_DESC2 AS ITEM_DESC2,
  T1.TYPE AS TYPE,

  T1.STORE_NBR AS STORE_NBR_CNFRM,
  T1.STATUS_CODE,

  T1.CONFIRMATION_DATE,

  T1.MODULAR_SECT_NBR,
  T1.NUMBER_OF_FACINGS,
  T1.MAX_STOCK_QTY,
  T1.SEQUENCE_NBR,
  T1.EFFECTIVE_DATE,
  SUM(VENTA_PIEZAS_YTD) AS Ventas_QTY,
  SUM(VENTA_PESOS_YTD) AS Ventas_Pesos,
  SUM(COSTO_YTD) AS Ventas_Costo,
  SUM(T2.OH_QTY) AS OH_QTY,
    SUM(OH_RTL) AS OH_RTL,
    SUM(OH_COST) AS OH_COST,
    SUM(IT_QTY) AS IT_QTY,
    SUM(IT_RTL) AS IT_RTL,
    SUM(IT_COST) AS IT_COST,
    SUM(IW_QTY) AS IW_QTY,
    SUM(IW_RTL) AS IW_RTL,
    SUM(IW_COST) AS IW_COST,
    SUM(IO_QTY) AS IO_QTY,
    SUM(IO_RTL) AS IO_RTL,
    SUM(IO_COST) AS IO_COST
FROM (

SELECT
  a.MODULAR_PLAN_ID,
  a.MODULAR_DEPT_NBR,
  a.MODULAR_CATG_NBR,
  a.MODULAR_PLAN_TITLE,
  a.MODULAR_EFF_DATE,
  a.MOD_ITEM_DISC_DATE,
  a.MODULAR_DIS_DATE,
  a.DRWG_TEMPLATE_NBR,
  g.STORE_NBR,
  e.Formato AS FORMATO,
  e.Tienda AS TIENDA1,
  e.Type_Cluster AS TIPO_TIENDA1,
  e.TYPE_TIENDA AS TYPE_TIENDA1,
  e.Nielsen AS NIELSEN1,
  e.Estado AS ESTADO1,

  b.MODULAR_UPC_NBR,
  b.PRIME_OLD_NBR,
  b.MODULAR_CATG_DESC,
  b.BASE_UNIT_RTL_AMT,
  b.SELLING_UNIT_QTY,

  z.PRIMARY_DESC AS ITEM_DESC1,
  z.SECONDARY_DESC AS ITEM_DESC2,
  z.TYPE_CODE AS TYPE,

  c.STORE_NBR AS STORE_NBR_CNFRM,
  c.STATUS_CODE,

  d.CONFIRMATION_DATE,

  f.MODULAR_SECT_NBR,
  f.NUMBER_OF_FACINGS,
  f.MAX_STOCK_QTY,
  f.SEQUENCE_NBR,
  f.EFFECTIVE_DATE




FROM wmt-edw-prod.MX_WM_VM.MODULAR_PLAN a
Inner JOIN wmt-edw-prod.MX_WM_VM.MODULAR_STORE g ON (a.MODULAR_PLAN_ID = g.MODULAR_PLAN_ID)
LEFT JOIN wmt-edw-prod.MX_WM_VM.MODULAR_PLAN_UPC b ON (a.MODULAR_PLAN_ID = b.MODULAR_PLAN_ID AND g.MODULAR_PLAN_ID = b.MODULAR_PLAN_ID)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC z ON (b.PRIME_OLD_NBR = z.OLD_NBR)
LEFT JOIN wmt-edw-prod.MX_WM_VM.MODULAR_STR_CNFRM c ON (a.MODULAR_PLAN_ID = c.MODULAR_PLAN_ID)
LEFT JOIN wmt-edw-prod.MX_WM_VM.MODULAR_STORE_CONF d ON (a.MODULAR_PLAN_ID = d.MODULAR_PLAN_ID AND c.STORE_NBR = d.STORE_NBR)
LEFT JOIN wmt-edw-prod.MX_WM_VM.MODULAR_LOCATION f ON (z.item_NBR = f.ITEM_NBR AND f.DRWG_TEMPLATE_NBR = a.DRWG_TEMPLATE_NBR)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (g.store_nbr = e.Det)

WHERE --a.MODULAR_DEPT_NBR IN (95)
--AND a.MODULAR_CATG_NBR IN (1200)
--AND MODULAR_UPC_NBR IN (750100333652)
--AND e.NIELSEN IN ('VALLE DE MÉXICO')
--AND a.MODULAR_PLAN_TITLE LIKE ("%4%")
--AND e.Tienda LIKE ("%ORIENTE%")
--a.MODULAR_PLAN_ID IN (5630154)
--AND EXTRACT(YEAR FROM a.MODULAR_EFF_DATE) <= EXTRACT(YEAR FROM CURRENT_DATE)
--AND a.DRWG_TEMPLATE_NBR IN (2344)
g.STORE_NBR IN (4120)


GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31

ORDER BY a.MODULAR_EFF_DATE DESC,a.MODULAR_CATG_NBR ASC ) AS T1


LEFT JOIN
(
  SELECT 
                                            
    f.Formato AS FORMATO,
    f.Squad AS SQUAD_LEAD,
    f.Distrito AS DISTRITO,
    f.Det AS DET,
    f.Tienda AS TIENDA,
    f.Type_Cluster AS TIPO_TIENDA,
    f.TYPE_TIENDA AS SEGMENTO,
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
    C.Type_Code AS TIPO_ITEM,
    c.STATUS_CODE AS STATUS_CODE,
    --j.COST AS Costo_Unitario,
    --a.WM_YR_WK AS WM_WEEK,
    --d.WM_MONTH AS WM_MONTH,
    --d.FISCAL_YEAR AS YEAR,

    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_YTD,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_YTD,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * j.Cost) AS COSTO_YTD,
    --COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = EXTRACT(MONTH FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0) AS VENTA_PIEZAS_MTD,
    --COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = EXTRACT(MONTH FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_MTD,
    --COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = EXTRACT(MONTH FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * j.COST) END),0) AS COSTO_MTD,
    SUM(j.on_hand_qty) AS OH_QTY,
    SUM(j.on_hand_qty * j.sell_rtl) AS OH_RTL,
    SUM(j.on_hand_qty * j.cost) AS OH_COST,
    SUM(j.in_transit_qty) AS IT_QTY,
    SUM(j.in_transit_qty * j.sell_rtl) AS IT_RTL,
    SUM(j.in_transit_qty * j.cost) AS IT_COST,
    SUM(j.in_warehouse_qty) AS IW_QTY,
    SUM(j.in_warehouse_qty * j.sell_rtl) AS IW_RTL,
    SUM(j.in_warehouse_qty * j.cost) AS IW_COST,
    SUM(j.on_order_qty) AS IO_QTY,
    SUM(j.on_order_qty * j.sell_rtl) AS IO_RTL,
    SUM(j.on_order_qty * j.cost) AS IO_COST,
    COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_CLUSTER = "GENERAL" )THEN f.DET||''||b.UPC_nbr END)),0) AS Tiendas_GENERAL,
    COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_CLUSTER = "PREMIUM" )THEN f.DET||''||b.UPC_nbr END)),0) AS Tiendas_PREMIUM,
    COUNT(DISTINCT(f.DET||''||b.UPC_nbr)) AS Alcance_Total,
    COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_TIENDA = "PLAYA LOCAL/BALNEARIOS" )THEN f.DET||''||b.UPC_nbr END)),0) AS ALTA_PLAYA,
    COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_TIENDA = "TURISMO EXTRANJERO" )THEN f.DET||''||b.UPC_nbr END)),0) AS ALTA_TURISMO,
    COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_TIENDA = "TIPO DEPARTAMENTAL" )THEN f.DET||''||b.UPC_nbr END)),0) AS ALTA_DEPARTAMENTAL



FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
left JOIN wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT j ON (j.item_nbr = c.old_nbr AND j.store_nbr = a.store_nbr)

WHERE d.gregorian_date BETWEEN DATE '2025-10-01' AND  CURRENT_DATE
--AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,
                         --58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
--AND c.order_dept_nbr IN (46,40,69,28,38,26,8,2)
--AND h.tribu IN ("SALUD Y BIENESTAR","MG","FOOD")
AND f.Det IN(4720)
AND f.Formato IN ('SUPERCENTER')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24) AS T2

ON(T1.store_nbr = T2.DET
  AND T1.PRIME_OLD_NBR = T2.ITEM_NBR)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
