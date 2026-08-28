SELECT 
                                            
    f.Formato AS FORMATO,
    --f.Squad AS SQUAD_LEAD,
    --f.Distrito AS DISTRITO,
    --f.Det AS DET,
    --f.Tienda AS TIENDA,
    --f.Type_Cluster AS TIPO_TIENDA,
    --f.TYPE_TIENDA AS SEGMENTO,
    --f.Nielsen AS NIELSEN, 
    --f.Estado AS ESTADO,
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
    c.vendor_nbr AS VENDOR,
    c.Vendor_name AS VND_Name,
    b.signing_desc AS SIGNING_DESC,
    C.Type_Code AS TIPO_ITEM,
    c.STATUS_CODE AS STATUS_CODE,
    c.EFFECTIVE_DATE,

    --j.COST AS Costo_Unitario,
    --a.WM_YR_WK AS WM_WEEK,
    --d.WM_MONTH AS WM_MONTH,
    --d.FISCAL_YEAR AS YEAR,
    SUM(a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) AS VENTA_PIEZAS_YTD,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * a.sell_price) AS VENTA_PESOS_YTD,
    SUM((a.sat_qty * d.sat_mult +a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult +a.wed_qty * d.wed_mult + a.thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) * j.Cost) AS COSTO_YTD,
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
    COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_TIENDA = "TIPO DEPARTAMENTAL" )THEN f.DET||''||b.UPC_nbr END)),0) AS ALTA_DEPARTAMENTAL,
    --COALESCE(SUM(CASE WHEN(f.TYPE_CLUSTER = "PREMIUM") THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.   thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0)/COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_CLUSTER = "GENERAL" )THEN f.DET||''||b.UPC_nbr END)),0) AS Velocity_General,
    --COALESCE(SUM(CASE WHEN(f.TYPE_CLUSTER = "PREMIUM") THEN (a.sat_qty * d.sat_mult + a.sun_qty * d.sun_mult +a.mon_qty * d.mon_mult + a.tue_qty * d.tue_mult + a.wed_qty * d.wed_mult + a.   thu_qty * d.thu_mult + a.fri_qty * d.fri_mult) END),0)/COALESCE(COUNT(DISTINCT(CASE WHEN(f.TYPE_CLUSTER = "PREMIUM" )THEN f.DET||''||b.UPC_nbr END)),0) AS Velocity_Premium


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
and e.store_nbr in (1584,
1622,
2342,
4978,
3253,
3114,
3848,
2689,
2034,
2382,
2989,
2431,
1016,
5241,
1617,
3845,
6338,
4012,
6275,
5297,
1083,
2302,
6390,
3504,
3358,
6224,
6395,
3030,
2344,
4972,
4137,
1801,
6229,
3211,
2053,
4989,
4011)
AND h.tribu IN ("SALUD Y BIENESTAR","MG","FOOD")
AND f.Formato IN ('SUPERCENTER')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19--,20,21,22,23,24
