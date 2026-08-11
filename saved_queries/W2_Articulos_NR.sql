CREATE OR REPLACE TABLE wmt-edw-sandbox.OME_Promocional_Eventos.STOCK_NR_3845_UNIVERSIDAD AS

WITH ventas AS (
  SELECT 
    -- Clave
    b.upc_nbr AS UPC,
    --b.old_nbr AS ITEM_NBR,

    f.Banner AS FORMATO,
    f.Formato AS SUBFORMATO,
    f.Squad AS SQUAD_LEAD,
    f.Distrito AS DISTRITO,
    f.Tienda AS TIENDA,
    f.Det AS DET,
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
    c.TYPE_CODE AS TYPE_NBR,
    b.item1_desc AS ITEM_DESC1,
    b.item2_desc AS ITEM_DESC2,
    b.signing_desc AS SIGNING_DESC,
    CASE 
      WHEN c.TYPE_CODE IN ('03', '10', '43') THEN 'NO RESURTIBLE'
      ELSE 'RESURTIBLE'
    END AS TYPE_ITEM,

    -- Métricas de ventas
    SUM(
      a.sat_qty * d.sat_mult +
      a.sun_qty * d.sun_mult +
      a.mon_qty * d.mon_mult +
      a.tue_qty * d.tue_mult +
      a.wed_qty * d.wed_mult +
      a.thu_qty * d.thu_mult +
      a.fri_qty * d.fri_mult
    ) AS VENTA_PIEZAS,

    SUM((
      a.sat_qty * d.sat_mult +
      a.sun_qty * d.sun_mult +
      a.mon_qty * d.mon_mult +
      a.tue_qty * d.tue_mult +
      a.wed_qty * d.wed_mult +
      a.thu_qty * d.thu_mult +
      a.fri_qty * d.fri_mult
    ) * a.sell_price) AS VENTA_PESOS

  FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b 
    ON a.item_nbr = b.item_nbr
  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c 
    ON b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr
  INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d 
    ON a.wm_yr_wk = d.wm_yr_wk
  INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e 
    ON a.store_nbr = e.store_nbr
  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f 
    ON a.store_nbr = f.Det
  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g 
    ON b.dept_nbr = g.NumDepto 
  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h 
    ON CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) = h.NumCat 
    AND b.dept_nbr = h.NumDepto
  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i 
    ON b.Dept_nbr = i.NumDepto AND b.Fineline_nbr = i.NumFl

  WHERE d.gregorian_date BETWEEN DATE '2026-01-04' AND DATE '2026-02-03'
    AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
    --AND b.item_status_code IN ('A', '')
    AND c.TYPE_CODE IN ('03', '10', '43')
    AND f.Det IN ( 3845 ) -- 2076
    --AND h.Tribu IN ( 'MG')
    --AND f.Formato IN ('SUPERCENTER') --'WALMART EXPRESS'

  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
)
,

cobert_vta AS (
  SELECT 
    -- Clave
    b.upc_nbr AS UPC,
    --b.old_nbr AS ITEM_NBR,

    f.Banner AS FORMATO,
    f.Formato AS SUBFORMATO,
    f.Squad AS SQUAD_LEAD,
    f.Distrito AS DISTRITO,
    f.Tienda AS TIENDA,
    f.Det AS DET,
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
    c.TYPE_CODE AS TYPE_NBR,
    b.item1_desc AS ITEM_DESC1,
    b.item2_desc AS ITEM_DESC2,
    b.signing_desc AS SIGNING_DESC,
    CASE 
      WHEN c.TYPE_CODE IN ('03', '10', '43') THEN 'NO RESURTIBLE'
      ELSE 'RESURTIBLE'
    END AS TYPE_ITEM,

    -- Métricas de ventas
    SUM(
      a.sat_qty * d.sat_mult +
      a.sun_qty * d.sun_mult +
      a.mon_qty * d.mon_mult +
      a.tue_qty * d.tue_mult +
      a.wed_qty * d.wed_mult +
      a.thu_qty * d.thu_mult +
      a.fri_qty * d.fri_mult
    ) AS VENTA_PIEZAS,

    SUM((
      a.sat_qty * d.sat_mult +
      a.sun_qty * d.sun_mult +
      a.mon_qty * d.mon_mult +
      a.tue_qty * d.tue_mult +
      a.wed_qty * d.wed_mult +
      a.thu_qty * d.thu_mult +
      a.fri_qty * d.fri_mult
    ) * a.sell_price) AS VENTA_PESOS

  FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b 
    ON a.item_nbr = b.item_nbr
  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c 
    ON b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr
  INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d 
    ON a.wm_yr_wk = d.wm_yr_wk
  INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e 
    ON a.store_nbr = e.store_nbr
  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f 
    ON a.store_nbr = f.Det
  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g 
    ON b.dept_nbr = g.NumDepto 
  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h 
    ON CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) = h.NumCat
    AND b.dept_nbr = h.NumDepto
  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i 
    ON b.Dept_nbr = i.NumDepto AND b.Fineline_nbr = i.NumFl

  WHERE d.gregorian_date BETWEEN DATE '2025-02-01' AND DATE '2025-02-28'
    AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
    --AND b.item_status_code IN ('A')
    AND c.TYPE_CODE IN ('03', '10', '43')
    AND f.Det IN ( 3845 ) -- 2076
    --AND h.Tribu IN ( 'MG')
    --AND f.Formato IN ('SUPERCENTER') --'WALMART EXPRESS'

  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
)
,

