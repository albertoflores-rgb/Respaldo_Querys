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
    i.CLASIFICACION_TIENDA as CLASIFICACION_TIENDA,
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
    i.TIPO as TIPO_RESURTIDO,

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
    SUM(i.ACUM_LT) AS ACUM_LT,
    COUNT(DISTINCT e.Det) AS NUMTIENDAS

FROM wmt-edw-prod.MX_WM_VM.STOCK_KEEPING_UNIT a
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM b ON (a.item_nbr = b.old_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC c ON (b.old_nbr = c.old_nbr AND b.item_nbr = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO d ON (a.store_nbr = d.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto and b.Fineline_nbr=h.NumFl)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.SUPPLY_CHAIN_DB i ON (b.old_nbr = i.old_nbr AND a.store_nbr = i.store_nbr and I.FECHA_ACT = '2026-01-01')

WHERE 
a.store_nbr in (2344)


GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35