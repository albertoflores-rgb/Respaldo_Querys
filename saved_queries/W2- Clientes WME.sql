SELECT 
											
    g.Formato AS FORMATO,
    g.Squad AS SQUAD_LEAD,
    g.Distrito AS DISTRITO,
    g.Det AS DET,
    g.Tienda AS TIENDA,
    g.Type_Cluster AS TIPO_TIENDA,
    g.Nielsen AS NIELSEN, 
    g.Estado AS ESTADO,
    i.Tribu AS TRIBU,
    i.Squad AS SQUAD,
    c.Dept_nbr AS NUMDEPTO,
    h.NumDepartamento AS DEPARTAMENTO,
    CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    i.NumCategoria AS CATEGORIA,
    c.Fineline_nbr AS NUMFL,
    j.NumFineline AS FINELINE,
    c.upc_nbr AS UPC,
    c.old_nbr AS ITEM_NBR,
    c.item1_desc AS ITEM_DESC1,
    c.item2_desc AS ITEM_DESC2,
    c.signing_desc AS SIGNING_DESC,
    e.WM_MONTH AS WM_MONTH,
    e.FISCAL_YEAR AS YEAR,
    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES

FROM wmt-edw-prod.MX_WM_MB_VM.SCAN a
INNER JOIN wmt-edw-prod.MX_WM_MB_VM.VISIT b ON (a.visit_nbr=b.visit_nbr AND a.store_nbr=b.store_nbr AND a.visit_date=b.visit_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM c ON (a.scan_id = c.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.ITEM_DESC d ON (c.old_nbr = d.old_nbr AND c.item_nbr = d.item_nbr) 
INNER JOIN wmt-edw-prod.MX_WM_VM.CALENDAR_DAY e ON (a.visit_date = e.gregorian_date AND b.visit_date = e.gregorian_date)
INNER JOIN wmt-edw-prod.MX_WM_VM.STORE_INFO f ON (a.store_nbr = f.store_nbr) 
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_STORES_AUTOSERVICES g ON (a.store_nbr = g.Det)
INNER JOIN wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_DEPARTMENT_AUTOSERVICES h ON (c.dept_nbr = h.NumDepto) 
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_CATEGORY_AUTOSERVICES i ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2))=i.NumCat)
LEFT JOIN  wmt-edw-sandbox.WM_AD_HOC_MX.CATALOGUE_FINELINE_AUTOSERVICES j ON (c.Dept_nbr=j.NumDepto AND c.Fineline_nbr=j.NumFl)
WHERE e.gregorian_date BETWEEN DATE '2024-01-01' AND  CURRENT_DATE
--AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
--AND c.order_dept_nbr IN (46,40,69,28,38,26,8,2)
--AND i.tribu IN ("SALUD Y BIENESTAR")
AND g.Formato IN ('WALMART EXPRESS')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23