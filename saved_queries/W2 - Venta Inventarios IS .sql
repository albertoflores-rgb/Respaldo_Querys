Select 

  a.FORMATO1,
  a.SQUAD_LEAD1,
  a.DISTRITO1,
  a.ESTADO1,
  a.DET1,
  a.TIENDA1,
  a.TIPO_TIENDA1,
  a.TYPE_TIENDA1,
  a.NIELSEN1,
  a.TRIBU1,
  a.SQUAD1,
  a.NUMDEPTO1,
  a.DEPARTAMENTO1,
  a.NUMCAT1,
  a.CATEGORIA1,
  a.NUMFL1,
  a.FINELINE1,
  a.IED,
  a.OED,
  a.TYPE_ITEM,
  a.STATUS_ITEM,
  a.UPC1,
  a.ITEM_NBR1,
  a.ITEM_DESC11,
  a.VENDOR_NAME,
  a.VENDOR_NBR,
--Inventarios

  --SUM((T2.OH_RTL/T2.OH_QTY)/(T2.OH_COST/T2.OH_QTY)) AS MARGIN,
  sum(a.OH_QTY) AS OH_QTY,
  SUM(a.OH_RTL) AS OH_RTL,
  SUM(a.OH_COST) AS OH_COST,
  SUM(a.IT_QTY) AS IT_QTY,
  SUM(a.IT_RTL) AS IT_RTL,
  SUM(a.IT_COST) AS IT_COST,
  SUM(a.IW_QTY) AS IW_QTY,
  SUM(a.IW_RTL) AS IW_RTL,
  SUM(a.IW_COST) AS IW_COST,
  SUM(a.OH_QTY + a.IT_QTY + a.IW_QTY) AS Total_Cadena,
  SUM(a.OH_RTL + a.IT_RTL + a.IW_RTL) AS Total_Cadena_RTL,
  SUM(a.IO_QTY) AS IO_QTY,
  SUM(a.IO_RTL) AS IO_RTL,
  SUM(a.IO_COST) AS IO_COST,

