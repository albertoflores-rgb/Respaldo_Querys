DECLARE _M1_SUBFMT_1 ARRAY <STRING> ;
DECLARE _M1_NUMDEPTO_1 ARRAY <INT64> ;
DECLARE _M1_NUMCAT_1 ARRAY <STRING> ;
DECLARE _M1_UPC_NBR_1 ARRAY <INT64> ;
DECLARE _M1_UPC_NBR_2 ARRAY <INT64> ;
DECLARE _M1_ITEM_NBR_1 ARRAY <INT64> ;
DECLARE _M1_ITEM_NBR_2 ARRAY <INT64> ;



-- FECHAS
DECLARE _M1_FECHA_INICIO_TY DATE DEFAULT '2026-04-22' ;
DECLARE _M1_FECHA_FIN_TY DATE DEFAULT '2026-07-02' ;
DECLARE _M1_FECHA_INICIO_LY DATE DEFAULT '2025-07-03' ;
DECLARE _M1_FECHA_FIN_LY DATE DEFAULT '2025-08-22' ;

SET _M1_FECHA_INICIO_TY = DATE '2026-04-22' ;
SET _M1_FECHA_FIN_TY = DATE '2026-07-02' ;
SET _M1_FECHA_INICIO_LY = DATE '2025-07-03' ;
SET _M1_FECHA_FIN_LY = DATE_ADD (DATE '2025-07-03', INTERVAL (DATE_DIFF (CURRENT_DATE , DATE '2026-04-22' , DAY) -1 ) DAY);

--DECLARE _M1_FECHA_FIN_LY DATE DEFAULT '2025-08-13' ;

