SELECT 
                                            
    e.Formato AS FORMATO,
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
    b.upc_nbr AS UPC,
    b.old_nbr AS ITEM_NBR,
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
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES e ON (a.store_nbr = e.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES f ON (b.dept_nbr = f.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES g ON (CONCAT(Dept_nbr,"-",SUBSTRING(CAST(Fineline_nbr AS STRING),1,2))  = g.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES h ON (b.Dept_nbr=h.NumDepto and b.Fineline_nbr=h.NumFl)
WHERE c.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,
                           58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98) 
                           --AND c.order_dept_nbr IN (46,40,69,28,38,26,8,2)
AND g.tribu IN ("SALUD Y BIENESTAR")
AND b.item_status_code IN ('A','I','D')
AND e.Formato IN ('SUPERCENTER')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
