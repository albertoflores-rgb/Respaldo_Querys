SELECT 
  T1.FORMATO1,
  T1.SQUAD_LEAD1,
  T1.DISTRITO1,
  T1.ESTADO1,
  T1.DET1,
  T1.TIENDA1,
  T1.TIPO_TIENDA1,
  T1.TYPE_TIENDA1,
  T1.NIELSEN1,
  T1.TRIBU1,
  T1.SQUAD1,
  T1.NUMDEPTO1,
  T1.DEPARTAMENTO1,
  T1.NUMCAT1,
  T1.CATEGORIA1,
  T1.NUMFL1,
  T1.FINELINE1,
  T1.IED,
  T1.OED,
  T1.TYPE_ITEM,
  T1.STATUS_ITEM,
  T1.UPC1,
  T1.ITEM_NBR1,
  T1.ITEM_DESC11,
  T1.VENDOR_NAME,
  T1.VENDOR_NBR,

  T2.TOTAL_CAPACITY as total_capacity,
  T2.Facings as facings,
  T2.PORCENTAJE_CARGADO as porcentaje_cargado,
  T2.SS_GANADOR as SS_Ganador,
  T2.BASE_PRESS as BASE_PRESS,
  T2.SAFETY_GANADOR AS SAFETY_GANADOR,
  T2.Cedis_Asignado AS CEDIS_ASIGNADO,
  T2.WHSE_DS_NAME AS WHSE_DS_NAME,
  T2.REV_X_SEM AS REV_X_SEM,
  T2.PALLET_TI_QTY AS PALLET_TI_QTY,
  T2.PALLET_HI_QTY AS PALLET_HI_QTY,
  T2.LEAD_TIME_DAY_QTY AS LEAD_TIME_DAY_QTY,
  T2.Fecha_Act AS Fecha_Act,

 --Resurtido
 
  SUM(T2.DDV_OH) as DDV_OH,
  sum(T2.DDV_IT) as DDV_IT,
  SUM(T2.DDV_TTL) AS DDV_TTL,
  SUM(T2.DDV_EMPAQUE) AS DDV_EMPAQUE,
  SUM(T2.ACUM_LT) AS ACUM_LT,
--Inventarios

  --SUM((T2.OH_RTL/T2.OH_QTY)/(T2.OH_COST/T2.OH_QTY)) AS MARGIN,
  sum(T2.OH_QTY) AS OH_QTY,
  SUM(T2.OH_RTL) AS OH_RTL,
  SUM(T2.OH_COST) AS OH_COST,
  SUM(T2.IT_QTY) AS IT_QTY,
  SUM(T2.IT_RTL) AS IT_RTL,
  SUM(T2.IT_COST) AS IT_COST,
  SUM(T2.IW_QTY) AS IW_QTY,
  SUM(T2.IW_RTL) AS IW_RTL,
  SUM(T2.IW_COST) AS IW_COST,
  SUM(T2.OH_QTY + T2.IT_QTY + T2.IW_QTY) AS Total_Cadena,
  SUM(T2.IO_QTY) AS IO_QTY,
  SUM(T2.IO_RTL) AS IO_RTL,
  SUM(T2.IO_COST) AS IO_COST,