--Ventas
  SUM(a.Enero_Qty) AS Enero_Qty,
  SUM(a.Febrero_Qty) AS Febrero_Qty,
  SUM(a.Marzo_Qty) AS Marzo_Qty,
  SUM(a.Abril_Qty) AS Abril_Qty,
  SUM(a.Mayo_Qty) AS Mayo_Qty,
  SUM(a.Junio_Qty) AS Junio_Qty,
  SUM(a.Julio_Qty) AS Julio_Qty,
  SUM(a.Agosto_Qty) AS Agosto_Qty,
  SUM(a.Septiembre_Qty) AS Septiembre_Qty,
  SUM(a.Octubre_Qty) AS Octubre_Qty,
  SUM(a.Noviembre_Qty) AS Noviembre_Qty,
  SUM(a.Diciembre_Qty) AS Diciembre_Qty,
  SUM(a.Enero_RTL) AS Enero_RTL,
  SUM(a.Febrero_RTL) AS Febrero_RTL,
  SUM(a.Marzo_RTL) AS Marzo_RTL,
  SUM(a.Abril_RTL) AS Abril_RTL,
  SUM(a.Mayo_Qty) AS Mayo_RTL,
  SUM(a.Junio_RTL) AS Junio_RTL,
  SUM(a.Julio_RTL) AS Julio_RTL,
  SUM(a.Agosto_RTL) AS Agosto_RTL,
  SUM(a.Septiembre_RTL) AS Septiembre_RTL,
  SUM(a.Octubre_RTL) AS Octubre_RTL,
  SUM(a.Noviembre_RTL) AS Noviembre_RTL,
  SUM(a.Diciembre_RTL) AS Diciembre_RTL,

 --LY

  SUM(a.Enero_Qty_LY) AS Enero_Qty_LY,
  SUM(a.Febrero_Qty_LY) AS Febrero_Qty_LY,
  SUM(a.Marzo_Qty_LY) AS Marzo_Qty_LY,
  SUM(a.Abril_Qty_LY) AS Abril_Qty_LY,
  SUM(a.Mayo_Qty_LY) AS Mayo_Qty_LY,
  SUM(a.Junio_Qty_LY) AS Junio_Qty_LY,
  SUM(a.Julio_Qty_LY) AS Julio_Qty_LY,
  SUM(a.Agosto_Qty_LY) AS Agosto_Qty_LY,
  SUM(a.Septiembre_Qty_LY) AS Septiembre_Qty_LY,
  SUM(a.Octubre_Qty_LY) AS Octubre_Qty_LY,
  SUM(a.Noviembre_Qty_LY) AS Noviembre_Qty_LY,
  SUM(a.Diciembre_Qty_LY) AS Diciembre_Qty_LY,
  SUM(a.Enero_RTL_ly) AS Enero_RTL_LY,
  SUM(a.Febrero_RTL_LY) AS Febrero_RTL_LY,
  SUM(a.Marzo_RTL_LY) AS Marzo_RTL_LY,
  SUM(a.Abril_RTL_LY) AS Abril_RTL_LY,
  SUM(a.Mayo_RTL_LY) AS Mayo_RTL_LY,
  SUM(a.Junio_RTL_LY) AS Junio_RTL_LY,
  SUM(a.Julio_RTL_LY) AS Julio_RTL_LY,
  SUM(a.Agosto_RTL_LY) AS Agosto_RTL_LY,
  SUM(a.Septiembre_RTL_LY) AS Septiembre_RTL_LY,
  SUM(a.Octubre_RTL_LY) AS Octubre_RTL_LY,
  SUM(a.Noviembre_RTL_LY) AS Noviembre_RTL_LY,
  SUM(a.Diciembre_RTL_LY) AS Diciembre_RTL_LY,

--INSTOCK

  SUM(B.COMBINACIONES_SC) AS COMBINACIONES_SC,
  SUM(B.FALTANTES_OH_SC) AS FALTANTES_OH_SC, 
  SUM(B.FALTANTES_IT_SC) AS FALTANTES_IT_SC, 
  SUM(b.FALTANTES_IW_SC) AS FALTANTES_IW_SC, 
  SUM(b.FALTANTES_IO_SC) AS FALTANTES_IO_SC,
  SUM(b.PACKS_ORD_SC) AS PACKS_ORD_SC,
  SUM(b.PACKS_REC_SC) AS PACKS_REC_SC