inventario AS (
  SELECT 
    -- Clave
    --e.Det AS DET,
    b.upc_nbr AS UPC,
    e.Banner AS FORMATO,

    -- Dimensiones (tomadas de inventario)
    b.item1_desc AS ITEM_DESC1,
    b.item2_desc AS ITEM_DESC2,
    e.Formato AS SUBFORMATO,
    e.Squad AS SQUAD_LEAD,
    e.Distrito AS DISTRITO,
    e.Det AS DET,
    e.Tienda AS TIENDA,
    e.Type_Cluster AS TIPO_TIENDA,
    e.Nielsen AS NIELSEN, 
    e.Estado AS ESTADO,
    g.Tribu AS TRIBU,
    g.Squad AS SQUAD,
    b.Dept_nbr AS NUMDEPTO,
    f.NumDepartamento AS DEPARTAMENTO,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    g.NumCategoria AS CATEGORIA,
    b.Fineline_nbr AS NUMFL,
    h.NumFineline AS FINELINE,
    c.TYPE_CODE AS TYPE_NBR,
    b.item_status_code AS STATUS,
    b.old_nbr AS ITEM_NBR,
    b.signing_desc AS SIGNING_DESC,
    c.EFFECTIVE_DATE AS EFFECTIVE_DATE,
    CASE 
      WHEN c.TYPE_CODE IN ('03', '10', '43') THEN 'NO RESURTIBLE'
      ELSE 'RESURTIBLE'
    END AS TYPE_ITEM,

    -- Métricas de inventario
    SUM(a.on_hand_qty) AS OH_QTY,
    SUM(a.on_hand_qty * a.sell_rtl) AS OH_RTL,
    SUM(a.on_hand_qty * a.cost) AS OH_COST,
    SUM(a.in_transit_qty) AS IT_QTY,
    SUM(a.in_transit_qty * a.sell_rtl) AS IT_RTL,
    SUM(a.in_transit_qty * a.cost) AS IT_COST,
    SUM(a.in_warehouse_qty) AS IW_QTY,
    SUM(a.in_warehouse_qty * a.sell_rtl) AS IW_RTL,
    SUM(a.in_warehouse_qty * a.cost) AS IW_COST,
    SUM(a.on_order_qty) AS IO_QTY,
    SUM(a.on_order_qty * a.sell_rtl) AS IO_RTL,
    SUM(a.on_order_qty * a.cost) AS IO_COST,
    SUM(a.on_hand_qty + a.in_transit_qty + a.in_warehouse_qty + a.on_order_qty) as TTC_QTY,
    SUM((a.on_hand_qty + a.in_transit_qty + a.in_warehouse_qty + a.on_order_qty)*a.cost) as TTC_COST,
    SUM((a.on_hand_qty + a.in_transit_qty + a.in_warehouse_qty + a.on_order_qty)*a.sell_rtl) as TTC_RTL
    --COUNT(DISTINCT e.Det) AS NUMTIENDAS

  FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a

  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b 
    ON (a.item_nbr = b.old_nbr)

  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c 
    ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr)

  INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d 
    ON (a.store_nbr = d.store_nbr)

  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e 
    ON (a.store_nbr = e.Det)

  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f 
    ON (b.dept_nbr = f.NumDepto) 

  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g 
    ON CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) = g.NumCat
    AND b.dept_nbr = g.NumDepto

  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h 
    ON (b.Dept_nbr = h.NumDepto AND b.Fineline_nbr = h.NumFl)

  WHERE c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
    --AND b.item_status_code IN ('A')
    AND c.TYPE_CODE IN ('03', '10', '43')
    AND e.Det IN ( 3845)
    --AND g.Tribu IN ( 'MG')
    --AND e.Formato IN ('SUPERCENTER')  -- filtro de formato también en inventario 'WALMART EXPRESS'

  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25

  --HAVING SUM(a.on_hand_qty + a.in_transit_qty + a.in_warehouse_qty + a.on_order_qty) > 0
),

liquidaciones AS (
  SELECT 
    distinct Upc,
    Item,
    MD_State
  FROM wmt-edw-sandbox.W2_OME_DataHub.liquidaciones_activas_202605
  WHERE
    Formato IN ('SC')
    AND Determinante IN (3845)
    --AND ISC IN ('A')
),

GDM AS (
  SELECT 
    UPC,
    ITEM,
    EVENTO

  FROM wmt-edw-sandbox.OME_Promocional_Eventos.GDM_ENE01_FEB10_2026
)