--Ventas
  SUM(T1.Venta_Pzas_M01) AS Enero_Qty,
  SUM(T1.Venta_Pzas_M02) AS Febrero_Qty,
  SUM(T1.Venta_Pzas_M03) AS Marzo_Qty,
  SUM(T1.Venta_Pzas_M04) AS Abril_Qty,
  SUM(T1.Venta_Pzas_M05) AS Mayo_Qty,
  SUM(T1.Venta_Pzas_M06) AS Junio_Qty,
  SUM(T1.Venta_Pzas_M07) AS Julio_Qty,
  SUM(T1.Venta_Pzas_M08) AS Agosto_Qty,
  SUM(T1.Venta_Pzas_M09) AS Septiembre_Qty,
  SUM(T1.Venta_Pzas_M10) AS Octubre_Qty,
  SUM(T1.Venta_Pzas_M11) AS Noviembre_Qty,
  SUM(T1.Venta_Pzas_M12) AS Diciembre_Qty,
  SUM(T1.VENTA_PESOS_M01) AS Enero_RTL,
  SUM(T1.VENTA_PESOS_M02) AS Febrero_RTL,
  SUM(T1.VENTA_PESOS_M03) AS Marzo_RTL,
  SUM(T1.VENTA_PESOS_M04) AS Abril_RTL,
  SUM(T1.VENTA_PESOS_M05) AS Mayo_RTL,
  SUM(T1.VENTA_PESOS_M06) AS Junio_RTL,
  SUM(T1.VENTA_PESOS_M07) AS Julio_RTL,
  SUM(T1.VENTA_PESOS_M08) AS Agosto_RTL,
  SUM(T1.VENTA_PESOS_M09) AS Septiembre_RTL,
  SUM(T1.VENTA_PESOS_M10) AS Octubre_RTL,
  SUM(T1.VENTA_PESOS_M11) AS Noviembre_RTL,
  SUM(T1.VENTA_PESOS_M12) AS Diciembre_RTL,

 --LY

  SUM(T1.Venta_Pzas_M01LY) AS Cr_Enero_Qty_LY,
  SUM(T1.Venta_Pzas_M02LY) AS Cr_Febrero_Qty_LY,
  SUM(T1.Venta_Pzas_M03LY) AS Cr_Marzo_Qty_LY,
  SUM(T1.Venta_Pzas_M04LY) AS Cr_Abril_Qty_LY,
  SUM(T1.Venta_Pzas_M05LY) AS Cr_Mayo_Qty_LY,
  SUM(T1.Venta_Pzas_M06LY) AS Cr_Junio_Qty_LY,
  SUM(T1.Venta_Pzas_M07LY) AS Cr_Julio_Qty_LY,
  SUM(T1.Venta_Pzas_M08LY) AS Cr_Agosto_Qty_LY,
  SUM(T1.Venta_Pzas_M09LY) AS Cr_Septiembre_Qty_LY,
  SUM(T1.Venta_Pzas_M10LY) AS Cr_Octubre_Qty_LY,
  SUM(T1.Venta_Pzas_M11LY) AS Cr_Noviembre_Qty_LY,
  SUM(T1.Venta_Pzas_M12LY) AS Cr_Diciembre_Qty_LY,
  SUM(T1.VENTA_PESOS_M01LY) AS Cr_Enero_RTL_LY,
  SUM(T1.VENTA_PESOS_M02LY) AS Cr_Febrero_RTL_LY,
  SUM(T1.VENTA_PESOS_M03LY) AS Cr_Marzo_RTL_LY,
  SUM(T1.VENTA_PESOS_M04LY) AS Cr_Abril_RTL_LY,
  SUM(T1.VENTA_PESOS_M05LY) AS Cr_Mayo_RTL_LY,
  SUM(T1.VENTA_PESOS_M06LY) AS Cr_Junio_RTL_LY,
  SUM(T1.VENTA_PESOS_M07LY) AS Cr_Julio_RTL_LY,
  SUM(T1.VENTA_PESOS_M08LY) AS Cr_Agosto_RTL_LY,
  SUM(T1.VENTA_PESOS_M09LY) AS Cr_Septiembre_RTL_LY,
  SUM(T1.VENTA_PESOS_M10LY) AS Cr_Octubre_RTL_LY,
  SUM(T1.VENTA_PESOS_M11LY) AS Cr_Noviembre_RTL_LY,
  SUM(T1.VENTA_PESOS_M12LY) AS Cr_Diciembre_RTL_LY,

--INSTOCK

  --sum(T2.Combinaciones) AS  Combinaciones,
  --sum(T2.Faltantes_OH) as Faltantes_OH,
  --sum(t2.Faltantes_IT) as Faltantes_IT,
  --sum(T2.Faltantes_IW) as Faltantes_IW,
  --sum(t2.Faltantes_IO) as Faltantes_IO
  

FROM (
Select
                                            
    f.Formato AS FORMATO1,
    f.Squad AS SQUAD_LEAD1,
    f.Distrito AS DISTRITO1,
    f.Det AS DET1,
    f.Tienda AS TIENDA1,
    f.Type_Cluster AS TIPO_TIENDA1,
    f.TYPE_CLUSTER AS TYPE_TIENDA1,
    f.Nielsen AS NIELSEN1, 
    f.Estado AS ESTADO1,
    h.Tribu AS TRIBU1,
    h.Squad AS SQUAD1,
    b.Dept_nbr AS NUMDEPTO1,
    g.NumDepartamento AS DEPARTAMENTO1,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT1,
    h.NumCategoria AS CATEGORIA1,
    b.Fineline_nbr AS NUMFL1,
    i.NumFineline AS FINELINE1,
    b.upc_nbr AS UPC1,
    C.EFFECTIVE_DATE AS IED,
    C.OBSOLETE_DATE AS OED,
    C.STATUS_CODE AS STATUS_ITEM,
    C.TYPE_CODE AS TYPE_ITEM,
    b.old_nbr AS ITEM_NBR1,
    b.item1_desc AS ITEM_DESC11,
    b.item2_desc AS ITEM_DESC21,
    b.signing_desc AS SIGNING_DESC1,
    c.VENDOR_NBR AS VENDOR_NBR,
    c.VENDOR_NAME AS VENDOR_NAME,
    --d.GREGORIAN_DATE AS Fecha,
    --a.WM_YR_WK AS WM_WEEK,
    --EXTRACT(MONTH FROM d.gregorian_date) AS Month,
    --EXTRACT(YEAR FROM d.gregorian_date ) AS Year,
    --EXTRACT(DAY FROM (LAST_DAY (d.gregorian_date,MONTH))) AS Dias,

    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_T,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_T,
    
    --Ventas por semana------------------------------------------------------------------------------------------------------
    --COALESCE(SUM(CASE WHEN (Right (CAST(a.WM_YR_WK AS STRING),2) = "01") THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_WK01,

    --Ventas Semanales Pesos ------------------------------------------------------------------------------------------------------------------------------
   -- COALESCE(SUM(CASE WHEN (Right (CAST(a.WM_YR_WK AS STRING),2) = "01") THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_WK01,
   
    --Ventas por Mes------------------------------------------------------------------------------------------------------
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 1 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M01,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 2 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M02,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 3 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M03,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 4 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M04,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 5 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M05,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 6 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M06,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 7 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M07,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 8 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M08,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 9 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M09,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 10 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M10,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 11 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M11,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 12 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M12,

--Venta Piezas Mensual Año Pasdao-------------------------------

    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 1 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M01LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 2 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M02LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 3 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M03LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 4 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M04LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 5 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M05LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 6 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M06LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 7 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M07LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 8 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M08LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 9 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M09LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 10 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M10LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 11 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M11LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 12 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult +a. fri_qty * d.fri_mult) END),0) AS    Venta_Pzas_M12LY,

    --Ventas Mensual Pesos ------------------------------------------------------------------------------------------------------------------------------
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 1 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M01,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 2 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M02,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 3 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M03,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 4 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M04,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 5 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M05,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 6 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M06,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 7 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M07,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 8 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M08,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 9 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M09,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 10 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M10,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 11 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M11,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 12 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M12,

        --Ventas Mensual Pesos Año Pasado------------------------------------------------------------------------------------------------------------------------------
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 1 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M01LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 2 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M02LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 3 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M03LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 4 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M04LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 5 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M05LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 6 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M06LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 7 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M07LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 8 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M08LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 9 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M09LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 10 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M10LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 11 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M11LY,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = 12 AND EXTRACT(YEAR FROM d.gregorian_date) = EXTRACT(YEAR FROM CURRENT_DATE)-1) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_M12LY,

FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
WHERE d.gregorian_date BETWEEN DATE '2025-01-01' AND  CURRENT_DATE
AND c.order_dept_nbr IN (8,28,38,40,69,2,46)
--AND CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) IN ('90-11')
AND h.tribu IN ("SALUD Y BIENESTAR")
--AND f.Formato IN ('SUPERCENTER')

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28) AS T1

