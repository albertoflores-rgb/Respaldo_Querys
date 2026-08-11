SELECT 
											
    g.Formato AS FORMATO,
    g.Squad AS SQUAD_LEAD,
    g.Distrito AS DISTRITO,
    g.Det AS DET,
    g.Tienda AS TIENDA,
    g.Type_Cluster AS TIPO_TIENDA,
    g.Nielsen AS NIELSEN, 
    g.Estado AS ESTADO,
    --i.Tribu AS TRIBU,
    --i.Squad AS SQUAD,
    --c.Dept_nbr AS NUMDEPTO,
    --h.NumDepartamento AS DEPARTAMENTO,
    k.string_field_4 AS Mundo,



    --CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2)) AS NUMCAT,
    --i.NumCategoria AS CATEGORIA,
    --c.Fineline_nbr AS NUMFL,
    --j.NumFineline AS FINELINE,
    --c.upc_nbr AS UPC,
    --c.old_nbr AS ITEM_NBR,
    --c.item1_desc AS ITEM_DESC1,
    --c.item2_desc AS ITEM_DESC2,
    --c.signing_desc AS SIGNING_DESC,

    COUNT(DISTINCT a.store_nbr||''||a.visit_nbr)AS CLIENTES,
    COALESCE(COUNT(DISTINCT(CASE WHEN (e.gregorian_date BETWEEN DATE '2024-01-01' AND  '2024-05-31') THEN (a.store_nbr||''||a.visit_nbr) END)),0) AS Clientes_PreSOTF_LY,
    COALESCE(COUNT(DISTINCT(CASE WHEN (e.gregorian_date BETWEEN DATE '2024-06-01' AND  '2024-07-31') THEN (a.store_nbr||''||a.visit_nbr) END)),0) AS Clientes_Implementacion_LY,
    COALESCE(COUNT(DISTINCT(CASE WHEN (e.gregorian_date BETWEEN DATE '2024-08-01' AND  '2025-01-31') THEN (a.store_nbr||''||a.visit_nbr) END)),0) AS Clientes_Medicion_LY,

    COALESCE(COUNT(DISTINCT(CASE WHEN (e.gregorian_date BETWEEN DATE '2025-01-01' AND  '2025-05-31') THEN (a.store_nbr||''||a.visit_nbr) END)),0) AS Clientes_PreSOTF_TY,
    COALESCE(COUNT(DISTINCT(CASE WHEN (e.gregorian_date BETWEEN DATE '2025-06-01' AND  '2025-07-31') THEN (a.store_nbr||''||a.visit_nbr) END)),0) AS Clientes_Implementacion_TY,
    COALESCE(COUNT(DISTINCT(CASE WHEN (e.gregorian_date BETWEEN DATE '2025-08-01' AND  '2026-01-31') THEN (a.store_nbr||''||a.visit_nbr) END)),0) AS Clientes_Medicion_TY,

  

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
LEFT JOIN wmt-edw-sandbox.Black_Bird.Finelines_SOTF k ON (CONCAT(c.Dept_nbr,"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,2),"-",SUBSTRING(CAST(c.Fineline_nbr AS STRING),1,4))=k.string_field_2)

WHERE e.gregorian_date BETWEEN DATE '2024-01-01' AND  Current_Date
--AND d.order_dept_nbr IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,40,46,47,49,54,56,58,60,69,80,81,82,83,85,87,88,90,91,92,93,94,95,96,97,98)
--AND c.order_dept_nbr IN (46,40,69,28,38,26,8,2)
--AND i.tribu IN ("SALUD Y BIENESTAR")
AND g.Det IN (1139,
1833,
2044,
3114,
3239,
1027,
1833,
2676,
3051,
3800,
1686,
1512,
2541,
4012,
4071,
2033,
2079,
3005,
3794,
3857,
3847,
1032,
3504,
1580,
2466,
2644,
2464,
3005,
3851,
1834,
3872,
3877,
3858,
3876,
3847,
3863,
3846,
2034,
3720,
1810,
4547,
1584,
1770,
2344,
2382,
3845)
AND g.Formato IN ('SUPERCENTER')
GROUP BY 1,2,3,4,5,6,7,8,9--,10--,11,12,13