from(
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

  SUM(T1.Venta_Pzas_M01LY) AS Enero_Qty_LY,
  SUM(T1.Venta_Pzas_M02LY) AS Febrero_Qty_LY,
  SUM(T1.Venta_Pzas_M03LY) AS Marzo_Qty_LY,
  SUM(T1.Venta_Pzas_M04LY) AS Abril_Qty_LY,
  SUM(T1.Venta_Pzas_M05LY) AS Mayo_Qty_LY,
  SUM(T1.Venta_Pzas_M06LY) AS Junio_Qty_LY,
  SUM(T1.Venta_Pzas_M07LY) AS Julio_Qty_LY,
  SUM(T1.Venta_Pzas_M08LY) AS Agosto_Qty_LY,
  SUM(T1.Venta_Pzas_M09LY) AS Septiembre_Qty_LY,
  SUM(T1.Venta_Pzas_M10LY) AS Octubre_Qty_LY,
  SUM(T1.Venta_Pzas_M11LY) AS Noviembre_Qty_LY,
  SUM(T1.Venta_Pzas_M12LY) AS Diciembre_Qty_LY,
  SUM(T1.VENTA_PESOS_M01LY) AS Enero_RTL_LY,
  SUM(T1.VENTA_PESOS_M02LY) AS Febrero_RTL_LY,
  SUM(T1.VENTA_PESOS_M03LY) AS Marzo_RTL_LY,
  SUM(T1.VENTA_PESOS_M04LY) AS Abril_RTL_LY,
  SUM(T1.VENTA_PESOS_M05LY) AS Mayo_RTL_LY,
  SUM(T1.VENTA_PESOS_M06LY) AS Junio_RTL_LY,
  SUM(T1.VENTA_PESOS_M07LY) AS Julio_RTL_LY,
  SUM(T1.VENTA_PESOS_M08LY) AS Agosto_RTL_LY,
  SUM(T1.VENTA_PESOS_M09LY) AS Septiembre_RTL_LY,
  SUM(T1.VENTA_PESOS_M10LY) AS Octubre_RTL_LY,
  SUM(T1.VENTA_PESOS_M11LY) AS Noviembre_RTL_LY,
  SUM(T1.VENTA_PESOS_M12LY) AS Diciembre_RTL_LY,

FROM (
Select
                                            
    f.Formato AS FORMATO1,
    f.Squad AS SQUAD_LEAD1,
    f.Distrito AS DISTRITO1,
    f.Det AS DET1,
    f.Tienda AS TIENDA1,
    f.Type_Cluster AS TIPO_TIENDA1,
    f.TYPE_TIENDA AS TYPE_TIENDA1,
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

    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_T,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_T,
   
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
WHERE d.gregorian_date BETWEEN DATE '2025-04-01' AND  CURRENT_DATE

AND e.store_nbr IN (2345,2033,2347,2464,3846,2466,4547,3877,1489,3851,3863,3862,3845,1107,3848,3858,3857,3872,2644,3852,5765,3847,1083,3790,5791,1202,5855,5825)
AND CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) IN ('90-11')
AND f.Formato IN ('SUPERCENTER')

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
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto and b.Fineline_nbr=h.NumFl)

WHERE CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) IN ('90-11')
AND e.DET IN (2345,2033,2347,2464,3846,2466,4547,3877,1489,3851,3863,3862,3845,1107,3848,3858,3857,3872,2644,3852,5765,3847,1083,3790,5791,1202,5855,5825 )
AND e.Formato IN ('SUPERCENTER')

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21) AS T2

ON(T1.DET1 = T2.DET2
  AND T1.ITEM_NBR1 = T2.ITEM_NBR2)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26) AS a

