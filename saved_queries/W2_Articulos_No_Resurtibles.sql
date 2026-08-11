WITH ventas AS (
  SELECT 
    -- Clave
    b.upc_nbr AS UPC,
    b.old_nbr AS ITEM_NBR,

    -- Dimensiones (tomadas de ventas; si hubiera discrepancia con inventario, se resolverán por COALESCE más adelante)
    ANY_VALUE(f.Banner) AS FORMATO,
    ANY_VALUE(f.Formato) AS SUBFORMATO,
    ANY_VALUE(f.Squad) AS SQUAD_LEAD,
    ANY_VALUE(f.Distrito) AS DISTRITO,
    ANY_VALUE(f.Tienda) AS TIENDA,
    ANY_VALUE(f.Type_Cluster) AS TIPO_TIENDA,
    ANY_VALUE(f.Nielsen) AS NIELSEN, 
    ANY_VALUE(f.Estado) AS ESTADO,
    ANY_VALUE(h.Tribu) AS TRIBU,
    ANY_VALUE(h.Squad) AS SQUAD,
    ANY_VALUE(b.Dept_nbr) AS NUMDEPTO,
    ANY_VALUE(g.NumDepartamento) AS DEPARTAMENTO,
    ANY_VALUE(CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))) AS NUMCAT,
    ANY_VALUE(h.NumCategoria) AS CATEGORIA,
    ANY_VALUE(b.Fineline_nbr) AS NUMFL,
    ANY_VALUE(i.NumFineline) AS FINELINE,
    ANY_VALUE(c.TYPE_CODE) AS TYPE_NBR,
    ANY_VALUE(b.item1_desc) AS ITEM_DESC1,
    ANY_VALUE(b.item2_desc) AS ITEM_DESC2,
    ANY_VALUE(b.signing_desc) AS SIGNING_DESC,

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
  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i 
    ON b.Dept_nbr = i.NumDepto AND b.Fineline_nbr = i.NumFl

  WHERE d.gregorian_date BETWEEN DATE '2025-12-07' AND DATE '2026-01-04'
    AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
    AND b.item_status_code IN ('A')
    AND c.TYPE_CODE IN ('03', '10', '43')
    AND f.Det IN ( 3720)
    AND h.Tribu IN ( 'FOOD', 'SALUD Y BIENESTAR', 'MG')
    AND f.Formato IN ('SUPERCENTER', 'WALMART EXPRESS')

  GROUP BY b.upc_nbr, b.old_nbr
)
,

inventario AS (
  SELECT 
    -- Clave
    --e.Det AS DET,
    b.upc_nbr AS UPC,
    e.Banner AS FORMATO,

    -- Dimensiones (tomadas de inventario)
    ANY_VALUE(e.Formato) AS SUBFORMATO,
    ANY_VALUE(e.Squad) AS SQUAD_LEAD,
    ANY_VALUE(e.Distrito) AS DISTRITO,
    ANY_VALUE(e.Tienda) AS TIENDA,
    ANY_VALUE(e.Type_Cluster) AS TIPO_TIENDA,
    ANY_VALUE(e.Nielsen) AS NIELSEN, 
    ANY_VALUE(e.Estado) AS ESTADO,
    ANY_VALUE(g.Tribu) AS TRIBU,
    ANY_VALUE(g.Squad) AS SQUAD,
    ANY_VALUE(b.Dept_nbr) AS NUMDEPTO,
    ANY_VALUE(f.NumDepartamento) AS DEPARTAMENTO,
    ANY_VALUE(CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))) AS NUMCAT,
    ANY_VALUE(g.NumCategoria) AS CATEGORIA,
    ANY_VALUE(b.Fineline_nbr) AS NUMFL,
    ANY_VALUE(h.NumFineline) AS FINELINE,
    ANY_VALUE(c.TYPE_CODE) AS TYPE_NBR,
    ANY_VALUE(b.old_nbr) AS ITEM_NBR,
    ANY_VALUE(b.item1_desc) AS ITEM_DESC1,
    ANY_VALUE(b.item2_desc) AS ITEM_DESC2,
    ANY_VALUE(b.signing_desc) AS SIGNING_DESC,

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
    COUNT(DISTINCT e.Det) AS NUMTIENDAS

  FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a

  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b 
    ON a.item_nbr = b.old_nbr

  INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c 
    ON b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr

  INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d 
    ON a.store_nbr = d.store_nbr

  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e 
    ON a.store_nbr = e.Det

  INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f 
    ON b.dept_nbr = f.NumDepto 

  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g 
    ON CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2)) = g.NumCat

  LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h 
    ON b.Dept_nbr = h.NumDepto AND b.Fineline_nbr = h.NumFl

  WHERE c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
    AND b.item_status_code IN ('A')
    AND c.TYPE_CODE IN ('03', '10', '43')
    AND e.Det IN ( 3720)
    AND g.Tribu IN ( 'FOOD', 'SALUD Y BIENESTAR', 'MG')
    AND e.Formato IN ('SUPERCENTER', 'WALMART EXPRESS')  -- filtro de formato también en inventario

  GROUP BY e.Banner, b.upc_nbr
),