FULL JOIN
(
  SELECT 
                                            
    e.Formato AS FORMATO2,
    e.Squad AS SQUAD_LEAD2,
    e.Distrito AS DISTRITO2,
    e.Det AS DET2,
    e.Tienda AS TIENDA2,
    e.Type_Cluster AS TIPO_TIENDA2,
    e.Nielsen AS NIELSEN2, 
    e.Estado AS ESTADO2,
    g.Tribu AS TRIBU2,
    g.Squad AS SQUAD2,
    b.Dept_nbr AS NUMDEPTO2,
    f.NumDepartamento AS DEPARTAMENTO2,
    CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT2,
    g.NumCategoria AS CATEGORIA2,
    b.Fineline_nbr AS NUMFL2,
    h.NumFineline AS FINELINE2,
    b.upc_nbr AS UPC2,
    b.old_nbr AS ITEM_NBR2,
    b.item1_desc AS ITEM_DESC12,
    b.item2_desc AS ITEM_DESC22,
    b.signing_desc AS SIGNING_DESC2,
    i.CAPACITY as Capacity_tienda,
    i.TOTAL_CAPACITY as total_capacity,
    i.HORIZONTAL_FACING as facings,
    i.PORCENTAJE_CARGADO as porcentaje_cargado,
    i.SS_GANADOR as SS_Ganador,
    i.BASE_PRESS as BASE_PRESS,
    i.SAFETY_GANADOR AS SAFETY_GANADOR,
    I.WHSE_DS_NBR AS CEDIS_ASIGNADO,
    i.WHSE_DS_NAME AS WHSE_DS_NAME,
    i.REV_X_SEM AS REV_X_SEM,
    i.PALLET_TI_QTY AS PALLET_TI_QTY,
    i.PALLET_HI_QTY AS PALLET_HI_QTY,
    i.LEAD_TIME_DAY_QTY AS LEAD_TIME_DAY_QTY,
    i.Fecha_Act AS Fecha_Act,

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
    SUM(i.DDV_OH) as DDV_OH,
    sum(i.DDV_IT) as DDV_IT,
    SUM(i.DDV_TTL) AS DDV_TTL,
    SUM(i.DDV_EMPAQUE) AS DDV_EMPAQUE,
    SUM(i.ACUM_LT) AS ACUM_LT

FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto and b.Fineline_nbr=h.NumFl)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.SUPPLY_CHAIN_DB i ON (b.old_nbr = i.old_nbr AND a.store_nbr = i.store_nbr AND i.fecha_act = Date(current_date))

--LEFT JOIN  `wmt-edw-sandbox.Black_Bird.INSTOCK_DIARIO_W2` i ON (a.store_nbr = i.Det and b.UPC_NBR = i.upc)
WHERE c.order_dept_nbr IN (8,28,38,40,69,2,46)
AND g.tribu IN ("SALUD Y BIENESTAR")
--AND CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) IN ('90-11')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,32,33,34,35) AS T2

ON(T1.DET1 = T2.DET2
  AND T1.ITEM_NBR1 = T2.ITEM_NBR2)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39