LEFT JOIN(
  SELECT

  a.det,
  a.TRIBU,
  a.SQUAD,
  a.NUMDEPTO,
  a.DEPARTAMENTO,
  a.NUMCAT,
  a.CATEGORIA,
  a.NUMFL,
  a.FINELINE,
  a.UPC,
  a.SIGNING_DESC,
  a.STATUS,
  a.TYPE,
  SUM(a.COMBINACIONES) AS COMBINACIONES_SC,
  SUM(a.FALTANTES_OH) AS FALTANTES_OH_SC, 
  SUM(a.FALTANTES_IT) AS FALTANTES_IT_SC, 
  SUM(a.FALTANTES_IW) AS FALTANTES_IW_SC, 
  SUM(a.FALTANTES_IO) AS FALTANTES_IO_SC,
  SUM(a.PACKS_ORD) AS PACKS_ORD_SC,
  SUM(a.PACKS_REC) AS PACKS_REC_SC

FROM (
      SELECT

        a.DET,
        a.TRIBU,
        a.SQUAD,
        a.NUMDEPTO,
        a.DEPARTAMENTO,
        a.NUMCAT,
        a.CATEGORIA,
        a.NUMFL,
        a.FINELINE,
        a.UPC,
        a.ITEM_NBR,
        a.ITEM_DESC1,
        a.ITEM_DESC2,
        a.SIGNING_DESC,
        a.STATUS,
        a.TYPE,
        SUM(a.COMBINACIONES) AS COMBINACIONES,
        SUM(a.FALTANTES_OH) AS FALTANTES_OH, 
        SUM(a.FALTANTES_IT) AS FALTANTES_IT, 
        SUM(a.FALTANTES_IW) AS FALTANTES_IW, 
        SUM(a.FALTANTES_IO) AS FALTANTES_IO,
        SUM(a.OH_QTY) AS OH_QTY,
        SUM(a.IT_QTY) AS IT_QTY,
        SUM(a.IW_QTY) AS IW_QTY,
        SUM(a.IO_QTY) AS IO_QTY,
        SUM(a.PACKS_ORD) AS PACKS_ORD,
        SUM(a.PACKS_REC) AS PACKS_REC

      FROM (
            SELECT

              a.DET,
              a.TRIBU,
              a.SQUAD,
              a.NUMDEPTO,
              a.DEPARTAMENTO,
              a.NUMCAT,
              a.CATEGORIA,
              a.NUMFL,
              a.FINELINE,
              a.UPC,
              a.ITEM_NBR,
              a.ITEM_DESC1,
              a.ITEM_DESC2,
              a.SIGNING_DESC,
              a.STATUS,
              a.TYPE,
              a.COMBINACIONES,
              a.SALES_FCST,
              IF(a.OH_QTY < a.SALES_FCST,1,0) AS FALTANTES_OH, 
              IF(a.OH_IT_QTY < (a.SALES_FCST*3),1,0) AS FALTANTES_IT, 
              IF(a.OH_IT_IW_QTY < (a.SALES_FCST*5),1,0) AS FALTANTES_IW, 
              IF(a.OH_IT_IW_IO_QTY < ( a.SALES_FCST*7),1,0) AS FALTANTES_IO,
              a.OH_QTY,
              a.IT_QTY,
              a.IW_QTY,
              a.IO_QTY,
              a.PACKS_ORD,
              a.PACKS_REC

            FROM (
                  SELECT

                    a.DET,
                    a.TRIBU,
                    a.SQUAD,
                    a.NUMDEPTO,
                    a.DEPARTAMENTO,
                    a.NUMCAT,
                    a.CATEGORIA,
                    a.NUMFL,
                    a.FINELINE,
                    a.UPC,
                    a.ITEM_NBR,
                    a.ITEM_DESC1,
                    a.ITEM_DESC2,
                    a.SIGNING_DESC,
                    a.STATUS,
                    a.TYPE,
                    a.COMBINACIONES,
                    IF(a.SALES_FCST=0,a.INFO_FCST,a.SALES_FCST) AS SALES_FCST,
                    a.OH_QTY,
                    a.IT_QTY,
                    a.IW_QTY,
                    a.IO_QTY,
                    a.OH_IT_QTY,
                    a.OH_IT_IW_QTY,
                    a.OH_IT_IW_IO_QTY,
                    a.PACKS_ORD,
                    a.PACKS_REC

                  FROM (
                        SELECT

                          a.DET,
                          a.TRIBU,
                          a.SQUAD,
                          a.NUMDEPTO,
                          a.DEPARTAMENTO,
                          a.NUMCAT,
                          a.CATEGORIA,
                          a.NUMFL,
                          a.FINELINE,
                          a.UPC,
                          a.ITEM_NBR,
                          a.ITEM_DESC1,
                          a.ITEM_DESC2,
                          a.SIGNING_DESC,
                          a.STATUS,
                          a.TYPE,
                          1 AS COMBINACIONES,
                          IF(b.SALES_FCST IS NULL,0,b.SALES_FCST) AS SALES_FCST,
                          IF(c.OH_QTY IS NULL,0,c.OH_QTY) AS OH_QTY,
                          IF(c.IT_QTY IS NULL,0,c.IT_QTY) AS IT_QTY,
                          IF(c.IW_QTY IS NULL,0,c.IW_QTY) AS IW_QTY,
                          IF(c.IO_QTY IS NULL,0,c.IO_QTY) AS IO_QTY,
                          IF(c.OH_IT_QTY IS NULL,0,c.OH_IT_QTY) AS OH_IT_QTY,
                          IF(c.OH_IT_IW_QTY IS NULL,0,c.OH_IT_IW_QTY) AS OH_IT_IW_QTY,
                          IF(c.OH_IT_IW_IO_QTY IS NULL,0,c.OH_IT_IW_IO_QTY) AS OH_IT_IW_IO_QTY,
                          IF(d.INFO_FCST IS NULL,0,d.INFO_FCST) AS INFO_FCST,
                          IF(e.PACKS_ORD IS NULL,0,e.PACKS_ORD) AS PACKS_ORD,
                          IF(e.PACKS_REC IS NULL,0,e.PACKS_REC) AS PACKS_REC

                        FROM (
                              SELECT

                                a.DET,
                                a.TRIBU,
                                a.SQUAD,
                                a.NUMDEPTO,
                                a.DEPARTAMENTO,
                                a.NUMCAT,
                                a.CATEGORIA,
                                a.NUMFL,
                                a.FINELINE,
                                a.UPC,
                                a.ITEM_NBR,
                                a.ITEM_DESC1,
                                a.ITEM_DESC2,
                                a.SIGNING_DESC,
                                a.STATUS,
                                a.TYPE

                              FROM (
                                    SELECT

                                      a.store_nbr AS DET,
                                      g.Tribu AS TRIBU,
                                      g.Squad AS SQUAD,
                                      b.Dept_nbr AS NUMDEPTO,
                                      f.NumDepartamento AS DEPARTAMENTO,
                                      CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
                                      g.NumCategoria AS CATEGORIA,
                                      b.Fineline_nbr AS NUMFL,
                                      h.NumFineline AS FINELINE,
                                      b.upc_nbr AS UPC,
                                      b.old_nbr AS ITEM_NBR,
                                      b.item1_desc AS ITEM_DESC1,
                                      b.item2_desc AS ITEM_DESC2,
                                      b.signing_desc AS SIGNING_DESC,
                                      b.item_status_code AS STATUS,
                                      c.type_code AS TYPE,

                                    FROM wmt-edw-prod.MX_WM_VM.ITEM b 
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON ( b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr)
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.INFOREM_MANAGED_SKU a ON (b.item_nbr = a.item_nbr)
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr)
                                    INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                                    INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
                                    INNER JOIN wmt-edw-prod.MX_WM_REPL_VM.GRS_VENDOR_AGREEMENT i ON (b.vendor_nbr = i.vendor_nbr)
                                    LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))  = g.NumCat)
                                    LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto and b.Fineline_nbr=h.NumFl)
                                    WHERE c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND c.ordbk_flag IN ('Y')
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I')
                                    AND j.trait_nbr IN (297)
                                    AND c.type_code IN ('20','33','37','40')
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd IN (2)
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','03','3','07','7','6','06','8','08') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21)
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND b.dept_nbr IN(90,91,97) 
                                    AND c.type_code IN ('20','33','37','40')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18)
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21)
                                    AND j.trait_nbr IN (297)
                                    AND a.carry_option IN ('R') 
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND b.dept_nbr IN(90,91,97) 
                                    AND c.type_code IN ('20')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18)
                                    AND j.trait_nbr IN (297)
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER IN (1,0)
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R')  
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr IN(91,97) 
                                    AND c.type_code IN ('20') 
                                    AND c.ordbk_flag IN ('Y')
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2)
                                    AND j.trait_nbr IN (297)
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER IN (20) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr NOT IN(56,97,91,90,81,98,94,99) 
                                    AND c.type_code IN ('20','33','37','40')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2)
                                    AND j.trait_nbr IN (297)
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr IN(81,98,94,56) 
                                    AND c.type_code IN ('20','33','37','40')
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A') 
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2)
                                    AND j.trait_nbr IN (297)
                                    AND d.store_nbr NOT IN (3836) 
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15 
                                    AND b.dept_nbr IN(83,93) 
                                    AND c.type_code IN ('20') 
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A')
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.open_status NOT IN ('0','3','7')
                                    AND j.trait_nbr IN (297)
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER IN (20) 
                                    AND a.carry_option IN ('R') 
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    OR c.effective_date <= CURRENT_DATE -15 
                                    AND d.Open_date <= CURRENT_DATE -15  
                                    AND b.dept_nbr IN (81,98,94) 
                                    AND c.type_code IN ('20') 
                                    AND c.ordbk_flag IN ('Y') 
                                    AND c.status_code IN ('A')
                                    AND c.cancel_when_out_flag IN ('N') 
                                    AND c.itm_mbm_code IN ('M','I') 
                                    AND b.vendor_nbr NOT IN (18) 
                                    AND i.jda_vndr_stat_cd NOT IN (2) 
                                    AND d.store_nbr NOT IN (3836)
                                    AND j.trait_nbr IN (297)
                                    AND d.open_status NOT IN ('0','3','7') 
                                    AND c.ORDER_BOOK_SEQUENCE_NUMBER NOT IN (21) 
                                    AND a.carry_option IN ('R')  
                                    AND a.carried_status IN ('R') 
                                    AND b.Dept_nbr||c.type_code||c.ORDER_BOOK_SEQUENCE_NUMBER 
                                    NOT IN ('933721','83339','83401','83200','93221','833321','93070','81030','93030','83039','980789','93401','930787','810787',
                                    '933320','98379','83429','98221','93371','932021','83071','83220','81370', '83079','980797','81221','98070','810389',
                                    '983721','832021','98071','930714','98331','830714','812021','93409','813321','98079','98039','98200','83221','98371',
                                    '93071','93379','81201','930789','983321','83400','93420','83420','93200','83030','98339','81070','81200','81220','98370',
                                    '933321','93220','81331','98030','98220','83370','982021','93201','81071','83409','93039','83201','93331','81079','83421',
                                    '810789','81039','93421',     '83070','810714','980714','93079','93400')
                                    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) a ) a

                              LEFT JOIN(                                                                                                                                                      
                                        SELECT

                                          a.store_nbr AS DET,
                                          b.upc_nbr AS UPC, 
                                          b.old_nbr AS ITEM_NBR, 
                                          (SUM(sales_fcst_each_qty )/7)  AS SALES_FCST

                                        FROM wmt-edw-prod.MX_WM_VM.STORE_ITEM_FCST_WK_CONV a
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr)
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON ( b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
                                        INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                                        WHERE a.fcst_wm_yr_wk IN (SELECT DISTINCT wm_yr_wk FROM wmt-edw-prod.MX_WM_VM.CALENDAR_DAY WHERE gregorian_date = CURRENT_DATE)
                                        AND a.wm_yr_wk IN (SELECT DISTINCT wm_yr_wk FROM wmt-edw-prod.MX_WM_VM.CALENDAR_DAY WHERE gregorian_date = CURRENT_DATE)
                                        AND j.trait_nbr IN (297)
                                        GROUP BY 1,2,3 ) b ON (a.DET=b.DET AND a.UPC=b.UPC AND a.ITEM_NBR=b.ITEM_NBR)

                              LEFT JOIN (
                                          SELECT 

                                            a.store_nbr AS DET,
                                            b.upc_nbr AS UPC,
                                            b.old_nbr AS ITEM_NBR,
                                            SUM(a.on_hand_qty) AS OH_QTY,
                                            SUM(a.in_transit_qty) AS IT_QTY,
                                            SUM(a.IN_WAREHOUSE_QTY) AS IW_QTY,
                                            SUM(a.ON_ORDER_QTY) AS IO_QTY,
                                            SUM(a.on_hand_qty+a.in_transit_qty) AS OH_IT_QTY,
                                            SUM(a.on_hand_qty+a.in_transit_qty+a.IN_WAREHOUSE_QTY) AS OH_IT_IW_QTY,
                                            SUM(a.on_hand_qty+a.in_transit_qty+a.IN_WAREHOUSE_QTY+a.ON_ORDER_QTY) AS OH_IT_IW_IO_QTY

                                          FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.store_nbr = j.store_nbr)
                                          WHERE b.item_status_code IN ('A')
                                          AND c.obsolete_date > CURRENT_DATE
                                          AND j.trait_nbr IN (297)
                                          GROUP BY 1,2,3 ) c ON (a.DET=c.DET AND a.UPC=c.UPC AND a.ITEM_NBR=c.ITEM_NBR)

                                LEFT JOIN( 
                                          SELECT 

                                            a.BUSINESS_UNIT_NBR AS DET,
                                            b.upc_nbr AS UPC,
                                            b.old_nbr AS ITEM_NBR,
                                            SUM(a.RTFCST) AS INFO_FCST
                                          
                                          FROM wmt-edw-prod.MX_WM_VM.INFOREM_RECYCLE_DATA a
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr)
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON ( b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.BUSINESS_UNIT_NBR = e.store_nbr) 
                                          INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (a.BUSINESS_UNIT_NBR = j.store_nbr) 
                                          WHERE a.ft NOT IN ('X','E','I') 
                                          AND j.trait_nbr IN (297)
                                          GROUP BY 1,2,3 )d ON (a.DET=d.DET AND a.UPC=d.UPC AND a.ITEM_NBR=d.ITEM_NBR)

                                LEFT JOIN (
                                            SELECT          

                                              c.store_nbr AS DET,
                                              e.upc_nbr AS UPC,
                                              e.old_nbr AS ITEM_NBR,
                                              SUM(c.whpk_ordered_qty) AS PACKS_ORD,
                                              SUM(c.whpk_received_qty) AS PACKS_REC

                                            FROM wmt-edw-prod.MX_WM_VM.PURCHASE_ORDER a
                                            INNER JOIN  wmt-edw-prod.MX_WM_VM.PO_LINE b ON (a.po_nbr = b.po_nbr AND a.order_date = b.order_date)
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.PO_LINE_DISTRIBUTION c ON (a.po_nbr = c.po_nbr AND a.order_date = c.order_date)
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.item_nbr = d.item_nbr)
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM e ON ( d.old_nbr = e.old_nbr AND d.item_nbr = e.item_nbr) 
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (c.store_nbr = f.store_nbr) 
                                            INNER JOIN wmt-edw-prod.MX_WM_VM.TRAIT_STORE j ON (c.store_nbr = j.store_nbr)   
                                            WHERE a.cancel_date BETWEEN DATE_TRUNC(DATE_ADD(CURRENT_DATE('-06'), INTERVAL 1 WEEK), WEEK(MONDAY))-37 AND  DATE_TRUNC(DATE_ADD(CURRENT_DATE('-06'), INTERVAL 1 WEEK), WEEK(MONDAY))-10
                                            AND j.trait_nbr IN (297)
                                            AND a.po_status IN ('C')                                                   
                                            GROUP BY  1,2,3 ) e ON (a.DET=e.DET AND a.UPC=e.UPC AND a.ITEM_NBR=e.ITEM_NBR) )a )a )a

        GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16) a

WHERE NUMCAT IN ('90-11')
AND det in (2345,2033,2347,2464,3846,2466,4547,3877,1489,3851,3863,3862,3845,1107,3848,3858,3857,3872,2644,3852,5765,3847,1083,3790,5791,1202,5855,5825)

GROUP BY  1,2,3,4,5,6,7,8,9,10,11,12,13) AS B

ON (a.det1 = b.det
    AND a.UPC1 = b.UPC)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26