liquidaciones AS (
  SELECT 
    distinct Upc,
    Item
  FROM wmt-edw-sandbox.W2_OME_DataHub.liquidaciones_diciembre_sn51
  WHERE
    Formato IN ('SC')
    AND Resurtible IN ('No Resurtible')
)

SELECT
    -- Dimensiones (preferimos ventas; si no hay, tomamos inventario)
  COALESCE(v.FORMATO, i.FORMATO) AS FORMATO,
  COALESCE(v.SUBFORMATO, i.SUBFORMATO) AS SUBFORMATO,
  --COALESCE(v.SQUAD_LEAD, i.SQUAD_LEAD) AS SQUAD_LEAD,
  --COALESCE(v.DISTRITO, i.DISTRITO) AS DISTRITO,
  --COALESCE(v.DET, i.DET) AS DET,
  --COALESCE(v.TIENDA, i.TIENDA) AS TIENDA,
  COALESCE(v.TRIBU, i.TRIBU) AS TRIBU,
  COALESCE(v.SQUAD, i.SQUAD) AS SQUAD,
  COALESCE(v.NUMDEPTO, i.NUMDEPTO) AS NUMDEPTO,
  COALESCE(v.DEPARTAMENTO, i.DEPARTAMENTO) AS DEPARTAMENTO,
  CAST(COALESCE(v.NUMCAT, i.NUMCAT) AS STRING) AS NUMCAT,
  COALESCE(v.CATEGORIA, i.CATEGORIA) AS CATEGORIA,
  COALESCE(v.NUMFL, i.NUMFL) AS NUMFL,
  COALESCE(v.FINELINE, i.FINELINE) AS FINELINE,
  COALESCE(v.UPC, i.UPC) AS UPC,
  COALESCE(v.ITEM_NBR, i.ITEM_NBR) AS ITEM_NBR,
  COALESCE(v.ITEM_DESC1, i.ITEM_DESC1) AS ITEM_DESC1,
  COALESCE(v.TYPE_NBR, i.TYPE_NBR) AS TYPE_NBR,
  --COALESCE(v.ESTADO, i.ESTADO) AS ESTADO,
  i.NUMTIENDAS AS ALCANCE,

  -- Métricas
  i.OH_QTY, 
  i.OH_RTL,
  i.OH_COST,
  (i.OH_QTY + i.IT_QTY + i.IW_QTY + i.IO_QTY) AS TOTAL_QTY,
  (i.OH_RTL + i.IT_RTL + i.IW_RTL + i.IO_RTL) AS TOTAL_RTL,
  (i.OH_COST + i.IT_COST + i.IW_COST + i.IO_COST) AS TOTAL_COST,
  CAST( CEIL((i.OH_QTY + i.IT_QTY + i.IW_QTY + i.IO_QTY) / (i.NUMTIENDAS)) AS int64) AS PROM_TIENDA,
  v.VENTA_PIEZAS AS VENTA_QTY_L4W,
  v.VENTA_PESOS AS VENTA_PESOS_L4W,
  CASE 
    WHEN EXISTS( SELECT 11 FROM ventas AS v WHERE v.UPC = l.Upc AND v.ITEM_NBR = l.Item) THEN TRUE
    ELSE FALSE
END
  AS LIQUIDACION

FROM ventas v
FULL OUTER JOIN inventario i
  ON v.UPC = i.UPC
  AND v.ITEM_NBR = i.ITEM_NBR
FULL JOIN liquidaciones l
  ON v.UPC = l.Upc
  AND v.ITEM_NBR = l.Item

WHERE
  i.OH_QTY > 5

ORDER BY 
  11