SELECT
    -- Dimensiones (preferimos ventas; si no hay, tomamos inventario)
  --COALESCE(v.FORMATO, i.FORMATO) AS FORMATO,
  --COALESCE(v.SUBFORMATO, i.SUBFORMATO) AS SUBFORMATO,
  --COALESCE(v.SQUAD_LEAD, i.SQUAD_LEAD) AS SQUAD_LEAD,
  --COALESCE(v.DISTRITO, i.DISTRITO) AS DISTRITO,
  COALESCE(v.DET, i.DET, C.DET) AS DET,
  COALESCE(v.TIENDA, i.TIENDA, c.TIENDA) AS TIENDA,
  h.TRIBU AS TRIBU,
  h.SQUAD AS SQUAD,
  h.MEGA_SQUAD AS MEGA_SQUAD,
  COALESCE(v.NUMDEPTO, i.NUMDEPTO, c.NUMDEPTO) AS NUMDEPTO,
  COALESCE(v.DEPARTAMENTO, i.DEPARTAMENTO, c.DEPARTAMENTO) AS DEPARTAMENTO,
  CAST(COALESCE(v.NUMCAT, i.NUMCAT, c.NUMCAT) AS STRING) AS NUMCAT,
  COALESCE(v.CATEGORIA, i.CATEGORIA, c.CATEGORIA) AS CATEGORIA,
  COALESCE(v.NUMFL, i.NUMFL, c.NUMFL) AS NUMFL,
  COALESCE(v.FINELINE, i.FINELINE, c.FINELINE) AS FINELINE,
  COALESCE(v.UPC, i.UPC, c.UPC) AS UPC,
  --COALESCE(v.ITEM_NBR, i.ITEM_NBR) AS ITEM_NBR,
  COALESCE(v.ITEM_DESC1, i.ITEM_DESC1, c.ITEM_DESC1) AS ITEM_DESC1,
  COALESCE(v.TYPE_NBR, i.TYPE_NBR, c.TYPE_NBR) AS TYPE_NBR,
  i.TYPE_ITEM,
  i.STATUS,
  --COALESCE(v.ESTADO, i.ESTADO) AS ESTADO,
  --i.NUMTIENDAS AS ALCANCE,

  -- Métricas
  i.OH_QTY, 
  i.OH_RTL,
  i.OH_COST,
  i.IT_QTY,
  i.IW_QTY,
  i.IO_QTY,
  (i.OH_QTY + i.IT_QTY + i.IW_QTY + i.IO_QTY) AS TOTAL_QTY,
  (i.OH_RTL + i.IT_RTL + i.IW_RTL + i.IO_RTL) AS TOTAL_RTL,
  (i.OH_COST + i.IT_COST + i.IW_COST + i.IO_COST) AS TOTAL_COST,
  --CAST( CEIL((i.OH_QTY + i.IT_QTY + i.IW_QTY + i.IO_QTY) / (i.NUMTIENDAS)) AS int64) AS PROM_TIENDA,
  v.VENTA_PIEZAS AS VENTA_QTY_L4W,
  v.VENTA_PESOS AS VENTA_PESOS_L4W,
  --CEIL((v.VENTA_PIEZAS/28)/i.OH_QTY) AS DDV_OH,
  c.VENTA_PESOS AS VENTA_PESOS_ENE25,
  c.VENTA_PIEZAS AS VENTA_PIEZAS_ENE25,

  CASE 
    WHEN EXISTS (
      SELECT 1
      FROM liquidaciones l2
      WHERE l2.Upc  = COALESCE(v.UPC, i.UPC)
        --AND l2.Item = COALESCE(v.ITEM_NBR, i.ITEM_NBR)
    )
    THEN TRUE
    ELSE FALSE
  END AS LIQUIDACION,
  l2.MD_State AS NUM_LIQUIDACION,

  CASE 
    WHEN EXISTS (
      SELECT 1
      FROM GDM g2
      WHERE g2.UPC  = COALESCE(v.UPC, i.UPC)
        --AND l2.Item = COALESCE(v.ITEM_NBR, i.ITEM_NBR)
    )
    THEN ('GDM')
    ELSE ('NO')
  END AS GDM,
  i.EFFECTIVE_DATE,
  DATE_DIFF(CURRENT_DATE(), i.EFFECTIVE_DATE, DAY) AS DIAS_EN_TIENDA


FROM ventas v
FULL OUTER JOIN inventario i
  ON v.UPC = i.UPC
  AND v.DET = i.DET
FULL OUTER JOIN cobert_vta c
  ON v.UPC = c.UPC
  AND v.DET = c.DET
LEFT JOIN liquidaciones l2
  ON l2.Upc  = COALESCE(v.UPC, i.UPC)
LEFT JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h
  ON COALESCE(v.NUMDEPTO, i.NUMDEPTO, c.NUMDEPTO) = h.NUMDEPTO

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33
HAVING (i.OH_QTY + i.IT_QTY + i.IW_QTY + i.IO_QTY) > 0
ORDER BY 
  13