-- FILTROS
SET _M1_SUBFMT_1 = ['SUPERCENTER'] ;
SET _M1_NUMDEPTO_1 = [8];
--SET _M1_UPC_NBR_1 = [ ; -- UPC LY

-- QUERY

SELECT

  a.TRAIT AS SEL_STORE_TRAIT,
  a.NUMDEPTO AS ACCT_DEPT_NBR,
  a.DEPARTAMENTO AS DEPT_DESC,
  a.DET AS STORE_NBR,
  a.TIENDA AS STORE_NAME,
  a.NMCAT AS CATEGORY_NBR_INTL,
  a.NUMFL AS FINELINE,
  a.FINELINE AS FINELINE_DESC,
  a.UPC AS UPC,
  a.ITEM_NBR AS ITEM_NBR,
  0 AS ITEM_FLAGS,
  a.ITEM_DESC1 AS ITEM_DESC_1,
  a.ITEM_STATUS AS ITEM_STATUS_CODE,
  CAST(a.ITEM_TYPE AS INT64) AS ITEM_TYPE,
  a.VENTA_PIEZAS_TY AS RANGE_1_POS_QTY,
  a.VENTA_PESOS_TY AS RANGE_1_POS_SALES,
  a.OH_QTY AS RANGE_1_CURR_STR_ON_HAND_QTY,
  a.OH_COST AS RANGE_1_CURR_STR_ON_HAND_COST,
  a.OH_RTL AS RANGE_1_CURR_STR_ON_HAND_RETAIL,
  a.IT_QTY AS RANGE_1_CURR_STR_IN_WHSE_QTY,
  a.IT_COST AS RANGE_1_CURR_STR_IN_WHSE_COST,
  a.IT_RTL AS RANGE_1_CURR_STR_IN_WHSE_RETAIL,
  a.IW_QTY AS RANGE_1_CURR_STR_IN_TRANSIT_QTY,
  a.IW_COST AS RANGE_1_CURR_STR_IN_TRANSIT_COST,
  a.IW_RTL AS RANGE_1_CURR_STR_IN_TRANSIT_RETAIL,
  a.IO_QTY AS RANGE_1_CURR_STR_ON_ORDER_QTY,
  a.IO_COST AS RANGE_1_CURR_STR_ON_ORDER_COST,
  a.IO_RTL AS RANGE_1_CURR_STR_ON_ORDER_RETAIL,
  a.NET_SHIP_QTY_TY AS RANGE_1_NET_SHIP_QTY,
  a.NET_SHIP_COST_TY AS RANGE_1_NET_SHIPS_COST,
  a.NET_SHIP_RETAIL_TY AS RANGE_1_NET_SHIP_RETAIL,
  a.VENTA_PIEZAS_LY AS RANGE_2_POS_QTY,
  a.VENTA_PESOS_LY AS RANGE_2_POS_SALES,
  a.OH_QTY_LY AS RANGE_2_CURR_STR_ON_HAND_QTY,
  a.OH_COST_LY AS RANGE_2_CURR_STR_ON_HAND_COST,
  a.OH_RTL_LY AS RANGE_2_CURR_STR_ON_HAND_RETAIL,
  0 AS RANGE_2_CURR_STR_IN_WHSE_QTY,
  0 AS RANGE_2_CURR_STR_IN_WHSE_COST,
  0 AS RANGE_2_CURR_STR_IN_WHSE_RETAIL,
  0 AS RANGE_2_CURR_STR_IN_TRANSIT_QTY,
  0 AS RANGE_2_CURR_STR_IN_TRANSIT_COST,
  0 AS RANGE_2_CURR_STR_IN_TRANSIT_RETAIL,
  0 AS RANGE_2_CURR_STR_ON_ORDER_QTY,
  0 AS RANGE_2_CURR_STR_ON_ORDER_COST,
  0 AS RANGE_2_CURR_STR_ON_ORDER_RETAIL,
  a.NET_SHIP_QTY_LY AS RANGE_2_NET_SHIP_QTY,
  a.NET_SHIP_COST_LY AS RANGE_2_NET_SHIPS_COST,
  a.NET_SHIP_RETAIL_LY AS RANGE_2_NET_SHIP_RETAIL,


FROM(

  SELECT

    CASE WHEN a.SUBFORMATO = 'SUPERCENTER' THEN 297 WHEN a.SUBFORMATO = 'WALMART EXPRESS' THEN 11 ELSE 0 END AS TRAIT,
    a.SUBFORMATO,
    a.SQUAD_LEAD,
    a.DISTRITO,
    a.DET,
    a.TIENDA,
    a.TIPO_TIENDA,
    a.NIELSEN, 
    a.ESTADO,
    a.TRIBU,
    a.SQUAD,
    a.NUMDEPTO,
    a.DEPARTAMENTO,
    a.NMCAT,
    a.NUMCAT,
    a.CATEGORIA,
    a.NUMFL,
    a.FINELINE,
    a.UPC,
    a.ITEM_NBR,
    a.ITEM_TYPE,
    a.ITEM_STATUS,
    a.ITEM_DESC1,
    a.ITEM_DESC2,
    a.SIGNING_DESC,

    SUM(a.VENTA_COSTO_TY) AS VENTA_COSTO_TY,
    SUM(a.VENTA_PIEZAS_TY) AS VENTA_PIEZAS_TY,
    SUM(a.VENTA_PESOS_TY) AS VENTA_PESOS_TY,
    SUM(a.VENTA_COSTO_LY) AS VENTA_COSTO_LY,
    SUM(a.VENTA_PIEZAS_LY) AS VENTA_PIEZAS_LY,
    SUM(a.VENTA_PESOS_LY) AS VENTA_PESOS_LY,
    SUM(a.CLIENTES_TY) AS CLIENTES_TY,
    SUM(a.CLIENTES_LY) AS CLIENTES_LY,
    SUM(a.COMBINACIONES) AS COMBINACIONES,
    SUM(a.FALTANTES_OH) AS FALTANTES_OH, 
    SUM(a.FALTANTES_IT) AS FALTANTES_IT, 
    SUM(a.FALTANTES_IW) AS FALTANTES_IW, 
    SUM(a.FALTANTES_IO) AS FALTANTES_IO,
    SUM(a.OH_QTY) AS OH_QTY,
    SUM(a.OH_RTL) AS OH_RTL,
    SUM(a.OH_COST) AS OH_COST,
    SUM(a.IT_QTY) AS IT_QTY,
    SUM(a.IT_RTL) AS IT_RTL,
    SUM(a.IT_COST) AS IT_COST,
    SUM(a.IW_QTY) AS IW_QTY,
    SUM(a.IW_RTL) AS IW_RTL,
    SUM(a.IW_COST) AS IW_COST,
    SUM(a.IO_QTY) AS IO_QTY,
    SUM(a.IO_RTL) AS IO_RTL,
    SUM(a.IO_COST) AS IO_COST,
    SUM(a.NUMTIENDAS) AS NUMTIENDAS,
    SUM(a.PACKS_ORD) AS PACKS_ORD,
    SUM(a.PACKS_REC) AS PACKS_REC,

    SUM(a.OH_QTY_LY) AS OH_QTY_LY,
    SUM(a.OH_RTL_LY) AS OH_RTL_LY,
    SUM(a.OH_COST_LY) AS OH_COST_LY,
    SUM(a.NUMTIENDAS_LY) AS NUMTIENDAS_LY,

    SUM(a.NET_SHIP_QTY_TY) AS NET_SHIP_QTY_TY,
    SUM(a.NET_SHIP_COST_TY) AS NET_SHIP_COST_TY,
    SUM(a.NET_SHIP_RETAIL_TY) AS NET_SHIP_RETAIL_TY,
    SUM(a.NET_SHIP_QTY_LY) AS NET_SHIP_QTY_LY,
    SUM(a.NET_SHIP_COST_LY) AS NET_SHIP_COST_LY,
    SUM(a.NET_SHIP_RETAIL_LY) AS NET_SHIP_RETAIL_LY,

  FROM(

    SELECT

      a.SUBFORMATO,
      a.SQUAD_LEAD,
      a.DISTRITO,
      a.DET,
      a.TIENDA,
      a.TIPO_TIENDA,
      a.NIELSEN, 
      a.ESTADO,
      a.TRIBU,
      a.SQUAD,
      a.NUMDEPTO,
      a.DEPARTAMENTO,
      a.NMCAT,
      a.NUMCAT,
      a.CATEGORIA,
      a.NUMFL,
      a.FINELINE,
      a.UPC,
      a.ITEM_NBR,
      a.ITEM_TYPE,
      a.ITEM_STATUS,
      a.ITEM_DESC1,
      a.ITEM_DESC2,
      a.SIGNING_DESC,

      SUM(a.VENTA_COSTO) AS VENTA_COSTO_TY,
      SUM(a.VENTA_PIEZAS) AS VENTA_PIEZAS_TY,
      SUM(a.VENTA_PESOS) AS VENTA_PESOS_TY,
      SUM(0) AS VENTA_COSTO_LY,
      SUM(0) AS VENTA_PIEZAS_LY,
      SUM(0) AS VENTA_PESOS_LY,
      SUM(0) AS CLIENTES_TY,
      SUM(0) AS CLIENTES_LY,
      SUM(0) AS COMBINACIONES,
      SUM(0) AS FALTANTES_OH, 
      SUM(0) AS FALTANTES_IT, 
      SUM(0) AS FALTANTES_IW, 
      SUM(0) AS FALTANTES_IO,
      SUM(0) AS OH_QTY,
      SUM(0) AS OH_RTL,
      SUM(0) AS OH_COST,
      SUM(0) AS IT_QTY,
      SUM(0) AS IT_RTL,
      SUM(0) AS IT_COST,
      SUM(0) AS IW_QTY,
      SUM(0) AS IW_RTL,
      SUM(0) AS IW_COST,
      SUM(0) AS IO_QTY,
      SUM(0) AS IO_RTL,
      SUM(0) AS IO_COST,
      SUM(0) AS NUMTIENDAS,
      SUM(0) AS PACKS_ORD,
      SUM(0) AS PACKS_REC,

      SUM(0) AS OH_QTY_LY,
      SUM(0) AS OH_RTL_LY,
      SUM(0) AS OH_COST_LY,
      SUM(0) AS NUMTIENDAS_LY,

      SUM(0) AS NET_SHIP_QTY_TY,
      SUM(0) AS NET_SHIP_COST_TY,
      SUM(0) AS NET_SHIP_RETAIL_TY,
      SUM(0) AS NET_SHIP_QTY_LY,
      SUM(0) AS NET_SHIP_COST_LY,
      SUM(0) AS NET_SHIP_RETAIL_LY,

      SUM(0) AS BP_VENTA_PESOS,
      SUM(0) AS BP_VENTA_PIEZAS,
      SUM(0) AS BP_ST,
      SUM(0) AS BP_OP_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PIEZAS,
      SUM(0) AS FCST_ST,
      SUM(0) AS PG_FACTOR,
      SUM(0) AS PG_VENTAS,

    FROM(

      SELECT

          f.Formato AS SUBFORMATO,
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
          CAST(SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2) AS INT64) AS NMCAT,
          CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
          h.NumCategoria AS CATEGORIA,
          b.Fineline_nbr AS NUMFL,
          i.NumFineline AS FINELINE,
          b.upc_nbr AS UPC,
          b.old_nbr AS ITEM_NBR,
          c.type_code AS ITEM_TYPE,
          c.status_code AS ITEM_STATUS,
          b.item1_desc AS ITEM_DESC1,
          b.item2_desc AS ITEM_DESC2,
          b.signing_desc AS SIGNING_DESC,

          SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * c.cost) AS VENTA_COSTO,
          SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS,
          SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS,

        FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS_HIST a
        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
        INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
        INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
        INNER JOIN wmt-edw-sandbox.c0v05nw_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
        INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
        LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
        LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto AND b.Fineline_nbr=i.NumFl)
        WHERE d.gregorian_date BETWEEN _M1_FECHA_INICIO_TY AND _M1_FECHA_FIN_TY
        AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
        AND f.Formato IN UNNEST(_M1_SUBFMT_1)
        AND b.Dept_nbr IN UNNEST(_M1_NUMDEPTO_1)
        --AND NUMCAT IN UNNEST(_M1_NUMCAT_1)
        --AND CAST(b.upc_nbr AS INT64) IN UNNEST(_M1_UPC_NBR_1)
        --AND b.old_nbr IN UNNEST(_M1_ITEM_NBR_1)
        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
      ) a
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24

    UNION ALL

    SELECT

      a.SUBFORMATO,
      a.SQUAD_LEAD,
      a.DISTRITO,
      a.DET,
      a.TIENDA,
      a.TIPO_TIENDA,
      a.NIELSEN, 
      a.ESTADO,
      a.TRIBU,
      a.SQUAD,
      a.NUMDEPTO,
      a.DEPARTAMENTO,
      a.NMCAT,
      a.NUMCAT,
      a.CATEGORIA,
      a.NUMFL,
      a.FINELINE,
      a.UPC,
      a.ITEM_NBR,
      a.ITEM_TYPE,
      a.ITEM_STATUS,
      a.ITEM_DESC1,
      a.ITEM_DESC2,
      a.SIGNING_DESC,

      SUM(0) AS VENTA_COSTO_TY,
      SUM(0) AS VENTA_PIEZAS_TY,
      SUM(0) AS VENTA_PESOS_TY,
      SUM(a.VENTA_COSTO) AS VENTA_COSTO_LY,
      SUM(a.VENTA_PIEZAS) AS VENTA_PIEZAS_LY,
      SUM(a.VENTA_PESOS) AS VENTA_PESOS_LY,
      SUM(0) AS CLIENTES_TY,
      SUM(0) AS CLIENTES_LY,
      SUM(0) AS COMBINACIONES,
      SUM(0) AS FALTANTES_OH, 
      SUM(0) AS FALTANTES_IT, 
      SUM(0) AS FALTANTES_IW, 
      SUM(0) AS FALTANTES_IO,
      SUM(0) AS OH_QTY,
      SUM(0) AS OH_RTL,
      SUM(0) AS OH_COST,
      SUM(0) AS IT_QTY,
      SUM(0) AS IT_RTL,
      SUM(0) AS IT_COST,
      SUM(0) AS IW_QTY,
      SUM(0) AS IW_RTL,
      SUM(0) AS IW_COST,
      SUM(0) AS IO_QTY,
      SUM(0) AS IO_RTL,
      SUM(0) AS IO_COST,
      SUM(0) AS NUMTIENDAS,
      SUM(0) AS PACKS_ORD,
      SUM(0) AS PACKS_REC,

      SUM(0) AS OH_QTY_LY,
      SUM(0) AS OH_RTL_LY,
      SUM(0) AS OH_COST_LY,
      SUM(0) AS NUMTIENDAS_LY,

      SUM(0) AS NET_SHIP_QTY_TY,
      SUM(0) AS NET_SHIP_COST_TY,
      SUM(0) AS NET_SHIP_RETAIL_TY,
      SUM(0) AS NET_SHIP_QTY_LY,
      SUM(0) AS NET_SHIP_COST_LY,
      SUM(0) AS NET_SHIP_RETAIL_LY,

      SUM(0) AS BP_VENTA_PESOS,
      SUM(0) AS BP_VENTA_PIEZAS,
      SUM(0) AS BP_ST,
      SUM(0) AS BP_OP_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PIEZAS,
      SUM(0) AS FCST_ST,
      SUM(0) AS PG_FACTOR,
      SUM(0) AS PG_VENTAS,

    FROM(

      SELECT

          f.Formato AS SUBFORMATO,
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
          CAST(SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2) AS INT64) AS NMCAT,
          CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
          h.NumCategoria AS CATEGORIA,
          b.Fineline_nbr AS NUMFL,
          i.NumFineline AS FINELINE,
          b.upc_nbr AS UPC,
          b.old_nbr AS ITEM_NBR,
          c.type_code AS ITEM_TYPE,
          c.status_code AS ITEM_STATUS,
          b.item1_desc AS ITEM_DESC1,
          b.item2_desc AS ITEM_DESC2,
          b.signing_desc AS SIGNING_DESC,

          SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * c.cost) AS VENTA_COSTO,
          SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS,
          SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS,

        FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
        INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
        INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
        INNER JOIN wmt-edw-sandbox.c0v05nw_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
        INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
        LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
        LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto AND b.Fineline_nbr=i.NumFl)
        WHERE d.gregorian_date BETWEEN _M1_FECHA_INICIO_LY AND _M1_FECHA_FIN_LY
        AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
        AND f.Formato IN UNNEST(_M1_SUBFMT_1)
        AND b.Dept_nbr IN UNNEST(_M1_NUMDEPTO_1)
        --AND NUMCAT IN UNNEST(_M1_NUMCAT_1)
        --AND CAST(b.upc_nbr AS INT64) IN UNNEST(_M1_UPC_NBR_2)
        --AND b.old_nbr IN UNNEST(_M1_ITEM_NBR_1)
        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
      ) a
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24

    UNION ALL

    SELECT

      a.SUBFORMATO,
      a.SQUAD_LEAD,
      a.DISTRITO,
      a.DET,
      a.TIENDA,
      a.TIPO_TIENDA,
      a.NIELSEN, 
      a.ESTADO,
      a.TRIBU,
      a.SQUAD,
      a.NUMDEPTO,
      a.DEPARTAMENTO,
      a.NMCAT,
      a.NUMCAT,
      a.CATEGORIA,
      a.NUMFL,
      a.FINELINE,
      a.UPC,
      a.ITEM_NBR,
      a.ITEM_TYPE,
      a.ITEM_STATUS,
      a.ITEM_DESC1,
      a.ITEM_DESC2,
      a.SIGNING_DESC,

      SUM(0) AS VENTA_COSTO_TY,
      SUM(0) AS VENTA_PIEZAS_TY,
      SUM(0) AS VENTA_PESOS_TY,
      SUM(0) AS VENTA_COSTO_LY,
      SUM(0) AS VENTA_PIEZAS_LY,
      SUM(0) AS VENTA_PESOS_LY,
      SUM(0) AS CLIENTES_TY,
      SUM(0) AS CLIENTES_LY,
      SUM(0) AS COMBINACIONES,
      SUM(0) AS FALTANTES_OH, 
      SUM(0) AS FALTANTES_IT, 
      SUM(0) AS FALTANTES_IW, 
      SUM(0) AS FALTANTES_IO,
      SUM(a.OH_QTY) AS OH_QTY,
      SUM(a.OH_RTL) AS OH_RTL,
      SUM(a.OH_COST) AS OH_COST,
      SUM(a.IT_QTY) AS IT_QTY,
      SUM(a.IT_RTL) AS IT_RTL,
      SUM(a.IT_COST) AS IT_COST,
      SUM(a.IW_QTY) AS IW_QTY,
      SUM(a.IW_RTL) AS IW_RTL,
      SUM(a.IW_COST) AS IW_COST,
      SUM(a.IO_QTY) AS IO_QTY,
      SUM(a.IO_RTL) AS IO_RTL,
      SUM(a.IO_COST) AS IO_COST,
      SUM(a.NUMTIENDAS) AS NUMTIENDAS,
      SUM(0) AS PACKS_ORD,
      SUM(0) AS PACKS_REC,

      SUM(0) AS OH_QTY_LY,
      SUM(0) AS OH_RTL_LY,
      SUM(0) AS OH_COST_LY,
      SUM(0) AS NUMTIENDAS_LY,

      SUM(0) AS NET_SHIP_QTY_TY,
      SUM(0) AS NET_SHIP_COST_TY,
      SUM(0) AS NET_SHIP_RETAIL_TY,
      SUM(0) AS NET_SHIP_QTY_LY,
      SUM(0) AS NET_SHIP_COST_LY,
      SUM(0) AS NET_SHIP_RETAIL_LY,

      SUM(0) AS BP_VENTA_PESOS,
      SUM(0) AS BP_VENTA_PIEZAS,
      SUM(0) AS BP_ST,
      SUM(0) AS BP_OP_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PIEZAS,
      SUM(0) AS FCST_ST,
      SUM(0) AS PG_FACTOR,
      SUM(0) AS PG_VENTAS,

    FROM(
          
      SELECT 

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
        CAST(SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2) AS INT64) AS NMCAT,
        CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
        g.NumCategoria AS CATEGORIA,
        b.Fineline_nbr AS NUMFL,
        h.NumFineline AS FINELINE,
        b.upc_nbr AS UPC,
        b.old_nbr AS ITEM_NBR,
        c.type_code AS ITEM_TYPE,
        c.status_code AS ITEM_STATUS,
        b.item1_desc AS ITEM_DESC1,
        b.item2_desc AS ITEM_DESC2,
        b.signing_desc AS SIGNING_DESC,

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
      INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
      INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
      INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
      INNER JOIN wmt-edw-sandbox.c0v05nw_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
      INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
      LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
      LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto AND b.Fineline_nbr=h.NumFl)
      WHERE c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98) 
      AND b.item_status_code IN ('A','I','D')
      AND e.Formato IN UNNEST(_M1_SUBFMT_1)
      AND b.Dept_nbr IN UNNEST(_M1_NUMDEPTO_1)
      --AND NUMCAT IN UNNEST(_M1_NUMCAT_1)
      --AND CAST(b.upc_nbr AS INT64) IN UNNEST(_M1_UPC_NBR_1)
      --AND b.old_nbr IN UNNEST(_M1_ITEM_NBR_1)
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
    ) a
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24

    UNION ALL

    SELECT

      a.SUBFORMATO,
      a.SQUAD_LEAD,
      a.DISTRITO,
      a.DET,
      a.TIENDA,
      a.TIPO_TIENDA,
      a.NIELSEN, 
      a.ESTADO,
      a.TRIBU,
      a.SQUAD,
      a.NUMDEPTO,
      a.DEPARTAMENTO,
      a.NMCAT,
      a.NUMCAT,
      a.CATEGORIA,
      a.NUMFL,
      a.FINELINE,
      a.UPC,
      a.ITEM_NBR,
      a.ITEM_TYPE,
      a.ITEM_STATUS,
      a.ITEM_DESC1,
      a.ITEM_DESC2,
      a.SIGNING_DESC,

      SUM(0) AS VENTA_COSTO_TY,
      SUM(0) AS VENTA_PIEZAS_TY,
      SUM(0) AS VENTA_PESOS_TY,
      SUM(0) AS VENTA_COSTO_LY,
      SUM(0) AS VENTA_PIEZAS_LY,
      SUM(0) AS VENTA_PESOS_LY,
      SUM(0) AS CLIENTES_TY,
      SUM(0) AS CLIENTES_LY,
      SUM(0) AS COMBINACIONES,
      SUM(0) AS FALTANTES_OH, 
      SUM(0) AS FALTANTES_IT, 
      SUM(0) AS FALTANTES_IW, 
      SUM(0) AS FALTANTES_IO,
      SUM(0) AS OH_QTY,
      SUM(0) AS OH_RTL,
      SUM(0) AS OH_COST,
      SUM(0) AS IT_QTY,
      SUM(0) AS IT_RTL,
      SUM(0) AS IT_COST,
      SUM(0) AS IW_QTY,
      SUM(0) AS IW_RTL,
      SUM(0) AS IW_COST,
      SUM(0) AS IO_QTY,
      SUM(0) AS IO_RTL,
      SUM(0) AS IO_COST,
      SUM(0) AS NUMTIENDAS,
      SUM(0) AS PACKS_ORD,
      SUM(0) AS PACKS_REC,

      SUM(0) AS OH_QTY_LY,
      SUM(0) AS OH_RTL_LY,
      SUM(0) AS OH_COST_LY,
      SUM(0) AS NUMTIENDAS_LY,

      SUM(a.NET_SHIP_QTY) AS NET_SHIP_QTY_TY,
      SUM(a.NET_SHIP_COST) AS NET_SHIP_COST_TY,
      SUM(a.NET_SHIP_RTL) AS NET_SHIP_RETAIL_TY,
      SUM(0) AS NET_SHIP_QTY_LY,
      SUM(0) AS NET_SHIP_COST_LY,
      SUM(0) AS NET_SHIP_RETAIL_LY,

      SUM(0) AS BP_VENTA_PESOS,
      SUM(0) AS BP_VENTA_PIEZAS,
      SUM(0) AS BP_ST,
      SUM(0) AS BP_OP_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PIEZAS,
      SUM(0) AS FCST_ST,
      SUM(0) AS PG_FACTOR,
      SUM(0) AS PG_VENTAS,

    FROM(

      SELECT

        f.Formato AS SUBFORMATO,
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
        CAST(SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2) AS INT64) AS NMCAT,
        CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
        h.NumCategoria AS CATEGORIA,
        b.Fineline_nbr AS NUMFL,
        i.NumFineline AS FINELINE,
        b.upc_nbr AS UPC,
        b.old_nbr AS ITEM_NBR,
        c.type_code AS ITEM_TYPE,
        c.status_code AS ITEM_STATUS,
        b.item1_desc AS ITEM_DESC1,
        b.item2_desc AS ITEM_DESC2,
        b.signing_desc AS SIGNING_DESC,

        SUM(a.sat_ship_qty * d.sat_mult + a.sun_ship_qty * d.sun_mult +a.mon_ship_qty * d.mon_mult + a.tue_ship_qty * d.tue_mult + a.wed_ship_qty * d.wed_mult + a.thu_ship_qty * d.thu_mult + a.fri_ship_qty * d.fri_mult) AS NET_SHIP_QTY,
        SUM((a.sat_ship_qty * d.sat_mult +a.sun_ship_qty * d.sun_mult +a.mon_ship_qty * d.mon_mult + a.tue_ship_qty * d.tue_mult +a.wed_ship_qty * d.wed_mult + a.thu_ship_qty * d.thu_mult + a.fri_ship_qty * d.fri_mult) * a.ship_cost) AS NET_SHIP_COST,
        SUM((a.sat_ship_qty * d.sat_mult +a.sun_ship_qty * d.sun_mult +a.mon_ship_qty * d.mon_mult + a.tue_ship_qty * d.tue_mult +a.wed_ship_qty * d.wed_mult + a.thu_ship_qty * d.thu_mult + a.fri_ship_qty * d.fri_mult) * a.retail_amt) AS NET_SHIP_RTL

      FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
      INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
      INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
      INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
      INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr)
      INNER JOIN wmt-edw-sandbox.c0v05nw_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
      INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
      LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
      LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto AND b.Fineline_nbr=i.NumFl)
      WHERE d.gregorian_date BETWEEN _M1_FECHA_INICIO_TY AND _M1_FECHA_FIN_TY
      AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,
                                60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
      AND f.Formato IN UNNEST(_M1_SUBFMT_1)
      AND b.Dept_nbr IN UNNEST(_M1_NUMDEPTO_1)
      --AND NUMCAT IN UNNEST(_M1_NUMCAT_1)
      --AND CAST(b.upc_nbr AS INT64) IN UNNEST(_M1_UPC_NBR_1)
      --AND b.old_nbr IN UNNEST(_M1_ITEM_NBR_1)
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
    ) a
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24

    UNION ALL

    SELECT

      a.SUBFORMATO,
      a.SQUAD_LEAD,
      a.DISTRITO,
      a.DET,
      a.TIENDA,
      a.TIPO_TIENDA,
      a.NIELSEN, 
      a.ESTADO,
      a.TRIBU,
      a.SQUAD,
      a.NUMDEPTO,
      a.DEPARTAMENTO,
      a.NMCAT,
      a.NUMCAT,
      a.CATEGORIA,
      a.NUMFL,
      a.FINELINE,
      a.UPC,
      a.ITEM_NBR,
      a.ITEM_TYPE,
      a.ITEM_STATUS,
      a.ITEM_DESC1,
      a.ITEM_DESC2,
      a.SIGNING_DESC,

      SUM(0) AS VENTA_COSTO_TY,
      SUM(0) AS VENTA_PIEZAS_TY,
      SUM(0) AS VENTA_PESOS_TY,
      SUM(0) AS VENTA_COSTO_LY,
      SUM(0) AS VENTA_PIEZAS_LY,
      SUM(0) AS VENTA_PESOS_LY,
      SUM(0) AS CLIENTES_TY,
      SUM(0) AS CLIENTES_LY,
      SUM(0) AS COMBINACIONES,
      SUM(0) AS FALTANTES_OH, 
      SUM(0) AS FALTANTES_IT, 
      SUM(0) AS FALTANTES_IW, 
      SUM(0) AS FALTANTES_IO,
      SUM(0) AS OH_QTY,
      SUM(0) AS OH_RTL,
      SUM(0) AS OH_COST,
      SUM(0) AS IT_QTY,
      SUM(0) AS IT_RTL,
      SUM(0) AS IT_COST,
      SUM(0) AS IW_QTY,
      SUM(0) AS IW_RTL,
      SUM(0) AS IW_COST,
      SUM(0) AS IO_QTY,
      SUM(0) AS IO_RTL,
      SUM(0) AS IO_COST,
      SUM(0) AS NUMTIENDAS,
      SUM(0) AS PACKS_ORD,
      SUM(0) AS PACKS_REC,

      SUM(0) AS OH_QTY_LY,
      SUM(0) AS OH_RTL_LY,
      SUM(0) AS OH_COST_LY,
      SUM(0) AS NUMTIENDAS_LY,

      SUM(0) AS NET_SHIP_QTY_TY,
      SUM(0) AS NET_SHIP_COST_TY,
      SUM(0) AS NET_SHIP_RETAIL_TY,
      SUM(a.NET_SHIP_QTY) AS NET_SHIP_QTY_LY,
      SUM(a.NET_SHIP_COST) AS NET_SHIP_COST_LY,
      SUM(a.NET_SHIP_RTL) AS NET_SHIP_RETAIL_LY,

      SUM(0) AS BP_VENTA_PESOS,
      SUM(0) AS BP_VENTA_PIEZAS,
      SUM(0) AS BP_ST,
      SUM(0) AS BP_OP_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PESOS,
      SUM(0) AS FCST_VENTA_PIEZAS,
      SUM(0) AS FCST_ST,
      SUM(0) AS PG_FACTOR,
      SUM(0) AS PG_VENTAS,

    FROM(

      SELECT
                                          
        f.Formato AS SUBFORMATO,
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
        CAST(SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2) AS INT64) AS NMCAT,
        CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
        h.NumCategoria AS CATEGORIA,
        b.Fineline_nbr AS NUMFL,
        i.NumFineline AS FINELINE,
        b.upc_nbr AS UPC,
        b.old_nbr AS ITEM_NBR,
        c.type_code AS ITEM_TYPE,
        c.status_code AS ITEM_STATUS,
        b.item1_desc AS ITEM_DESC1,
        b.item2_desc AS ITEM_DESC2,
        b.signing_desc AS SIGNING_DESC,

        SUM(a.sat_ship_qty * d.sat_mult + a.sun_ship_qty * d.sun_mult +a.mon_ship_qty * d.mon_mult + a.tue_ship_qty * d.tue_mult + a.wed_ship_qty * d.wed_mult + a.thu_ship_qty * d.thu_mult + a.fri_ship_qty * d.fri_mult) AS NET_SHIP_QTY,
        SUM((a.sat_ship_qty * d.sat_mult +a.sun_ship_qty * d.sun_mult +a.mon_ship_qty * d.mon_mult + a.tue_ship_qty * d.tue_mult +a.wed_ship_qty * d.wed_mult + a.thu_ship_qty * d.thu_mult + a.fri_ship_qty * d.fri_mult) * a.ship_cost) AS NET_SHIP_COST,
        SUM((a.sat_ship_qty * d.sat_mult +a.sun_ship_qty * d.sun_mult +a.mon_ship_qty * d.mon_mult + a.tue_ship_qty * d.tue_mult +a.wed_ship_qty * d.wed_mult + a.thu_ship_qty * d.thu_mult + a.fri_ship_qty * d.fri_mult) * a.retail_amt) AS NET_SHIP_RTL

      FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_SHIP a
      INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
      INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
      INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
      INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr)
      INNER JOIN wmt-edw-sandbox.c0v05nw_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
      INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
      LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
      LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto AND b.Fineline_nbr=i.NumFl)
      WHERE d.gregorian_date BETWEEN _M1_FECHA_INICIO_LY AND _M1_FECHA_FIN_LY
      AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,55,56,58,
                                60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
      AND f.Formato IN UNNEST(_M1_SUBFMT_1)
      AND b.Dept_nbr IN UNNEST(_M1_NUMDEPTO_1)
      --AND NUMCAT IN UNNEST(_M1_NUMCAT_1)
      --AND CAST(b.upc_nbr AS INT64) IN UNNEST(_M1_UPC_NBR_2)
      --AND b.old_nbr IN UNNEST(_M1_ITEM_NBR_1)
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
      ) a
      GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
  ) a
  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
) a