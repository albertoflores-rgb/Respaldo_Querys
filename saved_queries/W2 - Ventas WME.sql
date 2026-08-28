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
    j.COST AS Costo_Unitario,
    --a.WM_YR_WK AS WM_WEEK,
    d.WM_MONTH AS WM_MONTH,
    d.FISCAL_YEAR AS YEAR,
    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_YTD,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_YTD,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * j.Cost) AS COSTO_YTD,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = EXTRACT(MONTH FROM CURRENT_DATE)) THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0) AS VENTA_PIEZAS_MTD,
    COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = EXTRACT(MONTH FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) END),0) AS VENTA_PESOS_MTD,
        COALESCE(SUM(CASE WHEN (EXTRACT(MONTH FROM d.gregorian_date) = EXTRACT(MONTH FROM CURRENT_DATE)) THEN ((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * j.COST) END),0) AS COSTO_MTD,
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


FROM wmt-edw-prod.MX_WM_VM.SKU_DLY_POS a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY d ON (a.wm_yr_wk = d.wm_yr_wk)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO e ON (a.store_nbr = e.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES f ON (a.store_nbr = f.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES g ON (b.dept_nbr = g.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES h ON (CONCAT(b.Dept_nbr,"-",SUBSTRING(CAST(b.Fineline_nbr AS STRING),1,2))=h.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES i ON (b.Dept_nbr=i.NumDepto and b.Fineline_nbr=i.NumFl)
LEFT JOIN wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT j ON (j.item_nbr = c.old_nbr AND j.store_nbr = a.store_nbr)

WHERE d.gregorian_date BETWEEN DATE '2024-01-01' AND  CURRENT_DATE
--AND c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,
                         --58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
--AND c.order_dept_nbr IN (46,40,69,28,38,26,8,2)
--AND h.tribu IN ("SALUD Y BIENESTAR")
AND f.Formato IN ('WALMART EXPRESS')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24

--Limit 100
